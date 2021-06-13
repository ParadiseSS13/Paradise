/**
  * handle_eye_contact() is called when we examine() something. If we examine an alive mob with a mind who has examined us in the last second within 5 tiles, we make eye contact!
  *
  * Note that if either party has their face obscured, the other won't get the notice about the eye contact
  * Also note that examine_more() doesn't proc this or extend the timer, just because it's simpler this way and doesn't lose much.
  *	The nice part about relying on examining is that we don't bother checking visibility, because we already know they were both visible to each other within the last second, and the one who triggers it is currently seeing them
  */
/mob/proc/handle_eye_contact(mob/living/examined_mob)
	return

/mob/living/handle_eye_contact(mob/living/examined_mob)
	if(!istype(examined_mob) || src == examined_mob || examined_mob.stat >= UNCONSCIOUS || !client || !examined_mob.client?.recent_examines || !(src in examined_mob.client.recent_examines))
		return

	if(get_dist(src, examined_mob) > EYE_CONTACT_RANGE)
		return

	// check to see if their face is blocked or, if not, a signal blocks it
	if(examined_mob.is_face_visible() && SEND_SIGNAL(src, COMSIG_MOB_EYECONTACT, examined_mob) != COMSIG_BLOCK_EYECONTACT)
		var/msg = "<span class='smallnotice'>You make eye contact with [examined_mob].</span>"
		addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, src, msg), 3) // so the examine signal has time to fire and this will print after

	if(is_face_visible() && SEND_SIGNAL(examined_mob, COMSIG_MOB_EYECONTACT, src) != COMSIG_BLOCK_EYECONTACT)
		var/msg = "<span class='smallnotice'>[src] makes eye contact with you.</span>"
		addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, examined_mob, msg), 3)

/mob/proc/clear_from_recent_examines(atom/A)
	if(!client)
		return
	UnregisterSignal(A, COMSIG_PARENT_QDELETING)
	LAZYREMOVE(client.recent_examines, A)

/mob/living/carbon/is_face_visible()
	return !(wear_mask?.flags_inv & HIDEFACE) && !(head?.flags_inv & HIDEFACE)

/mob/living/proc/is_face_visible()
	return TRUE
