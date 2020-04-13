/mob/camera/blob
	name = "Blob Overmind"
	real_name = "Blob Overmind"
	icon = 'icons/mob/blob.dmi'
	icon_state = "marker"

	see_in_dark = 8
	invisibility = INVISIBILITY_OBSERVER
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE

	pass_flags = PASSBLOB
	faction = list(ROLE_BLOB)

	var/obj/structure/blob/core/blob_core = null // The blob overmind's core
	var/blob_points = 0
	var/max_blob_points = 100
	var/last_attack = 0
	var/nodes_required = TRUE //if the blob needs nodes to place resource and factory blobs
	var/split_used = FALSE
	var/is_offspring = FALSE
	var/datum/reagent/blob/blob_reagent_datum = new/datum/reagent/blob()
	var/list/blob_mobs = list()

/mob/camera/blob/New()
	var/new_name = "[initial(name)] ([rand(1, 999)])"
	name = new_name
	real_name = new_name
	last_attack = world.time
	var/list/possible_reagents = list()
	for(var/type in subtypesof(/datum/reagent/blob))
		possible_reagents.Add(new type)
	blob_reagent_datum = pick(possible_reagents)
	if(blob_core)
		blob_core.adjustcolors(blob_reagent_datum.color)

	color = blob_reagent_datum.complementary_color
	..()

/mob/camera/blob/Life(seconds, times_fired)
	if(!blob_core)
		qdel(src)
	..()

/mob/camera/blob/Login()
	..()
	sync_mind()
	blob_help()
	update_health_hud()

/mob/camera/blob/update_health_hud()
	if(blob_core && hud_used)
		hud_used.blobhealthdisplay.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#e36600'>[round(blob_core.obj_integrity)]</font></div>"

/mob/camera/blob/proc/add_points(var/points)
	if(points != 0)
		blob_points = Clamp(blob_points + points, 0, max_blob_points)
		if(hud_used)
			hud_used.blobpwrdisplay.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#82ed00'>[round(src.blob_points)]</font></div>"

/mob/camera/blob/say(var/message)
	if(!message)
		return

	if(src.client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "You cannot send IC messages (muted).")
			return
		if(src.client.handle_spam_prevention(message,MUTE_IC))
			return

	if(stat)
		return

	blob_talk(message)

/mob/camera/blob/proc/blob_talk(message)
	log_say("(BLOB) [message]", src)

	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if(!message)
		return

	var/verb = "states,"
	var/rendered = "<font color=\"#EE4000\"><i><span class='game say'>Blob Telepathy, <span class='name'>[name]([blob_reagent_datum.name])</span> <span class='message'>[verb] \"[message]\"</span></span></i></font>"

	for(var/mob/M in GLOB.mob_list)
		if(isovermind(M) || isobserver(M) || istype((M), /mob/living/simple_animal/hostile/blob/blobbernaut))
			M.show_message(rendered, 2)

/mob/camera/blob/emote(act, m_type = 1, message = null, force)
	return

/mob/camera/blob/blob_act(obj/structure/blob/B)
	return

/mob/camera/blob/Stat()
	..()
	if(statpanel("Status"))
		if(blob_core)
			stat(null, "Core Health: [blob_core.obj_integrity]")
		stat(null, "Power Stored: [blob_points]/[max_blob_points]")

/mob/camera/blob/Move(var/NewLoc, var/Dir = 0)
	var/obj/structure/blob/B = locate() in range("3x3", NewLoc)
	if(B)
		loc = NewLoc
	else
		return 0

/mob/camera/blob/proc/can_attack()
	return (world.time > (last_attack + CLICK_CD_RANGE))
