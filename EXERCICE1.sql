CREATE DATABASE universite CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE universite;

CREATE TABLE ETUDIANT (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

CREATE TABLE PROFESSEUR (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    departement VARCHAR(100)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

CREATE TABLE COURS (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titre VARCHAR(150) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    credits INT NOT NULL
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

CREATE TABLE ENSEIGNEMENT (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cours_id INT,
    professeur_id INT,
    semestre VARCHAR(20),
    FOREIGN KEY (cours_id) REFERENCES COURS(id),
    FOREIGN KEY (professeur_id) REFERENCES PROFESSEUR(id) ON DELETE SET NULL
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

CREATE TABLE INSCRIPTION (
    id INT AUTO_INCREMENT PRIMARY KEY,
    etudiant_id INT,
    enseignement_id INT,
    date_inscription DATE,
    FOREIGN KEY (etudiant_id) REFERENCES ETUDIANT(id),
    FOREIGN KEY (enseignement_id) REFERENCES ENSEIGNEMENT(id),
    UNIQUE (etudiant_id, enseignement_id)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;

CREATE TABLE EXAMEN (
    id INT AUTO_INCREMENT PRIMARY KEY,
    inscription_id INT,
    date_examen DATE,
    score DECIMAL(4,2),
    commentaire TEXT,
    CHECK(score BETWEEN 0 AND 20),
    FOREIGN KEY (inscription_id) REFERENCES INSCRIPTION(id)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;
INSERT INTO PROFESSEUR (nom, email, departement) VALUES
('Dr. Dupont', 'dupont@univ.fr', 'Informatique'),
('Dr. Martin', 'martin@univ.fr', 'Mathématiques');

INSERT INTO COURS (titre, code, credits) VALUES
('Programmation', 'CS101', 6),
('Algèbre', 'MA101', 4),
('Bases de données', 'CS102', 5);

INSERT INTO ETUDIANT (nom, email) VALUES
('Alice', 'alice@email.com'),
('Bob', 'bob@email.com');

INSERT INTO ENSEIGNEMENT (cours_id, professeur_id, semestre) VALUES
(1, 1, '2025S1'),
(2, 2, '2025S1');

INSERT INTO INSCRIPTION (etudiant_id, enseignement_id, date_inscription) VALUES
(1, 1, '2025-09-01'),
(1, 2, '2025-09-02'),
(2, 1, '2025-09-01'),
(2, 2, '2025-09-02');

INSERT INTO EXAMEN (inscription_id, date_examen, score) VALUES
(5, CURDATE(), 15),
(6, CURDATE(), 18),
(7, CURDATE(), 12),
(8, CURDATE(), 14);

SELECT e.nom, e.email
FROM ETUDIANT e
JOIN INSCRIPTION i ON i.etudiant_id = e.id
JOIN ENSEIGNEMENT ens ON i.enseignement_id = ens.id
JOIN COURS c ON ens.cours_id = c.id
WHERE c.code = 'CS101';

SELECT nom, email
FROM PROFESSEUR
WHERE departement = 'Informatique';

SELECT *
FROM INSCRIPTION i
JOIN ETUDIANT e ON i.etudiant_id = e.id
WHERE e.nom = 'Alice'
ORDER BY date_inscription DESC;

SELECT e.nom AS etudiant, c.titre AS cours, ens.semestre, i.date_inscription
FROM INSCRIPTION i
JOIN ETUDIANT e ON i.etudiant_id = e.id
JOIN ENSEIGNEMENT ens ON i.enseignement_id = ens.id
JOIN COURS c ON ens.cours_id = c.id;

SELECT e.nom,
       (SELECT COUNT(*)
        FROM INSCRIPTION i
        WHERE i.etudiant_id = e.id
       ) AS total_cours
FROM ETUDIANT e;

CREATE OR REPLACE VIEW vue_etudiant_charges AS
SELECT e.id AS etudiant_id, e.nom, 
       COUNT(i.id) AS nb_inscriptions, 
       SUM(c.credits) AS total_credits
FROM ETUDIANT e
LEFT JOIN INSCRIPTION i ON i.etudiant_id = e.id
LEFT JOIN ENSEIGNEMENT ens ON i.enseignement_id = ens.id
LEFT JOIN COURS c ON ens.cours_id = c.id
GROUP BY e.id, e.nom;


SELECT c.titre, COUNT(i.id) AS nb_inscriptions
FROM COURS c
LEFT JOIN ENSEIGNEMENT ens ON ens.cours_id = c.id
LEFT JOIN INSCRIPTION i ON i.enseignement_id = ens.id
GROUP BY c.id, c.titre;

-- Cours avec plus de 10 inscriptions
SELECT c.titre
FROM COURS c
LEFT JOIN ENSEIGNEMENT ens ON ens.cours_id = c.id
LEFT JOIN INSCRIPTION i ON i.enseignement_id = ens.id
GROUP BY c.id, c.titre
HAVING COUNT(i.id) > 10;


SELECT ens.semestre, ROUND(AVG(ex.score), 2) AS moyenne_score
FROM EXAMEN ex
JOIN INSCRIPTION i ON ex.inscription_id = i.id
JOIN ENSEIGNEMENT ens ON i.enseignement_id = ens.id
GROUP BY ens.semestre;

ALTER TABLE EXAMEN ADD COLUMN commentaire TEXT;

