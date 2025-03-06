/**
 * Signals for department mechanics.
 * Doc format: `/// when the signal is called: (signal arguments)`.
 * All signals send the source datum of the signal as the first argument
 */

// Cargo shuttle

// Sent before the shuttle scans its contents.
// Use to initialize data that will be needed during the scan.
#define COMSIG_CARGO_BEGIN_SCAN			"begin_scan"
// Sent as the shuttle scans its contents.
// Can return sell flags (see code/__DEFINES/supply_defines.dm).
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


// Xenobio hotkeys

///from slime CtrlClickOn(): (/mob)
#define COMSIG_XENO_SLIME_CLICK_CTRL "xeno_slime_click_ctrl"
///from slime AltClickOn(): (/mob)
#define COMSIG_XENO_SLIME_CLICK_ALT "xeno_slime_click_alt"
///from slime ShiftClickOn(): (/mob)
#define COMSIG_XENO_SLIME_CLICK_SHIFT "xeno_slime_click_shift"
///from turf ShiftClickOn(): (/mob)
#define COMSIG_XENO_TURF_CLICK_SHIFT "xeno_turf_click_shift"
///from turf AltClickOn(): (/mob)
#define COMSIG_XENO_TURF_CLICK_CTRL "xeno_turf_click_alt"
///from monkey CtrlClickOn(): (/mob)
#define COMSIG_XENO_MONKEY_CLICK_CTRL "xeno_monkey_click_ctrl"
