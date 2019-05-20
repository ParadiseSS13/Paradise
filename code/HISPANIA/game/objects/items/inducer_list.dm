// este proc devuelve un atomo de celda de cada objeto que use una, estan compilados en esta lista.
// actualemte hay un pr en paradise que esta haciendo este trabajo. bastaria con borrar este dm para que no hayan codigos duplicados

/atom/movable/proc/get_cell()
	return

/obj/item/stock_parts/cell/get_cell()
	return src

/obj/mecha/get_cell()
	return cell

/mob/living/silicon/robot/get_cell()
	return cell

/obj/machinery/power/apc/get_cell()
	return cell

/obj/machinery/space_heater/get_cell()
	return cell


/obj/item/defibrillator/get_cell()
	return bcell

/obj/machinery/defibrillator_mount/get_cell()
	if(defib)
		return defib.get_cell()

/obj/item/melee/baton/get_cell()
	return bcell

/obj/item/modular_computer/get_cell()
	var/obj/item/computer_hardware/battery/battery_module = all_components[MC_CELL]
	if(battery_module && battery_module.battery)
		return battery_module.battery

/obj/machinery/chem_dispenser/get_cell()
	return cell

/obj/item/bodyanalyzer/get_cell()
	return power_supply


/obj/machinery/floodlight/get_cell()
	return cell

/obj/item/clothing/gloves/color/yellow/stun/get_cell()
	return cell

/obj/item/rig/get_cell()
	return cell

/mob/living/simple_animal/bot/mulebot/get_cell()
	return cell

/obj/item/computer_hardware/battery/get_cell()
	return battery

/obj/item/clothing/suit/space/space_ninja/get_cell()
	return suitCell

/obj/item/gun/energy/get_cell()
	return power_supply

/obj/item/gun/throw/crossbow/get_cell()
	return cell

/obj/spacepod/get_cell()
	return battery

/obj/item/rcs/get_cell()
	return rcell
