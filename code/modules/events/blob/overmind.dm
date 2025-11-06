/mob/camera/blob
	name = "Blob Overmind"
	real_name = "Blob Overmind"
	icon = 'icons/mob/blob.dmi'
	icon_state = "marker"

	invisibility = INVISIBILITY_HIGH
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	mouse_opacity = MOUSE_OPACITY_OPAQUE

	pass_flags = PASSBLOB
	faction = list(ROLE_BLOB)

	hud_type = /datum/hud/blob_overmind

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
	START_PROCESSING(SSobj, src)

/mob/camera/blob/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/mob/camera/blob/process()
	if(!blob_core)
		qdel(src)

/mob/camera/blob/Login()
	..()
	sync_mind()
	blob_help()
	update_health_hud()

/mob/camera/blob/update_health_hud()
	if(blob_core && hud_used)
		hud_used.blobhealthdisplay.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font face='Small Fonts' color='#e36600'>[round(blob_core.obj_integrity)]</font></div>"

/mob/camera/blob/proc/add_points(points)
	if(points != 0)
		blob_points = clamp(blob_points + points, 0, max_blob_points)
		if(hud_used)
			hud_used.blobpwrdisplay.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font face='Small Fonts' color='#82ed00'>[round(src.blob_points)]</font></div>"

/mob/camera/blob/say(message)
	if(!message)
		return

	if(src.client)
		if(check_mute(client.ckey, MUTE_IC))
			to_chat(src, "You cannot send IC messages (muted).")
			return
		if(src.client.handle_spam_prevention(message, MUTE_IC))
			return

	if(stat)
		return

	blob_talk(message)

/mob/camera/blob/proc/add_mob_to_overmind(mob/living/basic/blob/B)
	B.color = blob_reagent_datum?.complementary_color
	B.overmind = src
	blob_mobs += B
	RegisterSignal(B, COMSIG_PARENT_QDELETING, PROC_REF(on_blob_mob_death))

/mob/camera/blob/proc/on_blob_mob_death(mob/living/basic/blob/B)
	blob_mobs -= B

/mob/camera/blob/proc/blob_talk(message)
	log_say("(BLOB) [message]", src)

	message = sanitize_for_ic(trim(copytext(message, 1, MAX_MESSAGE_LEN)))

	if(!message)
		return

	var/rendered
	var/follow_text
	for(var/mob/M in GLOB.mob_list)
		follow_text = isobserver(M) ? " ([ghost_follow_link(src, ghost=M)])" : ""
		rendered = "<span class='blob'>Blob Telepathy, <span class='name'>[name]([blob_reagent_datum.name])</span>[follow_text] <span class='message'>states, \"[message]\"</span></span>"
		if(isovermind(M) || isobserver(M) || istype(M, /mob/living/basic/blob/blobbernaut))
			M.show_message(rendered, EMOTE_AUDIBLE)

/mob/camera/blob/blob_act(obj/structure/blob/B)
	return

/mob/camera/blob/get_status_tab_items()
	var/list/status_tab_data = ..()
	. = status_tab_data
	if(blob_core)
		status_tab_data[++status_tab_data.len] = list("Core Health:", "[blob_core.obj_integrity]")
		status_tab_data[++status_tab_data.len] = list("Power Stored:", "[blob_points]/[max_blob_points]")

/mob/camera/blob/Move(NewLoc, Dir = 0)
	var/obj/structure/blob/B = locate() in range(3, NewLoc)
	if(B)
		loc = NewLoc
	else
		return 0

/mob/camera/blob/proc/can_attack()
	return (world.time > (last_attack + CLICK_CD_RANGE))
