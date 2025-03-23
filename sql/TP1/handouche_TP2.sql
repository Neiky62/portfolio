--Handouche Quentin TPD

--Exercice 1
CREATE OR REPLACE PROCEDURE affich_note()
LANGUAGE plpgsql
AS $$
DECLARE
    e_rec RECORD; --variable record pour contenir chaque ligne
BEGIN
    --Boucle pour afficher chaque résultat
    FOR e_rec IN 
        SELECT e.nometu, e.prenometu, a.note, ep.libepr
        FROM avoir_note a
        JOIN etudiants e ON a.numetu = e.numetu
        JOIN epreuves ep ON a.numepr = ep.numepr
    LOOP
        RAISE NOTICE '% % a eu % à %', e_rec.nometu, e_rec.prenometu, e_rec.note, e_rec.libepr;
    END LOOP;
END;
$$;

call affich_note()

--NOTICE:  roblin lea a eu 15 à interro anglais
--NOTICE:  macarthur leon a eu 8 à interro anglais
--NOTICE:  minol luc a eu 7 à interro anglais
--NOTICE:  bagnole sophie a eu 11 à interro anglais
--NOTICE:  bury marc a eu 15 à interro anglais
--NOTICE:  vendraux marc a eu 16 à interro anglais
--NOTICE:  vendermaele helene a eu 1 à interro anglais
--NOTICE:  marke loic a eu 6 à interro anglais
--NOTICE:  dewa leon a eu 11 à interro anglais
--NOTICE:  roblin lea a eu 12 à partiel maths
--NOTICE:  macarthur leon a eu 12 à partiel maths
--NOTICE:  minol luc a eu 3 à partiel maths
--NOTICE:  bagnole sophie a eu 15 à partiel maths
--NOTICE:  bury marc a eu 9 à partiel maths
--NOTICE:  vendraux marc a eu 11 à partiel maths
--NOTICE:  vendermaele helene a eu 13 à partiel maths
--NOTICE:  marke loic a eu 19 à partiel maths
--NOTICE:  dewa leon a eu 6 à partiel maths
--NOTICE:  besson loic a eu 8 à partiel BD
--NOTICE:  godart jean-paul a eu 14 à partiel BD
--NOTICE:  beaux marie a eu 14 à partiel BD
--NOTICE:  turini elsa a eu 11 à partiel BD
--NOTICE:  torelle elise a eu 6 à partiel BD
--NOTICE:  pharis pierre a eu 3 à partiel BD
--NOTICE:  ephyre luc a eu 20 à partiel BD
--NOTICE:  leclercq jules a eu 12 à partiel BD
--NOTICE:  dupont luc a eu 11 à partiel BD
--NOTICE:  besson loic a eu 7 à partiel UNIX
--NOTICE:  godart jean-paul a eu 11 à partiel UNIX
--NOTICE:  beaux marie a eu 12 à partiel UNIX
--NOTICE:  turini elsa a eu 3 à partiel UNIX
--NOTICE:  torelle elise a eu 20 à partiel UNIX
--NOTICE:  pharis pierre a eu 12 à partiel UNIX
--NOTICE:  ephyre luc a eu 10 à partiel UNIX
--NOTICE:  leclercq jules a eu 8 à partiel UNIX
--NOTICE:  dupont luc a eu 10 à partiel UNIX
--NOTICE:  marke loic a eu 8 à partiel UNIX


--Exercice 2

CREATE OR REPLACE PROCEDURE ajout_enseignant(ens_nom varchar,ens_prenom varchar)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO enseignants (numens,nomens,preens,datembens)
    VALUES ((SELECT MAX(numens)+1 from enseignants),ens_nom,ens_prenom,NOW());
END;
$$;

--Exercice 3

CREATE OR REPLACE PROCEDURE ajout_etudiant(etu_nom varchar,etu_prenom varchar)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO etudiants (numetu,nometu,prenometu,datentetu)
    VALUES ((SELECT MAX(numetu)+1 from etudiants),etu_nom,etu_prenom,TO_DATE(EXTRACT(YEAR FROM NOW())::text || '-09-01', 'YYYY-MM-DD'));
END;
$$;

--Exercice 4

CREATE OR REPLACE PROCEDURE ajout_note(
    etu_nom varchar,
    etu_prenom varchar,
    libele varchar,
    noteetu int
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_numetu INT;
    v_numepr INT;
BEGIN
    SELECT numetu INTO v_numetu
    FROM etudiants
    WHERE nometu = etu_nom AND prenometu = etu_prenom;

    IF v_numetu IS NULL THEN
        RAISE EXCEPTION 'Étudiant % % non trouvé', etu_nom, etu_prenom;
    END IF;

    SELECT numepr INTO v_numepr
    FROM epreuves
    WHERE libepr = libele;

    IF v_numepr IS NULL THEN
        RAISE EXCEPTION 'Épreuve % non trouvée', libele;
    END IF;

    INSERT INTO avoir_note (numetu, numepr, note)
    VALUES (v_numetu, v_numepr, noteetu);

    RAISE NOTICE 'Note % ajoutée pour l''étudiant % % à l''épreuve %', 
                 noteetu, etu_nom, etu_prenom, libele;
END;
$$;


--Exercice 5

CREATE OR REPLACE PROCEDURE modifier_note(
    etu_nom varchar,
    etu_prenom varchar,
    libele varchar,
    noteetu int
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_numetu INT; 
    v_numepr INT; 
    v_note_exists BOOLEAN; 
BEGIN
    SELECT numetu INTO v_numetu
    FROM etudiants
    WHERE nometu = etu_nom AND prenometu = etu_prenom;

    IF v_numetu IS NULL THEN
        RAISE EXCEPTION 'Étudiant % % non trouvé', etu_nom, etu_prenom;
    END IF;

    SELECT numepr INTO v_numepr
    FROM epreuves
    WHERE libepr = libele;

    IF v_numepr IS NULL THEN
        RAISE EXCEPTION 'Épreuve % non trouvée', libele;
    END IF;

    SELECT EXISTS (
        SELECT 1 
        FROM avoir_note 
        WHERE numetu = v_numetu AND numepr = v_numepr
    ) INTO v_note_exists;

    IF NOT v_note_exists THEN
        RAISE EXCEPTION 'Aucune note trouvée pour l''étudiant % % et l''épreuve %', etu_nom, etu_prenom, libele;
    END IF;

    UPDATE avoir_note
    SET note = noteetu
    WHERE numetu = v_numetu AND numepr = v_numepr;

    RAISE NOTICE 'Note modifiée pour l''étudiant % % à l''épreuve % : Nouvelle note = %',
                 etu_nom, etu_prenom, libele, noteetu;
END;
$$;
