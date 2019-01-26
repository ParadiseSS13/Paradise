/mob/camera/blob
	name = "Blob Overmind"
	real_name = "Blob Overmind"
	icon = 'icons/mob/blob.dmi'
	icon_state = "marker"

	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_MINIMUM
	invisibility = INVISIBILITY_OBSERVER

	pass_flags = PASSBLOB
	faction = list("blob")

	var/obj/structure/blob/core/blob_core = null // The blob overmind's core
	var/blob_points = 0
	var/max_blob_points = 100
	var/last_attack = 0
	var/datum/reagent/blob/blob_reagent_datum = new/datum/reagent/blob()
	var/list/blob_mobs = list()
	var/ghostimage = null

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

	ghostimage = image(src.icon,src,src.icon_state)
	ghost_darkness_images |= ghostimage //so ghosts can see the blob cursor when they disable darkness
	updateallghostimages()
	..()

/mob/camera/blob/Life(seconds, times_fired)
	if(!blob_core)
		qdel(src)
	..()

/mob/camera/blob/Destroy()
	if(ghostimage)
		ghost_darkness_images -= ghostimage
		QDEL_NULL(ghostimage)
		updateallghostimages()
	return ..()

/mob/camera/blob/Login()
	..()
	sync_mind()
	to_chat(src, "<span class='notice'>You are the overmind!</span>")
	to_chat(src, "Your randomly chosen reagent is: <b>[blob_reagent_datum.name]</b>!")
	to_chat(src, "You are the overmind and can control the blob! You can expand, which will attack people, and place new blob pieces such as...")
	to_chat(src, "<b>Normal Blob</b> will expand your reach and allow you to upgrade into special blobs that perform certain functions.")
	to_chat(src, "<b>Shield Blob</b> is a strong and expensive blob which can take more damage. It is fireproof and can block air, use this to protect yourself from station fires.")
	to_chat(src, "<b>Reflective Blob</b>is an upgraded Shield Blob which has a high chance of deflecting energy projectiles, but is vulnerable to ballistics and brute damage.")
	to_chat(src, "<b>Resource Blob</b> is a blob which will collect more resources for you, try to build these earlier to get a strong income. It will benefit from being near your core or multiple nodes, by having an increased resource rate; put it alone and it won't create resources at all.")
	to_chat(src, "<b>Node Blob</b> is a blob which will grow, like the core. Unlike the core it won't give you a small income but it can power resource and factory blobs to increase their rate.")
	to_chat(src, "<b>Factory Blob</b> is a blob which will spawn blob spores which will attack nearby food. Putting this nearby nodes and your core will increase the spawn rate; put it alone and it will not spawn any spores.")
	to_chat(src, "<b>Shortcuts:</b> CTRL Click = Expand Blob / Middle Mouse Click = Rally Spores / Alt Click = Create Shield")
	update_health()

/mob/camera/blob/proc/update_health()
	if(blob_core)
		hud_used.blobhealthdisplay.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#e36600'>[round(blob_core.health)]</font></div>"

/mob/camera/blob/proc/add_points(var/points)
	if(points != 0)
		blob_points = Clamp(blob_points + points, 0, max_blob_points)
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
		if(isovermind(M) || isobserver(M))
			M.show_message(rendered, 2)

/mob/camera/blob/emote(var/act,var/m_type=1,var/message = null)
	return

/mob/camera/blob/blob_act()
	return

/mob/camera/blob/Stat()
	..()
	if(statpanel("Status"))
		if(blob_core)
			stat(null, "Core Health: [blob_core.health]")
		stat(null, "Power Stored: [blob_points]/[max_blob_points]")

/mob/camera/blob/Move(var/NewLoc, var/Dir = 0)
	var/obj/structure/blob/B = locate() in range("3x3", NewLoc)
	if(B)
		loc = NewLoc
	else
		return 0

/mob/camera/blob/proc/can_attack()
	return (world.time > (last_attack + CLICK_CD_RANGE))
