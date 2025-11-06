// -------------------------------------
// Generates an innocuous toy
// -------------------------------------
/obj/item/toy/random
	name = "Random Toy"

/obj/item/toy/random/Initialize(mapload)
	..()
	var/list/types = list(/obj/item/gun/projectile/shotgun/toy/crossbow, /obj/item/toy/balloon,/obj/item/toy/spinningtoy,/obj/item/reagent_containers/spray/waterflower) + subtypesof(/obj/item/toy/figure/mech)
	var/T = pick(types)
	new T(loc)
	return INITIALIZE_HINT_QDEL

// -------------------------------------
//	Random cleanables, clearly this makes sense
// -------------------------------------

/obj/effect/decal/cleanable/random
	name = "Random Mess"

/obj/effect/decal/cleanable/random/Initialize(mapload)
	. = ..()
	var/list/list = subtypesof(/obj/effect/decal/cleanable) - list(/obj/effect/decal/cleanable/random,/obj/effect/decal/cleanable/cobweb,/obj/effect/decal/cleanable/cobweb2)
	var/T = pick(list)
	new T(loc)
	qdel(src)

/obj/item/reagent_containers/drinks/bottle/random_drink
	name = "unlabelled drink"

/obj/item/reagent_containers/drinks/bottle/random_drink/Initialize(mapload)
	. = ..()
	var/list/possible_drinks = GLOB.drinks.Copy()
	if(prob(50))
		possible_drinks += list("pancuronium","lsd","omnizine","blood")

	var/datum/reagent/R = pick(possible_drinks)
	reagents.add_reagent(R, volume)
	name = "unlabelled bottle"
	icon_state = pick("alco-white","alco-green","alco-blue","alco-clear","alco-red")
	scatter_atom()

/obj/item/storage/pill_bottle/random_meds
	name = "unlabelled pillbottle"
	desc = "The sheer recklessness of this bottle's existence astounds you."
	allow_wrap = FALSE
	var/labelled = FALSE
	scatter_distance = 10

/obj/item/storage/pill_bottle/random_meds/Initialize(mapload)
	. = ..()
	scatter_atom()

/obj/item/storage/pill_bottle/random_meds/populate_contents()
	var/list/possible_meds_standard = GLOB.standard_medicines.Copy()
	var/list/possible_meds_rare = GLOB.rare_medicines.Copy()
	for(var/i in 1 to storage_slots)
		var/is_rare = prob(33)
		var/possible_meds = is_rare ? possible_meds_rare : possible_meds_standard

		var/datum/reagent/R = pick(possible_meds)
		var/obj/item/reagent_containers/pill/P = new(src)

		if(is_rare)
			P.reagents.add_reagent(R, 10)
		else
			P.reagents.add_reagent(R, rand(2, 5)*10)
		if(labelled)
			P.name = "[R] Pill"
			P.desc = "A pill containing [R]."
		else
			P.name = "Unlabelled Pill"
			P.desc = "Something about this pill entices you to try it, against your better judgement."


/obj/item/storage/pill_bottle/random_meds/labelled
	name = "variety pillbottle"
	labelled = TRUE

// --------------------------------------
//   Collen's box of wonder and mystery
// --------------------------------------
/obj/item/storage/box/grenades
	name = "tactical grenades"
	desc = "A box with 6 tactical grenades."
	icon_state = "grenade_box"

/obj/item/storage/box/grenades/populate_contents()
	var/static/list/grenadelist = list(
		/obj/item/grenade/chem_grenade/metalfoam,
		/obj/item/grenade/chem_grenade/incendiary,
		/obj/item/grenade/chem_grenade/antiweed,
		/obj/item/grenade/chem_grenade/cleaner,
		/obj/item/grenade/chem_grenade/teargas,
		/obj/item/grenade/chem_grenade/holywater,
		/obj/item/grenade/chem_grenade/meat,
		/obj/item/grenade/chem_grenade/dirt,
		/obj/item/grenade/chem_grenade/lube,
		/obj/item/grenade/smokebomb,
		/obj/item/grenade/chem_grenade/drugs,
		/obj/item/grenade/chem_grenade/ethanol) // holy list batman
	for(var/i in 1 to 6)
		var/nade = pick(grenadelist)
		new nade(src)
