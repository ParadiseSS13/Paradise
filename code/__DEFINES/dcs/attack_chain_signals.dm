// MARK: Item Interactions

// Return values for non-attack interactions.
#define ITEM_INTERACT_COMPLETE				1 //! Cancel the rest of the attack chain, indicating success.
#define ITEM_INTERACT_SKIP_TO_AFTER_ATTACK	2 //! Skip pre-attack and attack/attack_by, going straight to after_attack.

/// Sent when this atom is clicked on by a mob with an item.
///
/// [/atom/proc/item_interaction] -> mob/living/user, obj/item/tool, list/modifiers
#define COMSIG_INTERACT_TARGET		"interact_target"

/// Sent to a mob clicking on an atom with an item.
///
/// [/atom/proc/item_interaction] -> atom/target, obj/item/tool, list/modifiers
#define COMSIG_INTERACT_USER		"interact_user"

/// Sent to an item clicking on an atom.
///
/// [/atom/proc/item_interaction] -> mob/living/user, atom/target, list/modifiers
#define COMSIG_INTERACTING			"interacting"

#define COMSIG_INTERACT_RANGED		"interact_ranged"		//! [/atom/proc/ranged_item_interaction]
#define COMSIG_INTERACTING_RANGED	"interacting_ranged"	//! [/atom/proc/ranged_item_interaction]

#define COMSIG_ACTIVATE_SELF		"activate_self"			//! [/obj/item/proc/activate_self] -> mob/user

// Attack signals. These should share the returned flags, to standardize the attack chain.
// The chain currently works like:
// tool_act -> pre_attack -> target.attackby (item.attack) -> afterattack
// You can use these signal responses to cancel the attack chain at a certain point from most attack signal types.

// MARK: Attack Chain

// Signal interceptors for short-circuiting parts of the attack chain.

#define COMPONENT_CANCEL_ATTACK_CHAIN	(1<<0)	//! Cancel the attack chain entirely.
#define COMPONENT_SKIP_ATTACK			(1<<1)	//! Skip this attack step, continuing for the next one to happen.
#define COMPONENT_SKIP_AFTERATTACK		(1<<2)	//! Skip after_attacks (while allowing for e.g. attack_by).

#define COMSIG_PRE_ATTACK			"pre_attack"			//! [/obj/item/proc/pre_attack] -> atom/target, mob/user, params

#define COMSIG_ATTACK				"attack"				//! [/obj/item/proc/attack] -> mob/living/target, mob/living/user
#define COMSIG_ATTACK_OBJ			"attack_obj"			//! [/obj/item/proc/attack_obj] -> obj/attacked, mob/user
#define COMSIG_ATTACK_OBJ_LIVING	"attack_obj_living"		//! [/obj/item/proc/attack_obj] -> obj/attacked
#define COMSIG_ATTACK_BY			"attack_by"				//! [/atom/proc/attackby] -> obj/item/weapon, mob/living/user, params

#define COMSIG_AFTER_ATTACK			"item_after_attack"		//! [/obj/item/proc/afterattack] -> atom/target, mob/user, params
#define COMSIG_AFTER_ATTACKED_BY	"after_attacked_by"		//! [/obj/item/proc/afterattack] -> obj/item/weapon, mob/user, proximity_flag, params

/// Before attackingtarget has happened, source is the attacker and target is the attacked
#define COMSIG_HOSTILE_PRE_ATTACKINGTARGET "hostile_pre_attackingtarget"
	#define COMPONENT_HOSTILE_NO_ATTACK COMPONENT_CANCEL_ATTACK_CHAIN //cancel the attack, only works before attack happens
#define COMSIG_HOSTILE_ATTACKINGTARGET "hostile_attackingtarget"
/// Called when a /mob/living/simple_animal/hostile fines a new target: (atom/source, give_target)
#define COMSIG_HOSTILE_FOUND_TARGET "comsig_hostile_found_target"
/// After attackingtarget has happened, source is the attacker and target is the attacked, extra argument for if the attackingtarget was successful
#define COMSIG_HOSTILE_POST_ATTACKINGTARGET "hostile_post_attackingtarget"

// Return values for directing the control of the attack chain. Distinct from
// signal interceptors because they're not meant to be combined, and to mesh better with
// historical use of return values in attack chain procs.

#define CONTINUE_ATTACK			0		//! Continue the attack chain, i.e. allow other signals to respond.
#define FINISH_ATTACK			(1<<0)	//! Do not continue the attack chain.
#define MELEE_COOLDOWN_PREATTACK	(1<<1)	//! Apply a CLICK_CD_MELEE cooldown.

// Legacy-only, do not use in new code

#define COMSIG_TOOL_ATTACK "tool_attack"	//! [/obj/item/proc/tool_attack_chain] -> atom/tool, mob/user
#define COMPONENT_NO_ATTACK (1<<0)
#define COMPONENT_NO_INTERACT (1<<0)
#define COMPONENT_NO_ATTACK_OBJ (1<<0)
#define COMPONENT_CANCEL_TOOLACT (1<<0)
