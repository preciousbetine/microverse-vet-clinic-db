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

SELECT * FROM (
  SELECT vets.name AS vet_name, animals.name AS animal_name, date_of_visit
  FROM visits
  JOIN animals ON animals.id = visits.animal_id
  JOIN vets ON vets.id = visits.vet_id
) AS details
WHERE date_of_visit = (
  SELECT MAX(date_of_visit) FROM visits
  JOIN vets ON vets.id = visits.vet_id
  WHERE vets.name = 'William Tatcher'
);

SELECT
DISTINCT vets.name AS vet_name,
COUNT(animals.name) AS number_of_animals
FROM visits
JOIN animals ON animals.id = visits.animal_id
JOIN vets ON vets.id = visits.vet_id
WHERE vets.name = 'Stephanie Mendez'
GROUP BY vet_name;

SELECT vets.name AS vet_name, species.name AS specialty FROM vets
LEFT JOIN specializations ON vet_id = vets.id
LEFT JOIN species ON species_id = species.id;

SELECT vets.name as vet_name, animals.name as animal, date_of_visit FROM visits
JOIN animals ON animals.id = animal_id
JOIN vets ON vets.id = vet_id
WHERE vets.name = 'Stephanie Mendez' AND date_of_visit BETWEEN '1-1-2020' AND '30-8-2020';

SELECT COUNT(*), animals.name FROM visits
JOIN animals on animals.id = animal_id
GROUP BY animals.namespecializations
ORDER BY count DESC
LIMIT 1;

SELECT vets.name as vet_name, animals.name AS animal_name, date_of_visit
FROM visits
JOIN vets on vet_id = vets.id
JOIN animals ON animal_id = animals.id
WHERE vets.name = 'Maisy Smith'
ORDER BY date_of_visit
LIMIT 1;

SELECT animals.name AS animal_name, vets.name AS vet_name, date_of_visit
FROM visits
JOIN animals ON animals.id = animal_id
JOIN vets on vets.id = vet_id
ORDER BY date_of_visit DESC
LIMIT 1;

SELECT COUNT(*) AS num_visits_no_specialty FROM visits
LEFT JOIN (
  SELECT visit_id, animal_species_id, vet_species_id FROM (
    SELECT visited_vet_species.visit_id AS visit_id,
          visited_vet_species.vet_id AS vet_id,
          animal_species.animal_species_id AS animal_species_id,
          visited_vet_species.vet_species_id AS vet_species_id
    FROM (
      SELECT vets_visits.visit_id as visit_id, vets_visits.vet_id as vet_id, specializations.species_id as vet_species_id
      FROM (
        SELECT visits.id AS visit_id, vet_id FROM visits
      ) AS vets_visits
      LEFT JOIN specializations ON specializations.vet_id = vets_visits.vet_id
    ) AS visited_vet_species
    JOIN (
      SELECT visits.id AS visit_id,
              animals.species_id AS animal_species_id
              FROM visits
              JOIN animals ON animals.id = visits.animal_id
    ) AS animal_species ON animal_species.visit_id = visited_vet_species.visit_id
  ) AS specified_vets WHERE animal_species_id = vet_species_id
) AS non_specified_visits ON final_vets.visit_id = id WHERE vet_species_id IS NULL;

SELECT
vet_name AS this_vet,
species_name AS should_get_this_specialization,
num_visits AS bcos_so_called_species_have_visited_this_amount_of_times
FROM (
  SELECT visits_with_vets_names.vet_name as vet_name, species_name, COUNT(*) as num_visits
  FROM
  (
    SELECT animals.id AS animal_id, species_id, species.name AS species_name FROM animals
    JOIN species on species.id = species_id
  ) AS animals_and_species
  JOIN (
    SELECT visits.id, visits.animal_id, vets.name as vet_name, visits.date_of_visit FROM visits
    JOIN vets ON vets.id = visits.vet_id
  ) AS visits_with_vets_names ON animals_and_species.animal_id = visits_with_vets_names.animal_id
  WHERE vet_name = 'Maisy Smith'
  GROUP BY species_name, vet_name
) AS maisy_smith_visit_stats
ORDER BY num_visits DESC
LIMIT 1;
