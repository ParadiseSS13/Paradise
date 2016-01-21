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

	//self-recharging
	var/self_recharge = 0	//if set, the weapon will recharge itself
	var/use_external_power = 0 //if set, the weapon will look for an external power source to draw from, otherwise it recharges magically
	var/recharge_time = 4
	var/charge_tick = 0

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
	if(self_recharge)
		processing_objects.Add(src)
	update_icon()

/obj/item/weapon/gun/energy/Destroy()
	if(self_recharge)
		processing_objects.Remove(src)
	return ..()

/obj/item/weapon/gun/energy/process()
	if(self_recharge) //Every [recharge_time] ticks, recharge a shot for the cyborg
		charge_tick++
		if(charge_tick < recharge_time) return 0
		charge_tick = 0

		if(!power_supply || power_supply.charge >= power_supply.maxcharge)
			return 0 // check if we actually need to recharge

		if(use_external_power)
			var/obj/item/weapon/stock_parts/cell/external = get_external_power_supply()
			if(!external || !external.use(charge_cost/10)) //Take power from the borg...
				return 0								//Note, uses /10 because of shitty mods to the cell system

		power_supply.give(charge_cost) //... to recharge the shot
		update_icon()
	return 1

/obj/item/weapon/gun/energy/proc/get_external_power_supply()
	if(isrobot(src.loc))
		var/mob/living/silicon/robot/R = src.loc
		return R.cell
	if(istype(src.loc, /obj/item/rig_module))
		var/obj/item/rig_module/module = src.loc
		if(module.holder && module.holder.wearer)
			var/mob/living/carbon/human/H = module.holder.wearer
			if(istype(H) && H.back)
				var/obj/item/weapon/rig/suit = H.back
				if(istype(suit))
					return suit.cell
	return null

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
