/obj/item/robot_module
	name = "robot module"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	w_class = 100
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
	/// A list of modules the robot gets when Safety Overridden.
	var/list/override_modules = list()
	/// A list of modules the robot gets when either emagged or Safety Overridden.
	var/list/emag_override_modules = list()
	/// A list of modules that the robot gets when malf AI buys it.
	var/list/malf_modules = list()
	/// A list of modules that require special recharge handling. Examples include things like flashes, sprays and welding tools.
	var/list/special_rechargables = list()
	/// A list of all "energy stacks", i.e cables, brute kits, splints, etc.
	var/list/storages = list()
	/// A list of all "material stacks", i.e. metal, glass, and reinforced glass
	var/list/material_storages = list()
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

	for(var/i in override_modules)
		var/obj/item/I = new i(src)
		override_modules += I
		override_modules -= i
	// Even though these are created here the robot won't be able to see and equip them until they actually get emagged/hacked.
	for(var/i in emag_modules)
		var/obj/item/I = new i(src)
		emag_modules += I
		emag_modules -= i

	for(var/i in emag_override_modules)
		var/obj/item/I = new i(src)
		emag_override_modules += I
		emag_override_modules -= i

	for(var/i in malf_modules)
		var/obj/item/I = new i(src)
		malf_modules += I
		malf_modules -= i

	// Flashes need a special recharge, and since basically every module uses it, add it here.
	// Even if the module doesn't use a flash, it wont cause any issues to have it in this list.
	special_rechargables += /obj/item/flash/cyborg

	// This is done so we can loop through this list later and call cyborg_recharge() on the items while the borg is recharging.
	var/all_modules = basic_modules | override_modules | emag_modules | emag_override_modules | malf_modules
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
	QDEL_LIST_CONTENTS(override_modules)
	QDEL_LIST_CONTENTS(emag_modules)
	QDEL_LIST_CONTENTS(emag_override_modules)
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
		override_modules,
		emag_modules,
		emag_override_modules,
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
		I.set_nodrop(TRUE)
		I.mouse_opacity = MOUSE_OPACITY_OPAQUE

/**
 * Returns a `robot_energy_strage` datum of type `storage_type`. If one already exists, it returns that one, otherwise it create a new one.
 *
 * Arguments:
 * * storage_type - the subtype of `datum/robot_storage` to fetch or create.
 */
/obj/item/robot_module/proc/get_or_create_estorage(storage_type)
	for(var/e_storage in storages)
		var/datum/robot_storage/energy/S = e_storage
		if(istype(S, storage_type))
			return S
		var/datum/robot_storage/material/M = e_storage
		if(istype(M, storage_type))
			return M
	return new storage_type(src)

/**
 * Adds the item `I` to our `modules` list, and sets up an `/datum/robot_storage/energy` if its a stack.
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
	I.set_nodrop(TRUE)
	I.mouse_opacity = MOUSE_OPACITY_OPAQUE

	if(requires_rebuild)
		rebuild_modules()
	return I

/**
 * Builds the usable module list from the modules we have in `basic_modules`, `override_modules`, `emag_modules`, `emag_override_modules` and `malf_modules`
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

	if(R.weapons_unlock)
		for(var/item in override_modules)
			add_module(item, FALSE)

	if(R.emagged)
		for(var/item in emag_modules)
			add_module(item, FALSE)

	if(R.weapons_unlock || R.emagged)
		for(var/item in emag_override_modules)
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
	for(var/datum/robot_storage/energy/e_storage in storages)
		e_storage.add_charge(max(1, coeff * e_storage.recharge_rate))
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
	R.add_language("Galactic Common", TRUE)
	R.add_language("Sol Common", TRUE)
	R.add_language("Tradeband", TRUE)
	R.add_language("Gutter", FALSE)
	R.add_language("Cygni Standard", TRUE)
	R.add_language("Sinta'unathi", FALSE)
	R.add_language("Siik'tajr", FALSE)
	R.add_language("Canilunzt", FALSE)
	R.add_language("Qurvolious", FALSE)
	R.add_language("Vox-pidgin", FALSE)
	R.add_language("Rootspeak", FALSE)
	R.add_language("Trinary", TRUE)
	R.add_language("Chittin", FALSE)
	R.add_language("Bubblish", FALSE)
	R.add_language("Orluum", FALSE)
	R.add_language("Clownish", FALSE)
	R.add_language("Tkachi", FALSE)

///Adds armor to a cyborg. Normaly resets it to 0 across the board, unless the module has an armor defined.
/obj/item/robot_module/proc/add_armor(mob/living/silicon/robot/R)
	R.armor = module_armor


/// Adds anything in `subsystems` to the robot's verbs, and grants any actions that are in `module_actions`.
/obj/item/robot_module/proc/add_subsystems_and_actions(mob/living/silicon/robot/R)
	add_verb(R, subsystems)
	for(var/A in module_actions)
		var/datum/action/act = new A()
		act.Grant(R)
		R.module_actions += act

/// Removes any verbs from the robot that are in `subsystems`, and removes any actions that are in `module_actions`.
/obj/item/robot_module/proc/remove_subsystems_and_actions(mob/living/silicon/robot/R)
	remove_verb(R, subsystems)
	for(var/datum/action/A in R.module_actions)
		A.Remove(R)
		qdel(A)
	R.module_actions.Cut()

// Return true in an overridden subtype to prevent normal removal handling
/obj/item/robot_module/proc/handle_custom_removal(component_id, mob/living/user, obj/item/W)
	return FALSE

/// Overriden for specific modules if they have storage items. These should have their contents emptied out onto the floor.
/obj/item/robot_module/proc/handle_death(mob/living/silicon/robot/R, gibbed)
	return

// MARK: Robot Modules
// Medical
/obj/item/robot_module/medical
	name = "medical robot module"
	module_type = "Medical"
	subsystems = list(/mob/living/silicon/proc/subsystem_crew_monitor)
	basic_modules = list(
		/obj/item/flash/cyborg,
		/obj/item/crowbar/cyborg/red,
		/obj/item/healthanalyzer/advanced,
		/obj/item/robotanalyzer,
		/obj/item/borg_defib,
		/obj/item/handheld_defibrillator,
		/obj/item/roller_holder,
		/obj/item/reagent_containers/borghypo,
		/obj/item/scalpel/laser/laser1,
		/obj/item/hemostat,
		/obj/item/retractor,
		/obj/item/circular_saw,
		/obj/item/surgicaldrill,
		/obj/item/bonesetter,
		/obj/item/bonegel,
		/obj/item/fix_o_vein,
		/obj/item/extinguisher/mini/cyborg,
		/obj/item/reagent_containers/glass/beaker/large,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/syringe,
		/obj/item/stack/medical/bruise_pack/advanced/cyborg,
		/obj/item/stack/medical/ointment/advanced/cyborg,
		/obj/item/stack/medical/splint/cyborg,
		/obj/item/stack/nanopaste/cyborg,
		/obj/item/gripper/medical,
		/obj/item/surgical_drapes,
	)
	malf_modules = list(/obj/item/gun/syringemalf)
	special_rechargables = list(
		/obj/item/extinguisher/mini/cyborg,
		/obj/item/gun/syringemalf
	)

/obj/item/robot_module/medical/handle_death(mob/living/silicon/robot/R, gibbed)
	var/obj/item/gripper/medical/G = locate(/obj/item/gripper/medical) in modules
	if(G)
		G.drop_gripped_item(silent = TRUE)

// Emag the robot's equipment.
/obj/item/robot_module/medical/emag_act(mob/user)
	. = ..()
	for(var/obj/item/borg_defib/F in modules)
		F.emag_act()
	for(var/obj/item/reagent_containers/borghypo/F in modules)
		F.emag_act()
	for(var/obj/item/gripper/F in modules)
		F.emag_act()

// Remove the emagging on the robot's equipment.
/obj/item/robot_module/medical/unemag()
	for(var/obj/item/borg_defib/F in modules)
		F.emag_act()
	for(var/obj/item/reagent_containers/borghypo/F in modules)
		F.emag_act()
	for(var/obj/item/gripper/F in modules)
		F.emag_act()
	return ..()

/// Malf Syringe Gun
/obj/item/gun/syringemalf
	name = "plasma syringe cannon"
	desc = "A syringe gun integrated into a medical cyborg's chassis. Fires heavy-duty plasma syringes tipped in poison."
	icon_state = "rapidsyringegun"
	throw_range = 7
	force = 4
	fire_sound = 'sound/items/syringeproj.ogg'
	fire_delay = 0.75
	var/max_syringes = 14
	var/current_syringes = 14

//Preload Syringes
/obj/item/gun/syringemalf/Initialize(mapload)
	. = ..()
	chambered = new /obj/item/ammo_casing/syringegun(src)
	process_chamber()

//Recharge syringes in a recharger
/obj/item/gun/syringemalf/cyborg_recharge(coeff, emagged)
	if(current_syringes + (chambered.BB ? 1 : 0) < max_syringes)
		current_syringes++
		process_chamber()

//Cannot manually remove syringes
/obj/item/gun/syringemalf/attack_self__legacy__attackchain(mob/living/user)
	return

//Load syringe into the chamber
/obj/item/gun/syringemalf/process_chamber()
	if(!current_syringes || chambered?.BB)
		return

	chambered.BB = new /obj/item/projectile/bullet/dart/syringe/heavyduty(src)
	chambered.BB.reagents.add_reagent_list(list("toxin" = 2))
	chambered.BB.name = "heavy duty syringe"
	current_syringes--

/obj/item/gun/syringemalf/examine(mob/user)
	. = ..()
	var/num_syringes = current_syringes + (chambered.BB ? 1 : 0)
	. += "Can hold [max_syringes] syringe\s. Has [num_syringes] syringe\s remaining."

// Fluorosulphuric acid spray bottle.
/obj/item/reagent_containers/spray/cyborg_facid
	name = "Polyacid spray"
	spray_maxrange = 3
	spray_currentrange = 3
	adjustable = FALSE
	list_reagents = list("facid" = 250)

/obj/item/reagent_containers/spray/cyborg_facid/cyborg_recharge(coeff, emagged)
	if(emagged)
		reagents.check_and_add("facid", volume, 2 * coeff)

// Engineering
/obj/item/robot_module/engineering
	name = "engineering robot module"
	module_type = "Engineer"
	subsystems = list(/mob/living/silicon/proc/subsystem_power_monitor)
	module_actions = list(/datum/action/innate/robot_sight/engineering_scanner, /datum/action/innate/robot_magpulse)
	basic_modules = list(
		/obj/item/flash/cyborg,
		/obj/item/rpd,
		/obj/item/extinguisher,
		/obj/item/extinguisher/mini/cyborg, // Give them the option of BOTH extinguishers
		/obj/item/weldingtool/largetank/cyborg,
		/obj/item/screwdriver/cyborg,
		/obj/item/wrench/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/wirecutters/cyborg,
		/obj/item/multitool/cyborg,
		/obj/item/analyzer,
		/obj/item/geiger_counter/cyborg,
		/obj/item/holosign_creator/engineering,
		/obj/item/gripper/engineering,
		/obj/item/matter_decompiler,
		/obj/item/painter,
		/obj/item/areaeditor/blueprints/cyborg,
		/obj/item/stack/sheet/metal/cyborg,
		/obj/item/stack/rods/cyborg,
		/obj/item/stack/tile/plasteel/cyborg,
		/obj/item/stack/tile/catwalk/cyborg,
		/obj/item/stack/cable_coil/cyborg,
		/obj/item/stack/cable_coil/extra_insulated/cyborg,
		/obj/item/stack/sheet/glass/cyborg,
		/obj/item/stack/sheet/rglass/cyborg,
		/obj/item/inflatable/cyborg,
		/obj/item/inflatable/cyborg/door
	)
	emag_modules = list(/obj/item/melee/baton/loaded/borg_stun_arm, /obj/item/restraints/handcuffs/cable/zipties/cyborg, /obj/item/rcd/borg)
	override_modules = list(/obj/item/gun/energy/emitter/cyborg/proto)
	malf_modules = list(/obj/item/gun/energy/emitter/cyborg)
	special_rechargables = list(/obj/item/extinguisher, /obj/item/extinguisher/mini/cyborg, /obj/item/weldingtool/largetank/cyborg, /obj/item/gun/energy/emitter/cyborg)

/obj/item/robot_module/engineering/handle_death(mob/living/silicon/robot/R, gibbed)
	var/obj/item/gripper/engineering/G = locate(/obj/item/gripper/engineering) in modules
	var/obj/item/storage/part_replacer/P = locate(/obj/item/storage/part_replacer) in modules
	if(G)
		G.drop_gripped_item(silent = TRUE)
	if(istype(P))
		P.drop_inventory(R)

/obj/item/robot_module/engineering/emag_act(mob/user)
	. = ..()
	for(var/obj/item/gripper/F in modules)
		F.emag_act()

/obj/item/robot_module/engineering/unemag()
	for(var/obj/item/gripper/F in modules)
		F.emag_act()
	return ..()

// Security
/obj/item/robot_module/security
	name = "security robot module"
	module_type = "Security"
	subsystems = list(/mob/living/silicon/proc/subsystem_crew_monitor)
	basic_modules = list(
		/obj/item/flash/cyborg,
		/obj/item/crowbar/cyborg/red,
		/obj/item/restraints/handcuffs/cable/zipties/cyborg,
		/obj/item/melee/baton/loaded,
		/obj/item/gun/energy/disabler/cyborg,
		/obj/item/holosign_creator/security,
		/obj/item/clothing/mask/gas/sechailer/cyborg
	)
	emag_override_modules = list(/obj/item/gun/energy/laser/cyborg)
	special_rechargables = list(
		/obj/item/melee/baton/loaded,
		/obj/item/gun/energy/disabler/cyborg,
		/obj/item/gun/energy/laser/cyborg
	)

/obj/item/robot_module/security/update_cells(unlink_cell = FALSE)
	var/obj/item/melee/baton/B = locate(/obj/item/melee/baton/loaded) in modules
	if(B)
		B.link_new_cell(unlink_cell)

// Janitor
/obj/item/robot_module/janitor
	name = "janitorial robot module"
	module_type = "Janitor"
	basic_modules = list(
		/obj/item/flash/cyborg,
		/obj/item/crowbar/cyborg/red,
		/obj/item/soap/nanotrasen,
		/obj/item/storage/bag/trash/cyborg,
		/obj/item/mop/advanced/cyborg,
		/obj/item/lightreplacer/cyborg,
		/obj/item/holosign_creator/janitor,
		/obj/item/extinguisher/mini/cyborg,
		/obj/item/melee/flyswatter
	)
	emag_override_modules = list(/obj/item/reagent_containers/spray/cyborg_lube)
	emag_modules = list(/obj/item/reagent_containers/spray/cyborg_facid, /obj/item/malfbroom)
	malf_modules = list(/obj/item/stack/caution/proximity_sign/malf)
	special_rechargables = list(
		/obj/item/lightreplacer,
		/obj/item/reagent_containers/spray/cyborg_lube,
		/obj/item/reagent_containers/spray/cyborg_facid,
		/obj/item/extinguisher/mini/cyborg
	)

/obj/item/robot_module/janitor/handle_death(mob/living/silicon/robot/R, gibbed)
	var/obj/item/storage/bag/trash/T = locate(/obj/item/storage/bag/trash) in modules
	if(istype(T))
		T.drop_inventory(R)

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


/obj/item/malfbroom
	name = "cyborg combat broom"
	desc = "A steel-core push broom for the hostile cyborg. The firm bristles make it more suitable for fighting than cleaning."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "broom0"
	base_icon_state = "broom"
	attack_verb = list("smashed", "slammed", "whacked", "thwacked", "swept")
	force = 20

/obj/item/malfbroom/attack__legacy__attackchain(mob/target, mob/user)
	if(!ishuman(target))
		return ..()
	var/mob/living/carbon/human/H = target
	if(H.stat != CONSCIOUS || IS_HORIZONTAL(H))
		return ..()
	H.visible_message("<span class='danger'>[user] sweeps [H]'s legs out from under [H.p_them()]!</span>", \
						"<span class='userdanger'>[user] sweeps your legs out from under you!</span>", \
						"<span class='italics'>You hear sweeping.</span>")
	playsound(get_turf(user), 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
	H.apply_damage(20, BRUTE)
	H.KnockDown(4 SECONDS)
	add_attack_logs(user, H, "Leg swept with cyborg combat broom", ATKLOG_ALL)

// Service
/obj/item/robot_module/butler
	name = "service robot module"
	module_type = "Service"
	basic_modules = list(
		/obj/item/flash/cyborg,
		/obj/item/crowbar/cyborg/red,
		/obj/item/handheld_chem_dispenser/booze,
		/obj/item/handheld_chem_dispenser/soda,
		/obj/item/pen/multi,
		/obj/item/razor,
		/obj/item/instrument/piano_synth,
		/obj/item/healthanalyzer/advanced,
		/obj/item/rsf,
		/obj/item/reagent_containers/dropper/cyborg,
		/obj/item/lighter/zippo,
		/obj/item/storage/bag/tray/cyborg,
		/obj/item/reagent_containers/drinks/shaker,
		/obj/item/gripper/service
	)
	emag_override_modules = list(/obj/item/reagent_containers/drinks/bottle/beer/sleepy_beer)
	emag_modules = list(/obj/item/restraints/handcuffs/cable/zipties/cyborg, /obj/item/instrument/guitar/cyborg)
	malf_modules = list(/obj/item/gun/energy/gun/shotgun/cyborg)
	special_rechargables = list(
		/obj/item/reagent_containers/condiment/enzyme,
		/obj/item/reagent_containers/drinks/bottle/beer/sleepy_beer,
		/obj/item/gun/projectile/shotgun/automatic/combat/cyborg
	)

/obj/item/robot_module/butler/handle_death(mob/living/silicon/robot/R, gibbed)
	var/obj/item/gripper/service/G = locate(/obj/item/gripper/service) in modules
	var/obj/item/storage/bag/tray/cyborg/T = locate(/obj/item/storage/bag/tray/cyborg) in modules
	if(G)
		G.drop_gripped_item(silent = TRUE)
	if(istype(T))
		T.drop_inventory(R)

/obj/item/robot_module/butler/emag_act(mob/user)
	. = ..()
	for(var/obj/item/gripper/F in modules)
		F.emag_act()

/obj/item/robot_module/butler/unemag()
	for(var/obj/item/gripper/F in modules)
		F.emag_act()
	return ..()

// This is a special type of beer given when emagged, one sip and the target falls asleep.
/obj/item/reagent_containers/drinks/bottle/beer/sleepy_beer
	name = "Mickey Finn's Special Brew"
	list_reagents = list("beer2" = 50)
	is_glass = FALSE // Smashing a borgs sole beer bottle would be sad

/obj/item/reagent_containers/drinks/bottle/beer/sleepy_beer/cyborg_recharge(coeff, emagged)
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
	R.add_language("Qurvolious", 1)
	R.add_language("Vox-pidgin", 1)
	R.add_language("Rootspeak", 1)
	R.add_language("Trinary", 1)
	R.add_language("Chittin", 1)
	R.add_language("Bubblish", 1)
	R.add_language("Clownish",1)
	R.add_language("Cygni Standard", 1)
	R.add_language("Tkachi", 1)

// Mining
/obj/item/robot_module/miner
	name = "miner robot module"
	module_type = "Miner"
	module_armor = list(MELEE = 20, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 0, ACID = 0)
	module_actions = list(/datum/action/innate/robot_sight/meson)
	custom_removals = list("KA modkits")
	basic_modules = list(
		/obj/item/flash/cyborg,
		/obj/item/crowbar/cyborg/red,
		/obj/item/storage/bag/ore/cyborg,
		/obj/item/pickaxe/drill/cyborg,
		/obj/item/shovel,
		/obj/item/weldingtool/mini,
		/obj/item/extinguisher/mini/cyborg,
		/obj/item/t_scanner/adv_mining_scanner/cyborg,
		/obj/item/gun/energy/kinetic_accelerator/cyborg,
		/obj/item/gps/cyborg,
		/obj/item/gripper/mining
	)
	emag_modules = list(/obj/item/pickaxe/drill/jackhammer)
	malf_modules = list(/obj/item/gun/energy/kinetic_accelerator/cyborg/malf)
	special_rechargables = list(/obj/item/extinguisher/mini/cyborg, /obj/item/weldingtool/mini)

/obj/item/robot_module/miner/handle_death(mob/living/silicon/robot/R, gibbed)
	var/obj/item/gripper/mining/G = locate(/obj/item/gripper/mining) in modules
	var/obj/item/storage/bag/ore/B = locate(/obj/item/storage/bag/ore) in modules
	if(G)
		G.drop_gripped_item(silent = TRUE)
	if(istype(B))
		B.drop_inventory(R)

/obj/item/robot_module/miner/emag_act(mob/user)
	. = ..()
	for(var/obj/item/gripper/F in modules)
		F.emag_act()

/obj/item/robot_module/miner/unemag()
	for(var/obj/item/gripper/F in modules)
		F.emag_act()
	return ..()

// This makes it so others can crowbar out KA upgrades from the miner borg.
/obj/item/robot_module/miner/handle_custom_removal(component_id, mob/living/user, obj/item/W)
	if(component_id == "KA modkits")
		for(var/obj/item/gun/energy/kinetic_accelerator/cyborg/D in src)
			D.crowbar_act(user, W)
		to_chat(user, "You remove the KPA modkits.")
		return TRUE
	return ..()

// Xeno Hunter
/obj/item/robot_module/alien/hunter
	name = "alien hunter module"
	module_type = "Standard"
	module_actions = list(/datum/action/innate/robot_sight/thermal/alien)
	basic_modules = list(
		/obj/item/crowbar/cyborg/red,
		/obj/item/melee/energy/alien/claws,
		/obj/item/flash/cyborg/alien,
		/obj/item/reagent_containers/spray/alien/smoke,
	)
	emag_override_modules = list(/obj/item/reagent_containers/spray/alien/acid)
	special_rechargables = list(
		/obj/item/reagent_containers/spray/alien/acid,
		/obj/item/reagent_containers/spray/alien/smoke
	)

/obj/item/robot_module/alien/hunter/add_languages(mob/living/silicon/robot/R)
	. = ..()
	R.add_language("xenocommon", 1)

// Maintenance Drone
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
		/obj/item/gripper/engineering,
		/obj/item/matter_decompiler,
		/obj/item/reagent_containers/spray/cleaner/drone,
		/obj/item/soap,
		/obj/item/t_scanner,
		/obj/item/painter,
		/obj/item/rpd,
		/obj/item/analyzer,
		/obj/item/stack/sheet/metal/cyborg/drone,
		/obj/item/stack/rods/cyborg,
		/obj/item/stack/tile/plasteel/cyborg,
		/obj/item/stack/tile/catwalk/cyborg,
		/obj/item/stack/cable_coil/cyborg,
		/obj/item/stack/cable_coil/extra_insulated/cyborg,
		/obj/item/stack/sheet/glass/cyborg/drone,
		/obj/item/stack/sheet/rglass/cyborg/drone,
		/obj/item/stack/sheet/wood/cyborg,
		/obj/item/stack/tile/wood/cyborg
	)
	special_rechargables = list(
		/obj/item/reagent_containers/spray/cleaner/drone,
		/obj/item/weldingtool/largetank/cyborg,
		/obj/item/lightreplacer/cyborg
	)

/obj/item/robot_module/drone/handle_death(mob/living/silicon/robot/R, gibbed)
	var/obj/item/gripper/engineering/G = locate(/obj/item/gripper/engineering) in modules
	if(G)
		G.drop_gripped_item(silent = TRUE)

/obj/item/robot_module/drone/emag_act(mob/user)
	. = ..()
	for(var/obj/item/gripper/F in modules)
		F.emag_act()

/obj/item/robot_module/drone/unemag()
	for(var/obj/item/gripper/F in modules)
		F.emag_act()
	return ..()

// Sydicate Assault cyborg module.
/obj/item/robot_module/syndicate
	name = "syndicate assault robot module"
	module_type = "Malf" // cuz it looks cool
	basic_modules = list(
		/obj/item/flash/cyborg,
		/obj/item/melee/energy/sword/cyborg,
		/obj/item/gun/energy/printer,
		/obj/item/gun/projectile/revolver/grenadelauncher/multi/cyborg,
		/obj/item/card/emag,
		/obj/item/crowbar/cyborg/red,
		/obj/item/pinpointer/operative,
	)

// Sydicate Medical cyborg module.
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
		/obj/item/fix_o_vein,
		/obj/item/card/emag,
		/obj/item/crowbar/cyborg/red,
		/obj/item/pinpointer/operative,
		/obj/item/stack/medical/bruise_pack/advanced/cyborg/syndicate,
		/obj/item/stack/medical/ointment/advanced/cyborg/syndicate,
		/obj/item/stack/medical/splint/cyborg/syndicate,
		/obj/item/stack/nanopaste/cyborg/syndicate,
		/obj/item/gun/medbeam,
		/obj/item/extinguisher/mini, // Why the hell would the syndicate care about greys?
		/obj/item/gripper/medical,
	)
	special_rechargables = list(/obj/item/extinguisher/mini)

/obj/item/robot_module/syndicate_medical/emag_act(mob/user)
	. = ..()
	for(var/obj/item/gripper/F in modules)
		F.emag_act()

/obj/item/robot_module/syndicate_medical/unemag()
	for(var/obj/item/gripper/F in modules)
		F.emag_act()
	return ..()

// Sydicate Sabotuer/Engineering cyborg module.
/obj/item/robot_module/syndicate_saboteur
	name = "saboteur robot module" // Disguises are handled in the actual cyborg projector
	module_type = "Malf"
	basic_modules = list(
		/obj/item/flash/cyborg,
		/obj/item/rcd/borg/syndicate,
		/obj/item/rpd,
		/obj/item/extinguisher, // Syndicate dont care about no greys.
		/obj/item/weldingtool/largetank/cyborg,
		/obj/item/screwdriver/cyborg,
		/obj/item/wrench/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/wirecutters/cyborg,
		/obj/item/multitool/cyborg,
		/obj/item/t_scanner,
		/obj/item/analyzer,
		/obj/item/gripper/engineering,
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

/obj/item/robot_module/syndicate_saboteur/emag_act(mob/user)
	. = ..()
	for(var/obj/item/gripper/F in modules)
		F.emag_act()

/obj/item/robot_module/syndicate_saboteur/unemag()
	for(var/obj/item/gripper/F in modules)
		F.emag_act()
	return ..()

// Gamma security module.
/obj/item/robot_module/combat
	name = "combat robot module"
	module_type = "Malf"
	module_actions = list(/datum/action/innate/robot_magpulse)
	basic_modules = list(
		/obj/item/flash/cyborg,
		/obj/item/crowbar/cyborg/red,
		/obj/item/gun/energy/immolator/multi/cyborg, // primary weapon, strong at close range (ie: against blob/terror/xeno), but consumes a lot of energy per shot.
		// Borg gets 40 shots of this weapon. Gamma Sec ERT gets 10.
		// So, borg has way more burst damage, but also takes way longer to recharge / get back in the fight once depleted. Has to find a borg recharger and sit in it for ages.
		// Organic gamma sec ERT carries alternate weapons, including a box of flashbangs, and can load up on a huge number of guns from science. Borg cannot do either.
		// Overall, gamma borg has higher skill floor but lower skill ceiling.
		/obj/item/melee/baton/loaded, // secondary weapon, for things immune to burn, immune to ranged weapons, or for arresting low-grade threats
		/obj/item/restraints/handcuffs/cable/zipties/cyborg,
		/obj/item/pickaxe/drill/jackhammer, // for breaking walls to execute flanking moves
		/obj/item/extinguisher/mini/cyborg // for friendly fire from their immolator gun.
	)
	special_rechargables = list(
		/obj/item/melee/baton/loaded,
		/obj/item/gun/energy/immolator/multi/cyborg,
		/obj/item/extinguisher/mini/cyborg
	)

// Destroyer security module.
/obj/item/robot_module/destroyer
	name = "destroyer robot module"
	module_type = "Malf"
	module_actions = list(/datum/action/innate/robot_sight/thermal, /datum/action/innate/robot_magpulse)
	basic_modules = list(
		/obj/item/flash/cyborg,
		/obj/item/crowbar/cyborg/red,
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

// Deathsquad
/obj/item/robot_module/deathsquad
	name = "NT advanced combat module"
	module_type = "Malf"
	module_actions = list(/datum/action/innate/robot_sight/thermal, /datum/action/innate/robot_magpulse)
	basic_modules = list(
		/obj/item/flash/cyborg,
		/obj/item/melee/energy/sword/cyborg,
		/obj/item/gun/energy/pulse/cyborg,
		/obj/item/crowbar/cyborg/red,
	)
	special_rechargables = list(/obj/item/gun/energy/pulse/cyborg)

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

/datum/robot_storage
	/// The name of the storage.
	var/name = "Generic storage"
	/// The name that will be displayed in the status panel.
	var/statpanel_name = "Statpanel name"
	/// The max amount of materials the stack can hold at once.
	var/max_amount = 50
	/// Current amount of materials.
	var/amount

/datum/robot_storage/New(obj/item/robot_module/R)
	if(!amount)
		amount = max_amount

/**
 * Called whenever the cyborg uses one of its stacks. Subtract the amount used from this datum's `amount` variable.
 *
 * Arguments:
 * * reduction - the number to subtract from the `amount` var.
 */
/datum/robot_storage/proc/use_charge(reduction)
	if(amount < reduction)
		return FALSE // If we have more energy that we're about to drain, return

	amount -= reduction
	return TRUE

/**
 * Called whenever the cyborg is recharging and gains charge on its stack, or when clicking on other same-type stacks in the world.
 *
 * Arguments:
 * * addition - the number to add to the `energy` var.
 */
/datum/robot_storage/proc/add_charge(addition)
	amount = min(amount + addition, max_amount)

/datum/robot_storage/energy
	name = "Generic energy storage"
	/// The amount of energy the stack will regain while charging.
	var/recharge_rate = 1

/datum/robot_storage/energy/New(obj/item/robot_module/R)
	. = ..()
	if(R)
		R.storages += src

/datum/robot_storage/energy/metal
	name = "Metal Synthesizer"
	statpanel_name = "Metal"

/datum/robot_storage/energy/metal_tile
	name = "Floor tile Synthesizer"
	statpanel_name = "Floor tiles"
	max_amount = 60

/datum/robot_storage/energy/rods
	name = "Rod Synthesizer"
	statpanel_name = "Rods"

/datum/robot_storage/energy/catwalk
	name= "Catwalk Synthesizer"
	statpanel_name = "Catwalk Tiles"
	max_amount = 60

/datum/robot_storage/energy/glass
	name = "Glass Synthesizer"
	statpanel_name = "Glass"

/datum/robot_storage/energy/rglass
	name = "Reinforced glass Synthesizer"
	statpanel_name = "Reinforced glass"

/datum/robot_storage/energy/wood
	name = "Wood Synthesizer"
	statpanel_name = "Wood"

/datum/robot_storage/energy/wood_tile
	name = "Wooden tile Synthesizer"
	statpanel_name = "Wooden tiles"
	max_amount = 60

/datum/robot_storage/energy/cable
	name = "Cable Synthesizer"
	statpanel_name = "Cable"

// For the medical stacks, even though the recharge rate is 0, it will be set to 1 by default because of a `max()` proc.
// It will always take ~12 seconds to fully recharge these stacks beacuse of this. This time does not apply to the syndicate storages.
/datum/robot_storage/energy/medical
	name = "Medical Synthesizer"
	max_amount = 6
	recharge_rate = 0

/datum/robot_storage/energy/medical/splint
	name = "Splint Synthesizer"
	statpanel_name = "Splints"

/datum/robot_storage/energy/medical/splint/syndicate
	max_amount = 25

/datum/robot_storage/energy/medical/adv_burn_kit
	name = "Burn kit Synthesizer"
	statpanel_name = "Burn kits"

/datum/robot_storage/energy/medical/adv_burn_kit/syndicate
	max_amount = 25

/datum/robot_storage/energy/medical/adv_brute_kit
	name = "Trauma kit Synthesizer"
	statpanel_name = "Brute kits"

/datum/robot_storage/energy/medical/adv_brute_kit/syndicate
	max_amount = 25

/datum/robot_storage/energy/medical/nanopaste
	name = "Nanopaste Synthesizer"
	statpanel_name = "Nanopaste"

/datum/robot_storage/energy/medical/nanopaste/syndicate
	max_amount = 25

//Energy stack for landmines
/datum/robot_storage/energy/jani_landmine
	name = "Landmine Synthesizer"
	statpanel_name = "Landmines"
	max_amount = 4
	recharge_rate = 0.2

/// This datum is an alternative to the energy storages, instead being recharged in different ways
/datum/robot_storage/material
	name = "Generic material storage"
	/// What stacktype do we originally have
	var/stack
	/// Does this get added to the autorefill from the ORM
	var/add_to_storage = FALSE

/datum/robot_storage/material/New(obj/item/robot_module/R)
	if(R && add_to_storage)
		R.material_storages += src
	..()

/datum/robot_storage/material/glass
	name = "Glass Storage"
	statpanel_name = "Glass"
	stack = /obj/item/stack/sheet/glass
	add_to_storage = TRUE

/datum/robot_storage/material/rglass
	name = "Reinforced glass Storage"
	statpanel_name = "Reinforced glass"
	stack = /obj/item/stack/sheet/rglass

/datum/robot_storage/material/metal
	name = "Metal Storage"
	statpanel_name = "Metal"
	stack = /obj/item/stack/sheet/metal
	add_to_storage = TRUE

