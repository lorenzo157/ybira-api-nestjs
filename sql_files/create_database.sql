--\connect postgres;
--CREATE DATABASE arboles;

CREATE EXTENSION IF NOT EXISTS postgis;

BEGIN;
----------------------------------------- TABLAS DE ORDEN 0

CREATE TABLE IF NOT EXISTS pests (
    id_pest SERIAL PRIMARY KEY,
    pest_name VARCHAR(255) NOT NULL,
    CONSTRAINT unique_pest_name UNIQUE (pest_name)
);

CREATE TABLE IF NOT EXISTS conflicts (
    id_conflict SERIAL PRIMARY KEY,
    conflict_name VARCHAR(255) NOT NULL,
    CONSTRAINT unique_conflict_name UNIQUE (conflict_name)
);

CREATE TABLE IF NOT EXISTS diseases (
    id_disease SERIAL PRIMARY KEY,
    disease_name VARCHAR(255) NOT NULL,
    CONSTRAINT unique_disease_name UNIQUE (disease_name)
);

CREATE TABLE IF NOT EXISTS interventions (
    id_intervention SERIAL PRIMARY KEY,
    intervention_name VARCHAR(255) NOT NULL,
    CONSTRAINT unique_intervention_name UNIQUE (intervention_name)
);

CREATE TYPE defect_zone_type AS ENUM ('raiz', 'tronco', 'rama');
CREATE TABLE IF NOT EXISTS defects (
    id_defect SERIAL PRIMARY KEY,
    defect_name VARCHAR(255) NOT NULL,
    defect_zone defect_zone_type NOT NULL,
    CONSTRAINT unique_defect_name UNIQUE (defect_name)
);

CREATE TABLE IF NOT EXISTS provinces (
    id_province SERIAL PRIMARY KEY,
    province_name VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS roles (
    id_role SERIAL PRIMARY KEY,
    role_name VARCHAR(255) NOT NULL,
    CONSTRAINT unique_role_name UNIQUE (role_name)
);

CREATE TABLE IF NOT EXISTS permissions (
    id_permission SERIAL PRIMARY KEY,
    permission_name VARCHAR(255) NOT NULL,
    permission_description TEXT,
    CONSTRAINT unique_permission_name UNIQUE (permission_name)
);

----------------------------------------- TABLAS DE ORDEN 1

CREATE TABLE IF NOT EXISTS role_permission (
    id_role_permission SERIAL PRIMARY KEY,
    permission_id INTEGER NOT NULL,
    role_id INTEGER NOT NULL,
    CONSTRAINT fk_permission FOREIGN KEY (permission_id) REFERENCES permissions(id_permission),
    CONSTRAINT fk_role FOREIGN KEY (role_id) REFERENCES roles(id_role),
    CONSTRAINT unique_role_permission UNIQUE (permission_id, role_id)
);

CREATE TABLE IF NOT EXISTS cities (
    id_city SERIAL PRIMARY KEY,
    city_name VARCHAR(255) NOT NULL,
    province_id INTEGER NOT NULL,
    CONSTRAINT fk_province FOREIGN KEY (province_id) REFERENCES provinces(id_province)
);

----------------------------------------- TABLAS DE ORDEN 2

CREATE TABLE IF NOT EXISTS neighborhoods (
    id_neighborhood SERIAL PRIMARY KEY,
    neighborhood_name VARCHAR(255) NOT NULL,
    num_blocks_in_neighborhood INTEGER NOT NULL,
    city_id INTEGER NOT NULL,
    deleted_at TIMESTAMP NULL DEFAULT NULL,
    boundary GEOGRAPHY(POLYGON, 4326),
    CONSTRAINT fk_city FOREIGN KEY (city_id) REFERENCES cities(id_city)
);

CREATE TABLE IF NOT EXISTS users (
    id_user SERIAL PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    height_meters NUMERIC(5, 4) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL,
    phoneNumber VARCHAR(255),
    address TEXT,
    role_id INTEGER NOT NULL,
    city_id INTEGER NOT NULL,
    password_reset_token VARCHAR(255),
    CONSTRAINT fk_role FOREIGN KEY (role_id) REFERENCES roles(id_role),
    CONSTRAINT fk_city FOREIGN KEY (city_id) REFERENCES cities(id_city),
    CONSTRAINT unique_email UNIQUE (email)
);

----------------------------------------- TABLAS DE ORDEN 3

CREATE TABLE IF NOT EXISTS projects (
    id_project SERIAL PRIMARY KEY,
    project_name VARCHAR(255) NOT NULL,
    project_description TEXT,
    start_date DATE NOT NULL,
    end_date DATE,
    project_type VARCHAR(255) NOT NULL,
    city_id INTEGER,
    user_id INTEGER NOT NULL,
    CONSTRAINT fk_city FOREIGN KEY (city_id) REFERENCES cities(id_city),
    CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES users(id_user)
);

----------------------------------------- TABLAS DE ORDEN 4

CREATE TABLE IF NOT EXISTS project_user (
    id_project_user SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    project_id INTEGER NOT NULL,
    CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES users(id_user) ON DELETE CASCADE,
    CONSTRAINT fk_project FOREIGN KEY (project_id) REFERENCES projects(id_project)  ON DELETE CASCADE,
    CONSTRAINT unique_user_project UNIQUE (user_id, project_id)
);

CREATE TABLE IF NOT EXISTS unit_work (
    id_unit_work SERIAL PRIMARY KEY,
    project_id INTEGER NULL,
    neighborhood_id INTEGER NULL,
	move_target INTEGER NOT NULL DEFAULT 0,
	restrict_access INTEGER NOT NULL DEFAULT 0,
    cabling INTEGER NOT NULL DEFAULT 0,
    fastening INTEGER NOT NULL DEFAULT 0,
    propping INTEGER NOT NULL DEFAULT 0,
    permeable_surface_increases INTEGER NOT NULL DEFAULT 0,
    fertilizations INTEGER NOT NULL DEFAULT 0,
    descompression INTEGER NOT NULL DEFAULT 0,
    drains INTEGER NOT NULL DEFAULT 0,
    extractions INTEGER NOT NULL DEFAULT 0,
    plantations INTEGER NOT NULL DEFAULT 0,
    openings_pot INTEGER NOT NULL DEFAULT 0,
    advanced_inspections INTEGER NOT NULL DEFAULT 0,
    pruning_training INTEGER NOT NULL DEFAULT 0,
	pruning_sanitary INTEGER NOT NULL DEFAULT 0,
	pruning_height_reduction INTEGER NOT NULL DEFAULT 0,
	pruning_branch_thinning INTEGER NOT NULL DEFAULT 0,
	pruning_sign_clearing INTEGER NOT NULL DEFAULT 0,
	pruning_power_line_clearing INTEGER NOT NULL DEFAULT 0,
	pruning_root_deflectors INTEGER NOT NULL DEFAULT 0,
    unit_work_id INTEGER,
    campaign_description TEXT,
    create_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_project FOREIGN KEY (project_id) REFERENCES projects(id_project),
    CONSTRAINT fk_neighborhood FOREIGN KEY (neighborhood_id) REFERENCES neighborhoods(id_neighborhood),
    CONSTRAINT fk_unit_work FOREIGN KEY (unit_work_id) REFERENCES unit_work(id_unit_work) ON DELETE CASCADE,
    CONSTRAINT unique_project_neighborhood UNIQUE (project_id, neighborhood_id)
);

CREATE TYPE wind_exposure_type AS ENUM ('expuesto', 'parcialmente expuesto', 'protegido', 'tunel de viento');
CREATE TYPE vigor_type AS ENUM ('excelente', 'normal', 'pobre');
CREATE TYPE canopy_density_type AS ENUM ('escasa', 'normal', 'densa');
CREATE TYPE growth_space_type AS ENUM ('sin cazuela', 'cazuela = 1 - 2 m2', 'cazuela > 2 m2', 'vereda jardin');
CREATE TYPE tree_value_type AS ENUM ('historico', 'monumental', 'singular', 'notable', 'plaza/parque (ornamental)', 'reclamo');
CREATE TYPE street_materiality_type AS ENUM ('tierra', 'mejorado petroleo', 'asfalto', 'concreto', 'cordon cuneta');
CREATE TABLE IF NOT EXISTS trees (
    id_tree SERIAL PRIMARY KEY,
    datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    path_photo VARCHAR(255),
    city_block INTEGER,
    perimeter NUMERIC(8, 5),
    height NUMERIC(8, 5),
    incline NUMERIC(8, 5),
    trees_in_the_block SMALLINT,
    use_under_the_tree VARCHAR(255),
    frequency_use SMALLINT,
    potential_damage SMALLINT,
    is_movable BOOLEAN,
    is_restrictable BOOLEAN,
    is_missing BOOLEAN,
    is_dead BOOLEAN,
    exposed_roots BOOLEAN,
    DCH NUMERIC(7, 5),
    wind_exposure wind_exposure_type,
    vigor vigor_type,
    canopy_density canopy_density_type,
    growth_space growth_space_type,
    tree_value tree_value_type,
    tree_type_name VARCHAR(255),
    gender VARCHAR(255),
    species VARCHAR(255),
    scientific_name VARCHAR(255),
    project_id INTEGER NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    neighborhood_id INTEGER,
    street_materiality street_materiality_type,
    risk SMALLINT,
    address TEXT NOT NULL,
    tree_info_collection_start_time TIMESTAMP NOT NULL,
    location GEOGRAPHY(POINT, 4326),
    CONSTRAINT fk_neighborhood FOREIGN KEY (neighborhood_id) REFERENCES neighborhoods(id_neighborhood),
    CONSTRAINT fk_project FOREIGN KEY (project_id) REFERENCES projects(id_project)
);

----------------------------------------- TABLAS DE ORDEN 5

CREATE TABLE IF NOT EXISTS pest_tree (
    id_pest_tree SERIAL PRIMARY KEY,
    tree_id INTEGER NOT NULL,
    pest_id INTEGER NOT NULL,
    CONSTRAINT fk_tree FOREIGN KEY (tree_id) REFERENCES trees(id_tree) ON DELETE CASCADE,
    CONSTRAINT fk_pest FOREIGN KEY (pest_id) REFERENCES pests(id_pest),
    CONSTRAINT unique_tree_pest UNIQUE (tree_id, pest_id)
);

CREATE TABLE IF NOT EXISTS conflict_tree (
    id_conflict_tree SERIAL PRIMARY KEY,
    tree_id INTEGER NOT NULL,
    conflict_id INTEGER NOT NULL,
    CONSTRAINT fk_tree FOREIGN KEY (tree_id) REFERENCES trees(id_tree) ON DELETE CASCADE,
    CONSTRAINT fk_conflict FOREIGN KEY (conflict_id) REFERENCES conflicts(id_conflict),
    CONSTRAINT unique_tree_conflict UNIQUE (tree_id, conflict_id)
);

CREATE TABLE IF NOT EXISTS disease_tree (
    id_disease_tree SERIAL PRIMARY KEY,
    tree_id INTEGER NOT NULL,
    disease_id INTEGER NOT NULL,
    CONSTRAINT fk_tree FOREIGN KEY (tree_id) REFERENCES trees(id_tree) ON DELETE CASCADE,
    CONSTRAINT fk_disease FOREIGN KEY (disease_id) REFERENCES diseases(id_disease),
    CONSTRAINT unique_tree_disease UNIQUE (tree_id, disease_id)
);

CREATE TABLE IF NOT EXISTS intervention_tree (
    id_intervention_tree SERIAL PRIMARY KEY,
    tree_id INTEGER NOT NULL,
    intervention_id INTEGER NOT NULL,
    CONSTRAINT fk_tree FOREIGN KEY (tree_id) REFERENCES trees(id_tree) ON DELETE CASCADE,
    CONSTRAINT fk_intervention FOREIGN KEY (intervention_id) REFERENCES interventions(id_intervention),
    CONSTRAINT unique_tree_intervention UNIQUE (tree_id, intervention_id)
);

CREATE TABLE IF NOT EXISTS defect_tree (
    id_defect_tree SERIAL PRIMARY KEY,
    tree_id INTEGER NOT NULL,
    defect_id INTEGER NOT NULL,
    defect_value SMALLINT NOT NULL,
    text_defect_value TEXT NOT NULL,
    branches DOUBLE PRECISION,
    CONSTRAINT fk_tree FOREIGN KEY (tree_id) REFERENCES trees(id_tree) ON DELETE CASCADE,
    CONSTRAINT fk_defect FOREIGN KEY (defect_id) REFERENCES defects(id_defect),
    CONSTRAINT unique_tree_defect UNIQUE (tree_id, defect_id)
);

COMMIT;

CREATE INDEX IF NOT EXISTS idx_trees_location         ON trees         USING GIST (location);
CREATE INDEX IF NOT EXISTS idx_neighborhoods_boundary ON neighborhoods  USING GIST (boundary);

-- Run seed.sql after this file to populate initial data and admin user

----------------------------------------- TRIGGER: set neighborhood and location

CREATE OR REPLACE FUNCTION set_neighborhood()
RETURNS TRIGGER AS $$
DECLARE
    tree_location GEOGRAPHY;
BEGIN
    tree_location := ST_SetSRID(ST_MakePoint(NEW.longitude::float, NEW.latitude::float), 4326)::geography;

    UPDATE trees
    SET
        neighborhood_id = (
            SELECT n.id_neighborhood
            FROM neighborhoods n
            WHERE ST_Within(tree_location::geometry, n.boundary::geometry)
            LIMIT 1
        ),
        location = tree_location
    WHERE id_tree = NEW.id_tree;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_neighborhood_trigger
AFTER INSERT OR UPDATE OF latitude, longitude ON trees
FOR EACH ROW
EXECUTE FUNCTION set_neighborhood();
