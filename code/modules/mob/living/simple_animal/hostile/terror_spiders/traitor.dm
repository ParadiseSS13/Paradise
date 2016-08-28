
// --------------------------------------------------------------------------------
// ----------------- TERROR SPIDERS: UPLINK ITEMS ---------------------------------
// --------------------------------------------------------------------------------


/obj/machinery/power/singularity_beacon/terrorspider_beacon
	name = "psionic beacon"
	desc = "A strange beacon."
	var/ondesc = "This strange beacon pulses with an evil-looking red light."
	var/countdown = 120
	var/summoned_spiders = 0
	icontype = "beaconsynd"
	icon_state = "beaconsynd0"

/obj/machinery/power/singularity_beacon/terrorspider_beacon/attack_hand(var/mob/user as mob)
	if(anchored)
		if(active)
			to_chat(user, "<span class='warning'>[src] is already active, and there is no off button!</span>")
		else
			Activate(user)
	else
		to_chat(user, "<span class='warning'>You need to screw the beacon to the floor first!</span>")

/obj/machinery/power/singularity_beacon/terrorspider_beacon/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/weapon/screwdriver))
		if(active)
			to_chat(user, "<span class='warning'>\The [W] does nothing!</span>")
			return
		if(anchored)
			anchored = 0
			to_chat(user, "<span class='notice'>You unscrew the beacon from the floor.</span>")
			disconnect_from_network()
			return
		else
			if(!connect_to_network())
				to_chat(user, "<span class='notice'>This device must be placed over an exposed cable.</span>")
				return
			anchored = 1
			to_chat(user, "<span class='notice'>You screw the beacon to the floor and attach the cable.</span>")
			return
	..()

/obj/machinery/power/singularity_beacon/terrorspider_beacon/Activate(mob/user = null)
	if(countdown == 0)
		to_chat(user, "This beacon has already been used up.")
		return
	if(surplus() < 1500)
		if(user)
			to_chat(user, "<span class='notice'>The connected wire doesn't have enough current.</span>")
		return
	icon_state = "[icontype]1"
	active = 1
	machines |= src
	if(user)
		to_chat(user, "<span class='notice'>You activate the beacon.</span>")

/obj/machinery/power/singularity_beacon/terrorspider_beacon/Deactivate(mob/user = null)
	icon_state = "[icontype]0"
	active = 0
	if(user)
		to_chat(user, "<span class='notice'>You deactivate the beacon.</span>")

/obj/machinery/power/singularity_beacon/terrorspider_beacon/process()
	if(!active)
		return PROCESS_KILL
	else
		if(countdown == 0)
			spawn_spiders()
			visible_message("<span class='danger'>\The [src] activates!</span>")
			explosion(get_turf(src),0,1,5,0)
			qdel(src)
		else if(surplus() > 1500)
			draw_power(1500)
			countdown--
			desc = ondesc + "<BR>A small digital display reads: <span class='danger'> [countdown]</span>"
		else
			Deactivate()

/obj/machinery/power/singularity_beacon/terrorspider_beacon/proc/spawn_spiders()
	var/spawncount = 1
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in all_vent_pumps)
		if((temp_vent.loc.z in config.station_levels) && !temp_vent.welded)
			if(temp_vent.parent.other_atmosmch.len > 50)
				vents += temp_vent
	while((spawncount >= 1) && vents.len)
		var/obj/vent = pick(vents)
		var/obj/effect/spider/spiderling/S = new(vent.loc)
		S.name = "evil-looking spiderling"
		S.grow_as = /mob/living/simple_animal/hostile/poison/terror_spider/white
		S.amount_grown = 50 // double-speed growth
		notify_ghosts("[src] has detonated in [get_area(src)], drawing a white terror spiderling to [get_area(S)]")
		vents -= vent
		spawncount--
