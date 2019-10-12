//todo: toothbrushes, and some sort of "toilet-filthinator" for the hos

/obj/structure/toilet
	name = "toilet"
	desc = "The HT-451, a torque rotation-based, waste disposal unit for small matter. This one seems remarkably clean."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "toilet00"
	density = 0
	anchored = 1
	var/open = 0			//if the lid is up
	var/cistern = 0			//if the cistern bit is open
	var/w_items = 0			//the combined w_class of all the items in the cistern
	var/mob/living/swirlie = null	//the mob being given a swirlie


/obj/structure/toilet/New()
	..()
	open = round(rand(0, 1))
	update_icon()

/obj/structure/toilet/Destroy()
	swirlie = null
	return ..()

/obj/structure/toilet/attack_hand(mob/living/user)
	if(swirlie)
		user.changeNext_move(CLICK_CD_MELEE)
		playsound(src.loc, "swing_hit", 25, 1)
		swirlie.visible_message("<span class='danger'>[user] slams the toilet seat onto [swirlie]'s head!</span>", "<span class='userdanger'>[user] slams the toilet seat onto [swirlie]'s head!</span>", "<span class='italics'>You hear reverberating porcelain.</span>")
		swirlie.adjustBruteLoss(5)
		return

	if(cistern && !open)
		if(!contents.len)
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

/obj/structure/toilet/update_icon()
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
						GM.visible_message("<span class='danger'>[user] slams [GM.name] into [src]!</span>", "<span class='userdanger'>[user] slams [GM.name] into [src]!</span>")
						GM.adjustBruteLoss(5)
			else
				to_chat(user, "<span class='warning'>You need a tighter grip!</span>")

	if(cistern)
		stash_goods(I, user)
		return


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

	var/response = input(user, "What do you want to do?", "[src]") as null|anything in choices
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
				anchored = 0
		if("Connect")
			user.visible_message("<span class='notice'>[user] starts connecting [src].</span>", "<span class='notice'>You begin connecting [src]...</span>")
			if(I.use_tool(src, user, 40, volume = I.tool_volume))
				if(!loc || anchored)
					return
				user.visible_message("<span class='notice'>[user] connects [src]!</span>", "<span class='notice'>You connect [src]!</span>")
				anchored = 1
		if("Rotate")
			var/list/dir_choices = list("North" = NORTH, "East" = EAST, "South" = SOUTH, "West" = WEST)
			var/selected = input(user,"Select a direction for the connector.", "Connector Direction") in dir_choices
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
	w_items += I.w_class
	to_chat(user, "<span class='notice'>You carefully place [I] into the cistern.</span>")

/obj/structure/toilet/secret
	var/secret_type = null

/obj/structure/toilet/secret/New()
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
	density = 0
	anchored = 1


/obj/structure/urinal/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/grab))
		var/obj/item/grab/G = I
		if(!G.confirm())
			return
		if(isliving(G.affecting))
			var/mob/living/GM = G.affecting
			if(G.state >= GRAB_AGGRESSIVE)
				if(GM.loc != get_turf(src))
					to_chat(user, "<span class='notice'>[GM.name] needs to be on [src].</span>")
					return
				user.changeNext_move(CLICK_CD_MELEE)
				playsound(src.loc, 'sound/effects/bang.ogg', 25, 1)
				user.visible_message("<span class='danger'>[user] slams [GM] into [src]!</span>", "<span class='notice'>You slam [GM] into [src]!</span>")
				GM.adjustBruteLoss(8)
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
			anchored = 0
			pixel_x = 0
			pixel_y = 0
	else
		user.visible_message("<span class='notice'>[user] begins connecting [src]...</span>", "<span class='notice'>You begin to connect [src]...</span>")
		if(I.use_tool(src, user, 40, volume = I.tool_volume))
			if(!loc || anchored)
				return
			user.visible_message("<span class='notice'>[user] connects [src]!</span>", "<span class='notice'>You connect [src]!</span>")
			anchored = 1
			pixel_x = 0
			pixel_y = 32

/obj/machinery/shower
	name = "shower"
	desc = "The HS-451. Installed in the 2550s by the Nanotrasen Hygiene Division."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "shower"
	density = 0
	anchored = 1
	use_power = NO_POWER_USE
	var/on = 0
	var/obj/effect/mist/mymist = null
	var/ismist = 0				//needs a var so we can make it linger~
	var/watertemp = "normal"	//freezing, normal, or boiling
	var/mobpresent = 0		//true if there is a mob on the shower's loc, this is to ease process()
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
	QDEL_NULL(mymist)
	QDEL_NULL(soundloop)
	return ..()

//add heat controls? when emagged, you can freeze to death in it?

/obj/effect/mist
	name = "mist"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mist"
	layer = MOB_LAYER + 1
	anchored = 1
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/machinery/shower/attack_hand(mob/M as mob)
	on = !on
	update_icon()
	if(on)
		soundloop.start()
		if(M.loc == loc)
			wash(M)
			check_heat(M)
			M.water_act(100, convertHeat(), src)
		for(var/atom/movable/G in src.loc)
			G.clean_blood()
			G.water_act(100, convertHeat(), src)
	else
		soundloop.stop()

/obj/machinery/shower/attackby(obj/item/I as obj, mob/user as mob, params)
	if(I.type == /obj/item/analyzer)
		to_chat(user, "<span class='notice'>The water temperature seems to be [watertemp].</span>")
	if(on)
		I.water_act(100, convertHeat(), src)
	return ..()

/obj/machinery/shower/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	to_chat(user, "<span class='notice'>You begin to adjust the temperature valve with the [I].</span>")
	if(I.use_tool(src, user, 50, volume = I.tool_volume))
		switch(watertemp)
			if("normal")
				watertemp = "freezing"
			if("freezing")
				watertemp = "boiling"
			if("boiling")
				watertemp = "normal"
	user.visible_message("<span class='notice'>[user] adjusts the shower with the [I].</span>", "<span class='notice'>You adjust [src] to [watertemp].</span>")
	update_icon()	//letsa update whenever we change the temperature, since the mist might need to change

/obj/machinery/shower/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(on)
		to_chat(user, "<span class='warning'>Turn [src] off before you attempt to cut it loose.</span>")
		return
	if(!I.tool_use_check(user, 0))
		return
	visible_message("<span class='notice'>[user] begins slicing [src] free...</span>", "<span class='notice'>You begin slicing [src] free...</span>", "<span class='warning'>You hear welding.</span>")
	if(I.use_tool(src, user, 40, volume = I.tool_volume))
		if(mymist)
			qdel(mymist)
		user.visible_message("<span class='notice'>[user] cuts [src] loose!</span>", "<span class='notice'>You cut [src] loose!</span>")
		var/obj/item/mounted/shower/S = new /obj/item/mounted/shower(get_turf(user))
		transfer_prints_to(S, TRUE)
		qdel(src)

/obj/machinery/shower/update_icon()	//this makes the shower mist up or clear mist (depending on water temperature)
	overlays.Cut()					//once it's been on for a while, in addition to handling the water overlay.
	if(on)
		overlays += image('icons/obj/watercloset.dmi', src, "water", MOB_LAYER + 1, dir)
		var/mist_time = 50		//5 seconds at normal temperature to build up mist
		if(watertemp == "freezing")
			mist_time = 70		//7 seconds on freezing temperature to disperse existing mist
		if(watertemp == "boiling")
			mist_time = 20		//2 seconds on boiling temperature to build up mist
		addtimer(CALLBACK(src, .proc/update_mist), mist_time)
	else
		addtimer(CALLBACK(src, .proc/update_mist), 250) //25 seconds for mist to disperse after being turned off

/obj/machinery/shower/proc/update_mist()
	if(on)
		if(watertemp == "freezing")
			if(mymist)
				qdel(mymist)
			ismist = 0
			return
		if(mymist)
			return
		ismist = 1
		mymist = new /obj/effect/mist(loc)
	else
		if(mymist)
			qdel(mymist)
		ismist = 0

/obj/machinery/shower/Crossed(atom/movable/O, oldloc)
	..()
	wash(O)
	if(ismob(O))
		mobpresent += 1
		check_heat(O)

/obj/machinery/shower/Uncrossed(atom/movable/O)
	if(ismob(O))
		mobpresent -= 1
	..()

/obj/machinery/shower/proc/convertHeat()
	switch(watertemp)
		if("boiling")
			return 340.15
		if("normal")
			return 310.15
		if("freezing")
			return 230.15

//Yes, showers are super powerful as far as washing goes.
/obj/machinery/shower/proc/wash(atom/movable/O as obj|mob)
	if(!on) return

	if(istype(O, /obj/item))
		var/obj/item/I = O
		I.extinguish()

	O.water_act(100, convertHeat(), src)

	if(isliving(O))
		var/mob/living/L = O
		L.ExtinguishMob()
		L.adjust_fire_stacks(-20) //Douse ourselves with water to avoid fire more easily
		to_chat(L, "<span class='warning'>You've been drenched in water!</span>")
		if(iscarbon(O))
			var/mob/living/carbon/M = O
			if(M.r_hand)
				M.r_hand.clean_blood()
			if(M.l_hand)
				M.l_hand.clean_blood()
			if(M.back)
				if(M.back.clean_blood())
					M.update_inv_back(0)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				var/washgloves = 1
				var/washshoes = 1
				var/washmask = 1
				var/washears = 1
				var/washglasses = 1

				if(H.wear_suit)
					washgloves = !(H.wear_suit.flags_inv & HIDEGLOVES)
					washshoes = !(H.wear_suit.flags_inv & HIDESHOES)

				if(H.head)
					washmask = !(H.head.flags_inv & HIDEMASK)
					washglasses = !(H.head.flags_inv & HIDEEYES)
					washears = !(H.head.flags_inv & HIDEEARS)

				if(H.wear_mask)
					if(washears)
						washears = !(H.wear_mask.flags_inv & HIDEEARS)
					if(washglasses)
						washglasses = !(H.wear_mask.flags_inv & HIDEEYES)

				if(H.head)
					if(H.head.clean_blood())
						H.update_inv_head(0,0)
				if(H.wear_suit)
					if(H.wear_suit.clean_blood())
						H.update_inv_wear_suit(0,0)
				else if(H.w_uniform)
					if(H.w_uniform.clean_blood())
						H.update_inv_w_uniform(0,0)
				if(H.gloves && washgloves)
					if(H.gloves.clean_blood())
						H.update_inv_gloves(0,0)
				if(H.shoes && washshoes)
					if(H.shoes.clean_blood())
						H.update_inv_shoes(0,0)
				if(H.wear_mask && washmask)
					if(H.wear_mask.clean_blood())
						H.update_inv_wear_mask(0)
				if(H.glasses && washglasses)
					if(H.glasses.clean_blood())
						H.update_inv_glasses(0)
				if(H.l_ear && washears)
					if(H.l_ear.clean_blood())
						H.update_inv_ears(0)
				if(H.r_ear && washears)
					if(H.r_ear.clean_blood())
						H.update_inv_ears(0)
				if(H.belt)
					if(H.belt.clean_blood())
						H.update_inv_belt(0)
			else
				if(M.wear_mask)            //if the mob is not human, it cleans the mask without asking for bitflags
					if(M.wear_mask.clean_blood())
						M.update_inv_wear_mask(0)

		else
			O.clean_blood()

	if(isturf(loc))
		var/turf/tile = loc
		loc.clean_blood()
		for(var/obj/effect/E in tile)
			if(is_cleanable(E))
				qdel(E)

/obj/machinery/shower/process()
	if(!on || !mobpresent)
		return
	for(var/mob/living/carbon/C in loc)
		if(prob(33))
			wash(C)	//re-applies water and re-cleans mob while they remain under the shower, 33% chance per process to avoid message spam/quick death
		check_heat(C)

/obj/machinery/shower/proc/check_heat(mob/M as mob)
	if(!on || watertemp == "normal")
		return
	if(iscarbon(M))
		var/mob/living/carbon/C = M

		if(watertemp == "freezing")
			//C.bodytemperature = max(80, C.bodytemperature - 80)
			to_chat(C, "<span class='warning'>The water is freezing!</span>")
			return
		if(watertemp == "boiling")
			//C.bodytemperature = min(500, C.bodytemperature + 35)
			C.adjustFireLoss(5)
			to_chat(C, "<span class='danger'>The water is searing!</span>")
			return


/obj/item/bikehorn/rubberducky
	name = "rubber ducky"
	desc = "Rubber ducky you're so fine, you make bathtime lots of fuuun. Rubber ducky I'm awfully fooooond of yooooouuuu~"	//thanks doohl
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "rubberducky"
	item_state = "rubberducky"
	honk_sounds = list('sound/items/squeaktoy.ogg' = 1)
	attack_verb = list("quacked", "squeaked")

/obj/structure/sink
	name = "sink"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "sink"
	desc = "A sink used for washing one's hands and face."
	anchored = 1
	var/busy = 0 	//Something's being washed at the moment
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
	busy = 1

	if(!do_after(user, 40, target = src))
		busy = 0
		return

	busy = 0

	user.visible_message("<span class='notice'>[user] washes [user.p_their()] [washing_face ? "face" : "hands"] using [src].</span>", \
						"<span class='notice'>You wash your [washing_face ? "face" : "hands"] using [src].</span>")
	if(washing_face)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.lip_style = null //Washes off lipstick
			H.lip_color = initial(H.lip_color)
			H.regenerate_icons()
		user.AdjustDrowsy(-rand(2,3)) //Washing your face wakes you up if you're falling asleep
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

	busy = 1
	var/wateract = 0
	wateract = (O.wash(user, src))
	busy = 0
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

	var/response = input(user, "What do you want to do?", "[src]") as null|anything in choices
	if(!Adjacent(user) || !response)	//moved away or cancelled
		return
	switch(response)
		if("Wash")
			busy = 1
			var/wateract = 0
			wateract = (I.wash(user, src))
			busy = 0
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
			var/selected = input(user, "Select a direction for the connector.", "Connector Direction") in dir_choices
			dir = dir_choices[selected]
	update_icon()	//is this necessary? probably not

/obj/structure/sink/update_icon()
	..()
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


/obj/structure/sink/puddle	//splishy splashy ^_^
	name = "puddle"
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
	if(!(get_dir(on_wall, user) in cardinal))
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
	icon = 'icons/obj/storage.dmi'
	icon_state = "largebox"
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
		S.anchored = 0
		S.dir = user.dir
		S.update_icon()
		user.unEquip(src, 1)
		qdel(src)
		if(prob(50))
			new /obj/item/stack/sheet/cardboard(T)
