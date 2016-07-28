/obj/item/weapon/gun/energy
	icon_state = "energy"
	name = "energy gun"
	desc = "A basic energy-based gun."
	icon = 'icons/obj/guns/energy.dmi'
	fire_sound_text = "laser blast"

	var/obj/item/weapon/stock_parts/cell/power_supply //What type of power cell this uses
	var/cell_type = /obj/item/weapon/stock_parts/cell
	var/modifystate = 0
	var/list/ammo_type = list(/obj/item/ammo_casing/energy)
	var/select = 1 //The state of the select fire switch. Determines from the ammo_type list what kind of shot is fired next.
	var/can_charge = 1
	var/charge_sections = 4
	ammo_x_offset = 2
	var/shaded_charge = 0 //if this gun uses a stateful charge bar for more detail
	var/selfcharge = 0
	var/use_external_power = 0 //if set, the weapon will look for an external power source to draw from, otherwise it recharges magically
	var/charge_tick = 0
	var/charge_delay = 4

/obj/item/weapon/gun/energy/emp_act(severity)
	power_supply.use(round(power_supply.charge / severity))
	update_icon()

/obj/item/weapon/gun/energy/New()
	..()
	if(cell_type)
		power_supply = new cell_type(src)
	else
		power_supply = new(src)
	power_supply.give(power_supply.maxcharge)
	var/obj/item/ammo_casing/energy/shot
	for(var/i = 1, i <= ammo_type.len, i++)
		var/shottype = ammo_type[i]
		shot = new shottype(src)
		ammo_type[i] = shot
	shot = ammo_type[select]
	fire_sound = shot.fire_sound
	fire_delay = shot.delay
	if(selfcharge)
		processing_objects.Add(src)
	update_icon()

/obj/item/weapon/gun/energy/Destroy()
	if(selfcharge)
		processing_objects.Remove(src)
	return ..()

/obj/item/weapon/gun/energy/process()
	if(selfcharge) //Every [recharge_time] ticks, recharge a shot for the cyborg
		charge_tick++
		if(charge_tick < charge_delay)
			return
		charge_tick = 0
		if(!power_supply)
			return // check if we actually need to recharge
		var/obj/item/ammo_casing/energy/E = ammo_type[select]
		if(use_external_power)
			var/obj/item/weapon/stock_parts/cell/external = get_external_power_supply()
			if(!external || !external.use((E.e_cost)/10)) //Take power from the borg...
				return								//Note, uses /10 because of shitty mods to the cell system
		power_supply.give(1000) //... to recharge the shot
		update_icon()

/obj/item/weapon/gun/energy/attack_self(mob/living/user as mob)
	if(ammo_type.len > 1)
		select_fire(user)
		update_icon()
		if(istype(user,/mob/living/carbon/human)) //This has to be here or else if you toggle modes by clicking the gun in hand
			var/mob/living/carbon/human/H = user //Otherwise the mob icon doesn't update, blame shitty human update_icons() code
			H.update_inv_l_hand()
			H.update_inv_r_hand()

/obj/item/weapon/gun/energy/afterattack(atom/target as mob|obj|turf, mob/living/user as mob|obj, params)
	newshot() //prepare a new shot
	..()

/obj/item/weapon/gun/energy/can_shoot()
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	return power_supply.charge >= shot.e_cost

/obj/item/weapon/gun/energy/newshot()
	if(!ammo_type || !power_supply)
		return
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	if(power_supply.charge >= shot.e_cost) //if there's enough power in the power_supply cell...
		chambered = shot //...prepare a new shot based on the current ammo type selected
		chambered.newshot()
	return

/obj/item/weapon/gun/energy/process_chamber()
	if(chambered && !chambered.BB) //if BB is null, i.e the shot has been fired...
		var/obj/item/ammo_casing/energy/shot = chambered
		power_supply.use(shot.e_cost)//... drain the power_supply cell
	chambered = null //either way, released the prepared shot
	return

/obj/item/weapon/gun/energy/proc/select_fire(mob/living/user)
	select++
	if(select > ammo_type.len)
		select = 1
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	fire_sound = shot.fire_sound
	fire_delay = shot.delay
	if(shot.select_name)
		to_chat(user, "<span class='notice'>[src] is now set to [shot.select_name].</span>")
	update_icon()
	return

/obj/item/weapon/gun/energy/update_icon()
	overlays.Cut()
	var/ratio = Ceiling((power_supply.charge / power_supply.maxcharge) * charge_sections)
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	var/iconState = "[icon_state]_charge"
	var/itemState = null
	if(!initial(item_state))
		itemState = icon_state
	if(modifystate)
		overlays += "[icon_state]_[shot.select_name]"
		iconState += "_[shot.select_name]"
		if(itemState)
			itemState += "[shot.select_name]"
	if(power_supply.charge < shot.e_cost)
		overlays += "[icon_state]_empty"
	else
		if(!shaded_charge)
			for(var/i = ratio, i >= 1, i--)
				overlays += image(icon = icon, icon_state = iconState, pixel_x = ammo_x_offset * (i -1))
		else
			overlays += image(icon = icon, icon_state = "[icon_state]_[modifystate ? "[shot.select_name]_" : ""]charge[ratio]")
	if(F && can_flashlight)
		var/iconF = "flight"
		if(F.on)
			iconF = "flight_on"
		overlays += image(icon = icon, icon_state = iconF, pixel_x = flight_x_offset, pixel_y = flight_y_offset)
	if(itemState)
		itemState += "[ratio]"
		item_state = itemState

/obj/item/weapon/gun/energy/ui_action_click()
	toggle_gunlight()

/obj/item/weapon/gun/energy/suicide_act(mob/user)
	if(can_shoot())
		user.visible_message("<span class='suicide'>[user] is putting the barrel of the [name] in \his mouth.  It looks like \he's trying to commit suicide.</span>")
		sleep(25)
		if(user.l_hand == src || user.r_hand == src)
			user.visible_message("<span class='suicide'>[user] melts \his face off with the [name]!</span>")
			playsound(loc, fire_sound, 50, 1, -1)
			var/obj/item/ammo_casing/energy/shot = ammo_type[select]
			power_supply.use(shot.e_cost)
			update_icon()
			return(FIRELOSS)
		else
			user.visible_message("<span class='suicide'>[user] panics and starts choking to death!</span>")
			return(OXYLOSS)
	else
		user.visible_message("<span class='suicide'>[user] is pretending to blow \his brains out with the [name]! It looks like \he's trying to commit suicide!</b></span>")
		playsound(loc, 'sound/weapons/empty.ogg', 50, 1, -1)
		return (OXYLOSS)

/obj/item/weapon/gun/energy/proc/robocharge()
	if(isrobot(loc))
		var/mob/living/silicon/robot/R = loc
		if(R && R.cell)
			var/obj/item/ammo_casing/energy/shot = ammo_type[select] //Necessary to find cost of shot
			if(R.cell.use(shot.e_cost/10)) 		//Take power from the borg... //Divided by 10 because cells and charge costs are fucked.
				power_supply.give(shot.e_cost)	//... to recharge the shot

/obj/item/weapon/gun/energy/proc/get_external_power_supply()
	if(istype(loc, /obj/item/rig_module))
		var/obj/item/rig_module/module = loc
		if(module.holder && module.holder.wearer)
			var/mob/living/carbon/human/H = module.holder.wearer
			if(istype(H) && H.back)
				var/obj/item/weapon/rig/suit = H.back
				if(istype(suit))
					return suit.cell
	return null
