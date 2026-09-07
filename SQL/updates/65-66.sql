# Updates DB from 64 to 65 ~Burzah
# Removes column species_subtype on the characters table

ALTER TABLE `characters`
DROP COLUMN `species_subtype`;
