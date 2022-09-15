/**
	Ninja States Breaker

	This component is used to forcefully cancel some of the states typical only for the ninja
	Currently cancelles stealth and chameleon states.
 */
/datum/component/ninja_states_breaker
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// the suit reference
	var/obj/item/clothing/suit/space/space_ninja/my_suit

/datum/component/ninja_states_breaker/Initialize(ninja_suit)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	if(!istype(ninja_suit, /obj/item/clothing/suit/space/space_ninja))
		return COMPONENT_INCOMPATIBLE
	my_suit = ninja_suit

/datum/component/ninja_states_breaker/RegisterWithParent()
	RegisterSignal(parent, list(
		COMSIG_ATOM_BLOB_ACT,
		COMSIG_ATOM_FIRE_ACT,
		COMSIG_MOB_ADJUST_FIRE,
		COMSIG_PARENT_ATTACKBY,
		COMSIG_MOB_DEATH,
		COMSIG_ATOM_BULLET_ACT,
		COMSIG_ITEM_ATTACK,
		COMSIG_MOB_ITEM_ATTACK,
		COMSIG_MOB_APPLY_DAMAGE,
		COMSIG_SIMPLE_ANIMAL_ATTACKEDBY,
		COMSIG_CARBON_HITBY), .proc/cancel_states)


/datum/component/ninja_states_breaker/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ATOM_BLOB_ACT,
		COMSIG_ATOM_FIRE_ACT,
		COMSIG_MOB_ADJUST_FIRE,
		COMSIG_PARENT_ATTACKBY,
		COMSIG_MOB_DEATH,
		COMSIG_ATOM_BULLET_ACT,
		COMSIG_ITEM_ATTACK,
		COMSIG_MOB_ITEM_ATTACK,
		COMSIG_MOB_APPLY_DAMAGE,
		COMSIG_SIMPLE_ANIMAL_ATTACKEDBY,
		COMSIG_CARBON_HITBY))

/// Собственно код выключающий сам инвиз и хамелион режимы костюма
/datum/component/ninja_states_breaker/proc/cancel_states()
	//if-ы не разделять. Иначе в чат игры будет писать лишний текст
	if(my_suit.stealth)
		my_suit.cancel_stealth()
	if(my_suit.disguise_active)
		my_suit.restore_form()
