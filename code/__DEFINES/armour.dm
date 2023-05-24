// Armour defines for the new armour system.

#define ARMOUR_CONSTANT 50
#define ARMOUR_EQUATION(damage, armour, modifier) (armour <= -ARMOUR_CONSTANT ? INFINITY : (damage / (1 + (armour / ARMOUR_CONSTANT))) * modifier)
#define ARMOUR_PERCENTAGE_TO_VALUE(percentage) (percentage >= 100 ? INFINITY : (5000 / (100 - percentage)) - 50)
#define ARMOUR_VALUE_TO_PERCENTAGE(value) (value == INFINITY ? 100 : round((100 - (100 / (1 + (value / ARMOUR_CONSTANT)))), 0.01))
