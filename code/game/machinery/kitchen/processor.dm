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


//RECIPE DATUMS
/datum/food_processor_process
	var/input
	var/output
	var/time = 40

/datum/food_processor_process/proc/process(loc, what)
	if (src.output && loc)
		new src.output(loc)
	if (what)
		del(what)

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

/datum/food_processor_process/wheat
	input = "wheat"
	output = /obj/item/weapon/reagent_containers/food/snacks/flour

/datum/food_processor_process/spaghetti
	input = /obj/item/weapon/reagent_containers/food/snacks/flour
	output = /obj/item/weapon/reagent_containers/food/snacks/spagetti
/////////////////////////
///END OBJECT RECIPIES///
/////////////////////////

/datum/food_processor_process/mob/process(loc, what)
	..()

//////////////////////
/////MOB RECIPIES/////
//////////////////////
/datum/food_processor_process/mob/slime
	input = /mob/living/carbon/slime
	output = null

/datum/food_processor_process/mob/slime/process(loc, what)
	var/mob/living/carbon/slime/S = what
	var/C = S.cores
	if(S.stat != DEAD)
		S.loc = loc
		S.visible_message("<span class='notice'>[S] crawls free of the processor!</span>")
		return
	for(var/i = 1, i <= C, i++)
		new S.coretype(loc)
		feedback_add_details("slime_core_harvested","[replacetext(S.colour," ","_")]")
	..()

/datum/food_processor_process/mob/monkey
	input = /mob/living/carbon/monkey
	output = null

/datum/food_processor_process/mob/monkey/process(loc, what)
	var/mob/living/carbon/monkey/O = what
	if (O.client) //grief-proof
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
	for (var/Type in typesof(/datum/food_processor_process) - /datum/food_processor_process - /datum/food_processor_process/mob)
		var/datum/food_processor_process/P = new Type()
		if(istype(X, /obj/item/weapon/reagent_containers/food/snacks/grown))
			var/obj/item/weapon/reagent_containers/food/snacks/grown/G = X
			if(G.seed.kitchen_tag != P.input)
				continue
		else if (!istype(X, P.input))
			continue
		return P
	return 0

/obj/machinery/processor/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	if(!istype(O))
		return

	var/obj/item/what = O

	if(src.processing)
		user << "<span class='warning'>\the [src] is already processing something!</span>"
		return 1

	if(src.contents.len > 0) //TODO: several items at once? several different items?
		user << "<span class='warning'>Something is already in the processing chamber.</span>"
		return 1


	if (istype(O, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = O
		what = G.affecting

	var/datum/food_processor_process/P = select_recipe(what)

	if (!P)
		user << "<span class='warning'>That probably won't blend.</span>"
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
		user << "<span class='warning'>\the [src] is already processing something!</span>"
		return 1

	if(src.contents.len == 0)
		user << "<span class='warning'>\the [src] is empty.</span>"
		return 1

	for(var/O in src.contents)
		var/datum/food_processor_process/P = select_recipe(O)
		if (!P)
			log_admin("DEBUG: WARNING: The [O] in processor([src]) does not have a suitable recipe, but it was somehow put inside of the processor anyways.") //-rastaf0
			continue

		src.processing = 1
		user.visible_message("<span class='notice'> \the [user] turns on \the [src].", \
			"<span class='notice'>You turn on \the [src].</span>", \
			"<span class='notice'>You hear a food processor.</span>")

		playsound(src.loc, 'sound/machines/blender.ogg', 50, 1)
		use_power(500)

		sleep(P.time)

		P.process(src.loc, O)
		src.processing = 0

	src.visible_message("<span class='notice'>\the [src] has finished processing.</span>", \
		"<span class='notice'>\the [src] has finished processing.</span>", \
		"<span class='notice'>You hear a food processor stopping.</span>")
