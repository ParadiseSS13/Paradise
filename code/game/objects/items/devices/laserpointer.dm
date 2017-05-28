/obj/item/device/laser_pointer
	name = "laser pointer"
	desc = "Don't shine it in your eyes!"
	icon = 'icons/obj/device.dmi'
	icon_state = "pointer"
	item_state = "pen"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	materials = list(MAT_METAL=500, MAT_GLASS=500)
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "combat=1;magnets=2"
	var/pointer_icon_state = ""
	var/energy = 5
	var/max_energy = 5
	var/effectiveness = 33
	var/total_effectiveness = 0
	var/recharging = 0
	var/recharge_locked = 0
	var/obj/item/weapon/stock_parts/micro_laser/diode = null //used for upgrading!

/obj/item/device/laser_pointer/red
	pointer_icon_state = "red_laser"

/obj/item/device/laser_pointer/green
	pointer_icon_state = "green_laser"

/obj/item/device/laser_pointer/blue
	pointer_icon_state = "blue_laser"

/obj/item/device/laser_pointer/purple
	pointer_icon_state = "purple_laser"

/obj/item/device/laser_pointer/New()
	..()
	diode = new(src)
	if(!pointer_icon_state)
		pointer_icon_state = pick("red_laser", "green_laser", "blue_laser", "purple_laser")
	update_strength()

/obj/item/device/laser_pointer/Destroy()
	QDEL_NULL(diode)
	return ..()

/obj/item/device/laser_pointer/upgraded/New()
	..()
	QDEL_NULL(diode)
	diode = new /obj/item/weapon/stock_parts/micro_laser/ultra
	update_strength()

/obj/item/device/laser_pointer/process()
	if(prob(20 - recharge_locked*5))
		energy = min(energy+1, max_energy)
		if(energy >= max_energy)
			recharging = 0
			recharge_locked = 0
			..()

/obj/item/device/laser_pointer/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/weapon/stock_parts/micro_laser))
		if(!diode)
			user.drop_item()
			W.forceMove(src)
			diode = W
			to_chat(user, "<span class='notice'>You install a [diode] in [src].</span>")
			update_strength()
		else
			to_chat(user, "<span class='notice'>[src] already has a diode.</span>")

	if(isscrewdriver(W))
		if(diode)
			to_chat(user, "<span class='notice'>You remove the [diode.name] from the [src].</span>")
			diode.forceMove(get_turf(src))
			diode = null
			update_strength()
	else
		return ..()

/obj/item/device/laser_pointer/proc/update_strength()
	total_effectiveness =  min(effectiveness * (diode ? diode.rating : 0), 100)

/obj/item/device/laser_pointer/proc/laser_worthy(atom/target, mob/living/user)
	if(!(user in (viewers(7, target))))
		return 0
	if(!diode)
		to_chat(user, "<span class='notice'>You point [src] at [target], but nothing happens!</span>")
		return 0
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return 0
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if((HULK in H.mutations) || (H.species.flags & NOGUNS))
			to_chat(user, "<span class='warning'>Your fingers can't press the button!</span>")
			return 0

	//nothing happens if the battery is drained
	if(recharge_locked)
		to_chat(user, "<span class='notice'>You point [src] at [target], but it's still charging.</span>")
		return 0

	add_fingerprint(user)
	return 1

/obj/item/device/laser_pointer/proc/check_energy(mob/living/user)
	energy -= 1
	if(energy <= max_energy)
		if(!recharging)
			recharging = 1
			processing_objects.Add(src)
		if(energy <= 0)
			to_chat(user, "<span class='warning'>You've overused the battery of [src], now it needs time to recharge!</span>")
			recharge_locked = 1
	spawn(10)
		icon_state = "pointer"

/obj/item/device/laser_pointer/proc/lase_target(atom/target, mob/living/user, params)
	if(!laser_worthy(target, user))
		return
	icon_state = "pointer_[pointer_icon_state]"
	target.laser_act(user, src, params, total_effectiveness)
	check_energy(user)

/obj/item/device/laser_pointer/attack(mob/living/M, mob/living/user)
	lase_target(M, user)

/obj/item/device/laser_pointer/afterattack(atom/target, mob/living/user, flag, params)
	if(flag)	//we're placing the object on a table or in backpack
		return
	lase_target(target, user, params)



/mob/living/carbon/laser_act(mob/living/user, obj/item/device/laser_pointer/LP, params, severity)
	..()
	if(user.zone_sel.selecting == "eyes")
		add_logs(user, src, "shone in the eyes", object = "laser pointer")

		var/impact = 1
		if(prob(33))
			impact = 2
		else if(prob(50))
			impact = 0

		//20% chance to actually hit the eyes
		if(prob(severity) && flash_eyes(impact))
			to_chat(user, "<span class='notice'>You blind [src] by shining [LP] in their eyes.</span>")
			if(weakeyes)
				Stun(1)
		else
			to_chat(user, "<span class='warning'>You fail to blind [src] by shining [LP] at their eyes!</span>")


/mob/living/silicon/laser_act(mob/living/user, obj/item/device/laser_pointer/LP, params, severity)
	..()
	if(prob(severity))
		flash_eyes(affect_silicon = 1)
		Weaken(rand(5, 10))
		to_chat(src, "<span class='warning'>Your sensors were overloaded by a laser!</span>")
		to_chat(user, "<span class='notice'>You overload [src] by shining [LP] at their sensors.</span>")

		create_attack_log("<font color='orange'>Has had a laser pointer shone in their eyes by [user.name] ([user.ckey])</font>")
		user.create_attack_log("<font color='orange'>Shone a laser pointer in the eyes of [name] ([ckey])</font>")
		log_attack("<font color='orange'>[user.name] ([user.ckey]) Shone a laser pointer in the eyes of [name] ([ckey])</font>")
	else
		to_chat(user, "<span class='notice'>You fail to overload [src] by shining the laser at their sensors.</span>")


/obj/machinery/camera/laser_act(mob/living/user, obj/item/device/laser_pointer/LP, params, severity)
	..()
	if(prob(severity))
		emp_act(1)
		to_chat(user, "<span class='notice'>You hit the lens of [src] with [LP], temporarily disabling the camera!</span>")

		log_admin("\[[time_stamp()]\] [user.name] ([user.ckey]) EMPd a camera with a laser pointer")
		user.create_attack_log("[user.name] ([user.ckey]) EMPd a camera with a laser pointer")
	else
		to_chat(user, "<span class='info'>You missed the lens of [src] with [LP].</span>")


/atom/proc/laser_act(mob/living/user, obj/item/device/laser_pointer/LP, params, severity)
	//laser pointer image
	var/turf/targloc = get_turf(src)
	var/image/I = image('icons/obj/projectiles.dmi', targloc, LP.pointer_icon_state, 10)
	var/list/click_params = params2list(params)
	if(click_params)
		if(click_params["icon-x"])
			I.pixel_x = (text2num(click_params["icon-x"]) - 16)
		if(click_params["icon-y"])
			I.pixel_y = (text2num(click_params["icon-y"]) - 16)
	else
		I.pixel_x = pixel_x + rand(-5, 5)
		I.pixel_y = pixel_y + rand(-5, 5)

	to_chat(user, "<span class='info'>You point [LP] at [src].</span>")

	flick_overlay_view(I, targloc, 10)