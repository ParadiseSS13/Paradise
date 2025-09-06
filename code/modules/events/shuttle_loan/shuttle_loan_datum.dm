/// One of the potential shuttle loans you might receive.
/datum/shuttle_loan_situation
	/// Who sent the shuttle
	var/sender = "Central Command"
	/// What they said about it.
	var/announcement_text = "Unset announcement text"
	/// Supply points earned for taking the deal.
	var/bonus_points = 1000
	/// Small description of the loan for easier log reading.
	var/logging_desc

/datum/shuttle_loan_situation/New()
	. = ..()
	if(!logging_desc)
		stack_trace("No logging blurb set for [src.type]!")

/// Spawns paths added to `spawn_list`, and passes empty shuttle turfs so you can spawn more complicated things like dead bodies.
/datum/shuttle_loan_situation/proc/spawn_items(list/spawn_list, list/empty_shuttle_turfs)
	SHOULD_CALL_PARENT(FALSE)
	CRASH("Unimplemented get_spawned_items() on [src.type].")

/datum/shuttle_loan_situation/department_resupply
	sender = "Central Command Supply Department"
	announcement_text = "Seems we've ordered doubles of our department resupply packages this month. We'll be sending them to you."
	bonus_points = 0
	logging_desc = "Resupply packages"

/datum/shuttle_loan_situation/department_resupply/spawn_items(list/spawn_list, list/empty_shuttle_turfs)
	var/static/list/crate_types = list(
		/datum/supply_packs/emergency/evac,
		/datum/supply_packs/security/supplies,
		/datum/supply_packs/organic/food,
		/datum/supply_packs/emergency/weedcontrol,
		/datum/supply_packs/engineering/tools,
		/datum/supply_packs/engineering/engiequipment,
		/datum/supply_packs/science/robotics,
		/datum/supply_packs/science/plasma,
		/datum/supply_packs/medical/supplies
	)
	for(var/datum/supply_packs/crate in crate_types)
		var/datum/supply_packs/new_crate = new crate()
		new_crate.create_package(pick_n_take(empty_shuttle_turfs))

	for(var/i in 1 to 5)
		var/decal = pick(/obj/effect/decal/cleanable/flour, /obj/effect/decal/cleanable/blood/gibs/robot, /obj/effect/decal/cleanable/blood/oil)
		new decal(pick_n_take(empty_shuttle_turfs))

/datum/shuttle_loan_situation/syndiehijacking
	sender = "Central Command Counter-Intelligence"
	announcement_text = "The syndicate are trying to infiltrate your station. We let them hijack your cargo shuttle; you're saving us a headache."
	logging_desc = "Syndicate boarding party"

/datum/shuttle_loan_situation/syndiehijacking/spawn_items(list/spawn_list, list/empty_shuttle_turfs)
	spawn_list.Add(/mob/living/simple_animal/hostile/syndicate)
	spawn_list.Add(/mob/living/simple_animal/hostile/syndicate/ranged)
	if(prob(75))
		spawn_list.Add(/mob/living/simple_animal/hostile/syndicate/modsuit)
	if(prob(50))
		spawn_list.Add(/mob/living/simple_animal/hostile/syndicate/modsuit/ranged)

/datum/shuttle_loan_situation/lots_of_bees
	sender = "Central Command Janitorial Division"
	announcement_text = "One of our freighters carrying a bee shipment has been attacked by eco-terrorists. Clean up this mess."
	bonus_points = 800 // Toxin bees can be unbeelievably lethal
	logging_desc = "Shuttle full of bees"

/datum/shuttle_loan_situation/lots_of_bees/spawn_items(list/spawn_list, list/empty_shuttle_turfs)
	spawn_list.Add(/obj/effect/mob_spawn/human/corpse/syndicate)
	spawn_list.Add(/obj/effect/mob_spawn/human/corpse/random_species/cargo_tech)
	spawn_list.Add(/obj/effect/mob_spawn/human/corpse/random_species/cargo_tech)
	spawn_list.Add(/obj/effect/mob_spawn/human/corpse/random_species/security_officer)
	spawn_list.Add(/obj/item/honey_frame)
	spawn_list.Add(/obj/item/honey_frame)
	spawn_list.Add(/obj/item/honey_frame)
	spawn_list.Add(/obj/structure/beebox/unwrenched)
	spawn_list.Add(/obj/item/queen_bee/bought)
	spawn_list.Add(/obj/structure/closet/crate/hydroponics)
	var/datum/supply_packs/organic/hydroponics/beekeeping_fullkit/new_crate = new()
	new_crate.create_package(pick_n_take(empty_shuttle_turfs))

	for(var/i in 1 to 8)
		// A large influx of bees, directly into the cargo workplace
		spawn_list.Add(/mob/living/simple_animal/hostile/poison/bees)

	for(var/i in 1 to 5)
		var/decal = pick(/obj/effect/decal/cleanable/blood, /obj/effect/decal/cleanable/insectguts)
		new decal(pick_n_take(empty_shuttle_turfs))

	for(var/i in 1 to 10)
		var/casing = /obj/item/trash/spentcasing/bullet
		new casing(pick_n_take(empty_shuttle_turfs))

/datum/shuttle_loan_situation/jc_a_bomb
	sender = "Central Command Security Division"
	announcement_text = "We have discovered an active Syndicate bomb near our VIP shuttle's fuel lines. We're paying you to defuse it."
	bonus_points = 3000 // If you mess up, people die and the shuttle gets turned into swiss cheese
	logging_desc = "Shuttle with a ticking bomb"

/datum/shuttle_loan_situation/jc_a_bomb/spawn_items(list/spawn_list, list/empty_shuttle_turfs)
	spawn_list.Add(/obj/machinery/syndicatebomb/shuttle_loan)
	spawn_list.Add(/obj/item/paper/fluff/cargo/bomb)

/obj/item/paper/fluff/cargo/bomb
	name = "hastly scribbled note"
	info = "GOOD LUCK!"

/datum/shuttle_loan_situation/pizza_delivery
	sender = "Central Command Spacepizza Division"
	announcement_text = "It looks like a neighboring station accidentally delivered their pizza to you instead."
	bonus_points = 0
	logging_desc = "Pizza delivery"

/datum/shuttle_loan_situation/pizza_delivery/spawn_items(list/spawn_list, list/empty_shuttle_turfs)
	var/static/list/naughtypizza = list(/obj/item/pizzabox/pizza_bomb/autoarm)
	var/static/list/nicepizza = list(/obj/item/pizzabox/margherita, /obj/item/pizzabox/meat, /obj/item/pizzabox/vegetable, /obj/item/pizzabox/mushroom)
	for(var/i in 1 to 6)
		spawn_list.Add(pick(prob(5) ? naughtypizza : nicepizza))

/datum/shuttle_loan_situation/russian_party
	sender = "Central Command Soviet Outreach Program"
	announcement_text = "A group of angry Soviets want to have a party. We rented them your cargo shuttle as a venue."
	logging_desc = "Russian party squad"

/datum/shuttle_loan_situation/russian_party/spawn_items(list/spawn_list, list/empty_shuttle_turfs)
	var/datum/supply_packs/organic/party/party_crate = new()
	party_crate.create_package(pick_n_take(empty_shuttle_turfs))
	spawn_list.Add(/datum/supply_packs/organic/party)
	spawn_list.Add(/mob/living/basic/soviet)
	spawn_list.Add(/mob/living/basic/soviet/ranged/mosin)
	spawn_list.Add(/mob/living/basic/bear)
	if(prob(75))
		spawn_list.Add(/mob/living/basic/soviet)
	if(prob(50))
		spawn_list.Add(/mob/living/basic/bear)

/datum/shuttle_loan_situation/spider_gift
	sender = "Central Command Diplomatic Corps"
	announcement_text = "The Spider Clan has sent us a mysterious gift. We shipped it to you to see what's inside."
	logging_desc = "Shuttle full of spiders"

/datum/shuttle_loan_situation/spider_gift/spawn_items(list/spawn_list, list/empty_shuttle_turfs)
	spawn_list.Add(/mob/living/basic/giant_spider)
	spawn_list.Add(/mob/living/basic/giant_spider)
	spawn_list.Add(/mob/living/basic/giant_spider/nurse)
	if(prob(50))
		spawn_list.Add(/mob/living/basic/giant_spider/hunter)

	var/turf/victim_turf = pick_n_take(empty_shuttle_turfs)

	new /obj/effect/decal/remains/human(victim_turf)
	new /obj/item/clothing/shoes/jackboots/noisy(victim_turf)
	new /obj/item/clothing/mask/balaclava(victim_turf)

	for(var/i in 1 to 5)
		var/turf/web_turf = pick_n_take(empty_shuttle_turfs)
		new /obj/structure/spider/stickyweb(web_turf)

/datum/shuttle_loan_situation/mineral_haul
	sender = "Central Command Supply Department"
	announcement_text = "Another station's mining division has struck a mineral motherlode. We'll be sending your station some of the haul."
	bonus_points = 0
	logging_desc = "Mineral haul"

/datum/shuttle_loan_situation/mineral_haul/spawn_items(list/spawn_list, list/empty_shuttle_turfs)
	var/static/list/crate_types = list(
		/datum/supply_packs/materials/metal50,
		/datum/supply_packs/materials/glass50,
		/datum/supply_packs/materials/sandstone30,
	)
	for(var/datum/supply_packs/crate in crate_types)
		var/datum/supply_packs/new_crate = new crate()
		new_crate.create_package(pick_n_take(empty_shuttle_turfs))

	var/static/list/mineral_types = list(
		/obj/item/stack/sheet/mineral/diamond,
		/obj/item/stack/sheet/mineral/uranium,
		/obj/item/stack/sheet/mineral/plasma,
		/obj/item/stack/sheet/mineral/gold,
		/obj/item/stack/sheet/mineral/bananium,
		/obj/item/stack/sheet/mineral/tranquillite,
		/obj/item/stack/sheet/mineral/platinum,
		/obj/item/stack/sheet/mineral/palladium,
		/obj/item/stack/sheet/mineral/iridium,
		/obj/item/stack/sheet/mineral/silver
	)
	for(var/i in 1 to 5)
		var/mineral_type = pick(mineral_types)
		var/obj/item/stack/sheet/mineral/new_mineral = new mineral_type()
		new_mineral.amount = 10
		new new_mineral(pick_n_take(empty_shuttle_turfs))

/datum/shuttle_loan_situation/honk
	sender = "Central Command Entertainment Division"
	announcement_text = "A surplus of clowns were sent to us from the Clown College. You should be able to find some use of them."
	bonus_points = 500 // If you mess up, people die and the shuttle gets turned into swiss cheese
	logging_desc = "Shuttle with clowns"

/datum/shuttle_loan_situation/honk/spawn_items(list/spawn_list, list/empty_shuttle_turfs)
	spawn_list.Add(/obj/machinery/syndicatebomb/badmin/clown/shuttle_loan)
	spawn_list.Add(/obj/item/paper/fluff/cargo/bomb)
	for(var/i in 1 to 4)
		spawn_list.Add(/mob/living/basic/clown)
