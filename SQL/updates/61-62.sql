# Updates the DB from 61 to 62 ~SpaghettiBit
# Adds a subtype race to be stored on character saves

# Add species_subtype after species
ALTER TABLE `characters`
	ADD COLUMN `species_subtype` VARCHAR(7) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'None' AFTER `species`;
