// -------------------------------------
// Generates an innocuous toy
// -------------------------------------
/obj/item/toy/random
	name = "Random Toy"

/obj/item/toy/random/New()
	..()
	var/list/types = list(/obj/item/gun/projectile/shotgun/toy/crossbow, /obj/item/toy/balloon,/obj/item/toy/spinningtoy,/obj/item/reagent_containers/spray/waterflower) + subtypesof(/obj/item/toy/prize)
	var/T = pick(types)
	new T(loc)
	qdel(src)

// -------------------------------------
//	Random cleanables, clearly this makes sense
// -------------------------------------

/obj/effect/decal/cleanable/random
	name = "Random Mess"

/obj/effect/decal/cleanable/random/New()
	..()
	var/list/list = subtypesof(/obj/effect/decal/cleanable) - list(/obj/effect/decal/cleanable/random,/obj/effect/decal/cleanable/cobweb,/obj/effect/decal/cleanable/cobweb2)
	var/T = pick(list)
	new T(loc)
	qdel(src)


/obj/item/stack/sheet/animalhide/random
	name = "random animal hide"

/obj/item/stack/sheet/animalhide/random/New()
	..()
	var/htype = pick(/obj/item/stack/sheet/animalhide/cat,/obj/item/stack/sheet/animalhide/corgi,/obj/item/stack/sheet/animalhide/human,/obj/item/stack/sheet/animalhide/lizard,/obj/item/stack/sheet/animalhide/monkey)
	var/obj/item/stack/S = new htype(loc)
	S.amount = amount
	qdel(src)

// -------------------------------------
//    Not yet identified chemical.
//        Could be anything!
// -------------------------------------

/obj/item/reagent_containers/glass/bottle/random_reagent
	name = "unlabelled bottle"
	//	identify_probability = 0

/obj/item/reagent_containers/glass/bottle/random_reagent/New()
	..()
	var/list/possible_chems = GLOB.chemical_reagents_list.Copy()
	possible_chems -= GLOB.blocked_chems.Copy()
	var/datum/reagent/R = pick(possible_chems)
	if(GLOB.rare_chemicals.Find(R))
		reagents.add_reagent(R, 10)
	else
		reagents.add_reagent(R, rand(2, 3)*10)
	pixel_x = rand(-10, 10)
	pixel_y = rand(-10, 10)

//Cuts out the food and drink reagents
/obj/item/reagent_containers/glass/bottle/random_chem
	name = "unlabelled chemical bottle"
	//	identify_probability = 0

/obj/item/reagent_containers/glass/bottle/random_chem/New()
	..()
	var/R = get_random_reagent_id()
	if(GLOB.rare_chemicals.Find(R))
		reagents.add_reagent(R, 10)
	else
		reagents.add_reagent(R, rand(2, 3)*10)
	name = "unlabelled bottle"
	pixel_x = rand(-10, 10)
	pixel_y = rand(-10, 10)

/obj/item/reagent_containers/glass/bottle/random_base_chem
	name = "unlabelled chemical bottle"
	//	identify_probability = 0

/obj/item/reagent_containers/glass/bottle/random_base_chem/New()
	..()
	var/datum/reagent/R = pick(GLOB.base_chemicals)
	reagents.add_reagent(R, rand(2, 6)*5)
	name = "unlabelled bottle"
	pixel_x = rand(-10, 10)
	pixel_y = rand(-10, 10)

/obj/item/reagent_containers/food/drinks/bottle/random_drink
	name = "unlabelled drink"
	icon = 'icons/obj/drinks.dmi'

/obj/item/reagent_containers/food/drinks/bottle/random_drink/New()
	..()
	var/list/possible_drinks = GLOB.drinks.Copy()
	if(prob(50))
		possible_drinks += list("pancuronium","lsd","omnizine","blood")

	var/datum/reagent/R = pick(possible_drinks)
	reagents.add_reagent(R, volume)
	name = "unlabelled bottle"
	icon_state = pick("alco-white","alco-green","alco-blue","alco-clear","alco-red")
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

/obj/item/reagent_containers/food/drinks/bottle/random_reagent // Same as the chembottle code except the container
	name = "unlabelled drink?"
	icon = 'icons/obj/drinks.dmi'

/obj/item/reagent_containers/food/drinks/bottle/random_reagent/New()
	..()

	var/R = get_random_reagent_id()
	if(GLOB.rare_chemicals.Find(R))
		reagents.add_reagent(R, 10)
	else
		reagents.add_reagent(R, rand(3, 10)*10)
	name = "unlabelled bottle"
	icon_state = pick("alco-white","alco-green","alco-blue","alco-clear","alco-red")
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)
	qdel(src)

/obj/item/storage/pill_bottle/random_meds
	name = "unlabelled pillbottle"
	desc = "The sheer recklessness of this bottle's existence astounds you."
	var/labelled = FALSE

/obj/item/storage/pill_bottle/random_meds/New()
	..()
	for(var/i in 1 to storage_slots)
		var/list/possible_medicines = GLOB.standard_medicines.Copy()
		if(prob(50))
			possible_medicines += GLOB.rare_medicines.Copy()
		var/datum/reagent/R = pick(possible_medicines)
		var/obj/item/reagent_containers/food/pill/P = new(src)

		if(GLOB.rare_medicines.Find(R))
			P.reagents.add_reagent(R, 10)
		else
			P.reagents.add_reagent(R, rand(2, 5)*10)
		if(labelled)
			P.name = "[R] Pill"
			P.desc = "A pill containing [R]."
		else
			P.name = "Unlabelled Pill"
			P.desc = "Something about this pill entices you to try it, against your better judgement."
	pixel_x = rand(-10, 10)
	pixel_y = rand(-10, 10)

/obj/item/storage/pill_bottle/random_meds/labelled
	name = "variety pillbottle"
	labelled = TRUE


// -------------------------------------
//    Containers full of unknown crap
// -------------------------------------

/obj/structure/closet/crate/secure/unknownchemicals
	name = "grey-market chemicals grab pack"
	desc = "Crate full of chemicals of unknown type and value from a 'trusted' source."
	req_one_access = list(access_chemistry,access_research,access_qm) // the qm knows a guy, you see.

/obj/structure/closet/crate/secure/unknownchemicals/New()
	..()
	for(var/i in 1 to 7)
		new/obj/item/reagent_containers/glass/bottle/random_base_chem(src)
	for(var/i in 1 to 3)
		new/obj/item/reagent_containers/glass/bottle/random_chem(src)
	while(prob(50))
		new/obj/item/reagent_containers/glass/bottle/random_reagent(src)

	new/obj/item/storage/pill_bottle/random_meds(src)
	while(prob(25))
		new/obj/item/storage/pill_bottle/random_meds(src)

/obj/structure/closet/crate/secure/chemicals
	name = "chemical supply kit"
	desc = "Full of basic chemistry supplies."
	req_one_access = list(access_chemistry,access_research)

/obj/structure/closet/crate/secure/chemicals/New()
	..()
	for(var/chem in GLOB.standard_chemicals)
		var/obj/item/reagent_containers/glass/bottle/B = new(src)
		B.reagents.add_reagent(chem, B.volume)
		if(prob(85))
			var/datum/reagent/r = GLOB.chemical_reagents_list[chem]
			B.name	= "[r.name] bottle"
//			B.identify_probability = 100
		else
			B.name	= "unlabelled bottle"
			B.desc	= "Looks like the label fell off."
//			B.identify_probability = 0
//
/*
/obj/structure/closet/crate/bin/flowers
	name = "flower barrel"
	desc = "A bin full of fresh flowers for the bereaved."
	anchored = 0
	New()
		while(contents.len < 10)
			var/flowertype = pick(/obj/item/grown/sunflower,/obj/item/grown/novaflower,/obj/item/reagent_containers/food/snacks/grown/poppy,
				/obj/item/reagent_containers/food/snacks/grown/harebell,/obj/item/reagent_containers/food/snacks/grown/moonflower)
			var/atom/movable/AM = new flowertype(src)
			AM.pixel_x = rand(-10,10)
			AM.pixel_y = rand(-5,5)

/obj/structure/closet/crate/bin/plants
	name = "plant barrel"
	desc = "Caution: Contents may contain vitamins and minerals.  It is recommended that you deep fry them before eating."
	anchored = 0
	New()
		while(contents.len < 10)
			var/ptype = pick(/obj/item/reagent_containers/food/snacks/grown/apple,/obj/item/reagent_containers/food/snacks/grown/banana,
							 /obj/item/reagent_containers/food/snacks/grown/berries, /obj/item/reagent_containers/food/snacks/grown/cabbage,
							 /obj/item/reagent_containers/food/snacks/grown/carrot, /obj/item/reagent_containers/food/snacks/grown/cherries,
							 /obj/item/reagent_containers/food/snacks/grown/chili, /obj/item/reagent_containers/food/snacks/grown/cocoapod,
							 /obj/item/reagent_containers/food/snacks/grown/corn, /obj/item/reagent_containers/food/snacks/grown/eggplant,
							 /obj/item/reagent_containers/food/snacks/grown/grapes, /obj/item/reagent_containers/food/snacks/grown/greengrapes,
							 /obj/item/reagent_containers/food/snacks/grown/icepepper, /obj/item/reagent_containers/food/snacks/grown/lemon,
							 /obj/item/reagent_containers/food/snacks/grown/lime, /obj/item/reagent_containers/food/snacks/grown/orange,
							 /obj/item/reagent_containers/food/snacks/grown/potato, /obj/item/reagent_containers/food/snacks/grown/pumpkin,
							 /obj/item/reagent_containers/food/snacks/grown/soybeans, /obj/item/reagent_containers/food/snacks/grown/sugarcane,
							 /obj/item/reagent_containers/food/snacks/grown/tomato, /obj/item/reagent_containers/food/snacks/grown/watermelon,
							 /obj/item/reagent_containers/food/snacks/grown/wheat, /obj/item/reagent_containers/food/snacks/grown/whitebeet,
							 /obj/item/reagent_containers/food/snacks/grown/mushroom/chanterelle, /obj/item/reagent_containers/food/snacks/grown/mushroom/plumphelmet)
			var/obj/O = new ptype(src)
			O.pixel_x = rand(-10,10)
			O.pixel_y = rand(-5,5)
*/

/obj/structure/closet/secure_closet/random_drinks
	name = "unlabelled booze closet"
	req_access = list(access_bar)
	icon_state = "cabinetdetective_locked"
	icon_closed = "cabinetdetective"
	icon_locked = "cabinetdetective_locked"
	icon_opened = "cabinetdetective_open"
	icon_broken = "cabinetdetective_broken"
	icon_off = "cabinetdetective_broken"

/obj/structure/closet/secure_closet/random_drinks/New()
	..()
	for(var/i in 1 to 5)
		new/obj/item/reagent_containers/food/drinks/bottle/random_drink(src)
	while(prob(25))
		new/obj/item/reagent_containers/food/drinks/bottle/random_reagent(src)


// -------------------------------------
//          Do not order this.
//  If you order this, do not open it.
//        If you open this, run.
//       If you didn't run, pray.
// -------------------------------------

/obj/structure/largecrate/evil
	name = "\improper Mysterious Crate"
	desc = "What could it be?"

/obj/structure/largecrate/evil/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/crowbar))
		var/list/menace = pick(	/mob/living/simple_animal/hostile/carp,/mob/living/simple_animal/hostile/faithless,/mob/living/simple_animal/hostile/pirate,
								/mob/living/simple_animal/hostile/creature,/mob/living/simple_animal/hostile/pirate/ranged,
								/mob/living/simple_animal/hostile/hivebot,/mob/living/simple_animal/hostile/viscerator,/mob/living/simple_animal/hostile/pirate)

		visible_message("<span class='warning'>Something falls out of the [src]!</span>")
		var/obj/item/grenade/clusterbuster/C = new(src.loc)
		C.prime()
		sleep(10)
		new menace(src.loc)
		while(prob(15))
			new menace(get_step_rand(src.loc))
		..()
		return TRUE
	else
		return ..()


//
//
//
//                   ???
//
//
//

/obj/structure/largecrate/schrodinger
	name = "Schrodinger's Crate"
	desc = "What happens if you open it?"

/obj/structure/largecrate/schrodinger/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/crowbar))
		sleep(2)
		var/mob/living/simple_animal/pet/cat/Cat = new(loc)
		Cat.name = "Schrodinger's Cat"

		if(prob(50))
			Cat.apply_damage(250,TOX)
			Cat.desc = "It seems it's been dead for a while."
		else
			Cat.desc = "It was alive the whole time!"
	return ..()

// --------------------------------------
//   Collen's box of wonder and mystery
// --------------------------------------
/obj/item/storage/box/grenades
	name = "tactical grenades"
	desc = "A box with 6 tactical grenades."
	icon_state = "flashbang"
	var/list/grenadelist = list(/obj/item/grenade/chem_grenade/metalfoam, /obj/item/grenade/chem_grenade/incendiary,
	/obj/item/grenade/chem_grenade/antiweed, /obj/item/grenade/chem_grenade/cleaner, /obj/item/grenade/chem_grenade/teargas,
	/obj/item/grenade/chem_grenade/holywater, /obj/item/grenade/chem_grenade/meat,
	/obj/item/grenade/chem_grenade/dirt, /obj/item/grenade/chem_grenade/lube, /obj/item/grenade/smokebomb,
	/obj/item/grenade/chem_grenade/drugs, /obj/item/grenade/chem_grenade/ethanol) // holy list batman

/obj/item/storage/box/grenades/New()
	..()
	for(var/i in 1 to 6)
		var/nade = pick(grenadelist)
		new nade(src)