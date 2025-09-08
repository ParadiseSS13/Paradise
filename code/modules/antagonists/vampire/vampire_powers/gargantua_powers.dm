/datum/spell/vampire/self/blood_swell
	name = "Blood Swell (30)"
	desc = "You infuse your body with blood, making you highly resistant to stuns and physical damage. However, this makes you unable to fire ranged weapons while it is active."
	gain_desc = "You have gained the ability to temporarily resist large amounts of stuns and physical damage."
	base_cooldown = 40 SECONDS
	required_blood = 30
	action_icon_state = "blood_swell"

/datum/spell/vampire/self/blood_swell/cast(list/targets, mob/user)
	var/mob/living/target = targets[1]
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.apply_status_effect(STATUS_EFFECT_BLOOD_SWELL)

/datum/spell/vampire/self/stomp
	name = "Seismic Stomp (30)"
	desc = "You slam your foot into the ground sending a powerful shockwave through the station's hull, sending people flying away. Cannot be cast if your legs are restrained by a bola or similar."
	gain_desc = "You have gained the ability to knock people back using a powerful stomp."
	action_icon_state = "seismic_stomp"
	base_cooldown = 60 SECONDS
	required_blood = 30
	var/max_range = 4

/datum/spell/vampire/self/stomp/can_cast(mob/living/carbon/user, charge_check, show_message)
	if(user.legcuffed)
		return FALSE
	return ..()

/datum/spell/vampire/self/stomp/cast(list/targets, mob/user)
	var/turf/T = get_turf(user)
	playsound(T, 'sound/effects/meteorimpact.ogg', 100, TRUE)
	addtimer(CALLBACK(src, PROC_REF(hit_check), 1, T, user), 0.2 SECONDS)
	new /obj/effect/temp_visual/stomp(T)

/datum/spell/vampire/self/stomp/proc/hit_check(range, turf/start_turf, mob/user, safe_targets = list())
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
		L.KnockDown(1 SECONDS)
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

/datum/vampire_passive/blood_swell_upgrade
	gain_desc = "While blood swell is active, all of your melee attacks deal increased damage."

/datum/spell/vampire/self/overwhelming_force
	name = "Overwhelming Force"
	desc = "When toggled you will automatically pry open doors that you bump into if you do not have access."
	gain_desc = "You have gained the ability to force open doors at a small blood cost."
	base_cooldown = 2 SECONDS
	action_icon_state = "OH_YEAAAAH"

/datum/spell/vampire/self/overwhelming_force/cast(list/targets, mob/user)
	if(!HAS_TRAIT_FROM(user, TRAIT_FORCE_DOORS, VAMPIRE_TRAIT))
		to_chat(user, "<span class='warning'>You feel MIGHTY!</span>")
		ADD_TRAIT(user, TRAIT_FORCE_DOORS, VAMPIRE_TRAIT)
		user.status_flags &= ~CANPUSH
		user.move_resist = MOVE_FORCE_STRONG
	else
		REMOVE_TRAIT(user, TRAIT_FORCE_DOORS, VAMPIRE_TRAIT)
		user.move_resist = MOVE_FORCE_DEFAULT
		user.status_flags |= CANPUSH

/datum/spell/vampire/self/blood_rush
	name = "Blood Rush (30)"
	desc = "Infuse yourself with blood magic to boost your movement speed and break out of leg restraints."
	gain_desc = "You have gained the ability to temporarily move at high speeds."
	base_cooldown = 30 SECONDS
	required_blood = 30
	action_icon_state = "blood_rush"

/datum/spell/vampire/self/blood_rush/can_cast(mob/user, charge_check, show_message)
	var/mob/living/L = user
	// they're not getting anything out of this spell if they're stunned or buckled anyways, so we might as well stop them from wasting the blood
	if(L.IsWeakened() || L.buckled)
		to_chat(L, "<span class='warning'>You can't cast this spell while incapacitated!</span>")
		return FALSE
	return ..()

/datum/spell/vampire/self/blood_rush/cast(list/targets, mob/user)
	var/mob/living/target = targets[1]
	if(!ishuman(target))
		return

	var/mob/living/carbon/human/H = target
	to_chat(H, "<span class='notice'>You feel a rush of energy!</span>")

	H.apply_status_effect(STATUS_EFFECT_BLOOD_RUSH)
	H.clear_legcuffs(TRUE)
	// note that this doesn't cancel the baton knockdown timer
	H.SetKnockDown(0)
	H.stand_up(TRUE)

/datum/spell/fireball/demonic_grasp
	name = "Demonic Grasp (20)"
	desc = "Summon a hand of demonic energy, snaring and throwing its target around, based on your intent. Disarm pushes, grab pulls."
	gain_desc = "You have gained the ability to snare and disrupt people with demonic appendages."
	base_cooldown = 30 SECONDS
	fireball_type = /obj/item/projectile/magic/demonic_grasp

	selection_activated_message		= "<span class='notice'>You raise your hand, full of demonic energy! <B>Left-click to cast at a target!</B></span>"
	selection_deactivated_message	= "<span class='notice'>You re-absorb the energy...for now.</span>"

	action_icon_state = "demonic_grasp"

	action_background_icon_state = "bg_vampire"
	sound = null
	invocation_type = "none"
	invocation = null

/datum/spell/fireball/demonic_grasp/update_spell_icon()
	return

/datum/spell/fireball/demonic_grasp/create_new_handler()
	var/datum/spell_handler/vampire/V = new()
	V.required_blood = 20
	return V

/obj/item/projectile/magic/demonic_grasp
	name = "demonic grasp"
	// parry this you filthy casual
	reflectability = REFLECTABILITY_NEVER
	icon_state = null

/obj/item/projectile/magic/demonic_grasp/pixel_move(trajectory_multiplier)
	. = ..()
	new /obj/effect/temp_visual/demonic_grasp(loc)

/obj/item/projectile/magic/demonic_grasp/on_hit(atom/target, blocked, hit_zone)
	. = ..()
	if(!.)
		return
	if(!isliving(target))
		return
	var/mob/living/L = target
	L.Immobilize(1 SECONDS)
	var/throw_target
	if(!firer)
		return

	if(!L.affects_vampire(firer))
		return

	new /obj/effect/temp_visual/demonic_grasp(loc)

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

/datum/spell/vampire/charge
	name = "Charge (30)"
	desc = "You charge at wherever you click on screen, dealing large amounts of damage, stunning targets, and destroying walls and other objects."
	gain_desc = "You can now charge at a target on screen, dealing massive damage and destroying structures."
	required_blood = 30
	base_cooldown = 30 SECONDS
	action_icon_state = "vampire_charge"

/datum/spell/vampire/charge/create_new_targeting()
	return new /datum/spell_targeting/clicked_atom

/datum/spell/vampire/charge/can_cast(mob/user, charge_check, show_message)
	var/mob/living/L = user
	if(IS_HORIZONTAL(L))
		return FALSE
	return ..()

/datum/spell/vampire/charge/cast(list/targets, mob/user)
	var/target = targets[1]
	if(isliving(user))
		var/mob/living/L = user
		L.apply_status_effect(STATUS_EFFECT_CHARGING)
		L.throw_at(target, targeting.range, 1, L, FALSE, callback = CALLBACK(L, TYPE_PROC_REF(/mob/living, remove_status_effect), STATUS_EFFECT_CHARGING))

#define ARENA_SIZE 3

/datum/spell/vampire/arena
	name = "Desecrated Duel (150)"
	desc = "You leap towards someone. Upon landing, you conjure an arena, and within it you will heal brute and burn damage, recover from fatigue faster, and be strengthened against lasting damages. Can be recasted to end the spell early."
	gain_desc = "You can now leap to a target and trap them in a conjured arena."
	required_blood = 150
	base_cooldown = 30 SECONDS
	action_icon_state = "duel"
	should_recharge_after_cast = FALSE
	var/spell_active = FALSE
	/// Holds a reference to the timer until either the spell runs out or we recast it
	var/timer
	/// Holds a reference to all arena walls so we can qdel them easily with dispel()
	var/list/all_temp_walls = list()

/datum/spell/vampire/arena/create_new_targeting()
	var/datum/spell_targeting/click/T = new
	T.click_radius = 0
	T.allowed_type = /mob/living/carbon/human
	return T

/datum/spell/vampire/arena/cast(list/targets, mob/living/user)
	var/target = targets[1] // We only want to dash towards the first mob in our targeting list, if somehow multiple ended up in there
	if(!targets)
		return

	if(timer) // Recast to dispel the wall and buff early
		dispel(user)
		return

	// First we leap towards the enemy target
	user.add_stun_absorption("gargantua", INFINITY, 2) // We temporarily make the gargantua immune to stuns to stop any matrix fuckery from happening
	animate(user, 1 SECONDS, pixel_z = 64, flags = ANIMATION_RELATIVE, easing = SINE_EASING|EASE_OUT)
	addtimer(CALLBACK(user, user.spin(12, 1), 3, 2), 0.3 SECONDS)
	var/angle = get_angle(user, target) + 180
	user.transform = user.transform.Turn(angle)
	for(var/i in 1 to 10)
		var/move_dir = get_dir(user, target)
		user.forceMove(get_step(user, move_dir))
		if(get_turf(user) == get_turf(target))
			user.remove_stun_absorption("gargantua")
			user.set_body_position(STANDING_UP)
			user.transform = matrix()
			break
		sleep(1)
	animate(user, 0.2 SECONDS, pixel_z = -64, flags = ANIMATION_RELATIVE, easing = SINE_EASING|EASE_IN)
	// They get a cool soundeffect and a visual, as a treat

	playsound(get_turf(user), 'sound/effects/meteorimpact.ogg', 100, TRUE)
	new /obj/effect/temp_visual/stomp(get_turf(user))

	// Now we build the arena and give the caster the buff

	user.apply_status_effect(STATUS_EFFECT_VAMPIRE_GLADIATOR)
	spell_active = TRUE
	timer = addtimer(CALLBACK(src, PROC_REF(dispel), user, TRUE), 30 SECONDS, TIMER_STOPPABLE)
	INVOKE_ASYNC(src, PROC_REF(arena_trap), get_turf(target))  //Gets another arena trap queued up for when this one runs out.
	RegisterSignal(user, COMSIG_PARENT_QDELETING, PROC_REF(dispel))
	arena_checks(get_turf(target), user)

/datum/spell/vampire/arena/proc/arena_checks(turf/target_turf, mob/living/user)
	if(!spell_active || QDELETED(src))
		return
	INVOKE_ASYNC(src, PROC_REF(fighters_check), user)  //Checks to see if our fighters died.
	addtimer(CALLBACK(src, PROC_REF(arena_checks), target_turf, user), 5 SECONDS)

/datum/spell/vampire/arena/proc/arena_trap(turf/target_turf)
	for(var/tumor_range_turfs in circle_edge_turfs(target_turf, ARENA_SIZE))
		tumor_range_turfs = new /obj/effect/temp_visual/elite_tumor_wall/gargantua(tumor_range_turfs, src)
		all_temp_walls += tumor_range_turfs

/datum/spell/vampire/arena/proc/fighters_check(mob/living/user)
	if(QDELETED(user) || user.stat == DEAD)
		dispel(user)
		return

/datum/spell/vampire/arena/proc/dispel(mob/living/user)
	spell_active = FALSE
	if(timer)
		deltimer(timer)
		timer = null
	QDEL_LIST_CONTENTS(all_temp_walls)
	cooldown_handler.start_recharge()
	user.remove_status_effect(STATUS_EFFECT_VAMPIRE_GLADIATOR)
	user.visible_message("<span class='warning'>The arena begins to dissipate.</span>")

#undef ARENA_SIZE
