-- Migration:  59-60
-- Author:     warriorstar
-- Introduced: PR# 26645

-- This migration adds the 'ledger' and 'nested ledger' enum values to the
-- `feedback` table in conjunction with making those feedback types available
-- through SSblackbox.
-- No data migration is required.

ALTER TABLE
	`feedback`
MODIFY
	COLUMN `key_type` ENUM(
		'text',
		'amount',
		'tally',
		'nested tally',
		'associative',
		'ledger',
		'nested ledger'
	) NOT NULL
AFTER
	`key_name`;
