#define GIBTONITE_QUALITY_LOW 1
#define GIBTONITE_QUALITY_MEDIUM 2
#define GIBTONITE_QUALITY_HIGH 3
#define PROBABILITY_REFINE_BY_FIRE 50
#define ORESTACK_OVERLAYS_MAX 10
/**********************Mineral ores**************************/

/obj/item/stack/ore
	name = "rock"
	icon = 'icons/obj/mining.dmi'
	icon_state = "ore"
	max_amount = 50
	singular_name = "ore chunk"
	var/points = 0 //How many points this ore gets you from the ore redemption machine
	var/refined_type = null //What this ore defaults to being refined into

/obj/item/stack/ore/New()
	..()
	pixel_x = rand(0, 16) - 8
	pixel_y = rand(0, 8) - 8
	if(is_mining_level(z))
		score_oremined++ //When ore spawns, increment score.  Only include ore spawned on mining asteroid (No Clown Planet)

/obj/item/stack/ore/attackby(obj/item/I, mob/user, params)
	..()
	if(istype(I, /obj/item/weldingtool))
		var/obj/item/weldingtool/W = I
		if(W.remove_fuel(15) && refined_type)
			new refined_type(get_turf(src.loc), amount)
			qdel(src)
		else if(W.isOn())
			to_chat(user, "<span class='info'>Not enough fuel to smelt [src].</span>")

/obj/item/stack/ore/Crossed(atom/movable/AM)
	var/obj/item/storage/bag/ore/OB
	var/turf/simulated/floor/F = get_turf(src)
	if(loc != F)
		return ..()
	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		for(var/thing in H.get_body_slots())
			if(istype(thing, /obj/item/storage/bag/ore))
				OB = thing
				break
	else if(isrobot(AM))
		var/mob/living/silicon/robot/R = AM
		for(var/thing in R.get_all_slots())
			if(istype(thing, /obj/item/storage/bag/ore))
				OB = thing
				break
	if(OB && istype(F, /turf/simulated/floor/plating/airless/asteroid))
		F.attackby(OB, AM)
	return ..()

/obj/item/stack/ore/fire_act()
	..()
	if(isnull(refined_type))
		return
	else
		var/amountrefined = round((PROBABILITY_REFINE_BY_FIRE / 100) * amount, 1)
		if(amountrefined < 1)
			qdel(src)
		else
			new refined_type(get_turf(loc), amountrefined)
			qdel(src)

/obj/item/stack/ore/uranium
	name = "uranium ore"
	icon_state = "Uranium ore"
	origin_tech = "materials=5"
	singular_name = "uranium ore chunk"
	points = 30
	refined_type = /obj/item/stack/sheet/mineral/uranium
	materials = list(MAT_URANIUM=MINERAL_MATERIAL_AMOUNT)

/obj/item/stack/ore/iron
	name = "iron ore"
	icon_state = "Iron ore"
	origin_tech = "materials=1"
	singular_name = "iron ore chunk"
	points = 1
	refined_type = /obj/item/stack/sheet/metal
	materials = list(MAT_METAL=MINERAL_MATERIAL_AMOUNT)

/obj/item/stack/ore/glass
	name = "sand pile"
	icon_state = "Glass ore"
	origin_tech = "materials=1"
	singular_name = "sand pile"
	points = 1
	refined_type = /obj/item/stack/sheet/glass
	materials = list(MAT_GLASS=MINERAL_MATERIAL_AMOUNT)

GLOBAL_LIST_INIT(sand_recipes, list(\
		new /datum/stack_recipe("sandstone", /obj/item/stack/sheet/mineral/sandstone, 1, 1, 50)\
		))

/obj/item/stack/ore/glass/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.sand_recipes
	. = ..()

/obj/item/stack/ore/glass/throw_impact(atom/hit_atom)
	if(..() || !ishuman(hit_atom))
		return
	var/mob/living/carbon/human/C = hit_atom
	if(C.head && C.head.flags_cover & HEADCOVERSEYES)
		visible_message("<span class='danger'>[C]'s headgear blocks the sand!</span>")
		return
	if(C.wear_mask && C.wear_mask.flags_cover & MASKCOVERSEYES)
		visible_message("<span class='danger'>[C]'s mask blocks the sand!</span>")
		return
	if(C.glasses && C.glasses.flags_cover & GLASSESCOVERSEYES)
		visible_message("<span class='danger'>[C]'s glasses block the sand!</span>")
		return
	C.EyeBlurry(6)
	C.adjustStaminaLoss(15)//the pain from your eyes burning does stamina damage
	C.AdjustConfused(5)
	to_chat(C, "<span class='userdanger'>[src] gets into your eyes! The pain, it burns!</span>")
	qdel(src)

/obj/item/stack/ore/glass/basalt
	name = "volcanic ash"
	icon_state = "volcanic_sand"
	icon_state = "volcanic_sand"
	singular_name = "volcanic ash pile"

/obj/item/stack/ore/plasma
	name = "plasma ore"
	icon_state = "Plasma ore"
	origin_tech = "plasmatech=2;materials=2"
	singular_name = "plasma ore chunk"
	points = 15
	refined_type = /obj/item/stack/sheet/mineral/plasma
	materials = list(MAT_PLASMA=MINERAL_MATERIAL_AMOUNT)

/obj/item/stack/ore/plasma/attackby(obj/item/I as obj, mob/user as mob, params)
	if(istype(I, /obj/item/weldingtool))
		var/obj/item/weldingtool/W = I
		if(W.welding)
			to_chat(user, "<span class='warning'>You can't hit a high enough temperature to smelt [src] properly!</span>")
	else
		..()

/obj/item/stack/ore/silver
	name = "silver ore"
	icon_state = "Silver ore"
	origin_tech = "materials=3"
	singular_name = "silver ore chunk"
	points = 16
	refined_type = /obj/item/stack/sheet/mineral/silver
	materials = list(MAT_SILVER=MINERAL_MATERIAL_AMOUNT)

/obj/item/stack/ore/gold
	name = "gold ore"
	icon_state = "Gold ore"
	origin_tech = "materials=4"
	singular_name = "gold ore chunk"
	points = 18
	refined_type = /obj/item/stack/sheet/mineral/gold
	materials = list(MAT_GOLD=MINERAL_MATERIAL_AMOUNT)

/obj/item/stack/ore/diamond
	name = "diamond ore"
	icon_state = "Diamond ore"
	origin_tech = "materials=6"
	singular_name = "diamond ore chunk"
	points = 50
	refined_type = /obj/item/stack/sheet/mineral/diamond
	materials = list(MAT_DIAMOND=MINERAL_MATERIAL_AMOUNT)

/obj/item/stack/ore/bananium
	name = "bananium ore"
	icon_state = "Clown ore"
	origin_tech = "materials=4"
	singular_name = "bananium ore chunk"
	points = 60
	refined_type = /obj/item/stack/sheet/mineral/bananium
	materials = list(MAT_BANANIUM=MINERAL_MATERIAL_AMOUNT)

/obj/item/stack/ore/tranquillite
	name = "tranquillite ore"
	icon_state = "Mime ore"
	origin_tech = "materials=4"
	singular_name = "transquillite ore chunk"
	points = 60
	refined_type = /obj/item/stack/sheet/mineral/tranquillite
	materials = list(MAT_TRANQUILLITE=MINERAL_MATERIAL_AMOUNT)

/obj/item/stack/ore/titanium
	name = "titanium ore"
	icon_state = "Titanium ore"
	singular_name = "titanium ore chunk"
	points = 50
	materials = list(MAT_TITANIUM=MINERAL_MATERIAL_AMOUNT)
	refined_type = /obj/item/stack/sheet/mineral/titanium

/obj/item/stack/ore/slag
	name = "slag"
	desc = "Completely useless"
	icon_state = "slag"
	singular_name = "slag chunk"

/obj/item/twohanded/required/gibtonite
	name = "gibtonite ore"
	desc = "Extremely explosive if struck with mining equipment, Gibtonite is often used by miners to speed up their work by using it as a mining charge. This material is illegal to possess by unauthorized personnel under space law."
	icon = 'icons/obj/mining.dmi'
	icon_state = "Gibtonite ore"
	item_state = "Gibtonite ore"
	w_class = WEIGHT_CLASS_BULKY
	throw_range = 0
	anchored = 1 //Forces people to carry it by hand, no pulling!
	var/primed = 0
	var/det_time = 100
	var/quality = GIBTONITE_QUALITY_LOW //How pure this gibtonite is, determines the explosion produced by it and is derived from the det_time of the rock wall it was taken from, higher value = better
	var/attacher = "UNKNOWN"
	var/datum/wires/explosive/gibtonite/wires

/obj/item/twohanded/required/gibtonite/Destroy()
	QDEL_NULL(wires)
	return ..()

/obj/item/twohanded/required/gibtonite/attackby(obj/item/I, mob/user, params)
	if(!wires && istype(I, /obj/item/assembly/igniter))
		user.visible_message("[user] attaches [I] to [src].", "<span class='notice'>You attach [I] to [src].</span>")
		wires = new(src)
		attacher = key_name(user)
		qdel(I)
		overlays += "Gibtonite_igniter"
		return

	if(wires && !primed)
		if(istype(I, /obj/item/wirecutters) || istype(I, /obj/item/multitool) || istype(I, /obj/item/assembly/signaler))
			wires.Interact(user)
			return

	if(istype(I, /obj/item/pickaxe) || istype(I, /obj/item/resonator) || I.force >= 10)
		GibtoniteReaction(user)
		return
	if(primed)
		if(istype(I, /obj/item/mining_scanner) || istype(I, /obj/item/t_scanner/adv_mining_scanner) || istype(I, /obj/item/multitool))
			primed = 0
			user.visible_message("The chain reaction was stopped! ...The ore's quality looks diminished.", "<span class='notice'>You stopped the chain reaction. ...The ore's quality looks diminished.</span>")
			icon_state = "Gibtonite ore"
			quality = GIBTONITE_QUALITY_LOW
			return
	..()

/obj/item/twohanded/required/gibtonite/attack_ghost(mob/user)
	if(wires)
		wires.Interact(user)

/obj/item/twohanded/required/gibtonite/attack_self(mob/user)
	if(wires)
		wires.Interact(user)
	else
		..()

/obj/item/twohanded/required/gibtonite/bullet_act(var/obj/item/projectile/P)
	GibtoniteReaction(P.firer)
	..()

/obj/item/twohanded/required/gibtonite/ex_act()
	GibtoniteReaction(null, 1)

/obj/item/twohanded/required/gibtonite/proc/GibtoniteReaction(mob/user, triggered_by = 0)
	if(!primed)
		playsound(src,'sound/effects/hit_on_shattered_glass.ogg',50,1)
		primed = 1
		icon_state = "Gibtonite active"
		var/turf/bombturf = get_turf(src)
		var/notify_admins = 0
		if(z != 5)//Only annoy the admins ingame if we're triggered off the mining zlevel
			notify_admins = 1

		if(notify_admins)
			if(triggered_by == 1)
				message_admins("An explosion has triggered a [name] to detonate at [ADMIN_COORDJMP(bombturf)].")
			else if(triggered_by == 2)
				message_admins("A signal has triggered a [name] to detonate at [ADMIN_COORDJMP(bombturf)]. Igniter attacher: [key_name_admin(attacher)]")
			else
				message_admins("[key_name_admin(user)] has triggered a [name] to detonate at [ADMIN_COORDJMP(bombturf)].")
		if(triggered_by == 1)
			log_game("An explosion has primed a [name] for detonation at [AREACOORD(bombturf)]")
		else if(triggered_by == 2)
			log_game("A signal has primed a [name] for detonation at [AREACOORD(bombturf)]). Igniter attacher: [key_name(attacher)].")
		else
			user.visible_message("<span class='warning'>[user] strikes \the [src], causing a chain reaction!</span>", "<span class='danger'>You strike \the [src], causing a chain reaction.</span>")
			log_game("[key_name(user)] has primed a [name] for detonation at [AREACOORD(bombturf)])")
		spawn(det_time)
		if(primed)
			if(quality == GIBTONITE_QUALITY_HIGH)
				explosion(src.loc,2,4,9,adminlog = notify_admins)
			if(quality == GIBTONITE_QUALITY_MEDIUM)
				explosion(src.loc,1,2,5,adminlog = notify_admins)
			if(quality == GIBTONITE_QUALITY_LOW)
				explosion(src.loc,-1,1,3,adminlog = notify_admins)
			qdel(src)


/obj/item/stack/ore/ex_act()
	return

#undef GIBTONITE_QUALITY_LOW
#undef GIBTONITE_QUALITY_MEDIUM
#undef GIBTONITE_QUALITY_HIGH
#undef PROBABILITY_REFINE_BY_FIRE
#undef ORESTACK_OVERLAYS_MAX
