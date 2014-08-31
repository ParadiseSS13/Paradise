/obj/item/device/suit_cooling_unit
	name = "portable suit cooling unit"
	desc = "A portable heat sink and liquid cooled radiator that can be hooked up to a space suit's existing temperature controls to provide industrial levels of cooling."
	w_class = 4
	icon = 'icons/obj/device.dmi'
	icon_state = "suitcooler0"
	slot_flags = SLOT_BACK	//you can carry it on your back if you want, but it won't do anything unless attached to suit storage
	
	//copied from tank.dm
	flags = FPRINT | TABLEPASS | CONDUCT
	force = 5.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 4
	
	origin_tech = "magnets=2;materials=2"
	
	var/on = 0				//is it turned on?
	var/cover_open = 0		//is the cover open?
	var/obj/item/weapon/cell/cell
	var/max_cooling = 12				//in degrees per second - probably don't need to mess with heat capacity here
	var/charge_consumption = 16.6		//charge per second at max_cooling
	var/thermostat = T20C
	
	//TODO: make it heat up the surroundings when not in space

/obj/item/device/suit_cooling_unit/New()
	cell = new/obj/item/weapon/cell()	//comes with the crappy default power cell - high-capacity ones shouldn't be hard to find
	cell.loc = src

/obj/item/device/suit_cooling_unit/proc/cool_mob(mob/M)
	if (!on || !cell) return
	
	//make sure they have a suit and we are attached to it
	if (!attached_to_suit(M))
		return
	
	var/mob/living/carbon/human/H = M
	
	var/efficiency = H.get_pressure_protection()		//you need to have a good seal for effective cooling
	var/env_temp = get_environment_temperature()		//wont save you from a fire
	var/temp_adj = min(H.bodytemperature - max(thermostat, env_temp), max_cooling)
	
	if (temp_adj < 0)	//only cools, doesn't heat
		return
	
	var/charge_usage = (temp_adj/max_cooling)*charge_consumption
	
	H.bodytemperature -= temp_adj*efficiency
	
	cell.use(charge_usage)
	
	if(cell.charge <= 0)
		turn_off()

/obj/item/device/suit_cooling_unit/proc/get_environment_temperature()
	if (ishuman(loc))
		var/mob/living/carbon/human/H = loc
		if(istype(H.loc, /obj/mecha))
			var/obj/mecha/M = loc
			return M.return_temperature()
		else if(istype(H.loc, /obj/machinery/atmospherics/unary/cryo_cell))
			return H.loc:air_contents.temperature

	var/turf/T = get_turf(src)
	if(istype(T, /turf/space))
		return 0	//space has no temperature, this just makes sure the cooling unit works in space
	
	var/datum/gas_mixture/environment = T.return_air()
	if (!environment)
		return 0
	
	return environment.temperature

/obj/item/device/suit_cooling_unit/proc/attached_to_suit(mob/M)
	if (!ishuman(M)) 
		return 0
	
	var/mob/living/carbon/human/H = M
	
	if (!H.wear_suit || H.s_store != src)
		return 0
	
	return 1

/obj/item/device/suit_cooling_unit/proc/turn_on()
	if(!cell)
		return
	if(cell.charge <= 0)
		return
	
	on = 1
	updateicon()

/obj/item/device/suit_cooling_unit/proc/turn_off()
	if (ismob(src.loc))
		src.loc << "\The [src] clicks and whines as it powers down."	//let them know
	on = 0
	updateicon()

/obj/item/device/suit_cooling_unit/attack_self(mob/user as mob)
	if(cover_open && cell)
		if(ishuman(user))
			user.put_in_hands(cell)
		else
			cell.loc = get_turf(loc)

		cell.add_fingerprint(user)
		cell.updateicon()

		user << "You remove the [src.cell]."
		src.cell = null
		updateicon()
		return

	//TODO use a UI like the air tanks
	if(on)
		turn_off()
	else
		turn_on()
		if (on)
			user << "You switch on the [src]."

/obj/item/device/suit_cooling_unit/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/screwdriver))
		if(cover_open)
			cover_open = 0
			user << "You screw the panel into place."
		else
			cover_open = 1
			user << "You unscrew the panel."
		updateicon()
		return

	if (istype(W, /obj/item/weapon/cell))
		if(cover_open)
			if(cell)
				user << "There is a [cell] already installed here."
			else
				user.drop_item()
				W.loc = src
				cell = W
				user << "You insert the [cell]."
		updateicon()
		return
	
	return ..()

/obj/item/device/suit_cooling_unit/proc/updateicon()
	if (cover_open)
		if (cell)
			icon_state = "suitcooler1"
		else
			icon_state = "suitcooler2"
	else
		icon_state = "suitcooler0"

/obj/item/device/suit_cooling_unit/examine()
	set src in view(1)
	
	..()
	
	if (on)
		if (attached_to_suit(src.loc))
			usr << "It's switched on and running."
		else
			usr << "It's switched on, but not attached to anything."
	else
		usr << "It is switched off."
	
	if (cover_open)
		if(cell)
			usr << "The panel is open, exposing the [cell]."
		else
			usr << "The panel is open."
	
	if (cell)
		usr << "The charge meter reads [round(cell.percent())]%."
	else
		usr << "It doesn't have a power cell installed."