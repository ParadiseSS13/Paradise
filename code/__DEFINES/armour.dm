// Armour defines for the new armour system.

#define ARMOUR_CONSTANT 50
#define ARMOUR_EQUATION(damage, armour, modifier) ((damage / (1 + (armour / ARMOUR_CONSTANT))) * modifier)
#define ARMOUR_PERCENTAGE_TO_VALUE(percentage) ((5000 / (100 - percentage)) - 50)
#define ARMOUR_VALUE_TO_PERCENTAGE(value) (100 - (100 / (1 + (value / 50))))
