/* Database schema to keep the structure of entire database. */

CREATE TABLE animals (
    id integer GENERATED ALWAYS AS IDENTITY,
    name varchar(100),
    date_of_birth date,
    escape_attempts integer,
    neutered boolean,
    weight_kg decimal
);

ALTER TABLE animals ADD COLUMN species varchar(100);

CREATE TABLE owners (
    id integer GENERATED ALWAYS AS IDENTITY,
    full_name varchar(100),
    age integer,
    PRIMARY KEY(id)
);

CREATE TABLE species (
    id integer GENERATED ALWAYS AS IDENTITY,
    name varchar(100),
    PRIMARY KEY(id)
);

ALTER TABLE animals
ADD PRIMARY KEY(id),
DROP COLUMN species,
ADD COLUMN species_id integer,
ADD COLUMN owner_id integer,
ADD CONSTRAINT species_constraint
FOREIGN KEY (species_id)
REFERENCES species (id),
ADD CONSTRAINT owner_constraint
FOREIGN KEY (owner_id)
REFERENCES owners (id);

CREATE TABLE vets (
    id integer GENERATED ALWAYS AS IDENTITY,
    name varchar(100),
    age integer,
    date_of_graduation date,
    PRIMARY KEY(id)
);

CREATE TABLE specializations (
    species_id integer,
    vet_id integer,
    PRIMARY KEY(species_id, vet_id)
);

CREATE TABLE visits (
    id integer GENERATED ALWAYS AS IDENTITY,
    animal_id integer,
    vet_id integer,
    date_of_visit date,
    PRIMARY KEY(id)
);

ALTER TABLE owners ADD COLUMN email VARCHAR(120);
