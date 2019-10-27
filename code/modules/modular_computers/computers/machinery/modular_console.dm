/obj/machinery/modular_computer/console
	name = "console"
	desc = "A stationary computer."

	icon = 'icons/obj/modular_console.dmi'
	icon_state = "console"
	icon_state_powered = "console"
	icon_state_unpowered = "console-off"
	screen_icon_state_menu = "menu"
	hardware_flag = PROGRAM_CONSOLE
	anchored = 1
	density = 1
	base_idle_power_usage = 100
	base_active_power_usage = 500
	max_hardware_size = 4
	steel_sheet_cost = 10
	light_strength = 2
	max_integrity = 300
	integrity_failure = 150

	var/console_department = "" // Used in New() to set network tag according to our area.
	var/components = TRUE // Install basic components?

/obj/machinery/modular_computer/console/buildable
	components = FALSE

/obj/machinery/modular_computer/console/New()
	..()
	var/obj/item/computer_hardware/battery/battery_module = cpu.all_components[MC_CELL]
	if(battery_module)
		qdel(battery_module)

	if(components)
		var/obj/item/computer_hardware/network_card/wired/network_card = new()

		cpu.install_component(network_card)
		cpu.install_component(new /obj/item/computer_hardware/recharger/APC)
		cpu.install_component(new /obj/item/computer_hardware/hard_drive/super) // Consoles generally have better HDDs due to lower space limitations

		var/area/A = get_area(src)
		// Attempts to set this console's tag according to our area. Since some areas have stuff like "XX - YY" in their names we try to remove that too.
		if(A && console_department)
			network_card.identification_string = replacetext(replacetext(replacetext("[A.name] [console_department] Console", " ", "_"), "-", ""), "__", "_") // Replace spaces with "_"
		else if(A)
			network_card.identification_string = replacetext(replacetext(replacetext("[A.name] Console", " ", "_"), "-", ""), "__", "_")
		else if(console_department)
			network_card.identification_string = replacetext(replacetext(replacetext("[console_department] Console", " ", "_"), "-", ""), "__", "_")
		else
			network_card.identification_string = "Unknown Console"

	if(cpu)
		cpu.screen_on = 1
	update_icon()