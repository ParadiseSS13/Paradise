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

