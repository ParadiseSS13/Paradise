// Used in surgery step to determine how blood should be spread to the doc
/// Don't splash any blood.
#define SURGERY_BLOODSPREAD_NONE 0
/// Cover the surgeon's hands in blood.
#define SURGERY_BLOODSPREAD_HANDS 1
/// Cover the surgeon's body in blood.
#define SURGERY_BLOODSPREAD_FULLBODY 2

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

// Return these from end_step/fail_step to indicate the next move

/// The surgery step needs to be retried.
#define SURGERY_STEP_INCOMPLETE 0
/// The surgery should proceed to the next step.
#define SURGERY_STEP_CONTINUE 1
/// This step should be immediately retried.
#define SURGERY_STEP_RETRY 2
