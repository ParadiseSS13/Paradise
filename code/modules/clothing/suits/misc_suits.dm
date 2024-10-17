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
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "bluetag"
	item_state = "bluetag"
	blood_overlay_type = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	allowed = list (/obj/item/gun/energy/laser/tag/blue)
	resistance_flags = NONE

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi'
		)

/obj/item/clothing/suit/redtag
	name = "red laser tag armour"
	desc = "Pew pew pew."
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "redtag"
	item_state = "redtag"
	blood_overlay_type = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	allowed = list (/obj/item/gun/energy/laser/tag/red)
	resistance_flags = NONE

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi'
		)

/*
 * Costume
 */
/obj/item/clothing/suit/pirate_brown
	name = "brown pirate coat"
	desc = "Yarr."
	icon_state = "pirate_old"
	item_state = "pirate_old"

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi'
		)

/obj/item/clothing/suit/pirate_black
	name = "black pirate coat"
	desc = "Yarr."
	icon_state = "pirate"
	item_state = "pirate"

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi'
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
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "death"
	item_state = "death"
	flags = CONDUCT
	fire_resist = T0C+5200
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT


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
	name = "judge's robe costume"
	desc = "A fancy costume giving off an aura of authority."
	icon_state = "judge"
	item_state = "judge"
	body_parts_covered = UPPER_TORSO | LOWER_TORSO | LEGS | ARMS
	allowed = list(/obj/item/storage/fancy/cigarettes,/obj/item/stack/spacecash)
	flags_inv = HIDEJUMPSUIT


/obj/item/clothing/suit/wcoat
	name = "waistcoat"
	desc = "For some classy, murderous fun."
	icon_state = "vest"
	item_state = "wcoat"
	blood_overlay_type = "armor"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi'
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
	w_class = WEIGHT_CLASS_NORMAL
	allowed = list(/obj/item/flashlight,/obj/item/tank/internals/emergency_oxygen,/obj/item/toy)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT|HIDETAIL
	resistance_flags = NONE

	sprite_sheets = list(
		"Tajaran" = 'icons/mob/clothing/species/tajaran/suit.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/suit.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/suit.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi')


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
	allowed = list(/obj/item/storage/bible, /obj/item/nullrod, /obj/item/reagent_containers/drinks/bottle/holywater, /obj/item/storage/fancy/candle_box, /obj/item/candle, /obj/item/tank/internals/emergency_oxygen)

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
	flags_inv = HIDEJUMPSUIT
	dog_fashion = /datum/dog_fashion/back

/obj/item/clothing/suit/corgisuit/en
	name = "super-hero E-N suit"
	icon_state = "ensuit"

/obj/item/clothing/suit/corgisuit/super_hero
	name = "super-hero corgi suit"
	desc = "A suit made long ago by the ancient empire KFC. This one pulses with a strange power."
	flags = NODROP

/obj/item/clothing/suit/corgisuit/super_hero/en
	name = "super-hero E-N suit"
	icon_state = "ensuit"

/obj/item/clothing/suit/corgisuit/super_hero/en/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/clothing/suit/corgisuit/super_hero/en/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/suit/corgisuit/super_hero/en/process()
	if(prob(2))
		for(var/obj/M in orange(2,src))
			if(!M.anchored && (M.flags & CONDUCT))
				step_towards(M,src)
		for(var/mob/living/silicon/S in orange(2,src))
			if(isAI(S)) continue
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
	allowed = list(/obj/item/storage/bible, /obj/item/nullrod, /obj/item/reagent_containers/drinks/bottle/holywater, /obj/item/storage/fancy/candle_box, /obj/item/candle, /obj/item/tank/internals/emergency_oxygen)

/obj/item/clothing/suit/snowman
	name = "snowman outfit"
	desc = "Two white spheres covered in white glitter. 'Tis the season."
	icon_state = "snowman"
	item_state = "snowman"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	flags_inv = HIDEJUMPSUIT

/obj/item/clothing/suit/poncho
	name = "poncho"
	desc = "Your classic, non-racist poncho."
	icon_state = "classicponcho"
	item_state = "classicponcho"

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi'
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

/obj/item/clothing/suit/hooded/carp_costume
	name = "carp costume"
	desc = "A costume made from 'synthetic' carp scales, it smells."
	icon_state = "carp_casual"
	item_state = "labcoat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT	//Space carp like space, so you should too
	allowed = list(/obj/item/tank/internals/emergency_oxygen)
	hoodtype = /obj/item/clothing/head/hooded/carp_hood

/obj/item/clothing/head/hooded/carp_hood
	name = "carp hood"
	desc = "A hood attached to a carp costume."
	icon_state = "carp_casual"
	body_parts_covered = HEAD
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_HELM_MIN_TEMP_PROTECT
	flags = BLOCKHAIR
	flags_inv = HIDEEARS

/obj/item/clothing/suit/hooded/carp_costume/dragon
	name = "space carp poncho"
	desc = "A poncho fashioned from the scales of a corrupted space carp, it still smells."
	armor = list(MELEE = 30, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 15, RAD = 15, FIRE = INFINITY, ACID = INFINITY)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS|HANDS|FEET
	flags = STOPSPRESSUREDMAGE
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	hoodtype = /obj/item/clothing/head/hooded/carp_hood/dragon

/obj/item/clothing/suit/hooded/carp_costume/dragon/equipped(mob/user, slot, initial)
	. = ..()
	if(slot == SLOT_HUD_OUTER_SUIT)
		user.faction += "carp"
		to_chat(user, "<span class='cult'>You feel a something gnash in the back of your mind- the carp are your friends, not your foe.</span>")
		playsound(loc, 'sound/weapons/bite.ogg', 35, TRUE)

/obj/item/clothing/suit/hooded/carp_costume/dragon/dropped(mob/user)
	. = ..()
	if(user)
		user.faction -= "carp"
		to_chat(user, "<span class='cult'>A sudden calm fills the gnashing void of your mind- you're alone now.</span>")

/mob/living/carbon/human/Process_Spacemove(movement_dir = 0)
	if(..())
		return TRUE

	if(istype(wear_suit, /obj/item/clothing/suit/hooded/carp_costume/dragon))
		return TRUE
	//Do we have a working jetpack?
	var/obj/item/tank/jetpack/thrust
	if(istype(back, /obj/item/tank/jetpack))
		thrust = back
	else if(istype(wear_suit, /obj/item/clothing/suit/space/hardsuit))
		var/obj/item/clothing/suit/space/hardsuit/C = wear_suit
		thrust = C.jetpack
	else if(ismodcontrol(back))
		var/obj/item/mod/control/C = back
		thrust = locate(/obj/item/mod/module/jetpack) in C
	if(thrust)
		if((movement_dir || thrust.stabilizers) && thrust.allow_thrust(0.01, src))
			return TRUE
	if(dna.species.spec_Process_Spacemove(src))
		return TRUE
	return FALSE

/obj/item/clothing/head/hooded/carp_hood/dragon
	name = "space carp hood"
	desc = "Fashioned from the maw of a carp, this outfit makes you feel like a fish out of water."
	armor = list(MELEE = 55, BULLET = 15, LASER = 15, ENERGY = 15, BOMB = 15, RAD = 15, FIRE = INFINITY, ACID = INFINITY)
	flags = STOPSPRESSUREDMAGE
	min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT

/obj/item/clothing/suit/hooded/salmon_costume
	name = "salmon suit"
	desc = "A costume made from authentic salmon scales, it reeks!"
	icon_state = "salmon"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	allowed = list(/obj/item/fish/salmon, /obj/item/fish_eggs/salmon)
	hoodtype = /obj/item/clothing/head/hooded/salmon_hood

/obj/item/clothing/head/hooded/salmon_hood
	name = "salmon hood"
	desc = "A hood attached to a salmon suit."
	icon_state = "salmon"
	body_parts_covered = HEAD
	flags = BLOCKHAIR
	flags_inv = HIDEEARS

/// It's Hip!
/obj/item/clothing/suit/hooded/bee_costume
	name = "bee costume"
	desc = "Bee the true Queen!"
	icon_state = "bee"
	item_state = "labcoat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	flags = THICKMATERIAL
	hoodtype = /obj/item/clothing/head/hooded/bee_hood
	sprite_sheets = list("Vox" = 'icons/mob/clothing/species/vox/suit.dmi')

/obj/item/clothing/head/hooded/bee_hood
	name = "bee hood"
	desc = "A hood attached to a bee costume."
	icon_state = "bee"
	body_parts_covered = HEAD
	flags = THICKMATERIAL|BLOCKHAIR
	flags_inv = HIDEEARS
	sprite_sheets = list("Vox" = 'icons/mob/clothing/species/vox/head.dmi')

/// OH MY GOD WHAT HAVE YOU DONE!?!?!?
/obj/item/clothing/suit/bloated_human
	name = "bloated human suit"
	desc = "A horribly bloated suit made from human skins."
	icon_state = "lingspacesuit"
	item_state = "lingspacesuit"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/// Bleh!
/obj/item/clothing/suit/draculacoat
	name = "transylvanian coat"
	desc = "<i>What is a spessman? A miserable little pile of secrets.</i>"
	icon_state = "draculacoat"
	item_state = "draculacoat"

/*
 * Winter Coats
 */

/obj/item/clothing/suit/hooded/wintercoat
	name = "winter coat"
	desc = "A heavy jacket made from 'synthetic' animal furs."
	icon_state = "wintercoat"
	item_state = "coatwinter"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 0, ACID = 0)
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter)

	sprite_sheets = list("Vox" = 'icons/mob/clothing/species/vox/suit.dmi')

/obj/item/clothing/head/hooded/winterhood
	name = "winter hood"
	desc = "A hood attached to a heavy winter jacket."
	icon_state = "winterhood"
	body_parts_covered = HEAD
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	flags = BLOCKHAIR
	flags_inv = HIDEEARS

	sprite_sheets = list("Vox" = 'icons/mob/clothing/species/vox/head.dmi')

/obj/item/clothing/suit/pimpcoat
	name = "expensive coat"
	desc = "Very fluffy pink coat, made out of very expensive fur (clearly)."
	icon_state = "pimpcoat"
	item_state = "pimpcoat"
	blood_overlay_type = "armor"
	body_parts_covered = UPPER_TORSO|ARMS|LOWER_TORSO
	allowed = list(/obj/item/tank/internals/emergency_oxygen)
	cold_protection = UPPER_TORSO | LOWER_TORSO | ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

	sprite_sheets = list(
		"Grey" = 'icons/mob/clothing/species/grey/suit.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/suit.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi'
	)

/obj/item/clothing/suit/pimpcoat/white
	name = "fashionable coat"
	desc = "Very fluffy white coat, made out of quality synthetic fur."
	icon_state = "pimpcoat_white"
	item_state = "pimpcoat_white"

/obj/item/clothing/suit/pimpcoat/tan
	name = "coat of status"
	desc = "Very fluffy tan coat, made out of the finest fur from the Earth. Gifted to Quartermaster of Nanotrasen. Has additional layer of protection against harsh environment of Lavaland and a strap to hold equipment of Quartermaster."
	icon_state = "pimpcoat_tan"
	item_state = "pimpcoat_tan"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 10, RAD = 0, FIRE = 15, ACID = 50)
	allowed = list(/obj/item/paper, /obj/item/clipboard, /obj/item/gun/energy/kinetic_accelerator, /obj/item/melee/baton, /obj/item/flashlight/seclite, /obj/item/melee/classic_baton/telescopic, /obj/item/melee/knuckleduster, /obj/item/rcs)

/obj/item/clothing/suit/furcoat
	name = "fur coat"
	desc = "A trenchcoat made from fur. You could put an oxygen tank in one of the pockets."
	icon_state = "furcoat"
	item_state = "furcoat"
	blood_overlay_type = "armor"
	body_parts_covered = UPPER_TORSO|ARMS|LOWER_TORSO
	allowed = list(/obj/item/tank/internals/emergency_oxygen)
	cold_protection = UPPER_TORSO | LOWER_TORSO | ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/obj/item/clothing/suit/hooded/wintercoat/captain
	name = "captain's winter coat"
	icon_state = "wintercoat_captain"
	w_class = WEIGHT_CLASS_NORMAL
	item_state = "coatcaptain"
	armor = list(MELEE = 15, BULLET = 20, LASER = 20, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = 0, ACID = 50)
	allowed = list(/obj/item/gun/energy, /obj/item/reagent_containers/spray/pepper, /obj/item/gun/projectile, /obj/item/ammo_box,/obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/flashlight/seclite, /obj/item/melee/classic_baton/telescopic)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/captain

/obj/item/clothing/head/hooded/winterhood/captain
	icon_state = "winterhood_captain"

/obj/item/clothing/suit/hooded/wintercoat/security
	name = "security winter coat"
	icon_state = "wintercoat_sec"
	w_class = WEIGHT_CLASS_NORMAL
	item_state = "coatsecurity"
	armor = list(MELEE = 10, BULLET = 5, LASER = 10, ENERGY = 5, BOMB = 10, RAD = 0, FIRE = 20, ACID = 20)
	allowed = list(/obj/item/gun/energy, /obj/item/reagent_containers/spray/pepper, /obj/item/gun/projectile, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/flashlight/seclite, /obj/item/melee/classic_baton/telescopic)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/security
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/suit.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/suit.dmi'
		)

/obj/item/clothing/head/hooded/winterhood/security
	icon_state = "winterhood_sec"
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/head.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/head.dmi'
		)

/obj/item/clothing/suit/hooded/wintercoat/medical
	name = "medical winter coat"
	icon_state = "wintercoat_med"
	w_class = WEIGHT_CLASS_NORMAL
	item_state = "coatmedical"
	allowed = list(/obj/item/analyzer, /obj/item/dnainjector, /obj/item/reagent_containers/dropper, /obj/item/reagent_containers/syringe, /obj/item/reagent_containers/hypospray, /obj/item/reagent_containers/applicator,/obj/item/healthanalyzer,/obj/item/flashlight/pen, /obj/item/reagent_containers/glass/bottle, /obj/item/reagent_containers/glass/beaker, /obj/item/storage/pill_bottle, /obj/item/paper, /obj/item/melee/classic_baton/telescopic)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 0, ACID = 40)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/medical

/obj/item/clothing/head/hooded/winterhood/medical
	icon_state = "winterhood_med"

/obj/item/clothing/suit/hooded/wintercoat/science
	name = "science winter coat"
	icon_state = "wintercoat_sci"
	w_class = WEIGHT_CLASS_NORMAL
	item_state = "coatscience"
	allowed = list(/obj/item/analyzer, /obj/item/stack/medical, /obj/item/dnainjector, /obj/item/reagent_containers/dropper, /obj/item/reagent_containers/syringe, /obj/item/reagent_containers/hypospray, /obj/item/reagent_containers/applicator,/obj/item/healthanalyzer,/obj/item/flashlight/pen, /obj/item/reagent_containers/glass/bottle, /obj/item/reagent_containers/glass/beaker, /obj/item/storage/pill_bottle, /obj/item/paper, /obj/item/melee/classic_baton/telescopic)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 5, RAD = 0, FIRE = 0, ACID = 0)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/science

/obj/item/clothing/head/hooded/winterhood/science
	icon_state = "winterhood_sci"

/obj/item/clothing/suit/hooded/wintercoat/engineering
	name = "engineering winter coat"
	icon_state = "wintercoat_engi"
	w_class = WEIGHT_CLASS_NORMAL
	item_state = "coatengineer"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 10, FIRE = 20, ACID = 40)
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/t_scanner, /obj/item/rcd, /obj/item/rpd)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/engineering

/obj/item/clothing/head/hooded/winterhood/engineering
	icon_state = "winterhood_engi"

/obj/item/clothing/suit/hooded/wintercoat/engineering/atmos
	name = "atmospherics winter coat"
	icon_state = "wintercoat_atmos"
	item_state = "coatatmos"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/engineering/atmos

/obj/item/clothing/head/hooded/winterhood/engineering/atmos
	icon_state = "winterhood_atmos"

/obj/item/clothing/suit/hooded/wintercoat/hydro
	name = "hydroponics winter coat"
	icon_state = "wintercoat_hydro"
	item_state = "coathydro"
	allowed = list(/obj/item/reagent_containers/spray, /obj/item/plant_analyzer, /obj/item/seeds, /obj/item/reagent_containers/glass/bottle, /obj/item/hatchet, /obj/item/storage/bag/plants)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/hydro

/obj/item/clothing/head/hooded/winterhood/hydro
	icon_state = "winterhood_hydro"

/obj/item/clothing/suit/hooded/wintercoat/cargo
	name = "cargo winter coat"
	icon_state = "wintercoat_cargo"
	item_state = "coatcargo"
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter, /obj/item/rcs, /obj/item/clipboard, /obj/item/envelope, /obj/item/storage/bag/mail, /obj/item/mail_scanner)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/cargo

/obj/item/clothing/head/hooded/winterhood/cargo
	icon_state = "winterhood_cargo"

/obj/item/clothing/suit/hooded/wintercoat/miner
	name = "mining winter coat"
	icon_state = "wintercoat_miner"
	w_class = WEIGHT_CLASS_NORMAL
	item_state = "coatminer"
	allowed = list(/obj/item/pickaxe, /obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter, /obj/item/t_scanner/adv_mining_scanner, /obj/item/storage/bag/ore, /obj/item/gun/energy/kinetic_accelerator)
	armor = list(MELEE = 5, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 0, ACID = 0)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/miner

/obj/item/clothing/head/hooded/winterhood/miner
	icon_state = "winterhood_miner"

/obj/item/clothing/head/hooded/ablative
	name = "ablative hood"
	desc = "Hood hopefully belonging to an ablative trenchcoat. Includes a flash proof visor."
	icon_state = "ablativehood"
	flash_protect = FLASH_PROTECTION_FLASH
	flags = BLOCKHAIR
	armor = list(MELEE = 5, BULLET = 5, LASER = 50, ENERGY = 50, BOMB = 0, RAD = 0, FIRE = INFINITY, ACID = INFINITY)
	strip_delay = 3 SECONDS
	sprite_sheets = list("Vox" = 'icons/mob/clothing/species/vox/head.dmi',
						"Grey" = 'icons/mob/clothing/species/grey/head.dmi')

/obj/item/clothing/suit/hooded/ablative
	name = "ablative trenchcoat"
	desc = "Experimental trenchcoat specially crafted to reflect and absorb laser and disabler shots. Don't expect it to do all that much against an axe or a shotgun, however."
	icon_state = "ablativecoat"
	w_class = WEIGHT_CLASS_NORMAL
	item_state = "ablativecoat"
	body_parts_covered = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	heat_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	allowed = list(/obj/item/gun/energy, /obj/item/reagent_containers/spray/pepper, /obj/item/gun/projectile, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/flashlight/seclite, /obj/item/melee/classic_baton/telescopic, /obj/item/kitchen/knife/combat)
	armor = list(MELEE = 5, BULLET = 5, LASER = 50, ENERGY = 50, BOMB = 0, RAD = 0, FIRE = INFINITY, ACID = INFINITY)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	hoodtype = /obj/item/clothing/head/hooded/ablative
	strip_delay = 3 SECONDS
	put_on_delay = 4 SECONDS
	sprite_sheets = list("Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
						"Grey" = 'icons/mob/clothing/species/grey/suit.dmi')
	var/last_reflect_time
	var/reflect_cooldown = 4 SECONDS

/obj/item/clothing/suit/hooded/ablative/IsReflect()
	var/mob/living/carbon/human/user = loc
	if(user.wear_suit != src)
		return 0
	if(world.time - last_reflect_time >= reflect_cooldown)
		last_reflect_time = world.time
		return 1
	if(world.time - last_reflect_time <= 1) // This is so if multiple energy projectiles hit at once, they're all reflected
		return 1
	return 0

/*
 * Misc
 */

//hoodies
/obj/item/clothing/suit/hooded/hoodie
	name = "black hoodie"
	desc = "It's a hoodie. It has a hood. Most hoodies do."
	icon_state = "black_hoodie"
	item_state = "blueshieldcoat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen)
	hoodtype = /obj/item/clothing/head/hooded/hood
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi'
		)

/obj/item/clothing/head/hooded/hood
	name = "black hood"
	desc = "A hood attached to a hoodie."
	icon_state = "blackhood"
	body_parts_covered = HEAD
	cold_protection = HEAD
	flags = BLOCKHAIR
	flags_inv = HIDEEARS

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi'
		)

/obj/item/clothing/head/hooded/hood/blue
	icon_state = "bluehood"

/obj/item/clothing/head/hooded/hood/white
	icon_state = "whitehood"

/obj/item/clothing/suit/hooded/hoodie/blue
	name = "blue hoodie"
	icon_state = "blue_hoodie"
	hoodtype = /obj/item/clothing/head/hooded/hood/blue

/obj/item/clothing/suit/hooded/hoodie/mit
	name = "Martian Institute of Technology hoodie"
	desc = "A hoodie proudly worn by students and graduates alike, has the letters 'MIT' on the back."
	icon_state = "mit_hoodie"
	hoodtype = /obj/item/clothing/head/hooded/hood

/obj/item/clothing/suit/hooded/hoodie/cut
	name = "Canaan University of Technology hoodie"
	desc = "A bright hoodie with the Canaan University of Technology logo on the front."
	icon_state = "cut_hoodie"
	hoodtype = /obj/item/clothing/head/hooded/hood/white

/obj/item/clothing/suit/hooded/hoodie/lam
	name = "Lunar Academy of Medicine hoodie"
	desc = "A bright hoodie with the Lunar Academy of Medicine logo on the back."
	icon_state = "lam_hoodie"
	hoodtype = /obj/item/clothing/head/hooded/hood/white

/obj/item/clothing/suit/hooded/hoodie/nt
	name = "Nanotrasen hoodie"
	desc = "A blue hoodie with the Nanotrasen logo on the back."
	icon_state = "nt_hoodie"
	hoodtype = /obj/item/clothing/head/hooded/hood/blue

/obj/item/clothing/suit/hooded/hoodie/tp
	name = "Tharsis Polytech hoodie"
	desc = "A dark hoodie with the Tharsis Polytech logo on the back."
	icon_state = "tp_hoodie"
	hoodtype = /obj/item/clothing/head/hooded/hood

/obj/item/clothing/suit/straight_jacket
	name = "straight jacket"
	desc = "A suit that completely restrains the wearer."
	icon_state = "straight_jacket"
	item_state = "straight_jacket"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS|HANDS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT|HIDETAIL
	strip_delay = 60
	breakouttime = 3000

/obj/item/clothing/suit/straight_jacket/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(slot == SLOT_HUD_OUTER_SUIT)
		ADD_TRAIT(user, TRAIT_RESTRAINED, "straight_jacket")

/obj/item/clothing/suit/straight_jacket/dropped(mob/user, silent)
	. = ..()
	REMOVE_TRAIT(user, TRAIT_RESTRAINED, "straight_jacket")

/obj/item/clothing/suit/ianshirt
	name = "worn shirt"
	desc = "A worn out, curiously comfortable t-shirt with a picture of Ian. You wouldn't go so far as to say it feels like being hugged when you wear it but it's pretty close. Good for sleeping in."
	icon_state = "ianshirt"
	item_state = "ianshirt"

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi'
		)

//coats

/obj/item/clothing/suit/leathercoat
	name = "leather coat"
	desc = "A long, thick black leather coat."
	icon_state = "leathercoat"
	item_state = "leathercoat"
	resistance_flags = FIRE_PROOF

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
	icon_state = "brtrenchcoat_open"
	item_state = "brtrenchcoat_open"
	ignore_suitadjust = FALSE
	suit_adjusted = TRUE
	actions_types = list(/datum/action/item_action/button)
	adjust_flavour = "unbutton"

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi'
		)

/obj/item/clothing/suit/blacktrenchcoat
	name = "black trench coat"
	desc = "That shade of black just makes you look a bit more evil. Good for those mafia types."
	icon_state = "bltrenchcoat_open"
	item_state = "bltrenchcoat_open"
	ignore_suitadjust = FALSE
	suit_adjusted = TRUE
	actions_types = list(/datum/action/item_action/button)
	adjust_flavour = "unbutton"

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi'
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

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi'
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

/obj/item/clothing/suit/jacket/miljacket
	name = "olive military jacket"
	desc = "A canvas jacket styled after classical American military garb. Feels sturdy, yet comfortable. This one comes in olive."
	icon_state = "militaryjacket"
	item_state = "militaryjacket"
	ignore_suitadjust = 1
	actions_types = list()
	adjust_flavour = null
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/toy,/obj/item/storage/fancy/cigarettes, /obj/item/lighter, /obj/item/gun/projectile/automatic/pistol, /obj/item/gun/projectile/revolver, /obj/item/gun/energy/detective)
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi'
	)

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
	name = "xeno suit"
	desc = "A suit made out of chitinous alien hide."
	icon_state = "xenos"
	item_state = "xenos_helm"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS|HANDS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT

/obj/item/clothing/suit/storage/mercy_hoodie
	name = "mercy robe"
	desc = "A soft white robe made of a synthetic fiber that provides improved protection against biohazards. Possessing multiple overlapping layers, yet light enough to allow complete freedom of movement, it denotes its wearer as a master physician."
	icon_state = "mercy_hoodie"
	item_state = "mercy_hoodie"
	w_class = WEIGHT_CLASS_BULKY
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/tank/internals/emergency_oxygen,/obj/item/pen,/obj/item/flashlight/pen)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 10, FIRE = 50, ACID = 50)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT|HIDETAIL

/obj/item/clothing/head/mercy_hood
	name = "mercy Hood"
	desc = "A soft white hood made of a synthetic fiber that provides improved protection against biohazards. Its elegant design allows a clear field of vision."
	icon_state = "mercy_hood"
	item_state = "mercy_hood"
	permeability_coefficient = 0.01
	flags = BLOCKHAIR
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 10, FIRE = 50, ACID = 50)
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES

//Basic jacket and subtypes
/obj/item/clothing/suit/greatcoat/sec
	name = "security greatcoat"
	desc = "A wool-lined coat made from rugged materials that altogether make up to be a comfortable coat.\ GLORY TO ARSTOSKHA!!"
	icon_state = "secgreatcoat"
	item_state = "secgreatcoat"
	w_class = WEIGHT_CLASS_NORMAL
	ignore_suitadjust = TRUE
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS
	heat_protection = UPPER_TORSO|LOWER_TORSO|ARMS
	//Inherited from Security armour.
	allowed = list(/obj/item/gun/energy,/obj/item/reagent_containers/spray/pepper,/obj/item/gun/projectile,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/melee/baton,/obj/item/restraints/handcuffs,/obj/item/flashlight/seclite,/obj/item/melee/classic_baton/telescopic,/obj/item/kitchen/knife/combat)
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	strip_delay = 60
	put_on_delay = 40
	//End of inheritance from Security armour.
	armor = list(MELEE = 10, BULLET = 5, LASER = 10, ENERGY = 5, BOMB = 10, RAD = 0, FIRE = 20, ACID = 20)
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/suit.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/suit.dmi'
	)

/obj/item/clothing/suit/jacket
	name = "jacket"
	desc = "Basic jacket item, should not be seen in game."
	ignore_suitadjust = FALSE
	allowed = list(/obj/item/flashlight,/obj/item/tank/internals/emergency_oxygen,/obj/item/toy,/obj/item/storage/fancy/cigarettes,/obj/item/lighter)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	actions_types = list(/datum/action/item_action/zipper)
	adjust_flavour = "unzip"

/obj/item/clothing/suit/jacket/varsity
	name = "varsity jacket"
	desc = "Stylish jacket for young and invincible."
	icon_state = "varsity_classic"
	item_state = "varsity_classic"

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/suit.dmi'
	)

/obj/item/clothing/suit/jacket/varsity_sport
	name = "sport varsity jacket"
	desc = "Stylish jacket for fast and furious."
	icon_state = "varsity_sport"
	item_state = "varsity_sport"

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/suit.dmi'
	)

/obj/item/clothing/suit/jacket/varsity_blood
	name = "blood varsity jacket"
	desc = "Stylish jacket for dangerous and violent."
	icon_state = "varsity_blood"
	item_state = "varsity_blood"

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/suit.dmi'
	)

/obj/item/clothing/suit/jacket/driver
	name = "driver jacket"
	desc = "Whoever wears such jacket is literally me."
	icon_state = "driver_jacket"
	item_state = "driver_jacket"

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/suit.dmi'
	)

/obj/item/clothing/suit/jacket/leather
	name = "leather jacket"
	desc = "Pompadour not included."
	icon_state = "leatherjacket"
	ignore_suitadjust = 1
	actions_types = list()
	adjust_flavour = null
	resistance_flags = NONE
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi'
	)

/obj/item/clothing/suit/jacket/motojacket
	name = "leather motorcycle jacket"
	desc = "A vintage classic, loved by rockers, rebels, and punks alike."
	icon_state = "motojacket_open"
	item_state = "motojacket_open"
	ignore_suitadjust = FALSE
	suit_adjusted = TRUE
	actions_types = list(/datum/action/item_action/zipper)
	adjust_flavour = "unzip"

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/suit.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/suit.dmi'
		)

/obj/item/clothing/suit/jacket/leather/overcoat
	name = "leather overcoat"
	desc = "That's a damn fine coat."
	icon_state = "leathercoat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	cold_protection = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi'
	)

//Bomber jackets
/obj/item/clothing/suit/jacket/bomber
	name = "bomber jacket"
	desc = "Aviators not included."
	icon = 'icons/obj/clothing/suits/coat.dmi'
	icon_state = "bomber"
	item_state = "bomber"
	icon_override = 'icons/mob/clothing/suits/coat.dmi'
	ignore_suitadjust = FALSE
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter)
	body_parts_covered = UPPER_TORSO | LOWER_TORSO | ARMS
	cold_protection = UPPER_TORSO | LOWER_TORSO | ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	actions_types = list(/datum/action/item_action/zipper)
	adjust_flavour = "unzip"

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suits/coat.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/suits/coat.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/suits/coat.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/suits/coat.dmi'
		)

/obj/item/clothing/suit/jacket/bomber/syndicate
	name = "suspicious bomber jacket"
	desc = "A suspicious but extremely stylish jacket."
	icon_state = "bombersyndie"
	item_state = "bombersyndie"
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter, /obj/item/gun, /obj/item/melee/classic_baton/telescopic/contractor, /obj/item/kitchen/knife/combat)
	armor = list(MELEE = 5, BULLET = 5, LASER = 5, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 30, ACID = 30)

/obj/item/clothing/suit/jacket/bomber/sec
	name = "security bomber jacket"
	desc = "A stylish and worn-in armoured black bomber jacket emblazoned with a red stripe across the left. Looks rugged."
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "bombersec"
	item_state = "bombersec"
	//Inherited from Security armour.
	allowed = list(/obj/item/gun/energy,/obj/item/reagent_containers/spray/pepper,/obj/item/gun/projectile,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/melee/baton,/obj/item/restraints/handcuffs,/obj/item/flashlight/seclite,/obj/item/melee/classic_baton/telescopic,/obj/item/kitchen/knife/combat)
	heat_protection = UPPER_TORSO|LOWER_TORSO
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	strip_delay = 60
	put_on_delay = 40
	armor = list(MELEE = 10, BULLET = 5, LASER = 10, ENERGY = 5, BOMB = 10, RAD = 0, FIRE = 20, ACID = 20)
	//End of inheritance from Security armour.

/obj/item/clothing/suit/jacket/bomber/engi
	name = "engineering bomber jacket"
	desc = "A stylish and warm jacket adorned with the colors of the humble Station Engineer."
	icon_state = "bomberengi"
	item_state = "bomberengi"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 10, FIRE = 20, ACID = 40)
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/t_scanner, /obj/item/rcd, /obj/item/rpd)

/obj/item/clothing/suit/jacket/bomber/atmos
	name = "atmospherics bomber jacket"
	desc = "A stylish and warm jacket adorned with the colors of the magical Atmospherics Technician."
	icon_state = "bomberatmos"
	item_state = "bomberatmos"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 10, FIRE = 20, ACID = 40)
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/t_scanner, /obj/item/rcd, /obj/item/rpd)

/obj/item/clothing/suit/jacket/bomber/cargo
	name = "cargo bomber jacket"
	desc = "A stylish jacket to keep you warm in the warehouse."
	icon_state = "bombercargo"
	item_state = "bombercargo"
	allowed = list(/obj/item/rcs, /obj/item/clipboard, /obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/toy, /obj/item/lighter, /obj/item/storage/fancy/cigarettes, /obj/item/storage/bag/mail, /obj/item/envelope)

/obj/item/clothing/suit/jacket/bomber/mining
	name = "mining bomber jacket"
	desc = "A slightly armoured and stylish jacket for shaft miners."
	icon_state = "bombermining"
	item_state = "bombermining"
	allowed = list(/obj/item/pickaxe, /obj/item/t_scanner/adv_mining_scanner, /obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter, /obj/item/gun/energy/kinetic_accelerator, /obj/item/shovel, /obj/item/storage/bag/ore)
	armor = list(MELEE = 5, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/suit/jacket/bomber/expedition
	name = "expedition bomber jacket"
	desc = "A stylish jacket for station-side explorers. Won't do much to protect you from space."
	icon_state = "bomberexpedition"
	item_state = "bomberexpedition"
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter, /obj/item/gun/energy/kinetic_accelerator, /obj/item/t_scanner/adv_mining_scanner, /obj/item/shovel, /obj/item/pickaxe, /obj/item/storage/bag/ore, /obj/item/gps)

/obj/item/clothing/suit/jacket/bomber/hydro
	name = "hydroponics bomber jacket"
	desc = "A stylish choice for the workers of the hydroponics lab."
	icon_state = "bomberhydro"
	item_state = "bomberhydro"
	allowed = list(/obj/item/reagent_containers/spray, /obj/item/plant_analyzer, /obj/item/seeds, /obj/item/reagent_containers/glass/bottle, /obj/item/hatchet, /obj/item/storage/bag/plants)

/obj/item/clothing/suit/jacket/bomber/med
	name = "medical bomber jacket"
	desc = "A stain-resistant and stylish option for any member of the medical department."
	icon_state = "bombermed"
	item_state = "bombermed"
	allowed = list(/obj/item/bodyanalyzer, /obj/item/analyzer, /obj/item/dnainjector, /obj/item/reagent_containers/dropper, /obj/item/reagent_containers/syringe, /obj/item/reagent_containers/hypospray, /obj/item/reagent_containers/applicator, /obj/item/healthanalyzer, /obj/item/flashlight/pen, /obj/item/reagent_containers/glass/bottle, /obj/item/reagent_containers/glass/beaker, /obj/item/storage/pill_bottle, /obj/item/paper)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 5, FIRE = 0, ACID = 20)

/obj/item/clothing/suit/jacket/bomber/chem
	name = "chemistry bomber jacket"
	desc = "An exclusive and stylish variant of the medical bomber, for chemists only."
	icon_state = "bomberchem"
	item_state = "bomberchem"
	allowed = list(/obj/item/reagent_scanner, /obj/item/reagent_scanner/adv, /obj/item/analyzer, /obj/item/dnainjector, /obj/item/reagent_containers/dropper, /obj/item/reagent_containers/syringe, /obj/item/reagent_containers/hypospray, /obj/item/reagent_containers/applicator, /obj/item/healthanalyzer, /obj/item/flashlight/pen, /obj/item/reagent_containers/glass/bottle, /obj/item/reagent_containers/glass/beaker, /obj/item/storage/pill_bottle, /obj/item/paper)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 5, RAD = 0, FIRE = 0, ACID = 40)

/obj/item/clothing/suit/jacket/bomber/coroner
	name = "coroner's bomber jacket"
	desc = "An extremely exclusive and stylish jacket. Coroner's use only!"
	icon_state = "bombercoroner"
	item_state = "bombercoroner"
	allowed = list(/obj/item/autopsy_scanner, /obj/item/analyzer, /obj/item/dnainjector, /obj/item/reagent_containers/dropper, /obj/item/reagent_containers/syringe, /obj/item/reagent_containers/hypospray, /obj/item/reagent_containers/applicator, /obj/item/healthanalyzer, /obj/item/flashlight/pen, /obj/item/reagent_containers/glass/bottle, /obj/item/reagent_containers/glass/beaker, /obj/item/storage/pill_bottle, /obj/item/paper)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 5, FIRE = 0, ACID = 20)

/obj/item/clothing/suit/jacket/bomber/sci
	name = "science bomber jacket"
	desc = "A stylish and slightly bomb-resistant jacket for warmth within the sterile labs."
	icon_state = "bombersci"
	item_state = "bombersci"
	allowed = list(/obj/item/slime_scanner, /obj/item/reagent_scanner/adv, /obj/item/reagent_scanner, /obj/item/analyzer, /obj/item/stack/medical, /obj/item/dnainjector, /obj/item/reagent_containers/dropper, /obj/item/reagent_containers/syringe, /obj/item/reagent_containers/hypospray, /obj/item/reagent_containers/applicator, /obj/item/healthanalyzer, /obj/item/flashlight/pen, /obj/item/reagent_containers/glass/bottle, /obj/item/reagent_containers/glass/beaker, /obj/item/storage/pill_bottle, /obj/item/paper)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 5, RAD = 0, FIRE = 0, ACID = 20)

/obj/item/clothing/suit/jacket/bomber/robo
	name = "robotics bomber jacket"
	desc = "A stylish jacket to warm you up after handling cold robotic limbs."
	icon_state = "bomberrobo"
	item_state = "bomberrobo"
	allowed = list(/obj/item/robotanalyzer, /obj/item/analyzer, /obj/item/stack/medical, /obj/item/dnainjector, /obj/item/reagent_containers/dropper, /obj/item/reagent_containers/syringe, /obj/item/reagent_containers/hypospray, /obj/item/reagent_containers/applicator, /obj/item/healthanalyzer, /obj/item/flashlight/pen, /obj/item/reagent_containers/glass/bottle, /obj/item/reagent_containers/glass/beaker, /obj/item/storage/pill_bottle, /obj/item/paper)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 5, RAD = 0, FIRE = 0, ACID = 20)

//End of bombers
/obj/item/clothing/suit/officercoat
	name = "clown officer's coat"
	desc = "An overcoat for the clown officer, to keep him warm during those cold winter nights on the front."
	icon_state = "officersuit"
	item_state = "officersuit"
	ignore_suitadjust = 0
	actions_types = list(/datum/action/item_action/button)
	adjust_flavour = "unbutton"

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi'
		)

/obj/item/clothing/suit/soldiercoat
	name = "clown soldier's coat"
	desc = "An overcoat for the clown soldier, to keep him warm during those cold winter nights on the front."
	icon_state = "soldiersuit"
	item_state = "soldiersuit"
	ignore_suitadjust = 0
	actions_types = list(/datum/action/item_action/button)
	adjust_flavour = "unbutton"

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi'
		)

/obj/item/clothing/suit/sovietcoat
	name = "\improper Soviet greatcoat"
	desc = "A military overcoat made of rough wool that is thick enough to provide excellent protection against the elements."
	icon_state = "sovietcoat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	armor = list(MELEE = 15, BULLET = 15, LASER = 15, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = 30, ACID = 30)
	cold_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	allowed = list(/obj/item/flashlight, /obj/item/gun/energy, /obj/item/gun/projectile, /obj/item/ammo_box)

/obj/item/clothing/suit/sovietcoat/officer
	name = "\improper Soviet officer's greatcoat"
	desc = "A military overcoat made with expensive wool. The U.S.S.P armband means it must belong to someone important."
	icon_state = "sovietofficercoat"
	armor = list(MELEE = 25, BULLET = 25, LASER = 25, ENERGY = 10, BOMB = 20, RAD = 0, FIRE = 30, ACID = 30)

/obj/item/clothing/suit/toggle/owlwings
	name = "owl cloak"
	desc = "A soft brown cloak made of synthetic feathers. Soft to the touch, stylish, and a 2 meter wing span that will drive the ladies mad."
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "owl_wings"
	item_state = "owl_wings"
	body_parts_covered = ARMS
	armor = list(MELEE = 5, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 15, ACID = 15)
	allowed = list(/obj/item/gun/energy,/obj/item/reagent_containers/spray/pepper,/obj/item/gun/projectile,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/melee/baton,/obj/item/restraints/handcuffs,/obj/item/flashlight/seclite)
	actions_types = list(/datum/action/item_action/toggle_wings)


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
		A.UpdateButtons()

/obj/item/clothing/suit/lordadmiral
	name = "lord admiral's coat"
	desc = "You'll be the Ruler of the King's Navy in no time."
	icon_state = "lordadmiral"
	item_state = "lordadmiral"
	allowed = list (/obj/item/gun)

/obj/item/clothing/suit/fluff/noble_coat
	name = "noble coat"
	desc = "The livid blues, purples and greens are awesome enough to evoke a visceral response in you; it is not dissimilar to indigestion."
	icon_state = "noble_coat"
	item_state = "noble_coat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS


///Advanced Protective Suit, AKA, God Mode in wearable form.

/obj/item/clothing/suit/advanced_protective_suit
	name = "advanced protective suit"
	desc = "An incredibly advanced and complex suit; it has so many buttons and dials as to be incomprehensible."
	w_class = WEIGHT_CLASS_BULKY
	icon_state = "bomb"
	item_state = "bomb"
	actions_types = list(/datum/action/item_action/toggle)
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	flags = STOPSPRESSUREDMAGE | THICKMATERIAL | NODROP
	flags_2 = RAD_PROTECT_CONTENTS_2
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS|HEAD
	armor = list(MELEE = INFINITY, BULLET = INFINITY, LASER = INFINITY, ENERGY = INFINITY, BOMB = INFINITY, RAD = INFINITY, FIRE = INFINITY, ACID = INFINITY)
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS | HEAD
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	heat_protection = UPPER_TORSO | LOWER_TORSO|LEGS|FEET|ARMS|HANDS | HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	slowdown = -10
	siemens_coefficient = 0
	var/on = FALSE

/obj/item/clothing/suit/advanced_protective_suit/Destroy()
	if(on)
		on = FALSE
		STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/suit/advanced_protective_suit/ui_action_click()
	if(on)
		on = FALSE
		to_chat(usr, "You turn the suit's special processes off.")
	else
		on = TRUE
		to_chat(usr, "You turn the suit's special processes on.")
		START_PROCESSING(SSobj, src)


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
		STOP_PROCESSING(SSobj, src)

//Syndicate Chaplain Robe (WOLOLO!)
/obj/item/clothing/suit/hooded/chaplain_hoodie/missionary_robe
	w_class = WEIGHT_CLASS_NORMAL
	armor = list(MELEE = 5, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 0, RAD = 10, FIRE = 20, ACID = 20)
	var/obj/item/nullrod/missionary_staff/linked_staff = null

/obj/item/clothing/suit/hooded/chaplain_hoodie/missionary_robe/examine(mob/user)
	. = ..()
	if(isAntag(user))
		. += "<span class='warning'>This robe is made of totally reinforced fibers, granting it 100% not superficial protection. More importantly the robes also wirelessly generate power for the neurotransmitter in the linked missionary staff while being worn.</span>"

/obj/item/clothing/suit/hooded/chaplain_hoodie/missionary_robe/Destroy()
	if(linked_staff)	//delink on destruction
		linked_staff.robes = null
		linked_staff = null
	STOP_PROCESSING(SSobj, src)	//probably is cleared in a parent call already, but just in case we're gonna do it here
	return ..()

/obj/item/clothing/suit/hooded/chaplain_hoodie/missionary_robe/equipped(mob/living/carbon/human/H, slot)
	if(!istype(H) || slot != SLOT_HUD_OUTER_SUIT)
		STOP_PROCESSING(SSobj, src)
		return
	else
		START_PROCESSING(SSobj, src)

/obj/item/clothing/suit/hooded/chaplain_hoodie/missionary_robe/process()
	if(!linked_staff)	//if we don't have a linked staff, the rest of this is useless
		return

	if(!ishuman(loc))		//if we somehow try to process while not on a human, remove ourselves from processing and return
		STOP_PROCESSING(SSobj, src)
		return

	var/mob/living/carbon/human/H = loc

	if(linked_staff.faith >= 100)	//if the linked staff is fully recharged, do nothing
		return

	// Do not allow the staff to recharge if it's more than 3 tiles away from the robe. If get_dist returns 0, the robe and the staff in the same tile.
	if(!(get_dist(H, linked_staff) <= 3))
		if(prob(10))	//10% chance per process should avoid being too spammy, can tweak if it ends up still being too frequent.
			to_chat(H, "<span class='warning'>Your staff is unable to charge at this range. Get closer!</span>")
		return

	linked_staff.faith += 5
	if(linked_staff.faith >= 100)	//if this charge puts the staff at or above full, notify the wearer
		to_chat(H, "<span class='notice'>Faith renewed; ready to convert new followers.</span>")

/obj/item/clothing/suit/tailcoat
	name = "victorian tailcoat"
	desc = "A fancy victorian tailcoat."
	icon_state = "tailcoat"
	item_state = "tailcoat"

/obj/item/clothing/suit/victcoat
	name = "ladies victorian coat"
	desc = "A fancy victorian coat."
	icon_state = "ladiesvictoriancoat"
	item_state = "ladiesvictoriancoat"

/obj/item/clothing/suit/victcoat/red
	name = "ladies red victorian coat"
	icon_state = "ladiesredvictoriancoat"
	item_state = "ladiesredvictoriancoat"

//Mantles!
/obj/item/clothing/suit/mantle
	name = "mantle"
	desc = "A heavy quilted mantle, for keeping your shoulders warm and stylish."
	icon_state = "mantle"
	item_state = "mantle"
	body_parts_covered = UPPER_TORSO|ARMS
	cold_protection = UPPER_TORSO|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/obj/item/clothing/suit/mantle/regal
	name = "regal shawl"
	desc = "A fancy shawl for nobility, made from high quality materials."
	icon_state = "regal_mantle"
	item_state = "regal_mantle"

/obj/item/clothing/suit/mantle/old
	name = "old wrap"
	desc = "A tattered fabric wrap, faded over the years. Smells faintly of cigars."
	icon_state = "old_mantle"
	item_state = "old_mantle"

/obj/item/clothing/suit/ghost_sheet
	name = "ghost sheet"
	desc = "The hands float by themselves, so it's extra spooky."
	icon_state = "ghost_sheet"
	item_state = "ghost_sheet"
	throwforce = 0
	throw_speed = 1
	throw_range = 2
	w_class = WEIGHT_CLASS_TINY
	flags = BLOCKHAIR
	flags_inv = HIDEGLOVES|HIDEEARS|HIDEFACE

/obj/item/clothing/suit/furcape
	name = "fur cape"
	desc = "A cape made from fur. You'll really be stylin' now."
	icon_state = "furcape"
	item_state = "furcape"
	blood_overlay_type = "armor"
	body_parts_covered = UPPER_TORSO|ARMS
	cold_protection = UPPER_TORSO | ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/obj/item/clothing/suit/hooded/abaya
	name = "abaya"
	desc = "A modest, unrevealing attire fitted with a veil."
	icon_state = "abaya"
	item_state = "abaya"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	allowed = list(/obj/item/storage/bible, /obj/item/nullrod, /obj/item/reagent_containers/drinks/bottle/holywater, /obj/item/storage/fancy/candle_box, /obj/item/candle, /obj/item/tank/internals/emergency_oxygen)
	hoodtype = /obj/item/clothing/head/hooded/screened_niqab
	flags_inv = HIDEJUMPSUIT
	var/list/options = list(
		"Abaya" = /obj/item/clothing/suit/hooded/abaya,
		"Red Abaya" = /obj/item/clothing/suit/hooded/abaya/red,
		"Orange Abaya" = /obj/item/clothing/suit/hooded/abaya/orange,
		"Yellow Abaya" = /obj/item/clothing/suit/hooded/abaya/yellow,
		"Green Abaya" = /obj/item/clothing/suit/hooded/abaya/green,
		"Blue Abaya" = /obj/item/clothing/suit/hooded/abaya/blue,
		"Purple Abaya" = /obj/item/clothing/suit/hooded/abaya/purple,
		"White Abaya" = /obj/item/clothing/suit/hooded/abaya/white,
		"Rainbow Abaya" = /obj/item/clothing/suit/hooded/abaya/rainbow
	)

	sprite_sheets = list(
	"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
	"Grey" = 'icons/mob/clothing/species/grey/suit.dmi',
	"Drask" = 'icons/mob/clothing/species/drask/suit.dmi',
	"Kidan" = 'icons/mob/clothing/species/kidan/suit.dmi'
	)

/obj/item/clothing/suit/hooded/abaya/proc/reskin_abaya(mob/living/L)
	var/choice = input(L, "You may only change the color once.", "Reskin Abaya") in options

	if(!options[choice] || HAS_TRAIT(L, TRAIT_HANDS_BLOCKED) || !in_range(L, src))
		return
	var/abaya_type = options[choice]
	var/obj/item/clothing/suit/hooded/abaya/abaya = new abaya_type(get_turf(src))
	L.unEquip(src, silent = TRUE)
	L.put_in_active_hand(abaya)
	to_chat(L, "<span class='notice'>You are now wearing \a [choice]. Allahu Akbar!</span>")
	qdel(src)

/obj/item/clothing/suit/hooded/abaya/attack_self(mob/user)
	. = ..()
	reskin_abaya(user)

/obj/item/clothing/suit/hooded/abaya/red
	name = "red abaya"
	icon_state = "redabaya"
	hoodtype = /obj/item/clothing/head/hooded/screened_niqab/red

/obj/item/clothing/suit/hooded/abaya/orange
	name = "orange abaya"
	icon_state = "orangeabaya"
	hoodtype = /obj/item/clothing/head/hooded/screened_niqab/orange

/obj/item/clothing/suit/hooded/abaya/yellow
	name = "yellow abaya"
	icon_state = "yellowabaya"
	hoodtype = /obj/item/clothing/head/hooded/screened_niqab/yellow

/obj/item/clothing/suit/hooded/abaya/green
	name = "green abaya"
	icon_state = "greenabaya"
	hoodtype = /obj/item/clothing/head/hooded/screened_niqab/green

/obj/item/clothing/suit/hooded/abaya/blue
	name = "blue abaya"
	icon_state = "blueabaya"
	hoodtype = /obj/item/clothing/head/hooded/screened_niqab/blue

/obj/item/clothing/suit/hooded/abaya/purple
	name = "purple abaya"
	icon_state = "purpleabaya"
	hoodtype = /obj/item/clothing/head/hooded/screened_niqab/purple

/obj/item/clothing/suit/hooded/abaya/white
	name = "white abaya"
	icon_state = "whiteabaya"
	hoodtype = /obj/item/clothing/head/hooded/screened_niqab/white

/obj/item/clothing/suit/hooded/abaya/rainbow
	name = "rainbow abaya"
	icon_state = "rainbowabaya"
	hoodtype = /obj/item/clothing/head/hooded/screened_niqab/rainbow
