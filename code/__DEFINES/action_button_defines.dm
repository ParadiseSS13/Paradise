#define AB_CHECK_RESTRAINED		(1<<0)
#define AB_CHECK_STUNNED		(1<<1)
#define AB_CHECK_LYING			(1<<2)
#define AB_CHECK_CONSCIOUS		(1<<3)
#define AB_CHECK_TURF			(1<<4)
#define AB_CHECK_HANDS_BLOCKED	(1<<5)
#define AB_CHECK_IMMOBILE		(1<<6)

#define ACTION_BUTTON_DEFAULT_OVERLAY "default"
#define ACTION_BUTTON_DEFAULT_BACKGROUND "_use_ui_default_background"


//Upper left (action buttons)

#define UI_ACTION_PALETTE "WEST+0:23,NORTH-1:3"
#define UI_ACTION_PALETTE_OFFSET(north_offset) ("WEST+0:23,NORTH-[1+north_offset]:3")

#define UI_PALETTE_SCROLL "WEST+1:8,NORTH-6:28"
#define UI_PALETTE_SCROLL_OFFSET(north_offset) ("WEST+1:8,NORTH-[6+north_offset]:15")
// Defines relating to action button positions

/// Whatever the base action datum thinks is best
#define SCRN_OBJ_DEFAULT "default"
/// Floating somewhere on the hud, not in any predefined place
#define SCRN_OBJ_FLOATING "floating"
/// In the list of buttons stored at the top of the screen
#define SCRN_OBJ_IN_LIST "list"
/// In the collapseable palette
#define SCRN_OBJ_IN_PALETTE "palette"
/// In cult spell list
#define SCRN_OBJ_CULT_LIST "cult_list"
