//Regular rig suits
/obj/item/clothing/head/helmet/space/rig
	name = "hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment."
	icon_state = "rig0-engineering"
	item_state = "eng_helm"
	rig_restrict_helmet = 1
	armor = list(melee = 10, bullet = 5, laser = 10, energy = 5, bomb = 10, bio = 100, rad = 75)
	allowed = list(/obj/item/device/flashlight)
	var/brightness_on = 4 //luminosity when on
	var/on = 0
	item_color = "engineering" //Determines used sprites: rig[on]-[color] and rig[on]-[color]2 (lying down sprite)
	actions_types = list(/datum/action/item_action/toggle_helmet_light)

	//Species-specific stuff.
	species_restricted = list("exclude","Diona","Wryn")
	sprite_sheets = list(
		"Unathi" = 'icons/mob/species/unathi/helmet.dmi',
		"Tajaran" = 'icons/mob/species/tajaran/helmet.dmi',
		"Skrell" = 'icons/mob/species/skrell/helmet.dmi',
		"Vox" = 'icons/mob/species/vox/helmet.dmi',
		"Vulpkanin" = 'icons/mob/species/vulpkanin/helmet.dmi',
		"Drask" = 'icons/mob/species/drask/helmet.dmi'
		)
	sprite_sheets_obj = list(
		"Unathi" = 'icons/obj/clothing/species/unathi/hats.dmi',
		"Tajaran" = 'icons/obj/clothing/species/tajaran/hats.dmi',
		"Skrell" = 'icons/obj/clothing/species/skrell/hats.dmi',
		"Vox" = 'icons/obj/clothing/species/vox/hats.dmi',
		"Vulpkanin" = 'icons/obj/clothing/species/vulpkanin/hats.dmi',
		)

/obj/item/clothing/head/helmet/space/rig/equip_to_best_slot(mob/M)
	if(rig_restrict_helmet)
		to_chat(M, "<span class='warning'>You must fasten the helmet to a hardsuit first. (Target the head and use on a hardsuit)</span>") // Stop RIG helmet equipping
		return 0
	..()

/obj/item/clothing/head/helmet/space/rig/attack_self(mob/user)
	toggle_light(user)

/obj/item/clothing/head/helmet/space/rig/proc/toggle_light(mob/user)
	on = !on
	icon_state = "rig[on]-[item_color]"

	if(on)
		set_light(brightness_on)
	else
		set_light(0)

	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		H.update_inv_head()

	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/clothing/head/helmet/space/rig/item_action_slot_check(slot)
	if(slot == slot_head)
		return 1

/obj/item/clothing/suit/space/rig
	name = "hardsuit"
	desc = "A special space suit for environments that might pose hazards beyond just the vacuum of space. Provides more protection than a standard space suit."
	icon_state = "rig-engineering"
	item_state = "eng_hardsuit"
	armor = list(melee = 10, bullet = 5, laser = 10, energy = 5, bomb = 10, bio = 100, rad = 75)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/device/t_scanner, /obj/item/weapon/rcd)
	siemens_coefficient = 0

	species_restricted = list("exclude","Diona","Wryn")
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
		"Vulpkanin" = 'icons/obj/clothing/species/vulpkanin/suits.dmi',
		)

	//Breach thresholds, should ideally be inherited by most (if not all) hardsuits.
	breach_threshold = 18
	can_breach = 0

	//Component/device holders.
	var/obj/item/weapon/stock_parts/gloves = null     // Basic capacitor allows insulation, upgrades allow shock gloves etc.

	var/attached_boots = 1                            // Can't wear boots if some are attached
	var/obj/item/clothing/shoes/magboots/boots = null // Deployable boots, if any.
	var/attached_helmet = 1                           // Can't wear a helmet if one is deployable.
	var/obj/item/clothing/head/helmet/helmet = null   // Deployable helmet, if any.

	var/list/max_mounted_devices = 0                  // Maximum devices. Easy.
	var/list/can_mount = null                         // Types of device that can be hardpoint mounted.
	var/list/mounted_devices = null                   // Holder for the above device.
	var/obj/item/active_device = null                 // Currently deployed device, if any.

/obj/item/clothing/suit/space/rig/equipped(mob/M)
	..()

	var/mob/living/carbon/human/H = M

	if(!istype(H)) return

	spawn(1)	//to ensure the slot is set before we continue
		if(H.wear_suit != src)
			return

		if(attached_helmet && helmet)
			if(H.head)
				to_chat(M, "You are unable to deploy your suit's helmet as \the [H.head] is in the way.")
			else
				to_chat(M, "Your suit's helmet deploys with a hiss.")
				//TODO: Species check, skull damage for forcing an unfitting helmet on?
				helmet.forceMove(H)
				H.equip_to_slot(helmet, slot_head)
				helmet.flags |= NODROP

		if(attached_boots && boots)
			if(H.shoes)
				to_chat(M, "You are unable to deploy your suit's magboots as \the [H.shoes] are in the way.")
			else
				to_chat(M, "Your suit's boots deploy with a hiss.")
				boots.forceMove(H)
				H.equip_to_slot(boots, slot_shoes)
				boots.flags |= NODROP

/obj/item/clothing/suit/space/rig/dropped()
	..()

	var/mob/living/carbon/human/H

	if(helmet)
		H = helmet.loc
		if(istype(H))
			if(helmet && H.head == helmet)
				helmet.flags &= ~NODROP
				H.unEquip(helmet)
				helmet.forceMove(src)

	if(boots)
		H = boots.loc
		if(istype(H))
			if(boots && H.shoes == boots)
				boots.flags &= ~NODROP
				H.unEquip(boots)
				boots.forceMove(src)

/obj/item/clothing/suit/space/rig/verb/toggle_helmet()
	set name = "Toggle Helmet"
	set category = "Object"
	set src in usr

	if(!isliving(usr))
		return

	if(!helmet)
		to_chat(usr, "There is no helmet installed.")
		return

	var/mob/living/carbon/human/H = usr

	if(!istype(H)) return
	if(H.stat) return
	if(H.wear_suit != src) return

	if(H.head == helmet)
		helmet.flags &= ~NODROP
		H.unEquip(helmet)
		helmet.loc = src
		to_chat(H, "<span class='notice'>You retract your hardsuit helmet.</span>")
	else
		if(H.head)
			to_chat(H, "<span class='warning'>You cannot deploy your helmet while wearing another helmet.</span>")
			return
		//TODO: Species check, skull damage for forcing an unfitting helmet on?
		helmet.loc = H
		helmet.pickup(H)
		H.equip_to_slot(helmet, slot_head)
		helmet.flags |= NODROP
		to_chat(H, "<span class='notice'>You deploy your hardsuit helmet, sealing you off from the world.</span>")
	H.update_inv_head()

/obj/item/clothing/suit/space/rig/attackby(obj/item/W as obj, mob/user as mob, params)
	if(!isliving(user))
		return

	if(istype(src.loc,/mob/living))
		to_chat(user, "How do you propose to modify a hardsuit while it is being worn?")
		return

	if(istype(W,/obj/item/weapon/screwdriver))
		if(!helmet)
			to_chat(user, "\The [src] does not have a helmet installed.")
		else
			to_chat(user, "You detach \the [helmet] from \the [src]'s helmet mount.")
			helmet.loc = get_turf(src)
			src.helmet = null
			return
		if(!boots)
			to_chat(user, "\The [src] does not have any boots installed.")
		else
			to_chat(user, "You detach \the [boots] from \the [src]'s boot mounts.")
			boots.loc = get_turf(src)
			boots = null
		return

	else if(istype(W,/obj/item/clothing/head/helmet/space))
		if(!attached_helmet)
			to_chat(user, "\The [src] does not have a helmet mount.")
			return
		if(helmet)
			to_chat(user, "\The [src] already has a helmet installed.")
		else
			to_chat(user, "You attach \the [W] to \the [src]'s helmet mount.")
			user.drop_item()
			W.loc = src
			src.helmet = W
		return

	else if(istype(W,/obj/item/clothing/shoes/magboots))
		if(!attached_boots)
			to_chat(user, "\The [src] does not have boot mounts.")
			return

		if(boots)
			to_chat(user, "\The [src] already has magboots installed.")
		else
			to_chat(user, "You attach \the [W] to \the [src]'s boot mounts.")
			user.drop_item()
			W.loc = src
			boots = W
	else
		return ..()

	..()

//Engineering rig
/obj/item/clothing/head/helmet/space/rig/engineering
	name = "engineering hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has radiation shielding."
	icon_state = "rig0-engineering"
	item_state = "eng_helm"
	armor = list(melee = 10, bullet = 5, laser = 10, energy = 5, bomb = 10, bio = 100, rad = 75)

/obj/item/clothing/suit/space/rig/engineering
	name = "engineering hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has radiation shielding."
	icon_state = "rig-engineering"
	item_state = "eng_hardsuit"
	armor = list(melee = 10, bullet = 5, laser = 10, energy = 5, bomb = 10, bio = 100, rad = 75)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/device/t_scanner, /obj/item/weapon/rcd)

//Chief Engineer's rig
/obj/item/clothing/head/helmet/space/rig/elite
	name = "advanced hardsuit helmet"
	desc = "An advanced helmet designed for work in a hazardous, low pressure environment. Shines with a high polish."
	icon_state = "rig0-white"
	item_state = "ce_helm"
	item_color = "white"
	armor = list(melee = 40, bullet = 5, laser = 10, energy = 5, bomb = 50, bio = 100, rad = 90)
	heat_protection = HEAD												//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_HELM_MAX_TEMP_PROTECT

/obj/item/clothing/suit/space/rig/elite
	icon_state = "rig-white"
	name = "advanced hardsuit"
	desc = "An advanced suit that protects against hazardous, low pressure environments. Shines with a high polish."
	item_state = "ce_hardsuit"
	armor = list(melee = 40, bullet = 5, laser = 10, energy = 5, bomb = 50, bio = 100, rad = 90)
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS					//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT

//Mining rig
/obj/item/clothing/head/helmet/space/rig/mining
	name = "mining hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has reinforced plating."
	icon_state = "rig0-mining"
	item_state = "mining_helm"
	item_color = "mining"
	flags = HEADCOVERSEYES | BLOCKHAIR | HEADCOVERSMOUTH | STOPSPRESSUREDMAGE
	armor = list(melee = 30, bullet = 5, laser = 10, energy = 5, bomb = 50, bio = 100, rad = 50)

/obj/item/clothing/suit/space/rig/mining
	icon_state = "rig-mining"
	name = "mining hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has reinforced plating."
	item_state = "mining_hardsuit"
	armor = list(melee = 30, bullet = 5, laser = 10, energy = 5, bomb = 50, bio = 100, rad = 50)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/storage/bag/ore,/obj/item/weapon/pickaxe)


//Syndicate rig
/obj/item/clothing/head/helmet/space/rig/syndi
	name = "blood-red hardsuit helmet"
	desc = "A dual-mode advanced helmet designed for work in special operations. It is in travel mode. Property of Gorlex Marauders."
	icon_state = "rig1-syndi"
	item_state = "syndie_helm"
	item_color = "syndi"
	armor = list(melee = 40, bullet = 50, laser = 30, energy = 15, bomb = 35, bio = 100, rad = 50)
	on = 1
	flags = HEADCOVERSEYES | BLOCKHAIR | HEADCOVERSMOUTH | STOPSPRESSUREDMAGE | THICKMATERIAL
	actions_types = list(/datum/action/item_action/toggle_helmet_mode)

/obj/item/clothing/head/helmet/space/rig/syndi/update_icon()
	icon_state = "rig[on]-[item_color]"

/obj/item/clothing/head/helmet/space/rig/syndi/attack_self(mob/user)
	on = !on
	if(on)
		to_chat(user, "<span class='notice'>You switch your helmet to travel mode. It will allow you to stand in zero pressure environments, at the cost of speed and armor.</span>")
		name = "blood-red hardsuit helmet"
		desc = "A dual-mode advanced helmet designed for work in special operations. It is in travel mode. Property of Gorlex Marauders."
		flags = HEADCOVERSEYES | BLOCKHAIR | HEADCOVERSMOUTH | STOPSPRESSUREDMAGE | THICKMATERIAL | NODROP
		flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
		cold_protection = HEAD
		set_light(brightness_on)
	else
		to_chat(user, "<span class='notice'>You switch your helmet to combat mode. You will take damage in zero pressure environments, but you are more suited for a fight.</span>")
		name = "blood-red hardsuit helmet (combat)"
		desc = "A dual-mode advanced helmet designed for work in special operations. It is in combat mode. Property of Gorlex Marauders."
		flags = BLOCKHAIR | THICKMATERIAL | NODROP
		flags_inv = HIDEEARS
		cold_protection = null
		set_light(0)

	update_icon()
	playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
	user.update_inv_head()

	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/clothing/suit/space/rig/syndi
	name = "blood-red hardsuit"
	desc = "A dual-mode advanced hardsuit designed for work in special operations. It is in travel mode. Property of Gorlex Marauders."
	icon_state = "rig1-syndi"
	item_state = "syndie_hardsuit"
	item_color = "syndi"
	w_class = 3
	var/on = 1
	actions_types = list(/datum/action/item_action/toggle_hardsuit_mode)
	armor = list(melee = 40, bullet = 50, laser = 30, energy = 15, bomb = 35, bio = 100, rad = 50)
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/melee/energy/sword/saber,/obj/item/weapon/restraints/handcuffs,/obj/item/weapon/tank)

/obj/item/clothing/suit/space/rig/syndi/update_icon()
	icon_state = "rig[on]-[item_color]"

/obj/item/clothing/suit/space/rig/syndi/attack_self(mob/user)
	on = !on
	if(on)
		to_chat(user, "<span class='notice'>You switch your hardsuit to travel mode. It will allow you to stand in zero pressure environments, at the cost of speed and armor.</span>")
		name = "blood-red hardsuit"
		desc = "A dual-mode advanced hardsuit designed for work in special operations. It is in travel mode. Property of Gorlex Marauders."
		slowdown = 1
		flags = STOPSPRESSUREDMAGE | THICKMATERIAL
		flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
		cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	else
		to_chat(user, "<span class='notice'>You switch your hardsuit to combat mode. You will take damage in zero pressure environments, but you are more suited for a fight.</span>")
		name = "blood-red hardsuit (combat)"
		desc = "A dual-mode advanced hardsuit designed for work in special operations. It is in combat mode. Property of Gorlex Marauders."
		slowdown = 0
		flags = THICKMATERIAL
		flags_inv = null
		cold_protection = null

	update_icon()
	playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
	user.update_inv_wear_suit()
	user.update_inv_w_uniform()

	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

//Elite Syndie suit
/obj/item/clothing/head/helmet/space/rig/syndi/elite
	name = "elite syndicate hardsuit helmet"
	desc = "An elite version of the syndicate helmet, with improved armour and fire shielding. It is in travel mode. Property of Gorlex Marauders."
	icon_state = "rig0-syndielite"
	item_color = "syndielite"
	armor = list(melee = 60, bullet = 60, laser = 50, energy = 25, bomb = 55, bio = 100, rad = 70)
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT
	sprite_sheets = null

/obj/item/clothing/head/helmet/space/rig/syndi/elite/attack_self(mob/user)
	..()
	if(on)
		name = "elite syndicate hardsuit helmet"
		desc = "An elite version of the syndicate helmet, with improved armour and fire shielding. It is in travel mode. Property of Gorlex Marauders."
	else
		name = "elite syndicate hardsuit helmet (combat)"
		desc = "An elite version of the syndicate helmet, with improved armour and fire shielding. It is in combat mode. Property of Gorlex Marauders."

/obj/item/clothing/suit/space/rig/syndi/elite
	name = "elite syndicate hardsuit"
	desc = "An elite version of the syndicate hardsuit, with improved armour and fire shielding. It is in travel mode."
	icon_state = "rig0-syndielite"
	item_color = "syndielite"
	armor = list(melee = 60, bullet = 60, laser = 50, energy = 25, bomb = 55, bio = 100, rad = 70)
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT
	sprite_sheets = null

/obj/item/clothing/suit/space/rig/syndi/elite/attack_self(mob/user)
	..()
	if(on)
		name = "elite syndicate hardsuit"
		desc = "An elite version of the syndicate hardsuit, with improved armour and fire shielding. It is in travel mode. Property of Gorlex Marauders."
	else
		name = "elite syndicate hardsuit (combat)"
		desc = "An elite version of the syndicate hardsuit, with improved armour and fire shielding. It is in combat mode. Property of Gorlex Marauders."

//Wizard Rig
/obj/item/clothing/head/helmet/space/rig/wizard
	name = "gem-encrusted hardsuit helmet"
	desc = "A bizarre gem-encrusted helmet that radiates magical energies."
	icon_state = "rig0-wiz"
	item_state = "wiz_helm"
	item_color = "wiz"
	unacidable = 1 //No longer shall our kind be foiled by lone chemists with spray bottles!
	armor = list(melee = 40, bullet = 40, laser = 40, energy = 20, bomb = 35, bio = 100, rad = 50)
	heat_protection = HEAD												//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_HELM_MAX_TEMP_PROTECT
	unacidable = 1
	sprite_sheets = null

/obj/item/clothing/suit/space/rig/wizard
	icon_state = "rig-wiz"
	name = "gem-encrusted hardsuit"
	desc = "A bizarre gem-encrusted suit that radiates magical energies."
	item_state = "wiz_hardsuit"
	w_class = 3
	unacidable = 1
	armor = list(melee = 40, bullet = 40, laser = 40, energy = 20, bomb = 35, bio = 100, rad = 50)
	allowed = list(/obj/item/weapon/teleportation_scroll,/obj/item/weapon/tank)
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS					//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT
	unacidable = 1
	sprite_sheets = null

//Medical Rig
/obj/item/clothing/head/helmet/space/rig/medical
	name = "medical hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Built with lightweight materials for extra comfort, but does not protect the eyes from intense light."
	icon_state = "rig0-medical"
	item_state = "medical_helm"
	item_color = "medical"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES
	armor = list(melee = 10, bullet = 5, laser = 10, energy = 5, bomb = 10, bio = 100, rad = 50)
	flash_protect = 0
	scan_reagents = 1 //Generally worn by the CMO, so they'd get utility off of seeing reagents

/obj/item/clothing/suit/space/rig/medical
	icon_state = "rig-medical"
	name = "medical hardsuit"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Built with lightweight materials for extra comfort."
	item_state = "medical_hardsuit"
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/storage/firstaid,/obj/item/device/healthanalyzer,/obj/item/stack/medical,/obj/item/device/rad_laser)
	armor = list(melee = 10, bullet = 5, laser = 10, energy = 5, bomb = 10, bio = 100, rad = 50)

	//Security
/obj/item/clothing/head/helmet/space/rig/security
	name = "security hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has an additional layer of armor."
	icon_state = "rig0-sec"
	item_state = "sec_helm"
	item_color = "sec"
	armor = list(melee = 30, bullet = 15, laser = 30, energy = 10, bomb = 10, bio = 100, rad = 50)

/obj/item/clothing/suit/space/rig/security
	icon_state = "rig-sec"
	name = "security hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has an additional layer of armor."
	item_state = "sec_hardsuit"
	armor = list(melee = 30, bullet = 15, laser = 30, energy = 10, bomb = 10, bio = 100, rad = 50)
	allowed = list(/obj/item/weapon/gun,/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/melee/baton,/obj/item/weapon/reagent_containers/spray/pepper,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/weapon/restraints/handcuffs)


//Atmospherics Rig (BS12)
/obj/item/clothing/head/helmet/space/rig/atmos
	desc = "A special helmet designed for work in a hazardous, low pressure environments. Has improved thermal protection and minor radiation shielding."
	name = "atmospherics hardsuit helmet"
	icon_state = "rig0-atmos"
	item_state = "atmos_helm"
	item_color = "atmos"
	armor = list(melee = 10, bullet = 5, laser = 10, energy = 5, bomb = 10, bio = 100, rad = 0)
	heat_protection = HEAD												//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_HELM_MAX_TEMP_PROTECT

/obj/item/clothing/suit/space/rig/atmos
	desc = "A special suit that protects against hazardous, low pressure environments. Has improved thermal protection and minor radiation shielding."
	icon_state = "rig-atmos"
	name = "atmos hardsuit"
	item_state = "atmos_hardsuit"
	armor = list(melee = 10, bullet = 5, laser = 10, energy = 5, bomb = 10, bio = 100, rad = 0)
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS					//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT

//Singuloth armor
/obj/item/clothing/head/helmet/space/rig/singuloth
	name = "singuloth knight's helmet"
	desc = "This is an adamantium helmet from the chapter of the Singuloth Knights. It shines with a holy aura."
	icon_state = "rig0-singuloth"
	item_state = "singuloth_helm"
	item_color = "singuloth"
	armor = list(melee = 40, bullet = 5, laser = 20, energy = 5, bomb = 25, bio = 100, rad = 100)

/obj/item/clothing/suit/space/rig/singuloth
	icon_state = "rig-singuloth"
	name = "singuloth knight's armor"
	desc = "This is a ceremonial armor from the chapter of the Singuloth Knights. It's made of pure forged adamantium."
	item_state = "singuloth_hardsuit"
	flags = STOPSPRESSUREDMAGE
	armor = list(melee = 40, bullet = 5, laser = 20, energy = 5, bomb = 25, bio = 100, rad = 100)


/obj/item/clothing/head/helmet/space/rig/security/hos
	name = "head of security's hardsuit helmet"
	desc = "a special bulky helmet designed for work in a hazardous, low pressure environment. Has an additional layer of armor."
	icon_state = "rig0-hos"
	item_color = "hos"
	armor = list(melee = 45, bullet = 25, laser = 30,energy = 10, bomb = 25, bio = 100, rad = 50)
	sprite_sheets = null


/obj/item/clothing/suit/space/rig/security/hos
	icon_state = "rig-hos"
	name = "head of security's hardsuit"
	desc = "A special bulky suit that protects against hazardous, low pressure environments. Has an additional layer of armor."
	armor = list(melee = 45, bullet = 25, laser = 30, energy = 10, bomb = 25, bio = 100, rad = 50)
	sprite_sheets = null


/////////////SHIELDED//////////////////////////////////

/obj/item/clothing/suit/space/rig/shielded
	name = "shielded hardsuit"
	desc = "A hardsuit with built in energy shielding. Will rapidly recharge when not under fire."
	icon_state = "rig-hos"
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank, /obj/item/weapon/gun,/obj/item/weapon/reagent_containers/spray/pepper,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/restraints/handcuffs)
	armor = list(melee = 30, bullet = 15, laser = 30, energy = 10, bomb = 10, bio = 100, rad = 50)
	var/current_charges = 3
	var/max_charges = 3 //How many charges total the shielding has
	var/recharge_delay = 200 //How long after we've been shot before we can start recharging. 20 seconds here
	var/recharge_cooldown = 0 //Time since we've last been shot
	var/recharge_rate = 1 //How quickly the shield recharges once it starts charging
	var/shield_state = "shield-old"
	var/shield_on = "shield-old"
	sprite_sheets = null

/obj/item/clothing/suit/space/rig/shielded/hit_reaction(mob/living/carbon/human/owner, attack_text)
	if(current_charges > 0)
		var/datum/effect/system/spark_spread/s = new
		s.set_up(2, 1, src)
		s.start()
		owner.visible_message("<span class='danger'>[owner]'s shields deflect [attack_text] in a shower of sparks!</span>")
		current_charges--
		recharge_cooldown = world.time + recharge_delay
		processing_objects |= src
		if(current_charges <= 0)
			owner.visible_message("[owner]'s shield overloads!")
			shield_state = "broken"
			owner.update_inv_wear_suit()
		return 1
	return 0


/obj/item/clothing/suit/space/rig/shielded/Destroy()
	processing_objects.Remove(src)
	return ..()

/obj/item/clothing/suit/space/rig/shielded/process()
	if(world.time > recharge_cooldown && current_charges < max_charges)
		current_charges = Clamp((current_charges + recharge_rate), 0, max_charges)
		playsound(loc, 'sound/magic/Charge.ogg', 50, 1)
		if(current_charges == max_charges)
			playsound(loc, 'sound/machines/ding.ogg', 50, 1)
			processing_objects.Remove(src)
		shield_state = "[shield_on]"
		if(istype(loc, /mob/living/carbon/human))
			var/mob/living/carbon/human/C = loc
			C.update_inv_wear_suit()

//////Syndicate Version

/obj/item/clothing/suit/space/rig/shielded/syndi
	name = "blood-red hardsuit"
	desc = "An advanced hardsuit with built in energy shielding."
	icon_state = "rig1-syndi"
	item_state = "syndie_hardsuit"
	item_color = "syndi"
	armor = list(melee = 40, bullet = 50, laser = 30, energy = 15, bomb = 35, bio = 100, rad = 50)
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/melee/energy/sword/saber,/obj/item/weapon/restraints/handcuffs,/obj/item/weapon/tank)
	slowdown = 0
	sprite_sheets = list(
		"Unathi" = 'icons/mob/species/unathi/suit.dmi',
		"Tajaran" = 'icons/mob/species/tajaran/suit.dmi',
		"Skrell" = 'icons/mob/species/skrell/suit.dmi',
		"Vox" = 'icons/mob/species/vox/suit.dmi',
		"Vulpkanin" = 'icons/mob/species/vulpkanin/suit.dmi',
		"Drask" = 'icons/mob/species/drask/suit.dmi'
		)

/obj/item/clothing/head/helmet/space/rig/shielded/syndi
	name = "blood-red hardsuit helmet"
	desc = "An advanced hardsuit helmet with built in energy shielding."
	icon_state = "rig1-syndi"
	item_state = "syndie_helm"
	item_color = "syndi"
	armor = list(melee = 40, bullet = 50, laser = 30, energy = 15, bomb = 35, bio = 100, rad = 50)