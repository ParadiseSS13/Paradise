/obj/machinery/processor
	name = "\improper Food Processor"
	desc = "Used for turning ingredients into other ingredients."
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "processor"
	density = TRUE
	anchored = TRUE
	idle_power_consumption = 5
	active_power_consumption = 50

	var/processing = FALSE
	var/rating_speed = 1
	var/rating_amount = 1

/obj/machinery/processor/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/processor(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	RefreshParts()

/obj/machinery/processor/update_icon_state()
	. = ..()
	if(processing)
		icon_state = "processor_on"
		return
	icon_state = initial(icon_state)

/obj/machinery/processor/examine(mob/user)
	. = ..()
	if(!anchored)
		. += "<span class='notice'>Alt-click to rotate it.</span>"
	else
		. += "<span class='notice'>It is secured in place.</span>"

/obj/machinery/processor/AltClick(mob/user)
	if(user.incapacitated())
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(!Adjacent(user))
		return
	if(anchored)
		to_chat(user, "<span class='warning'>[src] is secured in place!</span>")
		return
	setDir(turn(dir, 90))

/obj/machinery/processor/RefreshParts()
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		rating_amount = B.rating
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		rating_speed = M.rating

/obj/machinery/processor/process()
	if(processing)
		return
	var/mob/living/simple_animal/slime/picked_slime
	for(var/mob/living/simple_animal/slime/slime in range(1, src))
		if(slime.loc == src)
			continue
		if(slime.stat)
			picked_slime = slime
			break
	if(!picked_slime)
		return
	var/datum/food_processor_process/P = select_recipe(picked_slime)
	if(!P)
		return

	visible_message("<span class='notice'>[picked_slime] is sucked into [src].</span>")
	picked_slime.forceMove(src)

//RECIPE DATUMS
/datum/food_processor_process
	var/input
	var/output
	var/time = 40

/// WHO NAME A PARAMETER FOR A PROC "what" holy hell
/datum/food_processor_process/proc/process_food(loc, what, obj/machinery/processor/processor)
	if(output && loc && processor)
		for(var/i = 0, i < processor.rating_amount, i++)
			new output(loc)
	if(what)
		qdel(what)

/////////////////////////
/////OBJECT RECIPIES/////
/////////////////////////
/datum/food_processor_process/meat
	input = /obj/item/food/meat
	output = /obj/item/food/ground_meat

/datum/food_processor_process/potato
	input = /obj/item/food/grown/potato
	output = /obj/item/food/rawsticks

/datum/food_processor_process/rawsticks
	input = /obj/item/food/rawsticks
	output = /obj/item/food/tatortot

/datum/food_processor_process/soybeans
	input = /obj/item/food/grown/soybeans
	output = /obj/item/food/soydope

/datum/food_processor_process/spaghetti
	input = /obj/item/food/sliced/dough
	output = /obj/item/food/spaghetti

/datum/food_processor_process/macaroni
	input = /obj/item/food/spaghetti
	output = /obj/item/food/macaroni

/datum/food_processor_process/parsnip
	input = /obj/item/food/grown/parsnip
	output = /obj/item/food/roastparsnip

/datum/food_processor_process/carrot
	input =  /obj/item/food/grown/carrot
	output = /obj/item/food/grown/carrot/wedges

/datum/food_processor_process/towercap
	input = /obj/item/grown/log
	output = /obj/item/popsicle_stick

/////////////////////////
///END OBJECT RECIPIES///
/////////////////////////

/datum/food_processor_process/mob/process_food(loc, what, processor)
	..()

//////////////////////
/////MOB RECIPIES/////
//////////////////////
/datum/food_processor_process/mob/slime
	input = /mob/living/simple_animal/slime
	output = null

/datum/food_processor_process/mob/slime/process_food(loc, what, obj/machinery/processor/processor)
	var/mob/living/simple_animal/slime/S = what
	var/C = S.cores
	if(S.stat != DEAD)
		S.forceMove(processor.drop_location())
		S.visible_message("<span class='notice'>[S] crawls free of the processor!</span>")
		return
	for(var/i in 1 to (C+processor.rating_amount-1))
		new S.coretype(processor.drop_location())
		SSblackbox.record_feedback("tally", "slime_core_harvested", 1, S.colour)
	..()

/datum/food_processor_process/mob/monkey
	input = /mob/living/carbon/human/monkey
	output = null

/datum/food_processor_process/mob/monkey/process_food(loc, what, processor)
	var/mob/living/carbon/human/monkey/O = what
	if(O.client) //grief-proof
		O.loc = loc
		O.visible_message("<span class='notice'>Suddenly [O] jumps out from the processor!</span>", \
				"<span class='notice'>You jump out of \the [src].</span>", \
				"<span class='notice'>You hear a chimp.</span>")
		return
	var/obj/item/reagent_containers/glass/bucket/bucket_of_blood = new(loc)
	var/datum/reagent/blood/B = new()
	B.holder = bucket_of_blood
	B.volume = 70
	//set reagent data
	B.data["donor"] = O.name
	B.data["blood_DNA"] = copytext(O.dna.unique_enzymes,1,0)
	bucket_of_blood.reagents.reagent_list += B
	bucket_of_blood.reagents.update_total()
	bucket_of_blood.on_reagent_change()
	//bucket_of_blood.reagents.handle_reactions() //blood doesn't react
	..()
////////////////////////
////END MOB RECIPIES////
////////////////////////

//END RECIPE DATUMS

/obj/machinery/processor/proc/select_recipe(X)
	for(var/Type in subtypesof(/datum/food_processor_process) - /datum/food_processor_process/mob)
		var/datum/food_processor_process/P = new Type()
		if(!istype(X, P.input))
			continue
		return P
	return 0

/obj/machinery/processor/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(processing)
		to_chat(user, "<span class='warning'>\the [src] is already processing something!</span>")
		return ITEM_INTERACT_COMPLETE

	if(default_deconstruction_screwdriver(user, "processor_open", "processor", used))
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/storage/part_replacer))
		return ..()

	if(default_unfasten_wrench(user, used, time = 4 SECONDS))
		return ITEM_INTERACT_COMPLETE

	default_deconstruction_crowbar(user, used)

	var/obj/item/what = used

	if(istype(used, /obj/item/grab))
		var/obj/item/grab/G = used
		what = G.affecting

	var/datum/food_processor_process/P = select_recipe(what)

	if(!P)
		to_chat(user, "<span class='warning'>That probably won't blend.</span>")
		return ITEM_INTERACT_COMPLETE

	user.visible_message("<span class='notice'>\the [user] puts \the [what] into \the [src].</span>", \
		"<span class='notice'>You put \the [what] into \the [src].")

	user.drop_item()

	what.loc = src
	return ITEM_INTERACT_COMPLETE

/obj/machinery/processor/attack_hand(mob/user)
	if(stat & (NOPOWER|BROKEN)) //no power or broken
		return

	if(processing)
		to_chat(user, "<span class='warning'>\the [src] is already processing something!</span>")
		return 1

	if(length(contents) == 0)
		to_chat(user, "<span class='warning'>\the [src] is empty.</span>")
		return 1
	processing = TRUE
	update_icon(UPDATE_ICON_STATE)
	user.visible_message("[user] turns on [src].", \
		"<span class='notice'>You turn on [src].</span>", \
		"<span class='italics'>You hear a food processor.</span>")
	playsound(loc, 'sound/machines/blender.ogg', 50, 1)
	use_power(500)
	var/total_time = 0
	for(var/O in contents)
		var/datum/food_processor_process/P = select_recipe(O)
		if(!P)
			log_debug("The [O] in processor([src]) does not have a suitable recipe, but it was somehow put inside of the processor anyways.")
			continue
		total_time += P.time
	sleep(total_time / rating_speed)

	for(var/O in contents)
		var/datum/food_processor_process/P = select_recipe(O)
		if(!P)
			log_debug("The [O] in processor([src]) does not have a suitable recipe, but it was somehow put inside of the processor anyways.")
			continue
		P.process_food(loc, O, src)
	processing = FALSE
	update_icon(UPDATE_ICON_STATE)

	visible_message("<span class='notice'>\the [src] has finished processing.</span>", \
		"<span class='notice'>\the [src] has finished processing.</span>", \
		"<span class='notice'>You hear a food processor stopping.</span>")
