/obj/item/weapon/gun/energy
	icon_state = "energy"
	name = "energy gun"
	desc = "A basic energy-based gun."
	fire_sound = 'sound/weapons/Taser.ogg'

	var/obj/item/weapon/stock_parts/cell/power_supply //What type of power cell this uses
	var/charge_cost = 1000 //How much energy is needed to fire.
	var/cell_type = "/obj/item/weapon/stock_parts/cell"
	var/projectile_type = "/obj/item/projectile/beam"
	var/modifystate
	var/can_charge = 1

/obj/item/weapon/gun/energy/emp_act(severity)
	if(power_supply)
		power_supply.use(round(power_supply.charge / severity))
		update_icon()

/obj/item/weapon/gun/energy/New()
	..()
	if(cell_type)
		power_supply = new cell_type(src)
	else
		power_supply = new(src)
	power_supply.give(power_supply.maxcharge)
	return

/obj/item/weapon/gun/energy/process_chambered()
	if(in_chamber)	return 1
	if(!power_supply)	return 0
	if(!power_supply.use(charge_cost))	return 0
	if(!projectile_type)	return 0
	in_chamber = new projectile_type(src)
	return 1

/obj/item/weapon/gun/energy/update_icon()
	if(cell_type)
		var/ratio = power_supply.charge / power_supply.maxcharge
		ratio = round(ratio, 0.25) * 100
		if(modifystate)
			icon_state = "[modifystate][ratio]"
		else
			icon_state = "[initial(icon_state)][ratio]"
	else
		icon_state = "energy0"
	overlays.Cut()
	if(F)
		if(F.on)
			overlays += "flight-on"
		else
			overlays += "flight"
	return
