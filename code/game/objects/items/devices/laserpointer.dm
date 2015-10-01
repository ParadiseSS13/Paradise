/obj/item/device/laser_pointer
	name = "laser pointer"
	desc = "Don't shine it in your eyes!"
	icon = 'icons/obj/device.dmi'
	icon_state = "pointer"
	item_state = "pen"
	var/pointer_icon_state
	flags = CONDUCT
	slot_flags = SLOT_BELT
	materials = list(MAT_METAL=500, MAT_GLASS=500)
	w_class = 2 //Increased to 2, because diodes are w_class 2. Conservation of matter.
	origin_tech = "combat=1"
	origin_tech = "magnets=2"
	var/turf/pointer_loc
	var/energy = 5
	var/max_energy = 5
	var/effectchance = 33
	var/recharging = 0
	var/recharge_locked = 0
	var/obj/item/weapon/stock_parts/micro_laser/diode //used for upgrading!


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
		pointer_icon_state = pick("red_laser","green_laser","blue_laser","purple_laser")

/obj/item/device/laser_pointer/upgraded/New()
	..()
	diode = new /obj/item/weapon/stock_parts/micro_laser/ultra



/obj/item/device/laser_pointer/attack(mob/living/M, mob/user)
	laser_act(M, user)

/obj/item/device/laser_pointer/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/weapon/stock_parts/micro_laser))
		if(!diode)
			user.drop_item()
			W.loc = src
			diode = W
			user << "<span class='notice'>You install a [diode.name] in [src].</span>"
		else
			user << "<span class='notice'>[src] already has a cell.</span>"

	else if(istype(W, /obj/item/weapon/screwdriver))
		if(diode)
			user << "<span class='notice'>You remove the [diode.name] from the [src].</span>"
			diode.loc = get_turf(src.loc)
			diode = null
			return
		..()
	return

/obj/item/device/laser_pointer/afterattack(var/atom/target, var/mob/living/user, flag, params)
	if(flag)	//we're placing the object on a table or in backpack
		return
	laser_act(target, user, params)

/obj/item/device/laser_pointer/proc/laser_act(var/atom/target, var/mob/living/user, var/params)
	if( !(user in (viewers(7,target))) )
		return
	if (!diode)
		user << "<span class='notice'>You point [src] at [target], but nothing happens!</span>"
		return
	if (!user.IsAdvancedToolUser())
		user << "<span class='warning'>You don't have the dexterity to do this!</span>"
		return

	add_fingerprint(user)

	//nothing happens if the battery is drained
	if(recharge_locked)
		user << "<span class='notice'>You point [src] at [target], but it's still charging.</span>"
		return

	var/outmsg
	var/turf/targloc = get_turf(target)

	//human/alien mobs
	if(iscarbon(target))
		if(user.zone_sel.selecting == "eyes")
			var/mob/living/carbon/C = target

			//20% chance to actually hit the eyes

			if(prob(effectchance * diode.rating))
				add_logs(C, user, "shone in the eyes", object="laser pointer")


				//eye target check
				outmsg = "<span class='notice'>You blind [C] by shining [src] in their eyes.</span>"
				if(C.weakeyes)
					C.Stun(1)
				var/eye_prot = C.eyecheck()
				if(C.blinded || eye_prot >= 2)
					eye_prot = 4
				var/severity = 3 - eye_prot
				if(prob(33))
					severity += 1
				else if(prob(50))
					severity -= 1
				severity = min(max(severity, 0), 4)
				var/mob/living/carbon/human/H = C
				var/obj/item/organ/eyes/E = H.internal_organs_by_name["eyes"]

				switch(severity)
					if(0)
						//no effect
						C << "<span class='info'>A small, bright dot appears in your vision.</span>"
					if(1)
						//industrial grade eye protection
						E.damage += rand(0, 2)
						C << "<span class='notice'>Something bright flashes in the corner of your vision!</span>"
					if(2)
						//basic eye protection (sunglasses)
						flick("flash", C.flash)
						E.damage += rand(1, 6)
						C << "<span class='danger'>Your eyes were blinded!</span>"
					if(3)
						//no eye protection
						if(prob(2))
							C.Weaken(1)
						flick("e_flash", C.flash)
						E.damage += rand(3, 7)
						C << "<span class='danger'>Your eyes were blinded!</span>"
					if(4)
						//the effect has been worsened by something
						if(prob(5))
							C.Weaken(1)
						flick("e_flash", C.flash)
						E.damage += rand(5, 10)
						C << "<span class='danger'>Your eyes were blinded!</span>"
			else
				outmsg = "<span class='notice'>You fail to blind [C] by shining [src] at their eyes.</span>"

	//robots and AI
	else if(issilicon(target))
		var/mob/living/silicon/S = target
		//20% chance to actually hit the sensors
		if(prob(effectchance * diode.rating))
			S.Weaken(rand(5,10))
			S << "<span class='warning'>Your sensors were overloaded by a laser!</span>"
			outmsg = "<span class='notice'>You overload [S] by shining [src] at their sensors.</span>"

			S.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has had a laser pointer shone in their eyes by [user.name] ([user.ckey])</font>")
			user.attack_log += text("\[[time_stamp()]\] <font color='orange'>Shone a laser pointer in the eyes of [S.name] ([S.ckey])</font>")
			log_attack("<font color='orange'>[user.name] ([user.ckey]) Shone a laser pointer in the eyes of [S.name] ([S.ckey])</font>")
		else
			outmsg = "<span class='notice'>You fail to overload [S] by shining [src] at their sensors.</span>"

	//cameras
	else if(istype(target, /obj/machinery/camera))
		var/obj/machinery/camera/C = target
		if(prob(effectchance * diode.rating))
			C.emp_act(1)
			outmsg = "<span class='notice'>You hit the lens of [C] with [src], temporarily disabling the camera!</span>"

			log_admin("\[[time_stamp()]\] [user.name] ([user.ckey]) EMPd a camera with a laser pointer")
			user.attack_log += text("\[[time_stamp()]\] [user.name] ([user.ckey]) EMPd a camera with a laser pointer")
		else
			outmsg = "<span class='info'>You missed the lens of [C] with [src].</span>"

	//laser pointer image
	icon_state = "pointer_[pointer_icon_state]"
	var/list/showto = list()
	for(var/mob/M in viewers(7,targloc))
		if(M.client)
			showto.Add(M.client)
	var/image/I = image('icons/obj/projectiles.dmi',targloc,pointer_icon_state,10)
	var/list/click_params = params2list(params)
	if(click_params)
		if(click_params["icon-x"])
			I.pixel_x = (text2num(click_params["icon-x"]) - 16)
		if(click_params["icon-y"])
			I.pixel_y = (text2num(click_params["icon-y"]) - 16)
	else
		I.pixel_x = target.pixel_x + rand(-5,5)
		I.pixel_y = target.pixel_y + rand(-5,5)

	if(outmsg)
		user << outmsg
	else
		user << "<span class='info'>You point [src] at [target].</span>"

	energy -= 1
	if(energy <= max_energy)
		if(!recharging)
			recharging = 1
			processing_objects.Add(src)
		if(energy <= 0)
			user << "<span class='warning'>You've overused the battery of [src], now it needs time to recharge!</span>"
			recharge_locked = 1

	flick_overlay(I, showto, 10)
	icon_state = "pointer"

/obj/item/device/laser_pointer/process()
	if(prob(20 - recharge_locked*5))
		energy += 1
		if(energy >= max_energy)
			energy = max_energy
			recharging = 0
			recharge_locked = 0
			..()