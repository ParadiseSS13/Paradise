// Plant analyzer
/obj/item/plant_analyzer
	name = "plant analyzer"
	desc = "A versatile scanner for analyzing plants, plant produce, and seeds. Can be used on a bag holding unsorted seeds to quickly and thorougly sort them into usable packs."
	icon = 'icons/obj/device.dmi'
	icon_state = "hydro"
	inhand_icon_state = "analyzer"
	w_class = WEIGHT_CLASS_TINY
	slot_flags = ITEM_SLOT_BELT
	origin_tech = "magnets=2;biotech=2"
	materials = list(MAT_METAL = 210, MAT_GLASS = 40)

/obj/item/plant_analyzer/pre_attack(atom/target, mob/user, params)
	if(!istype(target, /obj/item))
		return ..()

	var/found_unsorted_seeds = FALSE
	var/depth = 0
	for(var/obj/item/unsorted_seeds/unsorted in target)
		found_unsorted_seeds = TRUE
		if(!use_tool(target, user, 0.5 SECONDS))
			break
		depth++
		unsorted.sort(depth)

	if(found_unsorted_seeds)
		return FALSE
	return ..()


// *************************************
// Hydroponics Tools
// *************************************

/// -- Skie
/obj/item/reagent_containers/spray/weedspray
	name = "weed spray"
	desc = "It's a toxic mixture, in spray form, to kill small weeds."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "weedspray"
	inhand_icon_state = "plantbgone"
	belt_icon = null
	volume = 100
	throw_range = 10
	list_reagents = list("atrazine" = 100)

/obj/item/reagent_containers/spray/weedspray/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is huffing [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return TOXLOSS

/// -- Skie
/obj/item/reagent_containers/spray/pestspray
	name = "pest spray"
	desc = "It's some pest eliminator spray! <I>Do not inhale!</I>"
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "pestspray"
	inhand_icon_state = "plantbgone"
	belt_icon = null
	volume = 100
	throw_range = 10
	list_reagents = list("pestkiller" = 100)

/obj/item/reagent_containers/spray/pestspray/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is huffing [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return TOXLOSS

/obj/item/cultivator
	name = "cultivator"
	desc = "It's used for removing weeds or scratching your back."
	icon_state = "cultivator"
	inhand_icon_state = "cultivator"
	belt_icon = "cultivator"
	origin_tech = "engineering=2;biotech=2"
	flags = CONDUCT
	force = 5
	throwforce = 7
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL = 200)
	attack_verb = list("slashed", "sliced", "cut", "clawed")
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/cultivator/rake
	name = "rake"
	icon_state = "rake"
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("slashed", "sliced", "bashed", "clawed")
	hitsound = null
	materials = null
	flags = NONE
	resistance_flags = FLAMMABLE

/obj/item/hatchet
	name = "hatchet"
	desc = "A very sharp axe blade upon a short fibremetal handle. It has a long history of chopping things, but now it is used for chopping wood."
	icon = 'icons/obj/weapons/melee.dmi'
	icon_state = "hatchet"
	inhand_icon_state = "hatchet"
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	belt_icon = "hatchet"
	flags = CONDUCT
	force = 12
	w_class = WEIGHT_CLASS_TINY
	throwforce = 15
	throw_speed = 3
	throw_range = 4
	materials = list(MAT_METAL = 15000)
	origin_tech = "materials=2;combat=2"
	attack_verb = list("chopped", "torn", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharp = TRUE

/obj/item/hatchet/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is chopping at [user.p_themselves()] with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, TRUE, -1)
	return BRUTELOSS

/obj/item/hatchet/unathiknife
	name = "duelling knife"
	desc = "A length of leather-bound wood studded with razor-sharp teeth. How crude."
	icon_state = "unathiknife"
	inhand_icon_state = "knife"
	attack_verb = list("ripped", "torn", "cut")

/obj/item/hatchet/wooden
	desc = "A crude axe blade upon a short wooden handle."
	icon_state = "woodhatchet"
	materials = null
	flags = NONE

/obj/item/scythe
	name = "scythe"
	desc = "A sharp and curved blade on a long fibremetal handle, this tool makes it easy to reap what you sow."
	icon = 'icons/obj/weapons/melee.dmi'
	icon_state = "scythe"
	lefthand_file = 'icons/mob/inhands/weapons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons_righthand.dmi'
	force = 13
	throwforce = 5
	throw_range = 3
	w_class = WEIGHT_CLASS_BULKY
	flags = CONDUCT
	armor_penetration_flat = 20
	slot_flags = ITEM_SLOT_BACK
	origin_tech = "materials=3;combat=2"
	attack_verb = list("chopped", "sliced", "cut", "reaped")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharp = TRUE
	var/extend = TRUE
	var/swiping = FALSE

/obj/item/scythe/bone
	name = "bone scythe"
	desc = "Perfect for harvesting. And it's not about plants."
	icon_state = "bone_scythe"
	force = 14
	throw_range = 4
	origin_tech = "materials=1;combat=2"

/obj/item/scythe/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is beheading [user.p_themselves()] with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/external/affecting = H.get_organ("head")
		if(affecting)
			affecting.droplimb(1, DROPLIMB_SHARP)
			playsound(loc, pick('sound/misc/desceration-01.ogg','sound/misc/desceration-02.ogg','sound/misc/desceration-01.ogg'), 50, TRUE, -1)
	return BRUTELOSS

/obj/item/scythe/pre_attack(atom/target, mob/living/user, params)
	if(swiping || !istype(target, /obj/structure/spacevine) || get_turf(target) == get_turf(user))
		return ..()
	else
		var/turf/user_turf = get_turf(user)
		var/dir_to_target = get_dir(user_turf, get_turf(target))
		swiping = TRUE
		var/static/list/scythe_slash_angles = list(0, 45, 90, -45, -90)
		for(var/i in scythe_slash_angles)
			var/turf/T = get_step(user_turf, turn(dir_to_target, i))
			for(var/obj/structure/spacevine/V in T)
				if(user.Adjacent(V))
					melee_attack_chain(user, V)
		swiping = FALSE

/obj/item/scythe/tele
	name = "telescopic scythe"
	desc = "A sharp and curved blade on a collapsable fibre metal handle, this tool is the pinnacle of covert reaping technology."
	icon_state = "tscythe0"
	inhand_icon_state = null	//no sprite for folded version, like a tele-baton
	force = 3
	sharp = FALSE
	w_class = WEIGHT_CLASS_SMALL
	extend = FALSE
	slot_flags = ITEM_SLOT_BELT
	origin_tech = "materials=3;combat=3"
	attack_verb = list("hit", "poked")
	hitsound = "swing_hit"

/obj/item/scythe/tele/attack_self__legacy__attackchain(mob/user)
	extend = !extend
	if(extend)
		to_chat(user, "<span class='warning'>With a flick of your wrist, you extend the scythe. It's reaping time!</span>")
		slot_flags = ITEM_SLOT_BACK	//won't fit on belt, but can be worn on belt when extended
		w_class = WEIGHT_CLASS_BULKY		//won't fit in backpacks while extended
		force = 15		//slightly better than normal scythe damage
		attack_verb = list("chopped", "sliced", "cut", "reaped")
		hitsound = 'sound/weapons/bladeslice.ogg'
		//Extend sound (blade unsheath)
		playsound(src.loc, 'sound/weapons/blade_unsheath.ogg', 50, 1)	//Sound credit to Qat of Freesound.org
	else
		to_chat(user, "<span class='notice'>You collapse the scythe, folding it away for easy storage.</span>")
		slot_flags = ITEM_SLOT_BELT	//can be worn on belt again, but no longer makes sense to wear on the back
		w_class = WEIGHT_CLASS_SMALL
		force = 3
		attack_verb = list("hit", "poked")
		hitsound = "swing_hit"
		//Collapse sound (blade sheath)
		playsound(src.loc, 'sound/weapons/blade_sheath.ogg', 50, 1)		//Sound credit to Q.K. of Freesound.org
	set_sharpness(extend)
	update_icon(UPDATE_ICON_STATE)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.update_inv_l_hand()
		H.update_inv_r_hand()
	add_fingerprint(user)

/obj/item/scythe/tele/update_icon_state()
	if(extend)
		icon_state = "tscythe1"
		inhand_icon_state = "scythe"	//use the normal scythe in-hands
	else
		icon_state = "tscythe0"
		inhand_icon_state = null	//no sprite for folded version, like a tele-baton

// *************************************
// Nutrient defines for hydroponics
// *************************************


/obj/item/reagent_containers/glass/bottle/nutrient
	name = "jug of nutrient"
	desc = "A decent sized plastic jug."
	icon_state = "plastic_jug"
	inhand_icon_state = "carton"
	possible_transfer_amounts = list(1,2,5,10,20,40,80)
	volume = 80
	hitsound = 'sound/weapons/jug_empty_impact.ogg'
	mob_throw_hit_sound = 'sound/weapons/jug_empty_impact.ogg'
	force = 0.2
	throwforce = 0.2

/obj/item/reagent_containers/glass/bottle/nutrient/Initialize(mapload)
	. = ..()
	add_lid()

/obj/item/reagent_containers/glass/bottle/nutrient/on_reagent_change()
	. = ..()
	update_icon(UPDATE_OVERLAYS)
	if(reagents.total_volume)
		hitsound = 'sound/weapons/jug_filled_impact.ogg'
		mob_throw_hit_sound = 'sound/weapons/jug_filled_impact.ogg'
	else
		hitsound = 'sound/weapons/jug_empty_impact.ogg'
		mob_throw_hit_sound = 'sound/weapons/jug_empty_impact.ogg'

/obj/item/reagent_containers/glass/bottle/nutrient/update_overlays()
	. = ..()
	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "plastic_jug10")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent)
			if(0 to 10)
				filling.icon_state = "plastic_jug-10"
			if(11 to 29)
				filling.icon_state = "plastic_jug25"
			if(30 to 45)
				filling.icon_state = "plastic_jug40"
			if(46 to 61)
				filling.icon_state = "plastic_jug55"
			if(62 to 77)
				filling.icon_state = "plastic_jug70"
			if(78 to 92)
				filling.icon_state = "plastic_jug85"
			if(93 to INFINITY)
				filling.icon_state = "plastic_jug100"

		filling.icon += mix_color_from_reagents(reagents.reagent_list)
		. += filling

	if(!is_open_container())
		. += "lid_jug"


/obj/item/reagent_containers/glass/bottle/nutrient/ez
	name = "jug of E-Z-Nutrient"
	desc = "Contains a basic fertilizer with no special traits."
	icon_state = "plastic_jug_ez"
	list_reagents = list("eznutrient" = 80)

/obj/item/reagent_containers/glass/bottle/nutrient/mut
	name = "jug of Mutrient"
	desc = "Contains a fertilizer that causes mild mutations with each harvest."
	icon_state = "plastic_jug_mut"
	list_reagents = list("mutrient" = 80)

/obj/item/reagent_containers/glass/bottle/nutrient/l4z
	name = "jug of Left 4 Zed"
	desc = "Contains a fertilizer that limits plant yields to no more than one and causes significant mutations in plants."
	icon_state = "plastic_jug_l4z"
	list_reagents = list("left4zednutrient" = 80)

/obj/item/reagent_containers/glass/bottle/nutrient/rh
	name = "jug of Robust Harvest"
	desc = "Contains a fertilizer that increases the yield of a plant by 30% while causing no mutations."
	icon_state = "plastic_jug_rh"
	list_reagents = list("robustharvestnutrient" = 80)

/obj/item/reagent_containers/glass/bottle/nutrient/empty

/obj/item/reagent_containers/glass/bottle/nutrient/killer
	icon_state = "plastic_jug_k"

/obj/item/reagent_containers/glass/bottle/nutrient/killer/Initialize(mapload)
	. = ..()
	scatter_atom()

/obj/item/reagent_containers/glass/bottle/nutrient/killer/weedkiller
	name = "jug of weed killer"
	desc = "Contains a herbicide."
	icon_state = "plastic_jug_wk"
	list_reagents = list("atrazine" = 80)

/obj/item/reagent_containers/glass/bottle/nutrient/killer/pestkiller
	name = "jug of pest spray"
	desc = "Contains a pesticide."
	icon_state = "plastic_jug_pk"
	list_reagents = list("pestkiller" = 80)
