// This item just has an integrated camera console, which the data is "proxied" to
/obj/item/camera_bug
	name = "camera bug"
	desc = "For illicit snooping through the camera network."
	icon = 'icons/obj/device.dmi'
	icon_state = "camera_bug"
	w_class	= WEIGHT_CLASS_TINY
	item_state = "camera_bug"
	throw_speed	= 4
	throw_range	= 20
	origin_tech = "syndicate=1;engineering=3"
	/// Integrated camera console to serve UI data
	var/obj/machinery/computer/security/camera_bug/integrated_console
	var/connections = 0

/obj/machinery/computer/security/camera_bug
	name = "invasive camera utility"
	desc = "How did this get here?! Please report this as a bug to github"
	power_state = NO_POWER_USE
	requires_power = FALSE
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

/obj/item/camera_bug/attack_self(mob/user as mob)
	ui_interact(user)

/obj/item/camera_bug/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.inventory_state)
	integrated_console.ui_interact(user, ui_key, ui, force_open, master_ui, state)


/obj/item/camera_bug/ert
	name = "ERT Camera Monitor"
	desc = "A small handheld device used by ERT commanders to view camera feeds remotely."

/obj/item/camera_bug/ert/Initialize(mapload)
	. = ..()
	integrated_console.network = list("ERT")

/obj/item/wall_bug
	name = "\improper small camera"
	desc = "A camera with a sticky backside."
	icon = 'icons/obj/device.dmi'
	icon_state = "wall_bug"
	w_class = WEIGHT_CLASS_TINY
	var/obj/machinery/camera/portable/camera
	var/index = "REPORT THIS TO CODERS"

/obj/item/wall_bug/Initialize(mapload, obj/item/camera_bug/the_bug)
	. = ..()
	link_to_camera(the_bug)
	AddComponent(/datum/component/sticky)

/obj/item/wall_bug/Destroy()
	QDEL_NULL(camera)
	. = ..()

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

	camera = new /obj/machinery/camera/portable(src)
	camera.network = list("camera_bug[camera_bug.UID()]")
	camera.c_tag = "Hidden Camera [index]"

/obj/item/paper/camera_bug
	name = "Camera Bug Guide"
	icon_state = "paper"
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
