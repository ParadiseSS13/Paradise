//Action availability flags
#define AB_CHECK_RESTRAINED 1
#define AB_CHECK_STUNNED 2
#define AB_CHECK_LYING 4
#define AB_CHECK_CONSCIOUS 8
#define AB_TRANSFER_MIND 16
#define AB_CHECK_TURF 32

//Advanced action types
//Those actions have cooldown, and unavailable until it ends
#define ADV_ACTION_TYPE_RECHARGE "recharge"
//Those actions are toggled on and off
#define ADV_ACTION_TYPE_TOGGLE "toggle"
//Those actions have cooldown, but u can turn the corresponding ability off before it ends,
//or do something else with a smart use of "action_ready" var
#define ADV_ACTION_TYPE_TOGGLE_RECHARGE "toggle_recharge"
//Those actions have charges and are unavailable until you regain at least one charge.
#define ADV_ACTION_TYPE_CHARGES "charges"
