Create table PARRAINS(
    num_etu1 INT NOT NULL,
    num_etu2 INT NOT NULL,
    PRIMARY KEY (num_etu1,num_etu2)
);

CREATE OR REPLACE FUNCTION check_existence_etudiants()
RETURN TRIGGER AS $$
BEGIN
    IF NEW.num_etu1 IS NULL THEN
        RAISE EXCEPTION 'Le numéro de l etudiant 1 ne doit pas être null';
    END IF;

    IF NEW.num_etu2 IS NULL THEN
        RAISE EXCEPTION 'Le numéro de l etudiant 2 ne doit pas être null';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM etudiants
        WHERE numetu = NEW.num_etu1;
    ) THEN
        RAISE EXCEPTION 'Etudiant % inexistant', NEW.num_etu1;
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM etudiants
        WHERE numetu = NEW.num_etu2;
    ) THEN
        RAISE EXCEPTION 'Etudiant % inexistant', NEW.num_etu2;
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM etudiants
        WHERE (numetu = NEW.num_etu1 and numetu = NEW.num_etu2);
    ) THEN
        RAISE EXCEPTION 'Etudiant % % inexistant', NEW.num_etu1,NEW.num_etu2;
    END IF;

    

    RETURN NEW;
END;
$$ LANGUAGE plpgsql

CREATE TRIGGER trigger_check_existence
BEFORE INSERT OR UPDATE ON PARRAINS
FOR EACH ROW 
EXECUTE FUNCTION check_existence_etudiants(); 