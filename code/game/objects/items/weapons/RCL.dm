/obj/item/rcl
	name = "rapid cable layer (RCL)"
	desc = "A device used to rapidly deploy cables. It has screws on the side which can be removed to slide off the cables."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rcl-0"
	inhand_icon_state = "rcl-0"
	force = 5 //Plastic is soft
	throwforce = 5
	throw_speed = 1
	origin_tech = "engineering=4;materials=2"
	var/max_amount = 90
	var/active = FALSE
	var/obj/structure/cable/last = null
	var/obj/item/stack/cable_coil/loaded = null
	new_attack_chain = TRUE

/obj/item/rcl/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed)

/obj/item/rcl/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!istype(used, /obj/item/stack/cable_coil))
		return ..()

	var/obj/item/stack/cable_coil/coil = used
	if(!loaded)
		if(!user.transfer_item_to(coil, src))
			to_chat(user, "<span class='warning'>[coil] is stuck to your hand!</span>")
			return ITEM_INTERACT_COMPLETE
		loaded = coil
		loaded.max_amount = max_amount //We store a lot.
	else
		if(loaded.amount >= max_amount)
			to_chat(user, "<span class='warning'>You cannot fit any more cable on [src]!</span>")
			return ITEM_INTERACT_COMPLETE

		var/amount = min(loaded.amount + coil.get_amount(), max_amount)
		coil.use(amount - loaded.amount)
		loaded.amount = amount
		refresh_icon(user)
		to_chat(user, "<span class='notice'>You add the cables to [src]. It now contains [loaded.amount].</span>")
		return ITEM_INTERACT_COMPLETE

/obj/item/rcl/proc/refresh_icon(mob/user)
	update_icon(UPDATE_ICON_STATE)
	user.update_inv_l_hand()
	user.update_inv_r_hand()

/obj/item/rcl/screwdriver_act(mob/user, obj/item/I)
	if(!loaded)
		to_chat(user, "<span class='warning'>There's no cable to remove!</span>")
		return
	. = TRUE
	if(!I.use_tool(src, user, FALSE, volume = I.tool_volume))
		return
	to_chat(user, "<span class='notice'>You loosen the securing screws on the side, allowing you to lower the guiding edge and retrieve the wires.</span>")
	while(loaded.amount > 30) //There are only two kinds of situations: "nodiff" (60,90), or "diff" (31-59, 61-89)
		var/diff = loaded.amount % 30
		if(diff)
			loaded.use(diff)
			new /obj/item/stack/cable_coil(user.loc, diff)
		else
			loaded.use(30)
			new /obj/item/stack/cable_coil(user.loc, 30)
	loaded.max_amount = initial(loaded.max_amount)
	loaded.forceMove(user.loc)
	user.put_in_hands(loaded)
	loaded = null
	refresh_icon(user)

/obj/item/rcl/examine(mob/user)
	. = ..()
	if(loaded)
		. += "<span class='notice'>It contains [loaded.amount]/[max_amount] cables.</span>"
	else
		. += "<span class='warning'>It's empty!</span>"

/obj/item/rcl/Destroy()
	QDEL_NULL(loaded)
	last = null
	active = FALSE
	return ..()

/obj/item/rcl/update_icon_state()
	if(!loaded)
		icon_state = "rcl-0"
		inhand_icon_state = "rcl-0"
		return
	switch(loaded.amount)
		if(61 to INFINITY)
			icon_state = "rcl-30"
		if(31 to 60)
			icon_state = "rcl-20"
		if(1 to 30)
			icon_state = "rcl-10"
		else
			icon_state = "rcl-0"
	inhand_icon_state = "rcl[loaded.amount ? "" : "-0"]"

/obj/item/rcl/proc/is_empty(mob/user, loud = 1)
	refresh_icon(user)
	if(!loaded || !loaded.amount)
		if(loud)
			to_chat(user, "<span class='warning'>The last of the cables unreel from [src]!</span>")
		if(loaded)
			qdel(loaded)
			loaded = null
		return TRUE
	return FALSE

/obj/item/rcl/dropped(mob/wearer)
	..()
	active = FALSE
	last = null

/obj/item/rcl/activate_self(mob/user)
	if(..())
		return FINISH_ATTACK

	active = HAS_TRAIT(src, TRAIT_WIELDED)
	if(!active)
		last = null
	else if(!last)
		for(var/obj/structure/cable/C in get_turf(user))
			if(C.d1 == 0 || C.d2 == 0)
				last = C
				break

/obj/item/rcl/on_mob_move(direct, mob/user)
	if(active && isturf(user.loc))
		trigger(user)

/obj/item/rcl/proc/trigger(mob/user)
	if(is_empty(user, 0))
		to_chat(user, "<span class='warning'>[src] is empty!</span>")
		return
	if(last)
		if(get_dist(last, user) == 1) //hacky, but it works
			var/turf/T = get_turf(user)
			if(!isturf(T) || T.intact || !T.can_have_cabling())
				last = null
				return
			if(get_dir(last, user) == last.d2)
				//Did we just walk backwards? Well, that's the one direction we CAN'T complete a stub.
				last = null
				return
			loaded.cable_join(last, user)
			if(is_empty(user))
				return //If we've run out, display message and exit
		else
			last = null
	last = loaded.place_turf(get_turf(loc), user, turn(user.dir, 180))
	is_empty(user) //If we've run out, display message

/obj/item/rcl/pre_loaded/New() //Comes preloaded with cable, for testing stuff
	..()
	loaded = new()
	loaded.max_amount = max_amount
	loaded.amount = max_amount
	update_icon(UPDATE_ICON_STATE)
