#define SURGERY_FAILED			0
#define SURGERY_SUCCESS			1
#define SURGERY_CONTINUE		2 	// Return value where a surgery step will be repeated after it's done

// Start of all surgeries
#define SURGERY_STAGE_START					"start"
#define SURGERY_STAGE_ALWAYS				"always" 	// Can always be used
#define SURGERY_STAGE_SAME					"same" 		// If the next step will be the same
// Common used
#define SURGERY_STAGE_INCISION				"incision made"
#define SURGERY_STAGE_CLAMPED				"bleeding clamped"
#define SURGERY_STAGE_OPEN_INCISION			"skin retracted"
#define SURGERY_STAGE_SAWN_BONES			"bones sawn"
#define SURGERY_STAGE_OPEN_INCISION_BONES	"bones retracted"

#define SURGERY_STAGE_DENTAL				"teeth drilled"
#define SURGERY_STAGE_ATTACH_LIMB			"limb attached"
#define SURGERY_STAGE_OPEN_INCISION_CUT		"tissue cut"

// Cavity surgery
#define SURGERY_STAGE_CAVITY_OPEN			"open cavity"
#define SURGERY_STAGE_CAVITY_CLOSING		"cavity filled"

#define SURGERY_STAGE_BONES_GELLED			"bones gelled"
#define SURGERY_STAGE_BONES_SET				"bones set"

#define SURGERY_STAGE_ROBOTIC_HATCH_UNLOCKED	"hatch unlocked"
#define SURGERY_STAGE_ROBOTIC_HATCH_OPEN		"hatch open"

#define SURGERY_STAGE_CARAPACE_SAWN				"carapace sawn open"
#define SURGERY_STAGE_CARAPACE_CUT				"carapace cut"
#define SURGERY_STAGE_CARAPACE_OPEN				"carapace open"