/datum/spell/shadow_cloak
	name = "Cloak of Shadow"
	desc = "Completely conceals your identity, but does not make you invisible.  Can be activated early to disable it. \
		While cloaked, you move faster, but undergo actions much slower. \
		Taking damage while cloaked may cause it to lift suddenly, causing negative effects. "

	action_background_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_background_icon_state = "bg_heretic"
	action_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	action_icon_state = "ninja_cloak"
	sound = 'sound/effects/curse/curse2.ogg'

	is_a_heretic_spell = TRUE
	clothes_req = FALSE
	base_cooldown = 12 SECONDS

	/// How long before we automatically uncloak?
	var/uncloak_time = 3 MINUTES
	/// The cloak currently active
	var/datum/status_effect/shadow_cloak/active_cloak
	COOLDOWN_DECLARE(uncloak_timer)


/datum/spell/shadow_cloak/before_cast(mob/living/cast_on)
	. = ..()
	sound = pick(
		'sound/effects/curse/curse1.ogg',
		'sound/effects/curse/curse2.ogg',
		'sound/effects/curse/curse3.ogg',
		'sound/effects/curse/curse4.ogg',
		'sound/effects/curse/curse5.ogg',
		'sound/effects/curse/curse6.ogg',
	)

/datum/spell/shadow_cloak/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/shadow_cloak/cast(list/targets, mob/user)
	. = ..()
	if(active_cloak)
		uncloak_mob(user)
		cooldown_handler.start_recharge(base_cooldown)

	else
		COOLDOWN_START(src,uncloak_timer, 3 MINUTES)
		cloak_mob(user)
		cooldown_handler.start_recharge(1 SECONDS)

/datum/spell/shadow_cloak/proc/cloak_mob(mob/living/cast_on)
	playsound(cast_on, 'sound/effects/ahaha.ogg', 50, TRUE, -1, extrarange = SILENCED_SOUND_EXTRARANGE, frequency = 0.5)
	cast_on.visible_message(
		SPAN_WARNING("[cast_on] disappears into the shadows!"),
		SPAN_NOTICE("You disappear into the shadows, becoming unidentifiable."),
	)

	active_cloak = cast_on.apply_status_effect(/datum/status_effect/shadow_cloak)
	RegisterSignal(active_cloak, COMSIG_PARENT_QDELETING, PROC_REF(on_early_cloak_loss))
	RegisterSignal(cast_on, SIGNAL_REMOVETRAIT(TRAIT_ALLOW_HERETIC_CASTING), PROC_REF(on_focus_lost))

/datum/spell/shadow_cloak/proc/uncloak_mob(mob/living/cast_on, show_message = TRUE)
	if(!QDELETED(active_cloak))
		UnregisterSignal(active_cloak, COMSIG_PARENT_QDELETING)
		qdel(active_cloak)
	active_cloak = null

	UnregisterSignal(cast_on, SIGNAL_REMOVETRAIT(TRAIT_ALLOW_HERETIC_CASTING))
	playsound(cast_on, 'sound/effects/curse/curseattack.ogg', 50)
	if(show_message)
		cast_on.visible_message(
			SPAN_WARNING("[cast_on] appears from the shadows!"),
			SPAN_NOTICE("You appear from the shadows, identifiable once more."),
		)
	COOLDOWN_START(src, uncloak_timer, 5 SECONDS)


/// Signal proc for [COMSIG_PARENT_QDELETING], if our cloak is deleted early, impart negative effects
/datum/spell/shadow_cloak/proc/on_early_cloak_loss(datum/status_effect/source)
	SIGNAL_HANDLER

	var/mob/living/removed = source.owner
	uncloak_mob(removed, show_message = FALSE)
	removed.visible_message(
		SPAN_WARNING("[removed] is pulled from the shadows!"),
		SPAN_USERDANGER("You are pulled out of the shadows!"),
	)

	removed.KnockDown(0.5 SECONDS)
	removed.Slowed(2 MINUTES, 0.5) // jesus
	cooldown_handler.start_recharge(uncloak_time * 2/3)

/// Signal proc for [SIGNAL_REMOVETRAIT] via [TRAIT_ALLOW_HERETIC_CASTING], losing our focus midcast will throw us out.
/datum/spell/shadow_cloak/proc/on_focus_lost(mob/living/source)
	SIGNAL_HANDLER

	uncloak_mob(source, show_message = FALSE)
	source.visible_message(
		SPAN_WARNING("[source] suddenly appears from the shadows!"),
		SPAN_USERDANGER("As you lose your focus, you are pulled out of the shadows!"),
	)
	cooldown_handler.start_recharge(uncloak_time / 3)

/// Shadow cloak effect. Conceals the owner in a cloud of purple smoke, making them unidentifiable.
/// Also comes with some other buffs and debuffs - faster movespeed, slower actionspeed, etc.
/datum/status_effect/shadow_cloak
	id = "shadow_cloak"
	alert_type = null
	tick_interval = 0
	/// How much damage we've been hit with
	var/damage_sustained = 0
	/// How much damage we can be hit with before it starts rolling reveal chances
	var/damage_before_reveal = 25
	/// Method to track plant overlay on mob for later removal
	var/mutable_appearance/cloak_image

/datum/status_effect/shadow_cloak/on_apply()
	hide_user(owner)
	// Add the relevant traits and modifiers
	ADD_TRAIT(owner, TRAIT_GOTTAGONOTSOFAST, id)
	ADD_TRAIT(owner, TRAIT_UNKNOWN, id)
	ADD_TRAIT(owner, TRAIT_SILENT_FOOTSTEPS, id)
	// Register signals to cause effects
	RegisterSignal(owner, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_dir_change))
	RegisterSignal(owner, COMSIG_MOB_STATCHANGE, PROC_REF(on_stat_change))
	RegisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_damaged))
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_movement))
	return TRUE

/datum/status_effect/shadow_cloak/on_remove()
	// Remove image
	QDEL_NULL(cloak_image)
	owner.remove_alt_appearance(id)
	// Remove traits and modifiers
	REMOVE_TRAIT(owner, TRAIT_GOTTAGONOTSOFAST, id)
	REMOVE_TRAIT(owner, TRAIT_UNKNOWN, id)
	REMOVE_TRAIT(owner, TRAIT_SILENT_FOOTSTEPS, id)
	// Clear signals
	UnregisterSignal(owner, list(
		COMSIG_ATOM_DIR_CHANGE,
		COMSIG_MOB_STATCHANGE,
		COMSIG_MOB_APPLY_DAMAGE,
		COMSIG_MOVABLE_MOVED,
	))

/// Signal proc for [COMSIG_ATOM_DIR_CHANGE], handles turning the effect as we turn
/datum/status_effect/shadow_cloak/proc/on_dir_change(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER

	cloak_image.dir = new_dir

/// Signal proc for [COMSIG_MOB_STATCHANGE], going past soft crit will stop the effect
/datum/status_effect/shadow_cloak/proc/on_stat_change(datum/source, new_stat, old_stat)
	SIGNAL_HANDLER

	// Going above unconscious will self-delete
	if(new_stat >= UNCONSCIOUS)
		qdel(src)

/// Signal proc for [COMSIG_MOB_APPLY_DAMAGE], being damaged past a threshold will roll a chance to stop the effect
/datum/status_effect/shadow_cloak/proc/on_damaged(datum/source, damage, damagetype, ...)
	SIGNAL_HANDLER

	// Stam damage is generally bursty, so we'll half it
	if(damagetype == STAMINA)
		damage *= 0.5

	// Add incoming damage to the total damage sustained
	damage_sustained += damage
	// If we're not past the threshold, return
	if(damage_sustained < damage_before_reveal)
		return

	// Otherwise, we have a probability based on how much damage sustained to self delete
	if(prob(damage_sustained))
		qdel(src)

/// Signal proc for [COMSIG_MOVABLE_MOVED], leaves a cool looking trail behind us as we walk
/datum/status_effect/shadow_cloak/proc/on_movement(mob/living/carbon/L, atom/old_loc)
	SIGNAL_HANDLER
	var/obj/effect/temp_visual/dir_setting/cloak_walk/trail = new (old_loc, owner.dir)
	if(owner.body_position == LYING_DOWN)
		trail.transform = turn(trail.transform, 90)

/datum/status_effect/shadow_cloak/proc/hide_user(mob/living/carbon/user)
	cloak_image = image('icons/effects/effects.dmi', owner, "curse", dir = owner.dir)
	cloak_image.dir = owner.dir
	cloak_image.override = TRUE
	cloak_image.alpha = 0
	animate(cloak_image, alpha = 255, 0.2 SECONDS)
	owner.add_alt_appearance(id, cloak_image, GLOB.player_list)


// Visual effect for the shadow cloak "trail"
/obj/effect/temp_visual/dir_setting/cloak_walk
	duration = 0.75 SECONDS
	icon_state = "curse"

/obj/effect/temp_visual/dir_setting/cloak_walk/Initialize(mapload, set_dir)
	. = ..()
	animate(src, alpha = 0, time = duration - 1)


