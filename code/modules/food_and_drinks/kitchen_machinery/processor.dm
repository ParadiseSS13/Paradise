/obj/machinery/processor
	name = "Food Processor"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "processor"
	layer = 2.9
	density = 1
	anchored = 1

	var/broken = 0
	var/processing = 0

	use_power = 1
	idle_power_usage = 5
	active_power_usage = 50
	var/rating_speed = 1
	var/rating_amount = 1

/obj/machinery/processor/New()
		..()
		component_parts = list()
		component_parts += new /obj/item/weapon/circuitboard/processor(null)
		component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
		component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
		RefreshParts()

/obj/machinery/processor/RefreshParts()
	for(var/obj/item/weapon/stock_parts/matter_bin/B in component_parts)
		rating_amount = B.rating
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		rating_speed = M.rating

/obj/machinery/processor/process()
	..()
	// The irony
	// To be clear, if it's grinding, then it can't suck them up
	if(processing)
		return
	var/mob/living/carbon/slime/picked_slime
	for(var/mob/living/carbon/slime/slime in range(1, src))
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

	visible_message("[picked_slime] is sucked into \the [src].")
	picked_slime.forceMove(src)

//RECIPE DATUMS
/datum/food_processor_process
	var/input
	var/output
	var/time = 40

/datum/food_processor_process/proc/process_food(loc, what, obj/machinery/processor/processor)
	if(src.output && loc && processor)
		for(var/i = 0, i < processor.rating_amount, i++)
			new src.output(loc)
	if(what)
		qdel(what)

/////////////////////////
/////OBJECT RECIPIES/////
/////////////////////////
/datum/food_processor_process/meat
	input = /obj/item/weapon/reagent_containers/food/snacks/meat
	output = /obj/item/weapon/reagent_containers/food/snacks/meatball

/datum/food_processor_process/potato
	input = "potato"
	output = /obj/item/weapon/reagent_containers/food/snacks/fries

/datum/food_processor_process/carrot
	input = "carrot"
	output = /obj/item/weapon/reagent_containers/food/snacks/carrotfries

/datum/food_processor_process/soybeans
	input = "soybeans"
	output = /obj/item/weapon/reagent_containers/food/snacks/soydope

/datum/food_processor_process/spaghetti
	input = /obj/item/weapon/reagent_containers/food/snacks/doughslice
	output = /obj/item/weapon/reagent_containers/food/snacks/spagetti
/////////////////////////
///END OBJECT RECIPIES///
/////////////////////////

/datum/food_processor_process/mob/process_food(loc, what, processor)
	..()

//////////////////////
/////MOB RECIPIES/////
//////////////////////
/datum/food_processor_process/mob/slime
	input = /mob/living/carbon/slime
	output = null

/datum/food_processor_process/mob/slime/process_food(loc, what, obj/machinery/processor/processor)
	var/mob/living/carbon/slime/S = what
	var/C = S.cores
	if(S.stat != DEAD)
		S.loc = loc
		S.visible_message("<span class='notice'>[S] crawls free of the processor!</span>")
		return
	for(var/i in 1 to (C+processor.rating_amount-1))
		new S.coretype(loc)
		feedback_add_details("slime_core_harvested","[replacetext(S.colour," ","_")]")
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
	var/obj/item/weapon/reagent_containers/glass/bucket/bucket_of_blood = new(loc)
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

/obj/machinery/processor/proc/select_recipe(var/X)
	for(var/Type in subtypesof(/datum/food_processor_process) - /datum/food_processor_process/mob)
		var/datum/food_processor_process/P = new Type()
		if(istype(X, /obj/item/weapon/reagent_containers/food/snacks/grown))
			var/obj/item/weapon/reagent_containers/food/snacks/grown/G = X
			if(G.seed.kitchen_tag != P.input)
				continue
		else if(!istype(X, P.input))
			continue
		return P
	return 0

/obj/machinery/processor/attackby(var/obj/item/O as obj, var/mob/user as mob, params)

	if(src.processing)
		to_chat(user, "<span class='warning'>\the [src] is already processing something!</span>")
		return 1

	if(default_deconstruction_screwdriver(user, "processor1", "processor", O))
		return

	if(exchange_parts(user, O))
		return

	if(default_unfasten_wrench(user, O))
		return

 	default_deconstruction_crowbar(O)

	var/obj/item/what = O

	if(istype(O, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = O
		what = G.affecting

	var/datum/food_processor_process/P = select_recipe(what)

	if(!P)
		to_chat(user, "<span class='warning'>That probably won't blend.</span>")
		return 1

	user.visible_message("<span class='notice'>\the [user] puts \the [what] into \the [src].</span>", \
		"<span class='notice'>You put \the [what] into \the [src].")

	user.drop_item()

	what.loc = src
	return

/obj/machinery/processor/attack_hand(var/mob/user as mob)
	if(stat & (NOPOWER|BROKEN)) //no power or broken
		return

	if(src.processing)
		to_chat(user, "<span class='warning'>\the [src] is already processing something!</span>")
		return 1

	if(src.contents.len == 0)
		to_chat(user, "<span class='warning'>\the [src] is empty.</span>")
		return 1
	src.processing = 1
	user.visible_message("[user] turns on [src].", \
		"<span class='notice'>You turn on [src].</span>", \
		"<span class='italics'>You hear a food processor.</span>")
	playsound(src.loc, 'sound/machines/blender.ogg', 50, 1)
	use_power(500)
	var/total_time = 0
	for(var/O in src.contents)
		var/datum/food_processor_process/P = select_recipe(O)
		if(!P)
			log_debug("The [O] in processor([src]) does not have a suitable recipe, but it was somehow put inside of the processor anyways.")
			continue
		total_time += P.time
	sleep(total_time / rating_speed)

	for(var/O in src.contents)
		var/datum/food_processor_process/P = select_recipe(O)
		if(!P)
			log_debug("The [O] in processor([src]) does not have a suitable recipe, but it was somehow put inside of the processor anyways.")
			continue
		P.process_food(src.loc, O, src)
	src.processing = 0

	src.visible_message("<span class='notice'>\the [src] has finished processing.</span>", \
		"<span class='notice'>\the [src] has finished processing.</span>", \
		"<span class='notice'>You hear a food processor stopping.</span>")
