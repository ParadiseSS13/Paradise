/obj/item/storage/belt
	name = "belt"
	desc = "Can hold various things."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "utilitybelt"
	item_state = "utility"
	lefthand_file = 'icons/mob/inhands/equipment/belt_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/belt_righthand.dmi'
	slot_flags = SLOT_BELT
	attack_verb = list("whipped", "lashed", "disciplined")
	max_integrity = 300
	equip_sound = 'sound/items/equip/toolbelt_equip.ogg'
	/// Do we have overlays for items held inside the belt?
	var/use_item_overlays = FALSE
	/// Bypasses the "belt in bag" prevention if TRUE
	var/storable = FALSE
	/// Ignores update_weight() if TRUE
	var/large = FALSE

/obj/item/storage/belt/proc/update_weight()
	if(large)
		return
	if(!length(contents) || storable)
		w_class = WEIGHT_CLASS_NORMAL
		return

	w_class = WEIGHT_CLASS_BULKY

/obj/item/storage/belt/remove_from_storage(obj/item/I, atom/new_location)
	. = ..()
	update_weight()

/obj/item/storage/belt/can_be_inserted(obj/item/I, stop_messages = FALSE)
	if(isstorage(loc) && !istype(loc, /obj/item/storage/backpack/holding) && !istype(loc, /obj/item/storage/hidden/implant) && !storable)
		to_chat(usr, "<span class='warning'>You can't seem to fit [I] into [src].</span>")
		return FALSE
	. = ..()

/obj/item/storage/belt/Initialize(mapload)
	. = ..()
	update_weight()

/obj/item/storage/belt/update_overlays()
	. = ..()
	if(!use_item_overlays)
		return
	for(var/obj/item/I in contents)
		if(!I.belt_icon)
			continue
		var/image/belt_image = image(icon, I.belt_icon)
		belt_image.color = I.color
		. += belt_image

/obj/item/storage/belt/handle_item_insertion(obj/item/I, prevent_warning)
	. = ..()
	update_weight()

/obj/item/storage/belt/proc/can_use()
	return is_equipped()

/obj/item/storage/belt/MouseDrop(obj/over_object, src_location, over_location)
	var/mob/M = usr
	if(!istype(over_object, /obj/screen))
		return ..()
	playsound(loc, "rustle", 50, TRUE, -5)
	if(!M.restrained() && !M.stat && can_use())
		switch(over_object.name)
			if("r_hand")
				M.unEquip(src, silent = TRUE)
				M.put_in_r_hand(src)
			if("l_hand")
				M.unEquip(src, silent = TRUE)
				M.put_in_l_hand(src)
		add_fingerprint(usr)
		return

/obj/item/storage/belt/deserialize(list/data)
	..()
	update_icon()

/obj/item/storage/belt/utility
	name = "tool-belt" //Carn: utility belt is nicer, but it bamboozles the text parsing.
	desc = "Can hold various tools."
	icon_state = "utilitybelt"
	item_state = "utility"
	use_item_overlays = TRUE
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 18
	drop_sound = 'sound/items/handling/toolbelt_drop.ogg'
	pickup_sound = 'sound/items/handling/toolbelt_pickup.ogg'
	can_hold = list(
		/obj/item/crowbar,
		/obj/item/screwdriver,
		/obj/item/weldingtool,
		/obj/item/wirecutters,
		/obj/item/wrench,
		/obj/item/multitool,
		/obj/item/flashlight,
		/obj/item/stack/cable_coil,
		/obj/item/t_scanner,
		/obj/item/analyzer,
		/obj/item/geiger_counter,
		/obj/item/extinguisher/mini,
		/obj/item/holosign_creator)

/obj/item/storage/belt/utility/full/populate_contents()
	new /obj/item/screwdriver(src)
	new /obj/item/wrench(src)
	new /obj/item/weldingtool(src)
	new /obj/item/crowbar(src)
	new /obj/item/wirecutters(src)
	new /obj/item/stack/cable_coil/random(src, 30)
	update_icon()

/obj/item/storage/belt/utility/full/multitool/populate_contents()
	..()
	new /obj/item/multitool(src)
	update_icon()

/obj/item/storage/belt/utility/atmostech/populate_contents()
	new /obj/item/screwdriver(src)
	new /obj/item/wrench(src)
	new /obj/item/weldingtool(src)
	new /obj/item/crowbar(src)
	new /obj/item/wirecutters(src)
	new /obj/item/t_scanner(src)
	new /obj/item/extinguisher/mini(src)
	update_icon()

/obj/item/storage/belt/utility/chief
	name = "advanced toolbelt"
	desc = "Holds tools, looks snazzy, and fits nicely into a bag"
	icon_state = "utilitybelt_ce"
	item_state = "utility_ce"
	storable = TRUE

/obj/item/storage/belt/utility/chief/full/populate_contents()
	new /obj/item/screwdriver/power(src)
	new /obj/item/crowbar/power(src)
	new /obj/item/weldingtool/experimental(src)//This can be changed if this is too much
	new /obj/item/multitool(src)
	new /obj/item/stack/cable_coil/random(src, 30)
	new /obj/item/extinguisher/mini(src)
	new /obj/item/analyzer(src)
	update_icon()
	//much roomier now that we've managed to remove two tools

/obj/item/storage/belt/utility/syndi_researcher // A cool looking belt thats essentially a syndicate toolbox
	desc = "A belt for holding tools, but with style."
	icon_state = "assaultbelt"
	item_state = "assault"

/obj/item/storage/belt/utility/syndi_researcher/populate_contents()
	new /obj/item/screwdriver(src, "red")
	new /obj/item/wrench(src)
	new /obj/item/weldingtool/largetank(src)
	new /obj/item/crowbar/red(src)
	new /obj/item/wirecutters(src, "red")
	new /obj/item/multitool/red(src)
	new /obj/item/stack/cable_coil(src, 30, COLOR_RED)
	update_icon()

/obj/item/storage/belt/medical
	name = "medical belt"
	desc = "Can hold various medical equipment."
	icon_state = "medicalbelt"
	item_state = "medical"
	use_to_pickup = TRUE //Allow medical belt to pick up medicine
	use_item_overlays = TRUE
	max_w_class = WEIGHT_CLASS_NORMAL
	can_hold = list(
		/obj/item/healthanalyzer,
		/obj/item/dnainjector,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/food/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/lighter/zippo,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/storage/pill_bottle,
		/obj/item/stack/medical,
		/obj/item/flashlight/pen,
		/obj/item/clothing/mask/surgical,
		/obj/item/clothing/gloves/color/latex,
		/obj/item/reagent_containers/hypospray/autoinjector,
		/obj/item/reagent_containers/hypospray/CMO,
		/obj/item/reagent_containers/hypospray/safety,
		/obj/item/sensor_device,
		/obj/item/wrench/medical,
		/obj/item/handheld_defibrillator,
		/obj/item/reagent_containers/applicator,
		/obj/item/geiger_counter
	)

/obj/item/storage/belt/medical/surgery
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 17
	use_to_pickup = TRUE
	name = "surgical belt"
	desc = "Can hold various surgical tools."
	storage_slots = 9
	use_item_overlays = TRUE
	can_hold = list(
		/obj/item/scalpel,
		/obj/item/hemostat,
		/obj/item/retractor,
		/obj/item/circular_saw,
		/obj/item/bonegel,
		/obj/item/bonesetter,
		/obj/item/FixOVein,
		/obj/item/surgicaldrill,
		/obj/item/cautery,
	)

/obj/item/storage/belt/medical/surgery/loaded/populate_contents()
	new /obj/item/scalpel(src)
	new /obj/item/hemostat(src)
	new /obj/item/retractor(src)
	new /obj/item/circular_saw(src)
	new /obj/item/bonegel(src)
	new /obj/item/bonesetter(src)
	new /obj/item/FixOVein(src)
	new /obj/item/surgicaldrill(src)
	new /obj/item/cautery(src)
	update_icon()

/obj/item/storage/belt/medical/response_team/populate_contents()
	new /obj/item/reagent_containers/food/pill/salbutamol(src)
	new /obj/item/reagent_containers/food/pill/salbutamol(src)
	new /obj/item/reagent_containers/food/pill/charcoal(src)
	new /obj/item/reagent_containers/food/pill/charcoal(src)
	new /obj/item/reagent_containers/food/pill/salicylic(src)
	new /obj/item/reagent_containers/food/pill/salicylic(src)
	new /obj/item/reagent_containers/food/pill/salicylic(src)
	update_icon()

/obj/item/storage/belt/botany
	name = "botanist belt"
	desc = "Can hold various botanical supplies."
	icon_state = "botanybelt"
	item_state = "botany"
	use_item_overlays = TRUE
	can_hold = list(
		/obj/item/plant_analyzer,
		/obj/item/cultivator,
		/obj/item/hatchet,
		/obj/item/reagent_containers/glass/bottle,
//		/obj/item/reagent_containers/syringe,
//		/obj/item/reagent_containers/glass/beaker,
		/obj/item/lighter/zippo,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/shovel/spade,
		/obj/item/flashlight/pen,
		/obj/item/seeds,
		/obj/item/wirecutters,
		/obj/item/wrench,
		/obj/item/reagent_containers/spray/weedspray,
		/obj/item/reagent_containers/spray/plantbgone,
		/obj/item/reagent_containers/spray/pestspray
		)

/obj/item/storage/belt/security
	name = "security belt"
	desc = "Can hold security gear like handcuffs and flashes."
	icon_state = "securitybelt"
	item_state = "security"//Could likely use a better one.
	storage_slots = 5
	max_w_class = WEIGHT_CLASS_NORMAL
	use_item_overlays = TRUE
	can_hold = list(
		/obj/item/grenade/flashbang,
		/obj/item/grenade/chem_grenade/teargas,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/restraints/handcuffs,
		/obj/item/flash,
		/obj/item/clothing/glasses,
		/obj/item/ammo_casing/shotgun,
		/obj/item/ammo_box,
		/obj/item/reagent_containers/food/snacks/donut,
		/obj/item/kitchen/knife/combat,
		/obj/item/melee/baton,
		/obj/item/melee/classic_baton,
		/obj/item/flashlight/seclite,
		/obj/item/holosign_creator/security,
		/obj/item/melee/classic_baton/telescopic,
		/obj/item/restraints/legcuffs/bola,
		/obj/item/clothing/mask/gas/sechailer,
		/obj/item/detective_scanner)

/obj/item/storage/belt/security/full/populate_contents()
	new /obj/item/reagent_containers/spray/pepper(src)
	new /obj/item/restraints/handcuffs(src)
	new /obj/item/grenade/flashbang(src)
	new /obj/item/flash(src)
	new /obj/item/melee/baton/loaded(src)
	update_icon()

/obj/item/storage/belt/security/response_team/populate_contents()
	new /obj/item/reagent_containers/spray/pepper(src)
	new /obj/item/melee/baton/loaded(src)
	new /obj/item/flash(src)
	new /obj/item/melee/classic_baton/telescopic(src)
	new /obj/item/grenade/flashbang(src)
	update_icon()

/obj/item/storage/belt/security/response_team_gamma/populate_contents()
	new /obj/item/melee/baton/loaded(src)
	new /obj/item/reagent_containers/spray/pepper(src)
	new /obj/item/flash(src)
	new /obj/item/grenade/flashbang(src)
	new /obj/item/grenade/flashbang(src)
	update_icon()

/obj/item/storage/belt/security/webbing
	name = "security webbing"
	desc = "Unique and versatile chest rig, can hold security gear."
	icon_state = "securitywebbing"
	item_state = "securitywebbing"
	storage_slots = 6
	use_item_overlays = FALSE
	can_hold = list(
		/obj/item/grenade/flashbang,
		/obj/item/grenade/chem_grenade/teargas,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/restraints/handcuffs,
		/obj/item/flash,
		/obj/item/clothing/glasses,
		/obj/item/ammo_casing/shotgun,
		/obj/item/ammo_box,
		/obj/item/reagent_containers/food/snacks/donut,
		/obj/item/kitchen/knife/combat,
		/obj/item/melee/baton,
		/obj/item/melee/classic_baton,
		/obj/item/flashlight/seclite,
		/obj/item/holosign_creator/security,
		/obj/item/melee/classic_baton/telescopic,
		/obj/item/restraints/legcuffs/bola,
		/obj/item/clothing/mask/gas/sechailer,
		/obj/item/detective_scanner,
		/obj/item/ammo_box/magazine/wt550m9
		)

/obj/item/storage/belt/soulstone
	name = "soul stone belt"
	desc = "Designed for ease of access to the shards during a fight, as to not let a single enemy spirit slip away"
	icon_state = "soulstonebelt"
	item_state = "soulstonebelt"
	storage_slots = 6
	use_item_overlays = TRUE
	can_hold = list(
		/obj/item/soulstone
		)

/obj/item/storage/belt/soulstone/full/populate_contents()
	for(var/I in 1 to 6)
		new /obj/item/soulstone(src)
	update_icon()


/obj/item/storage/belt/champion
	name = "championship belt"
	desc = "Proves to the world that you are the strongest!"
	icon_state = "championbelt"
	item_state = "champion"
	materials = list(MAT_GOLD=400)
	storage_slots = TRUE
	can_hold = list(
		/obj/item/clothing/mask/luchador
		)

/obj/item/storage/belt/military
	name = "military belt"
	desc = "A syndicate belt designed to be used by boarding parties.  Its style is modelled after the hardsuits they wear."
	icon_state = "militarybelt"
	item_state = "military"
	max_w_class = WEIGHT_CLASS_SMALL
	max_combined_w_class = 18
	resistance_flags = FIRE_PROOF

/obj/item/storage/belt/military/sst
	icon_state = "assaultbelt"
	item_state = "assault"

/obj/item/storage/belt/military/traitor
	name = "tool-belt"
	desc = "Can hold various tools. This model seems to have additional compartments and folds up rather nicely into a bag."
	icon_state = "utilitybelt"
	item_state = "utility"
	use_item_overlays = TRUE // So it will still show tools in it in case sec get lazy and just glance at it.
	storable = TRUE
	w_class_override = list(
		/obj/item/crowbar,
		/obj/item/screwdriver,
		/obj/item/weldingtool,
		/obj/item/wirecutters,
		/obj/item/wrench,
		/obj/item/multitool
		)

/obj/item/storage/belt/military/traitor/hacker/populate_contents()
	new /obj/item/screwdriver(src, "red")
	new /obj/item/wrench(src)
	new /obj/item/weldingtool/largetank(src)
	new /obj/item/crowbar/small(src)
	new /obj/item/wirecutters(src, "red")
	new /obj/item/stack/cable_coil(src, 30, COLOR_RED)
	update_icon()

/obj/item/storage/belt/grenade
	name = "grenadier belt"
	desc = "A belt for holding grenades."
	icon_state = "assaultbelt"
	item_state = "assault"
	storage_slots = 30
	max_combined_w_class = 60
	display_contents_with_number = TRUE
	can_hold = list(
		/obj/item/grenade,
		/obj/item/lighter,
		/obj/item/reagent_containers/food/drinks/bottle/molotov
		)

/obj/item/storage/belt/grenade/full/populate_contents()
	for(var/I in 1 to 4)
		new /obj/item/grenade/smokebomb(src) // Four of each
		new /obj/item/grenade/gluon(src)
	for(var/I in 1 to 10)
		new /obj/item/grenade/frag(src)
	for(var/I in 1 to 2)
		new /obj/item/grenade/gas/plasma(src)
		new /obj/item/grenade/empgrenade(src)
		new /obj/item/grenade/syndieminibomb(src)
	new /obj/item/grenade/chem_grenade/facid(src) //1
	new /obj/item/grenade/chem_grenade/saringas(src) //1

/obj/item/storage/belt/grenade/tactical // Traitor bundle version
	name = "tactical grenadier belt"
	storage_slots = 20 // Not as many slots as the nukie one
	max_combined_w_class = 40

/obj/item/storage/belt/grenade/tactical/populate_contents()
	for(var/I in 1 to 5)
		new /obj/item/grenade/smokebomb(src)
		new /obj/item/grenade/gluon(src)
		new /obj/item/grenade/plastic/c4(src) // Five of each
	for(var/I in 1 to 2)
		new /obj/item/grenade/frag(src)
		new /obj/item/grenade/empgrenade(src) // Two of each
	new /obj/item/grenade/syndieminibomb(src) // One minibomb

/obj/item/storage/belt/military/abductor
	name = "agent belt"
	desc = "A belt used by abductor agents."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "belt"
	item_state = "security"

/obj/item/storage/belt/military/abductor/full/populate_contents()
	new /obj/item/screwdriver/abductor(src)
	new /obj/item/wrench/abductor(src)
	new /obj/item/weldingtool/abductor(src)
	new /obj/item/crowbar/abductor(src)
	new /obj/item/wirecutters/abductor(src)
	new /obj/item/multitool/abductor(src)
	new /obj/item/stack/cable_coil(src, 30, COLOR_WHITE)

/obj/item/storage/belt/military/assault
	name = "assault belt"
	desc = "A tactical assault belt."
	icon_state = "assaultbelt"
	item_state = "assault"
	storage_slots = 6

/obj/item/storage/belt/military/assault/marines/full/populate_contents()
	new /obj/item/ammo_box/magazine/m12g(src)
	new /obj/item/ammo_box/magazine/m12g(src)
	new /obj/item/ammo_box/magazine/m12g(src)
	new /obj/item/ammo_box/magazine/m12g(src)
	new /obj/item/ammo_box/magazine/m45(src)
	new /obj/item/ammo_box/magazine/m45(src)
	update_icon()

/obj/item/storage/belt/military/assault/marines/elite/full/populate_contents()
	new /obj/item/ammo_box/magazine/m556/arg(src)
	new /obj/item/ammo_box/magazine/m556/arg(src)
	new /obj/item/ammo_box/magazine/m556/arg(src)
	new /obj/item/ammo_box/magazine/m45(src)
	new /obj/item/ammo_box/magazine/m45(src)
	update_icon()

/obj/item/storage/belt/military/assault/soviet/full/populate_contents()
	new /obj/item/ammo_box/magazine/ak814(src)
	new /obj/item/ammo_box/magazine/ak814(src)
	new /obj/item/ammo_box/magazine/ak814(src)
	new /obj/item/grenade/plastic/c4/thermite(src)
	new /obj/item/grenade/plastic/c4/thermite(src)
	new /obj/item/grenade/plastic/c4/thermite(src)
	update_icon()

/obj/item/storage/belt/janitor
	name = "janibelt"
	desc = "A belt used to hold most janitorial supplies."
	icon_state = "janibelt"
	item_state = "janibelt"
	storage_slots = 6
	max_w_class = WEIGHT_CLASS_BULKY // Set to this so the  light replacer can fit.
	use_item_overlays = TRUE
	can_hold = list(
		/obj/item/grenade/chem_grenade/cleaner,
		/obj/item/lightreplacer,
		/obj/item/flashlight,
		/obj/item/reagent_containers/spray,
		/obj/item/soap,
		/obj/item/holosign_creator/janitor,
		/obj/item/melee/flyswatter,
		/obj/item/storage/bag/trash,
		/obj/item/push_broom,
		/obj/item/door_remote/janikeyring
		)

/obj/item/storage/belt/janitor/full/populate_contents()
	new /obj/item/holosign_creator/janitor(src)
	new /obj/item/reagent_containers/spray/cleaner/advanced(src)
	new /obj/item/reagent_containers/spray/cleaner/advanced(src)
	new /obj/item/soap/deluxe(src)
	new /obj/item/grenade/chem_grenade/cleaner(src)
	new /obj/item/grenade/chem_grenade/cleaner(src)
	update_icon()

/obj/item/storage/belt/lazarus
	name = "trainer's belt"
	desc = "For the mining master, holds your lazarus capsules."
	icon_state = "lazarusbelt"
	item_state = "lazbelt"
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_TINY
	max_combined_w_class = 6
	storage_slots = 6
	can_hold = list(/obj/item/mobcapsule)
	large = TRUE

/obj/item/storage/belt/lazarus/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/storage/belt/lazarus/update_icon_state()
	icon_state = "[initial(icon_state)]_[length(contents)]"

/obj/item/storage/belt/lazarus/attackby(obj/item/I, mob/user)
	var/amount = length(contents)
	. = ..()
	if(amount != length(contents))
		update_icon()

/obj/item/storage/belt/lazarus/remove_from_storage(obj/item/I, atom/new_location)
	..()
	update_icon()


/obj/item/storage/belt/bandolier
	name = "bandolier"
	desc = "A bandolier for holding shotgun ammunition."
	icon_state = "bandolier"
	item_state = "bandolier"
	storage_slots = 16
	max_combined_w_class = 16
	can_hold = list(/obj/item/ammo_casing/shotgun)
	display_contents_with_number = TRUE

/obj/item/storage/belt/bandolier/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/storage/belt/bandolier/full/populate_contents()
	for(var/I in 1 to 8)
		new /obj/item/ammo_casing/shotgun/rubbershot(src)

/obj/item/storage/belt/bandolier/update_icon_state()
	icon_state = "[initial(icon_state)]_[min(length(contents), 8)]"

/obj/item/storage/belt/bandolier/attackby(obj/item/I, mob/user)
	var/amount = length(contents)
	..()
	if(amount != length(contents))
		update_icon()

/obj/item/storage/belt/holster
	name = "shoulder holster"
	desc = "A holster to conceal a carried handgun. WARNING: Badasses only."
	icon_state = "holster"
	item_state = "holster"
	storage_slots = 1
	max_w_class = WEIGHT_CLASS_NORMAL
	can_hold = list(
		/obj/item/gun/projectile/automatic/pistol,
		/obj/item/gun/energy/detective
		)

/obj/item/storage/belt/wands
	name = "wand belt"
	desc = "A belt designed to hold various rods of power. A veritable fanny pack of exotic magic."
	icon_state = "soulstonebelt"
	item_state = "soulstonebelt"
	storage_slots = 6
	use_item_overlays = TRUE
	can_hold = list(
		/obj/item/gun/magic/wand
		)

/obj/item/storage/belt/wands/full/populate_contents()
	new /obj/item/gun/magic/wand/death(src)
	new /obj/item/gun/magic/wand/resurrection(src)
	new /obj/item/gun/magic/wand/polymorph(src)
	new /obj/item/gun/magic/wand/teleport(src)
	new /obj/item/gun/magic/wand/door(src)
	new /obj/item/gun/magic/wand/fireball(src)

	for(var/obj/item/gun/magic/wand/W in contents) //All wands in this pack come in the best possible condition
		W.max_charges = initial(W.max_charges)
		W.charges = W.max_charges
	update_icon()

/obj/item/storage/belt/fannypack
	name = "fannypack"
	desc = "A dorky fannypack for keeping small items in."
	icon_state = "fannypack_leather"
	item_state = "fannypack_leather"
	storage_slots = 3
	max_w_class = WEIGHT_CLASS_SMALL

/obj/item/storage/belt/fannypack/black
	name = "black fannypack"
	icon_state = "fannypack_black"
	item_state = "fannypack_black"

/obj/item/storage/belt/fannypack/red
	name = "red fannypack"
	icon_state = "fannypack_red"
	item_state = "fannypack_red"

/obj/item/storage/belt/fannypack/purple
	name = "purple fannypack"
	icon_state = "fannypack_purple"
	item_state = "fannypack_purple"

/obj/item/storage/belt/fannypack/blue
	name = "blue fannypack"
	icon_state = "fannypack_blue"
	item_state = "fannypack_blue"

/obj/item/storage/belt/fannypack/orange
	name = "orange fannypack"
	icon_state = "fannypack_orange"
	item_state = "fannypack_orange"

/obj/item/storage/belt/fannypack/white
	name = "white fannypack"
	icon_state = "fannypack_white"
	item_state = "fannypack_white"

/obj/item/storage/belt/fannypack/green
	name = "green fannypack"
	icon_state = "fannypack_green"
	item_state = "fannypack_green"

/obj/item/storage/belt/fannypack/pink
	name = "pink fannypack"
	icon_state = "fannypack_pink"
	item_state = "fannypack_pink"

/obj/item/storage/belt/fannypack/cyan
	name = "cyan fannypack"
	icon_state = "fannypack_cyan"
	item_state = "fannypack_cyan"

/obj/item/storage/belt/fannypack/yellow
	name = "yellow fannypack"
	icon_state = "fannypack_yellow"
	item_state = "fannypack_yellow"

/obj/item/storage/belt/rapier
	name = "rapier sheath"
	desc = "Can hold rapiers."
	icon_state = "sheath"
	item_state = "sheath"
	storage_slots = 1
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_BULKY
	can_hold = list(/obj/item/melee/rapier)
	large = TRUE

/obj/item/storage/belt/rapier/populate_contents()
	new /obj/item/melee/rapier(src)
	update_icon()

/obj/item/storage/belt/rapier/attack_hand(mob/user)
	if(loc != user)
		return ..()

	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.incapacitated())
		return

	if(length(contents))
		var/obj/item/I = contents[1]
		H.visible_message("<span class='notice'>[H] takes [I] out of [src].</span>", "<span class='notice'>You take [I] out of [src].</span>")
		H.put_in_hands(I)
		update_icon()
	else
		to_chat(user, "<span class='warning'>[src] is empty!</span>")

/obj/item/storage/belt/rapier/handle_item_insertion(obj/item/W, prevent_warning)
	if(!..())
		return
	playsound(src, 'sound/weapons/blade_sheath.ogg', 20)

/obj/item/storage/belt/rapier/remove_from_storage(obj/item/W, atom/new_location)
	if(!..())
		return
	playsound(src, 'sound/weapons/blade_unsheath.ogg', 20)

/obj/item/storage/belt/rapier/update_icon_state()
	if(length(contents))
		icon_state = "[icon_state]-rapier"
		item_state = "[item_state]-rapier"
	else
		icon_state = initial(icon_state)
		item_state = initial(item_state)
	if(isliving(loc))
		var/mob/living/L = loc
		L.update_inv_belt()

// -------------------------------------
//     Bluespace Belt
// -------------------------------------

/obj/item/storage/belt/bluespace
	name = "Belt of Holding"
	desc = "The greatest in pants-supporting technology."
	icon_state = "holdingbelt"
	item_state = "holdingbelt"
	storage_slots = 14
	w_class = WEIGHT_CLASS_BULKY
	max_w_class = WEIGHT_CLASS_SMALL
	max_combined_w_class = 21 // = 14 * 1.5, not 14 * 2.  This is deliberate
	origin_tech = "bluespace=5;materials=4;engineering=4;plasmatech=5"
	can_hold = list()
	large = TRUE
	w_class_override = list(
		/obj/item/crowbar,
		/obj/item/screwdriver,
		/obj/item/weldingtool,
		/obj/item/wirecutters,
		/obj/item/wrench,
		/obj/item/multitool
		)

/obj/item/storage/belt/bluespace/owlman
	name = "Owlman's utility belt"
	desc = "Sometimes people choose justice.  Sometimes, justice chooses you..."
	icon_state = "securitybelt"
	item_state = "security"
	storage_slots = 6
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 18
	origin_tech = "bluespace=5;materials=4;engineering=4;plasmatech=5"
	allow_quick_empty = TRUE
	can_hold = list(
		/obj/item/grenade/smokebomb,
		/obj/item/restraints/legcuffs/bola
		)

	flags = NODROP
	var/smokecount = 0
	var/bolacount = 0
	var/cooldown = 0

/obj/item/storage/belt/bluespace/owlman/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	cooldown = world.time

/obj/item/storage/belt/bluespace/owlman/populate_contents()
	for(var/I in 1 to 4)
		new /obj/item/grenade/smokebomb(src)
	new /obj/item/restraints/legcuffs/bola(src)
	new /obj/item/restraints/legcuffs/bola(src)

/obj/item/storage/belt/bluespace/owlman/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/storage/belt/bluespace/owlman/process()
	if(cooldown < world.time - 600)
		smokecount = 0
		var/obj/item/grenade/smokebomb/S
		for(S in src)
			smokecount++
		bolacount = 0
		var/obj/item/restraints/legcuffs/bola/B
		for(B in src)
			bolacount++
		if(smokecount < 4)
			while(smokecount < 4)
				new /obj/item/grenade/smokebomb(src)
				smokecount++
		if(bolacount < 2)
			while(bolacount < 2)
				new /obj/item/restraints/legcuffs/bola(src)
				bolacount++
		cooldown = world.time
		update_icon()
		if(ishuman(loc))
			var/mob/living/carbon/human/H = loc
			if(H.belt && H.belt == src)
				if(H.s_active && H.s_active == src)
					H.s_active.show_to(H)

/obj/item/storage/belt/bluespace/attack(mob/M, mob/user, def_zone)
	return

/obj/item/storage/belt/bluespace/admin
	name = "Admin's Tool-belt"
	desc = "Holds everything for those that run everything."
	icon_state = "soulstonebelt"
	item_state = "soulstonebelt"
	w_class = 10 // permit holding other storage items
	storage_slots = 28
	max_w_class = 10
	max_combined_w_class = 280
	can_hold = list()

/obj/item/storage/belt/bluespace/admin/populate_contents()
	new /obj/item/crowbar(src)
	new /obj/item/screwdriver(src)
	new /obj/item/weldingtool/hugetank(src)
	new /obj/item/wirecutters(src)
	new /obj/item/wrench(src)
	new /obj/item/multitool(src)
	new /obj/item/stack/cable_coil(src)

	new /obj/item/restraints/handcuffs(src)
	new /obj/item/dnainjector/firemut(src)
	new /obj/item/dnainjector/telemut(src)
	new /obj/item/dnainjector/hulkmut(src)
//		new /obj/item/spellbook(src) // for smoke effects, door openings, etc
//		new /obj/item/magic/spellbook(src)

//		new/obj/item/reagent_containers/hypospray/admin(src)

/obj/item/storage/belt/bluespace/sandbox
	name = "Sandbox Mode Toolbelt"
	desc = "Holds whatever, you can spawn your own damn stuff."
	w_class = 10 // permit holding other storage items
	storage_slots = 28
	max_w_class = 10
	max_combined_w_class = 280
	can_hold = list()

/obj/item/storage/belt/bluespace/sandbox/populate_contents()
	new /obj/item/crowbar(src)
	new /obj/item/screwdriver(src)
	new /obj/item/weldingtool/hugetank(src)
	new /obj/item/wirecutters(src)
	new /obj/item/wrench(src)
	new /obj/item/multitool(src)
	new /obj/item/stack/cable_coil(src)

	new /obj/item/analyzer(src)
	new /obj/item/healthanalyzer(src)

/obj/item/storage/belt/mining
	name = "explorer's webbing"
	desc = "A versatile chest rig, cherished by miners and hunters alike."
	icon_state = "explorer1"
	item_state = "explorer1"
	storage_slots = 6
	max_w_class = WEIGHT_CLASS_BULKY
	max_combined_w_class = 20
	use_item_overlays = FALSE
	can_hold = list(
		/obj/item/crowbar,
		/obj/item/screwdriver,
		/obj/item/weldingtool,
		/obj/item/wirecutters,
		/obj/item/wrench,
		/obj/item/multitool,
		/obj/item/flashlight,
		/obj/item/stack/cable_coil,
		/obj/item/analyzer,
		/obj/item/extinguisher/mini,
		/obj/item/radio,
		/obj/item/clothing/gloves,
		/obj/item/resonator,
		/obj/item/mining_scanner,
		/obj/item/pickaxe,
		/obj/item/shovel,
		/obj/item/stack/sheet/animalhide,
		/obj/item/stack/sheet/sinew,
		/obj/item/stack/sheet/bone,
		/obj/item/lighter,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/reagent_containers/food/drinks/bottle,
		/obj/item/stack/medical,
		/obj/item/kitchen/knife,
		/obj/item/reagent_containers/hypospray,
		/obj/item/gps,
		/obj/item/storage/bag/ore,
		/obj/item/survivalcapsule,
		/obj/item/t_scanner/adv_mining_scanner,
		/obj/item/reagent_containers/food/pill,
		/obj/item/storage/pill_bottle,
		/obj/item/stack/ore,
		/obj/item/reagent_containers/food/drinks,
		/obj/item/organ/internal/regenerative_core,
		/obj/item/wormhole_jaunter,
		/obj/item/storage/bag/plants,
		/obj/item/stack/marker_beacon)

/obj/item/storage/belt/mining/vendor/Initialize(mapload)
	. = ..()
	new /obj/item/survivalcapsule(src)

/obj/item/storage/belt/mining/alt
	icon_state = "explorer2"
	item_state = "explorer2"

/obj/item/storage/belt/mining/primitive
	name = "hunter's belt"
	desc = "A versatile belt, woven from sinew."
	icon_state = "ebelt"
	item_state = "ebelt"
	storage_slots = 5

/obj/item/storage/belt/chef
	name = "culinary tool apron"
	desc = "An apron with various pockets for holding all your cooking tools and equipment."
	icon_state = "chefbelt"
	item_state = "chefbelt"
	storage_slots = 10
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 25
	can_hold = list(
		/obj/item/kitchen/utensil,
		/obj/item/kitchen/knife,
		/obj/item/kitchen/rollingpin,
		/obj/item/kitchen/mould,
		/obj/item/kitchen/sushimat,
		/obj/item/kitchen/cutter,
		/obj/item/assembly/mousetrap,
		/obj/item/reagent_containers/spray/pestspray,
		/obj/item/reagent_containers/food/drinks/flask,
		/obj/item/reagent_containers/food/drinks/drinkingglass,
		/obj/item/reagent_containers/food/drinks/bottle,
		/obj/item/reagent_containers/food/drinks/cans,
		/obj/item/reagent_containers/food/drinks/shaker,
		/obj/item/reagent_containers/food/snacks,
		/obj/item/reagent_containers/food/condiment,
		/obj/item/reagent_containers/glass/beaker)
