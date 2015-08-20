//Grown foods.
/obj/item/weapon/reagent_containers/food/snacks/grown

	name = "fruit"
	icon = 'icons/obj/hydroponics_products.dmi'
	icon_state = "blank"
	desc = "Nutritious! Probably."

	var/plantname
	var/datum/seed/seed
	var/potency = -1

/obj/item/weapon/reagent_containers/food/snacks/grown/New(newloc,planttype)

	..()
	if(!dried_type)
		dried_type = type
	src.pixel_x = rand(-5.0, 5)
	src.pixel_y = rand(-5.0, 5)

	// Fill the object up with the appropriate reagents.
	if(planttype)
		plantname = planttype

	if(!plantname)
		return

	if(!plant_controller)
		sleep(250) // ugly hack, should mean roundstart plants are fine.
	if(!plant_controller)
		world << "<span class='danger'>Plant controller does not exist and [src] requires it. Aborting.</span>"
		qdel(src)
		return

	seed = plant_controller.seeds[plantname]

	if(!seed)
		return

	name = "[seed.seed_name]"

	if(seed.modular_icon == 1)
		update_icon()
	else
		icon = 'icons/obj/harvest.dmi'
		icon_state = seed.preset_icon

	if(!seed.chems)
		return

	potency = seed.get_trait(TRAIT_POTENCY)

	for(var/rid in seed.chems)
		var/list/reagent_data = seed.chems[rid]
		if(reagent_data && reagent_data.len)
			var/rtotal = reagent_data[1]
			if(reagent_data.len > 1 && potency > 0)
				rtotal += round(potency/reagent_data[2])
			reagents.add_reagent(rid,max(1,rtotal))
	update_desc()
	update_trash()
	if(reagents.total_volume > 0)
		bitesize = 1+round(reagents.total_volume / 2, 1)

/obj/item/weapon/reagent_containers/food/snacks/grown/proc/update_trash()
	if(!seed)
		return
	trash = seed.trash_type
	if(seed.kitchen_tag)
		if(seed.kitchen_tag == "watermelon")	// 15% chance to leave behind a pack of watermelon seeds
			if(prob(15))
				var/obj/item/seeds/seeds = new()
				seeds.seed = seed
				seeds.update_seed()
				trash = seeds
			else
				trash = null

/obj/item/weapon/reagent_containers/food/snacks/grown/proc/update_desc()

	if(!seed)
		return
	if(!plant_controller)
		sleep(250) // ugly hack, should mean roundstart plants are fine.
	if(!plant_controller)
		world << "<span class='danger'>Plant controller does not exist and [src] requires it. Aborting.</span>"
		qdel(src)
		return

	if(plant_controller.product_descs["[seed.uid]"])
		desc = plant_controller.product_descs["[seed.uid]"]
	else
		var/list/descriptors = list()
		if(reagents.has_reagent("sugar") || reagents.has_reagent("cherryjelly") || reagents.has_reagent("honey") || reagents.has_reagent("berryjuice"))
			descriptors |= "sweet"
		if(reagents.has_reagent("charcoal"))
			descriptors |= "astringent"
		if(reagents.has_reagent("frostoil"))
			descriptors |= "numbing"
		if(reagents.has_reagent("nutriment"))
			descriptors |= "nutritious"
		if(reagents.has_reagent("condensedcapsaicin") || reagents.has_reagent("capsaicin"))
			descriptors |= "spicy"
		if(reagents.has_reagent("coco"))
			descriptors |= "bitter"
		if(reagents.has_reagent("orangejuice") || reagents.has_reagent("lemonjuice") || reagents.has_reagent("limejuice"))
			descriptors |= "sweet-sour"
		if(reagents.has_reagent("radium") || reagents.has_reagent("uranium"))
			descriptors |= "radioactive"
		if(reagents.has_reagent("amanitin") || reagents.has_reagent("toxin") || reagents.has_reagent("carpotoxin"))
			descriptors |= "poisonous"
		if(reagents.has_reagent("lsd") || reagents.has_reagent("space_drugs") || reagents.has_reagent("psilocybin"))
			descriptors |= "hallucinogenic"
		if(reagents.has_reagent("styptic_powder"))
			descriptors |= "medicinal"
		if(reagents.has_reagent("gold"))
			descriptors |= "shiny"
		if(reagents.has_reagent("lube"))
			descriptors |= "slippery"
		if(reagents.has_reagent("facid") || reagents.has_reagent("sacid"))
			descriptors |= "acidic"
		if(reagents.has_reagent("fuel"))
			descriptors |= "flammable"
		if(reagents.has_reagent("moonshine"))
			descriptors |= "intoxicating"
		if(seed.get_trait(TRAIT_JUICY))
			descriptors |= "juicy"
		if(seed.get_trait(TRAIT_STINGS))
			descriptors |= "stinging"
		if(seed.get_trait(TRAIT_TELEPORTING))
			descriptors |= "glowing"
		if(seed.get_trait(TRAIT_EXPLOSIVE))
			descriptors |= "bulbous"

		var/descriptor_num = rand(2,4)
		var/descriptor_count = descriptor_num
		desc = "A"
		while(descriptors.len && descriptor_num > 0)
			var/chosen = pick(descriptors)
			descriptors -= chosen
			desc += "[(descriptor_count>1 && descriptor_count!=descriptor_num) ? "," : "" ] [chosen]"
			descriptor_num--
		if(seed.seed_noun == "spores")
			desc += " mushroom"
		else
			desc += " fruit"
		plant_controller.product_descs["[seed.uid]"] = desc
	desc += ". Delicious! Probably."

/obj/item/weapon/reagent_containers/food/snacks/grown/update_icon()
	if(!seed || !plant_controller || !plant_controller.plant_icon_cache)
		return
	if(seed.modular_icon != 1)
		return
	overlays.Cut()
	var/image/plant_icon
	var/icon_key = "fruit-[seed.get_trait(TRAIT_PRODUCT_ICON)]-[seed.get_trait(TRAIT_PRODUCT_COLOUR)]-[seed.get_trait(TRAIT_PLANT_COLOUR)]"
	if(plant_controller.plant_icon_cache[icon_key])
		plant_icon = plant_controller.plant_icon_cache[icon_key]
	else
		plant_icon = image('icons/obj/hydroponics_products.dmi',"blank")
		var/image/fruit_base = image('icons/obj/hydroponics_products.dmi',"[seed.get_trait(TRAIT_PRODUCT_ICON)]-product")
		fruit_base.color = "[seed.get_trait(TRAIT_PRODUCT_COLOUR)]"
		plant_icon.overlays |= fruit_base
		if("[seed.get_trait(TRAIT_PRODUCT_ICON)]-leaf" in icon_states('icons/obj/hydroponics_products.dmi'))
			var/image/fruit_leaves = image('icons/obj/hydroponics_products.dmi',"[seed.get_trait(TRAIT_PRODUCT_ICON)]-leaf")
			fruit_leaves.color = "[seed.get_trait(TRAIT_PLANT_COLOUR)]"
			plant_icon.overlays |= fruit_leaves
		plant_controller.plant_icon_cache[icon_key] = plant_icon
	overlays |= plant_icon

/obj/item/weapon/reagent_containers/food/snacks/grown/Crossed(var/mob/living/M)
	if(seed && seed.get_trait(TRAIT_JUICY) == 2)
		if(istype(M))

			if(M.buckled)
				return

			if(istype(M,/mob/living/carbon/human))
				var/mob/living/carbon/human/H = M
				if(H.shoes && H.shoes.flags & NOSLIP)
					return

			M.stop_pulling()
			M << "<span class='notice'>You slipped on the [name]!</span>"
			playsound(src.loc, 'sound/misc/slip.ogg', 50, 1, -3)
			M.Stun(8)
			M.Weaken(5)
			seed.thrown_at(src,M)
			sleep(-1)
			if(src) qdel(src)
			return

/obj/item/weapon/reagent_containers/food/snacks/grown/throw_impact(atom/hit_atom)
	..()
	if(seed) seed.thrown_at(src,hit_atom)

/obj/item/weapon/reagent_containers/food/snacks/grown/attackby(var/obj/item/weapon/W, var/mob/user)

	if(seed)
		if(seed.get_trait(TRAIT_PRODUCES_POWER) && istype(W, /obj/item/stack/cable_coil))
			var/obj/item/stack/cable_coil/C = W
			if(C.use(5))
				//TODO: generalize this.
				user << "<span class='notice'>You add some cable to the [src.name] and slide it inside the battery casing.</span>"
				var/obj/item/weapon/stock_parts/cell/potato/pocell = new /obj/item/weapon/stock_parts/cell/potato(get_turf(user))
				if(src.loc == user && !(user.l_hand && user.r_hand) && istype(user,/mob/living/carbon/human))
					user.put_in_hands(pocell)
				pocell.maxcharge = src.potency * 10
				pocell.charge = pocell.maxcharge
				qdel(src)
				return
		else if(W.sharp)
			var/reagents_per_slice
			var/obj/slice
			if(seed.kitchen_tag == "pumpkin") // Ugggh these checks are awful.
				user.show_message("<span class='notice'>You carve a face into [src]!</span>", 1)
				new /obj/item/clothing/head/hardhat/pumpkinhead (user.loc)
				qdel(src)
				return
			else if(seed.kitchen_tag == "potato")
				user << "You slice \the [src] into sticks."
				reagents_per_slice = reagents.total_volume
				slice = new /obj/item/weapon/reagent_containers/food/snacks/rawsticks(get_turf(src))
				reagents.trans_to(slice, reagents_per_slice)
				qdel(src)
				return
			else if(seed.kitchen_tag == "carrot")
				user << "You slice \the [src] into sticks."
				reagents_per_slice = reagents.total_volume
				slice = new /obj/item/weapon/reagent_containers/food/snacks/carrotfries(get_turf(src))
				reagents.trans_to(slice, reagents_per_slice)
				qdel(src)
				return
			else if(seed.kitchen_tag == "watermelon")
				user << "You slice \the [src] into large slices."
				reagents_per_slice = reagents.total_volume/5
				for(var/i=0,i<5,i++)
					slice = new /obj/item/weapon/reagent_containers/food/snacks/watermelonslice(get_turf(src))
					reagents.trans_to(slice, reagents_per_slice)
				qdel(src)
				return
			else if(seed.kitchen_tag == "soybeans")
				user << "You roughly chop up \the [src]."
				reagents_per_slice = reagents.total_volume
				slice = new /obj/item/weapon/reagent_containers/food/snacks/soydope(get_turf(src))
				reagents.trans_to(slice, reagents_per_slice)
				qdel(src)
				return
			else if(seed.chems)
				if(istype(W,/obj/item/weapon/hatchet) && !isnull(seed.chems["woodpulp"]))
					user.show_message("<span class='notice'>You make planks out of \the [src]!</span>", 1)
					for(var/i=0,i<2,i++)
						var/obj/item/stack/sheet/wood/NG = new (user.loc)
						NG.color = seed.get_trait(TRAIT_PRODUCT_COLOUR)
						for (var/obj/item/stack/sheet/wood/G in user.loc)
							if(G==NG)
								continue
							if(G.amount>=G.max_amount)
								continue
							G.attackby(NG, user)
						user << "You add the newly-formed wood to the stack. It now contains [NG.amount] planks."
					qdel(src)
					return
		else if(istype(W, /obj/item/weapon/rollingpaper))
			if(seed.kitchen_tag == "ambrosia" || seed.kitchen_tag == "ambrosiadeus" || seed.kitchen_tag == "tobacco" || seed.kitchen_tag == "stobacco")
				user.unEquip(W)
				if(seed.kitchen_tag == "ambrosia")
					var/obj/item/clothing/mask/cigarette/joint/J = new /obj/item/clothing/mask/cigarette/joint(user.loc)
					J.chem_volume = src.reagents.total_volume
					src.reagents.trans_to(J, J.chem_volume)
					qdel(W)
					user.put_in_active_hand(J)
				else if(seed.kitchen_tag == "ambrosiadeus")
					var/obj/item/clothing/mask/cigarette/joint/deus/J = new /obj/item/clothing/mask/cigarette/joint/deus(user.loc)
					J.chem_volume = src.reagents.total_volume
					src.reagents.trans_to(J, J.chem_volume)
					qdel(W)
					user.put_in_active_hand(J)
				else if(seed.kitchen_tag == "tobacco" || seed.kitchen_tag == "stobacco")
					var/obj/item/clothing/mask/cigarette/handroll/J = new /obj/item/clothing/mask/cigarette/handroll(user.loc)
					J.chem_volume = src.reagents.total_volume
					src.reagents.trans_to(J, J.chem_volume)
					qdel(W)
					user.put_in_active_hand(J)
				user << "\blue You roll the [src] into a rolling paper."
				qdel(src)
			else
				user << "\red You can't roll a smokable from the [src]."

	..()

/obj/item/weapon/reagent_containers/food/snacks/grown/attack(var/mob/living/carbon/M, var/mob/user, var/def_zone)
	if(user == M)
		return ..()

	if(user.a_intent == "harm")

		// This is being copypasted here because reagent_containers (WHY DOES FOOD DESCEND FROM THAT) overrides it completely.
		// TODO: refactor all food paths to be less horrible and difficult to work with in this respect. ~Z
		if(!istype(M) || (can_operate(M) && do_surgery(M,user,src))) return 0

		user.lastattacked = M
		M.lastattacker = user
		user.attack_log += "\[[time_stamp()]\]<font color='red'> Attacked [M.name] ([M.ckey]) with [name] (INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(damtype)])</font>"
		M.attack_log += "\[[time_stamp()]\]<font color='orange'> Attacked by [user.name] ([user.ckey]) with [name] (INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(damtype)])</font>"
		msg_admin_attack("[user.name] ([user.ckey])[isAntag(user) ? "(ANTAG)" : ""] attacked [M.name] ([M.ckey]) with [name] (INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(damtype)])" )

		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			var/hit = H.attacked_by(src, user, def_zone)
			if(hit && hitsound)
				playsound(loc, hitsound, 50, 1, -1)
			return hit
		else
			if(attack_verb.len)
				user.visible_message("<span class='danger'>[M] has been [pick(attack_verb)] with [src] by [user]!</span>")
			else
				user.visible_message("<span class='danger'>[M] has been attacked with [src] by [user]!</span>")

			if (hitsound)
				playsound(loc, hitsound, 50, 1, -1)
			switch(damtype)
				if("brute")
					M.take_organ_damage(force)
					if(prob(33))
						var/turf/simulated/location = get_turf(M)
						if(istype(location)) location.add_blood_floor(M)
				if("fire")
					if (!(RESIST_COLD in M.mutations))
						M.take_organ_damage(0, force)
			M.updatehealth()

		if(seed && seed.get_trait(TRAIT_STINGS))
			if(!reagents || reagents.total_volume <= 0)
				return
			reagents.remove_any(rand(1,3))
			seed.thrown_at(src,M)
			sleep(-1)
			if(!src)
				return
			if(prob(35))
				if(user)
					user << "<span class='danger'>\The [src] has fallen to bits.</span>"
					//user.drop_from_inventory(src)
				qdel(src)

		add_fingerprint(user)
		return 1

	else
		..()

/obj/item/weapon/reagent_containers/food/snacks/grown/attack_self(mob/user as mob)

	if(!seed)
		return

	if(istype(user.loc,/turf/space))
		return

	if(user.a_intent == "harm")
		user.visible_message("<span class='danger'>\The [user] squashes \the [src]!</span>")
		seed.thrown_at(src,user)
		sleep(-1)
		if(src) qdel(src)
		return

	if(seed.kitchen_tag == "grass")
		user.show_message("<span class='notice'>You make a grass tile out of \the [src]!</span>", 1)
		for(var/i=0,i<2,i++)
			var/obj/item/stack/tile/grass/G = new (user.loc)
			G.color = seed.get_trait(TRAIT_PRODUCT_COLOUR)
			for (var/obj/item/stack/tile/grass/NG in user.loc)
				if(G==NG)
					continue
				if(NG.amount>=NG.max_amount)
					continue
				NG.attackby(G, user)
			user << "You add the newly-formed grass to the stack. It now contains [G.amount] tiles."
		qdel(src)
		return

	if(seed.get_trait(TRAIT_SPREAD) > 0)
		user << "<span class='notice'>You plant the [src.name].</span>"
		new /obj/machinery/portable_atmospherics/hydroponics/soil/invisible(get_turf(user),src.seed)
		new /obj/effect/plant(get_turf(user), src.seed)
		qdel(src)
		return

	/*
	if(seed.kitchen_tag)
		switch(seed.kitchen_tag)
			if("shand")
				var/obj/item/stack/medical/bruise_pack/tajaran/poultice = new /obj/item/stack/medical/bruise_pack/tajaran(user.loc)
				poultice.heal_brute = potency
				user << "<span class='notice'>You mash the leaves into a poultice.</span>"
				del(src)
				return
			if("mtear")
				var/obj/item/stack/medical/ointment/tajaran/poultice = new /obj/item/stack/medical/ointment/tajaran(user.loc)
				poultice.heal_burn = potency
				user << "<span class='notice'>You mash the petals into a poultice.</span>"
				del(src)
				return
	*/

/obj/item/weapon/reagent_containers/food/snacks/grown/pickup(mob/user)
	..()
	if(!seed)
		return
	if(seed.get_trait(TRAIT_STINGS))
		var/mob/living/carbon/human/H = user
		if(istype(H) && H.gloves)
			return
		if(!reagents || reagents.total_volume <= 0)
			return
		reagents.remove_any(rand(1,3)) //Todo, make it actually remove the reagents the seed uses.
		seed.do_thorns(H,src)
		seed.do_sting(H,src,pick("r_hand","l_hand"))