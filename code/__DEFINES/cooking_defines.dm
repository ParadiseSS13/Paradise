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
#define PCWJ_BURN_TIME_LOW 15 MINUTES
#define PCWJ_BURN_TIME_MEDIUM 10 MINUTES
#define PCWJ_BURN_TIME_HIGH 5 MINUTES

// Ignite times for reagents interacting with a stove.
// The stove will catch fire if left on too long with flammable reagents in any of its holders.
#define PCWJ_IGNITE_TIME_LOW 20 MINUTES
#define PCWJ_IGNITE_TIME_MEDIUM 15 MINUTES
#define PCWJ_IGNITE_TIME_HIGH 10 MINUTES

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
#define PCWJ_USE_GRILL(temperature, time, options...) new/datum/cooking/recipe_step/use_grill(temperature, time, list(##options))
#define PCWJ_USE_OVEN(temperature, time, options...) new/datum/cooking/recipe_step/use_oven(temperature, time, list(##options))
#define PCWJ_USE_STOVE(temperature, time, options...) new/datum/cooking/recipe_step/use_stove(temperature, time, list(##options))
#define PCWJ_USE_ICE_CREAM_MIXER(time, options...) new/datum/cooking/recipe_step/use_ice_cream_mixer(time, list(##options))
#define PCWJ_USE_DEEP_FRYER(time, options...) new/datum/cooking/recipe_step/use_deep_fryer(time, list(##options))

#define PCWJ_CONTAINER_AVAILABLE 1
#define PCWJ_CONTAINER_BUSY 2

#define COOKER_SURFACE_STOVE "stovetop"
#define COOKER_SURFACE_GRILL "grill"
#define COOKER_SURFACE_OVEN "oven"
#define COOKER_SURFACE_DEEPFRYER "deepfryer"
#define COOKER_SURFACE_ICE_CREAM_MIXER "ice_cream_mixer"
