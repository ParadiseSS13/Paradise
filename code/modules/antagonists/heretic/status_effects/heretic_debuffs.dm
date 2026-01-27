// MARK: AMOK
/datum/status_effect/amok
	id = "amok"
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	duration = 10 SECONDS

/datum/status_effect/amok/on_apply(mob/living/afflicted)
	to_chat(owner, SPAN_BOLDWARNING("You feel filled with a rage that is not your own!"))
	return TRUE

/datum/status_effect/amok/tick(seconds_between_ticks)
	var/last_intent = owner.a_intent
	owner.a_intent = INTENT_HARM

	// If we're holding a gun, expand the range a bit.
	// Otherwise, just look for adjacent targets
	var/search_radius = isgun(owner.get_active_hand()) ? 3 : 1

	var/list/mob/living/targets = list()
	for(var/mob/living/potential_target in oview(owner, search_radius))
		if(IS_HERETIC_OR_MONSTER(potential_target))
			continue
		targets += potential_target

	if(LAZYLEN(targets))
		var/poor_smuck = pick(targets)
		add_attack_logs(owner, poor_smuck, "attacked [poor_smuck] due to the amok debuff.", ATKLOG_FEW)
		owner.ClickOn(poor_smuck)
	owner.a_intent = last_intent

// MARK: Cloudstruck
/datum/status_effect/cloudstruck
	id = "cloudstruck"
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	duration = 3 SECONDS
	on_remove_on_mob_delete = TRUE
	///This overlay is applied to the owner for the duration of the effect.
	var/static/mutable_appearance/mob_overlay

/datum/status_effect/cloudstruck/on_creation(mob/living/new_owner, duration = 10 SECONDS)
	src.duration = duration
	if(!mob_overlay)
		mob_overlay = mutable_appearance('icons/effects/eldritch.dmi', "cloud_swirl", ABOVE_MOB_LAYER)
	return ..()

/datum/status_effect/cloudstruck/on_apply()
	owner.add_overlay(mob_overlay)
	owner.become_blind(id)
	return TRUE

/datum/status_effect/cloudstruck/on_remove()
	owner.cure_blind(id)
	owner.cut_overlay(mob_overlay)

// MARK: Starmark
/datum/status_effect/star_mark
	id = "star_mark"
	alert_type = /atom/movable/screen/alert/status_effect/star_mark
	duration = 30 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	///overlay used to indicate that someone is marked
	var/mutable_appearance/cosmic_overlay
	/// icon file for the overlay
	var/effect_icon = 'icons/effects/eldritch.dmi'
	/// icon state for the overlay
	var/effect_icon_state = "cosmic_ring"
	/// Storage for the spell caster
	var/spell_caster

/atom/movable/screen/alert/status_effect/star_mark
	name = "Star Mark"
	desc = "A ring above your head prevents you from entering cosmic fields or teleporting through cosmic runes..."
	icon_state = "star_mark"

/datum/status_effect/star_mark/on_creation(mob/living/new_owner, mob/living/new_spell_caster)
	if(new_spell_caster)
		spell_caster = new_spell_caster.UID()
	return ..()

/datum/status_effect/star_mark/Destroy()
	return ..()

/datum/status_effect/star_mark/on_apply()
	if(istype(owner, /mob/living/basic/heretic_summon/star_gazer))
		return FALSE
	var/mob/living/spell_caster_resolved = locateUID(spell_caster)
	var/datum/antagonist/mindslave/heretic_monster/monster = owner.mind?.has_antag_datum(/datum/antagonist/mindslave/heretic_monster)
	if(spell_caster_resolved && monster)
		if(monster.master?.current == spell_caster_resolved)
			return FALSE
	RegisterSignal(owner, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(update_owner_overlay))
	owner.update_appearance(UPDATE_OVERLAYS)
	return TRUE

/// Updates the overlay of the owner
/datum/status_effect/star_mark/proc/update_owner_overlay(atom/source, list/overlays)
	SIGNAL_HANDLER

	if(!cosmic_overlay)
		cosmic_overlay = mutable_appearance(effect_icon, effect_icon_state, BELOW_MOB_LAYER)
		source.add_overlay(cosmic_overlay)

/datum/status_effect/star_mark/on_remove()
	UnregisterSignal(owner, COMSIG_ATOM_UPDATE_OVERLAYS)
	owner.cut_overlay(cosmic_overlay)
	owner.update_appearance(UPDATE_OVERLAYS)
	QDEL_NULL(cosmic_overlay)
	return ..()

/datum/status_effect/star_mark/extended
	duration = 3 MINUTES

// MARK: Last Resort
/datum/status_effect/heretic_lastresort
	id = "heretic_lastresort"
	alert_type = /atom/movable/screen/alert/status_effect/heretic_lastresort
	duration = 12 SECONDS
	status_type = STATUS_EFFECT_REPLACE
	tick_interval = 0

/atom/movable/screen/alert/status_effect/heretic_lastresort
	name = "Last Resort"
	desc = "Your head spins, heart pumping as fast as it can, losing the fight with the ground. Run to safety!"
	icon_state = "lastresort"

/datum/status_effect/heretic_lastresort/on_apply()
	ADD_TRAIT(owner, TRAIT_IGNORESLOWDOWN, id)
	to_chat(owner, SPAN_USERDANGER("You are on the brink of losing consciousness, run!"))
	return TRUE

/datum/status_effect/heretic_lastresort/on_remove()
	REMOVE_TRAIT(owner, TRAIT_IGNORESLOWDOWN, id)
	owner.Paralyse(20 SECONDS, TRUE) //Stun immunity will not save you, pay the price of magic


// MARK: Moon Conversion
/// Used by moon heretics to make people mad
/datum/status_effect/moon_converted
	id = "moon converted"
	alert_type = /atom/movable/screen/alert/status_effect/moon_converted
	status_type = STATUS_EFFECT_REPLACE
	///used to track damage
	var/damage_sustained = 0
	///overlay used to indicate that someone is marked
	var/mutable_appearance/moon_insanity_overlay
	/// icon file for the overlay
	var/effect_icon = 'icons/effects/eldritch.dmi'
	/// icon state for the overlay
	var/effect_icon_state = "moon_insanity_overlay"

/datum/status_effect/moon_converted/on_creation()
	moon_insanity_overlay = mutable_appearance(effect_icon, effect_icon_state, ABOVE_MOB_LAYER)
	owner.update_appearance(UPDATE_OVERLAYS)
	. = ..()

/datum/status_effect/moon_converted/Destroy()
	to_chat(owner, chat_box_notice(SPAN_DANGER("You have been freed from the Moon's influence and regain your senses.")))
	return ..()

/datum/status_effect/moon_converted/on_apply()
	RegisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_damaged))
	// Heals them so people who are in crit can have this affect applied on them and still be of some use for the heretic
	owner.adjustBruteLoss(-100)
	owner.adjustFireLoss(-100)

	var/list/messages = list()
	messages.Add(SPAN_USERDANGER("THE MOON SHOWS YOU THE TRUTH AND THE LIARS WISH TO COVER IT, SLAY THEM ALL!!!"))
	messages.Add(SPAN_WARNING("Attack everyone you can see (besides your enlightener) without discrimination!"))
	to_chat(owner, chat_box_red(messages.Join("<br>")))

	owner.Paralyse(5 SECONDS)
	ADD_TRAIT(owner, TRAIT_MUTE, src.UID())
	owner.add_overlay(moon_insanity_overlay)
	owner.update_appearance(UPDATE_OVERLAYS)
	return TRUE

/datum/status_effect/moon_converted/proc/on_damaged(datum/source, damage, damagetype)
	SIGNAL_HANDLER

	// Stamina damage is funky so we will ignore it
	if(damagetype == STAMINA)
		return

	damage_sustained += damage

	if(damage_sustained < 60)
		return

	qdel(src)

/datum/status_effect/moon_converted/on_remove()
	// Span warning to help realize they aren't evil anymore
	REMOVE_TRAIT(owner, TRAIT_MUTE, src.UID())
	UnregisterSignal(owner, COMSIG_ATOM_UPDATE_OVERLAYS)
	UnregisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_damaged))
	owner.cut_overlay(moon_insanity_overlay)
	owner.update_icon()
	QDEL_NULL(moon_insanity_overlay)
	return ..()


/atom/movable/screen/alert/status_effect/moon_converted
	name = "Moon Converted"
	desc = "They LIE, SLAY ALL OF THE THEM!!! THE LIARS OF THE SUN MUST FALL!!!"
	icon_state = "moon_insanity"

/mob/living/proc/apply_necropolis_curse(set_curse)
	var/datum/status_effect/necropolis_curse/C = has_status_effect(/datum/status_effect/necropolis_curse)
	if(QDELETED(C))
		apply_status_effect(/datum/status_effect/necropolis_curse, set_curse)
	else
		C.duration += 3000 //time added by additional curses
	return C

// MARK: Necropolis curse
/datum/status_effect/necropolis_curse
	id = "necrocurse"
	duration = 10 MINUTES //you're cursed for 10 minutes have fun
	tick_interval = 5 SECONDS
	alert_type = null
	var/curse_flags = NONE
	var/effect_last_activation = 0
	var/effect_cooldown = 100
	var/obj/effect/temp_visual/curse/wasting_effect = new

/datum/status_effect/necropolis_curse/on_creation(mob/living/new_owner, set_curse)
	. = ..()
	owner.overlay_fullscreen("curse", /atom/movable/screen/fullscreen/stretch/curse, 1)


/datum/status_effect/necropolis_curse/on_remove()
	owner.clear_fullscreen("curse", 50)

/datum/status_effect/necropolis_curse/tick(seconds_between_ticks)
	if(owner.stat == DEAD)
		return
	if(effect_last_activation <= world.time)
		effect_last_activation = world.time + effect_cooldown
		var/grab_dir = turn(owner.dir, pick(-90, 90, 180, 180)) //grab them from a random direction other than the one faced, favoring grabbing from behind
		var/turf/spawn_turf = get_ranged_target_turf(owner, grab_dir, 5)
		if(spawn_turf)
			grasp(spawn_turf)

/datum/status_effect/necropolis_curse/proc/grasp(turf/spawn_turf)
	set waitfor = FALSE
	new/obj/effect/temp_visual/dir_setting/curse/grasp_portal(spawn_turf, owner.dir)
	playsound(spawn_turf, 'sound/effects/curse/curse2.ogg', 80, TRUE, -1)
	var/obj/projectile/curse_hand/C = new (spawn_turf)
	C.preparePixelProjectile(owner, spawn_turf)
	if(QDELETED(C)) // safety check if above fails - above has a stack trace if it does fail
		return
	C.fire()

/obj/effect/temp_visual/curse
	icon_state = "curse"

/obj/effect/temp_visual/curse/Initialize(mapload)
	. = ..()
	deltimer(timerid)

// MARK: Broken Blade
/datum/status_effect/broken_blade
	id = "broken_blade"
	duration = 150 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/broken_blade
	status_type = STATUS_EFFECT_REPLACE
	show_duration = TRUE

/datum/status_effect/broken_blade/on_creation(mob/living/new_owner, new_icon_state)
	. = ..()
	linked_alert.icon_state = new_icon_state

/atom/movable/screen/alert/status_effect/broken_blade
	name = "Broken Blade"
	desc = "You have broken one of the blades of the Mansus. They will not loan you another for a while."
	icon = 'icons/obj/weapons/khopesh.dmi'
	icon_state = "eldritch_blade"

// MARK: Insanity
/datum/status_effect/stacking/heretic_insanity
	id = "insanity"
	on_remove_on_mob_delete = TRUE
	status_type = STATUS_EFFECT_REFRESH
	tick_interval = 25 SECONDS
	consumed_on_threshold = FALSE
	stack_threshold = 21 // no threshold
	max_stacks = 20
	alert_type = /atom/movable/screen/alert/status_effect/insanity

/datum/status_effect/stacking/heretic_insanity/on_creation(mob/living/new_owner, stacks_to_apply = 1)
	. = ..()
	RegisterSignal(owner, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(update_stacks_overlay))
	add_stacks(stacks_to_apply)

/datum/status_effect/stacking/heretic_insanity/Destroy()
	animate_fade_colored(owner, 2 SECONDS)
	. = ..()

/datum/status_effect/stacking/heretic_insanity/refresh()
	. = ..()
	add_stacks(1)
	owner.update_icon(UPDATE_OVERLAYS)

/datum/status_effect/stacking/heretic_insanity/process()
	update_shown_stacks()
	update_greyscale()
	owner.update_icon(UPDATE_OVERLAYS)
	return ..()

/datum/status_effect/stacking/heretic_insanity/proc/update_greyscale()
	var/stack_intensity = 1 - (0.66 * (stacks / max_stacks))
	var/inverse_intensity = 0.33 * (stacks / max_stacks)
	var/custom_greyscale = list(stack_intensity, inverse_intensity, inverse_intensity,\
								inverse_intensity, stack_intensity, inverse_intensity,\
								inverse_intensity, inverse_intensity, stack_intensity)
	animate(owner, color = custom_greyscale, time = 2 SECONDS, easing = SINE_EASING, flags = ANIMATION_PARALLEL)

/datum/status_effect/stacking/heretic_insanity/proc/update_stacks_overlay(atom/parent_atom, list/overlays)
	SIGNAL_HANDLER

	linked_alert?.update_appearance(UPDATE_ICON_STATE|UPDATE_DESC)

/datum/status_effect/stacking/heretic_insanity/proc/update_shown_stacks()
	if(!linked_alert)
		return

	linked_alert.maptext = MAPTEXT_TINY_UNICODE("<span style='text-align:right; font-size: 8pt'>[stacks]</span>")

//---- Screen alert
/atom/movable/screen/alert/status_effect/insanity
	name = "Moon's Light"
	desc = "The light is so bright, it dulls your senses and eats at your mind."
	icon_state = "insanity_minor"

/atom/movable/screen/alert/status_effect/insanity/update_icon_state()
	. = ..()
	if(!istype(attached_effect, /datum/status_effect/stacking/heretic_insanity))
		return
	var/datum/status_effect/stacking/heretic_insanity/insanity_effect = attached_effect
	if(insanity_effect.stacks < 6)
		icon_state = initial(icon_state)
	if(insanity_effect.stacks >= 6)
		icon_state = "insanity_moderate"
	if(insanity_effect.stacks >= 14)
		icon_state = "insanity_full"

/atom/movable/screen/alert/status_effect/insanity/update_desc(updates)
	. = ..()
	if(!istype(attached_effect, /datum/status_effect/stacking/heretic_insanity))
		return
	var/datum/status_effect/stacking/heretic_insanity/insanity_effect = attached_effect
	if(insanity_effect.stacks < 6)
		desc = initial(desc)
	if(insanity_effect.stacks >= 6)
		desc = "The light is blindingly white! \
			The moon calls for the true nature of your soul!"
	if(insanity_effect.stacks >= 14)
		desc = "Light LEAKS through the CRACKS. \
			My mind is BRIGHTER than it EVER was. \
			THE HIGHER I RISE THE MORE I SEE."
