//Grown foods.
/obj/item/weapon/reagent_containers/food/snacks/grown

	name = "fruit"
	icon = 'icons/obj/hydroponics_products.dmi'
	icon_state = "blank"
	desc = "Nutritious! Probably."

	var/plantname
	var/datum/seed/seed
	var/potency = -1
	var/awakening = 0
	burn_state = FLAMMABLE

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
		to_chat(world, "<span class='danger'>Plant controller does not exist and [src] requires it. Aborting.</span>")
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
		to_chat(world, "<span class='danger'>Plant controller does not exist and [src] requires it. Aborting.</span>")
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
		if(reagents.has_reagent("cocoa"))
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
		if(reagents.has_reagent("gold") || reagents.has_reagent("silver"))
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
			to_chat(M, "<span class='notice'>You slipped on the [name]!</span>")
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
				to_chat(user, "<span class='notice'>You add some cable to the [src.name] and slide it inside the battery casing.</span>")
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
				to_chat(user, "You slice \the [src] into sticks.")
				reagents_per_slice = reagents.total_volume
				slice = new /obj/item/weapon/reagent_containers/food/snacks/rawsticks(get_turf(src))
				reagents.trans_to(slice, reagents_per_slice)
				qdel(src)
				return
			else if(seed.kitchen_tag == "carrot")
				to_chat(user, "You slice \the [src] into sticks.")
				reagents_per_slice = reagents.total_volume
				slice = new /obj/item/weapon/reagent_containers/food/snacks/carrotfries(get_turf(src))
				reagents.trans_to(slice, reagents_per_slice)
				qdel(src)
				return
			else if(seed.kitchen_tag == "watermelon")
				to_chat(user, "You slice \the [src] into large slices.")
				reagents_per_slice = reagents.total_volume/5
				for(var/i=0,i<5,i++)
					slice = new /obj/item/weapon/reagent_containers/food/snacks/watermelonslice(get_turf(src))
					reagents.trans_to(slice, reagents_per_slice)
				qdel(src)
				return
			else if(seed.kitchen_tag == "soybeans")
				to_chat(user, "You roughly chop up \the [src].")
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
						for(var/obj/item/stack/sheet/wood/G in user.loc)
							if(G==NG)
								continue
							if(G.amount>=G.max_amount)
								continue
							G.attackby(NG, user)
						to_chat(user, "You add the newly-formed wood to the stack. It now contains [NG.amount] planks.")
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
				to_chat(user, "\blue You roll the [src] into a rolling paper.")
				qdel(src)
			else
				to_chat(user, "\red You can't roll a smokable from the [src].")

	..()

/obj/item/weapon/reagent_containers/food/snacks/grown/attack(var/mob/living/carbon/M, var/mob/user, var/def_zone)
	if(awakening)
		to_chat(user, "<span class='warning'>The [src] is twitching and shaking, preventing you from eating it.</span>")
		return
	if(user == M)
		return ..()

	if(user.a_intent == I_HARM)

		// This is being copypasted here because reagent_containers (WHY DOES FOOD DESCEND FROM THAT) overrides it completely.
		// TODO: refactor all food paths to be less horrible and difficult to work with in this respect. ~Z
		if(!istype(M)) return 0

		if(!def_zone)
			def_zone = check_zone(user.zone_sel.selecting)

		user.lastattacked = M
		M.lastattacker = user
		user.attack_log += "\[[time_stamp()]\]<font color='red'> Attacked [key_name(M)] with [name] (INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(damtype)])</font>"
		M.attack_log += "\[[time_stamp()]\]<font color='orange'> Attacked by [key_name(user)] with [name] (INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(damtype)])</font>"
		msg_admin_attack("[key_name_admin(user)] attacked [key_name_admin(M)] with [name] (INTENT: [uppertext(user.a_intent)]) (DAMTYE: [uppertext(damtype)])" )

		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			var/hit = H.attacked_by(src, user, def_zone)
			if(hit && hitsound)
				playsound(loc, hitsound, 50, 1, -1)
			//return hit
		else
			if(attack_verb.len)
				user.visible_message("<span class='danger'>[M] has been [pick(attack_verb)] with [src] by [user]!</span>")
			else
				user.visible_message("<span class='danger'>[M] has been attacked with [src] by [user]!</span>")

			if(hitsound)
				playsound(loc, hitsound, 50, 1, -1)
			switch(damtype)
				if("brute")
					M.take_organ_damage(force)
					if(prob(33))
						var/turf/simulated/location = get_turf(M)
						if(istype(location)) location.add_blood_floor(M)
				if("fire")
					M.take_organ_damage(0, force)
			M.updatehealth()

		if(seed && seed.get_trait(TRAIT_CARNIVOROUS))
			seed.do_thorns(M, src, def_zone)

		if(ishuman(M) && seed && seed.get_trait(TRAIT_STINGS))
			if(!reagents || reagents.total_volume <= 0)
				return
			seed.do_sting(M, src, def_zone)
			reagents.remove_any(rand(1,3))		//use up some of the reagents at random
			sleep(-1)
			if(!src)
				return
			if(reagents && reagents.total_volume <= 0)		//used-up fruit will be destroyed
				if(user)
					to_chat(user, "<span class='danger'>\The [src] has dried out and crumbles to dust.</span>")
					//user.drop_from_inventory(src)
				qdel(src)
			else if(prob(35))		//fruit that still has reagents has a chance of breaking each time it stings on hit
				if(user)
					to_chat(user, "<span class='danger'>\The [src] has fallen to bits.</span>")
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

	if(user.a_intent == I_HARM)
		user.visible_message("<span class='danger'>\The [user] squashes \the [src]!</span>")
		seed.thrown_at(src,user)
		sleep(-1)
		if(src) qdel(src)
		return

	if(user.a_intent == I_DISARM && seed.get_trait(TRAIT_SPREAD) > 0)		//Using disarm so we can tell if you want to plant or convert non-final plants
		to_chat(user, "<span class='notice'>You plant the [src.name].</span>")
		new /obj/machinery/portable_atmospherics/hydroponics/soil/invisible(get_turf(user),src.seed)
		new /obj/effect/plant(get_turf(user), src.seed)
		qdel(src)
		return


	if(!seed.final_form)	//This isn't even my final form! (sorry, it had to be done)
		switch(seed.kitchen_tag)
			if("comfrey")
				var/obj/item/stack/medical/bruise_pack/comfrey/poultice = new /obj/item/stack/medical/bruise_pack/comfrey(user.loc)
				poultice.heal_brute = potency
				to_chat(user, "<span class='notice'>You mash the leaves into a poultice.</span>")
				qdel(src)
				return
			if("aloe")
				var/obj/item/stack/medical/ointment/aloe/poultice = new /obj/item/stack/medical/ointment/aloe(user.loc)
				poultice.heal_burn = potency
				to_chat(user, "<span class='notice'>You mash the petals into a poultice.</span>")
				qdel(src)
				return
			if("grass")
				user.show_message("<span class='notice'>You make a grass tile out of \the [src]!</span>", 1)
				for(var/i=0,i<2,i++)
					var/obj/item/stack/tile/grass/G = new (user.loc)
					G.color = seed.get_trait(TRAIT_PRODUCT_COLOUR)
					for(var/obj/item/stack/tile/grass/NG in user.loc)
						if(G==NG)
							continue
						if(NG.amount>=NG.max_amount)
							continue
						NG.attackby(G, user)
					to_chat(user, "You add the newly-formed grass to the stack. It now contains [G.amount] tiles.")
				qdel(src)
				return
			if("sunflower")
				var/obj/item/weapon/grown/sunflower/SF = new /obj/item/weapon/grown/sunflower(user.loc)
				user.unEquip(src)
				user.put_in_hands(SF)
				qdel(src)
				return
			if("novaflower")
				var/obj/item/weapon/grown/novaflower/NF = new /obj/item/weapon/grown/novaflower(user.loc)
				if(prob(10))
					user.say("PRAISE THE SUN!")
				else
					to_chat(user, "PRAISE THE SUN!")
				user.unEquip(src)
				user.put_in_hands(NF)
				qdel(src)
				return
			if("nettle")
				var/obj/item/weapon/grown/nettle/nettle = new /obj/item/weapon/grown/nettle(user.loc)
				nettle.force = round((5 + potency / 5), 1)
				to_chat(user, "You straighten up the plant.")
				user.unEquip(src)
				user.put_in_hands(nettle)
				qdel(src)
				return
			if("deathnettle")
				var/obj/item/weapon/grown/nettle/death/DN = new /obj/item/weapon/grown/nettle/death(user.loc)
				DN.force = round((5 + potency / 2.5), 1)
				to_chat(user, "You straighten up the plant.")
				user.unEquip(src)
				user.put_in_hands(DN)
				qdel(src)
				return
			if("killertomato")
				if(awakening || istype(user.loc,/turf/space))
					return
				to_chat(user, "<span class='notice'>You begin to awaken the Killer Tomato...</span>")
				awakening = 1

				spawn(30)
					if(!qdeleted(src))
						var/mob/living/simple_animal/hostile/killertomato/K = new /mob/living/simple_animal/hostile/killertomato(get_turf(src.loc))
						var/endurance_value = seed.get_trait(TRAIT_ENDURANCE)
						K.maxHealth += round(endurance_value / 3)
						K.melee_damage_lower += round(potency / 10)
						K.melee_damage_upper += round(potency / 10)
						var/production_value = seed.get_trait(TRAIT_PRODUCTION)
						K.move_to_delay -= round(production_value / 50)
						K.health = K.maxHealth
						K.visible_message("<span class='notice'>The Killer Tomato growls as it suddenly awakens.</span>")
						if(user)
							user.unEquip(src)
						qdel(src)
			if("cashpod")
				to_chat(user, "You crack open the cash pod...")
				var/value = round(seed.get_trait(TRAIT_POTENCY))
				user.unEquip(src)
				switch(value)
					if(0)
						to_chat(user, "It's empty! What a waste...")
					if(1 to 10)
						to_chat(user, "It has a space dollar inside. Woo.")
						new /obj/item/weapon/spacecash(get_turf(user))
					if(11 to 20)
						to_chat(user, "It has 10 space dollars inside!")
						new /obj/item/weapon/spacecash/c10(get_turf(user))
					if(21 to 30)
						to_chat(user, "It has 20 space dollars inside! Cool!")
						new /obj/item/weapon/spacecash/c20(get_turf(user))
					if(31 to 40)
						to_chat(user, "It has 50 space dollars inside! Nice!")
						new /obj/item/weapon/spacecash/c50(get_turf(user))
					if(41 to 50)
						to_chat(user, "It has 100 space dollars inside! Sweet!")
						new /obj/item/weapon/spacecash/c100(get_turf(user))
					if(51 to 60)
						to_chat(user, "It has 200 space dollars inside! Awesome!")
						new /obj/item/weapon/spacecash/c200(get_turf(user))
					if(61 to 80)
						to_chat(user, "It has 500 space dollars inside! CHA-CHING!")
						new /obj/item/weapon/spacecash/c500(get_turf(user))
					else
						to_chat(user, "It has 1000 space dollars inside! JACKPOT!")
						new /obj/item/weapon/spacecash/c1000(get_turf(user))
				qdel(src)
				return

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


/obj/item/weapon/reagent_containers/food/snacks/grown/On_Consume(mob/M, mob/user)
	if(seed && seed.get_trait(TRAIT_BATTERY_RECHARGE))
		if(!reagents.total_volume)
			var/batteries_recharged = 0
			for(var/obj/item/weapon/stock_parts/cell/C in user.GetAllContents())
				var/newcharge = (potency*0.01)*C.maxcharge
				if(C.charge < newcharge)
					C.charge = newcharge
					if(isobj(C.loc))
						var/obj/O = C.loc
						O.update_icon() //update power meters and such
					batteries_recharged = 1
			if(batteries_recharged)
				to_chat(user, "<span class='notice'>Battery has recovered.</span>")
	..()