/datum/action/cooldown/mob_cooldown/vox_armalis/activate_qani
	name = "Activate Qani-Laaca"
	button_icon = 'icons/obj/surgery.dmi'
	button_icon_state = "sandy"
	desc = "Activates an advanced Qani-Laaca implant, giving you high speed and the ability to dodge bullets for 20 seconds."
	click_to_activate = FALSE
	melee_cooldown_time = CLICK_CD_CLICK_ABILITY
	cooldown_time = 40 SECONDS
	shared_cooldown = NONE

/datum/action/cooldown/mob_cooldown/vox_armalis/activate_qani/Activate(atom/target)
	var/mob/living/basic/megafauna/vox_armalis/armalis = owner
	if(!istype(armalis))
		return
	RegisterSignal(armalis, COMSIG_MOVABLE_MOVED, PROC_REF(on_movement))
	RegisterSignal(armalis, COMSIG_ATOM_PREHIT, PROC_REF(dodge_bullets))
	armalis.next_move_modifier -= 0.5
	armalis.speed -= 1
	addtimer(CALLBACK(src, PROC_REF(end_qani)), 20 SECONDS)
	to_chat(armalis, "<span class='notice'>A flood of suppressants and performance enhancers flood your system, while your augments go into overdrive.</span>")
	StartCooldown()

/// Leaves an afterimage behind the mob when they move
/datum/action/cooldown/mob_cooldown/vox_armalis/activate_qani/proc/on_movement(mob/living/L, atom/old_loc)
	SIGNAL_HANDLER
	if(HAS_TRAIT(L, TRAIT_IMMOBILIZED))
		return NONE
	new /obj/effect/temp_visual/decoy/mephedrone_afterimage(old_loc, L, 1.25 SECONDS)

/// Tries to dodge incoming bullets if we aren't disabled for any reasons
/datum/action/cooldown/mob_cooldown/vox_armalis/activate_qani/proc/dodge_bullets(mob/living/basic/megafauna/vox_armalis/armalis, obj/projectile/hitting_projectile)
	SIGNAL_HANDLER

	if(HAS_TRAIT(armalis, TRAIT_IMMOBILIZED))
		return NONE
	armalis.visible_message(
		"<span class='danger'>[armalis] effortlessly dodges [hitting_projectile]!</span>",
		"<span class='userdanger'>You effortlessly evade [hitting_projectile]!</span>",
	)
	playsound(armalis, pick('sound/weapons/bulletflyby.ogg', 'sound/weapons/bulletflyby2.ogg', 'sound/weapons/bulletflyby3.ogg'), 75, TRUE)
	armalis.add_filter("mephedrone_overdose_blur", 2, gauss_blur_filter(5))
	addtimer(CALLBACK(armalis, TYPE_PROC_REF(/atom, remove_filter), "mephedrone_overdose_blur"), 0.5 SECONDS)
	return ATOM_PREHIT_FAILURE

/datum/action/cooldown/mob_cooldown/vox_armalis/activate_qani/proc/end_qani()
	var/mob/living/basic/megafauna/vox_armalis/armalis = owner
	if(!istype(armalis))
		return
	UnregisterSignal(armalis, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(armalis, COMSIG_ATOM_PREHIT)
	armalis.next_move_modifier += 0.5
	armalis.speed += 1
	to_chat(armalis, "<span class='notice'>Your augments return to standard operation speeds as the suppressants wear off.</span>")

/datum/action/cooldown/mob_cooldown/vox_armalis/swap_ammo
	name = "Switch Ammunition"
	button_icon = 'icons/obj/guns/energy.dmi'
	button_icon_state = "noisecannon"
	desc = "Switches the ammunition that your heavy spikethrower fires between spike, flechette, and AP sabot."
	click_to_activate = FALSE
	melee_cooldown_time = CLICK_CD_CLICK_ABILITY
	cooldown_time = 0 SECONDS
	shared_cooldown = NONE
	/// The type of ammunition
	var/ammo_type = 1

/datum/action/cooldown/mob_cooldown/vox_armalis/swap_ammo/Activate(atom/target)
	var/mob/living/basic/megafauna/vox_armalis/armalis = owner
	if(!istype(armalis))
		return

	var/datum/component/ranged_attacks/comp = armalis.GetComponent(/datum/component/ranged_attacks)
	if(!comp)
		return

	playsound(armalis, 'sound/weapons/kenetic_reload.ogg', 60, TRUE)
	switch(ammo_type)
		if(1)
			ammo_type++
			comp.casing_type = /obj/item/ammo_casing/caseless/spike_flechettes
			comp.burst_shots = 1
			comp.cooldown_time = 0.5 SECONDS
			to_chat(armalis, "<span class='notice'>You switch your heavy spikethrower to flechette shot.</span>")
		if(2)
			ammo_type++
			comp.casing_type = /obj/item/ammo_casing/caseless/spike_penetrator
			comp.burst_shots = 1
			comp.cooldown_time = 1 SECONDS
			to_chat(armalis, "<span class='notice'>You switch your heavy spikethrower to penetrating shot.</span>")
		if(3)
			ammo_type = 1
			comp.casing_type = /obj/item/ammo_casing/caseless/heavy_spike
			comp.burst_shots = 2
			comp.cooldown_time = 0.5 SECONDS
			to_chat(armalis, "<span class='notice'>You switch your heavy spikethrower to heavy spike shot.</span>")
	StartCooldown()

/datum/action/cooldown/mob_cooldown/vox_armalis/ignite_claws
	name = "Toggle Plasma Talons"
	button_icon = 'icons/obj/weapons/energy_melee.dmi'
	button_icon_state = "pyro_claws"
	desc = "Switches your plasma talons on or off, increasing your damage but preventing you from knocking targets back."
	click_to_activate = FALSE
	melee_cooldown_time = CLICK_CD_CLICK_ABILITY
	cooldown_time = 0 SECONDS
	shared_cooldown = NONE

/datum/action/cooldown/mob_cooldown/vox_armalis/ignite_claws/Activate(atom/target)
	var/mob/living/basic/megafauna/vox_armalis/armalis = owner
	if(!istype(armalis))
		return

	if(armalis.plasma_claws)
		armalis.plasma_claws = FALSE
		armalis.melee_damage_lower = initial(armalis.melee_damage_lower)
		armalis.melee_damage_upper = initial(armalis.melee_damage_upper)
		armalis.attack_sound = initial(armalis.attack_sound)
		armalis.attack_verb_simple = initial(armalis.attack_verb_simple)
		armalis.attack_verb_continuous = initial(armalis.attack_verb_continuous)
		playsound(armalis, 'sound/weapons/saberoff.ogg', 80, TRUE)
		to_chat(armalis, "<span class='notice'>You switch off your plasma talons.</span>")
	else
		armalis.plasma_claws = TRUE
		armalis.melee_damage_lower += 10
		armalis.melee_damage_upper += 20
		armalis.attack_sound = 'sound/weapons/blade1.ogg'
		armalis.attack_verb_simple = "slash"
		armalis.attack_verb_continuous = "slashes"
		playsound(armalis, 'sound/weapons/saberon.ogg', 80, TRUE)
		to_chat(armalis, "<span class='warning'>You switch on your plasma talons.</span>")
	armalis.update_icon(UPDATE_OVERLAYS)
	StartCooldown()
