#define MARTIAL_COMBO_FAIL			0		// If the combo failed
#define MARTIAL_COMBO_CONTINUE		1		// If the combo should continue
#define MARTIAL_COMBO_DONE			2		// If the combo is successful and done
#define MARTIAL_COMBO_DONE_NO_CLEAR 3		// If the combo is successful and done but the others should have a chance to finish

#define MARTIAL_ARTS_CANNOT_USE 	-1

#define MARTIAL_COMBO_STEP_HARM		"harm"
#define MARTIAL_COMBO_STEP_DISARM	"disarm"
#define MARTIAL_COMBO_STEP_GRAB		"grab"
#define MARTIAL_COMBO_STEP_HELP		"help"

// A check used for all act types. Such as disarm_act
#define MARTIAL_ARTS_ACT_CHECK if((. = ..()) != FALSE) return .
