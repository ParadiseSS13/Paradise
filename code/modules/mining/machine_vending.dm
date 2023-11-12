// Use this define to register something as a purchasable!
// * n — The proper name of the purchasable
// * o — The object type path of the purchasable to spawn
// * p — The price of the purchasable in mining points
#define EQUIPMENT(n, o, p) n = new /datum/data/mining_equipment(n, o, p)

/**********************Mining Equipment Vendor**************************/

/obj/machinery/mineral/equipment_vendor
	name = "mining equipment vendor"
	desc = "An equipment vendor for miners, points collected at an ore redemption machine can be spent here."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "mining"
	density = TRUE
	anchored = TRUE
	var/obj/item/card/id/inserted_id
	var/list/prize_list // Initialized just below! (if you're wondering why - check CONTRIBUTING.md, look for: "hidden" init proc)
	var/dirty_items = FALSE // Used to refresh the static/redundant data in case the machine gets VV'd

/obj/machinery/mineral/equipment_vendor/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/mining_equipment_vendor(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	RefreshParts()

/obj/machinery/mineral/equipment_vendor/Initialize(mapload)
	. = ..()
	prize_list = list()
	prize_list["Gear"] = list(
		EQUIPMENT("Advanced Scanner", /obj/item/t_scanner/adv_mining_scanner, 800),
		EQUIPMENT("Explorer's Webbing", /obj/item/storage/belt/mining, 500),
		EQUIPMENT("Fulton Beacon", /obj/item/fulton_core, 400),
		EQUIPMENT("Mining Conscription Kit", /obj/item/storage/backpack/duffel/mining_conscript, 1500),
		EQUIPMENT("Advanced Jetpack Module", /obj/item/mod/module/jetpack/advanced, 2000),
		EQUIPMENT("Jump Boots", /obj/item/clothing/shoes/bhop, 2500),
		EQUIPMENT("Lazarus Capsule", /obj/item/mobcapsule, 800),
		EQUIPMENT("Lazarus Capsule belt", /obj/item/storage/belt/lazarus, 200),
		EQUIPMENT("Mining MODsuit", /obj/item/mod/control/pre_equipped/mining/vendor, 3500),
		EQUIPMENT("Asteroid MODsuit Skin", /obj/item/mod/skin_applier/asteroid, 1000),
		EQUIPMENT("Tracking Bio-chip Kit", /obj/item/storage/box/minertracker, 600),
	)
	prize_list["Consumables"] = list(
		EQUIPMENT("10 Marker Beacons", /obj/item/stack/marker_beacon/ten, 100),
		EQUIPMENT("Brute First-Aid Kit", /obj/item/storage/firstaid/brute, 600),
		EQUIPMENT("Fulton Pack", /obj/item/extraction_pack, 1000),
		EQUIPMENT("Jaunter", /obj/item/wormhole_jaunter, 750),
		EQUIPMENT("Chasm Jaunter Recovery Grenade", /obj/item/grenade/jaunter_grenade, 1500),
		EQUIPMENT("Lazarus Injector", /obj/item/lazarus_injector, 1000),
		EQUIPMENT("Point Transfer Card", /obj/item/card/mining_point_card, 500),
		EQUIPMENT("Shelter Capsule", /obj/item/survivalcapsule, 400),
		EQUIPMENT("Stabilizing Serum", /obj/item/hivelordstabilizer, 400),
		EQUIPMENT("Survival Medipen", /obj/item/reagent_containers/hypospray/autoinjector/survival, 500),
	)
	prize_list["Kinetic Accelerator"] = list(
		EQUIPMENT("Kinetic Accelerator", /obj/item/gun/energy/kinetic_accelerator, 750),
		EQUIPMENT("KA Adjustable Tracer Rounds", /obj/item/borg/upgrade/modkit/tracer/adjustable, 150),
		EQUIPMENT("KA AoE Damage", /obj/item/borg/upgrade/modkit/aoe/mobs, 2000),
		EQUIPMENT("KA Cooldown Decrease", /obj/item/borg/upgrade/modkit/cooldown, 1000),
		EQUIPMENT("KA Damage Increase", /obj/item/borg/upgrade/modkit/damage, 1000),
		EQUIPMENT("KA Hyper Chassis", /obj/item/borg/upgrade/modkit/chassis_mod/orange, 300),
		EQUIPMENT("KA Minebot Passthrough", /obj/item/borg/upgrade/modkit/minebot_passthrough, 100),
		EQUIPMENT("KA Range Increase", /obj/item/borg/upgrade/modkit/range, 1000),
		EQUIPMENT("KA Super Chassis", /obj/item/borg/upgrade/modkit/chassis_mod, 250),
		EQUIPMENT("KA White Tracer Rounds", /obj/item/borg/upgrade/modkit/tracer, 100),
	)
	prize_list["Digging Tools"] = list(
		EQUIPMENT("Diamond Pickaxe", /obj/item/pickaxe/diamond, 2000),
		EQUIPMENT("Kinetic Accelerator", /obj/item/gun/energy/kinetic_accelerator, 750),
		EQUIPMENT("Kinetic Crusher", /obj/item/kinetic_crusher, 750),
		EQUIPMENT("Resonator", /obj/item/resonator, 800),
		EQUIPMENT("Silver Pickaxe", /obj/item/pickaxe/silver, 1000),
		EQUIPMENT("Super Resonator", /obj/item/resonator/upgraded, 2500),
	)
	prize_list["Minebot"] = list(
		EQUIPMENT("Nanotrasen Minebot", /obj/item/mining_drone_cube, 800),
		EQUIPMENT("Minebot AI Upgrade", /obj/item/slimepotion/sentience/mining, 1000),
		EQUIPMENT("Minebot Armor Upgrade", /obj/item/mine_bot_upgrade/health, 400),
		EQUIPMENT("Minebot Cooldown Upgrade", /obj/item/borg/upgrade/modkit/cooldown/minebot, 600),
		EQUIPMENT("Minebot Melee Upgrade", /obj/item/mine_bot_upgrade, 400),
	)
	prize_list["Miscellaneous"] = list(
		EQUIPMENT("Absinthe", /obj/item/reagent_containers/food/drinks/bottle/absinthe/premium, 100),
		EQUIPMENT("Alien Toy", /obj/item/clothing/mask/facehugger/toy, 300),
		EQUIPMENT("Cigar", /obj/item/clothing/mask/cigarette/cigar/havana, 150),
		EQUIPMENT("GAR Meson Scanners", /obj/item/clothing/glasses/meson/gar, 500),
		EQUIPMENT("Laser Pointer", /obj/item/laser_pointer, 300),
		EQUIPMENT("Luxury Shelter Capsule", /obj/item/survivalcapsule/luxury, 3000),
		EQUIPMENT("Soap", /obj/item/soap/nanotrasen, 200),
		EQUIPMENT("Space Cash", /obj/item/stack/spacecash/c200, 2000),
		EQUIPMENT("Whiskey", /obj/item/reagent_containers/food/drinks/bottle/whiskey, 100),
		EQUIPMENT("HRD-MDE Project Box", /obj/item/storage/box/hardmode_box, 3500) //I want miners have to pay a lot to get this, but be set once they do.
	)
	prize_list["Extra"] = list() // Used in child vendors

/obj/machinery/mineral/equipment_vendor/proc/remove_id()
	if(inserted_id)
		inserted_id.forceMove(get_turf(src))
		inserted_id = null
		return TRUE

/obj/machinery/mineral/equipment_vendor/power_change()
	. = ..()
	update_icon(UPDATE_ICON_STATE)
	if(. && inserted_id && (stat & NOPOWER))
		visible_message("<span class='notice'>The ID slot indicator light flickers on [src] as it spits out a card before powering down.</span>")
		remove_id()

/obj/machinery/mineral/equipment_vendor/update_icon_state()
	if(has_power())
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-off"

/obj/machinery/mineral/equipment_vendor/attack_hand(mob/user)
	if(..())
		return
	ui_interact(user)

/obj/machinery/mineral/equipment_vendor/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/mineral/equipment_vendor/ui_data(mob/user)
	var/list/data = list()

	// ID
	if(inserted_id)
		data["has_id"] = TRUE
		data["id"] = list(
			"name" = inserted_id.registered_name,
			"points" = inserted_id.mining_points,
		)
	else
		data["has_id"] = FALSE

	return data

/obj/machinery/mineral/equipment_vendor/ui_static_data(mob/user)
	var/list/static_data = list()

	// Available items - in static data because we don't wanna compute this list every time! It hardly changes.
	static_data["items"] = list()
	for(var/cat in prize_list)
		var/list/cat_items = list()
		for(var/prize_name in prize_list[cat])
			var/datum/data/mining_equipment/prize = prize_list[cat][prize_name]
			cat_items[prize_name] = list("name" = prize_name, "price" = prize.cost)
		static_data["items"][cat] = cat_items

	return static_data

/obj/machinery/mineral/equipment_vendor/vv_edit_var(var_name, var_value)
	// Gotta update the static data in case an admin VV's the items for some reason..!
	if(var_name == "prize_list")
		dirty_items = TRUE
	return ..()

/obj/machinery/mineral/equipment_vendor/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	// Update static data if need be
	if(dirty_items)
		if(!ui)
			ui = SStgui.get_open_ui(user, src, ui_key)
		if(ui) // OK so ui?. somehow breaks the implied src so this is needed
			ui.initial_static_data = ui_static_data(user)
		dirty_items = FALSE

	// Open the window
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "MiningVendor", name, 400, 450)
		ui.open()
		ui.set_autoupdate(FALSE)

/obj/machinery/mineral/equipment_vendor/ui_act(action, params)
	if(..())
		return

	. = TRUE
	switch(action)
		if("logoff")
			if(!inserted_id)
				return
			if(ishuman(usr))
				usr.put_in_hands(inserted_id)
			else
				inserted_id.forceMove(get_turf(src))
			inserted_id = null
		if("purchase")
			if(!inserted_id)
				return
			var/category = params["cat"] // meow
			var/name = params["name"]
			if(!(category in prize_list) || !(name in prize_list[category])) // Not trying something that's not in the list, are you?
				return
			var/datum/data/mining_equipment/prize = prize_list[category][name]
			if(prize.cost > inserted_id.mining_points) // shouldn't be able to access this since the button is greyed out, but..
				to_chat(usr, "<span class='danger'>You have insufficient points.</span>")
				return

			inserted_id.mining_points -= prize.cost
			new prize.equipment_path(loc)
		else
			return FALSE
	add_fingerprint()

/obj/machinery/mineral/equipment_vendor/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, "mining-open", "mining", I))
		return
	if(panel_open)
		if(istype(I, /obj/item/crowbar))
			remove_id()
			default_deconstruction_crowbar(user, I)
		return TRUE
	if(istype(I, /obj/item/mining_voucher))
		if(!has_power())
			return
		redeem_voucher(I, user)
		return
	if(istype(I, /obj/item/card/id))
		if(!has_power())
			return
		var/obj/item/card/id/C = user.get_active_hand()
		if(istype(C) && !istype(inserted_id))
			if(!user.drop_item())
				return
			C.forceMove(src)
			inserted_id = C
			ui_interact(user)
		return
	return ..()

/**
  * Called when someone slaps the machine with a mining voucher
  *
  * Arguments:
  * * voucher - The voucher card item
  * * redeemer - The person holding it
  */
/obj/machinery/mineral/equipment_vendor/proc/redeem_voucher(obj/item/mining_voucher/voucher, mob/redeemer)
	var/items = list("Survival Capsule and Explorer's Webbing", "Resonator Kit", "Minebot Kit", "Extraction and Rescue Kit", "Crusher Kit", "Plasma Cutter", "Jaunter Kit", "Mining Conscription Kit")

	var/selection = input(redeemer, "Pick your equipment", "Mining Voucher Redemption") as null|anything in items
	if(!selection || !Adjacent(redeemer) || QDELETED(voucher) || voucher.loc != redeemer)
		return

	var/drop_location = drop_location()
	switch(selection)
		if("Survival Capsule and Explorer's Webbing")
			new /obj/item/storage/belt/mining/vendor(drop_location)
		if("Resonator Kit")
			new /obj/item/extinguisher/mini(drop_location)
			new /obj/item/resonator(drop_location)
		if("Minebot Kit")
			new /obj/item/mining_drone_cube(drop_location)
			new /obj/item/weldingtool/hugetank(drop_location)
			new /obj/item/clothing/head/welding(drop_location)
		if("Extraction and Rescue Kit")
			new /obj/item/extraction_pack(drop_location)
			new /obj/item/fulton_core(drop_location)
			new /obj/item/stack/marker_beacon/thirty(drop_location)
		if("Crusher Kit")
			new /obj/item/extinguisher/mini(drop_location)
			new /obj/item/kinetic_crusher(drop_location)
		if("Plasma Cutter")
			new /obj/item/gun/energy/plasmacutter(drop_location)
		if("Jaunter Kit")
			new /obj/item/wormhole_jaunter(drop_location)
			new /obj/item/stack/medical/bruise_pack/advanced(drop_location)
		if("Mining Conscription Kit")
			new /obj/item/storage/backpack/duffel/mining_conscript(drop_location)

	qdel(voucher)

/obj/machinery/mineral/equipment_vendor/ex_act(severity, target)
	do_sparks(5, TRUE, src)
	if(prob(50 / severity) && severity < 3)
		qdel(src)

/obj/machinery/mineral/equipment_vendor/Destroy()
	remove_id()
	return ..()


/**********************Mining Equiment Vendor (Golem)**************************/

/obj/machinery/mineral/equipment_vendor/golem
	name = "golem ship equipment vendor"

/obj/machinery/mineral/equipment_vendor/golem/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/mining_equipment_vendor/golem(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	RefreshParts()

/obj/machinery/mineral/equipment_vendor/golem/Initialize()
	. = ..()
	desc += "\nIt seems a few selections have been added."
	prize_list["Extra"] += list(
		EQUIPMENT("Extra ID", /obj/item/card/id/golem, 250),
		EQUIPMENT("Science Backpack", /obj/item/storage/backpack/science, 250),
		EQUIPMENT("Full Toolbelt", /obj/item/storage/belt/utility/full/multitool, 250),
		EQUIPMENT("Monkey Cube", /obj/item/reagent_containers/food/snacks/monkeycube, 250),
		EQUIPMENT("Royal Cape of the Liberator", /obj/item/bedsheet/rd/royal_cape, 500),
		EQUIPMENT("Grey Slime Extract", /obj/item/slime_extract/grey, 1000),
		EQUIPMENT("KA Trigger Modification Kit", /obj/item/borg/upgrade/modkit/trigger_guard, 1000),
		EQUIPMENT("Shuttle Console Board", /obj/item/circuitboard/shuttle/golem_ship, 2000),
		EQUIPMENT("The Liberator's Legacy", /obj/item/storage/box/rndboards, 2000),
	)

/**********************Mining Equiment Vendor (Gulag)**************************/

/obj/machinery/mineral/equipment_vendor/labor
	name = "labor camp equipment vendor"
	desc = "An equipment vendor for scum, points collected at an ore redemption machine can be spent here."

/obj/machinery/mineral/equipment_vendor/labor/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/mining_equipment_vendor/labor(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	RefreshParts()

/obj/machinery/mineral/equipment_vendor/labor/Initialize()
	. = ..()
	prize_list = list()
	prize_list["Scum"] += list(
		EQUIPMENT("Trauma Kit", /obj/item/stack/medical/bruise_pack/advanced, 150),
		EQUIPMENT("Whisky", /obj/item/reagent_containers/food/drinks/bottle/whiskey, 100),
		EQUIPMENT("Beer", /obj/item/reagent_containers/food/drinks/cans/beer, 50),
		EQUIPMENT("Absinthe", /obj/item/reagent_containers/food/drinks/bottle/absinthe/premium, 250),
		EQUIPMENT("Cigarettes", /obj/item/storage/fancy/cigarettes, 100),
		EQUIPMENT("Medical Marijuana", /obj/item/storage/fancy/cigarettes/cigpack_med, 250),
		EQUIPMENT("Cigar", /obj/item/clothing/mask/cigarette/cigar/havana, 150),
		EQUIPMENT("Box of matches", /obj/item/storage/box/matches, 50),
		EQUIPMENT("Cheeseburger", /obj/item/reagent_containers/food/snacks/burger/cheese, 150),
		EQUIPMENT("Big Burger", /obj/item/reagent_containers/food/snacks/burger/bigbite, 250),
		EQUIPMENT("Recycled Prisoner", /obj/item/reagent_containers/food/snacks/soylentgreen, 500),
		EQUIPMENT("Crayons", /obj/item/storage/fancy/crayons, 350),
		EQUIPMENT("Plushie", /obj/random/plushie, 750),
		EQUIPMENT("Dnd set", /obj/item/storage/box/characters, 500),
		EQUIPMENT("Dice set", /obj/item/storage/box/dice, 250),
		EQUIPMENT("Cards", /obj/item/deck/cards, 150),
		EQUIPMENT("UNUM!", /obj/item/deck/unum, 200),
		EQUIPMENT("Guitar", /obj/item/instrument/guitar, 750),
		EQUIPMENT("Synthesizer", /obj/item/instrument/piano_synth, 1500),
		EQUIPMENT("Diamond Pickaxe", /obj/item/pickaxe/diamond, 2000),
		EQUIPMENT("Analyzer", /obj/item/analyzer, 50)
	)

/**********************Mining Equipment Datum**************************/

/datum/data/mining_equipment
	var/equipment_name = "generic"
	var/equipment_path = null
	var/cost = 0

/datum/data/mining_equipment/New(name, path, equipment_cost)
	equipment_name = name
	equipment_path = path
	cost = equipment_cost

/**********************Mining Equipment Voucher**********************/

/obj/item/mining_voucher
	name = "mining voucher"
	desc = "A token to redeem a piece of equipment. Use it on a mining equipment vendor."
	icon = 'icons/obj/items.dmi'
	icon_state = "mining_voucher"
	w_class = WEIGHT_CLASS_TINY

/**********************Mining Point Card**********************/

/obj/item/card/mining_point_card
	name = "mining point card"
	desc = "A small card preloaded with mining points. Swipe your ID card over it to transfer the points, then discard."
	icon_state = "data"
	var/points = 500

/obj/item/card/mining_point_card/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/card/id))
		if(points)
			var/obj/item/card/id/C = I
			C.mining_points += points
			to_chat(user, "<span class='info'>You transfer [points] points to [C].</span>")
			points = 0
		else
			to_chat(user, "<span class='info'>There's no points left on [src].</span>")
	..()

/obj/item/card/mining_point_card/examine(mob/user)
	. = ..()
	. += "There's [points] points on the card."


#undef EQUIPMENT

