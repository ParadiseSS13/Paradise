//Check item use flags
#define PCWJ_NO_STEPS 1 //! The used object has no valid recipe uses
#define PCWJ_CHOICE_CANCEL 2 //! The user opted to cancel when given a choice
#define PCWJ_SUCCESS 3 //! The user decided to use the item and the step was followed
#define PCWJ_PARTIAL_SUCCESS 4 //! The user decided to use the item but the qualifications for the step was not fulfilled
#define PCWJ_COMPLETE 5 //! The meal has been completed!
#define PCWJ_LOCKOUT 6 //! Someone tried starting the function while a prompt was running. Jerk.
#define PCWJ_BURNT 7 //! The meal was ruined by burning the food somehow.
#define PCWJ_NO_RECIPES 8 //! There are no recipes that match this object and container combination.

#define PCWJ_CHECK_INVALID 0
#define PCWJ_CHECK_VALID 1
#define PCWJ_CHECK_FULL 2 //! For reagents, nothing can be added to
#define PCWJ_CHECK_SILENT 3

//Cooking container types
#define PLATE "plate"
#define CUTTING_BOARD "cutting board"
#define PAN "pan"
#define POT "pot"
#define BOWL "bowl"
#define DF_BASKET "deep fryer basket"
#define OVEN "oven"
#define GRILL "grill grate"

// Cooking machine temperature settings.
#define J_LO "Low"
#define J_MED "Medium"
#define J_HI "High"

// Burn times for cooking things on a stove.
// Anything put on a stove for this long becomes a burned mess.
#define PCWJ_BURN_TIME_LOW 3 MINUTES
#define PCWJ_BURN_TIME_MEDIUM 2 MINUTES
#define PCWJ_BURN_TIME_HIGH 1 MINUTES

// Ignite times for reagents interacting with a stove.
// The stove will catch fire if left on too long with flammable reagents in any of its holders.
#define PCWJ_IGNITE_TIME_LOW 6 MINUTES
#define PCWJ_IGNITE_TIME_MEDIUM 4 MINUTES
#define PCWJ_IGNITE_TIME_HIGH 2 MINUTES

//Food Quality Tiers
#define PCWJ_QUALITY_GARBAGE -2
#define PCWJ_QUALITY_GROSS -1.5
#define PCWJ_QUALITY_MEH 0.5
#define PCWJ_QUALITY_NORMAL 1
#define PCWJ_QUALITY_GOOD 1.2
#define PCWJ_QUALITY_VERY_GOOD 1.4
#define PCWJ_QUALITY_CUISINE 1.6
#define PCWJ_QUALITY_LEGENDARY 1.8
#define PCWJ_QUALITY_ELDRITCH 2.0

#define PCWJ_ADD_ITEM(item_type, options...) new/datum/cooking/recipe_step/add_item(item_type, list(##options))
#define PCWJ_ADD_PRODUCE(item_type, options...) new/datum/cooking/recipe_step/add_produce(item_type, list(##options))
#define PCWJ_ADD_REAGENT(reagent_name, amount, options...) new/datum/cooking/recipe_step/add_reagent(reagent_name, amount, list(##options))
#define PCWJ_USE_GRILL(temperature, time, options...) new/datum/cooking/recipe_step/use_machine/grill(temperature, time, list(##options))
#define PCWJ_USE_OVEN(temperature, time, options...) new/datum/cooking/recipe_step/use_machine/oven(temperature, time, list(##options))
#define PCWJ_USE_STOVE(temperature, time, options...) new/datum/cooking/recipe_step/use_machine/stovetop(temperature, time, list(##options))
#define PCWJ_USE_ICE_CREAM_MIXER(time, options...) new/datum/cooking/recipe_step/use_machine/ice_cream_mixer(time, list(##options))
#define PCWJ_USE_DEEP_FRYER(time, options...) new/datum/cooking/recipe_step/use_machine/deepfryer(time, list(##options))

#define PCWJ_CONTAINER_AVAILABLE 1
#define PCWJ_CONTAINER_BUSY 2

#define COOKER_SURFACE_STOVE "stovetop"
#define COOKER_SURFACE_GRILL "grill"
#define COOKER_SURFACE_OVEN "oven"
#define COOKER_SURFACE_DEEPFRYER "deepfryer"
#define COOKER_SURFACE_ICE_CREAM_MIXER "ice_cream_mixer"

#define COOKBOOK_CATEGORY_MISC "Miscellaneous"
#define COOKBOOK_CATEGORY_MEAT "Meat Dishes"
#define COOKBOOK_CATEGORY_DESSERTS "Desserts"
#define COOKBOOK_CATEGORY_BREAD "Breads"
#define COOKBOOK_CATEGORY_BREAKFASTS "Breakfast Dishes"
#define COOKBOOK_CATEGORY_SEAFOOD "Seafood Dishes"
#define COOKBOOK_CATEGORY_SUSHI "Sushi"
#define COOKBOOK_CATEGORY_BURGS "Burgers and Sandwiches"
#define COOKBOOK_CATEGORY_PIZZAS "Pastas and Pizzas"
#define COOKBOOK_CATEGORY_SIDES "Side Dishes"
#define COOKBOOK_CATEGORY_SALADS "Salads"
#define COOKBOOK_CATEGORY_SOUPS "Soups"
#define COOKBOOK_CATEGORY_CANDY "Candies"
#define COOKBOOK_CATEGORY_VEGE "Vegetarian Dishes"
#define COOKBOOK_CATEGORY_DONUTS "Donuts"

#define RADIAL_ACTION_SET_TIMER "Set timer"
#define RADIAL_ACTION_SET_TEMPERATURE "Set temperature"
#define RADIAL_ACTION_ON_OFF "Turn on/off"

#define AUTOCHEF_TASK_QUEUE_IDLE 0
#define AUTOCHEF_TASK_QUEUE_RUNNING 1
#define AUTOCHEF_TASK_QUEUE_INTERRUPTED 2

#define AUTOCHEF_TASK_START 0
#define AUTOCHEF_TASK_COMPLETE 1
#define AUTOCHEF_TASK_FOLLOW_STEPS 2
#define AUTOCHEF_TASK_WAIT_FOR_RESULT 3
#define AUTOCHEF_TASK_INTERRUPTED 4
#define AUTOCHEF_TASK_FAILED 5

#define AUTOCHEF_STEP_FAILURE 0
#define AUTOCHEF_STEP_COMPLETE 1
#define AUTOCHEF_STEP_ADDED_TASK 2
#define AUTOCHEF_STEP_STARTED 3

#define AUTOCHEF_PREP_INVALID 0
#define AUTOCHEF_PREP_VALID 1
#define AUTOCHEF_PREP_MISSING_INGREDIENT 2
#define AUTOCHEF_PREP_MISSING_REAGENT 3
#define AUTOCHEF_PREP_NO_AVAILABLE_MACHINES 4

#define COMSIG_COOK_GRILL_NO_FUEL "cook_grill_no_fuel"
#define COMSIG_COOK_MACHINE_STEP_COMPLETE "cook_machine_step_complete"
#define COMSIG_COOK_MACHINE_STEP_INTERRUPTED "cook_machine_step_interrupted"

#define COMSIG_AUTOCHEF_FIND_MACHINE(name) "autochef_find_machine_[name]"
