// ** BEGIN NINJA CLOTHING DEFINES **

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
	var/obj/item/clothing/glasses/hud/space_ninja/suitGlasses
	var/mob/living/carbon/human/suitOccupant

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

// ** END NINJA CLOTHING DEFINES **

// ** BEGIN NINJA SUIT PROCS **

/obj/item/clothing/suit/space/space_ninja/New()
	suitCell = new/obj/item/weapon/stock_parts/cell/ninja // The Ninja starts out with a 10,000 energy cell.
	if(suitCell.charge != suitCell.maxcharge)
		suitCell.charge = suitCell.maxcharge

/obj/item/clothing/suit/space/space_ninja/verb/toggle_suit()
	set category = "Space Ninja - Equiptment"
	set name = "Toggle Suit"

	if(usr.mind.special_role == "Ninja")
		if(suitBusy)
			usr << "<span style='color: #ff0000;'><b>ERROR: </b>Suit systems busy, cannot initiate [suitActive ? "de-activation" : "activation"] protocals at this time.</span>"
			return

		suitBusy = 1

		if(suitActive && (alert("Confirm suit systems shutdown? This cannot be halted once it has started.", "Confirm Shutdown", "Yes", "No") == "Yes"))
			usr << "<span style='color: #0000ff;'>Now de-initializing...</span>"

			sleep(15)
			usr << "<span style='color: #0000ff;'>Logging off, [usr.real_name]. Shutting down <b>SpiderOS</b>.</span>"

			sleep(10)
			usr<< "<span style='color: #0000ff;'>Primary system status: <B>OFFLINE</B>.\nBackup system status: <b>OFFLINE</b>.</span>"

			sleep(5)
			usr<< "<span style='color: #0000ff;'>VOID-shift device status: <B>OFFLINE</B>.\nCLOAK-tech device status: <B>OFFLINE</B>.</span>"
			//TODO: Shut down any active abilities

			sleep(10)
			usr<< "<span style='color: #0000ff;'>Disconnecting neural-net interface...</span> <span style='color: #32CD32'><b>Success</b>.</span>"
			usr.hud_used.instantiate()
			usr.regenerate_icons()

			sleep(5)
			usr<< "<span style='color: #0000ff;'>Disengaging neural-net interface...</span> <span style='color: #32CD32'><b>Success</b>.</span>"

			sleep(10)
			usr<< "<span style='color: #0000ff;'>Unsecuring external locking mechanism...\nNeural-net abolished.\nOperation status: <B>FINISHED</B>.</span>"
			//TODO: Grant verbs
			toggle_suit_lock(usr)
			usr.regenerate_icons()
			suitBusy = 0
			suitActive = 0

		else if(!suitActive) // Activate the suit.
			usr << "<span style='color: #0000ff;'>Now initializing...</span>"

			sleep(15)
			usr<< "<span style='color: #0000ff;'>Now establishing neural-net interface..."
			if(usr.mind.special_role != "Ninja")
				usr << "<span style='color: #ff0000;'><b>FÄ†AL ï¿½Rrï¿½R</b>: µ§er n¤t rec¤gnized, c-c¤ntr-r¤£§-£§ £¤cked."
				return

			sleep(10)
			usr<< "<span style='color: #0000ff;'>Neural-net established. Now monitoring brainwave pattern. \nBrainwave pattern</span> <span style='color: #32CD32;'><b>GREEN</b></span><span style='color: #0000ff;'>, proceeding.</span>"

			sleep(10)
			usr<< "<span style='color: #0000ff;'>Securing external locking mechanism...</span>"
			if(!toggle_suit_lock(usr))
				return

			sleep(5)
			usr<< "<span style='color: #0000ff;'>Suit secured, extending neural-net interface...</span>"
			usr.hud_used.human_hud('icons/mob/screen1_NinjaHUD.dmi',"#ffffff",255)
			usr.regenerate_icons()

			sleep(10)
			usr<< "<span style='color: #0000ff;'>VOID-shift device status: <b>ONLINE</b>.\nCLOAK-tech device status:<b>ONLINE</b></span>"

			sleep(5)
			usr<< "<span style='color: #0000ff;'>Primary system status: <b>ONLINE</b>.\nBackup system status: <b>ONLINE</b>.\nCurrent energy capacity: <b>[suitCell.charge]/[suitCell.maxcharge]</b>.</span>"

			sleep(10)
			usr<< "<span style='color: #0000ff;'>All systems operational. Welcome to <b>SpiderOS</b>, [usr.real_name].</span>"
			//TODO: Grant ninja verbs here.
			suitBusy = 0
			suitActive = 1

		else
			suitBusy = 0
			usr << "<span style='color: #0000ff;'><b>NOTICE: </b>Suit de-activation protocals aborted.</span>"
	else
		usr << "<span style='color: #ff0000;'><b>FÄ†AL ï¿½Rrï¿½R</b>: µ§er n¤t rec¤gnized, c-c¤ntr-r¤£§-£§ £¤cked."
		return

/obj/item/clothing/suit/space/space_ninja/proc/toggle_suit_lock(mob/living/carbon/human/user)
	if(!suitActive)
		if(!istype(user.wear_suit, /obj/item/clothing/suit/space/space_ninja))
			user<< "<span style='color: #ff0000;'><b>ERROR:</b> Unable to locate user.\nABORTING...</span>"
			return 0
		if(!istype(user.head, /obj/item/clothing/head/helmet/space/space_ninja))
			user<< "<span style='color: #ff0000;'><b>ERROR:</b> Unable to locate hood.\nABORTING...</span>"
			return 0
		if(!istype(user.gloves, /obj/item/clothing/gloves/space_ninja))
			user<< "<span style='color: #ff0000;'><b>ERROR:</b> Unable to locate gloves.\nABORTING...</span>"
			return 0
		if(!istype(user.shoes, /obj/item/clothing/shoes/space_ninja))
			user<< "<span style='color: #ff0000;'><b>ERROR:</b> Unable to locate foot gear.\nABORTING...</span>"
			return 0
		if(!istype(user.wear_mask, /obj/item/clothing/mask/gas/voice/space_ninja))
			user<< "<span style='color: #ff0000;'><b>ERROR:</b> Unable to locate mask.\nABORTING...</span>"
			return 0
		if(!istype(user.glasses, /obj/item/clothing/glasses/hud/space_ninja))
			user<< "<span style='color: #ff0000;'><b>WARNING:</b> Unable to locate eye gear, vision enhancement unavailable.</span><span style='color: #0000ff;'>\nProceeding...</span>"
		else
			suitGlasses = user.glasses
			suitGlasses.enabled = 1
			suitGlasses.icon_state = "cybereye-green"

		suitHood = user.head
		suitMask = user.wear_mask
		suitGloves = user.gloves
		suitShoes = user.shoes
		suitOccupant = user

		flags |= NODROP
		suitHood.flags |= NODROP
		suitMask.flags |= NODROP
		suitGloves.flags |= NODROP
		suitGloves.pickpocket = 1
		suitShoes.flags |= NODROP
		suitShoes.slowdown = -2

		icon_state = (user.gender == MALE ? "s-ninjan" : "s-ninjanf")
		suitGloves.icon_state = "s-ninjan"
		suitGloves.item_state = "s-ninjan"

		return 1

	else
		flags &= ~NODROP
		suitHood.flags &= ~NODROP
		suitMask.flags &= ~NODROP
		if(suitGlasses)
			suitGlasses.enabled = 0
			suitGlasses.icon_state = "cybereye-off"
		suitGloves.flags &= ~NODROP
		suitGloves.pickpocket = 0
		suitShoes.flags &= ~NODROP
		suitShoes.slowdown = -1
		icon_state = "s-ninja"
		suitGloves.icon_state = "s-ninja"
		suitGloves.item_state = "s-ninja"

		suitHood = null
		suitMask = null
		suitGlasses = null
		suitGloves = null
		suitShoes = null
		suitOccupant = null

		return 1

// ** END NINJA SUIT PROCS **

// **BEGIN NINJA GLASSES PROCS**

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

	if(usr.mind.special_role != "Ninja")
		usr << "<span style='color: #ff0000;'><b>FÄ†AL ï¿½Rrï¿½R</b>: µ§er n¤t rec¤gnized, c-c¤ntr-r¤£§-£§ £¤cked."
		return

	if(!enabled) // If the Ninja's suit is on and connected.
		usr << "<span style='color: #ff0000;'><b>ERROR: </b>No power supply detected, cannot activate optical implant.</span>"
		return

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


/obj/item/clothing/glasses/hud/space_ninja/Topic(href, href_list)
	if(usr.stat != 0 || !enabled)
		return 1

	if(href_list["night"])
		darkness_view = (darkness_view ? 0 : 8)
		see_darkness = (darkness_view ? 0 : 1)
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

// **END NINJA GLASSES PROCS**