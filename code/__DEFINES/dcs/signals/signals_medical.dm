/// From /datum/surgery/New(): (datum/surgery/surgery, surgery_location (body zone), obj/item/bodypart/targeted_limb)
// #define COMSIG_MOB_SURGERY_STARTED "mob_surgery_started"

/// From /datum/surgery_step/success(): (datum/surgery_step/step, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results)
// #define COMSIG_MOB_SURGERY_STEP_SUCCESS "mob_surgery_step_success"

/// Defib-specific signals

/// Called when a defibrillator is first applied to someone. (mob/living/user, mob/living/target, harmful)
#define COMSIG_DEFIB_PADDLES_APPLIED "defib_paddles_applied"
	/// Defib is out of power.
	#define COMPONENT_BLOCK_DEFIB_DEAD (1<<0)
	/// Something else: we won't have a custom message for this and should let the defib handle it.
	#define COMPONENT_BLOCK_DEFIB_MISC (1<<1)
/// Called when a defib has been successfully used, and a shock has been applied. (mob/living/user, mob/living/target, harmful, successful)
#define COMSIG_DEFIB_SHOCK_APPLIED "defib_zap"
/// Called when a defib's cooldown has run its course and it is once again ready. ()
#define COMSIG_DEFIB_READY "defib_ready"

/// From /obj/item/shockpaddles/do_help, after the defib do_after is complete, but before any effects are applied: (mob/living/defibber, obj/item/shockpaddles/source)
// #define COMSIG_DEFIBRILLATOR_PRE_HELP_ZAP "carbon_being_defibbed"
	/// Return to stop default defib handling
	// #define COMPONENT_DEFIB_STOP (1<<0)

/// From /obj/item/shockpaddles/proc/do_success(): (obj/item/shockpaddles/source)
// #define COMSIG_DEFIBRILLATOR_SUCCESS "defib_success"
	// // #define COMPONENT_DEFIB_STOP (1<<0) // Same return, to stop default defib handling

/// From /datum/surgery/can_start(): (mob/source, datum/surgery/surgery, mob/living/patient)
// #define COMSIG_SURGERY_STARTING "surgery_starting"
	// #define COMPONENT_CANCEL_SURGERY (1<<0)
	// #define COMPONENT_FORCE_SURGERY (1<<1)
