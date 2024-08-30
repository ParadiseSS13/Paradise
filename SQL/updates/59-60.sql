ALTER TABLE
	`feedback`
MODIFY
	COLUMN `key_type` enum(
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
