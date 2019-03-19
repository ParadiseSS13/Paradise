/obj/item/storage/belt
	name = "belt"
	desc = "Can hold various things."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "utilitybelt"
	item_state = "utility"
	slot_flags = SLOT_BELT
	attack_verb = list("whipped", "lashed", "disciplined")
	var/use_item_overlays = 0 // Do we have overlays for items held inside the belt?


/obj/item/storage/belt/update_icon()
	if(use_item_overlays)
		overlays.Cut()
		for(var/obj/item/I in contents)
			overlays += "[I.name]"

	..()

/obj/item/storage/belt/proc/can_use()
	return is_equipped()


/obj/item/storage/belt/MouseDrop(obj/over_object as obj, src_location, over_location)
	var/mob/M = usr
	if(!istype(over_object, /obj/screen))
		return ..()
	playsound(src.loc, "rustle", 50, 1, -5)
	if(!M.restrained() && !M.stat && can_use())
		switch(over_object.name)
			if("r_hand")
				M.unEquip(src)
				M.put_in_r_hand(src)
			if("l_hand")
				M.unEquip(src)
				M.put_in_l_hand(src)
		src.add_fingerprint(usr)
		return

/obj/item/storage/belt/deserialize(list/data)
	..()
	update_icon()

/obj/item/storage/belt/utility
	name = "tool-belt" //Carn: utility belt is nicer, but it bamboozles the text parsing.
	desc = "Can hold various tools."
	icon_state = "utilitybelt"
	item_state = "utility"
	use_item_overlays = 1
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
		/obj/item/extinguisher/mini,
		/obj/item/holosign_creator)

/obj/item/storage/belt/utility/full/New()
	..()
	new /obj/item/screwdriver(src)
	new /obj/item/wrench(src)
	new /obj/item/weldingtool(src)
	new /obj/item/crowbar(src)
	new /obj/item/wirecutters(src)
	new /obj/item/stack/cable_coil(src, 30, pick(COLOR_RED, COLOR_YELLOW, COLOR_ORANGE))
	update_icon()

/obj/item/storage/belt/utility/full/multitool/New()
	..()
	new /obj/item/multitool(src)
	update_icon()

/obj/item/storage/belt/utility/atmostech/New()
	..()
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
	desc = "Holds tools, looks snazzy"
	icon_state = "utilitybelt_ce"
	item_state = "utility_ce"

/obj/item/storage/belt/utility/chief/full/New()
	..()
	new /obj/item/screwdriver/power(src)
	new /obj/item/crowbar/power(src)
	new /obj/item/weldingtool/experimental(src)//This can be changed if this is too much
	new /obj/item/multitool(src)
	new /obj/item/stack/cable_coil(src, 30, pick(COLOR_RED, COLOR_YELLOW, COLOR_ORANGE))
	new /obj/item/extinguisher/mini(src)
	new /obj/item/analyzer(src)
	update_icon()
	//much roomier now that we've managed to remove two tools

/obj/item/storage/belt/medical
	use_to_pickup = 1 //Allow medical belt to pick up medicine
	name = "medical belt"
	desc = "Can hold various medical equipment."
	icon_state = "medicalbelt"
	item_state = "medical"
	use_item_overlays = 1
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
		/obj/item/rad_laser,
		/obj/item/sensor_device,
		/obj/item/wrench/medical,
	)

/obj/item/storage/belt/medical/surgery
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 17
	use_to_pickup = 1
	name = "surgical belt"
	desc = "Can hold various surgical tools."
	storage_slots = 9
	use_item_overlays = 1
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

/obj/item/storage/belt/medical/surgery/loaded

/obj/item/storage/belt/medical/surgery/loaded/New()
	..()
	new /obj/item/scalpel(src)
	new /obj/item/hemostat(src)
	new /obj/item/retractor(src)
	new /obj/item/circular_saw(src)
	new /obj/item/bonegel(src)
	new /obj/item/bonesetter(src)
	new /obj/item/FixOVein(src)
	new /obj/item/surgicaldrill(src)
	new /obj/item/cautery(src)

/obj/item/storage/belt/medical/response_team

/obj/item/storage/belt/medical/response_team/New()
	..()
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
	use_item_overlays = 1
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
	)


/obj/item/storage/belt/security
	name = "security belt"
	desc = "Can hold security gear like handcuffs and flashes."
	icon_state = "securitybelt"
	item_state = "security"//Could likely use a better one.
	storage_slots = 5
	max_w_class = WEIGHT_CLASS_NORMAL
	use_item_overlays = 1
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
		/obj/item/restraints/legcuffs/bola)

/obj/item/storage/belt/security/sec/New()
	..()
	new /obj/item/flashlight/seclite(src)
	update_icon()

/obj/item/storage/belt/security/response_team/New()
	..()
	new /obj/item/reagent_containers/spray/pepper(src)
	new /obj/item/melee/baton/loaded(src)
	new /obj/item/flash(src)
	new /obj/item/melee/classic_baton/telescopic(src)
	new /obj/item/grenade/flashbang(src)
	update_icon()

/obj/item/storage/belt/security/response_team_gamma/New()
	..()
	new /obj/item/melee/baton/loaded(src)
	new /obj/item/reagent_containers/spray/pepper(src)
	new /obj/item/flash(src)
	new /obj/item/grenade/flashbang(src)
	new /obj/item/grenade/flashbang(src)
	update_icon()

/obj/item/storage/belt/soulstone
	name = "soul stone belt"
	desc = "Designed for ease of access to the shards during a fight, as to not let a single enemy spirit slip away"
	icon_state = "soulstonebelt"
	item_state = "soulstonebelt"
	storage_slots = 6
	use_item_overlays = 1
	can_hold = list(
		"/obj/item/soulstone"
		)

/obj/item/storage/belt/soulstone/full/New()
	..()
	new /obj/item/soulstone(src)
	new /obj/item/soulstone(src)
	new /obj/item/soulstone(src)
	new /obj/item/soulstone(src)
	new /obj/item/soulstone(src)
	new /obj/item/soulstone(src)
	update_icon()


/obj/item/storage/belt/champion
	name = "championship belt"
	desc = "Proves to the world that you are the strongest!"
	icon_state = "championbelt"
	item_state = "champion"
	materials = list(MAT_GOLD=400)
	storage_slots = 1
	can_hold = list(
		"/obj/item/clothing/mask/luchador"
		)

/obj/item/storage/belt/military
	name = "military belt"
	desc = "A syndicate belt designed to be used by boarding parties.  Its style is modelled after the hardsuits they wear."
	icon_state = "militarybelt"
	item_state = "military"
	max_w_class = WEIGHT_CLASS_SMALL

/obj/item/storage/belt/military/sst
	icon_state = "assaultbelt"
	item_state = "assault"

/obj/item/storage/belt/military/traitor
	name = "tool-belt"
	desc = "Can hold various tools. This model seems to have additional compartments."
	icon_state = "utilitybelt"
	item_state = "utility"
	use_item_overlays = 1 // So it will still show tools in it in case sec get lazy and just glance at it.

/obj/item/storage/belt/grenade
	name = "grenadier belt"
	desc = "A belt for holding grenades."
	icon_state = "assaultbelt"
	item_state = "assault"
	storage_slots = 30
	max_combined_w_class = 60
	display_contents_with_number = 1
	can_hold = list(
		/obj/item/grenade,
		/obj/item/lighter,
		/obj/item/reagent_containers/food/drinks/bottle/molotov
		)

/obj/item/storage/belt/grenade/full/New()
	..()
	new /obj/item/grenade/smokebomb(src) //4
	new /obj/item/grenade/smokebomb(src)
	new /obj/item/grenade/smokebomb(src)
	new /obj/item/grenade/smokebomb(src)
	new /obj/item/grenade/empgrenade(src) //2
	new /obj/item/grenade/empgrenade(src)
	new /obj/item/grenade/gluon(src) //4
	new /obj/item/grenade/gluon(src)
	new /obj/item/grenade/gluon(src)
	new /obj/item/grenade/gluon(src)
	new /obj/item/grenade/chem_grenade/facid(src) //1
	new /obj/item/grenade/gas/plasma(src) //2
	new /obj/item/grenade/gas/plasma(src)
	new /obj/item/grenade/frag(src) //10
	new /obj/item/grenade/frag(src)
	new /obj/item/grenade/frag(src)
	new /obj/item/grenade/frag(src)
	new /obj/item/grenade/frag(src)
	new /obj/item/grenade/frag(src)
	new /obj/item/grenade/frag(src)
	new /obj/item/grenade/frag(src)
	new /obj/item/grenade/frag(src)
	new /obj/item/grenade/frag(src)
	new /obj/item/grenade/syndieminibomb(src) //2
	new /obj/item/grenade/syndieminibomb(src)

/obj/item/storage/belt/military/abductor
	name = "agent belt"
	desc = "A belt used by abductor agents."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "belt"
	item_state = "security"

/obj/item/storage/belt/military/abductor/full/New()
	..()
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

/obj/item/storage/belt/janitor
	name = "janibelt"
	desc = "A belt used to hold most janitorial supplies."
	icon_state = "janibelt"
	item_state = "janibelt"
	storage_slots = 6
	max_w_class = WEIGHT_CLASS_BULKY // Set to this so the  light replacer can fit.
	use_item_overlays = 1
	can_hold = list(
		/obj/item/grenade/chem_grenade/cleaner,
		/obj/item/lightreplacer,
		/obj/item/flashlight,
		/obj/item/reagent_containers/spray,
		/obj/item/soap,
		/obj/item/holosign_creator
		)

/obj/item/storage/belt/janitor/full/New()
	..()
	new /obj/item/lightreplacer(src)
	new /obj/item/holosign_creator(src)
	new /obj/item/reagent_containers/spray(src)
	new /obj/item/soap(src)
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

/obj/item/storage/belt/lazarus/New()
	..()
	update_icon()


/obj/item/storage/belt/lazarus/update_icon()
	..()
	icon_state = "[initial(icon_state)]_[contents.len]"

/obj/item/storage/belt/lazarus/attackby(obj/item/W, mob/user)
	var/amount = contents.len
	. = ..()
	if(amount != contents.len)
		update_icon()

/obj/item/storage/belt/lazarus/remove_from_storage(obj/item/W as obj, atom/new_location)
	..()
	update_icon()


/obj/item/storage/belt/bandolier
	name = "bandolier"
	desc = "A bandolier for holding shotgun ammunition."
	icon_state = "bandolier"
	item_state = "bandolier"
	storage_slots = 8
	can_hold = list(
		/obj/item/ammo_casing/shotgun
		)

/obj/item/storage/belt/bandolier/New()
	..()
	update_icon()

/obj/item/storage/belt/bandolier/full/New()
	..()
	new /obj/item/ammo_casing/shotgun/beanbag(src)
	new /obj/item/ammo_casing/shotgun/beanbag(src)
	new /obj/item/ammo_casing/shotgun/beanbag(src)
	new /obj/item/ammo_casing/shotgun/beanbag(src)
	new /obj/item/ammo_casing/shotgun/beanbag(src)
	new /obj/item/ammo_casing/shotgun/beanbag(src)
	new /obj/item/ammo_casing/shotgun/beanbag(src)
	new /obj/item/ammo_casing/shotgun/beanbag(src)
	update_icon()

/obj/item/storage/belt/bandolier/update_icon()
	..()
	icon_state = "[initial(icon_state)]_[contents.len]"

/obj/item/storage/belt/bandolier/attackby(obj/item/W, mob/user)
	var/amount = contents.len
	. = ..()
	if(amount != contents.len)
		update_icon()

/obj/item/storage/belt/bandolier/remove_from_storage(obj/item/W as obj, atom/new_location)
	..()
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
		/obj/item/gun/projectile/revolver/detective
		)

/obj/item/storage/belt/wands
	name = "wand belt"
	desc = "A belt designed to hold various rods of power. A veritable fanny pack of exotic magic."
	icon_state = "soulstonebelt"
	item_state = "soulstonebelt"
	storage_slots = 6
	use_item_overlays = 1
	can_hold = list(
		/obj/item/gun/magic/wand
		)

/obj/item/storage/belt/wands/full/New()
	..()
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

/obj/item/storage/belt/rapier/update_icon()
	icon_state = "[initial(icon_state)]"
	item_state = "[initial(item_state)]"
	if(contents.len)
		icon_state = "[initial(icon_state)]-rapier"
		item_state = "[initial(item_state)]-rapier"
	if(isliving(loc))
		var/mob/living/L = loc
		L.update_inv_belt()
	..()

/obj/item/storage/belt/rapier/New()
	..()
	new /obj/item/melee/rapier(src)
	update_icon()

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

/obj/item/storage/belt/bluespace/owlman
	name = "Owlman's utility belt"
	desc = "Sometimes people choose justice.  Sometimes, justice chooses you..."
	icon_state = "securitybelt"
	item_state = "security"
	storage_slots = 6
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 18
	origin_tech = "bluespace=5;materials=4;engineering=4;plasmatech=5"
	allow_quick_empty = 1
	can_hold = list(
		/obj/item/grenade/smokebomb,
		/obj/item/restraints/legcuffs/bola
		)

	flags = NODROP
	var/smokecount = 0
	var/bolacount = 0
	var/cooldown = 0



/obj/item/storage/belt/bluespace/owlman/New()
	..()
	new /obj/item/grenade/smokebomb(src)
	new /obj/item/grenade/smokebomb(src)
	new /obj/item/grenade/smokebomb(src)
	new /obj/item/grenade/smokebomb(src)
	new /obj/item/restraints/legcuffs/bola(src)
	new /obj/item/restraints/legcuffs/bola(src)
	processing_objects.Add(src)
	cooldown = world.time

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
		orient2hud()
		if(ishuman(loc))
			var/mob/living/carbon/human/H = loc
			if(H.belt && H.belt == src)
				if(H.s_active && H.s_active == src)
					H.s_active.show_to(H)

/obj/item/storage/belt/bluespace/attack(mob/M as mob, mob/user as mob, def_zone)
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

/obj/item/storage/belt/bluespace/admin/New()
	..()
	new /obj/item/crowbar(src)
	new /obj/item/screwdriver(src)
	new /obj/item/weldingtool/hugetank(src)
	new /obj/item/wirecutters(src)
	new /obj/item/wrench(src)
	new /obj/item/multitool(src)
	new /obj/item/stack/cable_coil(src)

	new /obj/item/restraints/handcuffs(src)
	new /obj/item/dnainjector/xraymut(src)
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

/obj/item/storage/belt/bluespace/sandbox/New()
	..()
	new /obj/item/crowbar(src)
	new /obj/item/screwdriver(src)
	new /obj/item/weldingtool/hugetank(src)
	new /obj/item/wirecutters(src)
	new /obj/item/wrench(src)
	new /obj/item/multitool(src)
	new /obj/item/stack/cable_coil(src)

	new /obj/item/analyzer(src)
	new /obj/item/healthanalyzer(src)
