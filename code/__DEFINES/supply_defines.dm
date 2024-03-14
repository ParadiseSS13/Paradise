// Signal types for the cargo shuttle

// Sent before the shuttle scans its contents.
// Use to initialize data that will be needed during the scan.
#define COMSIG_CARGO_BEGIN_SCAN			"begin_scan"
// Sent as the shuttle scans its contents.
// Can return sell flags.
#define COMSIG_CARGO_CHECK_SELL			"check_sell"
// Sent as the shuttle begins selling off its contents.
// Use to initialize data that will be needed during the sale.
#define COMSIG_CARGO_BEGIN_SELL			"begin_sell"
// Sent during sales for items marked with COMSIG_CARGO_SELL_PRIORITY.
#define COMSIG_CARGO_DO_PRIORITY_SELL	"do_priority_sell"
// Sent during sales for items marked with COMSIG_CARGO_SELL_NORMAL.
#define COMSIG_CARGO_DO_SELL			"do_sell"
// Sent during sales for items marked with COMSIG_CARGO_SELL_WRONG.
#define COMSIG_CARGO_SEND_ERROR			"send_error"
// Sent when sales are completed.
// Use to send summary messages for items that sell in bulk.
#define COMSIG_CARGO_END_SELL			"end_sell"

// Cargo sell flags

// Priorities
// Each priority blocks all lower priorities.
// Any priority (even WRONG) prevents items from being considered trash.
#define COMSIG_CARGO_SELL_PRIORITY	(1<<0)
#define COMSIG_CARGO_SELL_NORMAL	(1<<1)
#define COMSIG_CARGO_SELL_WRONG		(1<<2)
#define COMSIG_CARGO_MESS			(1<<3)

// Functional markers
// Marks the item as safe for the shuttle floor (e.g. crates)
#define COMSIG_CARGO_IS_SECURED		(1<<4)
