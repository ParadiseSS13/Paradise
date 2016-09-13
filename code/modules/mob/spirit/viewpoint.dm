#define FAVOR_PLEASED 1
#define FAVOR_INDIFFERENT 0
#define FAVOR_DISPLEASED -1


var/obj/cult_viewpoint/list/cult_viewpoints = list()


/obj/cult_viewpoint
	var/view_range = 7
	var/updating = 0
	var/mob/owner = null
	var/urge = ""
	var/favor = FAVOR_INDIFFERENT
	var/cult_name = null


/obj/cult_viewpoint/New(var/mob/target)
	owner = target
	//src.loc = owner
	cult_viewpoints+=src
	//handle_missing_mask()
	..()


/obj/cult_viewpoint/Destroy()
	processing_objects.Remove(src)
	cult_viewpoints-=src
	return ..()


// VERBS
/obj/cult_viewpoint/verb/check_urge()
	set category = "Cult"
	set desc = "Discover what your god commands of you."
	set name = "Check Urge"
	set src in usr
	if(src.urge)
		to_chat(owner, "\red \b You feel the urge to [src.urge]")
	else
		to_chat(owner, "\b You feel no supernatural compulsions.")


/obj/cult_viewpoint/verb/reach_out()
	set category = "Cult"
	set desc = "Reach out for your gods presence."
	set name = "Reach Out"
	set src in usr

	for(var/mob/spirit/mask/currentMask in spirits)
		if(currentMask.is_active())
			to_chat(owner, "\red \b You feel the reassuring presence of your god.")
			to_chat(currentMask, "<span class='cultspeech'><span class='name'><a href='byond://?src=[currentMask.UID()];track2=\ref[currentMask];track=\ref[usr]'>[get_display_name()]</a></span><span class='message'> has reached out to you.</span></span>")

			return
	to_chat(owner, "\b You feel a chilling absence.")
	handle_missing_mask()


/obj/cult_viewpoint/verb/check_favor()
	set category = "Cult"
	set desc = "Check your favor with your god."
	set name = "Check Favor"
	set src in usr
	switch(favor)
		if(FAVOR_PLEASED)
			to_chat(owner, "\red \b You bask in your gods favor.")
		if(FAVOR_INDIFFERENT)
			to_chat(owner, "\red \b You feel nothing.")
		if(FAVOR_DISPLEASED)
			to_chat(owner, "\red \b You cringe at your gods displeasure.")


/obj/cult_viewpoint/verb/pray_to_mask()
	set category = "Cult"
	set desc = "Pray to your god"
	set name = "Pray to Nar'Sie"
	set src in usr

	var/input = stripped_input(usr, "Please choose a message to say to your god.", "Pray to Nar'Sie", "")
	if(!input)
		return

	cult_log("[key_name(usr,0)](Pray):[input]")
	to_chat(owner, "<span class='cultspeech'><b>You pray to Nar'Sie</b>: [input]</span>")

	for(var/mob/spirit/spirit in spirits)
		to_chat(spirit, "<span class='cultspeech'><span class='name'><a href='byond://?src=[spirit.UID()];track2=\ref[spirit];track=\ref[usr]'>[get_display_name()]</a> prays : </span><span class='message'>[input]</span></span>")


// PROCS
/obj/cult_viewpoint/proc/set_favor(var/newFavor)
	favor = newFavor
	check_favor()


/obj/cult_viewpoint/proc/set_urge(var/newUrge)
	if(!newUrge)
		src.urge = null
	src.urge = copytext(newUrge, 1, MAX_MESSAGE_LEN)
	check_urge()


/obj/cult_viewpoint/proc/can_use()
	if(owner.stat != DEAD)
		return TRUE
	return FALSE


/obj/cult_viewpoint/proc/can_see()
	return hear(view_range, get_turf(owner))


/obj/cult_viewpoint/proc/get_cult_name()
	if(cult_name)
		return cult_name
	return "An Unknown Servant"


/obj/cult_viewpoint/proc/set_cult_name(var/newName)
	if(!owner)
		return FALSE
	if(newName)
		cult_name = newName
		to_chat(owner, "\red \b You have been blessed with the secret name of '[newName]'.")
	else
		cult_name = null
		to_chat(owner, "\red \b Your god has taken your secret name.")


/obj/cult_viewpoint/proc/get_display_name()
	if(istype(src,/obj/effect/rune))
		return name
	if(!owner)
		return
	if(cult_name)
		return cult_name
	return owner.name


/obj/cult_viewpoint/proc/become_mask()
	set category = "Cult"
	set name = "Become Mask"
	set desc = "Sacrifice your life and become a Mask of Nar'sie."
	set src in usr

	cult_log("[key_name(usr,0)] has tried to become a Mask of Nar'sie.")

	if(!active_mask())
		var/confirm = alert(owner.client, "You are about to become a Mask of Nar'sie.  This will destroy your body, and you will only be able to guide the other cultists through communication. Are you sure?", "Confirm Your Sacrifice", "Yes", "No")
		if(confirm == "Yes")
			var/transformation_type = alert(owner.client, "You are about to become a Mask. Do you want it to be subtle or violent?", "Mask", "Subtle", "Violent")
			if(!active_mask())
				cult_log("[key_name(usr,0)] has become a Mask of Nar'sie.")
				if(transformation_type=="Subtle")
					log_admin("[key_name_admin(owner)] has subtly become a Mask of Nar'sie")
					owner.make_into_mask(0,0)
				else
					log_admin("[key_name_admin(owner)] has violently become a Mask of Nar'sie")
					owner.make_into_mask(1,1)
		else
			return
	else
		to_chat(owner, "\b You cannot become a mask of Nar'Sie because a Mask already exists.")
	mask_has_been_found()
	return


/obj/cult_viewpoint/proc/active_mask()
	for(var/mob/spirit/mask/currentMask in spirits)
		if(currentMask.is_active())
			return TRUE
	return FALSE


/obj/cult_viewpoint/proc/handle_missing_mask()
	if(active_mask())
		mask_has_been_found()
	else
		mask_is_missing()


/obj/cult_viewpoint/proc/mask_has_been_found()
	for(var/obj/cult_viewpoint/viewpoint in cult_viewpoints)
		if(viewpoint.verbs.Find(/obj/cult_viewpoint/proc/become_mask))
			viewpoint.verbs-=/obj/cult_viewpoint/proc/become_mask


/obj/cult_viewpoint/proc/mask_is_missing()
	for(var/obj/cult_viewpoint/viewpoint in cult_viewpoints)
		if(!viewpoint.verbs.Find(/obj/cult_viewpoint/proc/become_mask))
			viewpoint.verbs+=/obj/cult_viewpoint/proc/become_mask


/proc/getCultViewpoint(var/mob/currentMob)
	for(var/obj/cult_viewpoint/currentView in currentMob)
		return currentView
	return FALSE


#undef FAVOR_PLEASED
#undef FAVOR_INDIFFERENT
#undef FAVOR_DISPLEASED