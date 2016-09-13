/obj/item/weapon/gun/energy/gun
	name = "energy gun"
	desc = "A basic energy-based gun with two settings: kill and disable."
	icon_state = "energy"
	item_state = null	//so the human update icon uses the icon_state instead.
	ammo_type = list(/obj/item/ammo_casing/energy/disabler, /obj/item/ammo_casing/energy/laser)
	origin_tech = "combat=3;magnets=2"
	modifystate = 2
	can_flashlight = 1
	ammo_x_offset = 3
	flight_x_offset = 15
	flight_y_offset = 10

/obj/item/weapon/gun/energy/gun/cyborg
	desc = "An energy-based laser gun that draws power from the cyborg's internal energy cell directly. So this is what freedom looks like?"

/obj/item/weapon/gun/energy/gun/cyborg/newshot()
	..()
	robocharge()

/obj/item/weapon/gun/energy/gun/cyborg/emp_act()
	return

/obj/item/weapon/gun/energy/gun/mounted
	name = "mounted energy gun"
	selfcharge = 1
	use_external_power = 1

/obj/item/weapon/gun/energy/gun/mini
	name = "miniature energy gun"
	desc = "A small, pistol-sized energy gun with a built-in flashlight. It has two settings: stun and kill."
	icon_state = "mini"
	item_state = "gun"
	w_class = 2
	ammo_x_offset = 2
	charge_sections = 3
	can_flashlight = 0 // Can't attach or detach the flashlight, and override it's icon update

/obj/item/weapon/gun/energy/gun/mini/New()
	F = new /obj/item/device/flashlight/seclite(src)
	..()
	power_supply.maxcharge = 6000
	power_supply.charge = 6000

/obj/item/weapon/gun/energy/gun/mini/update_icon()
	..()
	if(F && F.on)
		overlays += "mini-light"

/obj/item/weapon/gun/energy/gun/hos
	name = "\improper X-01 MultiPhase Energy Gun"
	desc = "This is a expensive, modern recreation of a antique laser gun. This gun has several unique firemodes, but lacks the ability to recharge over time."
	icon_state = "hoslaser"
	force = 10
	ammo_type = list(/obj/item/ammo_casing/energy/electrode/hos, /obj/item/ammo_casing/energy/laser/hos, /obj/item/ammo_casing/energy/disabler)
	ammo_x_offset = 4

/obj/item/weapon/gun/energy/gun/blueshield
	name = "advanced stun revolver"
	desc = "An advanced stun revolver with the capacity to shoot both electrodes and lasers."
	icon_state = "bsgun"
	item_state = "gun"
	force = 7
	ammo_type = list(/obj/item/ammo_casing/energy/electrode/hos, /obj/item/ammo_casing/energy/laser/hos)
	ammo_x_offset = 1
	shaded_charge = 1

/obj/item/weapon/gun/energy/gun/turret
	name = "hybrid turret gun"
	desc = "A heavy hybrid energy cannon with two settings: Stun and kill."
	icon_state = "turretlaser"
	item_state = "turretlaser"
	slot_flags = null
	w_class = 5
	ammo_type = list(/obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/laser)
	weapon_weight = WEAPON_MEDIUM
	can_flashlight = 0
	trigger_guard = TRIGGER_GUARD_NONE
	ammo_x_offset = 2

/obj/item/weapon/gun/energy/gun/nuclear
	name = "advanced energy gun"
	desc = "An energy gun with an experimental miniaturized nuclear reactor that automatically charges the internal power cell."
	icon_state = "nucgun"
	item_state = "nucgun"
	origin_tech = "combat=3;materials=5;powerstorage=3"
	var/fail_tick = 0
	charge_delay = 5
	can_charge = 0
	ammo_x_offset = 1
	ammo_type = list(/obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/laser, /obj/item/ammo_casing/energy/disabler)
	selfcharge = 1

/obj/item/weapon/gun/energy/gun/nuclear/process()
	if(fail_tick > 0)
		fail_tick--
	..()

/obj/item/weapon/gun/energy/gun/nuclear/shoot_live_shot()
	failcheck()
	update_icon()
	..()

/obj/item/weapon/gun/energy/gun/nuclear/proc/failcheck()
	if(!prob(reliability) && istype(loc, /mob/living))
		var/mob/living/M = loc
		switch(fail_tick)
			if(0 to 200)
				fail_tick += (2*(100-reliability))
				M.apply_effect(rand(3,120), IRRADIATE)
				to_chat(M, "<span class='userdanger'>Your [name] feels warmer.</span>")
			if(201 to INFINITY)
				processing_objects.Remove(src)
				M.apply_effect(300, IRRADIATE)
				crit_fail = 1
				to_chat(M, "<span class='userdanger'>Your [name]'s reactor overloads!</span>")

/obj/item/weapon/gun/energy/gun/nuclear/emp_act(severity)
	..()
	reliability = max(reliability - round(15/severity), 0) //Do not allow it to go negative!

/obj/item/weapon/gun/energy/gun/nuclear/update_icon()
	..()
	if(crit_fail)
		overlays += "[icon_state]_fail_3"
	else
		switch(fail_tick)
			if(0)
				overlays += "[icon_state]_fail_0"
			if(1 to 150)
				overlays += "[icon_state]_fail_1"
			if(151 to INFINITY)
				overlays += "[icon_state]_fail_2"
