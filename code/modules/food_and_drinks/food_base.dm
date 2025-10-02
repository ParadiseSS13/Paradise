////////////////////////////////////////////////////////////////////////////////
/// Food.
////////////////////////////////////////////////////////////////////////////////

#define MAX_WEIGHT_CLASS WEIGHT_CLASS_SMALL

//MARK: FOOD
/obj/item/food
	name = "snack"
	desc = "yummy!"
	icon = 'icons/obj/food/food.dmi'
	icon_state = null
	resistance_flags = FLAMMABLE
	container_type = INJECTABLE
	w_class = WEIGHT_CLASS_TINY
	new_attack_chain = TRUE
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
	var/trash
	var/slice_path
	var/slices_num
	var/dried_type
	var/dry = FALSE
	var/cooktype[0]
	var/cooked_type  //for microwave cooking. path of the resulting item after microwaving
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
			/obj/structure/closet,
			/obj/structure/shelf
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
	// Add viruses where needed
	if(length(M.viruses))
		AddComponent(/datum/component/viral_contamination, M.viruses)
	var/datum/reagent/blood/blood_contained = locate() in reagents.reagent_list
	// Infect contained blood as well for splash reactions
	if(blood_contained?.data["viruses"])
		var/list/blood_viruses = blood_contained.data["viruses"]
		blood_viruses |= M.viruses.Copy()
		blood_contained.data["viruses"] = blood_viruses
	SEND_SIGNAL(src, COMSIG_MOB_REAGENT_EXCHANGE, M)
	if(!reagents.total_volume)
		if(M == user)
			to_chat(user, "<span class='notice'>You finish eating [src].</span>")
		user.visible_message("<span class='notice'>[M] finishes eating [src].</span>")
		user.unequip(src)	//so icons update :[
		Post_Consume(M)
		var/obj/item/trash_item = generate_trash(user)
		user.put_in_hands(trash_item)
		qdel(src)

/obj/item/food/proc/Post_Consume(mob/living/M)
	return

/obj/item/food/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(user.a_intent == INTENT_HARM && force)
		return NONE

	user.changeNext_move(CLICK_CD_MELEE)
	if(reagents && !reagents.total_volume)	// Shouldn't be needed but it checks to see if it has anything left in it.
		to_chat(user, "<span class='warning'>None of [src] left, oh no!</span>")
		qdel(src)
		return ITEM_INTERACT_COMPLETE

	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(C.eat(src, user))
			bitecount++
			On_Consume(C, user)
		return ITEM_INTERACT_COMPLETE

	return NONE

/obj/item/food/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(is_pen(used))
		rename_interactive(user, used, use_prefix = FALSE, prompt = "What would you like to name this dish?")
		return ITEM_INTERACT_COMPLETE

	if(isstorage(used))
		return NONE

	if(istype(used, /obj/item/kitchen/utensil))
		var/obj/item/kitchen/utensil/U = used
		if(length(U.contents) >= U.max_contents)
			to_chat(user, "<span class='warning'>You cannot fit anything else on your [U].")
			return ITEM_INTERACT_COMPLETE

		user.visible_message(
			"<span class='notice'>[user] scoops up some [name] with [U]!</span>",
			"<span class='notice'>You scoop up some [name] with [U]!</span>"
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
		return ITEM_INTERACT_COMPLETE

	return NONE

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
			var/mob/living/basic/mouse/N = M
			to_chat(N, "<span class='notice'>You nibble away at [src].</span>")
			if(prob(50))
				N.visible_message("[N] nibbles away at [src].", "")
			N.adjustHealth(-2)
			N.taste(reagents)
		else if(iscaterpillar(M))
			var/mob/living/basic/nian_caterpillar/W = M
			W.taste(reagents)
			W.consume(src)

//MARK: SLICE
/obj/item/food/sliced

/obj/item/food/sliced/Initialize(mapload, made_by_sliceable = FALSE)
	if(made_by_sliceable)
		// we null reagent from subclass, because it will get reagents from parent sliceable
		list_reagents = list()
		return ..()
	if(length(list_reagents))
		return ..()

	// We don't have any reagents, let's add something
	log_debug("[src] was a sliced food, which was neither sliced and has no reagents.")
	list_reagents = list("nutriment" = 5)

	return ..()

//MARK: SLICEABLE
/obj/item/food/sliceable
	slices_num = 2

/obj/item/food/sliceable/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt-click to put something small inside.</span>"

/obj/item/food/sliceable/AltClick(mob/user)
	if(!Adjacent(user))
		return
	var/obj/item/I = user.get_active_hand()
	if(!I || I == src) // dont try to slip inside itself
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

/obj/item/food/sliceable/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if((slices_num <= 0 || !slices_num) || !slice_path)
		return ITEM_INTERACT_COMPLETE

	if(!used.sharp)
		return NONE

	var/inaccurate = TRUE
	if(istype(used, /obj/item/kitchen/knife) || istype(used, /obj/item/scalpel))
		inaccurate = FALSE

	if(!isturf(loc) || !(locate(/obj/structure/table) in loc) && \
			!(locate(/obj/machinery/optable) in loc) && !(locate(/obj/item/storage/bag/tray) in loc))
		to_chat(user, "<span class='warning'>You cannot slice [src] here! You need a table or at least a tray to do it.</span>")
		return ITEM_INTERACT_COMPLETE

	var/initial_volume = 0 // the total some of reagents this food had initially
	for(var/ingredient in list_reagents)
		initial_volume += list_reagents[ingredient]

	// Total slices after factoring in productivity value of the knife
	slices_num = clamp(slices_num * used.bit_productivity_mod, 1, round(slices_num * 2.5))
	// we want to account for how much has been eaten already, reduce slices by how is left vs. how much food we started with
	slices_num = clamp(slices_num * (reagents.total_volume / initial_volume), 1, slices_num)
	var/slices_lost
	if(!inaccurate)
		user.visible_message(
			"<span class='notice'>[user] slices [src] with [used].</span>",
			"<span class='notice'>You slice [src] with [used].</span>"
		)
	else
		user.visible_message(
			"<span class='notice'>[user] crudely slices [src] with [used], destroying some in the process!</span>",
			"<span class='notice'>You crudely slice [src] with [used], destroying some in the process!</span>"
		)
		slices_lost = rand(1, min(1, round(slices_num / 2)))
	// Low efficiency means more loss.
	if(used.bit_efficiency_mod < 1)
		slices_lost = slices_num * (1 - used.bit_efficiency_mod)
	var/reagents_per_slice = reagents.total_volume/slices_num
	for(var/i in 1 to (slices_num - slices_lost))
		var/obj/slice = new slice_path (loc, TRUE)
		reagents.trans_to(slice,reagents_per_slice)
		slice.scatter_atom()
	qdel(src)
	return ITEM_INTERACT_COMPLETE

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

//MARK: MISC
/obj/item/food/cereal
	name = "box of cereal"
	desc = "A box of cereal."
	icon_state = "cereal_box"
	list_reagents = list("nutriment" = 3)

#undef MAX_WEIGHT_CLASS
