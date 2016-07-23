/*
 * Contains:
 *		Lasertag
 *		Costume
 *		Winter Coats
 *		Misc
 */

/*
 * Lasertag
 */
/obj/item/clothing/suit/bluetag
	name = "blue laser tag armour"
	desc = "Blue Pride, Station Wide."
	icon_state = "bluetag"
	item_state = "bluetag"
	blood_overlay_type = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	allowed = list (/obj/item/weapon/gun/energy/laser/bluetag)
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi'
		)

/obj/item/clothing/suit/redtag
	name = "red laser tag armour"
	desc = "Pew pew pew."
	icon_state = "redtag"
	item_state = "redtag"
	blood_overlay_type = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	allowed = list (/obj/item/weapon/gun/energy/laser/redtag)
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi'
		)

/*
 * Costume
 */
/obj/item/clothing/suit/pirate_brown
	name = "brown pirate coat"
	desc = "Yarr."
	icon_state = "pirate_old"
	item_state = "pirate_old"
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi'
		)

/obj/item/clothing/suit/pirate_black
	name = "black pirate coat"
	desc = "Yarr."
	icon_state = "pirate"
	item_state = "pirate"
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi'
		)

/obj/item/clothing/suit/hgpirate
	name = "pirate captain coat"
	desc = "Yarr."
	icon_state = "hgpirate"
	item_state = "hgpirate"
	flags_inv = HIDEJUMPSUIT


/obj/item/clothing/suit/cyborg_suit
	name = "cyborg suit"
	desc = "Suit for a cyborg costume."
	icon_state = "death"
	item_state = "death"
	flags = CONDUCT
	fire_resist = T0C+5200
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT


/obj/item/clothing/suit/greatcoat
	name = "great coat"
	desc = "A Nazi great coat."
	icon_state = "nazi"
	item_state = "nazi"


/obj/item/clothing/suit/johnny_coat
	name = "johnny~~ coat"
	desc = "Johnny~~"
	icon_state = "johnny"
	item_state = "johnny"


/obj/item/clothing/suit/justice
	name = "justice suit"
	desc = "this pretty much looks ridiculous"
	icon_state = "justice"
	item_state = "justice"
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT


/obj/item/clothing/suit/judgerobe
	name = "judge's robe"
	desc = "This robe commands authority."
	icon_state = "judge"
	item_state = "judge"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	allowed = list(/obj/item/weapon/storage/fancy/cigarettes,/obj/item/weapon/spacecash)
	flags_inv = HIDEJUMPSUIT


/obj/item/clothing/suit/wcoat
	name = "waistcoat"
	desc = "For some classy, murderous fun."
	icon_state = "vest"
	item_state = "wcoat"
	blood_overlay_type = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi'
		)

/obj/item/clothing/suit/apron/overalls
	name = "coveralls"
	desc = "A set of denim overalls."
	icon_state = "overalls"
	item_state = "overalls"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS


/obj/item/clothing/suit/syndicatefake
	name = "black and red space suit replica"
	icon_state = "syndicate-black-red"
	item_state = "syndicate-black-red"
	desc = "A plastic replica of the syndicate space suit, you'll look just like a real murderous syndicate agent in this! This is a toy, it is not made for use in space!"
	w_class = 3
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen,/obj/item/toy)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT


/obj/item/clothing/suit/hastur
	name = "Hastur's robes"
	desc = "Robes not meant to be worn by man."
	icon_state = "hastur"
	item_state = "hastur"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT


/obj/item/clothing/suit/imperium_monk
	name = "imperium monk"
	desc = "Have YOU killed a xeno today?"
	icon_state = "imperium_monk"
	item_state = "imperium_monk"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	flags_inv = HIDESHOES|HIDEJUMPSUIT
	allowed = list(/obj/item/weapon/storage/bible, /obj/item/weapon/nullrod, /obj/item/weapon/reagent_containers/food/drinks/bottle/holywater, /obj/item/weapon/storage/fancy/candle_box, /obj/item/candle, /obj/item/weapon/tank/emergency_oxygen)

/obj/item/clothing/suit/chickensuit
	name = "chicken suit"
	desc = "A suit made long ago by the ancient empire KFC."
	icon_state = "chickensuit"
	item_state = "chickensuit"
	body_parts_covered = UPPER_TORSO|ARMS|LOWER_TORSO|LEGS|FEET
	flags_inv = HIDESHOES|HIDEJUMPSUIT

/obj/item/clothing/suit/corgisuit
	name = "corgi suit"
	desc = "A suit made long ago by the ancient empire KFC."
	icon_state = "corgisuit"
	item_state = "chickensuit"
	body_parts_covered = UPPER_TORSO|ARMS|LOWER_TORSO|LEGS|FEET
	flags_inv = HIDESHOES|HIDEJUMPSUIT

/obj/item/clothing/suit/corgisuit/super_hero
	name = "super-hero corgi suit"
	desc = "A suit made long ago by the ancient empire KFC. This one pulses with a strange power."
	flags = NODROP

/obj/item/clothing/suit/corgisuit/super_hero/en
	name = "\improper super-hero E-N suit"
	icon_state = "ensuit"

/obj/item/clothing/suit/corgisuit/super_hero/en/New()
	..()
	processing_objects.Add(src)

/obj/item/clothing/suit/corgisuit/super_hero/en/Destroy()
	processing_objects.Remove(src)
	return ..()

/obj/item/clothing/suit/corgisuit/super_hero/en/process()
	if(prob(2))
		for(var/obj/M in orange(2,src))
			if(!M.anchored && (M.flags & CONDUCT))
				step_towards(M,src)
		for(var/mob/living/silicon/S in orange(2,src))
			if(istype(S, /mob/living/silicon/ai)) continue
			step_towards(S,src)
		for(var/mob/living/carbon/human/machine/M in orange(2,src))
			step_towards(M,src)

/obj/item/clothing/suit/monkeysuit
	name = "monkey suit"
	desc = "A suit that looks like a primate"
	icon_state = "monkeysuit"
	item_state = "monkeysuit"
	body_parts_covered = UPPER_TORSO|ARMS|LOWER_TORSO|LEGS|FEET|HANDS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT


/obj/item/clothing/suit/holidaypriest
	name = "holiday priest"
	desc = "This is a nice holiday my son."
	icon_state = "holidaypriest"
	item_state = "holidaypriest"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	flags_inv = HIDEJUMPSUIT
	allowed = list(/obj/item/weapon/storage/bible, /obj/item/weapon/nullrod, /obj/item/weapon/reagent_containers/food/drinks/bottle/holywater, /obj/item/weapon/storage/fancy/candle_box, /obj/item/candle, /obj/item/weapon/tank/emergency_oxygen)

/obj/item/clothing/suit/cardborg
	name = "cardborg suit"
	desc = "An ordinary cardboard box with holes cut in the sides."
	icon_state = "cardborg"
	item_state = "cardborg"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	flags_inv = HIDEJUMPSUIT
	species_disguise = "High-tech robot"

/obj/item/clothing/suit/cardborg/equipped(mob/living/user, slot)
	..()
	if(slot == slot_wear_suit)
		disguise(user)

/obj/item/clothing/suit/cardborg/dropped(mob/living/user)
	..()
	user.remove_alt_appearance("standard_borg_disguise")

/obj/item/clothing/suit/cardborg/proc/disguise(mob/living/carbon/human/H, obj/item/clothing/head/cardborg/borghead)
	if(istype(H))
		if(!borghead)
			borghead = H.head
		if(istype(borghead, /obj/item/clothing/head/cardborg)) //why is this done this way? because equipped() is called BEFORE THE ITEM IS IN THE SLOT WHYYYY
			var/image/I = image(icon = 'icons/mob/robots.dmi' , icon_state = "robot", loc = H)
			I.override = 1
			I.overlays += image(icon = 'icons/mob/robots.dmi' , icon_state = "eyes-robot") //gotta look realistic
			H.add_alt_appearance("standard_borg_disguise", I, silicon_mob_list+H) //you look like a robot to robots! (including yourself because you're totally a robot)


/obj/item/clothing/suit/poncho
	name = "poncho"
	desc = "Your classic, non-racist poncho."
	icon_state = "classicponcho"
	item_state = "classicponcho"
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi'
		)

/obj/item/clothing/suit/poncho/green
	name = "green poncho"
	desc = "Your classic, non-racist poncho. This one is green."
	icon_state = "greenponcho"
	item_state = "greenponcho"

/obj/item/clothing/suit/poncho/red
	name = "red poncho"
	desc = "Your classic, non-racist poncho. This one is red."
	icon_state = "redponcho"
	item_state = "redponcho"

/obj/item/clothing/suit/poncho/ponchoshame
	name = "poncho of shame"
	desc = "Forced to live on your shameful acting as a fake Mexican, you and your poncho have grown inseperable. Literally."
	icon_state = "ponchoshame"
	item_state = "ponchoshame"
	flags = NODROP

/obj/item/clothing/suit/bloated_human	//OH MY GOD WHAT HAVE YOU DONE!?!?!?
	name = "bloated human suit"
	desc = "A horribly bloated suit made from human skins."
	icon_state = "lingspacesuit"
	item_state = "lingspacesuit"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/*
 * Winter Coats
 */

/obj/item/clothing/suit/hooded/wintercoat
	name = "winter coat"
	desc = "A heavy jacket made from 'synthetic' animal furs."
	icon_state = "wintercoat"
	item_state = "labcoat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 10, rad = 0)
	allowed = list(/obj/item/device/flashlight, /obj/item/weapon/tank/emergency_oxygen, /obj/item/toy, /obj/item/weapon/storage/fancy/cigarettes, /obj/item/weapon/lighter)
	species_fit = list("Vox")
	sprite_sheets = list("Vox" = 'icons/mob/species/vox/suit.dmi')

/obj/item/clothing/head/winterhood
	name = "winter hood"
	desc = "A hood attached to a heavy winter jacket."
	icon_state = "winterhood"
	body_parts_covered = HEAD
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	flags = NODROP|BLOCKHAIR
	flags_inv = HIDEEARS
	species_fit = list("Vox")
	sprite_sheets = list("Vox" = 'icons/mob/species/vox/head.dmi')

/obj/item/clothing/suit/hooded/wintercoat/captain
	name = "captain's winter coat"
	icon_state = "wintercoat_captain"
	armor = list(melee = 25, bullet = 30, laser = 30, energy = 10, bomb = 25, bio = 0, rad = 0)
	allowed = list(/obj/item/weapon/gun/energy, /obj/item/weapon/reagent_containers/spray/pepper, /obj/item/weapon/gun/projectile, /obj/item/ammo_box,/obj/item/ammo_casing, /obj/item/weapon/melee/baton, /obj/item/weapon/restraints/handcuffs, /obj/item/device/flashlight/seclite, /obj/item/weapon/melee/classic_baton/telescopic)
	hoodtype = /obj/item/clothing/head/winterhood/captain

/obj/item/clothing/head/winterhood/captain
	icon_state = "winterhood_captain"

/obj/item/clothing/suit/hooded/wintercoat/security
	name = "security winter coat"
	icon_state = "wintercoat_sec"
	armor = list(melee = 10, bullet = 10, laser = 10, energy = 5, bomb = 15, bio = 0, rad = 0)
	allowed = list(/obj/item/weapon/gun/energy, /obj/item/weapon/reagent_containers/spray/pepper, /obj/item/weapon/gun/projectile, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/weapon/melee/baton, /obj/item/weapon/restraints/handcuffs, /obj/item/device/flashlight/seclite, /obj/item/weapon/melee/classic_baton/telescopic)
	hoodtype = /obj/item/clothing/head/winterhood/security

/obj/item/clothing/head/winterhood/security
	icon_state = "winterhood_sec"

/obj/item/clothing/suit/hooded/wintercoat/medical
	name = "medical winter coat"
	icon_state = "wintercoat_med"
	allowed = list(/obj/item/device/analyzer, /obj/item/weapon/dnainjector, /obj/item/weapon/reagent_containers/dropper, /obj/item/weapon/reagent_containers/syringe, /obj/item/weapon/reagent_containers/hypospray, /obj/item/device/healthanalyzer,/obj/item/device/flashlight/pen, /obj/item/weapon/reagent_containers/glass/bottle, /obj/item/weapon/reagent_containers/glass/beaker, /obj/item/weapon/storage/pill_bottle, /obj/item/weapon/paper, /obj/item/weapon/melee/classic_baton/telescopic)
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 50, rad = 0)
	hoodtype = /obj/item/clothing/head/winterhood/medical

/obj/item/clothing/head/winterhood/medical
	icon_state = "winterhood_med"

/obj/item/clothing/suit/hooded/wintercoat/science
	name = "science winter coat"
	icon_state = "wintercoat_sci"
	allowed = list(/obj/item/device/analyzer, /obj/item/stack/medical, /obj/item/weapon/dnainjector, /obj/item/weapon/reagent_containers/dropper, /obj/item/weapon/reagent_containers/syringe, /obj/item/weapon/reagent_containers/hypospray, /obj/item/device/healthanalyzer,/obj/item/device/flashlight/pen, /obj/item/weapon/reagent_containers/glass/bottle, /obj/item/weapon/reagent_containers/glass/beaker, /obj/item/weapon/storage/pill_bottle, /obj/item/weapon/paper, /obj/item/weapon/melee/classic_baton/telescopic)
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 10, bio = 0, rad = 0)
	hoodtype = /obj/item/clothing/head/winterhood/science

/obj/item/clothing/head/winterhood/science
	icon_state = "winterhood_sci"

/obj/item/clothing/suit/hooded/wintercoat/engineering
	name = "engineering winter coat"
	icon_state = "wintercoat_engi"
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 20)
	allowed = list(/obj/item/device/flashlight, /obj/item/weapon/tank/emergency_oxygen, /obj/item/device/t_scanner, /obj/item/weapon/rcd)
	hoodtype = /obj/item/clothing/head/winterhood/engineering

/obj/item/clothing/head/winterhood/engineering
	icon_state = "winterhood_engi"

/obj/item/clothing/suit/hooded/wintercoat/engineering/atmos
	name = "atmospherics winter coat"
	icon_state = "wintercoat_atmos"
	hoodtype = /obj/item/clothing/head/winterhood/engineering/atmos

/obj/item/clothing/head/winterhood/engineering/atmos
	icon_state = "winterhood_atmos"

/obj/item/clothing/suit/hooded/wintercoat/hydro
	name = "hydroponics winter coat"
	icon_state = "wintercoat_hydro"
	allowed = list(/obj/item/weapon/reagent_containers/spray, /obj/item/device/analyzer/plant_analyzer, /obj/item/seeds, /obj/item/weapon/reagent_containers/glass/bottle, /obj/item/weapon/hatchet, /obj/item/weapon/storage/bag/plants)
	hoodtype = /obj/item/clothing/head/winterhood/hydro

/obj/item/clothing/head/winterhood/hydro
	icon_state = "winterhood_hydro"

/obj/item/clothing/suit/hooded/wintercoat/cargo
	name = "cargo winter coat"
	icon_state = "wintercoat_cargo"
	hoodtype = /obj/item/clothing/head/winterhood/cargo

/obj/item/clothing/head/winterhood/cargo
	icon_state = "winterhood_cargo"

/obj/item/clothing/suit/hooded/wintercoat/miner
	name = "mining winter coat"
	icon_state = "wintercoat_miner"
	allowed = list(/obj/item/weapon/pickaxe, /obj/item/device/flashlight, /obj/item/weapon/tank/emergency_oxygen, /obj/item/toy, /obj/item/weapon/storage/fancy/cigarettes, /obj/item/weapon/lighter)
	armor = list(melee = 10, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0)
	hoodtype = /obj/item/clothing/head/winterhood/miner

/obj/item/clothing/head/winterhood/miner
	icon_state = "winterhood_miner"


/*
 * Misc
 */

//hoodies
/obj/item/clothing/suit/hooded/hoodie
	name = "black hoodie"
	desc = "It's a hoodie. It has a hood. Most hoodies do."
	icon_state = "black_hoodie"
	item_state = "labcoat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	hoodtype = /obj/item/clothing/head/hood
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi'
		)

/obj/item/clothing/head/hood
	name = "black hood"
	desc = "A hood attached to a hoodie."
	icon_state = "blackhood"
	body_parts_covered = HEAD
	cold_protection = HEAD
	flags = NODROP|BLOCKHAIR
	flags_inv = HIDEEARS
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/head.dmi'
		)

/obj/item/clothing/head/hood/blue
	icon_state = "bluehood"

/obj/item/clothing/head/hood/white
	icon_state = "whitehood"

/obj/item/clothing/suit/hooded/hoodie/blue
	name = "blue hoodie"
	icon_state = "blue_hoodie"
	hoodtype = /obj/item/clothing/head/hood/blue

/obj/item/clothing/suit/hooded/hoodie/mit
	name = "Martian Institute of Technology hoodie"
	desc = "A hoodie proudly worn by students and graduates alike, has the letters 'MIT' on the back."
	icon_state = "mit_hoodie"
	hoodtype = /obj/item/clothing/head/hood

/obj/item/clothing/suit/hooded/hoodie/cut
	name = "Canaan University of Technology hoodie"
	desc = "A bright hoodie with the Canaan University of Technology logo on the front."
	icon_state = "cut_hoodie"
	hoodtype = /obj/item/clothing/head/hood/white

/obj/item/clothing/suit/hooded/hoodie/lam
	name = "Lunar Academy of Medicine hoodie"
	desc = "A bright hoodie with the Lunar Academy of Medicine logo on the back."
	icon_state = "lam_hoodie"
	hoodtype = /obj/item/clothing/head/hood/white

/obj/item/clothing/suit/hooded/hoodie/nt
	name = "Nanotrasen hoodie"
	desc = "A blue hoodie with the Nanotrasen logo on the back."
	icon_state = "nt_hoodie"
	hoodtype = /obj/item/clothing/head/hood/blue

/obj/item/clothing/suit/hooded/hoodie/tp
	name = "Tharsis Polytech hoodie"
	desc = "A dark hoodie with the Tharsis Polytech logo on the back."
	icon_state = "tp_hoodie"
	hoodtype = /obj/item/clothing/head/hood

/obj/item/clothing/suit/straight_jacket
	name = "straight jacket"
	desc = "A suit that completely restrains the wearer."
	icon_state = "straight_jacket"
	item_state = "straight_jacket"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS|HANDS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT|HIDETAIL
	flags_size = ONESIZEFITSALL
	strip_delay = 60

/obj/item/clothing/suit/ianshirt
	name = "worn shirt"
	desc = "A worn out, curiously comfortable t-shirt with a picture of Ian. You wouldn't go so far as to say it feels like being hugged when you wear it but it's pretty close. Good for sleeping in."
	icon_state = "ianshirt"
	item_state = "ianshirt"
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi'
		)



//pyjamas
//originally intended to be pinstripes >.>

/obj/item/clothing/under/bluepyjamas
	name = "blue pyjamas"
	desc = "Slightly old-fashioned sleepwear."
	icon_state = "blue_pyjamas"
	item_state = "blue_pyjamas"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS

/obj/item/clothing/under/redpyjamas
	name = "red pyjamas"
	desc = "Slightly old-fashioned sleepwear."
	icon_state = "red_pyjamas"
	item_state = "red_pyjamas"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS

//coats

/obj/item/clothing/suit/leathercoat
	name = "leather coat"
	desc = "A long, thick black leather coat."
	icon_state = "leathercoat"
	item_state = "leathercoat"

/obj/item/clothing/suit/browncoat
	name = "brown leather coat"
	desc = "A long, brown leather coat."
	icon_state = "browncoat"
	item_state = "browncoat"

/obj/item/clothing/suit/neocoat
	name = "black coat"
	desc = "A flowing, black coat."
	icon_state = "neocoat"
	item_state = "neocoat"

/obj/item/clothing/suit/browntrenchcoat
	name = "brown trench coat"
	desc = "It makes you stand out. Just the opposite of why it's typically worn. Nice try trying to blend in while wearing it."
	icon_state = "brtrenchcoat"
	item_state = "brtrenchcoat"
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi'
		)

/obj/item/clothing/suit/blacktrenchcoat
	name = "black trench coat"
	desc = "That shade of black just makes you look a bit more evil. Good for those mafia types."
	icon_state = "bltrenchcoat"
	item_state = "bltrenchcoat"
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi'
		)

//trackjackets

/obj/item/clothing/suit/tracksuit
	name = "black tracksuit"
	desc = "Lightweight and stylish. What else could a man ask of his tracksuit?"
	icon_state = "trackjacket_open"
	item_state = "bltrenchcoat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	ignore_suitadjust = 0
	suit_adjusted = 1
	actions_types = list(/datum/action/item_action/openclose)
	adjust_flavour = "unzip"
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi'
		)

/obj/item/clothing/suit/tracksuit/green
	name = "green tracksuit"
	icon_state = "trackjacketgreen_open"

/obj/item/clothing/suit/tracksuit/red
	name = "red tracksuit"
	icon_state = "trackjacketred_open"

/obj/item/clothing/suit/tracksuit/white
	name = "white tracksuit"
	icon_state = "trackjacketwhite_open"

//actual suits

/obj/item/clothing/suit/creamsuit
	name = "cream suit"
	desc = "A cream coloured, genteel suit."
	icon_state = "creamsuit"
	item_state = "creamsuit"

//stripper

/obj/item/clothing/under/stripper/stripper_pink
	name = "pink swimsuit"
	desc = "A rather skimpy pink swimsuit."
	icon_state = "stripper_p_under"
	item_color = "stripper_p"

/obj/item/clothing/under/stripper/stripper_green
	name = "green swimsuit"
	desc = "A rather skimpy green swimsuit."
	icon_state = "stripper_g_under"
	item_color = "stripper_g"

/obj/item/clothing/suit/stripper/stripper_pink
	name = "pink skimpy dress"
	desc = "A rather skimpy pink dress."
	icon_state = "stripper_p_over"
	item_state = "stripper_p"

/obj/item/clothing/suit/stripper/stripper_green
	name = "green skimpy dress"
	desc = "A rather skimpy green dress."
	icon_state = "stripper_g_over"
	item_state = "stripper_g"

/obj/item/clothing/under/stripper/mankini
	name = "the mankini"
	desc = "No honest man would wear this abomination"
	icon_state = "mankini"
	item_color = "mankini"

/obj/item/clothing/suit/jacket/miljacket
	name = "olive military jacket"
	desc = "A canvas jacket styled after classical American military garb. Feels sturdy, yet comfortable. This one comes in olive."
	icon_state = "militaryjacket"
	item_state = "militaryjacket"
	ignore_suitadjust = 1
	actions_types = list()
	adjust_flavour = null
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen,/obj/item/toy,/obj/item/weapon/storage/fancy/cigarettes,/obj/item/weapon/lighter,/obj/item/weapon/gun/projectile/automatic/pistol,/obj/item/weapon/gun/projectile/revolver,/obj/item/weapon/gun/projectile/revolver/detective)

/obj/item/clothing/suit/jacket/miljacket/navy
	name = "navy military jacket"
	desc = "A canvas jacket styled after classical American military garb. Feels sturdy, yet comfortable. This one comes in navy blue."
	icon_state = "navy_jacket"

/obj/item/clothing/suit/jacket/miljacket/desert
	name = "desert military jacket"
	desc = "A canvas jacket styled after classical American military garb. Feels sturdy, yet comfortable. This one comes in desert beige."
	icon_state = "desert_jacket"

/obj/item/clothing/suit/jacket/miljacket/white
	name = "white military jacket"
	desc = "A canvas jacket styled after classical American military garb. Feels sturdy, yet comfortable. This one comes in snow white."
	icon_state = "white_jacket"

/obj/item/clothing/suit/xenos
	name = "xenos suit"
	desc = "A suit made out of chitinous alien hide."
	icon_state = "xenos"
	item_state = "xenos_helm"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS|HANDS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	flags_size = ONESIZEFITSALL

//swimsuit
/obj/item/clothing/under/swimsuit/

/obj/item/clothing/under/swimsuit/black
	name = "black swimsuit"
	desc = "An oldfashioned black swimsuit."
	icon_state = "swim_black"
	item_color = "swim_black"

/obj/item/clothing/under/swimsuit/blue
	name = "blue swimsuit"
	desc = "An oldfashioned blue swimsuit."
	icon_state = "swim_blue"
	item_color = "swim_blue"

/obj/item/clothing/under/swimsuit/purple
	name = "purple swimsuit"
	desc = "An oldfashioned purple swimsuit."
	icon_state = "swim_purp"
	item_color = "swim_purp"

/obj/item/clothing/under/swimsuit/green
	name = "green swimsuit"
	desc = "An oldfashioned green swimsuit."
	icon_state = "swim_green"
	item_color = "swim_green"

/obj/item/clothing/under/swimsuit/red
	name = "red swimsuit"
	desc = "An oldfashioned red swimsuit."
	icon_state = "swim_red"
	item_color = "swim_red"

/obj/item/clothing/suit/storage/mercy_hoodie
	name = "mercy robe"
	desc = "A soft white robe made of a synthetic fiber that provides improved protection against biohazards. Possessing multiple overlapping layers, yet light enough to allow complete freedom of movement, it denotes its wearer as a master physician."
	icon_state = "mercy_hoodie"
	item_state = "mercy_hoodie"
	w_class = 4//bulky item
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	flags_size = ONESIZEFITSALL
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/weapon/tank/emergency_oxygen,/obj/item/weapon/pen,/obj/item/device/flashlight/pen)
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 100, rad = 20)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT|HIDETAIL

/obj/item/clothing/head/mercy_hood
	name = "Mercy Hood"
	desc = "A soft white hood made of a synthetic fiber that provides improved protection against biohazards. Its elegant design allows a clear field of vision."
	icon_state = "mercy_hood"
	item_state = "mercy_hood"
	permeability_coefficient = 0.01
	flags = HEADCOVERSEYES | HEADCOVERSMOUTH | BLOCKHAIR
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 100, rad = 20)
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES

/obj/item/clothing/suit/jacket
	name = "bomber jacket"
	desc = "Aviators not included."
	icon_state = "bomber"
	item_state = "bomber"
	ignore_suitadjust = 0
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank/emergency_oxygen,/obj/item/toy,/obj/item/weapon/storage/fancy/cigarettes,/obj/item/weapon/lighter)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS
	actions_types = list(/datum/action/item_action/zipper)
	adjust_flavour = "unzip"
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi'
		)

/obj/item/clothing/suit/jacket/pilot
	name = "security bomber jacket"
	desc = "A stylish and worn-in armoured black bomber jacket emblazoned with the NT Security crest on the left breast. Looks rugged."
	icon_state = "bombersec"
	item_state = "bombersec"
	ignore_suitadjust = 0
	//Inherited from Security armour.
	allowed = list(/obj/item/weapon/gun/energy,/obj/item/weapon/reagent_containers/spray/pepper,/obj/item/weapon/gun/projectile,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/restraints/handcuffs,/obj/item/device/flashlight/seclite,/obj/item/weapon/melee/classic_baton/telescopic,/obj/item/weapon/kitchen/knife/combat)
	heat_protection = UPPER_TORSO|LOWER_TORSO
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	strip_delay = 60
	put_on_delay = 40
	flags_size = ONESIZEFITSALL
	armor = list(melee = 25, bullet = 15, laser = 25, energy = 10, bomb = 25, bio = 0, rad = 0)
	//End of inheritance from Security armour.

/obj/item/clothing/suit/jacket/leather
	name = "leather jacket"
	desc = "Pompadour not included."
	icon_state = "leatherjacket"
	ignore_suitadjust = 1
	actions_types = list()
	adjust_flavour = null

/obj/item/clothing/suit/officercoat
	name = "Clown Officer's Coat"
	desc = "A classy clown officer's overcoat, also designed by Hugo Boss."
	icon_state = "officersuit"
	item_state = "officersuit"
	ignore_suitadjust = 0
	actions_types = list(/datum/action/item_action/button)
	adjust_flavour = "unbutton"
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi'
		)

/obj/item/clothing/suit/soldiercoat
	name = "Clown Soldier's Coat"
	desc = "An overcoat for the clown soldier, to keep him warm during those cold winter nights on the front."
	icon_state = "soldiersuit"
	item_state = "soldiersuit"
	ignore_suitadjust = 0
	actions_types = list(/datum/action/item_action/button)
	adjust_flavour = "unbutton"
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi'
		)

/obj/item/clothing/suit/toggle/owlwings
	name = "owl cloak"
	desc = "A soft brown cloak made of synthetic feathers. Soft to the touch, stylish, and a 2 meter wing span that will drive the ladies mad."
	icon_state = "owl_wings"
	item_state = "owl_wings"
	body_parts_covered = ARMS
	armor = list(melee = 5, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0)
	allowed = list(/obj/item/weapon/gun/energy,/obj/item/weapon/reagent_containers/spray/pepper,/obj/item/weapon/gun/projectile,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/restraints/handcuffs,/obj/item/device/flashlight/seclite)
	actions_types = list(/datum/action/item_action/toggle_wings)
	flags = NODROP

/obj/item/clothing/suit/toggle/owlwings/griffinwings
	name = "griffon cloak"
	desc = "A plush white cloak made of synthetic feathers. Soft to the touch, stylish, and a 2 meter wing span that will drive your captives mad."
	icon_state = "griffin_wings"
	item_state = "griffin_wings"

/obj/item/clothing/suit/toggle/attack_self()
	if(icon_state == initial(icon_state))
		icon_state = icon_state + "_t"
		item_state = icon_state + "_t"
	else
		icon_state = initial(icon_state)
		item_state = initial(item_state)
	usr.update_inv_wear_suit()
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/clothing/suit/lordadmiral
	name = "Lord Admiral's Coat"
	desc = "You'll be the Ruler of the King's Navy in no time."
	icon_state = "lordadmiral"
	item_state = "lordadmiral"
	allowed = list (/obj/item/weapon/gun)

/obj/item/clothing/suit/fluff/noble_coat
	name = "noble coat"
	desc = "The livid blues, purples and greens are awesome enough to evoke a visceral response in you; it is not dissimilar to indigestion."
	icon_state = "noble_coat"
	item_state = "noble_coat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS


///Advanced Protective Suit, AKA, God Mode in wearable form.

/obj/item/clothing/suit/advanced_protective_suit
	name = "Advanced Protective Suit"
	desc = "An incredibly advanced and complex suit; it has so many buttons and dials as to be incomprehensible."
	icon_state = "bomb"
	item_state = "bomb"
	actions_types = list(/datum/action/item_action/toggle)
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	flags = STOPSPRESSUREDMAGE | THICKMATERIAL | NODROP
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS|HEAD
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 100, bio = 100, rad = 100)
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS | HEAD
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	heat_protection = UPPER_TORSO | LOWER_TORSO|LEGS|FEET|ARMS|HANDS | HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT
	slowdown = -10
	siemens_coefficient = 0
	var/on = 0

/obj/item/clothing/suit/advanced_protective_suit/Destroy()
	if(on)
		on = 0
		processing_objects.Remove(src)
	return ..()

/obj/item/clothing/suit/advanced_protective_suit/ui_action_click()
	if(on)
		on = 0
		to_chat(usr, "You turn the suit's special processes off.")
	else
		on = 1
		to_chat(usr, "You turn the suit's special processes on.")
		processing_objects.Add(src)


/obj/item/clothing/suit/advanced_protective_suit/IsReflect()
	return (on)

/obj/item/clothing/suit/advanced_protective_suit/process()
	if(on)
		var/mob/living/carbon/human/user = src.loc
		if(user && ishuman(user) && (user.wear_suit == src))
			if(user.reagents.get_reagent_amount("stimulants") < 15)
				user.reagents.add_reagent("stimulants", 15)
			if(user.reagents.get_reagent_amount("adminordrazine") < 15)
				user.reagents.add_reagent("adminordrazine", 15)
			if(user.reagents.get_reagent_amount("nanites") < 15)
				user.reagents.add_reagent("nanites", 15)
			if(user.reagents.get_reagent_amount("syndicate_nanites") < 15)
				user.reagents.add_reagent("syndicate_nanites", 15)
	else
		processing_objects.Remove(src)
