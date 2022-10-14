#define CARBON 1
#define SILICON 2
#define CAMERA 3
/obj/item/signmaker
	name = "Signmaker Clown"
	desc = "A handy-dandy holographic projector"
	icon = 'icons/obj/device.dmi'
	icon_state = "signmaker_clown_off"
	item_state = "signmaker_clown"
	slot_flags = SLOT_BELT
	force = 0
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_SMALL

	var/pointer_busy = FALSE
	var/energy = 5
	var/max_energy = 5
	var/recharging = 0
	var/recharge_locked = 0
	var/holosign_type = /obj/structure/holosoap
	var/obj/structure/holosoap/sign
	var/emag = FALSE

/obj/item/signmaker/proc/clear_holosign()
	if(!sign)
		return
	qdel(sign)
	sign = null
	update_icon()

/obj/item/signmaker/proc/icon_flick()
	set waitfor = FALSE

	icon_state = "signmaker_clown_on"
	pointer_busy = TRUE
	sleep(10)
	pointer_busy = FALSE
	icon_state = "signmaker_clown_off"

/obj/item/signmaker/update_icon()
	if(sign)
		icon_state = "signmaker_clown_on"
	else
		icon_state = "signmaker_clown_off"

/obj/item/signmaker/emag_act(mob/user)
	add_attack_logs(user, src, "emagged")
	clear_holosign()
	to_chat(user, "You broke the pointer, oh no")
	holosign_type = /obj/structure/holosoap/holosoap_emagged

/obj/item/signmaker/attack_self(mob/user)
	clear_holosign()
	to_chat(user, "<span class='notice'>You clear active hologram.</span>")

/obj/item/signmaker/afterattack(var/atom/target, var/mob/living/user, params)
	laser_act(target, user, params)

/obj/item/signmaker/process()
	var/recharge_chance = 20 - recharge_locked*5
	if(!prob(recharge_chance))
		return
	energy = min(max_energy, energy++)
	if(energy == max_energy)
		recharging = FALSE
		recharge_locked = FALSE
		return PROCESS_KILL

/obj/item/signmaker/proc/laser_act(var/atom/target, var/mob/living/user, var/params)
	if( !(target in view(user)))
		return
	if(pointer_busy)
		to_chat(user, "<span class='notice'>You already pointing at something.</span>")
		return
	if(recharge_locked)
		to_chat(user, "<span class='notice'>You point [src] at [target], but it's still charging.</span>")
		return
	add_fingerprint(user)
	var/target_type = 0

	if(iscarbon(target))
		target_type = CARBON
	if(issilicon(target))
		target_type = SILICON
	if(istype(target, /obj/machinery/camera))
		target_type = CAMERA

	switch(target_type)
		if(CARBON)
			energy -= 1
			icon_flick()
			var/mob/living/carbon/C = target
			if(user.zone_selected == "eyes")
				add_attack_logs(user, C, "Shone a laser in the eyes with [src]")
				//20% chance to actually hit the eyes
				if(prob(20))
					visible_message("<span class='notice'>You blind [C] by shining [src] in [C.p_their()] eyes.</span>")
					if(C.weakeyes)
						C.Stun(1)
				else
					visible_message("<span class='warning'>You fail to blind [C] by shining [src] at [C.p_their()] eyes!</span>")
			else
				visible_message("<span class='info'>You missed the [C] with [src].</span>")
		if(SILICON)
			energy -= 1
			icon_flick()
			var/mob/living/silicon/S = target
			if(user.zone_selected == "eyes")
				//20% chance to actually hit the sensors
				if(prob(20))
					S.flash_eyes(affect_silicon = 1)
					S.Weaken(rand(5,10))
					to_chat(S, "<span class='warning'>Your sensors were overloaded by a laser!</span>")
					visible_message("<span class='notice'>You overload [S] by shining [src] at [S.p_their()] sensors.</span>")

					add_attack_logs(user, S, "shone [src] in their eyes")
				else
					visible_message("<span class='notice'>You fail to overload [S] by shining [src] at [S.p_their()] sensors.</span>")
			else
				visible_message("<span class='info'>You missed the [S] with [src].</span>")
		if(CAMERA)
			energy -= 1
			icon_flick()
			var/obj/machinery/camera/C = target
			if(prob(20))
				C.emp_act(1)
				visible_message("<span class='notice'>You hit the lens of [C] with [src], temporarily disabling the camera!</span>")

				log_admin("[key_name(user)] EMPd a camera with a signmaker")
				add_attack_logs(user, C, "EMPd with [src]", ATKLOG_ALL)
			else
				visible_message("<span class='info'>You missed the lens of [C] with [src].</span>")
		else
			create_holosign(target, user)
	//to make sure energy doesn't go below 0
	energy = max(0, energy)
	update_icon()
	if(energy <= max_energy)
		if(!recharging)
			recharging = TRUE
			START_PROCESSING(SSobj, src)
		if(energy <= 0)
			to_chat(user, "<span class='warning'>You've overused the battery of [src], now it needs time to recharge!</span>")
			recharge_locked = TRUE
			clear_holosign()

/obj/item/signmaker/proc/create_holosign(atom/target, mob/user)
	var/turf/T = get_turf(target)
	var/obj/structure/holosign/found_holosoap = locate(holosign_type) in T
	if(found_holosoap)
		if(found_holosoap == sign)
			to_chat(user, "<span class='notice'>You use [src] to deactivate [sign].</span>")
			clear_holosign()
		return
	if(is_blocked_turf(T, TRUE)) //can't put holograms on a tile that has dense stuff
		return
	clear_holosign()
	playsound(src, 'sound/machines/click.ogg', 20, 1)
	sign = new holosign_type(get_turf(target), src)
	update_icon()
	to_chat(user, "<span class='notice'>You create [sign.name] with [src].</span>")

/obj/structure/holosoap
	name = "holographic soap"
	desc = "looks like a real soap, but it's not."
	icon = 'icons/effects/effects.dmi'
	icon_state = "holo_soap"
	density = FALSE
	layer = ABOVE_MOB_LAYER
	anchored = TRUE
	pressure_resistance = ONE_ATMOSPHERE
	max_integrity = 1

	var/obj/item/signmaker/projector = null

/obj/structure/holosoap/Initialize(mapload, new_projector)
	. = ..()
	projector = new_projector

/obj/structure/holosoap/Destroy()
	projector.sign = null
	return ..()

/obj/structure/holosoap/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(loc, 'sound/items/squeaktoy.ogg', 80, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/squeaktoy.ogg', 80, TRUE)

/obj/structure/holosoap/Crossed(atom/movable/AM, oldloc)
	playsound(loc, 'sound/misc/slip.ogg', 80, TRUE)
	. = ..()

/obj/structure/holosoap/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	user.do_attack_animation(src)
	user.changeNext_move(CLICK_CD_MELEE)
	take_damage(5 , BRUTE, "melee", 1)

/obj/structure/holosoap/holosoap_emagged
	name = "solid holographic soap"
	desc = "looks like a real soap, but it's blocking your path now."
	density = TRUE

#undef CARBON
#undef SILICON
#undef CAMERA
