# Updating DB from 69-70 -FunnyMan3595
# Adds the admin_ranks table

# Create the new table.
CREATE TABLE `admin_ranks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `default_permissions` int(16) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=99 DEFAULT CHARSET=utf8mb4;

# Create official ranks for every existing display rank, with the minimum common permissions.
INSERT INTO admin_ranks (name, default_permissions)
SELECT admin_rank, BIT_AND(flags) FROM admin
# Admins in the "Removed" rank don't actually exist according to the old code, so don't give them a rank. Not having a rank will also stop them from getting extra_permissions later.
WHERE admin_rank != "Removed"
GROUP BY admin_rank;

# Add new columns to admin table.
ALTER TABLE admin
	ADD COLUMN `display_rank` varchar(32) COLLATE utf8mb4_unicode_ci,
	ADD COLUMN `permissions_rank` int(11) COMMENT 'Foreign key for admin_ranks.id',
	ADD COLUMN `extra_permissions` int(16) NOT NULL DEFAULT '0',
	ADD COLUMN `removed_permissions` int(16) NOT NULL DEFAULT '0';

# Set the rank and any extra_permissions for each admin.
# There won't be any removed_permissions because we took the minimum common permissions earlier.
# We also leave display_rank blank, since admin_ranks.name matches their old admin_rank.
UPDATE admin JOIN admin_ranks ON admin.admin_rank = admin_ranks.name
SET
	admin.permissions_rank = admin_ranks.id,
	admin.extra_permissions = admin.flags & ~admin_ranks.default_permissions;

# Drop the old columns from the admin table.
ALTER TABLE admin
	DROP COLUMN admin_rank,
	DROP COLUMN level,
	DROP COLUMN flags;

# Drop the lastadminrank column from the player table.
ALTER TABLE player DROP COLUMN lastadminrank;
