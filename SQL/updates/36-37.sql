# Updates DB from 36 to 37 -AffectedArc07
# New preferences column for colourblind mode

ALTER TABLE `player` ADD COLUMN `colourblind_mode` VARCHAR(48) NOT NULL DEFAULT 'None' AFTER `ghost_darkness_level`;
