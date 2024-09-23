// Cargo sell flags

// Priorities
// Each priority blocks all lower priorities.
// Any priority (even WRONG) prevents items from being considered trash.
#define COMSIG_CARGO_SELL_PRIORITY	(1<<0)
#define COMSIG_CARGO_SELL_NORMAL	(1<<1)
#define COMSIG_CARGO_SELL_WRONG		(1<<2)
#define COMSIG_CARGO_SELL_SKIP		(1<<3)
#define COMSIG_CARGO_MESS			(1<<4)

// Functional markers
// Marks the item as safe for the shuttle floor (e.g. crates)
#define COMSIG_CARGO_IS_SECURED		(1<<5)
