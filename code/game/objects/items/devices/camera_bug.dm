// This item just has an integrated camera console, which the data is "proxied" to
/obj/item/camera_bug
	name = "camera bug"
	desc = "For illicit snooping through the camera network."
	icon = 'icons/obj/device.dmi'
	icon_state = "camera_bug"
	w_class	= WEIGHT_CLASS_TINY
	throw_speed = 4
	throw_range = 20
	origin_tech = "syndicate=1;engineering=3"
	/// Integrated camera console to serve UI data
	var/obj/machinery/computer/security/camera_bug/integrated_console
	var/connections = 0

/obj/machinery/computer/security/camera_bug
	name = "invasive camera utility"
	desc = "How did this get here?! Please report this as a bug to github"
	power_state = NO_POWER_USE
	interact_offline = TRUE
	silent_console = TRUE

/obj/item/camera_bug/Initialize(mapload)
	. = ..()
	integrated_console = new(src)
	integrated_console.parent = src
	integrated_console.network = list("SS13", "camera_bug[UID()]")
	GLOB.restricted_camera_networks += "camera_bug[UID()]"

/obj/item/camera_bug/Destroy()
	QDEL_NULL(integrated_console)
	return ..()

/obj/item/camera_bug/attack_self__legacy__attackchain(mob/user as mob)
	ui_interact(user)

/obj/item/camera_bug/ui_state(mob/user)
	return GLOB.inventory_state

/obj/item/camera_bug/ui_interact(mob/user, datum/tgui/ui = null)
	integrated_console.ui_interact(user, ui)


/obj/item/camera_bug/ert
	name = "\improper ERT Camera Monitor"
	desc = "A small handheld device used by ERT commanders to view camera feeds remotely."

/obj/item/camera_bug/ert/Initialize(mapload)
	. = ..()
	integrated_console.network = list("ERT")

/obj/item/wall_bug
	name = "small camera"
	desc = "A camera with a sticky backside."
	icon = 'icons/obj/device.dmi'
	icon_state = "wall_bug"
	w_class = WEIGHT_CLASS_TINY
	var/obj/machinery/camera/portable/camera_bug/camera
	var/index = "REPORT THIS TO CODERS"
	/// What name shows up on the camera bug list
	var/camera_tag = "Hidden Camera"
	/// If it sticks to whatever you throw at it
	var/is_sticky = TRUE

/obj/item/wall_bug/Initialize(mapload, obj/item/camera_bug/the_bug)
	. = ..()
	link_to_camera(the_bug)
	if(is_sticky)
		AddComponent(/datum/component/sticky)
	ADD_TRAIT(src, TRAIT_NO_THROWN_MESSAGE, ROUNDSTART_TRAIT)

/obj/item/wall_bug/Destroy()
	QDEL_NULL(camera)
	return ..()

/obj/item/wall_bug/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		. += "It has a small label on it reading \"[index]\"."

/obj/item/wall_bug/proc/link_to_camera(obj/item/camera_bug/camera_bug)
	if(!istype(camera_bug))
		return
	if(camera) // we can't link twice
		return
	camera_bug.connections++
	index = camera_bug.connections

	camera = new /obj/machinery/camera/portable/camera_bug(src)
	camera.network = list("camera_bug[camera_bug.UID()]")
	camera.c_tag = "[camera_tag] [index]"

/// Created by a mindflayer ability
/obj/item/wall_bug/computer_bug
	name = "nanobot"
	desc = "A small droplet of a shimmering metallic slurry."
	camera_tag = "Surveillance Unit"
	is_sticky = FALSE
	/// Reference to the creator's antag datum
	var/datum/antagonist/mindflayer/flayer
	COOLDOWN_DECLARE(alert_cooldown)

/obj/item/wall_bug/computer_bug/Destroy()
	flayer = null
	return ..()

/obj/item/wall_bug/computer_bug/link_to_camera(obj/item/camera_bug/camera_bug, datum/antagonist/mindflayer/flayer_datum)
	..()
	if(flayer_datum)
		flayer = flayer_datum

/obj/machinery/camera/portable/camera_bug
	non_chunking_camera = TRUE

/obj/item/paper/camera_bug
	name = "\improper Camera Bug Guide"
	info = {"<b>Instructions on your new invasive camera utility</b><br>
	<br>
	This camera bug can access all default cameras on the station, along with the hidden cameras provided in this kit.<br>
	<br>
	The cameras in this kit have a sticky backside, allowing you to attach them to literally anything, even people.<br>
	<br>
	You may remove the cameras from said objects by grabbing them with an empty hand.<br>
	<br>
	You can view these hidden cameras by looking up "Hidden Camera" on your camera bug.<br>
	<br>
	Only the camera bug provided in this kit can see these hidden cameras.<br>
	<br>
	Other Camera bugs cannot see your hidden cameras.<br>
	<br>
	There is no other way to get these hidden cameras, so make sure to not lose them!<br>"}
