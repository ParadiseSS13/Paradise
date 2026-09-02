/datum/spell/fireball/furious_steel
	name = "Furious Steel"
	desc = "Summon three silver blades which orbit you. \
		While orbiting you, these blades will protect you from from attacks, but will be consumed on use. \
		Additionally, you can click to fire the blades at a target, dealing damage and causing bleeding."


	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon_state = "furious_steel"
	what_icon_state = "furious_steel"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	sound = 'sound/weapons/guillotine.ogg'

	is_a_heretic_spell = TRUE
	base_cooldown = 60 SECONDS
	invocation = "F'LSH'NG S'LV'R!"

	selection_activated_message = "You summon forth three blades of furious silver."
	selection_deactivated_message = "You conceal the blades of furious silver."
	fireball_type = /obj/projectile/magic/floating_blade
	projectile_amount = 3
	cares_about_turf = FALSE

	///Effect of the projectile that surrounds us while the spell is active
	var/projectile_effect = /obj/effect/floating_blade
	/// A ref to the status effect surrounding our heretic on activation.
	var/datum/status_effect/protective_blades/blade_effect

/datum/spell/fireball/furious_steel/InterceptClickOn(mob/user, params, atom/A)
	// Let the caster prioritize using items like guns over blade casts
	if(user.get_active_hand())
		return FALSE
	// Let the caster prioritize melee attacks like punches and shoves over blade casts
	if(get_dist(user, A) <= 1)
		return FALSE

	return ..()

/datum/spell/fireball/furious_steel/add_ranged_ability(mob/user, msg)
	. = ..()

	if(!isliving(user))
		return
	// Delete existing
	if(blade_effect)
		stack_trace("[type] had an existing blade effect in on_activation. This might be an exploit, and should be investigated.")
		UnregisterSignal(blade_effect, COMSIG_PARENT_QDELETING)
		QDEL_NULL(blade_effect)

	var/mob/living/living_user = user
	blade_effect = living_user.apply_status_effect(/datum/status_effect/protective_blades, null, projectile_amount, 25, 0.66 SECONDS, projectile_effect)
	RegisterSignal(blade_effect, COMSIG_PARENT_QDELETING, PROC_REF(on_status_effect_deleted))

/datum/spell/fireball/furious_steel/remove_ranged_ability(mob/user, msg)
	. = ..()
	if(isnull(blade_effect))
		cooldown_handler.start_recharge()
	else if(length(blade_effect.blades) != projectile_amount)
		cooldown_handler.start_recharge() //No free magic
	current_amount = 0
	QDEL_NULL(blade_effect)

/datum/spell/fireball/furious_steel/cast(list/targets, mob/living/user)
	if(isnull(blade_effect) || !length(blade_effect.blades))
		current_amount = 0
		cooldown_handler.start_recharge()
		return FALSE
	. = ..()
	if(!isnull(blade_effect) && length(blade_effect.blades))
		qdel(blade_effect.blades[1])


/datum/spell/fireball/furious_steel/proc/on_status_effect_deleted(datum/status_effect/protective_blades/source)
	SIGNAL_HANDLER

	blade_effect = null
	remove_ranged_ability(action.owner) //there has to be a better way to get this


/obj/projectile/magic/floating_blade
	name = "blade"
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "dio_knife"
	speed = 2
	damage = 25
	damage_type = BRUTE
	nodamage = FALSE
	/// Color applied as an outline filter on init
	var/outline_color = "#f8f8ff"

/obj/projectile/magic/floating_blade/Initialize(mapload)
	. = ..()
	add_filter("dio_knife", 2, list("type" = "outline", "color" = outline_color, "size" = 1))

/obj/projectile/magic/floating_blade/prehit(atom/target)
	if(isliving(target) && isliving(firer))
		var/mob/living/caster = firer
		var/mob/living/victim = target
		if(caster == victim)
			damage = 0
			nodamage = TRUE
			return FALSE

		if(caster.mind)
			var/datum/antagonist/mindslave/heretic_monster/monster = victim.mind?.has_antag_datum(/datum/antagonist/mindslave/heretic_monster)
			if(monster?.master == caster.mind)
				visible_message(SPAN_WARNING("[src] fizzles on contact with [victim]!"))
				damage = 0
				nodamage = TRUE
				return FALSE

	return ..()


/obj/projectile/magic/floating_blade/on_hit(atom/target, blocked, hit_zone)
	if(isliving(target) && isliving(firer))
		var/mob/living/caster = firer
		var/mob/living/victim = target
		if(caster == victim)
			return FALSE

		if(caster.mind)
			var/datum/antagonist/mindslave/heretic_monster/monster = victim.mind?.has_antag_datum(/datum/antagonist/mindslave/heretic_monster)
			if(monster?.master == caster.mind)
				visible_message(SPAN_WARNING("[src] fizzles on contact with [victim]!"))
				return FALSE

	return ..()

/obj/projectile/magic/floating_blade/haunted
	name = "ritual blade"
	icon = 'icons/obj/weapons/khopesh.dmi'
	icon_state = "render"
	damage = 35
	outline_color = "#D7CBCA"

/datum/spell/fireball/furious_steel/solo
	name = "Lesser Furious Steel"
	base_cooldown = 20 SECONDS
	projectile_amount = 1
	selection_activated_message = "You summon forth a blade of furious silver."
	selection_deactivated_message = "You conceal the blade of furious silver."

/datum/spell/fireball/furious_steel/haunted
	name = "Cursed Steel"
	desc = "Summon two cursed blades which orbit you. \
		While orbiting you, these blades will protect you from attacks, but will be consumed on use. \
		Additionally, you can click to fire the blades at a target, dealing damage and causing bleeding."
	action_icon_state = "cursed_steel"
	what_icon_state = "cursed_steel"

	base_cooldown = 40 SECONDS
	invocation = "IA!"

	selection_activated_message = "You summon forth two cursed blades."
	selection_deactivated_message = "You conceal the cursed blades."
	projectile_amount = 2
	fireball_type = /obj/projectile/magic/floating_blade/haunted
	projectile_effect = /obj/effect/floating_blade/haunted
