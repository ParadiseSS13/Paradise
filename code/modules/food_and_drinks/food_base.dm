////////////////////////////////////////////////////////////////////////////////
/// Food.
////////////////////////////////////////////////////////////////////////////////

#define MAX_WEIGHT_CLASS WEIGHT_CLASS_SMALL

/obj/item/food
	name = "snack"
	desc = "yummy"
	icon = 'icons/obj/food/food.dmi'
	icon_state = null
	resistance_flags = FLAMMABLE
	container_type = INJECTABLE
	w_class = WEIGHT_CLASS_TINY
	var/filling_color = "#FFFFFF" //Used by sandwiches.
	var/junkiness = 0  //for junk food. used to lower human satiety.
	var/bitesize = 2
	var/consume_sound = 'sound/items/eatfood.ogg'
	/// Will ants come near it?
	var/antable = TRUE
	/// location checked every 5 minutes. If its the same place, the food has a chance to spawn ants
	var/ant_location
	/// Things that suppress food from being infested by ants when on the same turf
	var/static/list/ant_suppressors
	/// Time we last checked for ants
	var/last_ant_time = 0
	/// Name of the food to show up in kitchen machines (microwaves, ovens, etc)
	var/ingredient_name
	var/ingredient_name_plural
	/// Sets the default container amount for all food items.
	var/volume = 50
	/// The list of reagents to create on Initialize()
	var/list/list_reagents = list()

	var/temperature_min = 0 // To limit the temperature of a reagent container can attain when exposed to heat/cold
	var/temperature_max = 10000

	/// How difficult is this food for the kitchen to make?
	/// Affects the quantity of food that is requested by CC.
	var/goal_difficulty = FOOD_GOAL_SKIP

	var/bitecount = 0
	var/trash = null
	var/slice_path
	var/slices_num
	var/dried_type = null
	var/dry = FALSE
	var/cooktype[0]
	var/cooked_type = null  //for microwave cooking. path of the resulting item after microwaving
	var/total_w_class = 0 //for the total weight an item of food can carry
	var/list/tastes  // for example list("crisps" = 2, "salt" = 1)

/obj/item/food/Initialize(mapload)
	. = ..()

	if(!reagents) // Some subtypes create their own reagents
		create_reagents(volume, temperature_min, temperature_max)
	add_initial_reagents()

	if(!antable)
		return

	if(!ant_suppressors)
		ant_suppressors = typecacheof(list(
			/obj/structure/table,
			/obj/structure/rack,
			/obj/structure/closet
		))
	START_PROCESSING(SSobj, src)
	ant_location = get_turf(src)
	last_ant_time = world.time

/obj/item/food/Destroy()
	ant_location = null
	if(isprocessing)
		STOP_PROCESSING(SSobj, src)
	if(contents)
		for(var/atom/movable/something in contents)
			something.forceMove(get_turf(src))
	return ..()

/obj/item/food/proc/add_initial_reagents()
	if(tastes && length(tastes) && length(list_reagents))
		for(var/rid in list_reagents)
			var/amount = list_reagents[rid]
			if(rid == "nutriment" || rid == "vitamin" || rid == "protein" || rid == "plantmatter")
				reagents.add_reagent(rid, amount, tastes.Copy())
			else
				reagents.add_reagent(rid, amount)

	else if(length(list_reagents))
		reagents.add_reagent_list(list_reagents)

/obj/item/food/process()
	if(!antable)
		return PROCESS_KILL
	if(world.time > last_ant_time + 5 MINUTES)
		check_for_ants()

/obj/item/food/proc/check_for_ants()
	last_ant_time = world.time

	// Are we unshielded from the fury of space ants?
	if(!prob(15)) // Ants are often not the smartest
		return
	if(!isturf(loc)) // Being inside something protects the food
		return

	var/turf/T = get_turf(src)

	if(T != ant_location) // Moving the food before a full ant swarm can arrive to the location also helps
		ant_location = T
		return

	for(var/obj/structure/S in T) // Check if some object on our turf protects the food from ants
		if(is_type_in_typecache(S, ant_suppressors))
			return

	// Dinner time!
	if(!locate(/obj/effect/decal/cleanable/ants) in T)
		new /obj/effect/decal/cleanable/ants(T)
	antable = FALSE
	desc += " It appears to be infested with ants. Yuck!"
	reagents.add_reagent("ants", 1) // Don't eat things with ants in it you weirdo.

/obj/item/food/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		if(bitecount > 0)
			if(bitecount==1)
				. += "<span class='notice'>[src] was bitten by someone!</span>"
			else if(bitecount<=3)
				. += "<span class='notice'>[src] was bitten [bitecount] times!</span>"
			else
				. += "<span class='notice'>[src] was bitten multiple times!</span>"

/obj/item/food/ex_act()
	if(reagents)
		for(var/datum/reagent/R in reagents.reagent_list)
			R.on_ex_act()
	if(!QDELETED(src))
		..()

//Placeholder for effect that trigger on eating that aren't tied to reagents.
/obj/item/food/proc/On_Consume(mob/M, mob/user)
	if(!user)
		return
	if(!reagents.total_volume)
		if(M == user)
			to_chat(user, "<span class='notice'>You finish eating [src].</span>")
		user.visible_message("<span class='notice'>[M] finishes eating [src].</span>")
		user.unEquip(src)	//so icons update :[
		Post_Consume(M)
		var/obj/item/trash_item = generate_trash(user)
		user.put_in_hands(trash_item)
		qdel(src)

/obj/item/food/proc/Post_Consume(mob/living/M)
	return

/obj/item/food/attack_self(mob/user)
	return

/obj/item/food/attack(mob/M, mob/user, def_zone)
	if(user.a_intent == INTENT_HARM && force)
		return ..()
	if(reagents && !reagents.total_volume)	// Shouldn't be needed but it checks to see if it has anything left in it.
		to_chat(user, "<span class='warning'>None of [src] left, oh no!</span>")
		M.unEquip(src)	//so icons update :[
		qdel(src)
		return FALSE

	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(C.eat(src, user))
			bitecount++
			On_Consume(C, user)
			return TRUE
	return FALSE

/obj/item/food/afterattack(obj/target, mob/user, proximity)
	return

/obj/item/food/attackby(obj/item/W, mob/user, params)
	if(is_pen(W))
		rename_interactive(user, W, use_prefix = FALSE, prompt = "What would you like to name this dish?")
		return
	if(isstorage(W))
		..() // -> item/attackby(, params)

	else if(istype(W,/obj/item/kitchen/utensil))

		var/obj/item/kitchen/utensil/U = W

		if(length(U.contents) >= U.max_contents)
			to_chat(user, "<span class='warning'>You cannot fit anything else on your [U].")
			return

		user.visible_message( \
			"[user] scoops up some [src] with \the [U]!", \
			"<span class='notice'>You scoop up some [src] with \the [U]!" \
		)

		bitecount++
		U.overlays.Cut()
		var/image/I = new(U.icon, "loadedfood")
		I.color = filling_color
		U.overlays += I

		var/obj/item/food/collected = new type
		collected.name = name
		collected.loc = U
		collected.reagents.remove_any(collected.reagents.total_volume)
		collected.trash = null
		if(reagents.total_volume > bitesize)
			reagents.trans_to(collected, bitesize)
		else
			reagents.trans_to(collected, reagents.total_volume)
			if(trash)
				var/obj/item/TrashItem
				if(ispath(trash,/obj/item))
					TrashItem = new trash(src)
				else if(isitem(trash))
					TrashItem = trash
				TrashItem.forceMove(loc)
			qdel(src)
		return TRUE
	else
		return ..()

/obj/item/food/proc/generate_trash(atom/location)
	if(trash)
		if(ispath(trash, /obj/item))
			. = new trash(location)
			trash = null
			return
		else if(isitem(trash))
			var/obj/item/trash_item = trash
			trash_item.forceMove(location)
			. = trash
			trash = null
			return

/obj/item/food/attack_animal(mob/M)
	if(isanimal(M))
		M.changeNext_move(CLICK_CD_MELEE)
		if(isdog(M))
			var/mob/living/simple_animal/pet/dog/D = M
			if(world.time < (D.last_eaten + 300))
				to_chat(D, "<span class='notice'>You are too full to try eating [src] right now.</span>")
			else if(bitecount >= 4)
				D.visible_message("[D] [pick("burps from enjoyment", "yaps for more", "woofs twice", "looks at the area where [src] was")].","<span class='notice'>You swallow up the last part of [src].</span>")
				playsound(loc,'sound/items/eatfood.ogg', rand(10,50), 1)
				D.adjustHealth(-10)
				D.last_eaten = world.time
				D.taste(reagents)
				qdel(src)
			else
				D.visible_message("[D] takes a bite of [src].","<span class='notice'>You take a bite of [src].</span>")
				playsound(loc,'sound/items/eatfood.ogg', rand(10,50), 1)
				bitecount++
				D.last_eaten = world.time
				D.taste(reagents)
		else if(ismouse(M))
			var/mob/living/simple_animal/mouse/N = M
			to_chat(N, "<span class='notice'>You nibble away at [src].</span>")
			if(prob(50))
				N.visible_message("[N] nibbles away at [src].", "")
			N.adjustHealth(-2)
			N.taste(reagents)
		else if(iscaterpillar(M))
			var/mob/living/simple_animal/nian_caterpillar/W = M
			W.taste(reagents)
			W.consume(src)

/obj/item/food/sliceable
	slices_num = 2

/obj/item/food/sliceable/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt-click to put something small inside.</span>"

/obj/item/food/sliceable/AltClick(mob/user)
	if(!Adjacent(user))
		return
	var/obj/item/I = user.get_active_hand()
	if(!I)
		return
	if(I.w_class > WEIGHT_CLASS_SMALL)
		to_chat(user, "<span class='warning'>You cannot fit [I] in [src]!</span>")
		return
	var/newweight = GetTotalContentsWeight() + I.GetTotalContentsWeight() + I.w_class
	if(newweight > MAX_WEIGHT_CLASS)
		// Nope, no bluespace slice food
		to_chat(user, "<span class='warning'>You cannot fit [I] in [src]!</span>")
		return
	if(!iscarbon(user))
		return
	if(!user.drop_item())
		to_chat(user, "<span class='warning'>You cannot slip [I] inside [src]!</span>")
		return
	to_chat(user, "<span class='warning'>You slip [I] inside [src].</span>")
	total_w_class += I.w_class
	add_fingerprint(user)
	I.forceMove(src)

/obj/item/food/sliceable/attackby(obj/item/I, mob/user, params)
	if((slices_num <= 0 || !slices_num) || !slice_path)
		return FALSE

	var/inaccurate = TRUE
	if(I.sharp)
		if(istype(I, /obj/item/kitchen/knife) || istype(I, /obj/item/scalpel))
			inaccurate = FALSE
	else
		return TRUE
	if(!isturf(loc) || !(locate(/obj/structure/table) in loc) && \
			!(locate(/obj/machinery/optable) in loc) && !(locate(/obj/item/storage/bag/tray) in loc))
		to_chat(user, "<span class='warning'>You cannot slice [src] here! You need a table or at least a tray to do it.</span>")
		return TRUE
	var/slices_lost = 0
	var/initial_volume = 0 // the total some of reagents this food had initially
	for(var/ingredient in list_reagents)
		initial_volume += list_reagents[ingredient]
	// we want to account for how much has been eaten already, reduce slices by how is left vs. how much food we started with
	slices_num = clamp(slices_num * (reagents.total_volume / initial_volume), 1, slices_num)
	if(!inaccurate)
		user.visible_message("<span class='notice'>[user] slices [src]!</span>",
		"<span class='notice'>You slice [src]!</span>")
	else
		user.visible_message("<span class='notice'>[user] crudely slices [src] with [I]!</span>",
			"<span class='notice'>You crudely slice [src] with your [I]</span>!")
		slices_lost = rand(1, min(1, round(slices_num / 2)))
	var/reagents_per_slice = reagents.total_volume/slices_num
	for(var/i in 1 to (slices_num - slices_lost))
		var/obj/slice = new slice_path (loc)
		reagents.trans_to(slice,reagents_per_slice)
		slice.pixel_x = rand(-7, 7)
		slice.pixel_y = rand(-7, 7)
	qdel(src)
	return ..()

/obj/item/food/badrecipe
	name = "burned mess"
	desc = "Someone should be demoted from chef for this."
	icon_state = "badrecipe"
	filling_color = "#211F02"
	list_reagents = list("????" = 30)

/obj/item/food/badrecipe/Initialize(mapload)
	. = ..()
	// it's burned! it should start off being classed as any cooktype that burns
	cooktype["grilled"] = TRUE
	cooktype["deep fried"] = TRUE

// MISC

/obj/item/food/cereal
	name = "box of cereal"
	desc = "A box of cereal."
	icon = 'icons/obj/food/food.dmi'
	icon_state = "cereal_box"
	list_reagents = list("nutriment" = 3)

/obj/item/food/deepfryholder
	name = "Deep Fried Foods Holder Obj"
	desc = "If you can see this description the code for the deep fryer fucked up."
	icon = 'icons/obj/food/food.dmi'
	icon_state = "deepfried_holder_icon"
	list_reagents = list("nutriment" = 3)

#undef MAX_WEIGHT_CLASS
