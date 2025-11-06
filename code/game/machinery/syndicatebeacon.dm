////////////////////////////////////////
//Singularity beacon
////////////////////////////////////////
/obj/machinery/power/singularity_beacon
	name = "ominous beacon"
	desc = "This looks suspicious..."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "beacon0"

	anchored = FALSE
	density = TRUE
	layer = MOB_LAYER - 0.2 //so people can't hide it and it's REALLY OBVIOUS

	var/active = FALSE
	var/icontype = "beacon"


/obj/machinery/power/singularity_beacon/proc/Activate(mob/user = null)
	if(get_surplus() < 1500)
		if(user)
			to_chat(user, "<span class='notice'>The connected wire doesn't have enough current.</span>")
		return
	for(var/thing in GLOB.singularities)
		var/obj/singularity/singulo = thing
		if(singulo.z == z)
			singulo.target = src
	icon_state = "[icontype]1"
	active = TRUE
	START_PROCESSING(SSmachines, src)
	if(user)
		to_chat(user, "<span class='notice'>You activate the beacon.</span>")


/obj/machinery/power/singularity_beacon/proc/Deactivate(mob/user = null)
	for(var/thing in GLOB.singularities)
		var/obj/singularity/singulo = thing
		if(singulo.target == src)
			singulo.target = null
	icon_state = "[icontype]0"
	active = FALSE
	if(user)
		to_chat(user, "<span class='notice'>You deactivate the beacon.</span>")

/obj/machinery/power/singularity_beacon/attack_ai(mob/user as mob)
	return

/obj/machinery/power/singularity_beacon/attack_hand(mob/user as mob)
	if(anchored)
		return active ? Deactivate(user) : Activate(user)
	else
		to_chat(user, "<span class='warning'>You need to screw the beacon to the floor first!</span>")
		return

/obj/machinery/power/singularity_beacon/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(active)
		to_chat(user, "<span class='warning'>You need to deactivate the beacon first!</span>")
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(anchored)
		anchored = FALSE
		to_chat(user, "<span class='notice'>You unscrew the beacon from the floor.</span>")
		disconnect_from_network()
		return
	else
		if(!connect_to_network())
			to_chat(user, "This device must be placed over an exposed cable.")
			return
		anchored = TRUE
		to_chat(user, "<span class='notice'>You screw the beacon to the floor and attach the cable.</span>")

/obj/machinery/power/singularity_beacon/Destroy()
	if(active)
		Deactivate()
	return ..()

//stealth direct power usage
/obj/machinery/power/singularity_beacon/process()
	if(!active)
		return PROCESS_KILL

	if(get_surplus() >= 1500)
		consume_direct_power(1500)
	else
		Deactivate()

/obj/machinery/power/singularity_beacon/syndicate
	icontype = "beaconsynd"
	icon_state = "beaconsynd0"
