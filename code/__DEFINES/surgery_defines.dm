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
/// An organ that has been violently opened, likely via damage.
#define ORGAN_ORGANIC_VIOLENT_OPEN 3

/// Synthetic organ that's been unscrewed.
#define ORGAN_SYNTHETIC_LOOSENED 4
/// Synthetic organ that's had its panel opened.
#define ORGAN_SYNTHETIC_OPEN 5

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

// Return values for surgery_step.initiate().
// Before you ask, yes, we need another definition for surgery steps here, since these control how we will act on the attack-chain
// side of things.
// Unless you're changing the mechanics of the surgery attack chain, you almost surely don't want to use these, and should
// instead be using the above SURGERY_STEP_X defines.

/// The surgery initiation isn't even going to be started. If you're working with the attack chain, this is probably what you'll be using.
#define SURGERY_INITIATE_CONTINUE_CHAIN 0

/// The surgery initiaition was a success. We're advancing the current surgery.
#define SURGERY_INITIATE_SUCCESS 1

/// The surgery initiation was interrupted, or for some reason never completed. We don't want to return FALSE to the attack chain, though.
#define SURGERY_INITIATE_FAILURE 2

/// The surgery never reached (or finished) the do_after. Go back to the state we were in before this even happened.
#define SURGERY_INITIATE_INTERRUPTED 3
