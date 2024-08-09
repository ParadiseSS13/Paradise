//todo: toothbrushes, and some sort of "toilet-filthinator" for the hos

/obj/structure/toilet
	name = "toilet"
	desc = "The HT-451, a torque rotation-based, waste disposal unit for small matter. This one seems remarkably clean."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "toilet00"
	density = FALSE
	anchored = TRUE
	var/open = FALSE			//if the lid is up
	var/cistern = FALSE			//if the cistern bit is open
	var/w_items = 0			//the combined w_class of all the items in the cistern
	var/mob/living/swirlie = null	//the mob being given a swirlie


/obj/structure/toilet/Initialize(mapload)
	. = ..()
	open = prob(50)
	update_icon()

/obj/structure/toilet/Destroy()
	swirlie = null
	return ..()

/obj/structure/toilet/attack_hand(mob/living/user)
	if(swirlie)
		user.changeNext_move(CLICK_CD_MELEE)
		playsound(src.loc, "swing_hit", 25, 1)
		swirlie.visible_message("<span class='danger'>[user] slams the toilet seat onto [swirlie]'s head!</span>", "<span class='userdanger'>[user] slams the toilet seat onto [swirlie]'s head!</span>", "<span class='italics'>You hear reverberating porcelain.</span>")
		swirlie.apply_damage(5, BRUTE, BODY_ZONE_HEAD)
		return

	if(cistern && !open)
		if(!length(contents))
			to_chat(user, "<span class='notice'>The cistern is empty.</span>")
			return
		else
			var/obj/item/I = pick(contents)
			if(ishuman(user))
				user.put_in_hands(I)
			else
				I.loc = get_turf(src)
			to_chat(user, "<span class='notice'>You find [I] in the cistern.</span>")
			w_items -= I.w_class
			return

	open = !open
	update_icon()

/obj/structure/toilet/update_icon_state()
	icon_state = "toilet[open][cistern]"
	if(!anchored)
		pixel_x = 0
		pixel_y = 0
		layer = OBJ_LAYER
	else
		if(dir == SOUTH)
			pixel_x = 0
			pixel_y = 8
		if(dir == NORTH)
			pixel_x = 0
			pixel_y = -8
			layer = FLY_LAYER

/obj/structure/toilet/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/reagent_containers))
		if(!open)
			return
		var/obj/item/reagent_containers/RG = I
		if(RG.is_refillable())
			if(RG.reagents.holder_full())
				to_chat(user, "<span class='warning'>[RG] is full.</span>")
			else
				RG.reagents.add_reagent("toiletwater", min(RG.volume - RG.reagents.total_volume, RG.amount_per_transfer_from_this))
				to_chat(user, "<span class='notice'>You fill [RG] from [src]. Gross.</span>")
			return

	if(istype(I, /obj/item/grab))
		user.changeNext_move(CLICK_CD_MELEE)
		var/obj/item/grab/G = I
		if(HAS_TRAIT(user, TRAIT_PACIFISM))
			to_chat(user, "<span class='danger'>Swirling [G.affecting] might hurt them!</span>")
			return
		if(!G.confirm())
			return
		if(isliving(G.affecting))
			var/mob/living/GM = G.affecting
			if(G.state >= GRAB_AGGRESSIVE)
				if(GM.loc != get_turf(src))
					to_chat(user, "<span class='warning'>[GM] needs to be on [src]!</span>")
					return
				if(!swirlie)
					if(open)
						GM.visible_message("<span class='danger'>[user] starts to give [GM] a swirlie!</span>", "<span class='userdanger'>[user] starts to give [GM] a swirlie...</span>")
						swirlie = GM
						if(do_after(user, 30, 0, target = src))
							GM.visible_message("<span class='danger'>[user] gives [GM] a swirlie!</span>", "<span class='userdanger'>[user] gives [GM] a swirlie!</span>", "<span class='italics'>You hear a toilet flushing.</span>")
							if(iscarbon(GM))
								var/mob/living/carbon/C = GM
								if(!C.internal)
									C.adjustOxyLoss(5)
							else
								GM.adjustOxyLoss(5)
						swirlie = null
					else
						playsound(src.loc, 'sound/effects/bang.ogg', 25, 1)
						GM.visible_message("<span class='danger'>[user] slams [GM.name]'s head into [src]!</span>", "<span class='userdanger'>[user] slams [GM.name]'s head into [src]!</span>")
						GM.apply_damage(5, BRUTE, BODY_ZONE_HEAD)
			else
				to_chat(user, "<span class='warning'>You need a tighter grip!</span>")
	if(istype(I, /obj/item/flamethrower))
		var/obj/item/flamethrower/big_lighter = I
		if(!big_lighter.lit)
			to_chat(user, "<span class='warning'>The flamethrower isn't lit!</span>")
			return
		big_lighter.default_ignite(loc, 0.01)
		if(!cistern) //Just changes what message you get, since fire_act handles the open cistern too.
			user.visible_message("<span class='warning'>[user] torches the contents of the top of the toilet with [big_lighter]!</span>", "<span class='warning'>You torch the top of the toilet with [big_lighter]! Whoops.</span>")
			return

		user.visible_message("<span class='notice'>[user] torches the contents of the cistern with [big_lighter]!</span>", "<span class='notice'>You torch the contents of the cistern with [big_lighter]!</span>")
		return

	if(cistern)
		update_contents_weight_class()
		stash_goods(I, user)
		return

/obj/structure/toilet/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay)
	..()
	if(!cistern)
		return
	for(var/obj/item/I in src)
		I.fire_act(air, exposed_temperature, exposed_volume, global_overlay)

//Used in case the contents of the cistern update outside of stash_goods, sets w_items to the new total weight.
/obj/structure/toilet/proc/update_contents_weight_class()
	var/new_total_weight = 0
	for(var/obj/item/I in src)
		new_total_weight += I.w_class
	w_items = new_total_weight

/obj/structure/toilet/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	to_chat(user, "<span class='notice'>You start to [cistern ? "replace the lid on the cistern" : "lift the lid off the cistern"]...</span>")
	playsound(loc, 'sound/effects/stonedoor_openclose.ogg', 50, 1)
	if(I.use_tool(src, user, 30, volume = I.tool_volume))
		user.visible_message("[user] [cistern ? "replaces the lid on the cistern" : "lifts the lid off the cistern"]!", "<span class='notice'>You [cistern ? "replace the lid on the cistern" : "lift the lid off the cistern"]!</span>", "<span class='italics'>You hear grinding porcelain.</span>")
		cistern = !cistern
		update_icon()
		return

/obj/structure/toilet/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	var/choices = list()
	if(cistern)
		choices += "Stash"
	if(anchored)
		choices += "Disconnect"
	else
		choices += "Connect"
		choices += "Rotate"

	var/response = tgui_input_list(user, "What do you want to do?", "[src]", choices)
	if(!Adjacent(user) || !response)	//moved away or cancelled
		return
	switch(response)
		if("Stash")
			stash_goods(I, user)
		if("Disconnect")
			user.visible_message("<span class='notice'>[user] starts disconnecting [src].</span>", "<span class='notice'>You begin disconnecting [src]...</span>")
			if(I.use_tool(src, user, 40, volume = I.tool_volume))
				if(!loc || !anchored)
					return
				user.visible_message("<span class='notice'>[user] disconnects [src]!</span>", "<span class='notice'>You disconnect [src]!</span>")
				anchored = FALSE
		if("Connect")
			user.visible_message("<span class='notice'>[user] starts connecting [src].</span>", "<span class='notice'>You begin connecting [src]...</span>")
			if(I.use_tool(src, user, 40, volume = I.tool_volume))
				if(!loc || anchored)
					return
				user.visible_message("<span class='notice'>[user] connects [src]!</span>", "<span class='notice'>You connect [src]!</span>")
				anchored = TRUE
		if("Rotate")
			var/list/dir_choices = list("North" = NORTH, "East" = EAST, "South" = SOUTH, "West" = WEST)
			var/selected = tgui_input_list(user, "Select a direction for the connector.", "Connector Direction", dir_choices)
			if(!selected)
				return
			dir = dir_choices[selected]
	update_icon()	//is this necessary? probably not

/obj/structure/toilet/proc/stash_goods(obj/item/I, mob/user)
	if(!I)
		return
	if(I.w_class > WEIGHT_CLASS_NORMAL)
		to_chat(user, "<span class='warning'>[I] does not fit!</span>")
		return
	if(w_items + I.w_class > WEIGHT_CLASS_HUGE)
		to_chat(user, "<span class='warning'>The cistern is full!</span>")
		return
	if(!user.drop_item())
		to_chat(user, "<span class='warning'>[I] is stuck to your hand, you cannot put it in the cistern!</span>")
		return
	I.loc = src
	update_contents_weight_class()
	to_chat(user, "<span class='notice'>You carefully place [I] into the cistern.</span>")

/obj/structure/toilet/secret
	var/secret_type = null

/obj/structure/toilet/secret/Initialize(mapload)
	. = ..()
	if(secret_type)
		var/obj/item/secret = new secret_type(src)
		secret.desc += " It's a secret!"
		w_items += secret.w_class



/obj/structure/urinal
	name = "urinal"
	desc = "The HU-452, an experimental urinal."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "urinal"
	density = FALSE
	anchored = TRUE


/obj/structure/urinal/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/grab))
		var/obj/item/grab/G = I
		if(!G.confirm())
			return
		if(HAS_TRAIT(user, TRAIT_PACIFISM))
			to_chat(user, "<span class='danger'>Slamming [G.affecting] into [src] might hurt them!</span>")
			return
		if(isliving(G.affecting))
			var/mob/living/GM = G.affecting
			if(G.state >= GRAB_AGGRESSIVE)
				if(GM.loc != get_turf(src))
					to_chat(user, "<span class='notice'>[GM.name] needs to be on [src].</span>")
					return
				user.changeNext_move(CLICK_CD_MELEE)
				playsound(src.loc, 'sound/effects/bang.ogg', 25, 1)
				user.visible_message("<span class='danger'>[user] slams [GM]'s head into [src]!</span>", "<span class='danger'>You slam [GM]'s head into [src]!</span>")
				GM.apply_damage(8, BRUTE, BODY_ZONE_HEAD)
			else
				to_chat(user, "<span class='warning'>You need a tighter grip!</span>")

/obj/structure/urinal/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	if(anchored)
		user.visible_message("<span class='notice'>[user] begins disconnecting [src]...</span>", "<span class='notice'>You begin to disconnect [src]...</span>")
		if(I.use_tool(src, user, 40, volume = I.tool_volume))
			if(!loc || !anchored)
				return
			user.visible_message("<span class='notice'>[user] disconnects [src]!</span>", "<span class='notice'>You disconnect [src]!</span>")
			anchored = FALSE
			pixel_x = 0
			pixel_y = 0
	else
		user.visible_message("<span class='notice'>[user] begins connecting [src]...</span>", "<span class='notice'>You begin to connect [src]...</span>")
		if(I.use_tool(src, user, 40, volume = I.tool_volume))
			if(!loc || anchored)
				return
			user.visible_message("<span class='notice'>[user] connects [src]!</span>", "<span class='notice'>You connect [src]!</span>")
			anchored = TRUE
			pixel_x = 0
			pixel_y = 32

#define SHOWER_FREEZING "freezing"
#define SHOWER_NORMAL "normal"
#define SHOWER_BOILING "boiling"

/obj/machinery/shower
	name = "shower"
	desc = "The HS-451. Installed in the 2550s by the Nanotrasen Hygiene Division."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "shower"
	density = FALSE
	anchored = TRUE
	power_state = NO_POWER_USE
	///Is the shower on or off?
	var/on = FALSE
	///What temperature the shower reagents are set to.
	var/current_temperature = SHOWER_NORMAL
	///What sound will be played on loop when the shower is on and pouring water.
	var/datum/looping_sound/showering/soundloop

/obj/machinery/shower/New(turf/T, newdir = SOUTH, building = FALSE)
	..()
	soundloop = new(list(src), FALSE)
	if(building)
		dir = newdir
		pixel_x = 0
		pixel_y = 0
		switch(newdir)
			if(SOUTH)
				pixel_y = 16
			if(NORTH)
				pixel_y = -5
				layer = FLY_LAYER

/obj/machinery/shower/Destroy()
	QDEL_NULL(soundloop)
	var/obj/effect/mist/mist = locate() in loc
	if(!QDELETED(mist))
		QDEL_IN(mist, 25 SECONDS)
	return ..()

//add heat controls? when emagged, you can freeze to death in it?

/obj/effect/mist
	name = "mist"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mist"
	layer = FLY_LAYER
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/machinery/shower/attack_hand(mob/M)
	on = !on
	update_icon()
	handle_mist()
	add_fingerprint(M)
	if(on)
		START_PROCESSING(SSmachines, src)
		process()
		soundloop.start()
	else
		soundloop.stop()
		var/turf/simulated/T = loc
		if(istype(T) && !T.density)
			T.MakeSlippery(TURF_WET_WATER, 5 SECONDS)

/obj/machinery/shower/attackby(obj/item/I, mob/user, params)
	if(I.type == /obj/item/analyzer)
		to_chat(user, "<span class='notice'>The water temperature seems to be [current_temperature].</span>")
	return ..()

/obj/machinery/shower/wrench_act(mob/user, obj/item/I)
	..()
	to_chat(user, "<span class='notice'>You begin to adjust the temperature valve with [I].</span>")
	if(I.use_tool(src, user, 50))
		switch(current_temperature)
			if(SHOWER_NORMAL)
				current_temperature = SHOWER_FREEZING
			if(SHOWER_FREEZING)
				current_temperature = SHOWER_BOILING
			if(SHOWER_BOILING)
				current_temperature = SHOWER_NORMAL
		user.visible_message("<span class='notice'>[user] adjusts the shower with \the [I].</span>", "<span class='notice'>You adjust the shower with \the [I] to [current_temperature] temperature.</span>")
		add_hiddenprint(user)
	handle_mist()
	return TRUE

/obj/machinery/shower/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(on)
		to_chat(user, "<span class='warning'>Turn [src] off before you attempt to cut it loose.</span>")
		return
	if(!I.tool_use_check(user, 0))
		return
	visible_message("<span class='notice'>[user] begins slicing [src] free...</span>", "<span class='notice'>You begin slicing [src] free...</span>", "<span class='warning'>You hear welding.</span>")
	if(I.use_tool(src, user, 40, volume = I.tool_volume))
		user.visible_message("<span class='notice'>[user] cuts [src] loose!</span>", "<span class='notice'>You cut [src] loose!</span>")
		var/obj/item/mounted/shower/S = new /obj/item/mounted/shower(get_turf(user))
		transfer_prints_to(S, TRUE)
		qdel(src)

/obj/machinery/shower/update_overlays()
	. = ..()
	if(on)
		var/mutable_appearance/water_falling = mutable_appearance('icons/obj/watercloset.dmi', "water", ABOVE_MOB_LAYER)
		. += water_falling

/obj/machinery/shower/proc/handle_mist()
	// If there is no mist, and the shower was turned on (on a non-freezing temp): make mist in 5 seconds
	// If there was already mist, and the shower was turned off (or made cold): remove the existing mist in 25 sec
	var/obj/effect/mist/mist = locate() in loc
	if(!mist && on && current_temperature != SHOWER_FREEZING)
		addtimer(CALLBACK(src, PROC_REF(make_mist)), 5 SECONDS)

	if(mist && (!on || current_temperature == SHOWER_FREEZING))
		addtimer(CALLBACK(src, PROC_REF(clear_mist)), 25 SECONDS)


/obj/machinery/shower/proc/make_mist()
	var/obj/effect/mist/mist = locate() in loc
	if(!mist && on && current_temperature != SHOWER_FREEZING)
		new /obj/effect/mist(loc)

/obj/machinery/shower/proc/clear_mist()
	var/obj/effect/mist/mist = locate() in loc
	if(mist && (!on || current_temperature == SHOWER_FREEZING))
		qdel(mist)

/obj/machinery/shower/Crossed(atom/movable/AM)
	..()
	if(on)
		wash(AM)

/obj/machinery/shower/proc/convertHeat()
	switch(current_temperature)
		if(SHOWER_BOILING)
			return 340.15
		if(SHOWER_NORMAL)
			return 310.15
		if(SHOWER_FREEZING)
			return 230.15

//Yes, showers are super powerful as far as washing goes.
/obj/machinery/shower/proc/wash(atom/A)
	if(isitem(A))
		var/obj/item/I = A
		I.extinguish()

	A.water_act(100, convertHeat(), src)

	if(isliving(A))
		var/mob/living/L = A
		check_heat(L)
		L.ExtinguishMob()
		L.adjust_fire_stacks(-20) //Douse ourselves with water to avoid fire more easily

	A.clean_blood(radiation_clean = TRUE)

/obj/machinery/shower/process()
	if(on)
		if(isturf(loc))
			var/turf/tile = loc
			tile.water_act(100, convertHeat(), src)
			tile.clean_blood(radiation_clean = TRUE)
			for(var/obj/effect/E in tile)
				if(E.is_cleanable())
					qdel(E)
		for(var/A in loc)
			wash(A)
	else
		on = FALSE
		soundloop.stop()
		handle_mist()
		update_icon()

/obj/machinery/shower/proc/check_heat(mob/M)
	if(current_temperature == SHOWER_NORMAL)
		return
	if(iscarbon(M))
		var/mob/living/carbon/C = M

		if(current_temperature == SHOWER_FREEZING)
			//C.bodytemperature = max(80, C.bodytemperature - 80)
			to_chat(C, "<span class='warning'>The water is freezing!</span>")

		else if(current_temperature == SHOWER_BOILING)
			//C.bodytemperature = min(500, C.bodytemperature + 35)
			C.adjustFireLoss(5)
			to_chat(C, "<span class='danger'>The water is searing!</span>")

#undef SHOWER_FREEZING
#undef SHOWER_NORMAL
#undef SHOWER_BOILING

/obj/item/bikehorn/rubberducky
	name = "rubber ducky"
	desc = "Rubber ducky you're so fine, you make bathtime lots of fuuun. Rubber ducky I'm awfully fooooond of yooooouuuu~"	//thanks doohl
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "rubberducky"
	item_state = "rubberducky"
	honk_sounds = list('sound/items/squeaktoy.ogg' = 1)
	attack_verb = list("quacked", "squeaked")

/obj/item/bikehorn/rubberducky/captainducky
	name = "captain rubber ducky"
	desc = "Captain's favorite rubber ducky. This one squeaks with power."
	icon_state = "cap_rubber_ducky"

/obj/structure/sink
	name = "sink"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "sink"
	desc = "A sink used for washing one's hands and face."
	anchored = TRUE
	var/busy = FALSE 	//Something's being washed at the moment
	var/can_move = 1	//if the sink can be disconnected and moved
	var/can_rotate = 1	//if the sink can be rotated to face alternate directions

/obj/structure/sink/attack_hand(mob/user as mob)
	if(!user || !istype(user))
		return
	if(!iscarbon(user))
		return
	if(!Adjacent(user))
		return
	if(!anchored)
		to_chat(user, "<span class='warning'>[src] isn't connected, wrench it into position first!</span>")
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/external/temp = H.bodyparts_by_name["r_hand"]
		if(user.hand)
			temp = H.bodyparts_by_name["l_hand"]
		if(temp && !temp.is_usable())
			to_chat(user, "<span class='notice'>You try to move your [temp.name], but cannot!")
			return

	if(busy)
		to_chat(user, "<span class='notice'>Someone's already washing here.</span>")
		return
	var/selected_area = parse_zone(user.zone_selected)
	var/washing_face = 0
	if(selected_area in list("head", "mouth", "eyes"))
		washing_face = 1
	user.visible_message("<span class='notice'>[user] starts washing [user.p_their()] [washing_face ? "face" : "hands"]...</span>", \
						"<span class='notice'>You start washing your [washing_face ? "face" : "hands"]...</span>")
	busy = TRUE

	if(!do_after(user, 40, target = src))
		busy = FALSE
		return

	busy = FALSE

	user.visible_message("<span class='notice'>[user] washes [user.p_their()] [washing_face ? "face" : "hands"] using [src].</span>", \
						"<span class='notice'>You wash your [washing_face ? "face" : "hands"] using [src].</span>")
	if(washing_face)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.lip_style = null //Washes off lipstick
			H.lip_color = initial(H.lip_color)
			H.regenerate_icons()
			H.AdjustDrowsy(-rand(4 SECONDS, 6 SECONDS)) //Washing your face wakes you up if you're falling asleep
	else
		user.clean_blood()


/obj/structure/sink/attackby(obj/item/O, mob/user, params)
	if(busy)
		to_chat(user, "<span class='warning'>Someone's already washing here!</span>")
		return

	if(!(istype(O)))
		return

	if(!anchored)
		to_chat(user, "<span class='warning'>[src] isn't connected, wrench it into position first!</span>")
		return

	busy = TRUE
	var/wateract = 0
	wateract = O.wash(user, src)
	busy = FALSE
	if(wateract)
		O.water_act(20, COLD_WATER_TEMPERATURE, src)

/obj/structure/sink/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	var/choices = list()
	if(anchored)
		choices += "Wash"
		if(can_move)
			choices += "Disconnect"
	else
		choices += "Connect"
		if(can_rotate)
			choices += "Rotate"

	var/response = tgui_input_list(user, "What do you want to do?", "[src]", choices)
	if(!Adjacent(user) || !response)	//moved away or cancelled
		return
	switch(response)
		if("Wash")
			busy = TRUE
			var/wateract = 0
			wateract = (I.wash(user, src))
			busy = FALSE
			if(wateract)
				I.water_act(20, COLD_WATER_TEMPERATURE, src)
		if("Disconnect")
			user.visible_message("<span class='notice'>[user] starts disconnecting [src].</span>", "<span class='notice'>You begin disconnecting [src]...</span>")
			if(I.use_tool(src, user, 40, volume = I.tool_volume))
				if(!loc || !anchored)
					return
				user.visible_message("<span class='notice'>[user] disconnects [src]!</span>", "<span class='notice'>You disconnect [src]!</span>")
				anchored = FALSE
		if("Connect")
			user.visible_message("<span class='notice'>[user] starts connecting [src].</span>", "<span class='notice'>You begin connecting [src]...</span>")
			if(I.use_tool(src, user, 40, volume = I.tool_volume))
				if(!loc || anchored)
					return
				user.visible_message("<span class='notice'>[user] connects [src]!</span>", "<span class='notice'>You connect [src]!</span>")
				anchored = TRUE
		if("Rotate")
			var/list/dir_choices = list("North" = NORTH, "East" = EAST, "South" = SOUTH, "West" = WEST)
			var/selected = tgui_input_list(user, "Select a direction for the connector.", "Connector Direction", dir_choices)
			if(!selected)
				return
			dir = dir_choices[selected]
	update_icon()	//is this necessary? probably not

/obj/structure/sink/update_icon_state()
	layer = OBJ_LAYER
	if(!anchored)
		pixel_x = 0
		pixel_y = 0
	else
		//the following code will probably want to be updated in the future to be less reliant on hardcoded offsets based on the can_move/can_rotate values
		if(!can_move)		//puddles
			return
		if(!can_rotate)		//kitchen sinks
			pixel_x = 0
			pixel_y = 28
			return
		else				//normal sinks
			if(dir == NORTH || dir == SOUTH)
				pixel_x = 0
				pixel_y = (dir == NORTH) ? -5 : 30
				if(dir == NORTH)
					layer = FLY_LAYER
			else
				pixel_x = (dir == EAST) ? 12 : -12
				pixel_y = 0


/obj/structure/sink/kitchen
	name = "kitchen sink"
	icon_state = "sink_alt"
	can_rotate = 0


/// splishy splashy ^_^
/obj/structure/sink/puddle
	name = "puddle"
	desc = "A puddle of clean water. Looks refreshing."
	icon_state = "puddle"
	can_move = 0
	can_rotate = 0
	resistance_flags = UNACIDABLE

/obj/structure/sink/puddle/attack_hand(mob/M as mob)
	icon_state = "puddle-splash"
	..()
	icon_state = "puddle"

/obj/structure/sink/puddle/attackby(obj/item/O as obj, mob/user as mob, params)
	icon_state = "puddle-splash"
	..()
	icon_state = "puddle"

/obj/structure/sink/kitchen/old
	name = "old sink"
	desc = "A sink used for washing one's hands and face. It looks rusty and home-made."

//////////////////////////////////
//		Bathroom Fixture Items	//
//////////////////////////////////


/obj/item/mounted/shower
	name = "shower fixture"
	desc = "A self-adhering shower fixture. Simply stick to a wall, no plumber needed!"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "shower"
	item_state = "buildpipe"

/obj/item/mounted/shower/try_build(turf/on_wall, mob/user, proximity_flag)
	//overriding this because we don't care about other items on the wall, but still need to do adjacent checks
	if(!on_wall || !user)
		return
	if(proximity_flag != 1) //if we aren't next to the wall
		return
	if(!(get_dir(on_wall, user) in GLOB.cardinal))
		to_chat(user, "<span class='warning'>You need to be standing next to a wall to place \the [src].</span>")
		return
	return 1

/obj/item/mounted/shower/do_build(turf/on_wall, mob/user)
	var/obj/machinery/shower/S = new /obj/machinery/shower(get_turf(user), get_dir(on_wall, user), 1)
	transfer_prints_to(S, TRUE)
	qdel(src)


/obj/item/bathroom_parts
	name = "toilet in a box"
	desc = "An entire toilet in a box, straight from Space Sweden. It has an unpronounceable name."
	icon = 'icons/obj/boxes.dmi'
	icon_state = "large_box"
	w_class = WEIGHT_CLASS_BULKY
	var/result = /obj/structure/toilet
	var/result_name = "toilet"

/obj/item/bathroom_parts/urinal
	name = "urinal in a box"
	result = /obj/structure/urinal
	result_name = "urinal"

/obj/item/bathroom_parts/sink
	name = "sink in a box"
	result = /obj/structure/sink
	result_name = "sink"

/obj/item/bathroom_parts/New()
	..()
	desc = "An entire [result_name] in a box, straight from Space Sweden. It has an [pick("unpronounceable", "overly accented", "entirely gibberish", "oddly normal-sounding")] name."

/obj/item/bathroom_parts/attack_self(mob/user)
	var/turf/T = get_turf(user)
	if(!T)
		to_chat(user, "<span class='warning'>You can't build that here!</span>")
		return
	if(result in T.contents)
		to_chat(user, "<span class='warning'>There's already \an [result_name] here.</span>")
		return
	user.visible_message("<span class='notice'>[user] begins assembling a new [result_name].</span>", "<span class='notice'>You begin assembling a new [result_name].</span>")
	if(do_after(user, 30, target = user))
		user.visible_message("<span class='notice'>[user] finishes building a new [result_name]!</span>", "<span class='notice'>You finish building a new [result_name]!</span>")
		var/obj/structure/S = new result(T)
		S.anchored = FALSE
		S.dir = user.dir
		S.update_icon()
		user.unEquip(src, 1)
		qdel(src)
		if(prob(50))
			new /obj/item/stack/sheet/cardboard(T)
