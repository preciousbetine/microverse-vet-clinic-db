/*Queries that provide answers to the questions from all projects.*/

SELECT * FROM animals WHERE name LIKE '%mon';
SELECT name FROM animals WHERE date_of_birth BETWEEN '1-1-2016' AND '31-12-2019';
SELECT name FROM animals WHERE neutered AND escape_attempts < 3;
SELECT date_of_birth FROM animals WHERE name IN ('Agumon', 'Pikachu');
SELECT name, escape_attempts FROM animals WHERE weight_kg > 10.5;
SELECT * FROM animals WHERE neutered;
SELECT * FROM animals WHERE NOT name = 'Gabumon';
SELECT * FROM animals WHERE weight_kg BETWEEN 10.4 AND 17.3;

SELECT COUNT(*) FROM animals;
SELECT COUNT(*) FROM animals WHERE escape_attempts = 0;
SELECT AVG(weight_kg) FROM animals;
SELECT neutered, SUM(escape_attempts) FROM animals GROUP BY neutered;
SELECT neutered, MIN(weight_kg), MAX(weight_kg) FROM animals GROUP BY neutered;
SELECT neutered, AVG(escape_attempts) FROM animals WHERE date_of_birth BETWEEN '1-1-1990' AND '1-1-2000' GROUP BY neutered;

SELECT * FROM (
  SELECT name, full_name AS owner_name
  FROM animals
  JOIN owners
  ON owner_id = owners.id
) AS animal_owners
WHERE owner_name = 'Melody Pond';

SELECT * FROM (
  SELECT animals.name AS animal_name, species.name AS animal_type
  FROM animals
  JOIN species
  ON species_id = species.id
) AS animal_species
WHERE animal_type = 'Pokemon';

SELECT full_name AS owner_name, name AS animal_name
FROM owners
LEFT JOIN animals
ON owner_id = owners.id;

SELECT species.name AS specie,
COUNT(animals.name) AS number_of_animals
FROM species
JOIN animals
ON species.id = animals.species_id
GROUP BY specie;

SELECT * FROM (
  SELECT owners.full_name AS owner_name,
  animals.name AS animal_name,
  species.name AS specie
  FROM animals
  JOIN owners ON owners.id = animals.owner_id
  JOIN species ON species.id = animals.species_id
) AS animal_details
WHERE owner_name = 'Jennifer Orwell' AND specie = 'Digimon';

SELECT * FROM (
  SELECT owners.full_name AS owner_name,
  animals.name AS animal_name,
  escape_attempts
  FROM animals
  JOIN owners ON owners.id = animals.owner_id
) AS animal_details
WHERE owner_name = 'Dean Winchester' AND escape_attempts = 0;


SELECT full_name as owner_name, COUNT(name) AS number_of_animals
FROM animals
JOIN owners
ON owners.id = animals.owner_id
GROUP BY owner_name
HAVING COUNT(name) = (
  SELECT MAX(animal_count)
  FROM (
    SELECT COUNT(name) AS animal_count
    FROM animals
    JOIN owners
    ON owners.id = animals.owner_id
    GROUP BY owners.full_name
  ) AS animal_counts
);
