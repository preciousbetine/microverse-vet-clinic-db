
-- All animals whose name ends with "mon"
SELECT * FROM animals WHERE name LIKE '%mon';
-- All animals born between 2016 and 2019
SELECT name FROM animals WHERE date_of_birth BETWEEN '1-1-2016' AND '31-12-2019';
-- All animals that are neutered and have tried to escape less than 3 times
SELECT name FROM animals WHERE neutered AND escape_attempts < 3;
-- Date of birth of animals that are named "Agumon" or "Pikachu"
SELECT date_of_birth FROM animals WHERE name IN ('Agumon', 'Pikachu');
-- Name and number of escape attempts of animals that weigh more than 10.5kg
SELECT name, escape_attempts FROM animals WHERE weight_kg > 10.5;
-- All neutered animals
SELECT * FROM animals WHERE neutered;
-- All animals that aren't named "Gabumon"
SELECT * FROM animals WHERE NOT name = 'Gabumon';
-- All animals that weigh between 10.4kg and 17.3kg
SELECT * FROM animals WHERE weight_kg BETWEEN 10.4 AND 17.3;


-- Total number of animals
SELECT COUNT(*) FROM animals;
-- Number of animals that have never tried to escape
SELECT COUNT(*) FROM animals WHERE escape_attempts = 0;
-- Average weight of all animals
SELECT AVG(weight_kg) FROM animals;
-- Class of animals that escape the most: neutered or not
SELECT neutered, SUM(escape_attempts) FROM animals GROUP BY neutered;
-- Minimum and maximum weights from each class of animal: neutered and non-neutered
SELECT neutered, MIN(weight_kg), MAX(weight_kg) FROM animals GROUP BY neutered;
-- Average number of escape attempts of each class of animal: neutered and non-neutered. Only those born between 1990 and 2000
SELECT neutered, AVG(escape_attempts) FROM animals WHERE date_of_birth BETWEEN '1-1-1990' AND '1-1-2000' GROUP BY neutered;


-- Animals that belong to Melody Pond
SELECT * FROM (
  SELECT name, full_name AS owner_name
  FROM animals
  JOIN owners
  ON owner_id = owners.id
) AS animal_owners
WHERE owner_name = 'Melody Pond';

-- Animals that are of the Pokemon species
SELECT * FROM (
  SELECT animals.name AS animal_name, species.name AS animal_type
  FROM animals
  JOIN species
  ON species_id = species.id
) AS animal_species
WHERE animal_type = 'Pokemon';

-- All owners and their animals (including people that don't own any)
SELECT full_name AS owner_name, name AS animal_name
FROM owners
LEFT JOIN animals
ON owner_id = owners.id;

-- Number of animals per species
SELECT species.name AS specie,
COUNT(animals.name) AS number_of_animals
FROM species
JOIN animals
ON species.id = animals.species_id
GROUP BY specie;

-- All animals of the Digimon species belonging to Jennifer Orwell
SELECT * FROM (
  SELECT owners.full_name AS owner_name,
  animals.name AS animal_name,
  species.name AS specie
  FROM animals
  JOIN owners ON owners.id = animals.owner_id
  JOIN species ON species.id = animals.species_id
) AS animal_details
WHERE owner_name = 'Jennifer Orwell' AND specie = 'Digimon';

-- All Dean Winchester's animals that have zero escape attempts
SELECT * FROM (
  SELECT owners.full_name AS owner_name,
  animals.name AS animal_name,
  escape_attempts
  FROM animals
  JOIN owners ON owners.id = animals.owner_id
) AS animal_details
WHERE owner_name = 'Dean Winchester' AND escape_attempts = 0;

-- Person with the most animals
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


-- Last animal seen by William Tatcher
SELECT
  animal_name AS last_animal_seen_by,
  vet_name AS this_vet,
  date_of_visit
FROM (
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

-- Number of different animals Stephanie Mendez has seen
SELECT
DISTINCT vets.name AS this_vet_has_seen,
COUNT(animals.name) AS this_number_of_animals
FROM visits
JOIN animals ON animals.id = visits.animal_id
JOIN vets ON vets.id = visits.vet_id
WHERE vets.name = 'Stephanie Mendez'
GROUP BY this_vet_has_seen;

-- All vets and their specialties, including those that don't have any
SELECT vets.name AS vet_name, species.name AS specialty FROM vets
LEFT JOIN specializations ON vet_id = vets.id
LEFT JOIN species ON species_id = species.id;

-- All animals that visited Stephanie Mendez between April 1st and August 30th, 2020
SELECT vets.name as vet_name, animals.name as animal, date_of_visit FROM visits
JOIN animals ON animals.id = animal_id
JOIN vets ON vets.id = vet_id
WHERE vets.name = 'Stephanie Mendez' AND date_of_visit BETWEEN '1-1-2020' AND '30-8-2020';

-- The animal that has the most number of visits to vets
SELECT
animals.name AS this_animal_has_visited_vets,
COUNT(*) AS this_number_of_times
FROM visits
JOIN animals on animals.id = animal_id
GROUP BY animals.name
ORDER BY this_number_of_times DESC
LIMIT 1;

-- Maisy Smith's first visit
SELECT
animals.name AS this_animal,
vets.name as visited_this_vet,
date_of_visit AS on_this_date
FROM visits
JOIN vets on vet_id = vets.id
JOIN animals ON animal_id = animals.id
WHERE vets.name = 'Maisy Smith'
ORDER BY date_of_visit
LIMIT 1;

-- Details about the most recent visit
SELECT
animals.name AS this_animal,
vets.name AS visited_this_vet,
date_of_visit AS on_this_date
FROM visits
JOIN animals ON animals.id = animal_id
JOIN vets on vets.id = vet_id
ORDER BY date_of_visit DESC
LIMIT 1;

-- Visits to vets that did not specialize in the species of the animal
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
) AS non_specified_visits ON non_specified_visits.visit_id = id WHERE vet_species_id IS NULL;

-- Preferrable specialty for Maisy Smith
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
