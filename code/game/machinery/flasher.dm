// It is a gizmo that flashes a small area

/obj/machinery/flasher
	name = "Mounted flash"
	desc = "A wall-mounted flashbulb device."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "mflash1"
	var/id = null
	var/range = 2 //this is roughly the size of brig cell
	var/disable = 0
	var/last_flash = 0 //Don't want it getting spammed like regular flashes
	var/strength = 5 //How weakened targets are when flashed.
	var/base_state = "mflash"
	anchored = 1

/obj/machinery/flasher/portable //Portable version of the flasher. Only flashes when anchored
	name = "portable flasher"
	desc = "A portable flashing device. Wrench to activate and deactivate. Cannot detect slow movements."
	icon_state = "pflash1"
	strength = 4
	anchored = 0
	base_state = "pflash"
	density = 1

/*
/obj/machinery/flasher/New()
	sleep(4)					//<--- What the fuck are you doing? D=
	sd_set_light(2)
*/
/obj/machinery/flasher/power_change()
	if( powered() )
		stat &= ~NOPOWER
		icon_state = "[base_state]1"
//		sd_set_light(2)
	else
		stat |= ~NOPOWER
		icon_state = "[base_state]1-p"
//		sd_set_light(0)

//Don't want to render prison breaks impossible
/obj/machinery/flasher/attackby(obj/item/I, mob/user, params)
	if(iswirecutter(I))
		add_fingerprint(user)
		disable = !disable
		if(disable)
			user.visible_message("<span class='warning'>[user] has disconnected [src]'s flashbulb!</span>", "<span class='warning'>You disconnect [src]'s flashbulb!</span>")
		if(!disable)
			user.visible_message("<span class='warning'>[user] has connected [src]'s flashbulb!</span>", "<span class='warning'>You connect [src]'s flashbulb!</span>")
	else
		return ..()

//Let the AI trigger them directly.
/obj/machinery/flasher/attack_ai(mob/user)
	if(anchored)
		return flash()

/obj/machinery/flasher/attack_ghost(mob/user)
	if(anchored && user.can_advanced_admin_interact())
		return flash()

/obj/machinery/flasher/proc/flash()
	if(!(powered()))
		return

	if((disable) || (last_flash && world.time < last_flash + 150))
		return

	playsound(loc, 'sound/weapons/flash.ogg', 100, 1)
	flick("[base_state]_flash", src)
	last_flash = world.time
	use_power(1000)

	for(var/mob/living/L in viewers(src, null))
		if(get_dist(src, L) > range)
			continue

		if(L.flash_eyes(affect_silicon = 1))
			L.Weaken(strength)
			if(L.weakeyes)
				L.Weaken(strength * 1.5)
				L.visible_message("<span class='disarm'><b>[L]</b> gasps and shields [L.p_their()] eyes!</span>")

/obj/machinery/flasher/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	if(prob(75/severity))
		flash()
	..(severity)

/obj/machinery/flasher/portable/HasProximity(atom/movable/AM as mob|obj)
	if((disable) || (last_flash && world.time < last_flash + 150))
		return

	if(istype(AM, /mob/living/carbon))
		var/mob/living/carbon/M = AM
		if((M.m_intent != MOVE_INTENT_WALK) && (anchored))
			flash()

/obj/machinery/flasher/portable/attackby(obj/item/I, mob/user, params)
	if(iswrench(I))
		add_fingerprint(user)
		anchored = !anchored

		if(!anchored)
			user.show_message(text("<span class='warning'>[src] can now be moved.</span>"))
			overlays.Cut()

		else if(anchored)
			user.show_message(text("<span class='warning'>[src] is now secured.</span>"))
			overlays += "[base_state]-s"
	else
		return ..()

// Flasher button
/obj/machinery/flasher_button
	name = "flasher button"
	desc = "A remote control switch for a mounted flasher."
	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt"
	var/id = null
	var/active = 0
	anchored = 1.0
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 4

/obj/machinery/flasher_button/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/flasher_button/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		return attack_hand(user)

/obj/machinery/flasher_button/attackby(obj/item/W, mob/user as mob, params)
	return attack_hand(user)

/obj/machinery/flasher_button/attack_hand(mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return
	if(active)
		return

	use_power(5)

	active = 1
	icon_state = "launcheract"

	for(var/obj/machinery/flasher/M in world)
		if(M.id == id)
			spawn()
				M.flash()

	sleep(50)

	icon_state = "launcherbtt"
	active = 0
