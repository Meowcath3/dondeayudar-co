-- dondeayudar.co — Supabase schema + seed data
-- Run this once in the Supabase SQL editor (or via the Supabase MCP connector).

create extension if not exists pgcrypto;

create table if not exists public.points (
  id uuid primary key default gen_random_uuid(),
  city text not null,
  name text not null,
  address text not null,
  accepts text not null,
  whatsapp text not null default '',
  instagram text not null default '',
  donation text not null default '',
  note text not null default '',
  verified boolean not null default false,
  source text not null default '',
  source_type text not null default 'community' check (source_type in ('curated','community')),
  created_at timestamptz not null default now()
);

alter table public.points enable row level security;

drop policy if exists "public can read points" on public.points;
create policy "public can read points" on public.points for select using (true);

-- Anyone can add a physical point, but the policy itself enforces the site's rules:
-- no whatsapp/instagram/donation links, no payment/Nequi/bank text anywhere in the
-- submission, and the category has to be one of the fixed labels from the form.
drop policy if exists "public can add community points" on public.points;
create policy "public can add community points" on public.points for insert
with check (
  source_type = 'community'
  and verified = false
  and whatsapp = ''
  and instagram = ''
  and donation = ''
  and source = ''
  and accepts in (
    'alimentos y agua','aseo e higiene','ropa, cobijas y abrigo',
    'alimentos y artículos para mascotas','salud, medicamentos y primeros auxilios',
    'todo menos plata'
  )
  and name !~* '(nequi|daviplata|banco|bancolombia|davivienda|cuenta|transferenc|pago|paypal|\yqr\y|bitcoin|cripto|whatsapp|instagram|facebook|tiktok|https?:|www\.|@|\.com|\.co)'
  and address !~* '(nequi|daviplata|banco|bancolombia|davivienda|cuenta|transferenc|pago|paypal|\yqr\y|bitcoin|cripto|whatsapp|instagram|facebook|tiktok|https?:|www\.|@|\.com|\.co)'
  and city !~* '(nequi|daviplata|banco|bancolombia|davivienda|cuenta|transferenc|pago|paypal|\yqr\y|bitcoin|cripto|whatsapp|instagram|facebook|tiktok|https?:|www\.|@|\.com|\.co)'
);

-- No update/delete policies are defined, so nobody (anon or otherwise) can edit or remove
-- a point through the public API — only via the Supabase dashboard with the service key.

-- ---- seed data: the 151 curated / verified points already gathered ----
insert into public.points (city,name,address,accepts,whatsapp,instagram,donation,note,verified,source,source_type) values
('Cali','IPUC Paso Ancho','Cra 56 # 12A-125','Alimentos no perecederos','','','','Disponible 11, 13, 15 y 16 de agosto',false,'','curated'),
('Tolima','Cuerpo de Bomberos','Calle 3 # 8-21','Alimentos no perecederos, útiles de cocina, aseo personal, ropa, frazadas','573209171113','','','',false,'','curated'),
('Cali','Gobernación del Valle del Cauca','Cra 1 #26-85','Todo menos plata; también reciben comida para mascotas','','gobvalle','','',false,'','curated'),
('Cali','Gobernación del Valle del Cauca — Punto para animales','Cra 56 # 7 Oeste-445','Comida y medicamentos para animales, cobijas, artículos de aseo, mallas, camas','','gobvalle','','Atienden todos los días después de las 9:00 a.m.',false,'','curated'),
('Trujillo (Valle del Cauca)','Alcaldía de Trujillo — Jardín del Valle','Calle 10 #19-08 y Calle 18 #18-16','Comida, agua, abrigo, higiene, primeros auxilios','','','','',false,'','curated'),
('Bogotá','Casa del Valle en Bogotá','Calle 34 #5-50','Todo menos plata; también reciben comida para mascotas','','','','',false,'','curated'),
('Candelaria (Valle del Cauca)','Parroquia Nuestra Señora de la Candelaria','Cra 7 #9-56','Todo menos plata; también reciben comida para mascotas','','','','',false,'','curated'),
('El Cairo (Valle del Cauca)','Instituto Técnico María Auxiliadora','Cra 14 #7-31','Todo menos comida para mascotas','','','','',false,'','curated'),
('Suesca (Cundinamarca)','Alcaldía de Suesca','Centro de Vida Sensorial (piso 1) y Secretaría de Desarrollo Social','Todo menos plata; también reciben comida para mascotas','','','','',false,'','curated'),
('Bogotá','Fundación Cigarra','Calle 71Q Sur #27-60','Todo tipo de ayuda','573212465421','fundacioncigarra','https://www.cigarra.org/?view_full_site=true','',false,'','curated'),
('La Cumbre (Valle del Cauca)','Alcaldía de La Cumbre','Estación de Bomberos de La Cumbre','Todo menos plata','','','','',false,'','curated'),
('Buenaventura','Corporación Manglaria','Carrera 56B #5-92','Todo tipo de ayuda','','manglariapacifico','https://www.corporacionmanglaria.org/','También reciben albergue temporal y atención psicosocial',false,'','curated'),
('Palmira','Oficina Pastoral de Palmira','Carrera 36 #36-39, C.C. Llanogrande y Unicentro Palmira','Todo menos plata','','','','',false,'','curated'),
('Pradera (Valle del Cauca)','Institución Educativa Alfredo Posada Correa','Carrera 13 Calle 11 #11-00, vía La Tupia (Barrio Bello Horizonte)','Todo tipo de ayuda','','','','',false,'','curated'),
('Santa Rosa de Cabal','Cuerpo de Bomberos Voluntarios','Carrera 15 con Calle 11, esquina','Todo menos plata','573506977228','bomberossantarosadecabal','','',false,'','curated'),
('Venecia (Antioquia)','Casa de Kiko','Cra 52 #54-65','Todo menos plata','','','','',false,'','curated'),
('Belén de Umbría','Alcaldía Municipal de Belén de Umbría','Estación de bomberos','Todo menos plata','','','','',false,'','curated'),
('Albán (Cundinamarca)','Alcaldía de Albán','Oficina de Desarrollo Social y Centro de Vida Sensorial','Todo menos plata','573177407814','alcaldiaalban','','',false,'','curated'),
('Campoalegre (Huila)','Fundación Dejando Huellas Felices','Calle 29 #12-50, Barrio El Viso','Todo menos plata','','fundaciondejandohuellasfelices','','',false,'','curated'),
('Manta (Cundinamarca)','Policía Nacional — Sede Manta','Cra 5 #2-08','Todo menos plata','573223483621','','','',false,'','curated'),
('Lérida (Tolima)','Electroiluminaciones del Tolima','Calle 8 #4-25 y Calle 8 #4-31 (consultorio de odontología)','Todo menos plata','','','','',false,'','curated'),
('Istmina (Chocó)','Fundación Unisocial','Iglesia Universal de Istmina','Todo menos plata','','','','',false,'','curated'),
('Bogotá','Centro García Márquez','Calle 12B #3-17','Todo menos plata','573203641275','','','',false,'','curated'),
('Bucaramanga','Bodega Portón Azul','Calle 23 #12-52, Barrio Girardot','Todo menos plata','','','','',false,'','curated'),
('Bucaramanga','Libardog','Cra 27A #45A-16, Sotomayor','Todo menos plata','','libardog_bga','','',false,'','curated'),
('Bucaramanga','Alicia Wonderland','Cra 37 #53-43, Cabecera','Todo menos plata','','aliciacomco','','',false,'','curated'),
('Bucaramanga','Don Lucho Lechonería — Sotomayor','Cl. 45 #24-95','Todo menos plata','','donlucholechoneria','','Horario: 9:00 a.m. – 9:00 p.m.',false,'','curated'),
('Bucaramanga','Don Lucho — Caracolí','Plazoleta de comidas, Local 411','Todo menos plata','','donlucholechoneria','','',false,'','curated'),
('Bucaramanga','Don Lucho — De la Cuesta','Plazoleta de comidas, Local 234','Todo menos plata','','donlucholechoneria','','',false,'','curated'),
('Bucaramanga','Moufflet — Nuevo Sotomayor','Cra 23 #51-77','Todo menos plata','','moufflet30','','',false,'','curated'),
('Bucaramanga','Moufflet — Cabecera','Cra 35 #54-51','Todo menos plata','','moufflet30','','',false,'','curated'),
('Bucaramanga','Moufflet — Cañaveral','Calle 31 #22-279','Todo menos plata','','moufflet30','','',false,'','curated'),
('Bucaramanga','Neomundo','Punto Neomundo','Todo menos plata','','','','',false,'','curated'),
('Itagüí','Consejo Municipal de Juventudes de Itagüí','Parque principal de Itagüí','Todo menos plata','','cmj_itagui','','Disponible martes 11 y miércoles 12 de agosto, 10:00 a.m. – 5:00 p.m.',false,'','curated'),
('Bogotá','Fundación Galería Aborigen','Cra. 6A #116-17','Todo tipo de ayuda','','galeriaaborigen','https://www.gofundme.com/f/ayudas-para-las-comunidades-indigenas-del-choco','Ayuda directa a comunidades indígenas del Chocó',false,'','curated'),
('Medellín','Fundación Banco Arquidiocesano de Alimentos de Medellín (FUBAM)','Belén, Carrera 52 #30A-97','Alimentos','','','','',true,'https://qhubomedellin.com/util-para-vos/donde-entregar-donaciones-para-terremoto-en-medellin-PA39825381','curated'),
('Medellín','Fundación Saciar','Carrera 50 #25-329','Alimentos','','','','Punto oficial de la red de 10 puntos de la Alcaldía de Medellín',true,'https://qhubomedellin.com/util-para-vos/donde-entregar-donaciones-para-terremoto-en-medellin-PA39825381','curated'),
('Medellín','Restaurante Belisario','Sede Provenza y sede C.C. El Tesoro (oficina: Calle 7 #35-44)','Alimentos','','','','',false,'','curated'),
('Medellín','Librería Rodante Delfos','Laureles, Calle 79 #52A-23','Alimentos','','','','',false,'','curated'),
('Medellín','Fundación El Arte de los Sueños','Perpetuo Socorro, Cra 48 #35-47','Alimentos','','','','Lun/Mié/Vie 8:30 a.m.–12:00 p.m. · Mar/Jue 8:30 a.m.–4:00 p.m.',false,'','curated'),
('Medellín','Batallón Girardot','Calle 66E #39-84','Alimentos','','','','',false,'','curated'),
('Itagüí','Parque principal de Itagüí','Parque principal','Alimentos','','','','Disponible martes 11 y miércoles 12 de agosto, 10:00 a.m.–5:00 p.m.',false,'','curated'),
('Medellín','Casa Eterna','Calle 23 Sur #3-133, La Esplanada (vía Las Palmas)','Alimentos','','','','Lun–Dom, 2:00 p.m.–6:00 p.m.',false,'','curated'),
('Bogotá','Banco de Alimentos de Bogotá','Calle 19A #32-25','Alimentos','','','https://www.bancodealimentos.org.co','Donación en línea · Llave Bre-B: 0091677852',false,'','curated'),
('Cali','Banco de Alimentos de Cali','Calle 24 #6-103, Barrio San Nicolás','Alimentos','','','','',false,'','curated'),
('Cali','Plazoleta Jairo Varela','Punto habilitado por la Alcaldía de Cali','Todo menos plata','','','','',false,'','curated'),
('Buenaventura','Banco de Alimentos de Buenaventura','Av. Simón Bolívar #47C-70, interior Colegio Seminario','Alimentos','','','','',false,'','curated'),
('Manizales','Banco de Alimentos','Calle 49 #27A-85','Alimentos','','','','',false,'','curated'),
('Pereira / Dosquebradas','Café Consulta','Pereira / Dosquebradas','Alimentos','','','','',false,'','curated'),
('Pereira / Dosquebradas','Café Perla del Otún','Pereira / Dosquebradas','Alimentos','','','','',false,'','curated'),
('Pereira / Dosquebradas','Café El Remanso','Pereira / Dosquebradas','Alimentos','','','','',false,'','curated'),
('Pereira / Dosquebradas','Café Kennedy','Pereira / Dosquebradas','Alimentos','','','','',false,'','curated'),
('Pereira / Dosquebradas','Café Ormaza','Pereira / Dosquebradas','Alimentos','','','','',false,'','curated'),
('Pereira / Dosquebradas','Café San Nicolás','Pereira / Dosquebradas','Alimentos','','','','',false,'','curated'),
('Pereira / Dosquebradas','Café Comuna 9','Pereira / Dosquebradas','Alimentos','','','','',false,'','curated'),
('Dosquebradas','Parroquia San Marcos Evangelista','Barrio Santa Isabel','Alimentos','','','','',false,'','curated'),
('Armenia','Banco de Alimentos Monseñor Roberto López Londoño','Calle 21 #12-25','Alimentos','','','','',false,'','curated'),
('Ibagué','Banco Arquidiocesano de Alimentos de Ibagué','Carrera 4 con Estadio, #23-42/44','Alimentos','','','','',false,'','curated'),
('Bogotá','Cruz Roja — SAMU Sur','Avenida Carrera 68 #31-41 Sur','Todo menos plata','','','','',false,'','curated'),
('Bogotá','Cruz Roja — SAMU Norte','Calle 134, Carrera 7B Bis #132-32','Todo menos plata','','','','',false,'','curated'),
('Bogotá','Cruz Roja — Centro de Salvamento Acuático','Avenida La Esmeralda #63-81','Todo menos plata','','','','',false,'','curated'),
('Bogotá','Cruz Roja — Sede administrativa','Carrera 24 #73-38','Todo menos plata','','','','Atención las 24 horas',false,'','curated'),
('Bogotá','Cruz Roja — Bodega','Diagonal 79B #62-53','Todo menos plata','','','','',false,'','curated'),
('Bogotá','Cruz Roja — Palacio de los Deportes','Calle 63 #59A-06','Todo menos plata','','','','',false,'','curated'),
('Bogotá','Cruz Roja — Universidad Jorge Tadeo Lozano','Carrera 4 #22-61','Todo menos plata','','','','Horario: 8:00 a.m.–9:00 p.m., todos los días',false,'','curated'),
('Bogotá','Cruz Roja — Usaquén','Calle 161A #7F-55','Todo menos plata','','','','Horario: 8:00 a.m.–9:00 p.m., todos los días',false,'','curated'),
('Bogotá','Cruz Roja — Unicentro','Carrera 15 #124-30','Todo menos plata','','','','Horario: 8:00 a.m.–9:00 p.m., todos los días',false,'','curated'),
('Cali','Banco de Sangre HUV','Calle 5 #36-08, urgencias del Hospital Universitario del Valle','Donación de sangre','','','','',false,'','curated'),
('Cali','Banco de Sangre Hemolife','Calle 38N #3N-21, Prados del Norte','Donación de sangre','','','','',false,'','curated'),
('Cali','Banco de Sangre Cruz Roja Valle','Parqueadero Cruz Roja Valle, Carrera 38 Bis #5B, San Fernando','Donación de sangre','','','','',false,'','curated'),
('Cali','Banco de Sangre Fundación Valle del Lili','Sede principal, Torre 2, Piso 4','Donación de sangre','','','','',false,'','curated'),
('Cali','Banco de Sangre Imbanaco','Sede principal, Carrera 38 Bis #5B2-04, Santa Isabel','Donación de sangre','','','','',false,'','curated'),
('Bogotá','Banco Distrital de Sangre de Bogotá','Puntos de donación indicados por la Cruz Roja Colombiana','Donación de sangre (se necesita con urgencia O+ y O-)','','banconacionaldesangre','','',false,'','curated'),
('Quibdó','Centro Logístico Humanitario del Departamento del Chocó','Antigua Bodega Postobón, Km 4 vía Quibdó–Yuto','Personal de salud, medicamentos, kits de emergencia, jeringas, guantes, gasas, líquidos intravenosos, esparadrapo, linternas','573104820430','','','',false,'','curated'),
('Ibagué','Universidad del Tolima','Universidad del Tolima','Alimentos no perecederos, alimentos para mascotas, agua potable, aseo personal, frazadas, juegos didácticos','','','','',false,'','curated'),
('San Gil','Ministerio Casa Sobre la Roca','Calle 21 #6B-44, Rojas Pinilla','Todo menos plata','573168280661','','','Horario: 7:00 a.m.–9:00 p.m.',false,'','curated'),
('Barbosa (Santander)','Ministerio Casa Sobre la Roca','Cra 7 #11-62, Barrio Samán','Todo menos plata','573155584196','','','Horario: 7:00 a.m.–9:00 p.m.',false,'','curated'),
('Barrancabermeja','Ministerio Casa Sobre la Roca','Km 1 vía al Retén, antigua bomba Santander','Todo menos plata','573103377891','','','Horario: 7:00 a.m.–9:00 p.m.',false,'','curated'),
('Sabana de Torres','Ministerio Casa Sobre la Roca','Calle 19 #19-51','Todo menos plata','573008411458','','','Horario: 7:00 a.m.–9:00 p.m.',false,'','curated'),
('San Gil','Secretaría de Gestión Social y Salud','Primer piso, Alcaldía Municipal de San Gil','Guantes de trabajo, cascos, gafas de protección, tapabocas, linternas, baterías/power banks, botiquines, artículos de higiene y bioseguridad, baldes, picas y herramientas manuales, cobijas limpias','','','','Plazo: 11 de agosto, 7:00 p.m.',false,'','curated'),
('Bucaramanga','Punto de Acopio — Cabecera','Cra 35 #44-42','Todo menos plata','','','','',false,'','curated'),
('Bucaramanga','Punto de Acopio — Ciudadela','Centro Comercial Acrópolis','Todo menos plata','','','','',false,'','curated'),
('Barrancabermeja','Punto de Acopio — Colombia','Cra 19 #49-37','Todo menos plata','','','','',false,'','curated'),
('Bucaramanga','Punto de Acopio — Coltabaco','Cra 26 #35-63','Todo menos plata','','','','',false,'','curated'),
('Floridablanca','Punto de Acopio — Floridablanca','Cra 8 #3-61','Todo menos plata','','','','',false,'','curated'),
('Floridablanca','Punto de Acopio — Gaira','Cl. 157 #154-137','Todo menos plata','','','','',false,'','curated'),
('Bucaramanga','Punto de Acopio — K-27','Cra 27 #19-40','Todo menos plata','','','','',false,'','curated'),
('Floridablanca','Punto de Acopio — La 200','Cl. 200 #10-23','Todo menos plata','','','','',false,'','curated'),
('Piedecuesta','Punto de Acopio — Piedecuesta','Cra 6 #9-76','Todo menos plata','','','','',false,'','curated'),
('Bucaramanga','Punto de Acopio — Puerta del Sol','Cra 27 #65-55','Todo menos plata','','','','',false,'','curated'),
('Floridablanca','Punto de Acopio — Ruitoque','Aldea Comercial Ruitoque','Todo menos plata','','','','',false,'','curated'),
('Piedecuesta','Punto de Acopio — Nativos Piedecuesta','Mall Río del Hato, Local 15','Todo menos plata','','','','',false,'','curated'),
('Floridablanca','Punto de Acopio — KM3 Anillo Vial','Edificio Suiza Vita (recepción)','Todo menos plata','','','','',false,'','curated'),
('Manizales','FOSU — Iglesia San Antonio','Calle 17 #26-37','Alimentos no perecederos, agua embotellada, artículos de aseo personal, ropa en buen estado, cobijas y frazadas, medicamentos (no vencidos)','573104938994','','','Más información: Adrian Colorado 310 493 8994 · Libardo Díaz 312 758 6521 · Mauricio Caicedo 312 503 4200',false,'','curated'),
('Dosquebradas','FOSU — Barrio Bombay','Carrera 12 con Calle 62, esquina','Alimentos no perecederos, agua embotellada, artículos de aseo personal, ropa en buen estado, cobijas y frazadas, medicamentos (no vencidos)','573104938994','','','Más información: Adrian Colorado 310 493 8994 · Libardo Díaz 312 758 6521 · Mauricio Caicedo 312 503 4200',false,'','curated'),
('Pereira','FOSU — Barrio Samaria','Calle 33A con Carrera 32','Alimentos no perecederos, agua embotellada, artículos de aseo personal, ropa en buen estado, cobijas y frazadas, medicamentos (no vencidos)','573104938994','','','Más información: Adrian Colorado 310 493 8994 · Libardo Díaz 312 758 6521 · Mauricio Caicedo 312 503 4200',false,'','curated'),
('Armenia','FOSU — Sede Segunda','Calle 36 #25-18, Barrio Santander','Alimentos no perecederos, agua embotellada, artículos de aseo personal, ropa en buen estado, cobijas y frazadas, medicamentos (no vencidos)','573104938994','','','Más información: Adrian Colorado 310 493 8994 · Libardo Díaz 312 758 6521 · Mauricio Caicedo 312 503 4200',false,'','curated'),
('Armenia','Institución Educativa Fundanza','Calle 19 #27-40, Barrio San José','Artículos de aseo (jabón, shampoo, papel higiénico, crema dental, cepillos de dientes), alimentos no perecederos (arroz, granos, pasta, enlatados, aceite, harina), agua potable','','','','',false,'','curated'),
('Cúcuta','Familia Plátanos — Plátano Verdes','Conjunto Portal Boconó, Local 2, anillo vial antes de Postobón','Alimentos e insumos (no reciben ropa)','573123392032','','','Luego trasladan las donaciones a un centro verificado',false,'','curated'),
('Cúcuta','Banco de Alimentos — Diócesis de Cúcuta','Parroquias de la Diócesis, Barrio Pescadero y Centro Comercial Ventura Plaza','Alimentos no perecederos, productos de aseo, colchonetas, tendidos y toallas','','','','',false,'','curated'),
('Cúcuta','Biblioteca Pública Julio Pérez Ferrero','Av. 1 #12-35, La Playa','Alimentos no perecederos, medicamentos, insumos de primeros auxilios, artículos de baño e higiene, carpas, linternas, pilas, cobijas, impermeables, colchonetas','','','','Horario extendido',false,'','curated'),
('Medellín','UdeA — Oficina AfroUdeA, Bloque 9','Universidad de Antioquia, Bloque 9','Todo menos plata','573114505940','','','Horario: lunes a viernes, 9:00 a.m.–5:00 p.m.',false,'','curated'),
('Medellín','Universidad EAFIT','Carrera 49 #7 Sur-50 (placa cubierta)','Todo menos plata','','','','Horario: lunes a viernes, 7:00 a.m.–6:00 p.m.',true,'https://qhubomedellin.com/util-para-vos/donde-entregar-donaciones-para-terremoto-en-medellin-PA39825381','curated'),
('Medellín','Simón Coffee','Cra 37 #10-54','Todo menos plata','','','','',false,'','curated'),
('Medellín','Hall — Alcaldía de Medellín','Alcaldía de Medellín','Todo menos plata','','','','',true,'https://qhubomedellin.com/util-para-vos/donde-entregar-donaciones-para-terremoto-en-medellin-PA39825381','curated'),
('Medellín','Remanence','Calle 10B #35-27','Todo menos plata','','','','Horario: lunes a domingo, 11:00 a.m.–5:30 p.m.',false,'','curated'),
('Medellín','Bodega Guayaquiliando','Avenida 80 #52-88','Todo menos plata','','','','',false,'','curated'),
('Medellín','La Razón','Calle 44 #42-70','Todo menos plata','','','','',false,'','curated'),
('Bogotá','Laika Mascotas — Calle 116','Av. Calle 116 #18B-43','Alimentos y artículos para mascotas','','laikamascotas','','',false,'','curated'),
('Bogotá','Laika Mascotas — Chapinero','Ak. 7 #59-34','Alimentos y artículos para mascotas','','laikamascotas','','',false,'','curated'),
('Bogotá','Laika Mascotas — Modelia','Av. Calle 24 #74A-57','Alimentos y artículos para mascotas','','laikamascotas','','',false,'','curated'),
('Bogotá','Laika Mascotas — La 19','Calle 94 #13-73','Alimentos y artículos para mascotas','','laikamascotas','','',false,'','curated'),
('Cali','Laika Mascotas — Capri','Calle 13 #75-110','Alimentos y artículos para mascotas','','laikamascotas','','',false,'','curated'),
('Cali','Laika Mascotas — Pance','Calle 18 #12-82','Alimentos y artículos para mascotas','','laikamascotas','','',false,'','curated'),
('Medellín','Laika Mascotas — Agua Bendita','Calle 2 Sur #32-54','Alimentos y artículos para mascotas','','laikamascotas','','',false,'','curated'),
('Medellín','Laika Mascotas — Arkadia','Carrera 70 #1-141','Alimentos y artículos para mascotas','','laikamascotas','','',false,'','curated'),
('Llanogrande (Antioquia)','Laika Mascotas — Llanogrande','Llanogrande, Antioquia','Alimentos y artículos para mascotas','','laikamascotas','','',false,'','curated'),
('Colombia — todas las ciudades','Laika Mascotas','Consulta el perfil para encontrar el punto más cercano','Alimentos y artículos para mascotas','','laikamascotas','','',false,'','curated'),
('Pereira','Fundación Siempre a Tu Lado','Consulta el perfil para donar o ayudar','Alimentos y apoyo para animales','','siempreatulado_albergue','','',false,'','curated'),
('Bogotá','Fundación Kenovy Colombia','Consulta el perfil — rescate, rehabilitación y adopción','Alimentos y apoyo para animales','','fundacionkenovycolombia','','',false,'','curated'),
('Cali','Royi Pets','Consulta el perfil para donaciones y apoyo a mascotas','Alimentos y artículos para mascotas','','royipets','','',false,'','curated'),
('Colombia · internacional','Cruz Roja Colombiana','Donación en línea desde su portal oficial','Donaciones económicas verificadas','','','https://www.ayuda.cruzrojacolombiana.org/','',false,'','curated'),
('Colombia · internacional','Fundación PLAN','Donación en línea desde su portal oficial','Donaciones económicas verificadas','','fundacionplan','https://plan.org.co/quiero-ayudar/terremoto-en-colombia/','',false,'','curated'),
('Colombia · internacional','Presentes y ProAntioquia','Donación en línea desde su portal oficial','Donaciones económicas verificadas','','presentescorporacion','https://www.presentes.co/dona/','',false,'','curated'),
('Colombia · internacional','Asociación de Bancos de Alimentos de Colombia (ABACO)','Donación en línea o transferencia bancaria','Donaciones económicas verificadas para alimentos','','abacocolombia','','Bancolombia cuenta corriente 15264342372 · NIT 900326456-1 · Llave Bre-B: 0090989753',true,'https://www.bluradio.com/nacion/donde-donar-para-los-damnificados-por-el-terremoto-en-colombia-rg10','curated'),
('Colombia · internacional','Manos Visibles','Donación en línea desde su portal oficial','Donaciones económicas verificadas; ayuda directa al Chocó','','manosvisibles','','',false,'','curated'),
('Colombia · internacional','Fundación Galería Aborigen','Donación en línea (GoFundMe)','Donaciones económicas verificadas; comunidades indígenas del Chocó','','galeriaaborigen','https://www.gofundme.com/f/ayudas-para-las-comunidades-indigenas-del-choco','',false,'','curated'),
('Colombia · internacional','Convoy of Hope','Ayuda humanitaria y respuesta al terremoto para familias afectadas','Donaciones económicas verificadas, ayuda humanitaria','','convoyofhope','','',false,'','curated'),
('Colombia · internacional','World Central Kitchen','Respuesta alimentaria junto a aliados locales en Colombia','Donaciones económicas verificadas para alimentos','','wckitchen','','',false,'','curated'),
('Colombia · internacional','The House Project','Alimentos, atención médica y refugio para familias afectadas','Donaciones económicas verificadas, alimentos, salud y refugio','','thehouseproject','','',false,'','curated'),
('Colombia · internacional','Direct Relief','Asistencia médica para necesidades de salud por la emergencia','Donaciones económicas verificadas, medicamentos y salud','','directrelief','','',false,'','curated'),
('Medellín','Parque Biblioteca Belén','Carrera 76 #18A-19','Alimentos no perecederos, kits de aseo, pañales, colchonetas, mantas','','','','',true,'https://www.eltiempo.com/colombia/medellin/medellin-se-une-por-las-victimas-del-terremoto-en-colombia-conozca-los-10-puntos-para-entregar-sus-donaciones-3577553','curated'),
('Medellín','Parque Biblioteca San Javier','Calle 42C #95-50','Alimentos no perecederos, kits de aseo, pañales, colchonetas, mantas','','','','',true,'https://qhubomedellin.com/util-para-vos/donde-entregar-donaciones-para-terremoto-en-medellin-PA39825381','curated'),
('Medellín','Parque Biblioteca Gabriel García Márquez','Carrera 80 #104-04','Alimentos no perecederos, kits de aseo, pañales, colchonetas, mantas','','','','',true,'https://qhubomedellin.com/util-para-vos/donde-entregar-donaciones-para-terremoto-en-medellin-PA39825381','curated'),
('Medellín','Parque Biblioteca León de Greiff','Calle 59A #36-30','Alimentos no perecederos, kits de aseo, pañales, colchonetas, mantas','','','','',true,'https://qhubomedellin.com/util-para-vos/donde-entregar-donaciones-para-terremoto-en-medellin-PA39825381','curated'),
('Medellín','Biblioteca Pública El Poblado','Calle 3B Sur #29B-56','Alimentos no perecederos, kits de aseo, pañales, colchonetas, mantas','','','','',true,'https://qhubomedellin.com/util-para-vos/donde-entregar-donaciones-para-terremoto-en-medellin-PA39825381','curated'),
('Medellín','Terminal del Norte','Carrera 64C #78-580, Local 9840','Alimentos no perecederos, kits de aseo, pañales, colchonetas, mantas','','','','',true,'https://qhubomedellin.com/util-para-vos/donde-entregar-donaciones-para-terremoto-en-medellin-PA39825381','curated'),
('Bogotá','Palacio de los Deportes — punto para el Chocó','Calle 63, Parque Metropolitano Simón Bolívar','Alimentos, elementos de primera necesidad','','','','Habilitado el 12 de agosto a pedido de la Gobernación del Chocó; todo lo recolectado se envía directamente al Chocó',true,'https://los40.com.co/2026/08/12/alcaldia-habilito-punto-de-acopio-en-bogota-para-enviar-ayudas-directamente-al-choco-tras-el-terremoto/','curated'),
('Bogotá','Colombia Un Solo Corazón — 122 Plaza Apartahotel','Carrera 15A #122-27','Alimentos, artículos de aseo, primeros auxilios','','','','',true,'https://revistadiners.com.co/lo-ultimo/puntos-de-acopio-terremoto-colombia/','curated'),
('Bogotá','Colombia Un Solo Corazón — Codabas','Carrera 7 #180-75, Módulo 2, Piso 2','Alimentos, artículos de aseo, primeros auxilios','','','','',true,'https://revistadiners.com.co/lo-ultimo/puntos-de-acopio-terremoto-colombia/','curated'),
('Bogotá','Colombia Un Solo Corazón — Unicentro (entrada Cra 13)','C.C. Unicentro, entrada Carrera 13, zona de banderas','Alimentos, artículos de aseo, primeros auxilios','','','','',true,'https://revistadiners.com.co/lo-ultimo/puntos-de-acopio-terremoto-colombia/','curated'),
('Bogotá','Vive Claro','Recinto Vive Claro','Agua potable, alimentos no perecederos, cobijas/mantas/colchonetas, artículos de higiene personal, suministros de primeros auxilios','','','','Parte de la campaña Colombia Un Solo Corazón; lo recolectado se envía a Chocó, Caldas, Risaralda, Valle del Cauca, Quindío, Cauca y Tolima',true,'https://www.eltiempo.com/bogota/vive-claro-sera-un-centro-nacional-de-acopio-para-recibir-donaciones-tras-terremoto-en-colombia-asi-puede-donar-o-ser-voluntario-3577800','curated'),
('Bogotá','Estadio El Campín — Fundación Solidaridad por Colombia','Entrada por la Carrera 30','Todo tipo de ayuda','','','','Organizado por Sencia y Fundación Solidaridad por Colombia · también reciben dinero a la llave Bre-B @juntosxcolombia',true,'https://www.bluradio.com/nacion/donde-donar-para-los-damnificados-por-el-terremoto-en-colombia-rg10','curated'),
('Chía (Cundinamarca)','Colombia Un Solo Corazón — Chía','Carrera 9 #12-41, diagonal al CAM','Alimentos, artículos de aseo, primeros auxilios','573112555912','','','',true,'https://www.infobae.com/colombia/2026/08/11/tras-el-fuerte-terremoto-en-colombia-la-primera-dama-ana-lucia-pineda-anuncio-puntos-de-acopio-de-ayudas-humanitarias-un-solo-corazon/','curated'),
('Cáqueza (Cundinamarca)','Colombia Un Solo Corazón — Cáqueza','Calle 4 #4-09, Deportivos Willys','Alimentos, artículos de aseo, primeros auxilios','573143087520','','','Contactos adicionales: 310 273 1133 · 310 321 3108',true,'https://www.infobae.com/colombia/2026/08/11/tras-el-fuerte-terremoto-en-colombia-la-primera-dama-ana-lucia-pineda-anuncio-puntos-de-acopio-de-ayudas-humanitarias-un-solo-corazon/','curated'),
('Sincelejo (Sucre)','Colombia Un Solo Corazón — Sincelejo','Calle 19 #21-41, Calle 7 de Agosto, frente a Droguería Maxi Económica Rosario Barrios','Alimentos, artículos de aseo, primeros auxilios','573114788851','','','Contactos adicionales: 300 789 8726 · 300 490 6741',true,'https://www.infobae.com/colombia/2026/08/11/tras-el-fuerte-terremoto-en-colombia-la-primera-dama-ana-lucia-pineda-anuncio-puntos-de-acopio-de-ayudas-humanitarias-un-solo-corazon/','curated'),
('Acacías (Meta)','Colombia Un Solo Corazón — Acacías','Calle 15 #16-43, frente al Banco de Occidente, Barrio Centro','Alimentos, artículos de aseo, primeros auxilios','573142426083','','','',true,'https://www.infobae.com/colombia/2026/08/11/tras-el-fuerte-terremoto-en-colombia-la-primera-dama-ana-lucia-pineda-anuncio-puntos-de-acopio-de-ayudas-humanitarias-un-solo-corazon/','curated'),
('Florencia (Caquetá)','Colombia Un Solo Corazón — Florencia','Carrera 10A #7-04, Barrio Avenidas','Alimentos, artículos de aseo, primeros auxilios','573178871620','','','',true,'https://www.infobae.com/colombia/2026/08/11/tras-el-fuerte-terremoto-en-colombia-la-primera-dama-ana-lucia-pineda-anuncio-puntos-de-acopio-de-ayudas-humanitarias-un-solo-corazon/','curated'),
('Quibdó','Colombia Un Solo Corazón — Barrio Los Ángeles','Calle 27A #23-44, Barrio Los Ángeles, sector San Gabriel','Alimentos, artículos de aseo, primeros auxilios','573108050535','','','',true,'https://www.infobae.com/colombia/2026/08/11/tras-el-fuerte-terremoto-en-colombia-la-primera-dama-ana-lucia-pineda-anuncio-puntos-de-acopio-de-ayudas-humanitarias-un-solo-corazon/','curated'),
('Colombia · internacional','Fundación Colombia Luz y Sonrisas','Donación por transferencia bancaria','Donaciones económicas verificadas','','','','Banco de Bogotá, cuenta de ahorros 125128462 · NIT 9020850963',true,'https://www.bluradio.com/nacion/donde-donar-para-los-damnificados-por-el-terremoto-en-colombia-rg10','curated'),
('Colombia · internacional','Corporación Organización El Minuto de Dios','Donación en línea o transferencia bancaria','Donaciones económicas verificadas','','','https://www.minutodedios.org','Davivienda, cuenta de ahorros 004000240970 · NIT 860.010.371-0',true,'https://www.bluradio.com/nacion/donde-donar-para-los-damnificados-por-el-terremoto-en-colombia-rg10','curated');