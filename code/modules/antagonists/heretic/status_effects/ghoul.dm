/datum/status_effect/ghoul
	id = "ghoul"
	alert_type = /atom/movable/screen/alert/status_effect/ghoul
	/// The new max health value set for the ghoul, if supplied
	var/new_max_health
	/// What, if any, stamina modifier we applied to the ghoul mob
	var/stamina_mod_applied
	/// Reference to the master of the ghoul's mind
	var/datum/mind/master_mind
	/// An optional callback invoked when a ghoul is made (on_apply)
	var/datum/callback/on_made_callback
	/// An optional callback invoked when a goul is unghouled (on_removed)
	var/datum/callback/on_lost_callback

/datum/status_effect/ghoul/Destroy()
	master_mind = null
	on_made_callback = null
	on_lost_callback = null
	return ..()

/datum/status_effect/ghoul/on_creation(
	mob/living/new_owner,
	new_max_health,
	datum/mind/master_mind,
	datum/callback/on_made_callback,
	datum/callback/on_lost_callback,
)

	src.new_max_health = new_max_health
	src.master_mind = master_mind
	src.on_made_callback = on_made_callback
	src.on_lost_callback = on_lost_callback

	. = ..()

/datum/status_effect/ghoul/on_apply()
	if(!ishuman(owner))
		return FALSE

	var/mob/living/carbon/human/human_target = owner

	RegisterSignal(human_target, COMSIG_MOB_DEATH, PROC_REF(remove_ghoul_status))
	human_target.revive() // Have to do an admin heal here, otherwise they'll likely just die due to missing organs or limbs

	if(new_max_health)
		if(new_max_health < human_target.maxHealth)
			if(isnum(stamina_mod_applied))
				stamina_mod_applied = (new_max_health / human_target.maxHealth)
			human_target.physiology.stamina_mod *= stamina_mod_applied
		human_target.setMaxHealth(new_max_health)
		human_target.health = new_max_health

	on_made_callback?.Invoke(human_target)
	ADD_TRAIT(human_target, TRAIT_FAKEDEATH, UID())
	human_target.become_husk(MAGIC_TRAIT)
	human_target.faction |= "heretic"

	if(human_target.mind)
		human_target.mind.add_antag_datum(new /datum/antagonist/mindslave/heretic_monster(master_mind))
		human_target.mind.remove_antag_datum(/datum/antagonist/cultist)
	return TRUE

/datum/status_effect/ghoul/on_remove()
	remove_ghoul_status()
	return ..()

/// Removes the ghoul effects from our owner and returns them to normal.
/datum/status_effect/ghoul/proc/remove_ghoul_status(datum/source)
	SIGNAL_HANDLER

	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/human_target = owner

	if(new_max_health)
		if(isnum(stamina_mod_applied))
			human_target.physiology.stamina_mod /= stamina_mod_applied
		human_target.setMaxHealth(initial(human_target.maxHealth))

	on_lost_callback?.Invoke(human_target)
	REMOVE_TRAIT(human_target, TRAIT_FAKEDEATH, UID())
	human_target.cure_husk(MAGIC_TRAIT)
	human_target.faction -= "heretic"
	human_target.mind?.remove_antag_datum(/datum/antagonist/mindslave/heretic_monster)
	var/datum/antagonist/heretic/whoetic = master_mind.has_antag_datum(/datum/antagonist/heretic)
	LAZYREMOVE(whoetic.list_of_our_monsters, owner.UID())

	UnregisterSignal(human_target, COMSIG_MOB_DEATH)
	if(!QDELETED(src))
		qdel(src)

/atom/movable/screen/alert/status_effect/ghoul
	name = "Flesh Servant"
	desc = "You are a Ghoul!"
	icon_state = "mind_control"
