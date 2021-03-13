/*
Warping extracts crossbreed
put up a rune with bluespace effects, lots of those runes are fluff or act as a passive buff, others are just griefing tools
*/

/obj/item/slimecross/warping
	name = "warped extract"
	desc = "It just won't stay in place."
	icon_state = "warping"
	effect = "warping"
	colour = "grey"
	var/obj/effect/warped_rune/runepath ///what runes will be drawn depending on the crossbreed color
	var/warp_charge = 1 /// the number of "charge" a bluespace crossbreed start with
	var/max_charge = 1 ///max number of charge, might be different depending on the crossbreed
	var/storing_time = 15 ///time it takes to store the rune back into the crossbreed
	var/drawing_time = 15 ///time it takes to draw the rune

/obj/effect/warped_rune
	name = "warped rune"
	desc = "An unstable rune born of the depths of bluespace"
	icon = 'icons/hispania/obj/slimecrossing.dmi'
	icon_state = "greyspace_rune"
	move_resist = INFINITY  //here to avoid the rune being moved since it only sets it's turf once when it's drawn. doesn't include admin fuckery.
	anchored = TRUE
	layer = MID_TURF_LAYER
	resistance_flags = FIRE_PROOF
	var/storing_time = 5 ///is only used for bluespace crystal erasing as of now
	var/turf/rune_turf ///Nearly all runes needs to know which turf they are on
	var/cooldown = 0 ///starting cooldown of the rune.
	var/max_cooldown = 10 SECONDS ///duration of the cooldown for the rune only applies to certain runes

/obj/item/slimecross/warping/examine()
	desc = "It just won't stay in place. it has [warp_charge] charge left"
	return ..()

///runes can also be deleted by bluespace crystals relatively fast as an alternative to cleaning them.
/obj/effect/warped_rune/attackby(obj/item/used_item, mob/user)
	. = ..()
	if(!istype(used_item,/obj/item/stack/sheet/bluespace_crystal) && !istype(used_item,/obj/item/stack/ore/bluespace_crystal))
		return

	var/obj/item/stack/space_crystal = used_item
	if(do_after(user, storing_time,target = src)) //the time it takes to nullify it depends on the rune too
		to_chat(user, "<span class='notice'>You nullify the effects of the rune with the bluespace crystal!</span>")
		qdel(src)
		space_crystal.amount--
		playsound(src, 'sound/effects/phasein.ogg', 20, TRUE)

		if(space_crystal.amount <= 0)
			qdel(space_crystal)

/obj/effect/warped_rune/acid_act()
	. = ..()
	visible_message("<span class='warning'>[src] has been dissolved by the acid</span>")
	playsound(src, 'sound/items/welder.ogg', 150, TRUE)
	qdel(src)

///nearly all runes use their turf in some way so we set rune_turf to their turf automatically, the rune also start on cooldown if it uses one.
/obj/effect/warped_rune/Initialize()
	. = ..()
	rune_turf = get_turf(src)
	RegisterSignal(rune_turf, COMSIG_COMPONENT_CLEAN_ACT, .proc/clean_rune)
	cooldown = world.time + max_cooldown

/obj/effect/warped_rune/proc/clean_rune()
	qdel(src)

///using the extract on the floor will "draw" the rune.
/obj/item/slimecross/warping/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return

	if(isturf(target) && locate(/obj/effect/warped_rune) in target) //check if the target is a floor and if there's a rune on said floor
		to_chat(user, "<span class='warning'>There is already a bluespace rune here!</span>")
		return

	if(istype(target,/turf/space) && !istype(target, runepath))
		to_chat(user, "<span class='warning'>you cannot draw a rune here!</span>")
		return

	if(istype(target, runepath)) //checks if the target is a rune and then if you can store it
		if(warp_charge >= max_charge)
			to_chat(user, "<span class='warning'>[src] is already full!</span>")
			return

		else if(do_after(user, storing_time,target = target) && warp_charge < max_charge)
			warping_crossbreed_absorb(target, user)
			return

	if(warp_charge < 1) //check if we have at least 1 charge left.
		to_chat(user, "<span class='warning'>[src] is empty!</span>")
		return

	if(do_after(user, drawing_time,target = target))
		if(warp_charge >= 1 && !locate(/obj/effect/warped_rune) in target) //check one last time if a rune has been drawn during the do_after and if there's enough charges left
			warping_crossbreed_spawn(target,user)

///spawns the rune, taking away one rune charge
/obj/item/slimecross/warping/proc/warping_crossbreed_spawn(atom/target, mob/user)
	playsound(target, 'sound/effects/slosh.ogg', 20, TRUE)
	warp_charge--
	new runepath(target)
	to_chat(user, "<span class='notice'>You carefully draw the rune with [src].</span>")

///absorb the rune into the crossbreed adding one more charge to the crossbreed.
/obj/item/slimecross/warping/proc/warping_crossbreed_absorb(atom/target, mob/user)
	to_chat(user, "<span class='notice'>You store the rune in [src].</span>")
	qdel(target)
	warp_charge++
	return

/* Creates a rune that will periodically absorb slime extract of the same color. After 8 extracts have been absorbed the rune will spawn a slime of that color*/

/obj/item/slimecross/warping/grey
	name = "greyspace crossbreed"
	colour = "grey"
	effect_desc = "Creates a rune. Extracts that are on the rune are absorbed, 8 extracts produces an adult slime of that color."
	runepath = /obj/effect/warped_rune/greyspace

/obj/effect/warped_rune/greyspace
	name = "greyspace rune"
	desc = "Death is merely a setback, anything can be rebuilt given the right components"
	icon_state = "greyspace_rune"
	max_cooldown = 3 SECONDS
	var/absorbed_extracts = 0 ///number of slime extract currently absorbed by the rune
	var/mob/living/simple_animal/slime/spawned_slime///mob path of the slime spawned by the rune
	var/extractype = FALSE///extractype is used to remember the type of the extract on the rune

/obj/effect/warped_rune/greyspace/Initialize()
	. = ..()
	START_PROCESSING(SSprocessing, src)

/obj/effect/warped_rune/greyspace/process()
	if(cooldown < world.time)
		cooldown = world.time + max_cooldown
		slimerevival()

///Makes a slime of the color of the extract that was put on the rune.can only take one type of extract between slime spawning.
/obj/effect/warped_rune/greyspace/proc/slimerevival()
	for(var/obj/item/slime_extract/extract in rune_turf)
		if(extract.color_slime == extractype || !extractype) //check if the extract is the first one or of the right color.
			extractype = extract.color_slime
			qdel(extract)//vores the slime extract
			playsound(rune_turf, 'sound/effects/splat.ogg', 20, TRUE)
			absorbed_extracts++
			if (absorbed_extracts < 8)
				return

			playsound(rune_turf, 'sound/effects/splat.ogg', 20, TRUE)
			spawned_slime = new(rune_turf, extractype)  //spawn a slime from the extract's color
			spawned_slime.amount_grown = SLIME_EVOLUTION_THRESHOLD
			spawned_slime.Evolve() //slime starts as an adult
			absorbed_extracts = 0
			extractype = FALSE // reset extractype to FALSE to allow a new extract type
			RegisterSignal(spawned_slime, COMSIG_PARENT_QDELETING, .proc/delete_slime)

/obj/effect/warped_rune/greyspace/proc/delete_slime()
	spawned_slime = null

/obj/effect/warped_rune/greyspace/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	extractype = null
	return ..()

/*The orange rune warp basically ignites whoever walks on it,the fire will teleport you at random as long as you are on fire*/

/obj/item/slimecross/warping/orange
	desc = "Creates a rune "
	colour = "orange"
	runepath = /obj/effect/warped_rune/orangespace
	effect_desc = "Creates a rune burning with bluespace fire, anyone walking into the rune will ignite"
	drawing_time = 15 SECONDS

/obj/effect/warped_rune/orangespace
	desc = "When all is reduced to ash, it shall be reborn from the depth of bluespace."
	icon_state = "bluespace_fire"
	max_cooldown = 5 SECONDS

///teleport people and put them on fire if they run into the rune.
/obj/effect/warped_rune/orangespace/Crossed(atom/movable/burned)
	. = ..()
	if(!locate(/obj/effect/hotspot) in rune_turf) //will create a hotspot to burn items passing through too.
		new /obj/effect/hotspot(rune_turf)

	if(istype(burned,/mob/living/carbon/human))
		var/mob/living/carbon/human/burning = burned
		burning.adjust_fire_stacks(10)
		burning.IgniteMob()

/* the blue warp rune  keeps a tile slippery CONSTANTLY by adding lube over it. Excellent if you hate standing up.*/

/obj/item/slimecross/warping/blue
	colour = "blue"
	runepath = /obj/effect/warped_rune/cyanspace //we'll call the blue rune cyanspace to not mix it up with actual bluespace rune
	effect_desc = "creates a rune that constantly wet itself with slippery lube as long as the rune is up"

/obj/effect/warped_rune/cyanspace
	icon_state = "slipperyspace"
	desc = "You will crawl like the rest. Standing up is not an option."

/obj/effect/warped_rune/cyanspace/Initialize()
	. = ..()
	START_PROCESSING(SSprocessing, src)

/obj/effect/warped_rune/cyanspace/process()
	slippery_rune(rune_turf)

/obj/effect/warped_rune/cyanspace/proc/slippery_rune(turf/lube_turf)
	if(isfloorturf(lube_turf))
		var/turf/simulated/F = lube_turf
		F.MakeSlippery(TURF_WET_LUBE, 10 SECONDS)

/obj/effect/warped_rune/cyanspace/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	.=..()

/*The purple warp rune makes advanced burn kit and advanced trauma kit if you put cloth or plastic on it. */

/obj/item/slimecross/warping/purple
	colour = "purple"
	runepath = /obj/effect/warped_rune/purplespace
	effect_desc = "Draws a rune that transforms plastic into advanced burn kit and cloth into advanced trauma kit"

/obj/effect/warped_rune/purplespace
	desc = "When all that was left were plastic walls and the clothes on their back, they knew what they had to do."
	icon_state = "purplespace"
	max_cooldown = 3 SECONDS
	var/obj/item/stack/medical/ointment/advanced/advanced///object path of the advanced burn kit spawned
	var/obj/item/stack/medical/bruise_pack/advanced/burn///object path of the advanced trauma kit spawned

/obj/effect/warped_rune/purplespace/Initialize()
	. = ..()
	START_PROCESSING(SSprocessing, src)

/obj/effect/warped_rune/purplespace/process()
	if(cooldown < world.time)
		cooldown = world.time + max_cooldown
		transmute_heal()

///transforms cloth and plastic into advanced trauma kit and advanced burn kit
/obj/effect/warped_rune/purplespace/proc/transmute_heal()
	for(var/obj/item/stack/sheet/plastic/plastic in rune_turf)  //replace plastic with advanced burn kit
		if(plastic.amount < 2)
			break

		plastic.use(2)
		advanced = new (rune_turf,1)
		playsound(rune_turf, 'sound/effects/splat.ogg', 20, TRUE)

	for(var/obj/item/stack/sheet/cloth/cloth in rune_turf) //replace cloth with ointment
		if(cloth.amount < 2)
			return

		cloth.use(2)
		burn = new(rune_turf, 1)
		playsound(rune_turf, 'sound/effects/splat.ogg', 20, TRUE)

/obj/effect/warped_rune/purplespace/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	.=..()

/*Metal rune : makes an invisible wall. actually I lied, the rune is the wall.*/

/obj/item/slimecross/warping/metal
	colour = "metal"
	runepath = /obj/effect/warped_rune/metalspace
	effect_desc = "Draws a rune that prevents passage above it, takes longer to store and draw than other runes."
	drawing_time = 50  //Longer to draw like most griefing runes
	storing_time = 25
	max_charge = 4 //higher to allow a wider degree of fuckery, still takes a long ass time to draw but you can draw multiple ones at once.
	warp_charge = 4

//It's a wall what do you want from me
/obj/effect/warped_rune/metalspace
	desc = "Words are powerful things, they can stop someone dead in their tracks if used in the right way"
	icon_state = "metal_space"
	density = TRUE
	storing_time = 10 //faster to destroy with the bluespace crystal than with the crossbreed

/*  Yellow rune space acts as an infinite generator, works without power and anywhere, recharges the APC of the room it's in and any battery fueled things.*/

/obj/item/slimecross/warping/yellow
	colour = "yellow"
	runepath = /obj/effect/warped_rune/yellowspace
	effect_desc = "Draws a rune that infinitely recharge any items as long as they have a battery. It will also passively recharge the APC of the room"

/obj/effect/warped_rune/yellowspace
	desc = "Where does all this energy come from? Who knows,the process does not matter, only the result."
	icon_state = "elec_rune"
	max_cooldown = 5 SECONDS

/obj/effect/warped_rune/yellowspace/Initialize()
	. = ..()
	START_PROCESSING(SSprocessing, src)


/obj/effect/warped_rune/yellowspace/process()
	if(cooldown > world.time)
		return

	var/area/rune_area = get_area(rune_turf)
	cooldown = world.time + max_cooldown

	for(var/obj/recharged in rune_turf) //recharges items on the rune
		electrishare(recharged)

	for(var/mob/living/silicon/robot/charged_borg in rune_turf)
		borg_electrishare(charged_borg)//borgs use a different get_cell() so they use a different proc like the special needs child they are

	for(var/obj/machinery/power/apc/apc_recharged in rune_area) //recharges the APC of the room
		electrishare(apc_recharged)

///charge the battery of an item by 20% every time it's called. God bless get_cell()
/obj/effect/warped_rune/yellowspace/proc/electrishare(obj/recharged)
	if(recharged.get_cell()) //check if the item has a cell
		var/obj/item/stock_parts/cell/battery = recharged.get_cell()
		if(battery.charge >= battery.maxcharge) //don't charge if the battery is full
			return

		battery.charge += battery.maxcharge * 0.2
		if(battery.charge > battery.maxcharge)
			battery.charge = battery.maxcharge
		battery.update_icon()
		recharged.update_icon()

///the same thing as electrishare but with borgs, 20% of the borg's battery rechared every 5 seconds.
/obj/effect/warped_rune/yellowspace/proc/borg_electrishare(mob/living/silicon/robot/charged_borg)
	if(charged_borg.get_cell()) //check if the item has a cell
		var/obj/item/stock_parts/cell/battery = charged_borg.get_cell()
		if(battery.charge >= battery.maxcharge) //don't charge if the battery is full
			return

		battery.charge += battery.maxcharge * 0.2
		if(battery.charge > battery.maxcharge)
			battery.charge = battery.maxcharge //we don't need to update the cell icon since literally no one can see the battery inside the borg anyway.

/obj/effect/warped_rune/yellowspace/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	.=..()

/* Dark purple crossbreed, Fill up any beaker like container with 50 unit of plasma dust every 30 seconds  */

/obj/item/slimecross/warping/darkpurple
	colour = "dark purple"
	runepath = /obj/effect/warped_rune/darkpurplespace
	effect_desc = "Makes a rune that will periodically create plasma dust,to harvest it simply put a beaker of some kind over the rune."

/obj/effect/warped_rune/darkpurplespace
	icon = 'icons/hispania/obj/slimecrossing.dmi'
	icon_state = "plasma_crystal"
	desc = "The purple ocean would only grow bigger with time."
	max_cooldown = 30 SECONDS //creates 50 unit every 30 seconds

/obj/effect/warped_rune/darkpurplespace/Initialize()
	. = ..()
	START_PROCESSING(SSprocessing, src)

/obj/effect/warped_rune/darkpurplespace/process()
	if(cooldown < world.time)
		cooldown = world.time + max_cooldown
		dust_maker()

/obj/effect/warped_rune/darkpurplespace/proc/dust_maker()
	for(var/obj/item/reagent_containers/glass/beaker in rune_turf)
		beaker.reagents.add_reagent("plasma_dust",  30)

/*People who step on the dark blue rune will suddendly get very cold,pretty straight forward.*/

/obj/item/slimecross/warping/darkblue
	colour = "dark blue"
	runepath = /obj/effect/warped_rune/darkbluespace
	effect_desc = "Draws a rune creating an unbearable cold above the rune."

/obj/effect/warped_rune/darkbluespace
	desc = "Cold,so cold, why does the world always feel so cold?"
	icon_state = "cold_rune"

/obj/effect/warped_rune/darkbluespace/Initialize()
	. = ..()
	START_PROCESSING(SSprocessing, src)
	RegisterSignal(rune_turf,COMSIG_ATOM_ENTERED,.proc/cold_tile)

/obj/effect/warped_rune/darkbluespace/process() //will keep the person on the tile cold for good measure
	cold_tile()

///it makes people that step on the tile very cold.
/obj/effect/warped_rune/darkbluespace/proc/cold_tile()
	for(var/mob/living/carbon/human in rune_turf)
		human.adjust_bodytemperature(-1000) //Not enough to crit anyone not already weak to cold, might need serious rebalance if cold damage is reworked.

/obj/effect/warped_rune/darkbluespace/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	.=..()

/* makes a rune that absorb food, whenever someone step on the rune the nutrition come back to them until they are full.*/

/obj/item/slimecross/warping/silver
	colour = "silver"
	effect_desc = "Draws a rune that will absorb nutriment from foods that are above it and then redistribute it to anyone passing by."
	runepath = /obj/effect/warped_rune/silverspace

/obj/effect/warped_rune/silverspace
	desc = "Feed me and I will feed you back, such is the deal."
	icon_state = "food_rune"
	var/nutriment = 0 ///Used to remember how much food/nutriment has been absorbed by the rune

/obj/effect/warped_rune/silverspace/Initialize()
	. = ..()
	START_PROCESSING(SSprocessing, src)

/obj/effect/warped_rune/silverspace/examine()
	desc = "Feed me and I will feed you back. I currently hold [nutriment] units of nutrition."
	return ..()

///any food put on the rune with nutrients will have said nutrients absorbed by the rune. Then the nutrients will be redirected to the people on the rune
/obj/effect/warped_rune/silverspace/process()
	for(var/obj/item/reagent_containers/food/nutriment_source in rune_turf) //checks if there's snacks on the rune.and then vores the food
		for(var/datum/reagent/consumable/nutriment/nutr in nutriment_source.reagents.reagent_list)
			nutriment += round((nutr.nutriment_factor * nutr.volume) / (nutr.metabolization_rate)) //the value of nutrition for the nutriment unit
			nutriment_source.reagents.remove_reagent(nutr.id,1)

	for(var/mob/living/carbon/human/person_fed in rune_turf)
		if((person_fed.nutrition >= NUTRITION_LEVEL_WELL_FED) || (nutriment <= 0)) //don't need to feed a perfectly well-fed boi
			return

		var/nutrition_to_add = min(nutriment, max(round(NUTRITION_LEVEL_FULL - 1 - person_fed.nutrition), 0))
		person_fed.nutrition += nutrition_to_add
		nutriment -= nutrition_to_add

/obj/effect/warped_rune/silverspace/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	nutriment = null
	return ..()

/* Bluespace rune,reworked so that the last person that walked on the rune will swap place with the next person stepping on it*/


/obj/item/slimecross/warping/bluespace
	colour = "bluespace"
	runepath = /obj/effect/warped_rune/bluespace
	effect_desc = "Puts up a rune that will swap the next two person that walk on the rune."

/obj/effect/warped_rune/bluespace
	desc = "Everyone is everywhere at once, yet so far away from each other"
	icon_state = "bluespace_rune"
	max_cooldown = 3 SECONDS //only here to avoid spam lag
	var/mob/living/carbon/first_person /// first person to run into the rune
	var/mob/living/carbon/second_person ///second person that run into the rune

///the first two person that stepped on the rune swap places after the second person stepped on it.
/obj/effect/warped_rune/bluespace/Crossed(atom/movable/crossing)
	. = ..()
	if(cooldown > world.time) //checks if 2 seconds have passed to avoid spam.
		return

	cooldown = max_cooldown + world.time
	if(!istype(crossing,/mob/living/carbon/human))
		return

	if(!first_person)
		first_person = crossing //remember who stepped in so we can teleport them later.
		return

	if(crossing == first_person)
		return

	second_person = crossing
	do_teleport(second_person, first_person)//swap both of their place.
	do_teleport(first_person, rune_turf)
	first_person = null

/obj/effect/warped_rune/bluespace/Destroy()
	first_person = null
	second_person = null
	.=..()

///colors whatever steps on the rune randomly

/obj/item/slimecross/warping/pyrite
	colour = "pyrite"
	runepath = /obj/effect/warped_rune/pyritespace
	effect_desc = "draws a rune that will randomly color whatever steps on it"

/obj/effect/warped_rune/pyritespace
	desc = "Who shall we be today? they asked, but not even the canvas would answer."
	icon_state = "colorune"

///colors whatever steps on the rune randomly
/obj/effect/warped_rune/pyritespace/Crossed(atom/movable/colored)
	. = ..()
	if(!istype(colored,/mob/living) && (!istype(colored,/obj/item)))
		return

	colored.color = rgb(rand(0,255),rand(0,255),rand(0,255))

/*Acts as a bunker making anything into the rune immune to outside explosions and gas leaks. doesn't work if the epicenter of the explosion is IN the rune */

/obj/item/slimecross/warping/oil
	colour = "oil"
	runepath = /obj/effect/warped_rune/oilspace
	effect_desc = "protects anything on the rune from explosions unless the rune is in the center of the explosion."

/obj/effect/warped_rune/oilspace
	icon_state = "oil_rune"
	desc = "The world is ending, but we have one last trick up our sleeve, we will survive."
	var/list/bunker_list ///used to remember the oilspace_bunker specific to this rune

/obj/effect/oilspace_bunker
	icon_state = "barrier"
	desc = "Thicc."

/obj/effect/oilspace_bunker //we'll surround the rune with these so it "blocks" nearby explosions. Although only the rune itself is 100% protected
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	invisibility = TRUE //no one can see those
	anchored = TRUE
	explosion_block = INFINITY
	move_resist = INFINITY //we need it to stay in the same place until it's deleted.
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/effect/oilspace_bunker/New()
	..()
	air_update_turf(TRUE)

/obj/effect/oilspace_bunker/CanAtmosPass(turf/T)
	return FALSE

/obj/effect/warped_rune/oilspace/Initialize()
	. = ..()
	for(var/turf/bunker_turf in range(1,rune_turf))
		var/obj/effect/oilspace_bunker/bunker_wall = new /obj/effect/oilspace_bunker(bunker_turf)
		LAZYADD(bunker_list, bunker_wall)

/obj/effect/warped_rune/oilspace/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	for(var/bunker_wall in bunker_list)
		LAZYREMOVE(bunker_list, bunker_wall)
		qdel(bunker_wall)
	bunker_list = null
	return ..()

/* black space rune : will swap out the species of the two next person walking on the rune  */

/obj/item/slimecross/warping/black
	colour = "black"
	runepath = /obj/effect/warped_rune/blackspace
	effect_desc = "Will swap the species of the first two humanoids that walk on the rune. Also works on corpses."
	drawing_time = 10 SECONDS

/obj/effect/warped_rune/blackspace
	icon_state = "cursed_rune"
	desc = "Your body is the problem, limited, so very very limited."
	var/mob/living/carbon/human/first_person ///first person to step on the rune
	var/mob/living/carbon/human/second_person ///second person to step on the rune
	var/stepped_on = FALSE ///here to check if someone already stepped on the rune

/obj/effect/warped_rune/blackspace/Initialize()
	. = ..()
	cooldown = 0 //doesn't start on cooldown like most runes
	for(var/atom/movable/crossing in rune_turf)
		Crossed(crossing)

///will swap the species of the first two human or human subset that walk on the rune
/obj/effect/warped_rune/blackspace/Crossed(atom/movable/crossing)
	. = ..()

	if(!istype(crossing,/mob/living/carbon/human))
		return

	swap_species(crossing)

/obj/effect/warped_rune/blackspace/Destroy()
	first_person = null
	second_person = null
	return ..()

/obj/effect/warped_rune/blackspace/proc/swap_species(atom/movable/crossing)
	if(cooldown > world.time) //here to avoid spam/lag
		to_chat(crossing, "<span class='warning'>The rune needs a little more time before processing your DNA!</span>")
		return

	var/mob/living/carbon/human/crosser = crossing
	if(!stepped_on)
		first_person = crosser
		RegisterSignal(first_person, COMSIG_PARENT_QDELETING, .proc/delete_person_reference, first_person)
		stepped_on = TRUE
		return

	if(crosser == first_person || crosser.stat == DEAD)
		return

	second_person = crosser
	var/first_dna = first_person.dna.species.type
	var/second_dna = second_person.dna.species.type
	second_person.set_species(first_dna)  //swap the species
	first_person.set_species(second_dna)
	stepped_on = FALSE
	cooldown = max_cooldown + world.time //the default max cooldown is of 10 seconds

/obj/effect/warped_rune/blackspace/proc/delete_person_reference(mob/destroyed_person)
	if(destroyed_person == first_person)
		first_person = null
	else if(destroyed_person == second_person)
		second_person = null

/obj/effect/warped_rune/blackspace/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	.=..()
