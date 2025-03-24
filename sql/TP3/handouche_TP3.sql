--Handouche Quentin TPD

--1
CREATE TABLE type
(
typ_id char(3) PRIMARY KEY,
typ_nom varchar(30)
);

CREATE TABLE pokemon
(
pok_id int PRIMARY KEY,
pok_nom varchar(30) NOT NULL,
pok_poids real NOT NULL,
pok_taille real NOT NULL,
pok_evo int REFERENCES pokemon(pok_id),
pok_type1 char(3) NOT NULL REFERENCES type(typ_id),
pok_type2 char(3) REFERENCES type(typ_id)
);

CREATE TABLE efficacite
(
eff_id1 char(3) REFERENCES type(typ_id),
eff_id2 char(3) REFERENCES type(typ_id),
eff_taux real NOT NULL,
CONSTRAINT pk_effID PRIMARY KEY (eff_id1,eff_id2)
);



--2
CREATE OR REPLACE FUNCTION check_minuscule_type()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE type set typ_id = UPPER(typ_id);
    NEW.typ_id := UPPER(NEW.typ_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tgr_check_minuscule_type
BEFORE INSERT on type
FOR EACH ROW
EXECUTE FUNCTION check_minuscule_type();

--3

CREATE OR REPLACE FUNCTION remplir_efficacite()
RETURNS TRIGGER AS $$
DECLARE
    e RECORD;
BEGIN
    FOR e in select typ_id from type LOOP
        insert into efficacite values (NEW.typ_id,e.typ_id,1);
        IF e.typ_id <> NEW.typ_id THEN
            INSERT INTO efficacite VALUES (e.typ_id, NEW.typ_id, 1);
        END IF;
    END LOOP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_remplir_efficacite
AFTER INSERT ON type
FOR EACH ROW
EXECUTE FUNCTION remplir_efficacite();

--4

CREATE OR REPLACE FUNCTION maj_efficacite(eff_1 varchar,eff_2 varchar,taux real)
RETURNS VOID AS $$
DECLARE
    e RECORD;
    veff_id1 varchar;
    veff_id2 varchar;
BEGIN
    Select typ_id into veff_id1 from type where typ_nom ilike eff_1;
    Select typ_id into veff_id2 from type where typ_nom ilike eff_2;

    FOR e in select eff_id1,eff_id2 from efficacite LOOP
        IF e.eff_id1 = veff_id1 and e.eff_id2 = veff_id2 THEN
            UPDATE efficacite set eff_taux = taux where eff_id1 = veff_id1 and eff_id2 = veff_id2;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

--5

CREATE OR REPLACE PROCEDURE affiche_type_super_efficace()
LANGUAGE plpgsql as $$
DECLARE 
    e RECORD;
    veff_n1 varchar;
    veff_n2 varchar;
BEGIN
    FOR e in select * from efficacite LOOP
        SELECT typ_nom INTO veff_n1 FROM type WHERE typ_id = e.eff_id1;
        SELECT typ_nom INTO veff_n2 FROM type WHERE typ_id = e.eff_id2;
        IF e.eff_taux = 2 THEN
            RAISE NOTICE 'Le type % est conseillé contre le type %. Efficacité de %',veff_n1,veff_n2,e.eff_taux;
        END IF;
        IF e.eff_taux = 1 THEN
            RAISE NOTICE 'Le type % est égalité contre le type %. Efficacité de %',veff_n1,veff_n2,e.eff_taux;
        END IF;
        IF e.eff_taux = 0.5 OR e.eff_taux = 0 THEN
            RAISE NOTICE 'Le type % est déconseillé contre le type %. Efficacité de %',veff_n1,veff_n2,e.eff_taux;
        END IF;
    END LOOP;
END;
$$;


--6

INSERT INTO pokemon (pok_id, pok_nom, pok_poids, pok_taille, pok_evo, pok_type1, pok_type2) VALUES
(1, 'Bulbizarre', 6.9, 0.7, NULL, 'PLA', 'POI'),
(2, 'Herbizarre', 13.0, 1.0, 1, 'PLA', 'POI'),
(3, 'Florizarre', 100.0, 2.0, 2, 'PLA', 'POI'),
(4, 'Salamèche', 8.5, 0.6, NULL, 'FEU', NULL),
(5, 'Reptincel', 19.0, 1.1, 4, 'FEU', NULL),
(6, 'Dracaufeu', 90.5, 1.7, 5, 'FEU', 'VOL'),
(7, 'Carapuce', 9.0, 0.5, NULL, 'EAU', NULL),
(8, 'Carabaffe', 22.5, 1.0, 7, 'EAU', NULL),
(9, 'Tortank', 85.5, 1.6, 8, 'EAU', NULL),
(10, 'Chenipan', 2.9, 0.3, NULL, 'INS', NULL),
(11, 'Chrysacier', 9.9, 0.7, 10, 'INS', NULL),
(12, 'Papilusion', 32.0, 1.1, 11, 'INS', 'VOL'),
(13, 'Aspicot', 3.2, 0.3, NULL, 'INS', 'POI'),
(14, 'Coconfort', 10.0, 0.6, 13, 'INS', 'POI'),
(15, 'Dardargnan', 29.5, 1.0, 14, 'INS', 'POI'),
(16, 'Roucool', 1.8, 0.3, NULL, 'NOR', 'VOL'),
(17, 'Roucoups', 30.0, 1.1, 16, 'NOR', 'VOL'),
(18, 'Roucarnage', 39.5, 1.5, 17, 'NOR', 'VOL'),
(19, 'Rattata', 3.5, 0.3, NULL, 'NOR', NULL),
(20, 'Rattatac', 18.5, 0.7, 19, 'NOR', NULL),
(21, 'Pikachu', 6.0, 0.4, NULL, 'ELE', NULL),
(22, 'Raichu', 30.0, 0.8, 21, 'ELE', NULL),
(23, 'Sabelette', 12.0, 0.6, NULL, 'SOL', NULL),
(24, 'Sablaireau', 29.5, 1.0, 23, 'SOL', NULL),
(25, 'Nidoran♀', 7.0, 0.4, NULL, 'POI', NULL),
(26, 'Nidorina', 20.0, 0.8, 25, 'POI', NULL),
(27, 'Nidoqueen', 60.0, 1.3, 26, 'POI', 'SOL'),
(28, 'Nidoran♂', 9.0, 0.5, NULL, 'POI', NULL),
(29, 'Nidorino', 19.5, 0.9, 28, 'POI', NULL),
(30, 'Nidoking', 62.0, 1.4, 29, 'POI', 'SOL');

-- Création de la procédure affiche_type_super_efficace_pokemon
CREATE OR REPLACE PROCEDURE affiche_type_super_efficace_pokemon()
LANGUAGE plpgsql AS $$
DECLARE
    p1 RECORD; -- Pokémon conseillé (attaquant)
    p2 RECORD; -- Pokémon cible (défenseur)
    eff1 REAL; -- Efficacité contre le premier type du défenseur
    eff2 REAL; -- Efficacité contre le second type du défenseur
    eff3 REAL; -- Efficacité du type secondaire de l'attaquant contre le premier type du défenseur
    eff4 REAL; -- Efficacité du type secondaire de l'attaquant contre le second type du défenseur
    efficacite_globale REAL; -- Efficacité totale 
BEGIN
    FOR p1 IN SELECT * FROM pokemon LOOP

        FOR p2 IN SELECT * FROM pokemon LOOP

            eff1 := 1;
            eff2 := 1;
            eff3 := 1;
            eff4 := 1;

            SELECT eff_taux INTO eff1 FROM efficacite WHERE eff_id1 = p1.pok_type1 AND eff_id2 = p2.pok_type1;

            IF p2.pok_type2 IS NOT NULL THEN 
                SELECT eff_taux INTO eff2  FROM efficacite  WHERE eff_id1 = p1.pok_type1 AND eff_id2 = p2.pok_type2;
            END IF;

            IF p1.pok_type2 IS NOT NULL THEN 
                SELECT eff_taux INTO eff3FROM efficacite WHERE eff_id1 = p1.pok_type2 AND eff_id2 = p2.pok_type1;
            END IF;

            IF p1.pok_type2 IS NOT NULL AND p2.pok_type2 IS NOT NULL THEN 
                SELECT eff_taux INTO eff4 FROM efficacite WHERE eff_id1 = p1.pok_type2 AND eff_id2 = p2.pok_type2;
            END IF;

            efficacite_globale := eff1 * eff2 * eff3 * eff4;

            IF efficacite_globale > 1 THEN
                RAISE NOTICE '% est conseillé face à % : efficacité globale de %.',
                    p1.pok_nom, p2.pok_nom, efficacite_globale;
            END IF;
        END LOOP;
    END LOOP;
END;
$$;

--NOTICE:  Bulbizarre est conseillé face à Carapuce : efficacité globale de 2.
--NOTICE:  Bulbizarre est conseillé face à Carabaffe : efficacité globale de 2.
--NOTICE:  Bulbizarre est conseillé face à Tortank : efficacité globale de 2.
--NOTICE:  Herbizarre est conseillé face à Carapuce : efficacité globale de 2.
--NOTICE:  Herbizarre est conseillé face à Carabaffe : efficacité globale de 2.
--NOTICE:  Herbizarre est conseillé face à Tortank : efficacité globale de 2.
--NOTICE:  Florizarre est conseillé face à Carapuce : efficacité globale de 2.
--NOTICE:  Florizarre est conseillé face à Carabaffe : efficacité globale de 2.
--NOTICE:  Florizarre est conseillé face à Tortank : efficacité globale de 2.
--NOTICE:  Salamèche est conseillé face à Bulbizarre : efficacité globale de 2.
--NOTICE:  Salamèche est conseillé face à Herbizarre : efficacité globale de 2.
--NOTICE:  Salamèche est conseillé face à Florizarre : efficacité globale de 2.
--NOTICE:  Salamèche est conseillé face à Chenipan : efficacité globale de 2.