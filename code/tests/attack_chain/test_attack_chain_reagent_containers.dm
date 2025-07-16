/datum/game_test/room_test/attack_chain_applicator/Run()
	var/datum/test_puppeteer/player = new(src)
	var/datum/test_puppeteer/target = player.spawn_puppet_nearby()
	var/obj/item/reagent_containers/applicator/mender = player.spawn_obj_in_hand(/obj/item/reagent_containers/applicator/burn)

	mender.delay = 0
	target.puppet.apply_damage(1, BURN)
	player.click_on(target)
	TEST_ASSERT(target.check_attack_log("Automends with"), "player failed to use mender on target")
	TEST_ASSERT_EQUAL(target.puppet.health, target.puppet.getMaxHealth(), "mender failed to mend damage")

	player.puppet.attack_log_old = null
	player.puppet.apply_damage(1, BURN)
	player.use_item_in_hand()
	TEST_ASSERT(player.check_attack_log("Automends with"), "player failed to use mender on target")
	TEST_ASSERT_EQUAL(player.puppet.health, player.puppet.getMaxHealth(), "mender failed to mend damage")

	mender.reagents.total_volume = 0
	player.click_on(target)
	TEST_ASSERT_LAST_CHATLOG(player, "[mender] is empty")

	var/obj/item/storage/backpack/backpack = player.spawn_obj_nearby(/obj/item/storage/backpack)
	player.click_on(backpack)
	TEST_ASSERT_LAST_CHATLOG(player, "You put")

	// ToasTODO: Add an AltClick test

// Test recipe for testing reagent containers in old kitchen machinery
/datum/recipe/microwave/test_recipe
	duplicate = FALSE
	reagents = list("sodiumchloride" = 50)
	items = list(/obj/item/food/grown/apple)
	result = /obj/item/food/badrecipe

/datum/game_test/room_test/attack_chain_condiment/Run()
	var/datum/test_puppeteer/player = new(src)
	var/obj/item/reagent_containers/saltshaker = player.spawn_obj_in_hand(/obj/item/reagent_containers/condiment/saltshaker)

	var/obj/structure/reagent_dispensers/watertank = player.spawn_obj_nearby(/obj/structure/reagent_dispensers/watertank)
	player.click_on(watertank)
	TEST_ASSERT_LAST_CHATLOG(player, "[saltshaker] is full!")

	var/obj/machinery/kitchen_machine/microwave = player.spawn_obj_nearby(/obj/machinery/kitchen_machine/microwave)
	player.click_on(microwave)
	TEST_ASSERT_ANY_CHATLOG(player, "You transfer")
	TEST_ASSERT_NOT_CHATLOG(player, "You hit")

	player.click_on(player)
	TEST_ASSERT_LAST_CHATLOG(player, "You swallow some")

	saltshaker.reagents.total_volume = 0
	player.click_on(microwave)
	TEST_ASSERT_LAST_CHATLOG(player, "is empty!")
	player.click_on(player)
	TEST_ASSERT_LAST_CHATLOG(player, "None of [saltshaker] left, oh no!")

	player.click_on(watertank)
	TEST_ASSERT_LAST_CHATLOG(player, "You fill")

	var/obj/item/storage/backpack = player.spawn_obj_nearby(/obj/item/storage/backpack)
	player.click_on(backpack)
	TEST_ASSERT_LAST_CHATLOG(player, "You put")

	var/obj/item/food/sliced/margherita_pizza = player.spawn_obj_nearby(/obj/item/food/sliced/margherita_pizza)
	player.spawn_obj_in_hand(/obj/item/reagent_containers/condiment/pack)
	player.click_on(margherita_pizza)
	TEST_ASSERT_LAST_CHATLOG(player, "You tear open")

	player.spawn_obj_in_hand(/obj/item/reagent_containers/condiment/pack)
	player.click_on(backpack)
	TEST_ASSERT_LAST_CHATLOG(player, "You put")

/datum/game_test/room_test/attack_chain_drinks/Run()
	var/datum/test_puppeteer/player = new(src)
	var/obj/structure/reagent_dispensers/watertank/watertank = player.spawn_obj_nearby(/obj/structure/reagent_dispensers/watertank)
	var/obj/item/reagent_containers/glass/bucket/bucket = player.spawn_obj_nearby(/obj/item/reagent_containers/glass/bucket)
	var/obj/item/storage/backpack/backpack = player.spawn_obj_nearby(/obj/item/storage/backpack)

	// Drinks
	var/obj/item/reagent_containers/drinks/coffee/coffee = player.spawn_obj_in_hand(/obj/item/reagent_containers/drinks/coffee)
	player.click_on(player)
	TEST_ASSERT_ANY_CHATLOG(player, "You swallow a gulp of [coffee]")

	player.click_on(bucket)
	TEST_ASSERT_LAST_CHATLOG(player, "You transfer")

	coffee.reagents.total_volume = 0
	player.click_on(player)
	TEST_ASSERT_LAST_CHATLOG(player, "None of [coffee] left, oh no!")

	player.click_on(bucket)
	TEST_ASSERT_LAST_CHATLOG(player, "[coffee] is empty.")

	player.click_on(watertank)
	TEST_ASSERT_LAST_CHATLOG(player, "You fill [coffee] with")

	player.click_on(backpack)
	TEST_ASSERT(coffee in backpack.contents, "player failed to put [coffee] in backpack")

	bucket.reagents.total_volume = 0
	qdel(coffee)

	// Cans
	var/obj/item/reagent_containers/drinks/cans/can = player.spawn_obj_in_hand(/obj/item/reagent_containers/drinks/cans/cola)

	player.click_on(player)
	TEST_ASSERT_LAST_CHATLOG(player, "You need to open [can] first!")

	player.use_item_in_hand()
	TEST_ASSERT_LAST_CHATLOG(player, "You open the drink with an audible pop!")

	player.click_on(watertank)
	TEST_ASSERT_LAST_CHATLOG(player, "You fill [can] with")

	player.click_on(player)
	TEST_ASSERT_ANY_CHATLOG(player, "You swallow a gulp of [can]")

	player.click_on(bucket)
	TEST_ASSERT_LAST_CHATLOG(player, "You transfer")

	player.set_zone("head")
	player.set_intent("harm")
	can.reagents.total_volume = 0
	player.click_on(player)
	TEST_ASSERT_LAST_CHATLOG(player, "You crush [can] on your forehead.")

	can = player.spawn_obj_in_hand(/obj/item/reagent_containers/drinks/cans/cola)
	player.set_intent("help")
	player.click_on(backpack)
	TEST_ASSERT(can in backpack.contents, "player failed to put can in backpack")
	qdel(can)

	// Bottles
	var/obj/item/reagent_containers/drinks/bottle/whiskey/bottle = player.spawn_obj_in_hand(/obj/item/reagent_containers/drinks/bottle/whiskey)
	player.click_on(bucket)
	TEST_ASSERT_LAST_CHATLOG(player, "You transfer")

	player.click_on(player)
	TEST_ASSERT_ANY_CHATLOG(player, "You swallow a gulp of [bottle]")

	player.click_on(watertank)
	TEST_ASSERT_LAST_CHATLOG(player, "You fill [bottle] with")

	player.set_intent("harm")
	player.click_on(player)
	TEST_ASSERT(player.check_attack_log("Hit with [bottle]"), "player failed to smash a bottle on harm intent")
	TEST_ASSERT_NOTEQUAL(player.puppet.health, player.puppet.getMaxHealth(), "bottle smash didnt deal damage")
	player.puppet.drop_item()
	player.set_intent("help")

	bottle = player.spawn_obj_in_hand(/obj/item/reagent_containers/drinks/bottle/whiskey)
	player.click_on(backpack)
	TEST_ASSERT(bottle in backpack.contents, "player failed to put bottle in backpack")
	qdel(bottle)

	// Molotov
	var/obj/item/reagent_containers/drinks/bottle/molotov/molotov = player.spawn_obj_nearby(/obj/item/reagent_containers/drinks/bottle/molotov)
	molotov.list_reagents = list("vodka" = 100)

	var/lighter = player.spawn_obj_in_hand(/obj/item/lighter/zippo)
	player.use_item_in_hand()
	player.click_on(molotov)
	TEST_ASSERT(molotov.active, "player failed to light molotov")

	player.puppet.drop_item()
	player.click_on(molotov)
	player.use_item_in_hand()
	TEST_ASSERT(!molotov.active, "player failed to extinguish molotov")

	player.click_on(backpack)
	TEST_ASSERT(molotov in backpack.contents, "player failed to put molotov in backpack")
	qdel(molotov)

	// Drinking glass
	var/obj/item/reagent_containers/drinks/drinkingglass/glass = player.spawn_obj_nearby(/obj/item/reagent_containers/drinks/drinkingglass)
	var/obj/item/food/egg/egg = player.spawn_obj_in_hand(/obj/item/food/egg)
	player.click_on(glass)
	TEST_ASSERT_LAST_CHATLOG(player, "You break [egg] in")

	player.click_on(glass)
	player.click_on(backpack)
	TEST_ASSERT(glass in backpack.contents, "player failed to put drinking glass in backpack")
	qdel(glass)

	// Shot glass - For some reason the shotglass doesn't get clicked. Works ingame
	var/obj/item/reagent_containers/drinks/drinkingglass/shotglass/shotglass = player.spawn_obj_nearby(/obj/item/reagent_containers/drinks/drinkingglass/shotglass)
	shotglass.reagents.add_reagent("vodka", 15)

	player.click_on(lighter)
	player.click_on(shotglass)
	TEST_ASSERT_LAST_CHATLOG(player, "The shot glass of Vodka begins to burn with a blue hue!")

	player.puppet.drop_item()
	player.click_on(shotglass)
	player.use_item_in_hand()
	TEST_ASSERT_LAST_CHATLOG(player, "The dancing flame on the flaming shot glass of Vodka dies out.")

/datum/game_test/room_test/attack_chain_medcontainers/Run()
	var/datum/test_puppeteer/player = new(src)
	var/datum/test_puppeteer/target = player.spawn_puppet_nearby()

	var/obj/structure/table/table = player.spawn_obj_nearby(/obj/structure/table)

	// Pills
	var/obj/pill = player.spawn_obj_in_hand(/obj/item/reagent_containers/pill/salicylic)
	player.click_on_self()
	TEST_ASSERT_LAST_CHATLOG(player, "You swallow [pill].")
	var/obj/beaker = player.spawn_obj_nearby(/obj/item/reagent_containers/glass/beaker)
	player.puppet.swap_hand()
	pill = player.spawn_obj_in_hand(/obj/item/reagent_containers/pill/salicylic)
	player.click_on(beaker)
	TEST_ASSERT_LAST_CHATLOG(player, "You break open [pill] in [beaker].")
	pill = player.spawn_obj_in_hand(/obj/item/reagent_containers/pill/salicylic)
	player.click_on(beaker)
	TEST_ASSERT_LAST_CHATLOG(player, "You dissolve [pill] in [beaker].")
	pill = player.spawn_obj_in_hand(/obj/item/reagent_containers/pill/salicylic)
	player.use_item_in_hand()
	TEST_ASSERT_LAST_CHATLOG(player, "You swallow [pill].")
	pill = player.spawn_obj_in_hand(/obj/item/reagent_containers/pill/salicylic)
	player.click_on(table)
	TEST_ASSERT(pill in get_turf(table), "pill not placed on table")

	// Patches
	var/obj/item/reagent_containers/patch/patch = player.spawn_obj_in_hand(/obj/item/reagent_containers/patch/silver_sulf)
	player.click_on_self()
	TEST_ASSERT_LAST_CHATLOG(player, "You apply [patch].")
	patch = player.spawn_obj_in_hand(/obj/item/reagent_containers/patch/silver_sulf)
	patch.instant_application = TRUE
	player.click_on(target)
	TEST_ASSERT_LAST_CHATLOG(player, "[player.puppet] forces [target.puppet] to apply [patch].")

	// Beakers
	beaker = player.spawn_obj_in_hand(/obj/item/reagent_containers/glass/beaker)
	var/obj/machinery/clonepod/clonepod = player.spawn_obj_nearby(/obj/machinery/clonepod)
	beaker.reagents.add_reagent("sanguine_reagent", 10)
	player.click_on(clonepod)
	TEST_ASSERT_LAST_CHATLOG(player, "You transfer 10 units of the solution to [clonepod].")
	player.click_on(table)
	TEST_ASSERT(beaker in get_turf(table), "beaker not placed on table")

	// Pill bottles
	var/obj/pill_bottle = player.spawn_obj_in_hand(/obj/item/storage/pill_bottle)
	player.puppet.swap_hand()
	pill = player.spawn_obj_in_hand(/obj/item/reagent_containers/pill/salicylic)
	player.click_on(pill_bottle)
	TEST_ASSERT_LAST_CHATLOG(player, "You put [pill] into [pill_bottle].")

/datum/game_test/room_test/attack_chain_syringes/Run()
	var/datum/test_puppeteer/player = new(src)
	var/datum/test_puppeteer/target = player.spawn_puppet_nearby()

	var/obj/item/reagent_containers/syringe/syringe = player.spawn_obj_in_hand(/obj/item/reagent_containers/syringe)
	var/obj/beaker = player.spawn_obj_nearby(/obj/item/reagent_containers/glass/beaker)
	beaker.reagents.add_reagent("plasma_dust", 10)
	player.click_on(beaker)
	TEST_ASSERT_LAST_CHATLOG(player, "You fill the syringe with 5 units of the solution.")
	qdel(syringe)

	syringe = player.spawn_obj_in_hand(/obj/item/reagent_containers/syringe)
	player.click_on(target)
	TEST_ASSERT_LAST_CHATLOG(player, "[player.puppet] takes a blood sample from [target.puppet]")
	qdel(syringe)

	syringe = player.spawn_obj_in_hand(/obj/item/reagent_containers/syringe)
	syringe.syringe_draw_time = 0
	player.click_on_self()
	TEST_ASSERT_LAST_CHATLOG(player, "[player.puppet] takes a blood sample from [player.puppet]")
	var/obj/slime_extract = player.spawn_obj_nearby(/obj/item/slime_extract/grey)
	player.click_on(slime_extract)
	TEST_ASSERT_ANY_CHATLOG(player, "the used slime extract's power is consumed in the reaction")

	player.click_on(beaker)
	TEST_ASSERT_LAST_CHATLOG(player, "You inject 5 units of the solution")

/datum/game_test/room_test/attack_chain_iv_bags/Run()
	var/datum/test_puppeteer/player = new(src)
	var/datum/test_puppeteer/target = player.spawn_puppet_nearby()

	var/obj/machinery/iv_drip/iv_drip = player.spawn_obj_nearby(/obj/machinery/iv_drip)
	var/obj/blood_bag = player.spawn_obj_in_hand(/obj/item/reagent_containers/iv_bag)
	player.click_on(iv_drip)
	TEST_ASSERT_LAST_CHATLOG(player, "You attach [blood_bag] to [iv_drip].")
	var/obj/beaker = player.spawn_obj_in_hand(/obj/item/reagent_containers/glass/beaker/cryoxadone)
	player.click_on(iv_drip)
	TEST_ASSERT_LAST_CHATLOG(player, "You transfer 10 units of the solution to [blood_bag].")
	player.put_away(beaker)
	target.puppet.forceMove(get_turf(iv_drip))
	iv_drip.drag_drop_onto(target.puppet, player.puppet)
	TEST_ASSERT_LAST_CHATLOG(player, "[player.puppet] inserts [blood_bag]'s needle into [target.puppet]'s arm")

	blood_bag = player.spawn_obj_in_hand(/obj/item/reagent_containers/iv_bag)
	player.puppet.swap_hand()
	player.retrieve(beaker)
	player.click_on(blood_bag)
	TEST_ASSERT_LAST_CHATLOG(player, "You transfer 10 units of the solution to [blood_bag]")

	player.puppet.swap_hand()
	player.click_on(beaker)
	TEST_ASSERT_LAST_CHATLOG(player, "You transfer 1 units of the solution to [beaker]")

/datum/game_test/room_test/attack_chain_chemistry_bags/Run()
	var/datum/test_puppeteer/player = new(src)

	var/obj/table = player.spawn_obj_nearby(/obj/structure/table)
	var/turf/T = get_turf(table)
	var/obj/last_patch
	for(var/i in 1 to 5)
		last_patch = new /obj/item/reagent_containers/patch/styptic(T)
	var/obj/chem_bag = player.spawn_obj_in_hand(/obj/item/storage/bag/chemistry)
	player.click_on(last_patch)
	TEST_ASSERT_EQUAL(length(chem_bag.contents), 5, "chem bag failed to pick up patches")

	var/obj/chem_fridge = player.spawn_obj_nearby(/obj/machinery/smartfridge/medbay)
	player.click_on(chem_fridge)
	TEST_ASSERT_LAST_CHATLOG(player, "You load [chem_fridge] with [chem_bag]")

	player.puppet.swap_hand()
	var/obj/patch = player.spawn_obj_in_hand(/obj/item/reagent_containers/patch/styptic)
	player.click_on(chem_bag)
	TEST_ASSERT_LAST_CHATLOG(player, "You put [patch] into [chem_bag]")

/datum/game_test/room_test/attack_chain_rags/Run()
	var/datum/test_puppeteer/player = new(src)
	var/turf/simulated/floor/floor = get_turf(player.puppet)
	new/obj/effect/decal/cleanable/dirt(floor)
	var/obj/item/reagent_containers/glass/rag/rag = player.spawn_obj_in_hand(/obj/item/reagent_containers/glass/rag)
	rag.wipespeed = 0
	player.click_on(floor)
	TEST_ASSERT_LAST_CHATLOG(player, "You clean the floor with the damp rag.")

	var/datum/test_puppeteer/target = player.spawn_puppet_nearby()
	rag.reagents.add_reagent("omnizine", 10)
	player.click_on(target)
	TEST_ASSERT_LAST_CHATLOG(player, "You smother [target.puppet] with [rag]")

/datum/game_test/room_test/attack_chain_hyposprays/Run()
	var/datum/test_puppeteer/player = new(src)
	var/obj/autoinjector = player.spawn_obj_in_hand(/obj/item/reagent_containers/hypospray/autoinjector/stimpack)
	player.click_on_self()
	TEST_ASSERT_ANY_CHATLOG(player, "You feel a tiny prick")
	TEST_ASSERT_ANY_CHATLOG(player, "You inject [player.puppet] with [autoinjector]")
	var/mob/target = player.spawn_mob_nearby(/mob/living/carbon/human)
	player.put_away(autoinjector)
	autoinjector = player.spawn_obj_in_hand(/obj/item/reagent_containers/hypospray/autoinjector/stimpack)
	player.click_on(target)
	TEST_ASSERT_ANY_CHATLOG(player, "You inject [target] with [autoinjector]")

/datum/game_test/room_test/attack_chain_droppers/Run()
	var/datum/test_puppeteer/player = new(src)
	var/datum/test_puppeteer/target = player.spawn_puppet_nearby()
	var/obj/item/reagent_containers/dropper/dropper = player.spawn_obj_in_hand(/obj/item/reagent_containers/dropper)
	dropper.mob_drip_delay = 0
	var/obj/item/beaker = player.spawn_obj_nearby(/obj/item/reagent_containers/glass/beaker/waterbottle)
	player.click_on(beaker)
	TEST_ASSERT_LAST_CHATLOG(player, "You fill [dropper] with 1 units of the solution.")
	player.click_on(target)
	TEST_ASSERT_ANY_CHATLOG(player, "[player.puppet] drips something into [target.puppet]'s eyes")
	TEST_ASSERT_NOT_CHATLOG(player, "You cannot directly remove reagents from [target.puppet]")

/datum/game_test/room_test/attack_chain_spray/Run()
	var/datum/test_puppeteer/player = new(src)
	var/obj/item/reagent_containers/spray/spray = player.spawn_obj_in_hand(/obj/item/reagent_containers/spray)
	var/obj/structure/table = player.spawn_obj_nearby(/obj/structure/table)
	player.click_on(table)
	TEST_ASSERT(spray in get_turf(table), "spray bottle not placed on table")
