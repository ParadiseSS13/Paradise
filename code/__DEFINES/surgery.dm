/// Defines for surgery and other stuff.


// Used in surgery step to determine how blood should be spread to the doc
/// Don't splash any blood.
#define SURGERY_BLOODSPREAD_NONE 0
/// Cover the surgeon's hands in blood.
#define SURGERY_BLOODSPREAD_HANDS 1
/// Cover the surgeon's body in blood.
#define SURGERY_BLOODSPREAD_FULLBODY 2

// The type of surgeries that an initiator can start.
// Note that this doesn't apply for surgeries applied on missing organs.
/// An initiator with this can start surgeries on organic organs. Make sure that anything that can be sharp gets this as well.
#define SURGERY_INITIATOR_ORGANIC 1
/// An initiator with this can start surgeries on robotic organs.
#define SURGERY_INITIATOR_ROBOTIC 2

// How "open" an organ is.

/// Closed up.
#define ORGAN_CLOSED 0

// Different defines for different organ types, though both can still reference ORGAN_CLOSED
/// An organic limb that's been opened, at least once.
#define ORGAN_ORGANIC_OPEN 1
/// An organ that's encased, probably with bone, where that casing has been cut through.
#define ORGAN_ORGANIC_ENCASED_OPEN 2

/// Synthetic organ that's been unscrewed.
#define ORGAN_SYNTHETIC_LOOSENED 3
/// Synthetic organ that's had its panel opened.
#define ORGAN_SYNTHETIC_OPEN 4

// Return defines for surgery steps

/// Return this from begin_step() to abort the step and not try the surgery.
#define SURGERY_BEGINSTEP_ABORT (-1)

/// Return this from begin_step() to skip the current step entirely and proceed to the next one.
/// Use this if you would end up leaving someone in an invalid state.
#define SURGERY_BEGINSTEP_SKIP (1)

// Return these from end_step/fail_step to indicate the next move

/// The surgery step was not completed for some reason, and the next action will again be on this step.
#define SURGERY_STEP_INCOMPLETE 0
/// The surgery step was completed, and the surgery should continue to the next step.
#define SURGERY_STEP_CONTINUE 1
/// This step will automatically be retried without question as long as this is returned.
/// Be very cautious with this one! Make sure that any flow where this is used has an exit condition where something else will be returned.
/// Otherwise, the user will be stuck in a loop!
#define SURGERY_STEP_RETRY_ALWAYS 2
/// This surgery step will be conditionally retried, so long as the surgery step's can_repeat() proc returns TRUE.
/// Otherwise, it'll behave just like SURGERY_STEP_INCOMPLETE.
#define SURGERY_STEP_RETRY 3
