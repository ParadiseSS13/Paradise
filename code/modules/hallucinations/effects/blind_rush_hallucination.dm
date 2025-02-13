/**
  * # Hallucination - Blind Rush
  *
  * Makes target blind and causes them to see semi-transparent humanoids running at them.
  */
/datum/hallucination_manager/blind_rush
	initial_hallucination = /obj/effect/hallucination/no_delete/blind_rusher
	trigger_time = 3.4 SECONDS //total length of the hallucination is a little more than ten seconds

/datum/hallucination_manager/blind_rush/get_spawn_location()
	var/list/turfs = orange(13, owner.loc)
	return pick(turfs)

/datum/hallucination_manager/blind_rush/on_spawn()
	owner.playsound_local(get_turf(src), 'sound/spookoween/ghost_whisper.ogg', 30, TRUE)
	owner.become_blind("hallucination")
	to_chat(owner, "<span class='whisper'>Who turned off the light?</span>", MESSAGE_TYPE_INFO)

/datum/hallucination_manager/blind_rush/on_trigger()
	var/turf/spawn_location = get_spawn_location() //we need a new spawn location incase the player moved
	hallucination_list += new /obj/effect/hallucination/no_delete/blind_rusher(spawn_location, owner)
	to_chat(owner, "<span class='danger'>They're here.</span>", MESSAGE_TYPE_INFO)
	trigger_timer = addtimer(CALLBACK(src, PROC_REF(on_second_trigger)), trigger_time, TIMER_DELETE_ME)

/datum/hallucination_manager/blind_rush/proc/on_second_trigger()
	var/turf/spawn_location = get_spawn_location()
	hallucination_list += new /obj/effect/hallucination/no_delete/blind_rusher(spawn_location, owner)
	owner.Confused(9 SECONDS)
	owner.Jitter(9 SECONDS)
	to_chat(owner, "<span class='userdanger'>Run!</span>", MESSAGE_TYPE_INFO)
	trigger_timer = addtimer(CALLBACK(src, PROC_REF(on_last_trigger)), trigger_time, TIMER_DELETE_ME)

/datum/hallucination_manager/blind_rush/proc/on_last_trigger()
	owner.emote("collapse")
	owner.cure_blind("hallucination")
	qdel(src)

/obj/effect/hallucination/no_delete/blind_rusher
	name = "Unknown"
	alpha = 100
	hallucination_plane = 25 //to make sure we render the hallucination above the blindness layer.
	hallucination_layer = 25
	hallucination_icon = 'icons/mob/simple_human.dmi'
	hallucination_icon_state = ("faceless")
	hallucination_override = TRUE
	var/min_distance = 0
	var/rush_time = 2 DECISECONDS
	var/rush_timer = null

/obj/effect/hallucination/no_delete/blind_rusher/Initialize(mapload, mob/living/carbon/target)
	rush_timer = addtimer(CALLBACK(src, PROC_REF(rush)), rush_time, TIMER_LOOP | TIMER_DELETE_ME)
	if(prob(50))
		hallucination_icon = 'icons/mob/simple_human.dmi'
		hallucination_icon_state = pick("clown", "skeleton_warden", "skeleton_warden_alt")
	return ..()

/obj/effect/hallucination/no_delete/blind_rusher/proc/rush()
	if(get_dist(src, target) > min_distance)
		var/direction = get_dir(src, target) //making sure the hallucination is facing the player correctly.
		forceMove(get_step(src, direction)) //forceMove to go through walls and other dense turfs.
		dir = direction
	else
		target.playsound_local(get_turf(src), 'sound/misc/demon_attack1.ogg', 25, TRUE)
		qdel(src)
