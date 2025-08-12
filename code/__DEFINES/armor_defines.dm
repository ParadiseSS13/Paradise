// Armor defines for the new armor system
// We always declare armor in percentages, calculating actual value on the backend
// If armor >= MAX_ARMOR_PERCENTAGE, it counts as INFINITY and won't be decreased by any negative armor value or armor penetration
// Any other armor can be decreased by negative armor. Negative armor can't be penetrated (since there is nothing to penetrate)
// Basically armor varies from -INFINITY to MAX_ARMOR_PERCENTAGE when we talk about its percentage
// Or -MAX_ARMOR_VALUE to INFINITY when we talk about its value

/// The higher constant the more precise calculations will be. 50 is pretty much enough
#define ARMOR_CONSTANT 50
/// Max possible armor value. Anything above will count as INFINITY
#define MAX_ARMOR_VALUE ARMOR_CONSTANT * 100
/// Max sane armor% to have. You should never change this one, it will confuse everyone and break current armor values in the code
#define MAX_ARMOR_PERCENTAGE 100
/// We will round to this value in armor value calculations
#define ARMOR_PRECISION 0.01

/// Calculates damage based on new armor system. This should be the only place that calculates damage based on PERCENTAGE_TO_ARMOR_VALUE()
#define ARMOR_EQUATION(damage, armor) . = (. = PERCENTAGE_TO_ARMOR_VALUE(armor)) <= -ARMOR_CONSTANT ? INFINITY : ARMOR_CONSTANT * damage / (ARMOR_CONSTANT + .)
/// Converts percentage to new armor system's armor value. Used outside of ARMOR_EQUATION() only when we stack multiple sources of armor,
/// always convert the result back into percentages using ARMOR_VALUE_TO_PERCENTAGE()
#define PERCENTAGE_TO_ARMOR_VALUE(percentage) (percentage >= MAX_ARMOR_PERCENTAGE ? INFINITY : MAX_ARMOR_VALUE / (MAX_ARMOR_PERCENTAGE - percentage) - ARMOR_CONSTANT)
/// Converts new armor system's armor value to percentage
#define ARMOR_VALUE_TO_PERCENTAGE(value) (value == INFINITY ? MAX_ARMOR_PERCENTAGE : round(MAX_ARMOR_PERCENTAGE - MAX_ARMOR_VALUE / (value + ARMOR_CONSTANT), ARMOR_PRECISION))
