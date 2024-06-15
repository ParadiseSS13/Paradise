#define BSA_SIZE_FRONT		4
#define BSA_SIZE_BACK		6

// Secondary goals

/// How many units can be missing from a reagent and still count to the goal.
/// Prevents floationg point rounding from making you fail even though you
/// seemed to have sent enough.
#define REAGENT_GOAL_FORGIVENESS 0.1
