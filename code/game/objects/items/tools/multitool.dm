#define PROXIMITY_NONE ""
#define PROXIMITY_ON_SCREEN "_red"
#define PROXIMITY_NEAR "_yellow"

/**
 * Multitool -- A multitool is used for hacking electronic devices.
 */

/obj/item/multitool
	name = "multitool"
	desc = "A compact gadget used for testing electrical connections, manipulating wiring, and accessing certain locking mechanisms."
	icon = 'icons/obj/tools.dmi'
	icon_state = "multitool"
	belt_icon = "multitool"
	flags = CONDUCT
	throw_speed = 3
	drop_sound = 'sound/items/handling/multitool_drop.ogg'
	pickup_sound =  'sound/items/handling/multitool_pickup.ogg'
	materials = list(MAT_METAL = 300, MAT_GLASS = 140)
	origin_tech = "magnets=1;engineering=2"
	tool_behaviour = TOOL_MULTITOOL
	hitsound = 'sound/weapons/tap.ogg'
	new_attack_chain = TRUE
	/// Reference to whatever machine is held in the buffer
	var/obj/machinery/buffer // TODO - Make this a soft ref to tie into whats below
	/// Soft-ref for linked stuff. This should be used over the above var.
	var/buffer_uid
	/// Cooldown for detecting APCs
	COOLDOWN_DECLARE(cd_apc_scan)

/obj/item/multitool/multitool_check_buffer(user, silent = FALSE)
	return TRUE

/obj/item/multitool/proc/set_multitool_buffer(mob/user, obj/machinery/M)	//Loads a machine into memory, returns TRUE if it does
	if(!ismachinery(M))
		to_chat(user, "<span class='warning'>That's not a machine!</span>")
		return
	buffer = M
	to_chat(user, "<span class='notice'>You load [M]'s identifying data into [src]'s internal buffer.</span>")
	return TRUE

/obj/item/multitool/Destroy()
	buffer = null
	return ..()

/obj/item/multitool/activate_self(mob/user)
	. = ..()
	if(!COOLDOWN_FINISHED(src, cd_apc_scan))
		return
	COOLDOWN_START(src, cd_apc_scan, 1.5 SECONDS)
	var/area/local_area = get_area(src)
	var/obj/machinery/power/apc/apc = local_area?.get_apc()
	if(!apc)
		to_chat(user, "<span class='warning'>No APC detected.</span>")
		return
	if(get_turf(src) == get_turf(apc)) // we're standing on top of it
		to_chat(user, "<span class='notice'>APC detected 0 meters [dir2text(apc.dir)].</span>")
		return
	to_chat(user, "<span class='notice'>APC detected [get_dist(src, apc)] meter\s [dir2text(get_dir(src, apc))].</span>")

/obj/item/multitool/ranged_interact_with_atom(atom/target, mob/living/user, list/modifiers)
	. = ..()
	if(!(istype(target, /obj/machinery/atmospherics/unary) || istype(target, /obj/machinery/atmospherics/air_sensor)))
		return
	if(!(target in view(5, user)))
		to_chat(user,"<span class='warning'>[target] out of multitool range. Please get within 5 meters and try again.<span>")
		return
	return target.multitool_act(user, src)

// Syndicate device disguised as a multitool; it will turn red when an AI camera is nearby.
/obj/item/multitool/ai_detect
	origin_tech = "magnets=1;engineering=2;syndicate=1"
	w_class = WEIGHT_CLASS_SMALL
	inhand_icon_state = "multitool"
	var/track_cooldown = 0
	var/track_delay = 10 //How often it checks for proximity
	var/detect_state = PROXIMITY_NONE
	var/rangealert = 8	//Glows red when inside
	var/rangewarning = 20 //Glows yellow when inside

/obj/item/multitool/ai_detect/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/multitool/ai_detect/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/multitool/ai_detect/process()
	if(track_cooldown > world.time)
		return
	detect_state = PROXIMITY_NONE
	multitool_detect()
	icon_state = "[initial(icon_state)][detect_state]"
	belt_icon = "[initial(icon_state)][detect_state]"
	track_cooldown = world.time + track_delay
	if(istype(loc, /obj/item/storage/belt))
		var/obj/item/storage/belt/B = loc
		B.update_icon()

/obj/item/multitool/ai_detect/proc/multitool_detect()
	var/turf/our_turf = get_turf(src)
	for(var/mob/living/silicon/ai/AI in GLOB.ai_list)
		if(AI.camera_follow == src)
			detect_state = PROXIMITY_ON_SCREEN
			break

	if(!detect_state && GLOB.cameranet.chunk_generated(our_turf.x, our_turf.y, our_turf.z))
		var/datum/camerachunk/chunk = GLOB.cameranet.get_camera_chunk(our_turf.x, our_turf.y, our_turf.z)
		if(chunk)
			if(length(chunk.seenby))
				for(var/mob/camera/eye/ai/A in chunk.seenby)
					//Checks if the A is to be detected or not
					if(!A.ai_detector_visible)
						continue
					var/turf/detect_turf = get_turf(A)
					if(get_dist(our_turf, detect_turf) < rangealert)
						detect_state = PROXIMITY_ON_SCREEN
						break
					if(get_dist(our_turf, detect_turf) < rangewarning)
						detect_state = PROXIMITY_NEAR
						break

/obj/item/multitool/red
	name = "suspicious multitool"
	desc = "A slick black & red multitool used for testing and interfacing with electrical equipment in style."
	icon_state = "multitool_syndi"
	belt_icon = "multitool_syndi"
	toolspeed = 0.95 // dangerously fast... not like multitools use speed anyways
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "magnets=1;engineering=2;syndicate=1"

/obj/item/multitool/command
	name = "command multitool"
	desc = "A majestic blue multiool used for testing and interfacing with electrical equipment with class."
	icon_state = "multitool_command"
	belt_icon = "multitool_command"
	toolspeed = 0.95 //command those wires / that fireaxe cabinet!
	var/list/victims = list()

/obj/item/multitool/command/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] is attempting to command the command multitool! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	//basically just cleaned up and copied from the medical wrench code
	if(!user)
		return

	user.Immobilize(10 SECONDS)
	sleep(20)
	add_fingerprint(user)

	var/base_desc = "A majestic blue multiool used for testing and interfacing with electrical equipment with class. Its screen displays the text \""
	victims += user.name

	if(length(victims) < 3)
		desc = base_desc + english_list(victims) + ": executed for mutiny.\""
	else
		desc = base_desc + english_list(victims) + ", all executed for mutiny. Impressive.\""

	playsound(loc, 'sound/effects/supermatter.ogg', 50, TRUE, -1)
	for(var/obj/item/W in user)
		user.drop_item_to_ground(W)

	user.dust()
	return OBLITERATION

/obj/item/multitool/cyborg
	desc = "An integrated multitool used for electrical maintenance, typically found in construction and engineering robots."
	toolspeed = 0.5

/obj/item/multitool/cyborg/drone

/obj/item/multitool/cyborg/drone/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SHOW_WIRE_INFO, ROUNDSTART_TRAIT) // Drones are linked to the station

#undef PROXIMITY_NONE
#undef PROXIMITY_ON_SCREEN
#undef PROXIMITY_NEAR
