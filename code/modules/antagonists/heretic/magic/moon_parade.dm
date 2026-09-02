/datum/spell/fireball/moon_parade
	name = "Lunar parade"
	desc = "This unleashes the parade, making everyone in its way join it and suffer hallucinations."


	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon_state = "moon_parade"
	what_icon_state = "moon_parade"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	ranged_mousepointer = 'icons/effects/mouse_pointers/moon_target.dmi'

	sound = 'sound/magic/cosmic_energy.ogg'
	is_a_heretic_spell = TRUE
	base_cooldown = 30 SECONDS

	invocation = "L'N'R P'RAD"

	selection_activated_message = "You prepare to make them join the parade!"
	selection_deactivated_message = "You stop the music and halt the parade... for now."
	fireball_type = /obj/projectile/moon_parade


/obj/projectile/moon_parade
	name = "Lunar parade"
	icon_state = "lunar_parade"
	damage = 0
	damage_type = BURN
	speed = 5
	range = 75
	ricochets_max = 40
	ricochet_chance = 500
	ricochet_incidence_leeway = 0
	always_nonmob_ricochet = TRUE
	forcedodge = -1 //Only mobs, not walls or structures
	force_no_hit_message_or_sound = TRUE
	///looping sound datum for our projectile.
	var/datum/looping_sound/moon_parade/soundloop
	// A list of the people we hit
	var/list/mobs_hit = list()
	/// Have we been disabled by hitting an antimagic person
	var/disabled = FALSE

/obj/projectile/moon_parade/Initialize(mapload)
	. = ..()
	soundloop = new(list(src), TRUE)
	addtimer(CALLBACK(src, GLOBAL_PROC_REF(qdel), src), 12 SECONDS)


/obj/projectile/moon_parade/prehit(atom/target)
	if(!isliving(firer) || !isliving(target))
		return ..()
	var/mob/living/caster = firer
	var/mob/living/victim = target

	if(caster == victim)
		return

	if(!caster.mind)
		return

	var/datum/antagonist/mindslave/heretic_monster/monster = victim.mind?.has_antag_datum(/datum/antagonist/mindslave/heretic_monster)
	if(monster?.master == caster.mind)
		return

	// Anti-magic destroys the projectile for consistency and counterplay
	if(victim.can_block_magic(MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND))
		visible_message(SPAN_WARNING("The parade hits [victim] and a sudden wave of clarity comes over you!"))
		disabled = TRUE
		qdel(src)
		return

	return ..()

/obj/projectile/moon_parade/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(!isliving(target))
		qdel(src)
		return
	if(disabled)
		return

	var/mob/living/victim = target
	var/mob/living/caster = firer
	if(caster)
		if(caster == victim)
			return

		if(!caster.mind)
			return

		var/datum/antagonist/mindslave/heretic_monster/monster = victim.mind?.has_antag_datum(/datum/antagonist/mindslave/heretic_monster)
		if(monster?.master == caster.mind)
			return
	if(!(victim in mobs_hit))
		RegisterSignal(victim, COMSIG_PARENT_QDELETING, PROC_REF(clear_mob))
		victim.AddComponent(/datum/component/leash, src, distance = 1)
		to_chat(victim, SPAN_WARNING("You feel unable to move away from the parade!"))
		mobs_hit += victim
		new /obj/effect/hallucination/delusion(get_turf(victim), victim, 'icons/effects/eldritch.dmi', "heretic")
		victim.apply_status_effect(/datum/status_effect/stacking/heretic_insanity)
		log_override = TRUE

/obj/projectile/moon_parade/Destroy()
	for(var/mob/living/leftover_mob as anything in mobs_hit)
		clear_mob(leftover_mob)
	mobs_hit.Cut() // You never know
	soundloop.stop()
	return ..()


/obj/projectile/moon_parade/proc/clear_mob(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_PARENT_QDELETING)
	mobs_hit -= source

