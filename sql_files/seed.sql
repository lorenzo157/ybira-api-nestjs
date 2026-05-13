-- =========================================================
-- SEED DATA — run after create_database.sql
-- Safe to re-run (ON CONFLICT DO NOTHING)
-- =========================================================

----------------------------------------- ROLES
INSERT INTO roles (role_name) VALUES
('administrador'),
('gestor'),
('inspector')
ON CONFLICT (role_name) DO NOTHING;

----------------------------------------- PROVINCES
INSERT INTO provinces (province_name) VALUES
('Santa Fe'),
('Entre Rios'),
('Cordoba'),
('Buenos Aires'),
('Chaco'),
('Santiago del Estero')
ON CONFLICT DO NOTHING;

----------------------------------------- CITIES
INSERT INTO cities (city_name, province_id) VALUES
-- Santa Fe province — near Santa Fe city
('Santa Fe',           (SELECT id_province FROM provinces WHERE province_name = 'Santa Fe')),
('Santo Tome',         (SELECT id_province FROM provinces WHERE province_name = 'Santa Fe')),
('Recreo',             (SELECT id_province FROM provinces WHERE province_name = 'Santa Fe')),
('San Jose del Rincon',(SELECT id_province FROM provinces WHERE province_name = 'Santa Fe')),
('Laguna Paiva',       (SELECT id_province FROM provinces WHERE province_name = 'Santa Fe')),
('Sauce Viejo',        (SELECT id_province FROM provinces WHERE province_name = 'Santa Fe')),
-- Santa Fe province — near Rosario
('Rosario',            (SELECT id_province FROM provinces WHERE province_name = 'Santa Fe')),
('Granadero Baigorria',(SELECT id_province FROM provinces WHERE province_name = 'Santa Fe')),
('Capitan Bermudez',   (SELECT id_province FROM provinces WHERE province_name = 'Santa Fe')),
('San Lorenzo',        (SELECT id_province FROM provinces WHERE province_name = 'Santa Fe')),
('Funes',              (SELECT id_province FROM provinces WHERE province_name = 'Santa Fe')),
('Roldan',             (SELECT id_province FROM provinces WHERE province_name = 'Santa Fe')),
('Perez',              (SELECT id_province FROM provinces WHERE province_name = 'Santa Fe')),
('Canada de Gomez',    (SELECT id_province FROM provinces WHERE province_name = 'Santa Fe')),
-- Entre Rios province — near Parana
('Parana',             (SELECT id_province FROM provinces WHERE province_name = 'Entre Rios')),
('Oro Verde',          (SELECT id_province FROM provinces WHERE province_name = 'Entre Rios')),
('San Benito',         (SELECT id_province FROM provinces WHERE province_name = 'Entre Rios')),
('Crespo',             (SELECT id_province FROM provinces WHERE province_name = 'Entre Rios')),
('Diamante',           (SELECT id_province FROM provinces WHERE province_name = 'Entre Rios'))
ON CONFLICT DO NOTHING;

----------------------------------------- SUPER ADMIN USER
INSERT INTO users (first_name, last_name, email, password, phonenumber, address, role_id, city_id, height_meters)
VALUES (
    'administrador',
    '',
    'adm@example.com',
    '$argon2id$v=19$m=4096,t=3,p=4$HPX2inRLfIXmuvCCKdAU9A$q/ap3daDB2B5OQmkN3y5l686NdPhb4uQt/n5Wh0SHqY',   --LA CONTRASEÑA ES "contra"
    '',
    '',
    (SELECT id_role FROM roles WHERE role_name = 'administrador'),
    (SELECT id_city FROM cities WHERE city_name = 'Santa Fe'),
    1.70
)
ON CONFLICT (email) DO NOTHING;

----------------------------------------- CONFLICTS
INSERT INTO conflicts (conflict_name) VALUES
('obstruccion visual de señaletica vial'),
('obstruccion de visual(transito humano y vehicular)'),
('obstruccion fisica de transito humano o vehicular'),
('conductores de 1/2 tension'),
('conductores de baja tension'),
('transformadores'),
('rotura de veredas'),
('luminarias a menos de 3m'),
('rotura de desagues')
ON CONFLICT (conflict_name) DO NOTHING;

----------------------------------------- INTERVENTIONS
INSERT INTO interventions (intervention_name) VALUES
('extraccion del arbol'),
('plantacion de arbol faltante'),
('cableado'),
('sujecion'),
('apuntalamiento'),
('aumentar superficie permeable'),
('fertilizacion'),
('descompactado'),
('drenaje'),
('abertura de cazuela en vereda'),
('mover el blanco'),
('restringir acceso'),
('requiere inspeccion avanzada'),
('poda (formacion)'),
('poda (sanitaria)'),
('poda (reduccion de altura)'),
('poda (raleo de ramas)'),
('poda (despeje de señaletica)'),
('poda (despeje de conductores electricos)'),
('poda (radicular + uso de deflectores)')
ON CONFLICT (intervention_name) DO NOTHING;

----------------------------------------- DEFECTS
INSERT INTO defects (defect_name, defect_zone) VALUES
('cuerpos fructiferos de hongos en raices','raiz'),
('daño mecanico a raices','raiz'),
('raices estrangulantes','raiz'),
('raices muertas','raiz'),
('sintomas de enfermedad radicular en copa','raiz'),
('agallas, termiteros, hormigueros','tronco'),
('cancros de tronco','tronco'),
('cavidades en tronco','tronco'),
('coeficiente de esbeltez','tronco'),
('corteza perdida o muerta','tronco'),
('fustes miltiples','tronco'),
('heridas de tronco','tronco'),
('horqueta de tronco','tronco'),
('inclinacion','tronco'),
('pudricion de madera en tronco','tronco'),
('rajaduras de tronco','tronco'),
('cancros de rama','rama'),
('cavidades de rama','rama'),
('cuerpos fructiferos de hongos en rama','rama'),
('horqueta de rama','rama'),
('ramas colgantes o quebradas','rama'),
('ramas muertas','rama'),
('ramas sobre extendidas','rama'),
('rajaduras de rama','rama'),
('pudricion de madera en ramas','rama'),
('interferencia con red electrica','rama')
ON CONFLICT (defect_name) DO NOTHING;
