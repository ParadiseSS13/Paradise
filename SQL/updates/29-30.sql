# Updating SQL from 29 to 30 -AffectedArc07
# Add new viewrange toggle
ALTER TABLE `player` ADD COLUMN `viewrange` VARCHAR(5) NOT NULL DEFAULT '17x15' COLLATE 'utf8mb4_general_ci' AFTER `keybindings`;
