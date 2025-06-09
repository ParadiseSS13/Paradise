// Airlock controller control states
#define CONTROL_STATE_IDLE			0
#define CONTROL_STATE_PREPARE		1
#define CONTROL_STATE_DEPRESSURIZE	2
#define CONTROL_STATE_PRESSURIZE	3

// Airlock controller target states
#define TARGET_NONE			0
#define TARGET_INOPEN		-1
#define TARGET_OUTOPEN		-2

// Airlock controller button modes
#define MODE_INTERIOR "int"
#define MODE_EXTERIOR "ext"

#define VENT_ID(_id_to_link)		"[_id_to_link]_vent"
#define EXT_DOOR_ID(_id_to_link)	"[_id_to_link]_door_ext"
#define INT_DOOR_ID(_id_to_link)	"[_id_to_link]_door_int"
#define EXT_BTN_ID(_id_to_link)		"[_id_to_link]_btn_ext"
#define INT_BTN_ID(_id_to_link)		"[_id_to_link]_btn_int"
