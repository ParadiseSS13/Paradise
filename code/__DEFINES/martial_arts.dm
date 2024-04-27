#define MARTIAL_COMBO_FAIL				0		// If the combo failed
#define MARTIAL_COMBO_CONTINUE			1		// If the combo should continue
#define MARTIAL_COMBO_DONE				2		// If the combo is successful and done
#define MARTIAL_COMBO_DONE_NO_CLEAR 	3		// If the combo is successful and done but the others should have a chance to finish
#define MARTIAL_COMBO_DONE_BASIC_HIT	4		// If the combo should do a basic hit after it's done
#define MARTIAL_COMBO_DONE_CLEAR_COMBOS	5		// If the combo should do a basic hit after it's done

#define MARTIAL_ARTS_CANNOT_USE 	-1
#define MARTIAL_ARTS_ACT_SUCCESS	1

#define MARTIAL_COMBO_STEP_HARM		"Harm"
#define MARTIAL_COMBO_STEP_DISARM	"Disarm"
#define MARTIAL_COMBO_STEP_GRAB		"Grab"
#define MARTIAL_COMBO_STEP_HELP		"Help"

// A check used for all act types. Such as disarm_act
#define MARTIAL_ARTS_ACT_CHECK if((. = ..()) != FALSE) return
