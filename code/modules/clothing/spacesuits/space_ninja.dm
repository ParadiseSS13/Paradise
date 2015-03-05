/obj/item/clothing/head/helmet/space/space_ninja
	desc = "What may appear to be a simple black garment is in fact a highly sophisticated nano-weave helmet. Standard issue ninja gear."
	name = "ninja hood"
	icon_state = "s-ninja"
	item_state = "s-ninja_hood"
	armor = list(melee = 60, bullet = 60, laser = 45, energy = 15, bomb = 30, bio = 30, rad = 25)
	unacidable = 1
	siemens_coefficient = 0.2


/obj/item/clothing/mask/gas/voice/space_ninja
	name = "ninja mask"
	desc = "A close-fitting mask that acts both as an air filter and a post-modern fashion statement."
	icon_state = "s-ninja(norm)"
	item_state = "s-ninja_mask"
	unacidable = 1
	siemens_coefficient = 0.2

/obj/item/clothing/glasses/hud/space_ninja
	name = "vision enhancement implant"
	desc = "A high-tech ocular implant designed for Spider Clan operatives."
	icon_state = "cybereye-off"
	item_state = "eyepatch"
	flags = NODROP

	var/enabled = 0
	var/energyConsumption = 0
	var/antagHUDEnabled = 0
	var/mesonEnabled = 0
	var/materialEnabled = 0
	var/thermalEnabled = 0

/obj/item/clothing/glasses/hud/space_ninja/process_hud(var/mob/M) // Antag HUD processing.

	if(antagHUDEnabled) // We only process if the antag-vision mode is enabled.
		if(!M)	return
		if(!M.client)	return
		var/client/C = M.client
		for(var/mob/living/carbon/human/target in view(get_turf(M)))
			if(M.see_invisible < target.invisibility)
				continue
			if(!C) continue
			C.images += target.hud_list[SPECIALROLE_HUD]

/obj/item/clothing/glasses/hud/space_ninja/verb/modifyHUD(mob/user as mob)
	set category = "Space Ninja - Equiptment"
	set name = "Modify Vision"

	if(enabled) // If the Ninja's suit is on and connected.
		if(usr.mind.special_role != "Ninja")
			usr << "<span style='color: #ff0000;'><b>FÄ†AL ï¿½Rrï¿½R</b>: µ§er n¤t rec¤gnized, c-c¤ntr-r¤£§-£§ £¤cked."

		if(!user) // The user var is, so far as I can tell, required to refresh the window after each click.
			user = usr

		/*
		 * Each vision type the Ninja enables will drain more from his suit's battery per tick.
		 * For instance, if the Ninja were to rn around with thermals and AntagHUD on he would be losing an additional 10 energy per tick.
		 * Current vision modes are:
		 *  - Night
		 *  - Meson (Turfs)
		 *  - Material (Objects)
		 *  - Thermal (Mobs)
		 *  - Antag HUD
		 *
		 * -Dave
		 */
		var/dat = {"
		<center>Night Vision (2E) - <a href='?src=\ref[src];night=night'>[darkness_view ? "ENABLED" : "DISABLED"]</a><br>
		Meson Scanner (2E) - <a href='?src=\ref[src];meson=meson'>[mesonEnabled ? "ENABLED" : "DISABLED"]</a><br>
		Material Scanner (4E) - <a href='?src=\ref[src];material=material'>[materialEnabled ? "ENABLED" : "DISABLED"]</a><br>
		Thermal Scanner (4E) - <a href='?src=\ref[src];thermal=thermal'>[thermalEnabled ? "ENABLED" : "DISABLED"]</a><br>
		Threat Identification HUD (6E) - <a href='?src=\ref[src];antagHUD=antagHUD'>[antagHUDEnabled ? "ENABLED" : "DISABLED"]</a></center>
		"}

		var/datum/browser/popup = new(user, "SpiderOS", "SpiderOS Optical Interface", 310, 150)
		popup.set_content(dat)
		popup.open()
	else
		usr << "<span style='color: #ff0000;'><b>ERROR: </b>No power supply detected, cannot activate optical implant.</span>"


/obj/item/clothing/glasses/hud/space_ninja/Topic(href, href_list)
	if(usr.stat != 0 || !enabled)
		return 1

	if(href_list["night"])
		darkness_view = (darkness_view ? 0 : 8)
		energyConsumption += (darkness_view ? 2 : -2)
		usr << "Light amplification <span style='color: #0000ff;'><b>[(darkness_view ? "ENABLED" : "DISABLED")]</b></span>."

	else if(href_list["meson"])
		mesonEnabled = (mesonEnabled ? 0 : 1)

		if(mesonEnabled)
			vision_flags |= SEE_TURFS
		else
			vision_flags &= ~SEE_TURFS

		energyConsumption += (mesonEnabled ? 2 : -2)
		usr << "Meson scanning <span style='color: #0000ff;'><b>[(mesonEnabled ? "ENABLED" : "DISABLED")]</b></span>."

	else if(href_list["material"])
		materialEnabled = (materialEnabled ? 0 : 1)

		if(materialEnabled)
			vision_flags |= SEE_OBJS
		else
			vision_flags &= ~SEE_OBJS

		energyConsumption += (materialEnabled ? 4 : -4)
		usr << "Material scanning <span style='color: #0000ff;'><b>[(materialEnabled ? "ENABLED" : "DISABLED")]</b></span>."

	else if(href_list["thermal"])
		thermalEnabled = (thermalEnabled ? 0 : 1)

		if(thermalEnabled)
			vision_flags |= SEE_MOBS
			invisa_view = 2
		else
			vision_flags &= ~SEE_MOBS
			invisa_view = 0

		energyConsumption += (thermalEnabled ? 4 : -4)
		usr << "Thermal scanning <span style='color: #0000ff;'><b>[(thermalEnabled ? "ENABLED" : "DISABLED")]</b></span>."

	else if(href_list["antagHUD"])
		antagHUDEnabled = (antagHUDEnabled ? 0 : 1)
		energyConsumption += (antagHUDEnabled ? 6 : -6)
		usr << "Threat identification HUD <span style='color: #0000ff;'><b>[(antagHUDEnabled ? "ENABLED" : "DISABLED")]</b></span>."

	modifyHUD(usr) // Re-call the verb to get a fresh version of the window.
	return

/obj/item/clothing/suit/space/space_ninja
	name = "ninja suit"
	desc = "A unique, vaccum-proof suit of nano-enhanced armor designed specifically for Spider Clan assassins."
	icon_state = "s-ninja"
	item_state = "s-ninja_suit"
	allowed = list(/obj/item/weapon/gun, /obj/item/ammo_box, /obj/item/weapon/melee/baton, /obj/item/weapon/tank, /obj/item/weapon/stock_parts/cell)
	slowdown = 0
	unacidable = 1
	armor = list(melee = 60, bullet = 60, laser = 45,energy = 15, bomb = 30, bio = 30, rad = 30)
	siemens_coefficient = 0.2

	var/suitActive = 0
	var/suitBusy = 0

	var/obj/item/weapon/stock_parts/cell/suitCell
	var/obj/item/clothing/head/helmet/space/space_ninja/suitHood
	var/obj/item/clothing/gloves/space_ninja/suitGloves
	var/obj/item/clothing/shoes/space_ninja/suitShoes
	var/obj/item/clothing/mask/gas/voice/space_ninja/suitMask
	var/obj/item/clothing/glasses/space_ninja/suitGlasses
	var/mob/living/carbon/human/suitOccupant

/obj/item/clothing/suit/space/space_ninja/New()
	suitCell = /obj/item/weapon/stock_parts/cell/ninja // The Ninja starts out with a 10,000 energy cell.


/obj/item/clothing/gloves/space_ninja
	desc = "These nano-enhanced gloves insulate from electricity and provide fire resistance."
	name = "ninja gloves"
	icon_state = "s-ninja"
	item_state = "s-ninja"
	siemens_coefficient = 0
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE
	transfer_prints = FALSE


/obj/item/clothing/shoes/space_ninja
	name = "ninja shoes"
	desc = "A pair of running shoes. Excellent for running and even better for smashing skulls."
	icon_state = "s-ninja"
	permeability_coefficient = 0.01
	flags = NOSLIP
	armor = list(melee = 60, bullet = 60, laser = 45,energy = 15, bomb = 30, bio = 30, rad = 30)
	siemens_coefficient = 0.2
	cold_protection = FEET
	min_cold_protection_temperature = SHOE_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = FEET
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE


/obj/item/clothing/suit/space/space_ninja/verb/toggle_suit()
	set category = "Space Ninja - Equiptment"
	set name = "Toggle Suit"

	if(usr.mind.special_role == "Ninja")
		if(suitBusy)
			usr << "<span style='color: #ff0000;'><b>ERROR: </b>Suit systems busy, cannot initiate <b>[suitActive ? "de-activation" : "activation"]</b> protocals.</span>"
			return

		suitBusy = 1
		if(suitActive && (alert("Confirm suit systems shutdown? This cannot be halted once it has started", "Confirm Shutdown", "Yes", "No") == "Yes"))
			usr << ""
		else if(!suitActive) // Activate the suit.
			usr << ""
		else
			suitBusy = 0
			usr << "<span style='color: #0000ff;'><b>NOTICE: </b>Suit de-activation protocals aborted.</span>"
	else
		usr << "<span style='color: #ff0000;'><b>FÄ†AL ï¿½Rrï¿½R</b>: µ§er n¤t rec¤gnized, c-c¤ntr-r¤£§-£§ £¤cked."
		return