/obj/vehicle/train/ambulance/engine
	name = "ambulance train tug"
	desc = "A ridable electric car designed for pulling ambulance trolleys."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "docwagon2"			//mulebot icons until I get some proper icons
	on = 0
	powered = 1
	locked = 0
	layer = MOB_LAYER + 0.1
	load_item_visible = 1
	load_offset_x = 0
	load_offset_y = 7

	var/car_limit = 3		//how many cars an engine can pull before performance degrades
	active_engines = 1
	var/obj/item/key/ambulance/key

/obj/vehicle/train/ambulance/trolley
	name = "ambulance train trolley"
	icon = 'icons/vehicles/CargoTrain.dmi'
	icon_state = "ambulance"
	anchored = 0
	passenger_allowed = 1
	locked = 0

	load_item_visible = 1
	load_offset_x = 1
	load_offset_y = 7

//-------------------------------------------
// Standard procs
//-------------------------------------------
/obj/vehicle/train/ambulance/engine/New()
	..()
	cell = new /obj/item/weapon/stock_parts/cell/high
	key = new()

/obj/vehicle/train/ambulance/engine/Move()
	. = ..()
	handle_rotation()
	update_mob()

/obj/vehicle/train/ambulance/trolley/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(open && istype(W, /obj/item/weapon/wirecutters))
		passenger_allowed = !passenger_allowed
		user.visible_message("<span class='notice'>[user] [passenger_allowed ? "cuts" : "mends"] a cable in [src].</span>","<span class='notice'>You [passenger_allowed ? "cut" : "mend"] the load limiter cable.</span>")
	else
		..()

/obj/vehicle/train/ambulance/engine/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/key/ambulance))
		if(!key)
			user.drop_item()
			key = W
			W.loc = src
			verbs += /obj/vehicle/train/ambulance/engine/verb/remove_key
		return
	..()

/obj/vehicle/train/ambulance/update_icon()
	if(open)
		//icon_state = "mulebot-hatch"
		icon_state = initial(icon_state)
	else
		icon_state = initial(icon_state)

/obj/vehicle/train/ambulance/engine/Emag(mob/user as mob)
	..()
	flick("mulebot-emagged", src)

/obj/vehicle/train/ambulance/trolley/insert_cell(var/obj/item/weapon/stock_parts/cell/C, var/mob/living/carbon/human/H)
	return

/obj/vehicle/train/ambulance/engine/insert_cell(var/obj/item/weapon/stock_parts/cell/C, var/mob/living/carbon/human/H)
	..()
	update_stats()

/obj/vehicle/train/ambulance/engine/remove_cell(var/mob/living/carbon/human/H)
	..()
	update_stats()

/obj/vehicle/train/ambulance/engine/Bump(atom/Obstacle)
	var/obj/machinery/door/D = Obstacle
	var/mob/living/carbon/human/H = load
	if(istype(D) && istype(H))
		D.Bumped(H)		//a little hacky, but hey, it works, and repects access rights

	..()

/obj/vehicle/train/ambulance/trolley/Bump(atom/Obstacle)
	if(!lead)
		return //so people can't knock others over by pushing a trolley around
	..()

/obj/vehicle/train/ambulance/engine/handle_rotation()
	if(dir == SOUTH)
		layer = FLY_LAYER
	else
		layer = OBJ_LAYER

/obj/vehicle/train/ambulance/engine/proc/update_mob()
	if(load)
		load.dir = dir
		switch(dir)
			if(SOUTH)
				load.pixel_x = 0
				load.pixel_y = 7
			if(WEST)
				load.pixel_x = 13
				load.pixel_y = 7
			if(NORTH)
				load.pixel_x = 0
				load.pixel_y = 4
			if(EAST)
				load.pixel_x = -13
				load.pixel_y = 7


//-------------------------------------------
// Train procs
//-------------------------------------------
/obj/vehicle/train/ambulance/engine/turn_on()
	if(!key)
		return
	else
		..()
		update_stats()

/obj/vehicle/train/ambulance/RunOver(var/mob/living/carbon/human/H)
	var/list/parts = list("head", "chest", "l_leg", "r_leg", "l_arm", "r_arm")

	H.apply_effects(5, 5)
	for(var/i = 0, i < rand(1,3), i++)
		H.apply_damage(rand(1,5), BRUTE, pick(parts))

/obj/vehicle/train/ambulance/trolley/RunOver(var/mob/living/carbon/human/H)
	..()
	attack_log += text("\[[time_stamp()]\] <font color='red'>ran over [H.name] ([H.ckey])</font>")

/obj/vehicle/train/ambulance/engine/RunOver(var/mob/living/carbon/human/H)
	..()

	if(is_train_head() && istype(load, /mob/living/carbon/human))
		var/mob/living/carbon/human/D = load
		D << "\red \b You ran over [H]!"
		visible_message("<B>\red \The [src] ran over [H]!</B>")
		attack_log += text("\[[time_stamp()]\] <font color='red'>ran over [key_name(H)], driven by [key_name(D)]</font>")
		msg_admin_attack("[key_name_admin(D)] ran over [key_name_admin(H)]")
	else
		attack_log += text("\[[time_stamp()]\] <font color='red'>ran over [key_name(H)]</font>")


//-------------------------------------------
// Interaction procs
//-------------------------------------------
/obj/vehicle/train/ambulance/engine/relaymove(mob/user, direction)
	if(user != load)
		return 0

	if(is_train_head())
		if(direction == reverse_direction(dir) && tow) //can reverse with no tow
			return 0
		if(Move(get_step(src, direction)))
			return 1
		return 0
	else
		return ..()

/obj/vehicle/train/ambulance/engine/examine(mob/user)
	if(..(user, 1))
		user << "The power light is [on ? "on" : "off"].\nThere are[key ? "" : " no"] keys in the ignition."

/obj/vehicle/train/ambulance/engine/verb/check_power()
	set name = "Check power level"
	set category = "Object"
	set src in view(1)

	if(!istype(usr, /mob/living/carbon/human))
		return

	if(!cell)
		usr << "There is no power cell installed in [src]."
		return

	usr << "The power meter reads [round(cell.percent(), 0.01)]%"

/obj/vehicle/train/ambulance/engine/verb/start_engine()
	set name = "Start engine"
	set category = "Object"
	set src in view(1)

	if(!istype(usr, /mob/living/carbon/human))
		return

	if(on)
		usr << "The engine is already running."
		return

	turn_on()
	if (on)
		usr << "You start [src]'s engine."
	else
		if(cell.charge < charge_use)
			usr << "[src] is out of power."
		else
			usr << "[src]'s engine won't start."

/obj/vehicle/train/ambulance/engine/verb/stop_engine()
	set name = "Stop engine"
	set category = "Object"
	set src in view(1)

	if(!istype(usr, /mob/living/carbon/human))
		return

	if(!on)
		usr << "The engine is already stopped."
		return

	turn_off()
	if (!on)
		usr << "You stop [src]'s engine."

/obj/vehicle/train/ambulance/engine/verb/remove_key()
	set name = "Remove key"
	set category = "Object"
	set src in view(1)

	if(!istype(usr, /mob/living/carbon/human))
		return

	if(!key || (load && load != usr))
		return

	if(on)
		turn_off()

	key.loc = usr.loc
	if(!usr.get_active_hand())
		usr.put_in_hands(key)
	key = null

	verbs -= /obj/vehicle/train/ambulance/engine/verb/remove_key

//-------------------------------------------
// Loading/unloading procs
//-------------------------------------------
/obj/vehicle/train/ambulance/trolley/load(var/atom/movable/C)
	if(ismob(C) && !passenger_allowed)
		return 0
	if(!istype(C,/obj/machinery) && !istype(C,/obj/structure/closet) && !istype(C,/obj/structure/largecrate) && !istype(C,/obj/structure/reagent_dispensers) && !istype(C,/obj/structure/ore_box) && !ismob(C))
		return 0

	return ..()

/obj/vehicle/train/ambulance/engine/load(var/atom/movable/C)
	if(!ismob(C))
		return 0

	return ..()


//-------------------------------------------------------
// Stat update procs
//
// Update the trains stats for speed calculations.
// The longer the train, the slower it will go. car_limit
// sets the max number of cars one engine can pull at
// full speed. Adding more cars beyond this will slow the
// train proportionate to the length of the train. Adding
// more engines increases this limit by car_limit per
// engine.
//-------------------------------------------------------

/obj/vehicle/train/ambulance/engine/proc/update_move_delay()
	if(!is_train_head() || !on)
		move_delay = initial(move_delay)		//so that engines that have been turned off don't lag behind
	else
		move_delay = max(0, (-car_limit * active_engines) + train_length - active_engines)	//limits base overweight so you cant overspeed trains
		move_delay *= (1 / max(1, active_engines)) * 2 										//overweight penalty (scaled by the number of engines)
		move_delay += 1+config.run_speed 														//base reference speed
		move_delay *= 1.05
