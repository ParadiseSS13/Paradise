# Updating SQL from 42-43 ~AffectedArc07
# Adds round ID column to deaths table

ALTER TABLE `death` ADD COLUMN `death_rid` INT NULL AFTER `tod`;

# You may now run tools/death_rid_assigner to assign round IDs to existing deaths
