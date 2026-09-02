/mob/living/basic/netherworld/migo
	name = "mi-go"
	desc = "A pinkish, fungoid crustacean-like creature with numerous pairs of clawed appendages and a head covered with waving antennae."
	speak_emote = list("screams", "clicks", "chitters", "barks", "moans", "growls", "meows", "reverberates", "roars", "squeaks", "rattles", "exclaims", "yells", "remarks", "mumbles", "jabbers", "stutters", "seethes")
	icon_state = "mi-go"
	icon_living = "mi-go"
	icon_dead = "mi-go-dead"
	attack_verb_simple = "lacerate"
	attack_verb_continuous = "lacerates"
	speed = 0
	death_message = "wails as its form turns into a pulpy mush."
	death_sound = 'sound/voice/hiss6.ogg'
	/// Will the migo dodge?
	var/dodge_prob = 10
	surgery_container = /datum/xenobiology_surgery_container/migo


/// Makes the migo more likely to dodge around the more damaged it is
/mob/living/basic/netherworld/migo/proc/update_dodge_chance(health_ratio)
	dodge_prob = LERP(50, 10, health_ratio)

/mob/living/basic/netherworld/migo/proc/make_migo_sound()
	playsound(src, pick(GLOB.migo_sounds), 50, TRUE)

/mob/living/basic/netherworld/migo/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	..()
	if(stat)
		return
	make_migo_sound()

/mob/living/basic/netherworld/migo/Life()
	..()
	if(stat)
		return
	if(prob(10))
		make_migo_sound()

/mob/living/basic/netherworld/migo/Move(atom/newloc, dir, step_x, step_y)
	if(!ckey && prob(dodge_prob) && moving_diagonally == 0 && isturf(loc) && isturf(newloc) && stat != DEAD)
		return dodge(newloc, dir)
	else
		return ..()

/mob/living/basic/netherworld/migo/proc/dodge(moving_to, move_direction)
	// Assuming we move towards the target we want to swerve toward them to get closer
	var/cdir = turn(move_direction, 45)
	var/ccdir = turn(move_direction, -45)
	. = Move(get_step(loc, pick(cdir, ccdir)))
	if(!.)// Can't dodge there so we just carry on
		. = Move(moving_to, move_direction)

