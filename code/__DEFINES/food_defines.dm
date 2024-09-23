/// Used for secondary goals.
/// TOO easy, not accepted for variety goals.
#define FOOD_GOAL_SKIP 0
/// Easy food, ask for a lot for single goals.
#define FOOD_GOAL_EASY 1
/// Normal food, ask for a middling amount for single goals.
#define FOOD_GOAL_NORMAL 2
/// Hard reagent, ask for a little for single goals.
#define FOOD_GOAL_HARD 3
/// TOO hard, accepted for variety goals, but never used for single goals.
#define FOOD_GOAL_EXCESSIVE 4
/// Same as FOOD_GOAL_EXCESSIVE, just different name to indicate that there's another version of this food that's used in variety goals.
#define FOOD_GOAL_DUPLICATE FOOD_GOAL_EXCESSIVE
