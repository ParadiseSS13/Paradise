// Armor defines for the new stacking-armor system
// We always declare armor in percentages, calculating actual value on the backend
// If armor >= 100, it counts as INFINITY and won't be decreased by any negative armor value or armor penetration
// Any other armor can be decreased by negative armor. Negative armor can't be penetrated (since there is nothing to penetrate)
// Basically armor varies from -INFINITY to 100 when we talk about its percentage
// Or -MAX_ARMOR_VALUE to INFINITY when we talk about its value
// And please, don't change 100 in these defines, since 100 is what we expect to be max armor percentage!

/// The higher constant the more precise calculations will be. 50 is pretty much enough
#define ARMOR_CONSTANT 50
/// Max possible armor value. Anything above will count as INFINITY
#define MAX_ARMOR_VALUE ARMOR_CONSTANT * 100
/// We will round to this value in armor value calculations
#define ARMOR_PRECISION 0.01

/// Calculates damage based on new armor system. This should be the only place that calculates damage based on PERCENTAGE_TO_ARMOR_VALUE()
#define ARMOR_EQUATION(damage, armor) . = (. = PERCENTAGE_TO_ARMOR_VALUE(armor)) <= -ARMOR_CONSTANT ? INFINITY : ARMOR_CONSTANT * damage / (ARMOR_CONSTANT + .)
/// Converts percentage to new armor system's armor value. Used outside of ARMOR_EQUATION() only when we stack multiple sources of armor,
/// always convert the result back into percentages using ARMOR_VALUE_TO_PERCENTAGE()
#define PERCENTAGE_TO_ARMOR_VALUE(percentage) (percentage >= 100 ? INFINITY : MAX_ARMOR_VALUE / (100 - percentage) - ARMOR_CONSTANT)
/// Converts new armor system's armor value to percentage
#define ARMOR_VALUE_TO_PERCENTAGE(value) (value <= -ARMOR_CONSTANT ? 100 : round(100 - MAX_ARMOR_VALUE / (value + ARMOR_CONSTANT), ARMOR_PRECISION))
