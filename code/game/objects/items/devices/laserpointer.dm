/obj/item/laser_pointer
	name = "laser pointer"
	desc = "Don't shine it in your eyes!"
	icon = 'icons/obj/device.dmi'
	icon_state = "pointer"
	item_state = "pen"
	var/pointer_icon_state
	flags = CONDUCT
	slot_flags = SLOT_BELT
	materials = list(MAT_METAL=500, MAT_GLASS=500)
	w_class = WEIGHT_CLASS_SMALL //Increased to 2, because diodes are w_class 2. Conservation of matter.
	origin_tech = "combat=1;magnets=2"
	var/energy = 5
	var/max_energy = 5
	var/effectchance = 33
	var/recharging = 0
	var/recharge_locked = 0
	var/obj/item/stock_parts/micro_laser/diode //used for upgrading!


/obj/item/laser_pointer/red
	pointer_icon_state = "red_laser"
/obj/item/laser_pointer/green
	pointer_icon_state = "green_laser"
/obj/item/laser_pointer/blue
	pointer_icon_state = "blue_laser"
/obj/item/laser_pointer/purple
	pointer_icon_state = "purple_laser"

/obj/item/laser_pointer/New()
	..()
	diode = new(src)
	if(!pointer_icon_state)
		pointer_icon_state = pick("red_laser","green_laser","blue_laser","purple_laser")

/obj/item/laser_pointer/Destroy()
	QDEL_NULL(diode)
	return ..()

/obj/item/laser_pointer/upgraded/New()
	..()
	diode = new /obj/item/stock_parts/micro_laser/ultra



/obj/item/laser_pointer/attack(mob/living/M, mob/user)
	laser_act(M, user)

/obj/item/laser_pointer/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stock_parts/micro_laser))
		if(!diode)
			user.drop_item()
			W.loc = src
			diode = W
			to_chat(user, "<span class='notice'>You install a [diode.name] in [src].</span>")
		else
			to_chat(user, "<span class='notice'>[src] already has a cell.</span>")

	else if(istype(W, /obj/item/screwdriver))
		if(diode)
			to_chat(user, "<span class='notice'>You remove the [diode.name] from the [src].</span>")
			diode.loc = get_turf(src.loc)
			diode = null
			return
		..()
	return

/obj/item/laser_pointer/afterattack(var/atom/target, var/mob/living/user, flag, params)
	if(flag)	//we're placing the object on a table or in backpack
		return
	laser_act(target, user, params)

/obj/item/laser_pointer/proc/laser_act(var/atom/target, var/mob/living/user, var/params)
	if( !(user in (viewers(7,target))) )
		return
	if(!diode)
		to_chat(user, "<span class='notice'>You point [src] at [target], but nothing happens!</span>")
		return
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if((HULK in H.mutations) || (NOGUNS in H.dna.species.species_traits))
			user << "<span class='warning'>Your fingers can't press the button!</span>"
			return

	add_fingerprint(user)

	//nothing happens if the battery is drained
	if(recharge_locked)
		to_chat(user, "<span class='notice'>You point [src] at [target], but it's still charging.</span>")
		return

	var/outmsg
	var/turf/targloc = get_turf(target)

	//human/alien mobs
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(user.zone_selected == "eyes")
			add_attack_logs(user, C, "Shone a laser in the eyes with [src]")

			var/severity = 1
			if(prob(33))
				severity = 2
			else if(prob(50))
				severity = 0

			//20% chance to actually hit the eyes
			if(prob(effectchance * diode.rating) && C.flash_eyes(severity))
				outmsg = "<span class='notice'>You blind [C] by shining [src] in [C.p_their()] eyes.</span>"
				if(C.weakeyes)
					C.Stun(1)
			else
				outmsg = "<span class='warning'>You fail to blind [C] by shining [src] at [C.p_their()] eyes!</span>"

	//robots and AI
	else if(issilicon(target))
		var/mob/living/silicon/S = target
		//20% chance to actually hit the sensors
		if(prob(effectchance * diode.rating))
			S.flash_eyes(affect_silicon = 1)
			S.Weaken(rand(5,10))
			to_chat(S, "<span class='warning'>Your sensors were overloaded by a laser!</span>")
			outmsg = "<span class='notice'>You overload [S] by shining [src] at [S.p_their()] sensors.</span>"

			add_attack_logs(user, S, "shone [src] in their eyes")
		else
			outmsg = "<span class='notice'>You fail to overload [S] by shining [src] at [S.p_their()] sensors.</span>"

	//cameras
	else if(istype(target, /obj/machinery/camera))
		var/obj/machinery/camera/C = target
		if(prob(effectchance * diode.rating))
			C.emp_act(1)
			outmsg = "<span class='notice'>You hit the lens of [C] with [src], temporarily disabling the camera!</span>"

			log_admin("[key_name(user)] EMPd a camera with a laser pointer")
			user.create_attack_log("[key_name(user)] EMPd a camera with a laser pointer")
			add_attack_logs(user, C, "EMPd with [src]")
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
		to_chat(user, outmsg)
	else
		to_chat(user, "<span class='info'>You point [src] at [target].</span>")

	energy -= 1
	if(energy <= max_energy)
		if(!recharging)
			recharging = 1
			START_PROCESSING(SSobj, src)
		if(energy <= 0)
			to_chat(user, "<span class='warning'>You've overused the battery of [src], now it needs time to recharge!</span>")
			recharge_locked = 1

	flick_overlay(I, showto, 10)
	icon_state = "pointer"

/obj/item/laser_pointer/process()
	if(prob(20 - recharge_locked*5))
		energy += 1
		if(energy >= max_energy)
			energy = max_energy
			recharging = 0
			recharge_locked = 0
			..()
