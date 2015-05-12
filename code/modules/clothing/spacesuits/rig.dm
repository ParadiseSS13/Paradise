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
	_color = "engineering" //Determines used sprites: rig[on]-[color] and rig[on]-[color]2 (lying down sprite)
	action_button_name = "Toggle Helmet Light"

	//Species-specific stuff.
	species_restricted = list("exclude","Unathi","Tajaran","Skrell","Diona","Vox")
	sprite_sheets = list(
		"Unathi" = 'icons/mob/species/unathi/helmet.dmi',
		"Tajaran" = 'icons/mob/species/tajaran/helmet.dmi',
		"Skrell" = 'icons/mob/species/skrell/helmet.dmi',
		"Vox" = 'icons/mob/species/vox/helmet.dmi',
		)
	sprite_sheets_obj = list(
		"Unathi" = 'icons/obj/clothing/species/unathi/hats.dmi',
		"Tajaran" = 'icons/obj/clothing/species/tajaran/hats.dmi',
		"Skrell" = 'icons/obj/clothing/species/skrell/hats.dmi',
		"Vox" = 'icons/obj/clothing/species/vox/hats.dmi',
		)

	attack_self(mob/user)
		if(!isturf(user.loc))
			user << "You cannot turn the light on while in this [user.loc]" //To prevent some lighting anomalities.
			return
		on = !on
		icon_state = "rig[on]-[_color]"
//		item_state = "rig[on]-[color]"

		if(on)	set_light(brightness_on)
		else	set_light(0)

		if(istype(user,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = user
			H.update_inv_head()

/obj/item/clothing/suit/space/rig
	name = "hardsuit"
	desc = "A special space suit for environments that might pose hazards beyond just the vacuum of space. Provides more protection than a standard space suit."
	icon_state = "rig-engineering"
	item_state = "eng_hardsuit"
	slowdown = 2
	armor = list(melee = 10, bullet = 5, laser = 10, energy = 5, bomb = 10, bio = 100, rad = 75)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/device/t_scanner, /obj/item/weapon/rcd)

	species_restricted = list("exclude","Unathi","Tajaran","Skrell","Diona","Vox")
	sprite_sheets = list(
		"Unathi" = 'icons/mob/species/unathi/suit.dmi',
		"Tajaran" = 'icons/mob/species/tajaran/suit.dmi',
		"Skrell" = 'icons/mob/species/skrell/suit.dmi',
		"Vox" = 'icons/mob/species/vox/suit.dmi',
		)
	sprite_sheets_obj = list(
		"Unathi" = 'icons/obj/clothing/species/unathi/suits.dmi',
		"Tajaran" = 'icons/obj/clothing/species/tajaran/suits.dmi',
		"Skrell" = 'icons/obj/clothing/species/skrell/suits.dmi',
		"Vox" = 'icons/obj/clothing/species/vox/suits.dmi',
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

	if(H.wear_suit != src)
		return

	if(attached_helmet && helmet)
		if(H.head)
			M << "You are unable to deploy your suit's helmet as \the [H.head] is in the way."
		else
			M << "Your suit's helmet deploys with a hiss."
			//TODO: Species check, skull damage for forcing an unfitting helmet on?
			helmet.loc = H
			H.equip_to_slot(helmet, slot_head)
			helmet.flags |= NODROP

	if(attached_boots && boots)
		if(H.shoes)
			M << "You are unable to deploy your suit's magboots as \the [H.shoes] are in the way."
		else
			M << "Your suit's boots deploy with a hiss."
			boots.loc = H
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
				helmet.loc = src

	if(boots)
		H = boots.loc
		if(istype(H))
			if(boots && H.shoes == boots)
				boots.flags &= ~NODROP
				H.unEquip(boots)
				boots.loc = src

/*
/obj/item/clothing/suit/space/rig/verb/get_mounted_device()

	set name = "Deploy Mounted Device"
	set category = "Object"
	set src in usr

	if(!can_mount)
		verbs -= /obj/item/clothing/suit/space/rig/verb/get_mounted_device
		verbs -= /obj/item/clothing/suit/space/rig/verb/stow_mounted_device
		return

	if(!istype(usr, /mob/living)) return
	if(usr.stat) return

	if(active_device)
		usr << "You already have \the [active_device] deployed."
		return

	if(!mounted_devices.len)
		usr << "You do not have any devices mounted on \the [src]."
		return

/obj/item/clothing/suit/space/rig/verb/stow_mounted_device()

	set name = "Stow Mounted Device"
	set category = "Object"
	set src in usr

	if(!can_mount)
		verbs -= /obj/item/clothing/suit/space/rig/verb/get_mounted_device
		verbs -= /obj/item/clothing/suit/space/rig/verb/stow_mounted_device
		return

	if(!istype(usr, /mob/living)) return

	if(usr.stat) return

	if(!active_device)
		usr << "You have no device currently deployed."
		return
*/

/obj/item/clothing/suit/space/rig/verb/toggle_helmet()

	set name = "Toggle Helmet"
	set category = "Object"
	set src in usr

	if(!istype(src.loc,/mob/living)) return

	if(!helmet)
		usr << "There is no helmet installed."
		return

	var/mob/living/carbon/human/H = usr

	if(!istype(H)) return
	if(H.stat) return
	if(H.wear_suit != src) return

	if(H.head == helmet)
		helmet.flags &= ~NODROP
		H.unEquip(helmet)
		helmet.loc = src
		H << "\blue You retract your hardsuit helmet."
	else
		if(H.head)
			H << "\red You cannot deploy your helmet while wearing another helmet."
			return
		//TODO: Species check, skull damage for forcing an unfitting helmet on?
		helmet.loc = H
		helmet.pickup(H)
		H.equip_to_slot(helmet, slot_head)
		helmet.flags |= NODROP
		H << "\blue You deploy your hardsuit helmet, sealing you off from the world."
	H.update_inv_head()

/obj/item/clothing/suit/space/rig/attackby(obj/item/W as obj, mob/user as mob, params)

	if(!istype(user,/mob/living)) return

	if(user.a_intent == "help")

		if(istype(src.loc,/mob/living))
			user << "How do you propose to modify a hardsuit while it is being worn?"
			return

		var/target_zone = user.zone_sel.selecting

		if(target_zone == "head")

			//Installing a component into or modifying the contents of the helmet.
			if(!attached_helmet)
				user << "\The [src] does not have a helmet mount."
				return

			if(istype(W,/obj/item/weapon/screwdriver))
				if(!helmet)
					user << "\The [src] does not have a helmet installed."
				else
					user << "You detach \the [helmet] from \the [src]'s helmet mount."
					helmet.loc = get_turf(src)
					src.helmet = null
				return
			else if(istype(W,/obj/item/clothing/head/helmet/space))
				if(helmet)
					user << "\The [src] already has a helmet installed."
				else
					user << "You attach \the [W] to \the [src]'s helmet mount."
					user.drop_item()
					W.loc = src
					src.helmet = W
				return
			else
				return ..()

		else if(target_zone == "l_leg" || target_zone == "r_leg" || target_zone == "l_foot" || target_zone == "r_foot")

			//Installing a component into or modifying the contents of the feet.
			if(!attached_boots)
				user << "\The [src] does not have boot mounts."
				return

			if(istype(W,/obj/item/weapon/screwdriver))
				if(!boots)
					user << "\The [src] does not have any boots installed."
				else
					user << "You detatch \the [boots] from \the [src]'s boot mounts."
					boots.loc = get_turf(src)
					boots = null
				return
			else if(istype(W,/obj/item/clothing/shoes/magboots))
				if(boots)
					user << "\The [src] already has magboots installed."
				else
					user << "You attach \the [W] to \the [src]'s boot mounts."
					user.drop_item()
					W.loc = src
					boots = W
			else
				return ..()

		/*
		else if(target_zone == "l_arm" || target_zone == "r_arm" || target_zone == "l_hand" || target_zone == "r_hand")

			//Installing a component into or modifying the contents of the hands.

		else if(target_zone == "torso" || target_zone == "groin")

			//Modifying the cell or mounted devices

			if(!mounted_devices)
				return
		*/

		else //wat
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
	slowdown = 2
	armor = list(melee = 10, bullet = 5, laser = 10, energy = 5, bomb = 10, bio = 100, rad = 75)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/device/t_scanner, /obj/item/weapon/rcd)

//Chief Engineer's rig
/obj/item/clothing/head/helmet/space/rig/elite
	name = "advanced hardsuit helmet"
	desc = "An advanced helmet designed for work in a hazardous, low pressure environment. Shines with a high polish."
	icon_state = "rig0-white"
	item_state = "ce_helm"
	_color = "white"
	sprite_sheets = null
	armor = list(melee = 40, bullet = 5, laser = 10, energy = 5, bomb = 50, bio = 100, rad = 90)
	heat_protection = HEAD												//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_HELM_MAX_TEMP_PROTECT

/obj/item/clothing/suit/space/rig/elite
	icon_state = "rig-white"
	name = "advanced hardsuit"
	desc = "An advanced suit that protects against hazardous, low pressure environments. Shines with a high polish."
	item_state = "ce_hardsuit"
	sprite_sheets = null
	armor = list(melee = 40, bullet = 5, laser = 10, energy = 5, bomb = 50, bio = 100, rad = 90)
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS					//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT

//Mining rig
/obj/item/clothing/head/helmet/space/rig/mining
	name = "mining hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has reinforced plating."
	icon_state = "rig0-mining"
	item_state = "mining_helm"
	_color = "mining"
	flags = HEADCOVERSEYES | BLOCKHAIR | HEADCOVERSMOUTH | STOPSPRESSUREDMAGE
	armor = list(melee = 40, bullet = 5, laser = 10, energy = 5, bomb = 50, bio = 100, rad = 50)

/obj/item/clothing/suit/space/rig/mining
	icon_state = "rig-mining"
	name = "mining hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has reinforced plating."
	item_state = "mining_hardsuit"
	armor = list(melee = 40, bullet = 5, laser = 10, energy = 5, bomb = 50, bio = 100, rad = 50)
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/storage/bag/ore,/obj/item/weapon/pickaxe)


//Syndicate rig
/obj/item/clothing/head/helmet/space/rig/syndi
	name = "blood-red hardsuit helmet"
	desc = "A dual-mode advanced helmet designed for work in special operations. It is in travel mode. Property of Gorlex Marauders."
	icon_state = "hardsuit1-syndi"
	item_state = "syndie_helm"
	_color = "syndi"
	armor = list(melee = 60, bullet = 50, laser = 30, energy = 15, bomb = 35, bio = 100, rad = 50)
	on = 1
	flags = HEADCOVERSEYES | BLOCKHAIR | HEADCOVERSMOUTH | STOPSPRESSUREDMAGE | THICKMATERIAL
	action_button_name = "Toggle Helmet Mode"
	species_restricted = null
	sprite_sheets = null

/obj/item/clothing/head/helmet/space/rig/syndi/update_icon()
	icon_state = "hardsuit[on]-[_color]"

/obj/item/clothing/head/helmet/space/rig/syndi/attack_self(mob/user)
	if(!isturf(user.loc))
		user << "You cannot toggle your helmet while in this [user.loc]" //To prevent some lighting anomalities.
		return
	on = !on
	if(on)
		user << "<span class='notice'>You switch your helmet to travel mode.</span>"
		name = "blood-red hardsuit helmet"
		desc = "A dual-mode advanced helmet designed for work in special operations. It is in travel mode. Property of Gorlex Marauders."
		flags = HEADCOVERSEYES | BLOCKHAIR | HEADCOVERSMOUTH | STOPSPRESSUREDMAGE | THICKMATERIAL
		flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
		cold_protection = HEAD
		set_light(brightness_on)
	else
		user << "<span class='notice'>You switch your helmet to combat mode.</span>"
		name = "blood-red hardsuit helmet (combat)"
		desc = "A dual-mode advanced helmet designed for work in special operations. It is in combat mode. Property of Gorlex Marauders."
		flags = BLOCKHAIR
		flags_inv = HIDEEARS
		cold_protection = null
		set_light(0)

	update_icon()
	playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
	user.update_inv_head()

/obj/item/clothing/suit/space/rig/syndi
	name = "blood-red hardsuit"
	desc = "A dual-mode advanced hardsuit designed for work in special operations. It is in travel mode. Property of Gorlex Marauders."
	icon_state = "hardsuit1-syndi"
	item_state = "syndie_hardsuit"
	_color = "syndi"
	slowdown = 1
	w_class = 3
	var/on = 1
	action_button_name = "Toggle Hardsuit Mode"
	armor = list(melee = 60, bullet = 50, laser = 30, energy = 15, bomb = 35, bio = 100, rad = 50)
	allowed = list(/obj/item/weapon/gun,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/weapon/melee/baton,/obj/item/weapon/melee/energy/sword,/obj/item/weapon/restraints/handcuffs,/obj/item/weapon/tank)
	species_restricted = null
	sprite_sheets = null

/obj/item/clothing/suit/space/rig/syndi/update_icon()
	icon_state = "hardsuit[on]-[_color]"

/obj/item/clothing/suit/space/rig/syndi/attack_self(mob/user)
	on = !on
	if(on)
		user << "<span class='notice'>You switch your hardsuit to travel mode.</span>"
		name = "blood-red hardsuit helmet"
		desc = "A dual-mode advanced hardsuit designed for work in special operations. It is in travel mode. Property of Gorlex Marauders."
		slowdown = 1
		flags = STOPSPRESSUREDMAGE | THICKMATERIAL
		flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
		cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	else
		user << "<span class='notice'>You switch your hardsuit to combat mode.</span>"
		name = "blood-red hardsuit helmet (combat)"
		desc = "A dual-mode advanced hardsuit designed for work in special operations. It is in combat mode. Property of Gorlex Marauders."
		slowdown = 0
		flags = BLOCKHAIR
		flags_inv = null
		cold_protection = null

	update_icon()
	playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
	user.update_inv_wear_suit()
	user.update_inv_w_uniform()

//Wizard Rig
/obj/item/clothing/head/helmet/space/rig/wizard
	name = "gem-encrusted hardsuit helmet"
	desc = "A bizarre gem-encrusted helmet that radiates magical energies."
	icon_state = "rig0-wiz"
	item_state = "wiz_helm"
	_color = "wiz"
	unacidable = 1 //No longer shall our kind be foiled by lone chemists with spray bottles!
	armor = list(melee = 40, bullet = 20, laser = 20,energy = 20, bomb = 35, bio = 100, rad = 60)
	siemens_coefficient = 0.7
	heat_protection = HEAD												//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_HELM_MAX_TEMP_PROTECT
	unacidable = 1
	sprite_sheets = null

/obj/item/clothing/suit/space/rig/wizard
	icon_state = "rig-wiz"
	name = "gem-encrusted hardsuit"
	desc = "A bizarre gem-encrusted suit that radiates magical energies."
	item_state = "wiz_hardsuit"
	slowdown = 1
	w_class = 3
	unacidable = 1
	armor = list(melee = 40, bullet = 20, laser = 20, energy = 20, bomb = 35, bio = 100, rad = 50)
	allowed = list(/obj/item/weapon/teleportation_scroll,/obj/item/weapon/tank)
	heat_protection = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS					//Uncomment to enable firesuit protection
	max_heat_protection_temperature = FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT
	unacidable = 1
	siemens_coefficient = 0.7
	sprite_sheets = null

//Medical Rig
/obj/item/clothing/head/helmet/space/rig/medical
	name = "medical hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Built with lightweight materials for extra comfort, but does not protect the eyes from intense light."
	icon_state = "rig0-medical"
	item_state = "medical_helm"
	_color = "medical"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES
	armor = list(melee = 10, bullet = 5, laser = 10, energy = 5, bomb = 10, bio = 100, rad = 50)
	flash_protect = 0

/obj/item/clothing/suit/space/rig/medical
	icon_state = "rig-medical"
	name = "medical hardsuit"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Built with lightweight materials for extra comfort."
	item_state = "medical_hardsuit"
	slowdown = 1
	allowed = list(/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/storage/firstaid,/obj/item/device/healthanalyzer,/obj/item/stack/medical)
	armor = list(melee = 10, bullet = 5, laser = 10, energy = 5, bomb = 10, bio = 100, rad = 50)

	//Security
/obj/item/clothing/head/helmet/space/rig/security
	name = "security hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low pressure environment. Has an additional layer of armor."
	icon_state = "rig0-sec"
	item_state = "sec_helm"
	_color = "sec"
	armor = list(melee = 30, bullet = 15, laser = 30,energy = 10, bomb = 10, bio = 100, rad = 50)
	siemens_coefficient = 0.7

/obj/item/clothing/suit/space/rig/security
	icon_state = "rig-sec"
	name = "security hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has an additional layer of armor."
	item_state = "sec_hardsuit"
	armor = list(melee = 30, bullet = 15, laser = 30, energy = 10, bomb = 10, bio = 100, rad = 50)
	allowed = list(/obj/item/weapon/gun,/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/weapon/melee/baton,/obj/item/weapon/reagent_containers/spray/pepper,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/weapon/restraints/handcuffs)
	siemens_coefficient = 0.7


//Atmospherics Rig (BS12)
/obj/item/clothing/head/helmet/space/rig/atmos
	desc = "A special helmet designed for work in a hazardous, low pressure environments. Has improved thermal protection and minor radiation shielding."
	name = "atmospherics hardsuit helmet"
	icon_state = "rig0-atmos"
	item_state = "atmos_helm"
	_color = "atmos"
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
	_color = "singuloth"
	armor = list(melee = 40, bullet = 5, laser = 20,energy = 5, bomb = 25, bio = 100, rad = 100)

/obj/item/clothing/suit/space/rig/singuloth
	icon_state = "rig-singuloth"
	name = "singuloth knight's armor"
	desc = "This is a ceremonial armor from the chapter of the Singuloth Knights. It's made of pure forged adamantium."
	item_state = "singuloth_hardsuit"
	flags = STOPSPRESSUREDMAGE
	armor = list(melee = 40, bullet = 5, laser = 20,energy = 5, bomb = 25, bio = 100, rad = 100)
