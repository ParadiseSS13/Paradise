#define DAMAGE			1
#define FIRE			2

/obj/spacepod
	name = "\improper space pod"
	desc = "A space pod meant for space travel."
	icon = 'icons/48x48/pods.dmi'
	density = 1 //Dense. To raise the heat.
	opacity = 0

	anchored = 1
	unacidable = 1

	layer = 3.9
	infra_luminosity = 15

	var/mob/living/carbon/occupant
	var/mob/living/carbon/occupant2 //two seaters

	var/datum/spacepod/equipment/equipment_system

	var/battery_type = "/obj/item/weapon/stock_parts/cell/high"
	var/obj/item/weapon/stock_parts/cell/battery

	var/datum/gas_mixture/cabin_air
	var/obj/machinery/portable_atmospherics/canister/internal_tank
	var/use_internal_tank = 0
	var/datum/global_iterator/pr_int_temp_processor //normalizes internal air mixture temperature
	var/datum/global_iterator/pr_give_air //moves air from tank to cabin

	var/datum/effect/effect/system/ion_trail_follow/space_trail/ion_trail

	var/hatch_open = 0

	var/next_firetime = 0

	var/list/pod_overlays
	var/health = 250
	var/empcounter = 0 //Used for disabling movement when hit by an EMP

	var/lights = 0
	var/lights_power = 6
	var/list/icon_light_color = list("pod_civ" = LIGHT_COLOR_WHITE, \
									 "pod_mil" = "#BBF093", \
									 "pod_synd" = LIGHT_COLOR_RED, \
									 "pod_gold" = LIGHT_COLOR_WHITE, \
									 "pod_black" = "#3B8FE5", \
									 "pod_industrial" = "#CCCC00")

	var/allow2enter = 1

/obj/spacepod/New()
	. = ..()
	if(!pod_overlays)
		pod_overlays = new/list(2)
		pod_overlays[DAMAGE] = image(icon, icon_state="pod_damage")
		pod_overlays[FIRE] = image(icon, icon_state="pod_fire")
	bound_width = 64
	bound_height = 64
	dir = EAST
	battery = new battery_type(src)
	add_cabin()
	add_airtank()
	src.ion_trail = new /datum/effect/effect/system/ion_trail_follow/space_trail()
	src.ion_trail.set_up(src)
	src.ion_trail.start()
	src.use_internal_tank = 1
	pr_int_temp_processor = new /datum/global_iterator/pod_preserve_temp(list(src))
	pr_give_air = new /datum/global_iterator/pod_tank_give_air(list(src))
	equipment_system = new(src)
	spacepods_list += src

/obj/spacepod/Destroy()
	spacepods_list -= src
	return ..()

/obj/spacepod/process()
	if(src.empcounter > 0)
		src.empcounter--
	else
		processing_objects.Remove(src)


/obj/spacepod/proc/update_icons()
	if(!pod_overlays)
		pod_overlays = new/list(2)
		pod_overlays[DAMAGE] = image(icon, icon_state="pod_damage")
		pod_overlays[FIRE] = image(icon, icon_state="pod_fire")

	overlays.Cut()

	if(health <= round(initial(health)/2))
		overlays += pod_overlays[DAMAGE]
		if(health <= round(initial(health)/4))
			overlays += pod_overlays[FIRE]

	light_color = icon_light_color[src.icon_state]

/obj/spacepod/bullet_act(var/obj/item/projectile/P)
	if(P.damage && !P.nodamage)
		deal_damage(P.damage)
	else if(P.flag == "energy" && istype(P,/obj/item/projectile/ion)) //needed to make sure ions work properly
		empulse(src, 1, 1)

/obj/spacepod/blob_act()
	deal_damage(30)
	return

/obj/spacepod/attack_animal(mob/living/simple_animal/user as mob)
	if(user.melee_damage_upper == 0)
		user.emote("[user.friendly] [src]")
	else
		var/damage = rand(user.melee_damage_lower, user.melee_damage_upper)
		deal_damage(damage)
		visible_message("\red <B>[user]</B> [user.attacktext] [src]!")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked [src.name]</font>")
	return

/obj/spacepod/attack_alien(mob/user as mob)
	user.changeNext_move(CLICK_CD_MELEE)
	deal_damage(15)
	playsound(src.loc, 'sound/weapons/slash.ogg', 50, 1, -1)
	user << "\red You slash at \the [src]!"
	visible_message("\red The [user] slashes at [src.name]'s armor!")
	return

/obj/spacepod/proc/deal_damage(var/damage)
	var/oldhealth = health
	health = max(0, health - damage)
	var/percentage = (health / initial(health)) * 100
	if(occupant && oldhealth > health && percentage <= 25 && percentage > 0)
		var/sound/S = sound('sound/effects/engine_alert2.ogg')
		S.wait = 0 //No queue
		S.channel = 0 //Any channel
		S.volume = 50
		occupant << S
		if(occupant2)
			occupant2 << S
	if(occupant && oldhealth > health && !health)
		var/sound/S = sound('sound/effects/engine_alert1.ogg')
		S.wait = 0
		S.channel = 0
		S.volume = 50
		occupant << S
		if(occupant2)
			occupant2 << S
	if(!health)
		spawn(0)
			if(occupant)	occupant << "<span class='userdanger'>Critical damage to the vessel detected, core explosion imminent!</span>"
			if(occupant2)	occupant2 << "<span class='userdanger'>Critical damage to the vessel detected, core explosion imminent!</span>"

			for(var/i = 10, i >= 0; --i)
				if(occupant)	occupant << "<span class='warning'>[i]</span>"
				if(occupant2)	occupant2 << "<span class='warning'>[i]</span>"
				if(i == 0)
					explosion(loc, 2, 4, 8)
					qdel(src)
				sleep(10)

	update_icons()

/obj/spacepod/proc/repair_damage(var/repair_amount)
	if(health)
		health = min(initial(health), health + repair_amount)
		update_icons()


/obj/spacepod/ex_act(severity)
	switch(severity)
		if(1)
			var/mob/living/carbon/human/H = occupant
			var/mob/living/carbon/human/H2 = occupant2
			if(H)
				H.forceMove(get_turf(src))
				H.ex_act(severity + 1)
				H << "<span class='warning'>You are forcefully thrown from \the [src]!</span>"
			if(H2)
				H2.forceMove(get_turf(src))
				H2.ex_act(severity + 1)
				H2 << "<span class='warning'>You are forcefully thrown from \the [src]!</span>"
			qdel(ion_trail)
			qdel(src)
		if(2)
			deal_damage(100)
		if(3)
			if(prob(40))
				deal_damage(50)

/obj/spacepod/emp_act(severity)
	switch(severity)
		if(1)
			if(src.occupant)	src.occupant << "<span class='warning'>The pod console flashes 'Heavy EMP WAVE DETECTED'.</span>" //warn the occupants
			if(src.occupant2)	src.occupant2 << "<span class='warning'>The pod console flashes 'Heavy EMP WAVE DETECTED'.</span>" //warn the occupants

			if(battery)
				battery.charge = max(0, battery.charge - 5000) //Cell EMP act is too weak, this pod needs to be sapped.
			src.deal_damage(100)
			if(src.empcounter < 40)
				src.empcounter = 40 //Disable movement for 40 ticks. Plenty long enough.
			processing_objects.Add(src)

		if(2)
			if(src.occupant)	src.occupant << "<span class='warning'>The pod console flashes 'EMP WAVE DETECTED'.</span>" //warn the occupants
			if(src.occupant2)	src.occupant2 << "<span class='warning'>The pod console flashes 'EMP WAVE DETECTED'.</span>" //warn the occupants

			src.deal_damage(40)
			if(battery)
				battery.charge = max(0, battery.charge - 2500) //Cell EMP act is too weak, this pod needs to be sapped.
			if(src.empcounter < 20)
				src.empcounter = 20 //Disable movement for 20 ticks.
			processing_objects.Add(src)

/obj/spacepod/attackby(obj/item/W as obj, mob/user as mob, params)
	if(iscrowbar(W))
		hatch_open = !hatch_open
		playsound(loc, 'sound/items/Crowbar.ogg', 50, 1)
		user << "<span class='notice'>You [hatch_open ? "open" : "close"] the maintenance hatch.</span>"
	if(istype(W, /obj/item/weapon/stock_parts/cell))
		if(!hatch_open)
			user << "\red The maintenance hatch is closed!"
			return
		if(battery)
			user << "<span class='notice'>The pod already has a battery.</span>"
			return
		user.drop_item(W)
		battery = W
		W.forceMove(src)
		return
	if(istype(W, /obj/item/device/spacepod_equipment))
		if(!hatch_open)
			user << "\red The maintenance hatch is closed!"
			return
		if(!equipment_system)
			user << "<span class='warning'>The pod has no equipment datum, yell at pomf</span>"
			return
		if(istype(W, /obj/item/device/spacepod_equipment/weaponry))
			if(equipment_system.weapon_system)
				user << "<span class='notice'>The pod already has a weapon system, remove it first.</span>"
				return
			else
				user << "<span class='notice'>You insert \the [W] into the equipment system.</span>"
				user.drop_item(W)
				W.forceMove(src)
				equipment_system.weapon_system = W
				equipment_system.weapon_system.my_atom = src
				return

		if(istype(W, /obj/item/device/spacepod_equipment/misc))
			if(equipment_system.misc_system)
				user << "<span class='notice'>The pod already has a miscellaneous system, remove it first.</span>"
				return
			else
				user << "<span class='notice'>You insert \the [W] into the equipment system.</span>"
				user.drop_item(W)
				W.forceMove(src)
				equipment_system.misc_system = W
				equipment_system.misc_system.my_atom = src
				return

	if(istype(W, /obj/item/weapon/weldingtool))
		if(!hatch_open)
			user << "\red You must open the maintenance hatch before attempting repairs."
			return
		var/obj/item/weapon/weldingtool/WT = W
		if(!WT.isOn())
			user << "\red The welder must be on for this task."
			return
		if (health < initial(health))
			user << "\blue You start welding the spacepod..."
			playsound(loc, 'sound/items/Welder.ogg', 50, 1)
			if(do_after(user, 20, target = src))
				if(!src || !WT.remove_fuel(3, user)) return
				repair_damage(10)
				user << "\blue You mend some [pick("dents","bumps","damage")] with \the [WT]"
		else
			user << "\blue <b>\The [src] is fully repaired!</b>"


/obj/spacepod/attack_hand(mob/user as mob)
	if(!hatch_open)
		return ..()
	if(!equipment_system || !istype(equipment_system))
		user << "<span class='warning'>The pod has no equpment datum, or is the wrong type, yell at pomf.</span>"
		return
	var/list/possible = list()
	if(battery)
		possible.Add("Energy Cell")
	if(equipment_system.weapon_system)
		possible.Add("Weapon System")
	if(equipment_system.misc_system)
		possible.Add("Misc. System")
	/* Not yet implemented
	if(equipment_system.engine_system)
		possible.Add("Engine System")
	if(equipment_system.shield_system)
		possible.Add("Shield System")
	*/
	var/obj/item/device/spacepod_equipment/SPE
	switch(input(user, "Remove which equipment?", null, null) as null|anything in possible)
		if("Energy Cell")
			if(user.put_in_any_hand_if_possible(battery))
				user << "<span class='notice'>You remove \the [battery] from the space pod</span>"
				battery = null
		if("Weapon System")
			SPE = equipment_system.weapon_system
			if(user.put_in_any_hand_if_possible(SPE))
				user << "<span class='notice'>You remove \the [SPE] from the equipment system.</span>"
				SPE.my_atom = null
				equipment_system.weapon_system = null
			else
				user << "<span class='warning'>You need an open hand to do that.</span>"
		if("Misc. System")
			SPE = equipment_system.misc_system
			if(user.put_in_any_hand_if_possible(SPE))
				user << "<span class='notice'>You remove \the [SPE] from the equipment system.</span>"
				SPE.my_atom = null
				equipment_system.misc_system = null
			else
				user << "<span class='warning'>You need an open hand to do that.</span>"
		/*
		if("engine system")
			SPE = equipment_system.engine_system
			if(user.put_in_any_hand_if_possible(SPE))
				user << "<span class='notice'>You remove \the [SPE] from the equipment system.</span>"
				equipment_system.engine_system = null
			else
				user << "<span class='warning'>You need an open hand to do that.</span>"
		if("shield system")
			SPE = equipment_system.shield_system
			if(user.put_in_any_hand_if_possible(SPE))
				user << "<span class='notice'>You remove \the [SPE] from the equipment system.</span>"
				equipment_system.shield_system = null
			else
				user << "<span class='warning'>You need an open hand to do that.</span>"
		*/

	return

/obj/spacepod/civilian
	icon_state = "pod_civ"
	desc = "A sleek civilian space pod."

/obj/spacepod/random
	icon_state = "pod_civ"
// placeholder

/obj/spacepod/sec
	name = "\improper security spacepod"
	desc = "An armed security spacepod with reinforced armor plating."
	icon_state = "pod_mil"
	health = 400

/obj/spacepod/sec/New()
	..()
	var/obj/item/device/spacepod_equipment/weaponry/burst_taser/T = new /obj/item/device/spacepod_equipment/weaponry/taser
	T.loc = equipment_system
	equipment_system.weapon_system = T
	equipment_system.weapon_system.my_atom = src
	var/obj/item/device/spacepod_equipment/misc/tracker/L = new /obj/item/device/spacepod_equipment/misc/tracker
	L.loc = equipment_system
	equipment_system.misc_system = L
	equipment_system.misc_system.my_atom = src
	equipment_system.misc_system.enabled = 1
	return

/obj/spacepod/random/New()
	..()
	icon_state = pick("pod_civ", "pod_black", "pod_mil", "pod_synd", "pod_gold", "pod_industrial")
	switch(icon_state)
		if("pod_civ")
			desc = "A sleek civilian space pod."
		if("pod_black")
			desc = "An all black space pod with no insignias."
		if("pod_mil")
			desc = "A dark grey space pod brandishing the Nanotrasen Military insignia"
		if("pod_synd")
			desc = "A menacing military space pod with Fuck NT stenciled onto the side"
		if("pod_gold")
			desc = "A civilian space pod with a gold body, must have cost somebody a pretty penny"
		if("pod_industrial")
			desc = "A rough looking space pod meant for industrial work"
	update_icons()

/obj/spacepod/verb/toggle_internal_tank()
	set name = "Toggle internal airtank usage"
	set category = "Spacepod"
	set src = usr.loc
	set popup_menu = 0
	if(usr!=src.occupant)
		return
	use_internal_tank = !use_internal_tank
	src.occupant << "<span class='notice'>Now taking air from [use_internal_tank?"internal airtank":"environment"].</span>"
	return

/obj/spacepod/proc/add_cabin()
	cabin_air = new
	cabin_air.temperature = T20C
	cabin_air.volume = 200
	cabin_air.oxygen = O2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature)
	cabin_air.nitrogen = N2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature)
	return cabin_air

/obj/spacepod/proc/add_airtank()
	internal_tank = new /obj/machinery/portable_atmospherics/canister/air(src)
	return internal_tank

/obj/spacepod/proc/get_turf_air()
	var/turf/T = get_turf(src)
	if(T)
		. = T.return_air()
	return

/obj/spacepod/remove_air(amount)
	if(use_internal_tank)
		return cabin_air.remove(amount)
	else
		var/turf/T = get_turf(src)
		if(T)
			return T.remove_air(amount)
	return

/obj/spacepod/return_air()
	if(use_internal_tank)
		return cabin_air
	return get_turf_air()

/obj/spacepod/proc/return_pressure()
	. = 0
	if(use_internal_tank)
		. =  cabin_air.return_pressure()
	else
		var/datum/gas_mixture/t_air = get_turf_air()
		if(t_air)
			. = t_air.return_pressure()
	return

/obj/spacepod/proc/return_temperature()
	. = 0
	if(use_internal_tank)
		. = cabin_air.return_temperature()
	else
		var/datum/gas_mixture/t_air = get_turf_air()
		if(t_air)
			. = t_air.return_temperature()
	return

/obj/spacepod/proc/moved_inside(var/mob/living/carbon/human/H as mob)
	var/fukkendisk = usr.GetTypeInAllContents(/obj/item/weapon/disk/nuclear)
	if(fukkendisk)
		usr << "\red <B>The nuke-disk locks the door as you try to get in. You evil person.</b>"
		return

	if(H && H.client && H in range(1))
		if(src.occupant && src.occupant2)
			H << "<span class='notice'>[src.name] is full.</span>"
			return

		if(src.occupant && !src.occupant2)
			if(src.occupant == H)
				H.visible_message("You climb over the console and drop down into the secondary seat.")
			H.reset_view(src)
			H.stop_pulling()
			H.forceMove(src)
			if(src.occupant == H)	occupant = null
			src.occupant2 = H
			src.add_fingerprint(H)
			src.forceMove(src.loc)
			playsound(src, 'sound/machines/windowdoor.ogg', 50, 1)
			return 1

		else
			if(!src.occupant)
				H.reset_view(src)
				H.stop_pulling()
				H.forceMove(src)
				src.occupant = H
				src.add_fingerprint(H)
				src.forceMove(src.loc)
				playsound(src, 'sound/machines/windowdoor.ogg', 50, 1)
				return 1
			else
				return
	else
		return 0

/obj/spacepod/proc/moved_other_inside(var/mob/living/carbon/human/H as mob)
	if(!src.occupant2)
		H.reset_view(src)
		H.stop_pulling()
		H.forceMove(src)
		src.occupant2 = H
		src.forceMove(src.loc)
		playsound(src, 'sound/machines/windowdoor.ogg', 50, 1)
		return 1
	else
		return



/obj/spacepod/MouseDrop_T(mob/M as mob, mob/user as mob)
	if(!isliving(M)) return

	if(M != user && M.stat == DEAD && allow2enter)
		if(src.occupant2 && !src.occupant)
			usr << "<span class='danger'><b>You can't put a corpse into the driver's seat!</b></span>"
			return
		if(!src.occupant2)
			visible_message("<span class='danger'>[user.name] starts loading [M.name] into the pod!</span>")
			sleep(10)
			moved_other_inside(M)

	if(M == user)
		move_inside(user)


/obj/spacepod/verb/move_inside(var/mob/user)
	set category = "Object"
	set name = "Enter Pod"
	set src in oview(1)
	var/fukkendisk = usr.GetTypeInAllContents(/obj/item/weapon/disk/nuclear)

	if(user.restrained() || user.stat || user.weakened || user.stunned || user.paralysis || user.resting) //are you cuffed, dying, lying, stunned or other
		return
	if (!ishuman(user)) return

	if(fukkendisk)
		user << "<span class='warning'><B>The nuke-disk is locking the door every time you try to open it. You get the feeling that it doesn't want to go into the spacepod.</b></span>"
		return

	for(var/mob/living/carbon/slime/S in range(1,usr))
		if(S.Victim == user)
			user << "You're too busy getting your life sucked out of you."
			return

	try_user_enter(user)

/obj/spacepod/proc/try_user_enter(var/mob/user)
	if(!src.occupant && !src.occupant2)
		visible_message("<span class='notice'>[user] starts to climb into [src.name]</span>")
		if(enter_after(40,user))
			if(!src.occupant)
				moved_inside(user)
			else if(src.occupant != user)
				user << "<span class='notice'>[src.occupant] was faster. Try better next time, loser.</span>"
		else	user << "<span class='notice'>You stop entering the spacepod.</span>"
		return

	if(!allow2enter)
		user << "<span class='danger'>The door is locked!</span>"
		return

	if(occupant && occupant2)
		user << "<span class='danger'>You can't fit in \the [src], it's full!</span>"
		return

	if(occupant && !occupant2)
		user << "<span class='notice'><b>You start climbing into the passenger bay.</b></span>"
		user_enter(user)

	if(!occupant && occupant2)
		user << "<span class='notice'><b>You start climbing into the pilot's seat.</b></span>"
		user_enter(user)

/obj/spacepod/proc/user_enter(var/mob/user)
	visible_message("<span class='notice'>[user] starts to climb into \the [src.name].</span>")
	if(enter_after(40,user))
		moved_inside(user)
	else
		user << "You stop entering the spacepod."

/obj/spacepod/verb/exit_pod()
	set name = "Exit pod"
	set category = "Spacepod"
	set src = usr.loc

	var/mob/user = usr
	var/spos = 0
	if(!ismob(user))	return

	if(occupant == user)	spos = 1
	if(occupant2 == user)	spos = 2

	switch(spos)
		if(0)	return
		if(1)
			if(occupant2)	occupant2 << "<span class='notice'>[occupant.name] climbs out of the pod!</span>"
			occupant.forceMove(src.loc)
			occupant = null
			user << "<span class='notice'>You climb out of \the [src].</span>"
		if(2)
			if(occupant)	occupant << "<span class='notice'>[occupant2.name] climbs out of the pod!</span>"
			occupant2.forceMove(src.loc)
			occupant2 = null
			user << "<span class='notice'>You climb out of \the [src].</span>"

/obj/spacepod/verb/exit_pod2()
	set name = "Eject Secondary Seat"
	set category = "Spacepod"
	set src = usr.loc

	if(!occupant2)
		usr << "<span class='notice'>There is no one in the second seat.</span>"
		return

	if(usr == occupant2)
		usr << "<span class='notice'>How do you plan to do that? The eject button is out of reach.</span>"
		return

	if(usr == occupant)
		usr << "<span class='notice'>You eject [occupant2.name].</span>"
		occupant2 << "<span class='danger'>\The [src] ejects you forcefully!</span>"
		inertia_dir = 0
		occupant2.forceMove(src.loc)
		occupant2 = null

/obj/spacepod/verb/locksecondseat()
	set name = "Lock Doors"
	set category = "Spacepod"
	set src = usr.loc

	if(CheckIfOccupant2(usr))
		if(!allow2enter)
			usr << "<span class='notice'>You can't [allow2enter ? "lock" : "unlock"] the doors from your seat.</span>"
			return

	allow2enter = !allow2enter
	usr << "<span class='warning'>You [allow2enter ? "unlock" : "lock"] the doors.</span>"


/obj/spacepod/verb/toggleDoors()
	set name = "Toggle Nearby Pod Doors"
	set category = "Spacepod"
	set src = usr.loc

	var/list/pod_door_types = list(/obj/machinery/door/poddoor/two_tile_hor/, /obj/machinery/door/poddoor/two_tile_ver/, \
									/obj/machinery/door/poddoor/three_tile_hor, /obj/machinery/door/poddoor/three_tile_ver, \
									/obj/machinery/door/poddoor/four_tile_hor, /obj/machinery/door/poddoor/four_tile_ver)

	if(CheckIfOccupant2(usr))	return
	for(var/obj/machinery/door/poddoor/P in orange(3,src))
		if(is_type_in_list(P,pod_door_types))
			var/mob/living/carbon/human/L = usr
			if(P.check_access(L.get_active_hand()) || P.check_access(L.wear_id))
				if(P.density)
					P.open()
					return 1
				else
					P.close()
					return 1
			usr << "<span class='warning'>Access denied.</span>"
			return

	usr << "<span class='warning'>You are not close to any pod doors.</span>"
	return


/obj/spacepod/verb/fireWeapon()
	if(!CheckIfOccupant2(usr))
		set name = "Fire Pod Weapons"
		set desc = "Fire the weapons."
		set category = "Spacepod"
		set src = usr.loc
		if(!equipment_system.weapon_system)
			usr << "<span class='warning'>\The [src] has no weapons!</span>"
			return
		equipment_system.weapon_system.fire_weapons()

obj/spacepod/verb/toggleLights()
	set name = "Toggle Lights"
	set category = "Spacepod"
	set src = usr.loc
	if(!CheckIfOccupant2(usr))
		lightsToggle()

/obj/spacepod/proc/lightsToggle()
	lights = !lights
	if(lights)
		set_light(lights_power)
	else
		set_light(0)
	occupant << "Toggled lights [lights ? "on" : "off"]."
	return

/obj/spacepod/proc/enter_after(delay as num, var/mob/user as mob, var/numticks = 5)
	var/delayfraction = delay/numticks

	var/turf/T = user.loc

	for(var/i = 0, i<numticks, i++)
		sleep(delayfraction)
		if(!src || !user || !user.canmove || !(user.loc == T))
			return 0

	return 1

/datum/global_iterator/pod_preserve_temp  //normalizing cabin air temperature to 20 degrees celsium
	delay = 20

	process(var/obj/spacepod/spacepod)
		if(spacepod.cabin_air && spacepod.cabin_air.return_volume() > 0)
			var/delta = spacepod.cabin_air.temperature - T20C
			spacepod.cabin_air.temperature -= max(-10, min(10, round(delta/4,0.1)))
		return

/datum/global_iterator/pod_tank_give_air
	delay = 15

	process(var/obj/spacepod/spacepod)
		if(spacepod && spacepod.internal_tank)
			var/datum/gas_mixture/tank_air = spacepod.internal_tank.return_air()
			var/datum/gas_mixture/cabin_air = spacepod.cabin_air

			var/release_pressure = ONE_ATMOSPHERE
			var/cabin_pressure = cabin_air.return_pressure()
			var/pressure_delta = min(release_pressure - cabin_pressure, (tank_air.return_pressure() - cabin_pressure)/2)
			var/transfer_moles = 0
			if(pressure_delta > 0) //cabin pressure lower than release pressure
				if(tank_air.return_temperature() > 0)
					transfer_moles = pressure_delta*cabin_air.return_volume()/(cabin_air.return_temperature() * R_IDEAL_GAS_EQUATION)
					var/datum/gas_mixture/removed = tank_air.remove(transfer_moles)
					cabin_air.merge(removed)
			else if(pressure_delta < 0) //cabin pressure higher than release pressure
				var/datum/gas_mixture/t_air = spacepod.get_turf_air()
				pressure_delta = cabin_pressure - release_pressure
				if(t_air)
					pressure_delta = min(cabin_pressure - t_air.return_pressure(), pressure_delta)
				if(pressure_delta > 0) //if location pressure is lower than cabin pressure
					transfer_moles = pressure_delta*cabin_air.return_volume()/(cabin_air.return_temperature() * R_IDEAL_GAS_EQUATION)
					var/datum/gas_mixture/removed = cabin_air.remove(transfer_moles)
					if(t_air)
						t_air.merge(removed)
					else //just delete the cabin gas, we're in space or some shit
						qdel(removed)
		else
			return stop()
		return

/obj/spacepod/relaymove(mob/user, direction)
	if(!CheckIfOccupant2(user))
		handlerelaymove(user, direction)

/obj/spacepod/proc/handlerelaymove(mob/user, direction)
	var/moveship = 1
	if(battery && battery.charge >= 3 && health && empcounter == 0)
		src.dir = direction
		switch(direction)
			if(NORTH)
				if(inertia_dir == SOUTH)
					inertia_dir = 0
					moveship = 0
			if(SOUTH)
				if(inertia_dir == NORTH)
					inertia_dir = 0
					moveship = 0
			if(EAST)
				if(inertia_dir == WEST)
					inertia_dir = 0
					moveship = 0
			if(WEST)
				if(inertia_dir == EAST)
					inertia_dir = 0
					moveship = 0
		if(moveship)
			Move(get_step(src, direction), direction)
	else
		if(!battery)
			user << "<span class='warning'>No energy cell detected.</span>"
		else if(battery.charge < 3)
			user << "<span class='warning'>Not enough charge left.</span>"
		else if(!health)
			user << "<span class='warning'>She's dead, Jim</span>"
		else if(empcounter != 0)
			user << "<span class='warning'>The pod control interface isn't responding. The console indicates [empcounter] seconds before reboot.</span>"
		else
			user << "<span class='warning'>Unknown error has occurred, yell at pomf.</span>"
		return 0
	battery.charge = max(0, battery.charge - 3)

/obj/spacepod/proc/CheckIfOccupant2(mob/user)
	if(!src.occupant2)
		return 0
	if(src.occupant2)
		if(user == src.occupant2)
			return 1
		else
			return 0

/obj/effect/landmark/spacepod/random
	name = "spacepod spawner"
	invisibility = 101
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x"
	anchored = 1

/obj/effect/landmark/spacepod/random/New()
	..()

#undef DAMAGE
#undef FIRE
