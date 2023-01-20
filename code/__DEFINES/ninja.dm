//ninjacost() extraCheckFlag defines
#define N_STEALTH_CANCEL 1
#define N_ADRENALINE 2
#define N_HEAL 3

#define NINJA_INIT_LOCK_PHASE 6
#define NINJA_INIT_ICON_GENERATE_PHASE 8
#define NINJA_INIT_MODULES_PHASE 9
#define NINJA_INIT_COMPLETE_PHASE 14

#define NINJA_DEINIT_LOGOFF_PHASE 1
#define NINJA_DEINIT_MODULES_PHASE 4
#define NINJA_DEINIT_ICON_REGENERATE_PHASE 7
#define NINJA_DEINIT_UNLOCK_PHASE 9
#define NINJA_DEINIT_COMPLETE_PHASE 13

//ninja alpha defines
#define NINJA_ALPHA_NORMAL 255
#define NINJA_ALPHA_SPIRIT_FORM 64
#define NINJA_ALPHA_INVISIBILITY 0

//ninja suit tgui related flags
#define NINJA_TGUI_MAIN_SCREEN_STATE 0
#define NINJA_TGUI_LOADING_STATE 1

//ninjaDrainAct() defines for non numerical returns
#define INVALID_DRAIN "INVALID" //This one is if the drain proc needs to cancel, eg missing variables, etc, it's important.
#define DRAIN_RD_HACK_FAILED "RDHACKFAIL"
#define DRAIN_MOB_SHOCK "MOBSHOCK"
#define DRAIN_MOB_SHOCK_FAILED "MOBSHOCKFAIL"
