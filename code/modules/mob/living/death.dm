//This is the proc for gibbing a mob. Cannot gib ghosts.
//added different sort of gibs and animations. N
/mob/living/gib()
	if(!death(TRUE) && stat != DEAD)
		return FALSE
	// hide and freeze for the GC
	notransform = TRUE
	if(gib_nullifies_icon)
		icon = null
	invisibility = 101

	playsound(src.loc, 'sound/goonstation/effects/gib.ogg', 50, 1)
	gibs(loc, dna)
	QDEL_IN(src, 0)
	return TRUE

//This is the proc for turning a mob into ash. Mostly a copy of gib code (above).
//Originally created for wizard disintegrate. I've removed the virus code since it's irrelevant here.
//Dusting robots does not eject the MMI, so it's a bit more powerful than gib() /N
/mob/living/dust()
	if(!death(TRUE) && stat != DEAD)
		return FALSE
	new /obj/effect/decal/cleanable/ash(loc)
	// hide and freeze them while they get GC'd
	notransform = TRUE
	icon = null
	invisibility = 101
	QDEL_IN(src, 0)
	return TRUE

/mob/living/melt()
	if(!death(TRUE) && stat != DEAD)
		return FALSE
	// hide and freeze them while they get GC'd
	notransform = TRUE
	icon = null
	invisibility = 101
	QDEL_IN(src, 0)
	return TRUE

/mob/living/proc/can_die()
	return !(stat == DEAD || (status_flags & GODMODE))

// Returns true if mob transitioned from live to dead
// Do a check with `can_die` beforehand if you need to do any
// handling before `stat` is set
/mob/living/death(gibbed)
	if(!can_die())
		// Whew! Good thing I'm indestructible! (or already dead)
		return FALSE

	set_stat(DEAD)
	..()

	timeofdeath = world.time
	create_log(ATTACK_LOG, "died[gibbed ? " (Gibbed)": ""]")

	SetDizzy(0)
	SetJitter(0)
	SetLoseBreath(0)

	if(!gibbed && deathgasp_on_death)
		emote("deathgasp")

	if(mind && suiciding)
		mind.suicided = TRUE
	reset_perspective(null)
	reload_fullscreen()
	update_sight()
	update_action_buttons_icon()
	ADD_TRAIT(src, TRAIT_FLOORED, STAT_TRAIT)
	ADD_TRAIT(src, TRAIT_HANDS_BLOCKED, STAT_TRAIT) // immobilized is superfluous as moving when dead ghosts you.
	update_damage_hud()
	update_health_hud()
	update_stamina_hud()
	med_hud_set_health()
	med_hud_set_status()

	GLOB.alive_mob_list -= src
	GLOB.dead_mob_list += src
	if(mind)
		mind.store_memory("Time of death: [station_time_timestamp("hh:mm:ss", timeofdeath)]", 0)
		ADD_TRAIT(src, TRAIT_RESPAWNABLE, GHOSTED)

		if(mind.name && !isbrain(src)) // !isbrain() is to stop it from being called twice
			var/turf/T = get_turf(src)
			var/area_name = get_area_name(T)
			for(var/P in GLOB.dead_mob_list)
				var/mob/M = P
				if((M.client?.prefs.toggles2 & PREFTOGGLE_2_DEATHMESSAGE) && (isobserver(M) || M.stat == DEAD))
					to_chat(M, "<span class='deadsay'><b>[mind.name]</b> has died at <b>[area_name]</b>. (<a href='byond://?src=[M.UID()];jump=\ref[T]'>JMP</a>)</span>")
					if(last_words)
						to_chat(M, "<span class='deadsay'><b>[p_their(TRUE)] last words were:</b> \"[last_words]\"</span>")

	if(SSticker && SSticker.mode)
		SSticker.mode.check_win()

	clear_alert("succumb")

	// u no we dead
	return TRUE

/mob/living/proc/delayed_gib(inflate_at_end = FALSE)
	visible_message("<span class='danger'><b>[src]</b> starts convulsing violently!</span>", "You feel as if your body is tearing itself apart!")
	Weaken(30 SECONDS)
	do_jitter_animation(1000, -1) // jitter until they are gibbed
	addtimer(CALLBACK(src, inflate_at_end ? PROC_REF(quick_explode_gib) : PROC_REF(gib)), rand(2 SECONDS, 10 SECONDS))

/mob/living/proc/inflate_gib() // Plays an animation that makes mobs appear to inflate before finally gibbing
	addtimer(CALLBACK(src, PROC_REF(gib), null, null, TRUE, TRUE), 2.5 SECONDS)
	var/matrix/M = transform
	M.Scale(1.8, 1.2)
	animate(src, time = 40, transform = M, easing = SINE_EASING)

/mob/living/proc/quick_explode_gib()
	addtimer(CALLBACK(src, PROC_REF(gib), null, null, TRUE, TRUE), 0.1 SECONDS)
	var/matrix/M = transform
	M.Scale(1.8, 1.2)
	animate(src, time = 1, transform = M, easing = SINE_EASING)
