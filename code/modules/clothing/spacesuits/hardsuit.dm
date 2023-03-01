//Baseline hardsuits
/obj/item/clothing/head/helmet/space/hardsuit
	name = "hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment."
    //alt_desc =
	icon_state = "hardsuit0-engineering"
	item_state = "eng_helm"
	armor = list("melee" = 10, "bullet" = 5, "laser" = 10, "energy" = 15, "bomb" = 10, "bio" = 100, "rad" = 75, "fire" = 50, "acid" = 75)
	item_color = "engineering" //Determines used sprites: hardsuit[on]-[color] and hardsuit[on]-[color]2 (lying down sprite)
	//heat_protection =
	//max_heat_protection_temperature =
	//resistance_flags =
	max_integrity = 300
	var/basestate = "hardsuit"
	allowed = list(/obj/item/flashlight)
	var/brightness_on = 4 //luminosity when on
	var/on = FALSE
	var/obj/item/clothing/suit/space/hardsuit/suit
	actions_types = list(/datum/action/item_action/toggle_helmet_light)

	//Species-specific stuff.
	species_restricted = list("exclude","Wryn", "lesser form")
	sprite_sheets = list(
		"Unathi" = 'icons/mob/species/unathi/helmet.dmi',
		"Tajaran" = 'icons/mob/species/tajaran/helmet.dmi',
		"Skrell" = 'icons/mob/species/skrell/helmet.dmi',
		"Vox" = 'icons/mob/species/vox/helmet.dmi',
		"Vulpkanin" = 'icons/mob/species/vulpkanin/helmet.dmi',
		"Drask" = 'icons/mob/species/drask/helmet.dmi',
		"Grey" = 'icons/mob/species/grey/helmet.dmi'
		)
	sprite_sheets_obj = list(
		"Unathi" = 'icons/obj/clothing/species/unathi/hats.dmi',
		"Tajaran" = 'icons/obj/clothing/species/tajaran/hats.dmi',
		"Skrell" = 'icons/obj/clothing/species/skrell/hats.dmi',
		"Vox" = 'icons/obj/clothing/species/vox/hats.dmi',
		"Vulpkanin" = 'icons/obj/clothing/species/vulpkanin/hats.dmi'
		)

/obj/item/clothing/head/helmet/space/hardsuit/attack_self(mob/user)
	toggle_light(user)

/obj/item/clothing/head/helmet/space/hardsuit/proc/toggle_light(mob/user)
	on = !on
	icon_state = "[basestate][on]-[item_color]"

	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		H.update_inv_head()

	if(on)
		set_light(brightness_on)
	else
		set_light(0)
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/clothing/head/helmet/space/hardsuit/extinguish_light()
	if(on)
		toggle_light()
		visible_message("<span class='danger'>[src]'s light fades and turns off.</span>")

/obj/item/clothing/head/helmet/space/hardsuit/dropped(mob/user)
	..()
	if(suit)
		suit.RemoveHelmet()

/obj/item/clothing/head/helmet/space/hardsuit/item_action_slot_check(slot)
	if(slot == slot_head)
		return 1

/obj/item/clothing/head/helmet/space/hardsuit/equipped(mob/user, slot)
	..()
	if(slot != slot_head)
		if(suit)
			suit.RemoveHelmet()
		else
			qdel(src)

/obj/item/clothing/head/helmet/space/hardsuit/proc/display_visor_message(var/msg)
	var/mob/wearer = loc
	if(msg && ishuman(wearer))
		wearer.show_message("<b><span class='robot'>[msg]</span></b>", 1)

/obj/item/clothing/head/helmet/space/hardsuit/emp_act(severity)
	..()
	display_visor_message("[severity > 1 ? "Light" : "Strong"] electromagnetic pulse detected!")

/obj/item/clothing/suit/space/hardsuit
	name = "hardsuit"
	desc = "A special space suit for environments that might pose hazards beyond just the vacuum of space. Provides more protection than a standard space suit."
	icon_state = "hardsuit-engineering"
	item_state = "eng_hardsuit"
	max_integrity = 300
	armor = list("melee" = 10, "bullet" = 5, "laser" = 10, "energy" = 15, "bomb" = 10, "bio" = 100, "rad" = 75, "fire" = 50, "acid" = 75)
	allowed = list(/obj/item/flashlight,/obj/item/tank/internals,/obj/item/t_scanner, /obj/item/rcd, /obj/item/rpd)
	siemens_coefficient = 0
	var/obj/item/clothing/head/helmet/space/hardsuit/helmet
	actions_types = list(/datum/action/item_action/toggle_helmet)
	var/helmettype = /obj/item/clothing/head/helmet/space/hardsuit
	var/obj/item/tank/jetpack/suit/jetpack = null

	hide_tail_by_species = list("Vox" , "Vulpkanin" , "Unathi" , "Tajaran")
	species_restricted = list("exclude", "Wryn", "lesser form")
	sprite_sheets = list(
		"Unathi" = 'icons/mob/species/unathi/suit.dmi',
		"Tajaran" = 'icons/mob/species/tajaran/suit.dmi',
		"Skrell" = 'icons/mob/species/skrell/suit.dmi',
		"Vox" = 'icons/mob/species/vox/suit.dmi',
		"Vulpkanin" = 'icons/mob/species/vulpkanin/suit.dmi',
		"Drask" = 'icons/mob/species/drask/suit.dmi'
		)
	sprite_sheets_obj = list(
		"Unathi" = 'icons/obj/clothing/species/unathi/suits.dmi',
		"Tajaran" = 'icons/obj/clothing/species/tajaran/suits.dmi',
		"Skrell" = 'icons/obj/clothing/species/skrell/suits.dmi',
		"Vox" = 'icons/obj/clothing/species/vox/suits.dmi',
		"Vulpkanin" = 'icons/obj/clothing/species/vulpkanin/suits.dmi'
		)

/obj/item/clothing/suit/space/hardsuit/New()
	if(jetpack && ispath(jetpack))
		jetpack = new jetpack(src)
	..()

/obj/item/clothing/suit/space/hardsuit/attack_self(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	..()

/obj/item/clothing/suit/space/hardsuit/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/tank/jetpack/suit))
		if(jetpack)
			to_chat(user, "<span class='warning'>[src] already has a jetpack installed.</span>")
			return
		if(src == user.get_item_by_slot(slot_wear_suit)) //Make sure the player is not wearing the suit before applying the upgrade.
			to_chat(user, "<span class='warning'>You cannot install the upgrade to [src] while wearing it.</span>")
			return

		if(user.unEquip(I))
			I.forceMove(src)
			jetpack = I
			to_chat(user, "<span class='notice'>You successfully install the jetpack into [src].</span>")
			return
	return ..()

/obj/item/clothing/suit/space/hardsuit/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!jetpack)
		to_chat(user, "<span class='warning'>[src] has no jetpack installed.</span>")
		return
	if(src == user.get_item_by_slot(slot_wear_suit))
		to_chat(user, "<span class='warning'>You cannot remove the jetpack from [src] while wearing it.</span>")
		return
	jetpack.turn_off(user)
	jetpack.forceMove(drop_location())
	jetpack = null
	to_chat(user, "<span class='notice'>You successfully remove the jetpack from [src].</span>")

/obj/item/clothing/suit/space/hardsuit/equipped(mob/user, slot)
	..()
	if(jetpack)
		if(slot == slot_wear_suit)
			for(var/X in jetpack.actions)
				var/datum/action/A = X
				A.Grant(user)

/obj/item/clothing/suit/space/hardsuit/dropped(mob/user)
	..()
	if(jetpack)
		for(var/X in jetpack.actions)
			var/datum/action/A = X
			A.Remove(user)

/obj/item/clothing/suit/space/hardsuit/item_action_slot_check(slot)
	if(slot == slot_wear_suit) //we only give the mob the ability to toggle the helmet if he's wearing the hardsuit.
		return 1

//Engineering hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/engine
	name = "engineering hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has radiation shielding."
	icon_state = "hardsuit0-engineering"
	item_state = "eng_helm"
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 15, "bomb" = 10, "bio" = 100, "rad" = 75, "fire" = 100, "acid" = 75)
	item_color = "engineering"
	resistance_flags = FIRE_PROOF

/obj/item/clothing/suit/space/hardsuit/engine
	name = "engineering hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has radiation shielding."
	icon_state = "hardsuit-engineering"
	item_state = "eng_hardsuit"
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 15, "bomb" = 10, "bio" = 100, "rad" = 75, "fire" = 100, "acid" = 75)
	resistance_flags = FIRE_PROOF
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/engine
	dog_fashion = /datum/dog_fashion/back/hardsuit

//Atmospherics
/obj/item/clothing/head/helmet/space/hardsuit/engine/atmos
	name = "atmospherics hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has thermal shielding."
	icon_state = "hardsuit0-atmos"
	item_state = "atmos_helm"
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 15, "bomb" = 10, "bio" = 100, "rad" = 25, "fire" = 100, "acid" = 75)
	item_color = "atmos"
	heat_protection = HEAD												//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT

/obj/item/clothing/suit/space/hardsuit/engine/atmos
	name = "atmospherics hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has thermal shielding."
	icon_state = "hardsuit-atmos"
	item_state = "atmos_hardsuit"
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 15, "bomb" = 10, "bio" = 100, "rad" = 25, "fire" = 100, "acid" = 75)
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS|TAIL					//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/engine/atmos
	dog_fashion = null

//Chief Engineer's hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/engine/elite
	name = "advanced hardsuit helmet"
	desc = "An advanced helmet designed for work in a hazardous, low pressure environment. Shines with a high polish."
	icon_state = "hardsuit0-white"
	item_state = "ce_helm"
	armor = list("melee" = 40, "bullet" = 5, "laser" = 10, "energy" = 25, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 90)
	item_color = "white"
	heat_protection = HEAD												//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT

/obj/item/clothing/suit/space/hardsuit/engine/elite
	name = "advanced hardsuit"
	desc = "An advanced suit that protects against hazardous, low pressure environments. Shines with a high polish."
	icon_state = "hardsuit-white"
	item_state = "ce_hardsuit"
	armor = list("melee" = 40, "bullet" = 5, "laser" = 10, "energy" = 25, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 90)
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS|TAIL					//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/engine/elite
	jetpack = /obj/item/tank/jetpack/suit
	dog_fashion = null

//Mining hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/mining
	name = "mining hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has reinforced plating."
	icon_state = "hardsuit0-mining"
	item_state = "mining_helm"
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 15, "bomb" = 50, "bio" = 100, "rad" = 50, "fire" = 50, "acid" = 75)
	item_color = "mining"
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF
	brightness_on = 7

/obj/item/clothing/suit/space/hardsuit/mining
	name = "mining hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has reinforced plating."
	icon_state = "hardsuit-mining"
	item_state = "mining_hardsuit"
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 15, "bomb" = 50, "bio" = 100, "rad" = 50, "fire" = 50, "acid" = 75)
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS|TAIL
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/storage/bag/ore, /obj/item/pickaxe, /obj/item/resonator, /obj/item/mining_scanner, /obj/item/t_scanner/adv_mining_scanner, /obj/item/gun/energy/kinetic_accelerator, /obj/item/twohanded/kinetic_crusher, /obj/item/hierophant_club, /obj/item/twohanded/fireaxe/boneaxe)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/mining

//Syndicate hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/syndi
	name = "blood-red hardsuit helmet"
	desc = "A dual-mode advanced helmet designed for work in special operations. It is in travel mode. Property of Gorlex Marauders."
	alt_desc = "A dual-mode advanced helmet designed for work in special operations. It is in combat mode. Property of Gorlex Marauders."
	icon_state = "hardsuit1-syndi"
	item_state = "syndie_helm"
	armor = list("melee" = 40, "bullet" = 50, "laser" = 30, "energy" = 30, "bomb" = 35, "bio" = 100, "rad" = 50, "fire" = 50, "acid" = 90)
	item_color = "syndi"
	on = 1
	var/obj/item/clothing/suit/space/hardsuit/syndi/linkedsuit = null
	actions_types = list(/datum/action/item_action/toggle_helmet_mode)
	visor_flags_inv = HIDEMASK|HIDEGLASSES|HIDENAME|HIDETAIL
	visor_flags = STOPSPRESSUREDMAGE

/obj/item/clothing/head/helmet/space/hardsuit/syndi/update_icon()
	icon_state = "hardsuit[on]-[item_color]"

/obj/item/clothing/head/helmet/space/hardsuit/syndi/New()
	..()
	if(istype(loc, /obj/item/clothing/suit/space/hardsuit/syndi))
		linkedsuit = loc

/obj/item/clothing/head/helmet/space/hardsuit/syndi/attack_self(mob/user) //Toggle Helmet
	if(!isturf(user.loc))
		to_chat(user, "<span class='warning'>You cannot toggle your helmet while in this [user.loc]!</span>" )
		return
	on = !on
	if(on)
		to_chat(user, "<span class='notice'>You switch your hardsuit to EVA mode, sacrificing speed for space protection.</span>")
		name = initial(name)
		desc = initial(desc)
		set_light(brightness_on)
		flags |= visor_flags
		flags_cover |= HEADCOVERSEYES | HEADCOVERSMOUTH
		flags_inv |= visor_flags_inv
		cold_protection |= HEAD
	else
		to_chat(user, "<span class='notice'>You switch your hardsuit to combat mode and can now run at full speed.</span>")
		name += " (combat)"
		desc = alt_desc
		set_light(0)
		flags &= ~visor_flags
		flags_cover &= ~(HEADCOVERSEYES | HEADCOVERSMOUTH)
		flags_inv &= ~visor_flags_inv
		cold_protection &= ~HEAD
	update_icon()
	playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
	toggle_hardsuit_mode(user)
	user.update_inv_head()
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.head_update(src, forced = 1)
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/clothing/head/helmet/space/hardsuit/syndi/proc/toggle_hardsuit_mode(mob/user) //Helmet Toggles Suit Mode
	if(linkedsuit)
		if(on)
			linkedsuit.name = initial(linkedsuit.name)
			linkedsuit.desc = initial(linkedsuit.desc)
			linkedsuit.slowdown = 1
			linkedsuit.flags |= STOPSPRESSUREDMAGE
			linkedsuit.cold_protection |= UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS | TAIL
		else
			linkedsuit.name += " (combat)"
			linkedsuit.desc = linkedsuit.alt_desc
			linkedsuit.slowdown = 0
			linkedsuit.flags &= ~STOPSPRESSUREDMAGE
			linkedsuit.cold_protection &= ~(UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS | TAIL)

		linkedsuit.update_icon()
		user.update_inv_wear_suit()
		user.update_inv_w_uniform()

/obj/item/clothing/suit/space/hardsuit/syndi
	name = "blood-red hardsuit"
	desc = "A dual-mode advanced hardsuit designed for work in special operations. It is in travel mode. Property of Gorlex Marauders."
	alt_desc = "A dual-mode advanced hardsuit designed for work in special operations. It is in combat mode. Property of Gorlex Marauders."
	icon_state = "hardsuit1-syndi"
	item_state = "syndie_hardsuit"
	armor = list("melee" = 40, "bullet" = 50, "laser" = 30, "energy" = 30, "bomb" = 35, "bio" = 100, "rad" = 50, "fire" = 50, "acid" = 90)
	item_color = "syndi"
	w_class = WEIGHT_CLASS_NORMAL
	var/on = 1
	actions_types = list(/datum/action/item_action/toggle_hardsuit_mode)

	allowed = list(/obj/item/gun, /obj/item/ammo_box,/obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/melee/energy/sword, /obj/item/restraints/handcuffs, /obj/item/tank/internals)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi
	jetpack = /obj/item/tank/jetpack/suit

/obj/item/clothing/suit/space/hardsuit/syndi/update_icon()
	icon_state = "hardsuit[on]-[item_color]"

//Elite Syndie suit
/obj/item/clothing/head/helmet/space/hardsuit/syndi/elite
	name = "elite syndicate hardsuit helmet"
	desc = "An elite version of the syndicate helmet, with improved armour and fire shielding. It is in travel mode. Property of Gorlex Marauders."
	icon_state = "hardsuit0-syndielite"
	armor = list("melee" = 60, "bullet" = 60, "laser" = 50, "energy" = 40, "bomb" = 55, "bio" = 100, "rad" = 70, "fire" = 100, "acid" = 100)
	item_color = "syndielite"
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/suit/space/hardsuit/syndi/elite
	name = "elite syndicate hardsuit"
	desc = "An elite version of the syndicate hardsuit, with improved armour and fire shielding. It is in travel mode."
	icon_state = "hardsuit0-syndielite"
	armor = list("melee" = 60, "bullet" = 60, "laser" = 50, "energy" = 40, "bomb" = 55, "bio" = 100, "rad" = 70, "fire" = 100, "acid" = 100)
	item_color = "syndielite"
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS|TAIL
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi/elite

/obj/item/clothing/head/helmet/space/hardsuit/syndi/elite/comms
	name = "Comms Officer elite syndicate hardsuit helmet"
	desc = "An elite version of the syndicate helmet, with improved armour and fire shielding. This one has contractor style."
	icon_state = "hardsuit0-commsoff"
	item_color = "commsoff"
/obj/item/clothing/suit/space/hardsuit/syndi/elite/comms
	name = "Comms Officer elite syndicate hardsuit"
	desc = "An elite version of the syndicate hardsuit, with improved armour and fire shielding. This one has contractor style."
	icon_state = "hardsuit0-commsoff"
	item_color = "commsoff"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi/elite/comms

/obj/item/clothing/head/helmet/space/hardsuit/syndi/elite/med
	name = "Elite medical syndicate hardsuit helmet"
	desc = "An elite version of the syndicate helmet. This one is made special for medics."
	icon_state = "hardsuit1-smedelite"
	item_state = "hardsuit0-smedelite"
	item_color = "smedelite"

/obj/item/clothing/suit/space/hardsuit/syndi/elite/med
	name = "Elite medical syndicate hardsuit helmet"
	desc = "An elite version of the syndicate hardsuit. This one is made special for medics."
	icon_state = "hardsuit1-smedelite"
	item_state = "hardsuit0-smedelite"
	item_color = "smedelite"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi/elite/med

//Strike team hardsuits
/obj/item/clothing/head/helmet/space/hardsuit/syndi/elite/sst
	icon_state = "hardsuit0-sst"
	armor = list(melee = 70, bullet = 70, laser = 50, energy = 40, bomb = 80, bio = 100, rad = 100, fire = 100, acid = 100) //Almost as good as DS gear, but unlike DS can switch to combat for mobility
	item_color = "sst"

/obj/item/clothing/suit/space/hardsuit/syndi/elite/sst
	icon_state = "hardsuit0-sst"
	armor = list(melee = 70, bullet = 70, laser = 50, energy = 40, bomb = 80, bio = 100, rad = 100, fire = 100, acid = 100)
	item_color = "sst"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi/elite/sst

/obj/item/clothing/suit/space/hardsuit/syndi/freedom
	name = "eagle suit"
	desc = "An advanced, light suit, fabricated from a mixture of synthetic feathers and space-resistant material. A gun holster appears to be integrated into the suit."
	icon_state = "freedom"
	item_state = "freedom"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/syndi/freedom
	sprite_sheets = null

/obj/item/clothing/suit/space/hardsuit/syndi/freedom/update_icon()
	return

/obj/item/clothing/head/helmet/space/hardsuit/syndi/freedom
	name = "eagle helmet"
	desc = "An advanced, space-proof helmet. It appears to be modeled after an old-world eagle."
	icon_state = "griffinhat"
	item_state = "griffinhat"
	sprite_sheets = null

/obj/item/clothing/head/helmet/space/hardsuit/syndi/freedom/update_icon()
	return

//Soviet hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/soviet
	name = "\improper Soviet hardsuit helmet"
	desc = "A military hardsuit helmet bearing the red star of the U.S.S.P."
	icon_state = "hardsuit0-soviet"
	item_state = "hardsuit0-soviet"
	item_color = "soviet"
	armor = list("melee" = 35, "bullet" = 15, "laser" = 30,"energy" = 10, "bomb" = 10, "bio" = 100, "rad" = 50, "fire" = 75, "acid" = 75)

/obj/item/clothing/suit/space/hardsuit/soviet
	name = "\improper Soviet hardsuit"
	desc = "A soviet military hardsuit designed for maximum speed and mobility. Proudly displays the U.S.S.P flag on the chest."
	icon_state = "hardsuit-soviet"
	item_state = "hardsuit-soviet"
	slowdown = 0.5
	armor = list("melee" = 35, "bullet" = 15, "laser" = 30, "energy" = 10, "bomb" = 10, "bio" = 100, "rad" = 50, "fire" = 75, "acid" = 75)
	allowed = list(/obj/item/gun,/obj/item/flashlight,/obj/item/tank/internals,/obj/item/melee/baton,/obj/item/reagent_containers/spray/pepper,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/restraints/handcuffs)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/soviet
	jetpack = /obj/item/tank/jetpack/suit

/obj/item/clothing/head/helmet/space/hardsuit/soviet/commander
	name = "\improper Soviet command hardsuit helmet"
	desc = "A military hardsuit helmet with a red command stripe."
	icon_state = "hardsuit0-soviet-commander"
	item_state = "hardsuit0-soviet-commander"
	item_color = "soviet-commander"

/obj/item/clothing/suit/space/hardsuit/soviet/commander
	name = "\improper Soviet command hardsuit"
	desc = "A soviet military command hardsuit designed for maximum speed and mobility."
	icon_state = "hardsuit-soviet-commander"
	item_state = "hardsuit-soviet-commander"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/soviet/commander

//Medical hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/medical
	name = "medical hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Built with lightweight materials for extra comfort, but does not protect the eyes from intense light."
	icon_state = "hardsuit0-medical"
	item_state = "medical_helm"
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 5, "bomb" = 10, "bio" = 100, "rad" = 60, "fire" = 60, "acid" = 75)
	item_color = "medical"
	flash_protect = 0
	flags = STOPSPRESSUREDMAGE | THICKMATERIAL
	scan_reagents = 1 //Generally worn by the CMO, so they'd get utility off of seeing reagents

/obj/item/clothing/suit/space/hardsuit/medical
	name = "medical hardsuit"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Built with lightweight materials for extra comfort."
	icon_state = "hardsuit-medical"
	item_state = "medical_hardsuit"
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 5, "bomb" = 10, "bio" = 100, "rad" = 60, "fire" = 60, "acid" = 75)
	allowed = list(/obj/item/flashlight,/obj/item/tank/internals,/obj/item/storage/firstaid,/obj/item/healthanalyzer,/obj/item/stack/medical,/obj/item/rad_laser)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/medical
	slowdown = 0.5

//Security
/obj/item/clothing/head/helmet/space/hardsuit/security
	name = "security hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has an additional layer of armor."
	icon_state = "hardsuit0-sec"
	item_state = "sec_helm"
	armor = list("melee" = 35, "bullet" = 15, "laser" = 30,"energy" = 20, "bomb" = 10, "bio" = 100, "rad" = 50, "fire" = 75, "acid" = 75)
	item_color = "sec"

/obj/item/clothing/head/helmet/space/hardsuit/security/warden
	name = "warden's hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has an additional layer of armor."
	icon_state = "hardsuit0-warden"
	armor = list("melee" = 40, "bullet" = 20, "laser" = 30,"energy" = 20, "bomb" = 15, "bio" = 100, "rad" = 50, "fire" = 80, "acid" = 85)
	item_color = "warden"

/obj/item/clothing/suit/space/hardsuit/security/warden
	name = "warden's hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has an additional layer of armor."
	icon_state = "hardsuit-warden"
	armor = list("melee" = 40, "bullet" = 20, "laser" = 30,"energy" = 20, "bomb" = 15, "bio" = 100, "rad" = 50, "fire" = 80, "acid" = 85)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/security/warden

/obj/item/clothing/suit/space/hardsuit/security
	name = "security hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has an additional layer of armor."
	icon_state = "hardsuit-sec"
	item_state = "sec_hardsuit"
	armor = list("melee" = 35, "bullet" = 15, "laser" = 30, "energy" = 20, "bomb" = 10, "bio" = 100, "rad" = 50, "fire" = 75, "acid" = 75)
	allowed = list(/obj/item/gun,/obj/item/flashlight,/obj/item/tank/internals,/obj/item/melee/baton,/obj/item/reagent_containers/spray/pepper,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/restraints/handcuffs)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/security

/obj/item/clothing/head/helmet/space/hardsuit/security/hos
	name = "head of security's hardsuit helmet"
	desc = "A special bulky helmet designed for work in a hazardous, low pressure environment. Has an additional layer of armor."
	icon_state = "hardsuit0-hos"
	armor = list("melee" = 45, "bullet" = 25, "laser" = 30, "energy" = 30, "bomb" = 25, "bio" = 100, "rad" = 50, "fire" = 95, "acid" = 95)
	item_color = "hos"

/obj/item/clothing/suit/space/hardsuit/security/hos
	name = "head of security's hardsuit"
	desc = "A special bulky suit that protects against hazardous, low pressure environments. Has an additional layer of armor."
	icon_state = "hardsuit-hos"
	armor = list("melee" = 45, "bullet" = 25, "laser" = 30, "energy" = 30, "bomb" = 25, "bio" = 100, "rad" = 50, "fire" = 95, "acid" = 95)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/security/hos
	jetpack = /obj/item/tank/jetpack/suit

//Blueshield hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/blueshield
	name = "blueshield's hardsuit helmet"
	desc = "A special bulky helmet worn by the Blueshield Lieutenant. Has blue highlights and Blueshield`s sign on the chest plate. Heavy armoured, space ready and fire resistant."
	icon_state = "hardsuit0-blueshield"
	item_state = "hardsuit0-blueshield"
	armor = list("melee" = 40, "bullet" = 20, "laser" = 30, "energy" = 15, "bomb" = 25, "bio" = 100, "rad" = 50, "fire" = 80, "acid" = 80)
	item_color = "blueshield"

/obj/item/clothing/suit/space/hardsuit/blueshield
	name = "blueshield's hardsuit"
	desc = "A special bulky suit worn by the Blueshield Lieutenant. Has blue highlights and Blueshield`s sign on the chest plate. Heavy armoured, space ready and fire resistant."
	icon_state = "hardsuit-blueshield"
	item_state = "hardsuit-blueshield"
	armor = list("melee" = 40, "bullet" = 20, "laser" = 30, "energy" = 15, "bomb" = 25, "bio" = 100, "rad" = 50, "fire" = 80, "acid" = 80)
	item_color = "blueshield"
	allowed = list(/obj/item/gun,/obj/item/flashlight,/obj/item/tank/internals,/obj/item/melee/baton,/obj/item/reagent_containers/spray/pepper,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/restraints/handcuffs)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/blueshield
	jetpack = /obj/item/tank/jetpack/suit

//Research Director hardsuit
/obj/item/clothing/head/helmet/space/hardsuit/rd
	name = "Research Director Hardsuit Helmet"
	desc = "A prototype helmet designed for research in a hazardous, low pressure environment. Scientific data flashes across the visor."
	icon_state = "hardsuit0-rd"
	item_state = "rd"
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 5, "bomb" = 100, "bio" = 100, "rad" = 60, "fire" = 60, "acid" = 80)
	item_color = "rd"
	scan_reagents = TRUE
	var/hud_active = TRUE
	var/explosion_detection_dist = 40

/obj/item/clothing/head/helmet/space/hardsuit/rd/equipped(mob/user, slot)
	..()
	if(slot == slot_head)
		GLOB.doppler_arrays += src //Needed to sense the kabooms
		if(ishuman(user))
			var/mob/living/carbon/human/U = user
			if(istype(U.glasses, /obj/item/clothing/glasses/hud/diagnostic)) // If they are for some reason wearing a diagnostic hud when they put the helmet on
				return // already have a hud
			hud_active = TRUE

/obj/item/clothing/head/helmet/space/hardsuit/rd/dropped(mob/living/carbon/human/user)
	..()
	if((user.head == src) && hud_active)
		GLOB.doppler_arrays -= src

/obj/item/clothing/head/helmet/space/hardsuit/rd/proc/sense_explosion(x0, y0, z0, devastation_range, heavy_impact_range,
		light_impact_range, took, orig_dev_range, orig_heavy_range, orig_light_range)
	var/turf/T = get_turf(src)
	var/dx = abs(x0 - T.x)
	var/dy = abs(y0 - T.y)
	var/distance = 40
	if(T.z != z0)
		return
	if(dx > dy)
		distance = dx
	else
		distance = dy
	if(distance > explosion_detection_dist)
		return
	display_visor_message("Explosion detected! Epicenter radius: [devastation_range], Outer radius: [heavy_impact_range], Shockwave radius: [light_impact_range]")

/obj/item/clothing/suit/space/hardsuit/rd
	name = "Research Director Hardsuit"
	desc = "A prototype suit that protects against hazardous, low pressure environments. Fitted with extensive plating for handling explosives and dangerous research materials."
	icon_state = "hardsuit-rd"
	item_state = "hardsuit-rd"
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 5, "bomb" = 100, "bio" = 100, "rad" = 60, "fire" = 60, "acid" = 80)
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT //Same as an emergency firesuit. Not ideal for extended exposure.
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/gun/energy/wormhole_projector,
	/obj/item/hand_tele, /obj/item/aicard)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/rd
	jetpack = /obj/item/tank/jetpack/suit

//Singuloth armor
/obj/item/clothing/head/helmet/space/hardsuit/singuloth
	name = "singuloth knight's helmet"
	desc = "This is an adamantium helmet from the chapter of the Singuloth Knights. It shines with a holy aura."
	icon_state = "hardsuit0-singuloth"
	item_state = "singuloth_helm"
	armor = list(melee = 45, bullet = 25, laser = 30, energy = 10, bomb = 25, bio = 100, rad = 100, fire = 95, acid = 95)
	item_color = "singuloth"
	sprite_sheets = null

/obj/item/clothing/suit/space/hardsuit/singuloth
	name = "singuloth knight's armor"
	desc = "This is a ceremonial armor from the chapter of the Singuloth Knights. It's made of pure forged adamantium."
	icon_state = "hardsuit-singuloth"
	item_state = "singuloth_hardsuit"
	armor = list(melee = 45, bullet = 25, laser = 30, energy = 10, bomb = 25, bio = 100, rad = 100, fire = 95, acid = 95)
	flags = STOPSPRESSUREDMAGE
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/singuloth
	sprite_sheets = null

//Battlemage Hardsuit — code\modules\clothing\suits\wiz_robe.dm
//Deathsquad Hardsuit — code\modules\clothing\spacesuits\ert.dm
//Prototype RIG Hardsuit — code\modules\awaymissions\mission_code\ruins\oldstation.dm
