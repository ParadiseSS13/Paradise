/obj/effect/proc_holder/spell/vampire/self/blood_swell
	name = "Blood Swell"
	desc = "You infuse your body with blood, making you highly resistant to stuns and physical damage. However, this makes you unable to fire ranged weapons while it is active."
	gain_desc = "You have gained the ability to temporarly resist large amounts of stuns and physical damage."
	base_cooldown = 40 SECONDS
	required_blood = 30
	action_icon_state = "blood_swell"


/obj/effect/proc_holder/spell/vampire/self/blood_swell/cast(list/targets, mob/user)
	var/mob/living/target = targets[1]
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.apply_status_effect(STATUS_EFFECT_BLOOD_SWELL)


/datum/vampire_passive/blood_swell_upgrade
	gain_desc = "While blood swell is active all of your melee attacks deal increased damage."


/obj/effect/proc_holder/spell/vampire/self/stomp
	name = "Seismic Stomp"
	desc = "You slam your foot into the ground sending a powerful shockwave through the station's hull, sending people flying away. Cannot be cast if you legs are impared by a bola or similar."
	gain_desc = "You have gained the ability to knock people back using a powerful stomp."
	action_icon_state = "seismic_stomp"
	base_cooldown = 30 SECONDS
	required_blood = 25
	var/max_range = 4


/obj/effect/proc_holder/spell/vampire/self/stomp/can_cast(mob/living/carbon/user, charge_check, show_message)
	if(user.legcuffed)
		return FALSE
	return ..()


/obj/effect/proc_holder/spell/vampire/self/stomp/cast(list/targets, mob/user)
	var/turf/T = get_turf(user)
	playsound(T, 'sound/effects/meteorimpact.ogg', 100, TRUE)
	addtimer(CALLBACK(src, PROC_REF(hit_check), 1, T, user), 0.2 SECONDS)
	new /obj/effect/temp_visual/stomp(T)


/obj/effect/proc_holder/spell/vampire/self/stomp/proc/hit_check(range, turf/start_turf, mob/user, safe_targets = list())
	// gets the two outermost turfs in a ring, we get two so people cannot "walk over" the shockwave
	var/list/targets = view(range, start_turf) - view(range - 2, start_turf)
	for(var/turf/simulated/floor/flooring in targets)
		if(prob(100 - (range * 20)))
			flooring.ex_act(EXPLODE_LIGHT)

	for(var/mob/living/L in targets)
		if(L in safe_targets)
			continue

		if(L.throwing) // no double hits
			continue

		if(!L.affects_vampire(user))
			continue

		if(L.move_resist > MOVE_FORCE_VERY_STRONG)
			continue

		var/throw_target = get_edge_target_turf(L, get_dir(start_turf, L))
		INVOKE_ASYNC(L, TYPE_PROC_REF(/atom/movable, throw_at), throw_target, 3, 4)
		L.Weaken(2 SECONDS)
		safe_targets += L

	var/new_range = range + 1
	if(new_range <= max_range)
		addtimer(CALLBACK(src, PROC_REF(hit_check), new_range, start_turf, user, safe_targets), 0.2 SECONDS)


/obj/effect/temp_visual/stomp
	icon = 'icons/effects/seismic_stomp_effect.dmi'
	icon_state = "stomp_effect"
	duration = 0.8 SECONDS
	pixel_y = -16
	pixel_x = -16


/obj/effect/temp_visual/stomp/Initialize(mapload)
	. = ..()
	var/matrix/M = matrix() * 0.5
	transform = M
	animate(src, transform = M * 8, time = duration, alpha = 0)


/obj/effect/proc_holder/spell/vampire/self/overwhelming_force
	name = "Overwhelming Force"
	desc = "When toggled you will automatically pry open doors that you bump into if you do not have access."
	gain_desc = "You have gained the ability to force open doors at a small blood cost."
	base_cooldown = 2 SECONDS
	action_icon_state = "OH_YEAAAAH"


/obj/effect/proc_holder/spell/vampire/self/overwhelming_force/cast(list/targets, mob/user)
	if(!HAS_TRAIT_FROM(user, TRAIT_FORCE_DOORS, VAMPIRE_TRAIT))
		to_chat(user, span_userdanger("You feel MIGHTY!"))
		ADD_TRAIT(user, TRAIT_FORCE_DOORS, VAMPIRE_TRAIT)
		user.status_flags &= ~CANPUSH
		user.move_resist = MOVE_FORCE_STRONG

	else
		to_chat(user, span_warning("You feel weaker..."))
		REMOVE_TRAIT(user, TRAIT_FORCE_DOORS, VAMPIRE_TRAIT)
		user.move_resist = MOVE_FORCE_DEFAULT
		user.status_flags |= CANPUSH


/obj/effect/proc_holder/spell/vampire/self/blood_rush
	name = "Blood Rush"
	desc = "Infuse yourself with blood magic to boost your movement speed."
	gain_desc = "You have gained the ability to temporarily move at high speeds."
	base_cooldown = 30 SECONDS
	required_blood = 15
	action_icon_state = "blood_rush"


/obj/effect/proc_holder/spell/vampire/self/blood_rush/cast(list/targets, mob/user)
	var/mob/living/target = targets[1]
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		to_chat(H, span_notice("You feel a rush of energy!"))
		H.apply_status_effect(STATUS_EFFECT_BLOOD_RUSH)


/obj/effect/proc_holder/spell/fireball/demonic_grasp
	name = "Demonic Grasp"
	desc = "Fire a hand of demonic energy, snaring and throwing its target around, based on your intent. Disarm pushes, grab pulls."
	gain_desc = "You have gained the ability to snare and disrupt people with demonic apendages."
	base_cooldown = 15 SECONDS
	fireball_type = /obj/item/projectile/magic/demonic_grasp

	selection_activated_message		= span_notice("You raise your hand, full of demonic energy! <B>Left-click to cast at a target!</B>")
	selection_deactivated_message	= span_notice("You re-absorb the energy...for now.")

	action_icon_state = "demonic_grasp"

	panel = "Vampire"
	school = "vampire"
	action_background_icon_state = "bg_vampire"
	invocation_type = "none"
	invocation = null
	sound = 'sound/misc/exit_blood.ogg'
	need_active_overlay = TRUE


/obj/effect/proc_holder/spell/fireball/demonic_grasp/after_spell_init()
	update_vampire_spell_name()


/obj/effect/proc_holder/spell/fireball/demonic_grasp/update_icon()
	return


/obj/effect/proc_holder/spell/fireball/demonic_grasp/create_new_handler()
	var/datum/spell_handler/vampire/V = new()
	V.required_blood = 10
	return V


/obj/item/projectile/magic/demonic_grasp
	name = "demonic grasp"
	// parry this you filthy casual
	reflectability = REFLECTABILITY_NEVER
	icon_state = null


/obj/item/projectile/magic/demonic_grasp/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSprojectiles, src)


/obj/item/projectile/magic/demonic_grasp/Destroy()
	STOP_PROCESSING(SSprojectiles, src)
	return ..()


/obj/item/projectile/magic/demonic_grasp/process()
	new /obj/effect/temp_visual/demonic_grasp(loc)


/obj/item/projectile/magic/demonic_grasp/on_hit(atom/target, blocked, hit_zone)
	. = ..()
	if(!isliving(target))
		return

	playsound(get_turf(target), 'sound/misc/demon_attack1.ogg', 50, TRUE)
	var/mob/living/L = target
	L.Immobilize(3 SECONDS)
	new /obj/effect/temp_visual/demonic_grasp(loc)
	var/throw_target
	if(!firer)
		return

	if(!L.affects_vampire(firer))
		return

	switch(firer.a_intent)
		if(INTENT_DISARM)
			throw_target = get_edge_target_turf(L, get_dir(firer, L))
			L.throw_at(throw_target, 2, 5, spin = FALSE, callback = CALLBACK(src, PROC_REF(create_snare), L)) // shove away

		if(INTENT_GRAB)
			throw_target = get_step(firer, get_dir(firer, L))
			L.throw_at(throw_target, 2, 5, spin = FALSE, diagonals_first = TRUE, callback = CALLBACK(src, PROC_REF(create_snare), L)) // pull towards


/obj/item/projectile/magic/demonic_grasp/proc/create_snare(mob/target)
	new /obj/effect/temp_visual/demonic_snare(target.loc)


/obj/effect/temp_visual/demonic_grasp
	icon = 'icons/effects/vampire_effects.dmi'
	icon_state = "demonic_grasp"
	duration = 3.5 SECONDS


/obj/effect/temp_visual/demonic_snare
	icon = 'icons/effects/vampire_effects.dmi'
	icon_state = "immobilized"
	duration = 3 SECONDS


/obj/effect/proc_holder/spell/vampire/charge
	name = "Charge"
	desc = "You charge at wherever you click on screen, dealing large amounts of damage, stunning and destroying walls and other objects."
	gain_desc = "You can now charge at a target on screen, dealing massive damage and destroying structures."
	required_blood = 30
	base_cooldown = 30 SECONDS
	action_icon_state = "vampire_charge"
	need_active_overlay = TRUE


/obj/effect/proc_holder/spell/vampire/charge/create_new_targeting()
	return new /datum/spell_targeting/clicked_atom


/obj/effect/proc_holder/spell/vampire/charge/can_cast(mob/user, charge_check, show_message)
	var/mob/living/L = user
	if(L.lying || L.resting)
		return FALSE
	return ..()


/obj/effect/proc_holder/spell/vampire/charge/cast(list/targets, mob/user)
	var/target = targets[1]
	if(isliving(user))
		var/mob/living/L = user
		L.apply_status_effect(STATUS_EFFECT_CHARGING)
		L.throw_at(target, targeting.range, 1, L, FALSE, callback = CALLBACK(L, TYPE_PROC_REF(/mob/living, remove_status_effect), STATUS_EFFECT_CHARGING))

