// Plant analyzer
/obj/item/device/plant_analyzer
	name = "plant analyzer"
	desc = "A scanner used to evaluate a plant's various areas of growth."
	icon = 'icons/obj/device.dmi'
	icon_state = "hydro"
	item_state = "analyzer"
	w_class = 1
	slot_flags = SLOT_BELT
	origin_tech = "magnets=2;biotech=2"
	materials = list(MAT_METAL=30, MAT_GLASS=20)

// *************************************
// Hydroponics Tools
// *************************************

/obj/item/weapon/reagent_containers/spray/weedspray // -- Skie
	desc = "It's a toxic mixture, in spray form, to kill small weeds."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	name = "weed spray"
	icon_state = "weedspray"
	item_state = "plantbgone"
	volume = 100
	flags = OPENCONTAINER
	slot_flags = SLOT_BELT
	throwforce = 0
	w_class = 2
	throw_speed = 3
	throw_range = 10

/obj/item/weapon/reagent_containers/spray/weedspray/New()
	..()
	reagents.add_reagent("atrazine", 100)

/obj/item/weapon/reagent_containers/spray/weedspray/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is huffing the [src.name]! It looks like \he's trying to commit suicide.</span>")
	return (TOXLOSS)

/obj/item/weapon/reagent_containers/spray/pestspray // -- Skie
	desc = "It's some pest eliminator spray! <I>Do not inhale!</I>"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	name = "pest spray"
	icon_state = "pestspray"
	item_state = "plantbgone"
	volume = 100
	flags = OPENCONTAINER
	slot_flags = SLOT_BELT
	throwforce = 0
	w_class = 2
	throw_speed = 3
	throw_range = 10

/obj/item/weapon/reagent_containers/spray/pestspray/New()
	..()
	reagents.add_reagent("pestkiller", 100)

/obj/item/weapon/reagent_containers/spray/pestspray/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is huffing the [src.name]! It looks like \he's trying to commit suicide.</span>")
	return (TOXLOSS)

/obj/item/weapon/cultivator
	name = "cultivator"
	desc = "It's used for removing weeds or scratching your back."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "cultivator"
	item_state = "cultivator"
	origin_tech = "engineering=2;biotech=2"
	flags = CONDUCT
	force = 5
	throwforce = 7
	w_class = 2
	materials = list(MAT_METAL=50)
	attack_verb = list("slashed", "sliced", "cut", "clawed")
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/weapon/hatchet
	name = "hatchet"
	desc = "A very sharp axe blade upon a short fibremetal handle. It has a long history of chopping things, but now it is used for chopping wood."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "hatchet"
	flags = CONDUCT
	force = 12
	w_class = 1
	throwforce = 15
	throw_speed = 3
	throw_range = 4
	materials = list(MAT_METAL = 15000)
	origin_tech = "materials=2;combat=2"
	attack_verb = list("chopped", "torn", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharp = 1
	edge = 1

/obj/item/weapon/hatchet/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is chopping at \himself with the [src.name]! It looks like \he's trying to commit suicide.</span>")
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	return (BRUTELOSS)

/obj/item/weapon/hatchet/unathiknife
	name = "duelling knife"
	desc = "A length of leather-bound wood studded with razor-sharp teeth. How crude."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "unathiknife"
	attack_verb = list("ripped", "torn", "cut")

/obj/item/weapon/scythe
	icon_state = "scythe0"
	name = "scythe"
	desc = "A sharp and curved blade on a long fibremetal handle, this tool makes it easy to reap what you sow."
	force = 13
	throwforce = 5
	throw_speed = 2
	throw_range = 3
	w_class = 4
	flags = CONDUCT
	armour_penetration = 20
	slot_flags = SLOT_BACK
	origin_tech = "materials=3;combat=2"
	attack_verb = list("chopped", "sliced", "cut", "reaped")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharp = 1
	edge = 1
	var/extend = 1

/obj/item/weapon/scythe/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is beheading \himself with the [src.name]! It looks like \he's trying to commit suicide.</span>")
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/external/affecting = H.get_organ("head")
		if(affecting)
			affecting.droplimb(1, DROPLIMB_EDGE)
			playsound(loc, pick('sound/misc/desceration-01.ogg','sound/misc/desceration-02.ogg','sound/misc/desceration-01.ogg'), 50, 1, -1)
	return (BRUTELOSS)

/obj/item/weapon/scythe/tele
	icon_state = "tscythe0"
	item_state = null	//no sprite for folded version, like a tele-baton
	name = "telescopic scythe"
	desc = "A sharp and curved blade on a collapsable fibre metal handle, this tool is the pinnacle of covert reaping technology."
	force = 3
	sharp = 0
	edge = 0
	w_class = 2
	extend = 0
	slot_flags = SLOT_BELT
	origin_tech = "materials=3;combat=3"
	attack_verb = list("hit", "poked")
	hitsound = "swing_hit"

/obj/item/weapon/scythe/tele/attack_self(mob/user)
	extend = !extend
	if(extend)
		to_chat(user, "<span class='warning'>With a flick of your wrist, you extend the scythe. It's reaping time!</span>")
		icon_state = "tscythe1"
		item_state = "scythe0"	//use the normal scythe in-hands
		slot_flags = SLOT_BACK	//won't fit on belt, but can be worn on belt when extended
		w_class = 4		//won't fit in backpacks while extended
		force = 15		//slightly better than normal scythe damage
		attack_verb = list("chopped", "sliced", "cut", "reaped")
		hitsound = 'sound/weapons/bladeslice.ogg'
		//Extend sound (blade unsheath)
		playsound(src.loc, 'sound/weapons/blade_unsheath.ogg', 50, 1)	//Sound credit to Qat of Freesound.org
	else
		to_chat(user, "<span class='notice'>You collapse the scythe, folding it away for easy storage.</span>")
		icon_state = "tscythe0"
		item_state = null	//no sprite for folded version, like a tele-baton
		slot_flags = SLOT_BELT	//can be worn on belt again, but no longer makes sense to wear on the back
		w_class = 2
		force = 3
		attack_verb = list("hit", "poked")
		hitsound = "swing_hit"
		//Collapse sound (blade sheath)
		playsound(src.loc, 'sound/weapons/blade_sheath.ogg', 50, 1)		//Sound credit to Q.K. of Freesound.org
	sharp = extend
	edge = extend
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand()
		H.update_inv_r_hand()
	add_fingerprint(user)
	if(!blood_DNA)
		return
	if(blood_overlay && (blood_DNA.len >= 1))	//updated blood overlay, if any
		overlays.Cut()	//this might delete other item overlays as well but eeeeeh

		var/icon/I = new /icon(icon, icon_state)
		I.Blend(new /icon('icons/effects/blood.dmi', rgb(255,255,255)), ICON_ADD)
		I.Blend(new /icon('icons/effects/blood.dmi', "itemblood"), ICON_MULTIPLY)
		blood_overlay = I
		overlays += blood_overlay


// *************************************
// Nutrient defines for hydroponics
// *************************************


/obj/item/weapon/reagent_containers/glass/bottle/nutrient
	name = "bottle of nutrient"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"
	volume = 50
	w_class = 1
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(1,2,5,10,15,25,50)

/obj/item/weapon/reagent_containers/glass/bottle/nutrient/New()
	..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

/obj/item/weapon/reagent_containers/glass/bottle/nutrient/ez
	name = "bottle of E-Z-Nutrient"
	desc = "Contains a fertilizer that causes mild mutations with each harvest."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"

/obj/item/weapon/reagent_containers/glass/bottle/nutrient/ez/New()
	..()
	reagents.add_reagent("eznutriment", 50)

/obj/item/weapon/reagent_containers/glass/bottle/nutrient/l4z
	name = "bottle of Left 4 Zed"
	desc = "Contains a fertilizer that limits plant yields to no more than one and causes significant mutations in plants."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle18"

/obj/item/weapon/reagent_containers/glass/bottle/nutrient/l4z/New()
	..()
	reagents.add_reagent("left4zednutriment", 50)

/obj/item/weapon/reagent_containers/glass/bottle/nutrient/rh
	name = "bottle of Robust Harvest"
	desc = "Contains a fertilizer that increases the yield of a plant by 30% while causing no mutations."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle15"

/obj/item/weapon/reagent_containers/glass/bottle/nutrient/rh/New()
	..()
	reagents.add_reagent("robustharvestnutriment", 50)

/obj/item/weapon/reagent_containers/glass/bottle/nutrient/empty
	name = "bottle"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"

/obj/item/weapon/reagent_containers/glass/bottle/killer
	name = "bottle"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"
	volume = 50
	w_class = 1
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(1,2,5,10,15,25,50)

/obj/item/weapon/reagent_containers/glass/bottle/killer/weedkiller
	name = "bottle of weed killer"
	desc = "Contains a herbicide."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle19"

/obj/item/weapon/reagent_containers/glass/bottle/killer/weedkiller/New()
	..()
	reagents.add_reagent("atrazine", 50)

/obj/item/weapon/reagent_containers/glass/bottle/killer/pestkiller
	name = "bottle of pest spray"
	desc = "Contains a pesticide."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle20"

/obj/item/weapon/reagent_containers/glass/bottle/killer/pestkiller/New()
	..()
	reagents.add_reagent("pestkiller", 50)
