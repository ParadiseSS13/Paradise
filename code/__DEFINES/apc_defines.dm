// main_status var
#define APC_EXTERNAL_POWER_NOTCONNECTED 0
#define APC_EXTERNAL_POWER_NOENERGY 1
#define APC_EXTERNAL_POWER_GOOD 2

//opened
#define APC_CLOSED 0
#define APC_OPENED 1
#define APC_COVER_OFF 2

#define APC_AUTOFLAG_ALL_OFF 0
#define APC_AUTOFLAG_ENVIRO_ONLY 1
#define APC_AUTOFLAG_EQUIPMENT_OFF 2
#define APC_AUTOFLAG_ALL_ON 3

//electronics_state
#define APC_ELECTRONICS_NONE 0
#define APC_ELECTRONICS_INSTALLED 1

/// Power channel is off, anything connected to it is not powered, cannot be set manually by players
#define APC_CHANNEL_SETTING_OFF 0
/// APC power channel Setting Off, if set while apc is "on" set apc to "off" otherwise set to "auto-off"
#define APC_CHANNEL_SETTING_AUTO_OFF 1
/// APC power channel setting on,
#define APC_CHANNEL_SETTING_ON 2   //on
// APC user setting,
#define APC_CHANNEL_SETTING_AUTO_ON  3 //auto
