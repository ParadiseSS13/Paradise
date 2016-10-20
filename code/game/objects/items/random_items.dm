// -------------------------------------
// Generates an innocuous toy
// -------------------------------------
/obj/item/toy/random
	name = "Random Toy"
	New()
		..()
		var/list/types = list(/obj/item/weapon/gun/projectile/shotgun/toy/crossbow, /obj/item/toy/balloon,/obj/item/toy/spinningtoy,/obj/item/weapon/reagent_containers/spray/waterflower) + subtypesof(/obj/item/toy/prize)
		var/T = pick(types)
		new T(loc)
		spawn(1)
			qdel(src)

// -------------------------------------
//	Random cleanables, clearly this makes sense
// -------------------------------------

/obj/effect/decal/cleanable/random
	name = "Random Mess"
	New()
		..()
		var/list/list = subtypesof(/obj/effect/decal/cleanable) - list(/obj/effect/decal/cleanable/random,/obj/effect/decal/cleanable/cobweb,/obj/effect/decal/cleanable/cobweb2)
		var/T = pick(list)
		new T(loc)
		spawn(0)
			qdel(src)


/obj/item/stack/sheet/animalhide/random
	name = "random animal hide"
	New()
		..()
		spawn(1)
			var/htype = pick(/obj/item/stack/sheet/animalhide/cat,/obj/item/stack/sheet/animalhide/corgi,/obj/item/stack/sheet/animalhide/human,/obj/item/stack/sheet/animalhide/lizard,/obj/item/stack/sheet/animalhide/monkey)
			var/obj/item/stack/S = new htype(loc)
			S.amount = amount
			qdel(src)

// -------------------------------------
//    Not yet identified chemical.
//        Could be anything!
// -------------------------------------

/obj/item/weapon/reagent_containers/glass/bottle/random_reagent
	name = "unlabelled bottle"
//	identify_probability = 0
	New()
		..()
		var/datum/reagent/R = pick(chemical_reagents_list)
		if(rare_chemicals.Find(R))
			reagents.add_reagent(R,10)
		else
			reagents.add_reagent(R,rand(2,3)*10)
		pixel_x = rand(-10,10)
		pixel_y = rand(-10,10)

//Cuts out the food and drink reagents
/obj/item/weapon/reagent_containers/glass/bottle/random_chem
	name = "unlabelled chemical bottle"
//	identify_probability = 0
	New()
		..()

		var/datum/reagent/R = pick(standard_chemicals + rare_chemicals)
		if(rare_chemicals.Find(R))
			reagents.add_reagent(R,10)
		else
			reagents.add_reagent(R,rand(2,3)*10)
		name = "unlabelled bottle"
		pixel_x = rand(-10,10)
		pixel_y = rand(-10,10)

/obj/item/weapon/reagent_containers/glass/bottle/random_base_chem
	name = "unlabelled chemical bottle"
//	identify_probability = 0
	New()
		..()
		var/datum/reagent/R = pick(base_chemicals)
		reagents.add_reagent(R,rand(2,6)*5)
		name = "unlabelled bottle"
		pixel_x = rand(-10,10)
		pixel_y = rand(-10,10)

/obj/item/weapon/reagent_containers/food/drinks/bottle/random_drink
	name = "unlabelled drink"
	icon = 'icons/obj/drinks.dmi'
	New()
		..()
		var/list/additional_drinks = list()
		if(prob(50))
			additional_drinks += list("pancuronium","lsd","omnizine","blood")

		var/datum/reagent/R = pick(drinks + additional_drinks)
		reagents.add_reagent(R,volume)
		name = "unlabelled bottle"
		icon_state = pick("alco-white","alco-green","alco-blue","alco-clear","alco-red")
		pixel_x = rand(-5,5)
		pixel_y = rand(-5,5)

/obj/item/weapon/reagent_containers/food/drinks/bottle/random_reagent // Same as the chembottle code except the container
	name = "unlabelled drink?"
	icon = 'icons/obj/drinks.dmi'
	New()
		..()
		var/datum/reagent/R = pick(chemical_reagents_list)
		if(rare_chemicals.Find(R))
			reagents.add_reagent(R,10)
		else
			reagents.add_reagent(R,rand(3,10)*10)
		name = "unlabelled bottle"
		icon_state = pick("alco-white","alco-green","alco-blue","alco-clear","alco-red")
		pixel_x = rand(-5,5)
		pixel_y = rand(-5,5)
		spawn(0)
			qdel(src)

/obj/item/weapon/storage/pill_bottle/random_meds
	name = "unlabelled pillbottle"
	desc = "The sheer recklessness of this bottle's existence astounds you."

	New()
		..()
		var/i = 1
		while(i < storage_slots)

			var/datum/reagent/R
			if(prob(50))
				R = pick(standard_medicines + rare_medicines)
			else
				R = pick(standard_medicines)
			var/obj/item/weapon/reagent_containers/food/pill/P = new(src)

			if(rare_medicines.Find(R))
				P.reagents.add_reagent(R,10)
			else
				P.reagents.add_reagent(R,rand(2,5)*10)
			P.name = "Unlabelled Pill"
			P.desc = "Something about this pill entices you to try it, against your better judgement."
			i++
		pixel_x = rand(-10,10)
		pixel_y = rand(-10,10)
		return

// -------------------------------------
//    Containers full of unknown crap
// -------------------------------------

/obj/structure/closet/crate/secure/unknownchemicals
	name = "grey-market chemicals grab pack"
	desc = "Crate full of chemicals of unknown type and value from a 'trusted' source."
	req_one_access = list(access_chemistry,access_research,access_qm) // the qm knows a guy, you see.

	New()
		..()
		new/obj/item/weapon/reagent_containers/glass/bottle/random_base_chem(src)
		new/obj/item/weapon/reagent_containers/glass/bottle/random_base_chem(src)
		new/obj/item/weapon/reagent_containers/glass/bottle/random_base_chem(src)
		new/obj/item/weapon/reagent_containers/glass/bottle/random_base_chem(src)
		new/obj/item/weapon/reagent_containers/glass/bottle/random_base_chem(src)
		new/obj/item/weapon/reagent_containers/glass/bottle/random_base_chem(src)
		new/obj/item/weapon/reagent_containers/glass/bottle/random_base_chem(src)
		new/obj/item/weapon/reagent_containers/glass/bottle/random_chem(src)
		new/obj/item/weapon/reagent_containers/glass/bottle/random_chem(src)
		new/obj/item/weapon/reagent_containers/glass/bottle/random_chem(src)
		while(prob(50))
			new/obj/item/weapon/reagent_containers/glass/bottle/random_reagent(src)

		new/obj/item/weapon/storage/pill_bottle/random_meds(src)
		while(prob(25))
			new/obj/item/weapon/storage/pill_bottle/random_meds(src)

/obj/structure/closet/crate/secure/chemicals
	name		= "chemical supply kit"
	desc		= "Full of basic chemistry supplies."
	req_one_access	= list(access_chemistry,access_research)

	New()
		..()
		for(var/chem in standard_chemicals)
			var/obj/item/weapon/reagent_containers/glass/bottle/B = new(src)
			B.reagents.add_reagent(chem,B.volume)
			if(prob(85))
				var/datum/reagent/r = chemical_reagents_list[chem]
				B.name	= "[r.name] bottle"
//				B.identify_probability = 100
			else
				B.name	= "unlabelled bottle"
				B.desc	= "Looks like the label fell off."
//				B.identify_probability = 0

/*
/obj/structure/closet/crate/bin/flowers
	name = "flower barrel"
	desc = "A bin full of fresh flowers for the bereaved."
	anchored = 0
	New()
		while(contents.len < 10)
			var/flowertype = pick(/obj/item/weapon/grown/sunflower,/obj/item/weapon/grown/novaflower,/obj/item/weapon/reagent_containers/food/snacks/grown/poppy,
				/obj/item/weapon/reagent_containers/food/snacks/grown/harebell,/obj/item/weapon/reagent_containers/food/snacks/grown/moonflower)
			var/atom/movable/AM = new flowertype(src)
			AM.pixel_x = rand(-10,10)
			AM.pixel_y = rand(-5,5)

/obj/structure/closet/crate/bin/plants
	name = "plant barrel"
	desc = "Caution: Contents may contain vitamins and minerals.  It is recommended that you deep fry them before eating."
	anchored = 0
	New()
		while(contents.len < 10)
			var/ptype = pick(/obj/item/weapon/reagent_containers/food/snacks/grown/apple,/obj/item/weapon/reagent_containers/food/snacks/grown/banana,
							 /obj/item/weapon/reagent_containers/food/snacks/grown/berries, /obj/item/weapon/reagent_containers/food/snacks/grown/cabbage,
							 /obj/item/weapon/reagent_containers/food/snacks/grown/carrot, /obj/item/weapon/reagent_containers/food/snacks/grown/cherries,
							 /obj/item/weapon/reagent_containers/food/snacks/grown/chili, /obj/item/weapon/reagent_containers/food/snacks/grown/cocoapod,
							 /obj/item/weapon/reagent_containers/food/snacks/grown/corn, /obj/item/weapon/reagent_containers/food/snacks/grown/eggplant,
							 /obj/item/weapon/reagent_containers/food/snacks/grown/grapes, /obj/item/weapon/reagent_containers/food/snacks/grown/greengrapes,
							 /obj/item/weapon/reagent_containers/food/snacks/grown/icepepper, /obj/item/weapon/reagent_containers/food/snacks/grown/lemon,
							 /obj/item/weapon/reagent_containers/food/snacks/grown/lime, /obj/item/weapon/reagent_containers/food/snacks/grown/orange,
							 /obj/item/weapon/reagent_containers/food/snacks/grown/potato, /obj/item/weapon/reagent_containers/food/snacks/grown/pumpkin,
							 /obj/item/weapon/reagent_containers/food/snacks/grown/soybeans, /obj/item/weapon/reagent_containers/food/snacks/grown/sugarcane,
							 /obj/item/weapon/reagent_containers/food/snacks/grown/tomato, /obj/item/weapon/reagent_containers/food/snacks/grown/watermelon,
							 /obj/item/weapon/reagent_containers/food/snacks/grown/wheat, /obj/item/weapon/reagent_containers/food/snacks/grown/whitebeet,
							 /obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/chanterelle, /obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/plumphelmet)
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

	New()
		..()
		new/obj/item/weapon/reagent_containers/food/drinks/bottle/random_drink(src)
		new/obj/item/weapon/reagent_containers/food/drinks/bottle/random_drink(src)
		new/obj/item/weapon/reagent_containers/food/drinks/bottle/random_drink(src)
		new/obj/item/weapon/reagent_containers/food/drinks/bottle/random_drink(src)
		new/obj/item/weapon/reagent_containers/food/drinks/bottle/random_drink(src)
		while(prob(25))
			new/obj/item/weapon/reagent_containers/food/drinks/bottle/random_reagent(src)


// -------------------------------------
//          Do not order this.
//  If you order this, do not open it.
//        If you open this, run.
//       If you didn't run, pray.
// -------------------------------------

/obj/structure/largecrate/evil
	name = "Mysterious Crate"
	desc = "What could it be?"

	attackby(obj/item/weapon/W as obj, mob/user as mob, params)
		if(istype(W, /obj/item/weapon/crowbar))
			var/list/menace = pick(	/mob/living/simple_animal/hostile/carp,/mob/living/simple_animal/hostile/faithless,/mob/living/simple_animal/hostile/pirate,
									/mob/living/simple_animal/hostile/creature,/mob/living/simple_animal/hostile/pirate/ranged,
									/mob/living/simple_animal/hostile/hivebot,/mob/living/simple_animal/hostile/viscerator,/mob/living/simple_animal/hostile/pirate)

			visible_message("\red Something falls out of the [src]!")
			var/obj/item/weapon/grenade/clusterbuster/C = new(src.loc)
			C.prime()
			spawn(10)
				new menace(src.loc)
				while(prob(15))
					new menace(get_step_rand(src.loc))
				..()
			return 1
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

	attackby(obj/item/weapon/W as obj, mob/user as mob, params)
		if(istype(W, /obj/item/weapon/crowbar))
			var/mob/living/simple_animal/pet/cat/Cat1 = new(loc)
			Cat1.apply_damage(250)//,TOX)
			Cat1.name = "Schrodinger's Cat"
			Cat1.desc = "It seems it's been dead for a while."

			var/mob/living/simple_animal/pet/cat/Cat2 = new(loc)
			Cat2.name = "Schrodinger's Cat"
			Cat2.desc = "It's was alive the whole time!"
			sleep(2)
			if(prob(50))
				qdel(Cat1)
			else
				qdel(Cat2)
		return ..()

// --------------------------------------
//   Collen's box of wonder and mystery
// --------------------------------------
/obj/item/weapon/storage/box/grenades
	name = "tactical grenades"
	desc = "A box with 6 tactical grenades."
	icon_state = "flashbang"
	var/list/grenadelist = list(/obj/item/weapon/grenade/chem_grenade/metalfoam, /obj/item/weapon/grenade/chem_grenade/incendiary,
	/obj/item/weapon/grenade/chem_grenade/antiweed, /obj/item/weapon/grenade/chem_grenade/cleaner, /obj/item/weapon/grenade/chem_grenade/teargas,
	/obj/item/weapon/grenade/chem_grenade/holywater, /obj/item/weapon/grenade/chem_grenade/meat,
	/obj/item/weapon/grenade/chem_grenade/dirt, /obj/item/weapon/grenade/chem_grenade/lube, /obj/item/weapon/grenade/smokebomb,
	/obj/item/weapon/grenade/chem_grenade/drugs, /obj/item/weapon/grenade/chem_grenade/ethanol) // holy list batman

	New()
		..()
		var/nade1 = pick(grenadelist)
		var/nade2 = pick(grenadelist)
		var/nade3 = pick(grenadelist)
		var/nade4 = pick(grenadelist)
		var/nade5 = pick(grenadelist)
		var/nade6 = pick(grenadelist)

		new nade1(src)
		new nade2(src)
		new nade3(src)
		new nade4(src)
		new nade5(src)
		new nade6(src)
