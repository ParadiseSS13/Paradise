/obj/item/robot_module
	name = "robot module"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_module"
	w_class = 100
	item_state = "electronic"
	flags = CONDUCT
	var/module_armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 0, ACID = 0)

	/// Has the AI hacked the borg module, allowing access to the malf AI exclusive item.
	var/malfhacked = FALSE

	/// A list of all currently usable and created modules the robot currently has access too.
	var/list/modules = list()
	/// A list of module-specific, non-emag modules the borg will gain when this module is chosen.
	var/list/basic_modules = list()
	/// A list of modules the robot gets when emagged.
	var/list/emag_modules = list()
	/// A list of modules that the robot gets when malf AI buys it.
	var/list/malf_modules = list()
	/// A list of modules that require special recharge handling. Examples include things like flashes, sprays and welding tools.
	var/list/special_rechargables = list()
	/// A list of all "energy stacks", i.e metal, glass, brute kits, splints, etc.
	var/list/storages = list()
	/// Special actions this module will gain when chosen such as meson vision, or thermal vision.
	var/list/module_actions = list()
	/// Available tools given in the verb tab such as a crew monitor, or power monitor.
	var/list/subsystems = list()
	/// Radio channels the module owner has access to.
	var/list/channels = list()
	/// Special items that are able to be removed from the robot owner via crowbar.
	var/list/custom_removals = list()
	/// For icon usage.
	var/module_type = "NoMod"


/obj/item/robot_module/New()
	..()

	// Creates new objects from the type lists.
	for(var/i in basic_modules)
		var/obj/item/I = new i(src)
		basic_modules += I
		basic_modules -= i

	// Even though these are created here the robot won't be able to see and equip them until they actually get emagged/hacked.
	for(var/i in emag_modules)
		var/obj/item/I = new i(src)
		emag_modules += I
		emag_modules -= i

	for(var/i in malf_modules)
		var/obj/item/I = new i(src)
		malf_modules += I
		malf_modules -= i

	// Flashes need a special recharge, and since basically every module uses it, add it here.
	// Even if the module doesn't use a flash, it wont cause any issues to have it in this list.
	special_rechargables += /obj/item/flash/cyborg

	// This is done so we can loop through this list later and call cyborg_recharge() on the items while the borg is recharging.
	var/all_modules = basic_modules | emag_modules | malf_modules
	for(var/path in special_rechargables)
		var/obj/item/I = locate(path) in all_modules
		if(I) // If it exists, add the object reference.
			special_rechargables += I
		special_rechargables -= path // No matter what, remove the path from the list.

	// Add all the modules into the robot's inventory. Without this, their inventory will be blank.
	rebuild_modules()


/obj/item/robot_module/emp_act(severity)
	. = ..()
	for(var/object in modules)
		var/obj/O = object
		O.emp_act(severity)

/obj/item/robot_module/Destroy()
	// These can all contain actual objects, so we need to null them out.
	QDEL_LIST_CONTENTS(modules)
	QDEL_LIST_CONTENTS(basic_modules)
	QDEL_LIST_CONTENTS(emag_modules)
	QDEL_LIST_CONTENTS(malf_modules)
	QDEL_LIST_CONTENTS(storages)
	QDEL_LIST_CONTENTS(special_rechargables)
	return ..()

/obj/item/robot_module/Initialize(mapload)
	. = ..()
	module_armor = getArmor(arglist(module_armor))
/**
 * Searches through the various module lists for the given `item_type`, deletes and removes the item from all supplied lists, if the item is found.
 *
 * NOTE: be careful with using this proc, as it irreversibly removes entries from a borg's module list.
 * This is safe to do with upgrades because the only way to revert upgrades currently is either to rebuild the borg or use a reset module, which allows the lists to regenerate.
 *
 * Arugments:
 * * item_type - the type of item to search for. Also accepts objects themselves.
 */
/obj/item/robot_module/proc/remove_item_from_lists(item_or_item_type)
	var/list/lists = list(
		basic_modules,
		emag_modules,
		malf_modules,
		storages,
		special_rechargables
	)
	for(var/_list in lists)
		for(var/item in _list)
			var/obj/item/I = item
			if(!istype(I, item_or_item_type))
				continue
			if(!QDELETED(I))
				qdel(I)
			_list -= I

// Here for admin debugging purposes only.
/obj/item/robot_module/proc/fix_modules()
	for(var/item in modules)
		var/obj/item/I = item
		I.flags |= NODROP
		I.mouse_opacity = MOUSE_OPACITY_OPAQUE

/**
 * Returns a `robot_energy_strage` datum of type `storage_type`. If one already exists, it returns that one, otherwise it create a new one.
 *
 * Arguments:
 * * storage_type - the subtype of `datum/robot_energy_storage` to fetch or create.
 */
/obj/item/robot_module/proc/get_or_create_estorage(storage_type)
	for(var/e_storage in storages)
		var/datum/robot_energy_storage/S = e_storage
		if(istype(S, storage_type))
			return S
	return new storage_type(src)

/**
 * Adds the item `I` to our `modules` list, and sets up an `/datum/robot_energy_storage` if its a stack.
 *
 * Arugments:
 * * I - the item to add to our modules.
 * * requires_rebuild - if adding this item requires `rebuild_modules()` to be called.
 */
/obj/item/robot_module/proc/add_module(obj/item/I, requires_rebuild)
	if(I in modules) // No duplicate items.
		return

	if(istype(I, /obj/item/stack))
		var/obj/item/stack/S = I

		if(S.energy_type)
			S.source = get_or_create_estorage(S.energy_type)
			S.is_cyborg = TRUE

		// Here for safety. Using a cyborg stack without a `source` will create hundreds of runtimes.
		if(!S.source)
			qdel(S)
			return

	if(I.loc != src)
		I.forceMove(src)

	modules += I
	I.flags |= NODROP
	I.mouse_opacity = MOUSE_OPACITY_OPAQUE

	if(requires_rebuild)
		rebuild_modules()
	return I

/**
 * Builds the usable module list from the modules we have in `basic_modules`, `emag_modules` and `malf_modules`
 */
/obj/item/robot_module/proc/rebuild_modules()
	var/mob/living/silicon/robot/R = loc
	R.uneq_all()
	modules = list()

	if(!malfhacked && R.connected_ai)
		if(type in R.connected_ai.purchased_modules)
			malfhacked = TRUE

	// By this point these lists should only contain items. It's safe to use typeless loops here.
	for(var/item in basic_modules)
		add_module(item, FALSE)

	if(R.emagged || R.weapons_unlock)
		for(var/item in emag_modules)
			add_module(item, FALSE)

	if(malfhacked)
		for(var/item in malf_modules)
			add_module(item, FALSE)

	if(R.hud_used)
		R.hud_used.update_robot_modules_display()

/**
 * Handles the recharging of all borg stack items and any items which are in the `special_rechargables` list.
 *
 * Arguments:
 * * R - the owner of this module.
 * * coeff - a coefficient which can be used to modify the recharge rate of consumables.
 */
/obj/item/robot_module/proc/recharge_consumables(mob/living/silicon/robot/R, coeff = 1)
	for(var/e_storage in storages)
		var/datum/robot_energy_storage/E = e_storage
		E.add_charge(max(1, coeff * E.recharge_rate))
	for(var/item in special_rechargables)
		var/obj/item/I = item
		I.cyborg_recharge(coeff, R.emagged)

/**
 * Called when the robot owner of this module has their power cell replaced.
 *
 * Changes the linked power cell for module items to the newly inserted cell, or to `null`.
 * Arguments:
 * * unlink_cell - If TRUE, set the item's power cell variable to `null` rather than linking it to a new one.
 */
/obj/item/robot_module/proc/update_cells(unlink_cell = FALSE)
	return

/**
 * Called when the robot owner of this module has the `unemag()` proc called on them, which is only via admin means.
 *
 * Deletes this module's emag items, and recreates them.
 */
/obj/item/robot_module/unemag()
	. = ..()
	for(var/item in emag_modules)
		var/obj/item/old_item = item
		var/obj/item/new_item = new old_item.type(src)
		emag_modules += new_item
		if(old_item in special_rechargables) // If the old item was in this list, make sure the new one goes into it as well.
			special_rechargables += new_item
			special_rechargables -= old_item
		modules -= old_item
		emag_modules -= old_item
		qdel(old_item)
	rebuild_modules()

/**
 * Adds all of the languages this module is suppose to know and/or speak.
 *
 * Arugments:
 * * R - the owner of this module.
 */
/obj/item/robot_module/proc/add_languages(mob/living/silicon/robot/R)
	//full set of languages
	R.add_language("Galactic Common", 1)
	R.add_language("Sol Common", 1)
	R.add_language("Tradeband", 1)
	R.add_language("Gutter", 0)
	R.add_language("Neo-Russkiya", 0)
	R.add_language("Sinta'unathi", 0)
	R.add_language("Siik'tajr", 0)
	R.add_language("Canilunzt", 0)
	R.add_language("Skrellian", 0)
	R.add_language("Vox-pidgin", 0)
	R.add_language("Rootspeak", 0)
	R.add_language("Trinary", 1)
	R.add_language("Chittin", 0)
	R.add_language("Bubblish", 0)
	R.add_language("Orluum", 0)
	R.add_language("Clownish", 0)
	R.add_language("Tkachi", 0)

///Adds armor to a cyborg. Normaly resets it to 0 across the board, unless the module has an armor defined.
/obj/item/robot_module/proc/add_armor(mob/living/silicon/robot/R)
	R.armor = module_armor


/// Adds anything in `subsystems` to the robot's verbs, and grants any actions that are in `module_actions`.
/obj/item/robot_module/proc/add_subsystems_and_actions(mob/living/silicon/robot/R)
	R.verbs |= subsystems
	for(var/A in module_actions)
		var/datum/action/act = new A()
		act.Grant(R)
		R.module_actions += act

/// Removes any verbs from the robot that are in `subsystems`, and removes any actions that are in `module_actions`.
/obj/item/robot_module/proc/remove_subsystems_and_actions(mob/living/silicon/robot/R)
	R.verbs -= subsystems
	for(var/datum/action/A in R.module_actions)
		A.Remove(R)
		qdel(A)
	R.module_actions.Cut()

// Return true in an overridden subtype to prevent normal removal handling
/obj/item/robot_module/proc/handle_custom_removal(component_id, mob/living/user, obj/item/W)
	return FALSE

/obj/item/robot_module/proc/handle_death(mob/living/silicon/robot/R, gibbed)
	return

// Medical cyborg module.
/obj/item/robot_module/medical
	name = "medical robot module"
	module_type = "Medical"
	subsystems = list(/mob/living/silicon/proc/subsystem_crew_monitor)
	basic_modules = list(
		/obj/item/flash/cyborg,
		/obj/item/healthanalyzer/advanced,
		/obj/item/robotanalyzer,
		/obj/item/reagent_scanner/adv,
		/obj/item/borg_defib,
		/obj/item/handheld_defibrillator,
		/obj/item/roller_holder,
		/obj/item/borg/cyborghug,
		/obj/item/reagent_containers/borghypo,
		/obj/item/scalpel/laser/laser1,
		/obj/item/hemostat,
		/obj/item/retractor,
		/obj/item/circular_saw,
		/obj/item/surgicaldrill,
		/obj/item/bonesetter,
		/obj/item/bonegel,
		/obj/item/FixOVein,
		/obj/item/extinguisher/mini,
		/obj/item/reagent_containers/glass/beaker/large,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/syringe,
		/obj/item/stack/medical/bruise_pack/advanced/cyborg,
		/obj/item/stack/medical/ointment/advanced/cyborg,
		/obj/item/stack/medical/splint/cyborg,
		/obj/item/stack/nanopaste/cyborg,
		/obj/item/gripper_medical
	)
	emag_modules = list(/obj/item/reagent_containers/spray/cyborg_facid)
	special_rechargables = list(/obj/item/reagent_containers/spray/cyborg_facid, /obj/item/extinguisher/mini)

// Disable safeties on the borg's defib.
/obj/item/robot_module/medical/emag_act(mob/user)
	. = ..()
	for(var/obj/item/borg_defib/F in modules)
		F.emag_act()
	for(var/obj/item/reagent_containers/borghypo/F in modules)
		F.emag_act()

// Enable safeties on the borg's defib.
/obj/item/robot_module/medical/unemag()
	for(var/obj/item/borg_defib/F in modules)
		F.emag_act()
	for(var/obj/item/reagent_containers/borghypo/F in modules)
		F.emag_act()
	return ..()

// Fluorosulphuric acid spray bottle.
/obj/item/reagent_containers/spray/cyborg_facid
	name = "Polyacid spray"
	list_reagents = list("facid" = 250)

/obj/item/reagent_containers/spray/cyborg_facid/cyborg_recharge(coeff, emagged)
	if(emagged)
		reagents.check_and_add("facid", volume, 2 * coeff)

// Engineering cyborg module.
/obj/item/robot_module/engineering
	name = "engineering robot module"
	module_type = "Engineer"
	subsystems = list(/mob/living/silicon/proc/subsystem_power_monitor)
	module_actions = list(/datum/action/innate/robot_sight/meson)
	basic_modules = list(
		/obj/item/flash/cyborg,
		/obj/item/rpd,
		/obj/item/extinguisher,
		/obj/item/weldingtool/largetank/cyborg,
		/obj/item/screwdriver/cyborg,
		/obj/item/wrench/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/wirecutters/cyborg,
		/obj/item/multitool/cyborg,
		/obj/item/t_scanner,
		/obj/item/analyzer,
		/obj/item/geiger_counter/cyborg,
		/obj/item/holosign_creator/engineering,
		/obj/item/gripper_engineering,
		/obj/item/matter_decompiler,
		/obj/item/painter,
		/obj/item/areaeditor/blueprints/cyborg,
		/obj/item/stack/sheet/metal/cyborg,
		/obj/item/stack/rods/cyborg,
		/obj/item/stack/tile/plasteel/cyborg,
		/obj/item/stack/cable_coil/cyborg,
		/obj/item/stack/sheet/glass/cyborg,
		/obj/item/stack/sheet/rglass/cyborg
	)
	emag_modules = list(/obj/item/borg/stun, /obj/item/restraints/handcuffs/cable/zipties/cyborg, /obj/item/rcd/borg)
	malf_modules = list(/obj/item/gun/energy/emitter/cyborg)
	special_rechargables = list(/obj/item/extinguisher, /obj/item/weldingtool/largetank/cyborg, /obj/item/gun/energy/emitter/cyborg)

/obj/item/robot_module/engineering/handle_death(mob/living/silicon/robot/R, gibbed)
	var/obj/item/gripper_engineering/G = locate(/obj/item/gripper_engineering) in modules
	if(G)
		G.drop_gripped_item(silent = TRUE)

// Security cyborg module.
/obj/item/robot_module/security
	name = "security robot module"
	module_type = "Security"
	subsystems = list(/mob/living/silicon/proc/subsystem_crew_monitor)
	basic_modules = list(
		/obj/item/flash/cyborg,
		/obj/item/restraints/handcuffs/cable/zipties/cyborg,
		/obj/item/melee/baton/loaded,
		/obj/item/gun/energy/disabler/cyborg,
		/obj/item/holosign_creator/security,
		/obj/item/clothing/mask/gas/sechailer/cyborg
	)
	emag_modules = list(/obj/item/gun/energy/laser/cyborg)
	special_rechargables = list(
		/obj/item/melee/baton/loaded,
		/obj/item/gun/energy/disabler/cyborg,
		/obj/item/gun/energy/laser/cyborg
	)

/obj/item/robot_module/security/update_cells(unlink_cell = FALSE)
	var/obj/item/melee/baton/B = locate(/obj/item/melee/baton/loaded) in modules
	if(B)
		B.link_new_cell(unlink_cell)

// Janitor cyborg module.
/obj/item/robot_module/janitor
	name = "janitorial robot module"
	module_type = "Janitor"
	basic_modules = list(
		/obj/item/flash/cyborg,
		/obj/item/soap/nanotrasen,
		/obj/item/storage/bag/trash/cyborg,
		/obj/item/mop/advanced/cyborg,
		/obj/item/lightreplacer/cyborg,
		/obj/item/holosign_creator/janitor,
		/obj/item/extinguisher/mini
	)
	emag_modules = list(/obj/item/reagent_containers/spray/cyborg_lube, /obj/item/restraints/handcuffs/cable/zipties/cyborg)
	special_rechargables = list(
		/obj/item/lightreplacer,
		/obj/item/reagent_containers/spray/cyborg_lube,
		/obj/item/extinguisher/mini
	)

/obj/item/robot_module/janitor/Initialize(mapload)
	. = ..()
	var/mob/living/silicon/robot/R = loc
	RegisterSignal(R, COMSIG_MOVABLE_MOVED, PROC_REF(on_cyborg_move))

/**
 * Proc called after the janitor cyborg has moved, in order to clean atoms at it's new location.
 *
 * Arguments:
 * * mob/living/silicon/robot/R - The cyborg who moved.
 */
/obj/item/robot_module/janitor/proc/on_cyborg_move(mob/living/silicon/robot/R)
	SIGNAL_HANDLER

	if(R.stat == DEAD || !isturf(R.loc) || !R.floorbuffer)
		return
	var/turf/tile = R.loc
	for(var/A in tile)
		if(iseffect(A))
			var/obj/effect/E = A
			if(!E.is_cleanable())
				continue
			var/obj/effect/decal/cleanable/blood/B = E
			if(istype(B) && B.off_floor)
				tile.clean_blood()
			else
				qdel(E)
		else if(isitem(A))
			var/obj/item/I = A
			I.clean_blood()
		else if(ishuman(A))
			var/mob/living/carbon/human/cleaned_human = A
			if(!IS_HORIZONTAL(cleaned_human))
				continue
			cleaned_human.clean_blood()
			to_chat(cleaned_human, "<span class='danger'>[src] cleans your face!</span>")

// Service cyborg module.
/obj/item/robot_module/butler
	name = "service robot module"
	module_type = "Service"
	basic_modules = list(
		/obj/item/flash/cyborg,
		/obj/item/handheld_chem_dispenser/booze,
		/obj/item/handheld_chem_dispenser/soda,
		/obj/item/pen,
		/obj/item/razor,
		/obj/item/instrument/piano_synth,
		/obj/item/healthanalyzer/advanced,
		/obj/item/reagent_scanner/adv,
		/obj/item/rsf,
		/obj/item/reagent_containers/dropper/cyborg,
		/obj/item/lighter/zippo,
		/obj/item/storage/bag/tray/cyborg,
		/obj/item/reagent_containers/food/drinks/shaker
	)
	emag_modules = list(/obj/item/reagent_containers/food/drinks/cans/beer/sleepy_beer, /obj/item/restraints/handcuffs/cable/zipties/cyborg)
	special_rechargables = list(
		/obj/item/reagent_containers/food/condiment/enzyme,
		/obj/item/reagent_containers/food/drinks/cans/beer/sleepy_beer
	)


// This is a special type of beer given when emagged, one sip and the target falls asleep.
/obj/item/reagent_containers/food/drinks/cans/beer/sleepy_beer
	name = "Mickey Finn's Special Brew"
	list_reagents = list("beer2" = 50)

/obj/item/reagent_containers/food/drinks/cans/beer/sleepy_beer/cyborg_recharge(coeff, emagged)
	if(emagged)
		reagents.check_and_add("beer2", volume, 5)

/obj/item/robot_module/butler/add_languages(mob/living/silicon/robot/R)
	//full set of languages
	R.add_language("Galactic Common", 1)
	R.add_language("Sol Common", 1)
	R.add_language("Tradeband", 1)
	R.add_language("Gutter", 1)
	R.add_language("Sinta'unathi", 1)
	R.add_language("Siik'tajr", 1)
	R.add_language("Canilunzt", 1)
	R.add_language("Skrellian", 1)
	R.add_language("Vox-pidgin", 1)
	R.add_language("Rootspeak", 1)
	R.add_language("Trinary", 1)
	R.add_language("Chittin", 1)
	R.add_language("Bubblish", 1)
	R.add_language("Clownish",1)
	R.add_language("Neo-Russkiya", 1)
	R.add_language("Tkachi", 1)

/obj/item/robot_module/butler/handle_death(mob/living/silicon/robot/R, gibbed)
	var/obj/item/storage/bag/tray/cyborg/T = locate(/obj/item/storage/bag/tray/cyborg) in modules
	if(istype(T))
		T.drop_inventory(R)


/obj/item/robot_module/miner
	name = "miner robot module"
	module_type = "Miner"
	module_armor = list(MELEE = 20, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 0, ACID = 0)
	module_actions = list(/datum/action/innate/robot_sight/meson)
	custom_removals = list("KA modkits")
	basic_modules = list(
		/obj/item/flash/cyborg,
		/obj/item/storage/bag/ore/cyborg,
		/obj/item/pickaxe/drill/cyborg,
		/obj/item/shovel,
		/obj/item/weldingtool/mini,
		/obj/item/extinguisher/mini,
		/obj/item/storage/bag/sheetsnatcher/borg,
		/obj/item/t_scanner/adv_mining_scanner/cyborg,
		/obj/item/gun/energy/kinetic_accelerator/cyborg,
		/obj/item/gps/cyborg
	)
	emag_modules = list(/obj/item/borg/stun, /obj/item/pickaxe/drill/cyborg/diamond, /obj/item/restraints/handcuffs/cable/zipties/cyborg)
	special_rechargables = list(/obj/item/extinguisher/mini, /obj/item/weldingtool/mini)

// Replace their normal drill with a diamond drill.
/obj/item/robot_module/miner/emag_act()
	. = ..()
	for(var/obj/item/pickaxe/drill/cyborg/D in modules)
		// Make sure we don't remove the diamond drill If they already have a diamond drill from the borg upgrade.
		if(!istype(D, /obj/item/pickaxe/drill/cyborg/diamond))
			qdel(D)
			basic_modules -= D // Remove it from this list so it doesn't get added in the rebuild.

// Readd the normal drill
/obj/item/robot_module/miner/unemag()
	var/obj/item/pickaxe/drill/cyborg/C = new(src)
	basic_modules += C
	return ..()

// This makes it so others can crowbar out KA upgrades from the miner borg.
/obj/item/robot_module/miner/handle_custom_removal(component_id, mob/living/user, obj/item/W)
	if(component_id == "KA modkits")
		for(var/obj/item/gun/energy/kinetic_accelerator/cyborg/D in src)
			D.crowbar_act(user, W)
		to_chat(user, "You remove the KPA modkits.")
		return TRUE
	return ..()

// Deathsquad cyborg module.
/obj/item/robot_module/deathsquad
	name = "NT advanced combat module"
	module_type = "Malf"
	module_actions = list(/datum/action/innate/robot_sight/thermal)
	basic_modules = list(
		/obj/item/flash/cyborg,
		/obj/item/melee/energy/sword/cyborg,
		/obj/item/gun/energy/pulse/cyborg,
		/obj/item/crowbar/cyborg
	)
	special_rechargables = list(/obj/item/gun/energy/pulse/cyborg)

// Sydicate assault cyborg module.
/obj/item/robot_module/syndicate
	name = "syndicate assault robot module"
	module_type = "Malf" // cuz it looks cool
	basic_modules = list(
		/obj/item/flash/cyborg,
		/obj/item/melee/energy/sword/cyborg,
		/obj/item/gun/energy/printer,
		/obj/item/gun/projectile/revolver/grenadelauncher/multi/cyborg,
		/obj/item/card/emag,
		/obj/item/crowbar/cyborg,
		/obj/item/pinpointer/operative
	)

// Sydicate medical cyborg module.
/obj/item/robot_module/syndicate_medical
	name = "syndicate medical robot module"
	module_type = "Malf"
	basic_modules = list(
		/obj/item/flash/cyborg,
		/obj/item/healthanalyzer/advanced,
		/obj/item/reagent_scanner/adv,
		/obj/item/bodyanalyzer/borg/syndicate,
		/obj/item/borg_defib,
		/obj/item/handheld_defibrillator,
		/obj/item/roller_holder,
		/obj/item/reagent_containers/borghypo/syndicate,
		/obj/item/scalpel/laser/laser1,
		/obj/item/hemostat,
		/obj/item/retractor,
		/obj/item/melee/energy/sword/cyborg/saw, //Energy saw -- primary weapon
		/obj/item/surgicaldrill,
		/obj/item/bonesetter,
		/obj/item/bonegel,
		/obj/item/FixOVein,
		/obj/item/card/emag,
		/obj/item/crowbar/cyborg,
		/obj/item/pinpointer/operative,
		/obj/item/stack/medical/bruise_pack/advanced/cyborg/syndicate,
		/obj/item/stack/medical/ointment/advanced/cyborg/syndicate,
		/obj/item/stack/medical/splint/cyborg/syndicate,
		/obj/item/stack/nanopaste/cyborg/syndicate,
		/obj/item/gun/medbeam,
		/obj/item/extinguisher/mini,
		/obj/item/gripper_medical
	)
	special_rechargables = list(/obj/item/extinguisher/mini)

// Sydicate engineer/sabotuer cyborg module.
/obj/item/robot_module/syndicate_saboteur
	name = "saboteur robot module" // Disguises are handled in the actual cyborg projector
	module_type = "Malf"
	basic_modules = list(
		/obj/item/flash/cyborg,
		/obj/item/rcd/borg/syndicate,
		/obj/item/rpd,
		/obj/item/extinguisher,
		/obj/item/weldingtool/largetank/cyborg,
		/obj/item/screwdriver/cyborg,
		/obj/item/wrench/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/wirecutters/cyborg,
		/obj/item/multitool/cyborg,
		/obj/item/t_scanner,
		/obj/item/analyzer,
		/obj/item/gripper_engineering,
		/obj/item/melee/energy/sword/cyborg,
		/obj/item/card/emag,
		/obj/item/borg_chameleon,
		/obj/item/pinpointer/operative,
		/obj/item/stack/sheet/metal/cyborg,
		/obj/item/stack/rods/cyborg,
		/obj/item/stack/tile/plasteel/cyborg,
		/obj/item/stack/cable_coil/cyborg,
		/obj/item/stack/sheet/glass/cyborg,
		/obj/item/stack/sheet/rglass/cyborg
	)
	special_rechargables = list(/obj/item/extinguisher, /obj/item/weldingtool/largetank/cyborg)

/obj/item/robot_module/destroyer
	name = "destroyer robot module"
	module_type = "Malf"
	module_actions = list(/datum/action/innate/robot_sight/thermal)
	basic_modules = list(
		/obj/item/flash/cyborg,
		/obj/item/gun/energy/immolator/multi/cyborg, // See comments on /robot_module/combat below
		/obj/item/melee/baton/loaded, // secondary weapon, for things immune to burn, immune to ranged weapons, or for arresting low-grade threats
		/obj/item/restraints/handcuffs/cable/zipties/cyborg,
		/obj/item/pickaxe/drill/jackhammer, // for breaking walls to execute flanking moves
		/obj/item/borg/destroyer/mobility
	)
	special_rechargables = list(
		/obj/item/melee/baton/loaded,
		/obj/item/gun/energy/immolator/multi/cyborg
	)

/obj/item/robot_module/combat
	name = "combat robot module"
	module_type = "Malf"
	basic_modules = list(
		/obj/item/flash/cyborg,
		/obj/item/gun/energy/immolator/multi/cyborg, // primary weapon, strong at close range (ie: against blob/terror/xeno), but consumes a lot of energy per shot.
		// Borg gets 40 shots of this weapon. Gamma Sec ERT gets 10.
		// So, borg has way more burst damage, but also takes way longer to recharge / get back in the fight once depleted. Has to find a borg recharger and sit in it for ages.
		// Organic gamma sec ERT carries alternate weapons, including a box of flashbangs, and can load up on a huge number of guns from science. Borg cannot do either.
		// Overall, gamma borg has higher skill floor but lower skill ceiling.
		/obj/item/melee/baton/loaded, // secondary weapon, for things immune to burn, immune to ranged weapons, or for arresting low-grade threats
		/obj/item/restraints/handcuffs/cable/zipties/cyborg,
		/obj/item/pickaxe/drill/jackhammer // for breaking walls to execute flanking moves
	)
	special_rechargables = list(
		/obj/item/melee/baton/loaded,
		/obj/item/gun/energy/immolator/multi/cyborg
	)

// Xenomorph cyborg module.
/obj/item/robot_module/alien/hunter
	name = "alien hunter module"
	module_type = "Standard"
	module_actions = list(/datum/action/innate/robot_sight/thermal/alien)
	basic_modules = list(
		/obj/item/melee/energy/alien/claws,
		/obj/item/flash/cyborg/alien,
		/obj/item/reagent_containers/spray/alien/stun,
		/obj/item/reagent_containers/spray/alien/smoke,
	)
	emag_modules = list(/obj/item/reagent_containers/spray/alien/acid)
	special_rechargables = list(
		/obj/item/reagent_containers/spray/alien/acid,
		/obj/item/reagent_containers/spray/alien/stun,
		/obj/item/reagent_containers/spray/alien/smoke
	)

/obj/item/robot_module/alien/hunter/add_languages(mob/living/silicon/robot/R)
	. = ..()
	R.add_language("xenocommon", 1)

// Maintenance drone module.
/obj/item/robot_module/drone
	name = "drone module"
	module_type = "Engineer"
	basic_modules = list(
		/obj/item/weldingtool/largetank/cyborg,
		/obj/item/screwdriver/cyborg,
		/obj/item/wrench/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/wirecutters/cyborg/drone,
		/obj/item/multitool/cyborg/drone,
		/obj/item/lightreplacer/cyborg,
		/obj/item/gripper_engineering,
		/obj/item/matter_decompiler,
		/obj/item/reagent_containers/spray/cleaner/drone,
		/obj/item/soap,
		/obj/item/t_scanner,
		/obj/item/rpd,
		/obj/item/analyzer,
		/obj/item/stack/sheet/metal/cyborg,
		/obj/item/stack/rods/cyborg,
		/obj/item/stack/tile/plasteel/cyborg,
		/obj/item/stack/cable_coil/cyborg,
		/obj/item/stack/sheet/glass/cyborg,
		/obj/item/stack/sheet/rglass/cyborg,
		/obj/item/stack/sheet/wood/cyborg,
		/obj/item/stack/tile/wood/cyborg
	)
	special_rechargables = list(
		/obj/item/reagent_containers/spray/cleaner/drone,
		/obj/item/weldingtool/largetank/cyborg,
		/obj/item/lightreplacer/cyborg
	)

/obj/item/robot_module/drone/handle_death(mob/living/silicon/robot/R, gibbed)
	var/obj/item/gripper_engineering/G = locate(/obj/item/gripper_engineering) in modules
	if(G)
		G.drop_gripped_item(silent = TRUE)

/// Checks whether this item is a module of the robot it is located in.
/obj/item/proc/is_robot_module()
	if(!isrobot(loc))
		return FALSE

	var/mob/living/silicon/robot/R = loc

	return (src in R.module.modules)

/**
 *	# The robot_energy_storage datum
 *
 *  Used to handle robot stack items, such as metal, wood, nanopaste, etc.
 *
 *	To make things simple, the default `cost` of using 1 item from a borg stack, is 1.
 *	So then for example, when we have a `max_energy` of 50, the borg can use 50 of that item before it runs out.
 *
 *	The `recharge_rate` will be affected by the charge rate of a borg recharger, depending on the level of parts. By default it is 1.
 *	This amount will be given every 2 seconds. So at round start, rechargers will give 1 energy back every 2 seconds, to each stack the borg has.
 */
/datum/robot_energy_storage
	/// The name of the energy storage.
	var/name = "Generic energy storage"
	/// The name that will be displayed in the status panel.
	var/statpanel_name = "Statpanel name"
	/// The max amount of energy the stack can hold at once.
	var/max_energy = 50
	/// The amount of energy the stack will regain while charging.
	var/recharge_rate = 1
	/// Current amount of energy.
	var/energy

/datum/robot_energy_storage/New(obj/item/robot_module/R = null)
	if(!energy)
		energy = max_energy
	if(R)
		R.storages += src

/**
 * Called whenever the cyborg uses one of its stacks. Subtract the amount used from this datum's `energy` variable.
 *
 * Arguments:
 * * amount - the number to subtract from the `energy` var.
 */
/datum/robot_energy_storage/proc/use_charge(amount)
	if(energy < amount)
		return FALSE // If we have more energy that we're about to drain, return

	energy -= amount
	return TRUE

/**
 * Called whenever the cyborg is recharging and gains charge on its stack, or when clicking on other same-type stacks in the world.
 *
 * Arguments:
 * * amount - the number to add to the `energy` var.
 */
/datum/robot_energy_storage/proc/add_charge(amount)
	energy = min(energy + amount, max_energy)

/datum/robot_energy_storage/metal
	name = "Metal Synthesizer"
	statpanel_name = "Metal"

/datum/robot_energy_storage/metal_tile
	name = "Floor tile Synthesizer"
	statpanel_name = "Floor tiles"
	max_energy = 60

/datum/robot_energy_storage/rods
	name = "Rod Synthesizer"
	statpanel_name = "Rods"

/datum/robot_energy_storage/glass
	name = "Glass Synthesizer"
	statpanel_name = "Glass"

/datum/robot_energy_storage/rglass
	name = "Reinforced glass Synthesizer"
	statpanel_name = "Reinforced glass"

/datum/robot_energy_storage/wood
	name = "Wood Synthesizer"
	statpanel_name = "Wood"

/datum/robot_energy_storage/wood_tile
	name = "Wooden tile Synthesizer"
	statpanel_name = "Wooden tiles"
	max_energy = 60

/datum/robot_energy_storage/cable
	name = "Cable Synthesizer"
	statpanel_name = "Cable"

// For the medical stacks, even though the recharge rate is 0, it will be set to 1 by default because of a `max()` proc.
// It will always take ~12 seconds to fully recharge these stacks beacuse of this. This time does not apply to the syndicate storages.
/datum/robot_energy_storage/medical
	name = "Medical Synthesizer"
	max_energy = 6
	recharge_rate = 0

/datum/robot_energy_storage/medical/splint
	name = "Splint Synthesizer"
	statpanel_name = "Splints"

/datum/robot_energy_storage/medical/splint/syndicate
	max_energy = 25

/datum/robot_energy_storage/medical/adv_burn_kit
	name = "Burn kit Synthesizer"
	statpanel_name = "Burn kits"

/datum/robot_energy_storage/medical/adv_burn_kit/syndicate
	max_energy = 25

/datum/robot_energy_storage/medical/adv_brute_kit
	name = "Trauma kit Synthesizer"
	statpanel_name = "Brute kits"

/datum/robot_energy_storage/medical/adv_brute_kit/syndicate
	max_energy = 25

/datum/robot_energy_storage/medical/nanopaste
	name = "Nanopaste Synthesizer"
	statpanel_name = "Nanopaste"

/datum/robot_energy_storage/medical/nanopaste/syndicate
	max_energy = 25
