/obj/item/storage/toolbox
	name = "toolbox"
	desc = "Danger. Very robust."
	icon = 'icons/obj/storage.dmi'
	icon_state = "red"
	item_state = "toolbox_red"
	flags = CONDUCT
	force = 10.0
	throwforce = 10.0
	throw_speed = 2
	throw_range = 7
	w_class = WEIGHT_CLASS_BULKY
	materials = list(MAT_METAL = 500)
	origin_tech = "combat=1;engineering=1"
	attack_verb = list("robusted")
	hitsound = 'sound/weapons/smash.ogg'
	var/blurry_chance = 5

/obj/item/storage/toolbox/attack(mob/living/carbon/human/H, mob/living/carbon/user)
	. = ..()

	if(!istype(H))
		return

	if(user.zone_selected != "eyes" && user.zone_selected != "head")
		return

	if(!prob(blurry_chance))
		return

	if(force && (HAS_TRAIT(user, TRAIT_PACIFISM) || GLOB.pacifism_after_gt))
		to_chat(user, SPAN_WARNING("You don't want to harm other living beings!"))
		return

	H.AdjustEyeBlurry(8 SECONDS)
	to_chat(H, SPAN_DANGER("You feel a buzz in your head and your vision gets blurry."))

/obj/item/storage/toolbox/emergency
	name = "emergency toolbox"
	icon_state = "red"
	item_state = "toolbox_red"

/obj/item/storage/toolbox/emergency/populate_contents()
	new /obj/item/crowbar/red(src)
	new /obj/item/weldingtool/mini(src)
	new /obj/item/extinguisher/mini(src)
	if(prob(50))
		new /obj/item/flashlight(src)
	else
		new /obj/item/flashlight/flare(src)
	new /obj/item/radio(src)

/obj/item/storage/toolbox/emergency/old
	name = "rusty red toolbox"
	icon_state = "toolbox_red_old"

/obj/item/storage/toolbox/mechanical
	name = "mechanical toolbox"
	icon_state = "blue"
	item_state = "toolbox_blue"

/obj/item/storage/toolbox/mechanical/populate_contents()
	new /obj/item/screwdriver(src)
	new /obj/item/wrench(src)
	new /obj/item/weldingtool(src)
	new /obj/item/crowbar(src)
	new /obj/item/analyzer(src)
	new /obj/item/wirecutters(src)

/obj/item/storage/toolbox/mechanical/greytide
	flags = NODROP

/obj/item/storage/toolbox/mechanical/old
	name = "rusty blue toolbox"
	icon_state = "toolbox_blue_old"

/obj/item/storage/toolbox/electrical
	name = "electrical toolbox"
	icon_state = "yellow"
	item_state = "toolbox_yellow"

/obj/item/storage/toolbox/electrical/populate_contents()
	var/pickedcolor = pick(COLOR_RED, COLOR_YELLOW, COLOR_GREEN, COLOR_BLUE, COLOR_PINK, COLOR_ORANGE, COLOR_CYAN, COLOR_WHITE)
	new /obj/item/screwdriver(src)
	new /obj/item/wirecutters(src)
	new /obj/item/t_scanner(src)
	new /obj/item/crowbar(src)
	new /obj/item/stack/cable_coil(src, MAXCOIL, FALSE, pickedcolor)
	new /obj/item/stack/cable_coil(src, MAXCOIL, FALSE, pickedcolor)
	if(prob(5))
		new /obj/item/clothing/gloves/color/yellow(src)
	else
		new /obj/item/stack/cable_coil(src, MAXCOIL, FALSE, pickedcolor)

/obj/item/storage/toolbox/syndicate
	name = "suspicious looking toolbox"
	icon_state = "syndicate"
	item_state = "toolbox_syndi"
	origin_tech = "combat=2;syndicate=1;engineering=2"
	silent = 1
	force = 15.0
	throwforce = 18.0
	blurry_chance = 8

/obj/item/storage/toolbox/syndicate/populate_contents()
	new /obj/item/screwdriver(src, "red")
	new /obj/item/wrench(src)
	new /obj/item/weldingtool/largetank(src)
	new /obj/item/crowbar/red(src)
	new /obj/item/wirecutters(src, "red")
	new /obj/item/multitool(src)
	new /obj/item/clothing/gloves/combat(src)

/obj/item/storage/toolbox/syndisuper
	name = "exteremely suspicious looking toolbox"
	desc = "Danger. Robust - his second name."
	icon_state = "syndicate"
	item_state = "toolbox_syndi"
	origin_tech = "combat=5;syndicate=1;engineering=5"
	silent = 1
	force = 18.0 //robuster because of rarity
	throwforce = 20.0
	blurry_chance = 12

/obj/item/storage/toolbox/syndisuper/populate_contents()
	new /obj/item/screwdriver/power(src)
	new /obj/item/weldingtool/experimental(src)
	new /obj/item/crowbar/power(src)
	new /obj/item/multitool/cyborg(src)
	new /obj/item/stack/cable_coil(src, MAXCOIL)
	new /obj/item/clothing/gloves/combat(src)
	new /obj/item/clothing/glasses/sunglasses(src)

/obj/item/storage/toolbox/fakesyndi
	name = "suspicous looking toolbox"
	icon_state = "syndicate"
	item_state = "toolbox_syndi"
	desc = "Danger. Very Robust. The paint is still wet."

/obj/item/storage/toolbox/drone
	name = "mechanical toolbox"
	icon_state = "blue"
	item_state = "toolbox_blue"

/obj/item/storage/toolbox/drone/populate_contents()
	var/pickedcolor = pick(pick(COLOR_RED, COLOR_YELLOW, COLOR_GREEN, COLOR_BLUE, COLOR_PINK, COLOR_ORANGE, COLOR_CYAN, COLOR_WHITE))
	new /obj/item/screwdriver(src)
	new /obj/item/wrench(src)
	new /obj/item/weldingtool(src)
	new /obj/item/crowbar(src)
	new /obj/item/stack/cable_coil(src, MAXCOIL, TRUE, pickedcolor)
	new /obj/item/wirecutters(src)
	new /obj/item/multitool(src)

/obj/item/storage/toolbox/brass
	name = "brass box"
	desc = "A huge brass box with several indentations in its surface."
	icon_state = "brassbox"
	item_state = null
	resistance_flags = FIRE_PROOF | ACID_PROOF
	w_class = WEIGHT_CLASS_HUGE
	max_w_class = WEIGHT_CLASS_NORMAL
	max_combined_w_class = 28
	storage_slots = 28
	attack_verb = list("robusted", "crushed", "smashed")

/obj/item/storage/toolbox/brass/prefilled/populate_contents()
	new /obj/item/screwdriver/brass(src)
	new /obj/item/wirecutters/brass(src)
	new /obj/item/wrench/brass(src)
	new /obj/item/crowbar/brass(src)
	new /obj/item/weldingtool/experimental/brass(src)

// На ониксе это было в аптечках, но это буквально TOOLBOX - коробка для инструментов
/obj/item/storage/toolbox/surgery
	name = "surgery kit"
	desc = "Contains tools for surgery. Has precise foam fitting for safe transport."
	icon_state = "surgerykit"
	item_state = "firstaid-surgery"
	origin_tech = "combat=1;biotech=1"
	max_w_class = WEIGHT_CLASS_BULKY
	max_combined_w_class = 21
	storage_slots = 14
	can_hold = list(
		/obj/item/stack/medical/bruise_pack,
		/obj/item/bonesetter,
		/obj/item/bonegel,
		/obj/item/scalpel,
		/obj/item/hemostat,
		/obj/item/cautery,
		/obj/item/retractor,
		/obj/item/FixOVein,
		/obj/item/surgicaldrill,
		/obj/item/circular_saw)

/obj/item/storage/toolbox/surgery/populate_contents()
	new /obj/item/stack/medical/bruise_pack/advanced(src)
	new /obj/item/bonesetter(src)
	new /obj/item/bonegel(src)
	new /obj/item/scalpel(src)
	new /obj/item/hemostat(src)
	new /obj/item/cautery(src)
	new /obj/item/retractor(src)
	new /obj/item/FixOVein(src)
	new /obj/item/surgicaldrill(src)
	new /obj/item/circular_saw(src)

/obj/item/storage/toolbox/surgery/empty/populate_contents()
	return

