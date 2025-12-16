-- INNER JOIN : liste des examens avec nom étudiant et titre du cours
SELECT e.nom AS etudiant, c.titre AS cours, ex.date_examen, ex.score
FROM EXAMEN ex
INNER JOIN INSCRIPTION i ON ex.inscription_id = i.id
INNER JOIN ETUDIANT e ON i.etudiant_id = e.id
INNER JOIN ENSEIGNEMENT ens ON i.enseignement_id = ens.id
INNER JOIN COURS c ON ens.cours_id = c.id;

-- LEFT JOIN : nombre total d'examens passés par étudiant (zéro si aucun)
SELECT e.nom AS etudiant, COUNT(ex.id) AS nb_examens
FROM ETUDIANT e
LEFT JOIN INSCRIPTION i ON i.etudiant_id = e.id
LEFT JOIN EXAMEN ex ON ex.inscription_id = i.id
GROUP BY e.id, e.nom;

-- RIGHT JOIN : nombre d'étudiants inscrits par cours
SELECT c.titre AS cours, COUNT(DISTINCT i.etudiant_id) AS nb_etudiants
FROM COURS c
LEFT JOIN ENSEIGNEMENT ens ON ens.cours_id = c.id
LEFT JOIN INSCRIPTION i ON i.enseignement_id = ens.id
GROUP BY c.id, c.titre;

-- CROSS JOIN : toutes les paires Étudiant-Professeur limitées à 20 lignes
SELECT e.nom AS etudiant, p.nom AS professeur
FROM ETUDIANT e
CROSS JOIN PROFESSEUR p
LIMIT 20;

-- Création de la vue vue_performances
CREATE OR REPLACE VIEW vue_performances AS
SELECT e.id AS etudiant_id, e.nom,
       AVG(ex.score) AS moyenne_score
FROM ETUDIANT e
LEFT JOIN INSCRIPTION i ON i.etudiant_id = e.id
LEFT JOIN EXAMEN ex ON ex.inscription_id = i.id
GROUP BY e.id, e.nom;

-- CTE pour les trois cours ayant la meilleure moyenne
WITH top_cours AS (
    SELECT c.id AS cours_id, c.titre, c.credits, AVG(ex.score) AS moyenne_score
    FROM COURS c
    JOIN ENSEIGNEMENT ens ON ens.cours_id = c.id
    JOIN INSCRIPTION i ON i.enseignement_id = ens.id
    JOIN EXAMEN ex ON ex.inscription_id = i.id
    GROUP BY c.id, c.titre, c.credits
    ORDER BY moyenne_score DESC
    LIMIT 3
)
SELECT titre, credits, moyenne_score
FROM top_cours;
