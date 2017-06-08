//Prison Loafer//

/obj/structure/disposalpipe/loafer
	name = "disciplinary loaf processor"
	desc = "A pipe segment designed to convert detritus into a nutritionally-complete meal for inmates."
	icon = 'icons/goonstation/objects/machinery.dmi'
	icon_state = "pipe-loaf0"

/obj/structure/disposalpipe/loafer/horizontal
	dir = EAST

/obj/structure/disposalpipe/loafer/vertical
	dir = NORTH

/obj/structure/disposalpipe/loafer/New()
	..()
	dpdir = dir | turn(dir, 180)
	update()

/obj/structure/disposalpipe/loafer/transfer(obj/structure/disposalholder/H)
	if(H.contents.len)
		playsound(loc, 'sound/goonstation/machines/mixer.ogg', 50, 1)
		icon_state = "pipe-loaf1"

		var/doSuperLoaf = 0
		for(var/obj/item/weapon/reagent_containers/food/snacks/prison_loaf/PL in H)
			if(PL.super_dense)
				doSuperLoaf = 1
				break

		if(doSuperLoaf)
			for(var/atom/movable/O2 in H)
				qdel(O2)

			var/obj/item/weapon/reagent_containers/food/snacks/einstein_loaf/estein = new /obj/item/weapon/reagent_containers/food/snacks/einstein_loaf(src)
			estein.forceMove(H)
			loafer_pause()
			return ..()

		var/obj/item/weapon/reagent_containers/food/snacks/prison_loaf/newLoaf = new /obj/item/weapon/reagent_containers/food/snacks/prison_loaf(src)
		for(var/atom/movable/newIngredient in H)
			if(newIngredient.reagents)
				newIngredient.reagents.trans_to(newLoaf, 1000)

			if(istype(newIngredient, /obj/item/weapon/reagent_containers/food/snacks/prison_loaf))
				var/obj/item/weapon/reagent_containers/food/snacks/prison_loaf/otherLoaf = newIngredient
				newLoaf.loaf_factor += otherLoaf.loaf_factor * 1.2
				newLoaf.loaf_recursion = otherLoaf.loaf_recursion + 1

			else if(isliving(newIngredient))
				playsound(loc, pick('sound/effects/splat.ogg','sound/effects/slosh.ogg','sound/goonstation/effects/zhit.ogg','sound/effects/attackblob.ogg','sound/effects/blobattack.ogg','sound/goonstation/effects/bloody_stab.ogg'), 50, 1)
				var/mob/living/poorSoul = newIngredient
				if(issilicon(poorSoul))
					newLoaf.reagents.add_reagent("oil", 10)
					newLoaf.reagents.add_reagent("silicon", 10)
					newLoaf.reagents.add_reagent("iron", 10)
				else
					newLoaf.reagents.add_reagent("blood", 10)
					newLoaf.reagents.add_reagent("ectoplasm", 10)

				if(ishuman(newIngredient))
					newLoaf.loaf_factor += (newLoaf.loaf_factor / 5) + 50
				else
					newLoaf.loaf_factor += (newLoaf.loaf_factor / 10) + 50
				poorSoul.emote("scream")
				sleep(5)
				poorSoul.ghostize()
			else if(istype(newIngredient, /obj/item))
				var/obj/item/I = newIngredient
				newLoaf.loaf_factor += I.w_class * 5
			else
				newLoaf.loaf_factor++
			qdel(newIngredient)

		newLoaf.update()
		newLoaf.forceMove(H)
		loafer_pause()
		return ..()

/obj/structure/disposalpipe/loafer/proc/loafer_pause()
	sleep(3)
	playsound(loc, pick('sound/goonstation/machines/mixer.ogg','sound/goonstation/machines/mixer.ogg','sound/goonstation/machines/mixer.ogg','sound/machines/hiss.ogg','sound/machines/ding.ogg','sound/machines/buzz-sigh.ogg','sound/goonstation/effects/robogib.ogg','sound/effects/pop.ogg','sound/machines/warning-buzzer.ogg','sound/effects/Glassbr1.ogg','sound/goonstation/effects/gib.ogg','sound/goonstation/effects/spring.ogg','sound/goonstation/machines/engine_grump1.ogg','sound/goonstation/machines/engine_grump2.ogg','sound/goonstation/machines/engine_grump3.ogg','sound/effects/Glasshit.ogg','sound/effects/bubbles.ogg','sound/goonstation/effects/brrp.ogg'), 50, 1)
	sleep(3)
	playsound(loc, 'sound/goonstation/machines/engine_grump1.ogg', 50, 1)
	sleep(30)
	icon_state = "pipe-loaf0"

/obj/structure/disposalpipe/loafer/welded()
	return

#define MAXIMUM_LOAF_STATE_VALUE 10

/obj/item/weapon/reagent_containers/food/snacks/einstein_loaf
	name = "einstein-rosen loaf"
	desc = "A hypothetical feature of loaf-spacetime. It could in theory be used to open a bridge between one point in space-time to another point in loaf-spacetime, if one had the machine required ..."
	icon = 'icons/goonstation/objects/snacks.dmi'
	icon_state = "eloaf"
	volume = 1000
	force = 0
	throwforce = 0
	list_reagents = list("liquid_spacetime" = 11)

/obj/item/weapon/reagent_containers/food/snacks/prison_loaf
	name = "prison loaf"
	desc = "A rather slapdash loaf designed to feed prisoners.  Technically nutritionally complete and edible in the same sense that potted meat product is edible."
	icon = 'icons/goonstation/objects/snacks.dmi'
	icon_state = "ploaf0"
	volume = 1000
	force = 0
	throwforce = 0
	var/loaf_factor = 1
	var/loaf_recursion = 1
	var/super_dense = 0
	list_reagents = list("gravy" = 10, "beans" = 10, "fake_cheese" = 10, "silicate" = 10, "fungus" = 10, "synthflesh" = 10)

/obj/item/weapon/reagent_containers/food/snacks/prison_loaf/Destroy()
	processing_objects.Remove(src)
	return ..()

/obj/item/weapon/reagent_containers/food/snacks/prison_loaf/proc/update()
	var/orderOfLoafitude = max(0, min(round(log(8, loaf_factor)), MAXIMUM_LOAF_STATE_VALUE))

	w_class = min(orderOfLoafitude + 1, 4)

	switch(orderOfLoafitude)
		if(1)
			name = "prison loaf"
			desc = "A rather slapdash loaf designed to feed prisoners.  Technically nutritionally complete and edible in the same sense that potted meat product is edible."
			icon_state = "ploaf0"
			force = 0
			throwforce = 0
		if(2)
			name = "dense prison loaf"
			desc = "The chef must be really packing a lot of junk into these things today."
			icon_state = "ploaf0"
			force = 3
			throwforce = 3
			reagents.add_reagent("beff", 25)
		if(3)
			name = "extra dense prison loaf"
			desc = "Good lord, this thing feels almost like a brick. A brick made of kitchen scraps and god knows what else."
			icon_state = "ploaf0"
			force = 6
			throwforce = 6
			reagents.add_reagent("porktonium", 25)
		if(4)
			name = "super-compressed prison loaf"
			desc = "Hard enough to scratch a diamond, yet still somehow edible, this loaf seems to be emitting decay heat. Dear god."
			icon_state = "ploaf1"
			force = 11
			throwforce = 11
			throw_range = 6
			reagents.add_reagent("pyrosium", 25)
		if(5)
			name = "fissile loaf"
			desc = "There's so much junk packed into this loaf, the flavor atoms are starting to go fissile. This might make a decent engine fuel, but it definitely wouldn't be good for you to eat."
			icon_state = "ploaf2"
			force = 22
			throwforce = 22
			throw_range = 5
			reagents.add_reagent("uranium", 25)
		if(6)
			name = "fusion loaf"
			desc = "Forget fission, the flavor atoms in this loaf are so densely packed now that they are undergoing atomic fusion. What terrifying new flavor atoms might lurk within?"
			icon_state = "ploaf3"
			force = 44
			throwforce = 44
			throw_range = 4
			reagents.add_reagent("radium", 25)
		if(7)
			name = "neutron loaf"
			desc = "Oh good, the flavor atoms in this prison loaf have collapsed down to a a solid lump of neutrons."
			icon_state = "ploaf4"
			force = 66
			throwforce = 66
			throw_range = 3
			reagents.add_reagent("polonium", 25)
		if(8)
			name = "quark loaf"
			desc = "This nutritional loaf is collapsing into subatomic flavor particles. It is unfathmomably heavy."
			icon_state = "ploaf5"
			force = 88
			throwforce = 88
			throw_range = 2
			reagents.add_reagent("george_melonium", 25)
		if(9)
			name = "degenerate loaf"
			desc = "You should probably call a physicist."
			icon_state = "ploaf6"
			force = 110
			throwforce = 110
			throw_range = 1
			reagents.add_reagent("george_melonium", 50)
		if(10)
			name = "strangelet loaf"
			desc = "You should probably call a priest."
			icon_state = "ploaf7"
			force = 220
			throwforce = 220
			throw_range = 0
			reagents.add_reagent("george_melonium", 100)
			super_dense = 1
			processing_objects.Add(src)

/obj/item/weapon/reagent_containers/food/snacks/prison_loaf/process()
	if(isturf(loc))
		var/edge = get_edge_target_turf(src, pick(alldirs))
		spawn(0)
			throw_at(edge, 100, 1)

/obj/item/weapon/reagent_containers/food/snacks/prison_loaf/throw_impact(atom/hit_atom)
	..()
	if(super_dense)
		if(iswallturf(hit_atom))
			hit_atom.ex_act(2)
		else if(!isturf(hit_atom))
			hit_atom.ex_act(2)

#undef MAXIMUM_LOAF_STATE_VALUE