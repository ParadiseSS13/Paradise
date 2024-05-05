CREATE TEMPORARY TABLE characters_temp (
id INT,
new_skintone INT
) ENGINE=MEMORY;

INSERT INTO characters_temp (id, new_skintone)
	SELECT
	id,
	CASE
		WHEN skin_tone = 1 THEN 1
		WHEN skin_tone = 2 THEN 13
		WHEN skin_tone = 3 THEN 12
		WHEN skin_tone = 4 THEN 4
		WHEN skin_tone = 5 THEN 2
		WHEN skin_tone = 6 THEN 6
		WHEN skin_tone = 7 THEN 3
		WHEN skin_tone = 8 THEN 5
		ELSE 1
	END AS st
	FROM characters;

UPDATE characters, characters_temp
SET characters.skin_tone = characters_temp.new_skintone
WHERE characters.id = characters_temp.id;

DROP TABLE characters_temp;
