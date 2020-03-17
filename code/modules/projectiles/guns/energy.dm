/obj/item/gun/energy
	icon_state = "energy"
	name = "energy gun"
	desc = "A basic energy-based gun."
	icon = 'icons/obj/guns/energy.dmi'
	fire_sound_text = "laser blast"

	var/obj/item/stock_parts/cell/cell //What type of power cell this uses
	var/cell_type = /obj/item/stock_parts/cell
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

/obj/item/gun/energy/emp_act(severity)
	cell.use(round(cell.charge / severity))
	if(chambered)//phil235
		if(chambered.BB)
			qdel(chambered.BB)
			chambered.BB = null
		chambered = null
	newshot() //phil235
	update_icon()

/obj/item/gun/energy/get_cell()
	return cell

/obj/item/gun/energy/New()
	..()
	if(cell_type)
		cell = new cell_type(src)
	else
		cell = new(src)
	cell.give(cell.maxcharge)
	update_ammo_types()
	on_recharge()
	if(selfcharge)
		START_PROCESSING(SSobj, src)
	update_icon()

/obj/item/gun/energy/proc/update_ammo_types()
	var/obj/item/ammo_casing/energy/shot
	for(var/i = 1, i <= ammo_type.len, i++)
		var/shottype = ammo_type[i]
		shot = new shottype(src)
		ammo_type[i] = shot
	shot = ammo_type[select]
	fire_sound = shot.fire_sound
	fire_delay = shot.delay

/obj/item/gun/energy/Destroy()
	if(selfcharge)
		STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/gun/energy/process()
	if(selfcharge) //Every [recharge_time] ticks, recharge a shot for the cyborg
		charge_tick++
		if(charge_tick < charge_delay)
			return
		charge_tick = 0
		if(!cell)
			return // check if we actually need to recharge
		var/obj/item/ammo_casing/energy/E = ammo_type[select]
		if(use_external_power)
			var/obj/item/stock_parts/cell/external = get_external_cell()
			if(!external || !external.use(E.e_cost)) //Take power from the borg...
				return								//Note, uses /10 because of shitty mods to the cell system
		cell.give(100) //... to recharge the shot
		on_recharge()
		update_icon()

/obj/item/gun/energy/proc/on_recharge()
	newshot()

/obj/item/gun/energy/attack_self(mob/living/user as mob)
	if(ammo_type.len > 1)
		select_fire(user)
		update_icon()
		if(istype(user,/mob/living/carbon/human)) //This has to be here or else if you toggle modes by clicking the gun in hand
			var/mob/living/carbon/human/H = user //Otherwise the mob icon doesn't update, blame shitty human update_icons() code
			H.update_inv_l_hand()
			H.update_inv_r_hand()

/obj/item/gun/energy/can_shoot()
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	return cell.charge >= shot.e_cost

/obj/item/gun/energy/newshot()
	if(!ammo_type || !cell)
		return
	if(!chambered)
		var/obj/item/ammo_casing/energy/shot = ammo_type[select]
		if(cell.charge >= shot.e_cost) //if there's enough power in the WEAPON'S cell...
			chambered = shot //...prepare a new shot based on the current ammo type selected
			if(!chambered.BB)
				chambered.newshot()

/obj/item/gun/energy/process_chamber()
	if(chambered && !chambered.BB) //if BB is null, i.e the shot has been fired...
		var/obj/item/ammo_casing/energy/shot = chambered
		cell.use(shot.e_cost)//... drain the cell cell
		robocharge()
	chambered = null //either way, released the prepared shot
	newshot()

/obj/item/gun/energy/process_fire(atom/target, mob/living/user, message = 1, params, zone_override, bonus_spread = 0)
	if(!chambered && can_shoot())
		process_chamber()
	return ..()

/obj/item/gun/energy/proc/select_fire(mob/living/user)
	select++
	if(select > ammo_type.len)
		select = 1
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	fire_sound = shot.fire_sound
	fire_delay = shot.delay
	if(shot.select_name)
		to_chat(user, "<span class='notice'>[src] is now set to [shot.select_name].</span>")
	if(chambered)//phil235
		if(chambered.BB)
			qdel(chambered.BB)
			chambered.BB = null
		chambered = null
	newshot()
	update_icon()
	return

/obj/item/gun/energy/update_icon()
	overlays.Cut()
	var/ratio = Ceiling((cell.charge / cell.maxcharge) * charge_sections)
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
	if(cell.charge < shot.e_cost)
		overlays += "[icon_state]_empty"
	else
		if(!shaded_charge)
			for(var/i = ratio, i >= 1, i--)
				overlays += image(icon = icon, icon_state = iconState, pixel_x = ammo_x_offset * (i -1))
		else
			overlays += image(icon = icon, icon_state = "[icon_state]_[modifystate ? "[shot.select_name]_" : ""]charge[ratio]")
	if(gun_light && can_flashlight)
		var/iconF = "flight"
		if(gun_light.on)
			iconF = "flight_on"
		overlays += image(icon = icon, icon_state = iconF, pixel_x = flight_x_offset, pixel_y = flight_y_offset)
	if(bayonet && can_bayonet)
		overlays += knife_overlay
	if(itemState)
		itemState += "[ratio]"
		item_state = itemState

/obj/item/gun/energy/ui_action_click()
	toggle_gunlight()

/obj/item/gun/energy/suicide_act(mob/user)
	if(can_shoot())
		user.visible_message("<span class='suicide'>[user] is putting the barrel of the [name] in [user.p_their()] mouth.  It looks like [user.p_theyre()] trying to commit suicide.</span>")
		sleep(25)
		if(user.l_hand == src || user.r_hand == src)
			user.visible_message("<span class='suicide'>[user] melts [user.p_their()] face off with the [name]!</span>")
			playsound(loc, fire_sound, 50, 1, -1)
			var/obj/item/ammo_casing/energy/shot = ammo_type[select]
			cell.use(shot.e_cost)
			update_icon()
			return FIRELOSS
		else
			user.visible_message("<span class='suicide'>[user] panics and starts choking to death!</span>")
			return OXYLOSS
	else
		user.visible_message("<span class='suicide'>[user] is pretending to blow [user.p_their()] brains out with the [name]! It looks like [user.p_theyre()] trying to commit suicide!</b></span>")
		playsound(loc, 'sound/weapons/empty.ogg', 50, 1, -1)
		return OXYLOSS

/obj/item/gun/energy/vv_edit_var(var_name, var_value)
	switch(var_name)
		if("selfcharge")
			if(var_value)
				START_PROCESSING(SSobj, src)
			else
				STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/gun/energy/proc/robocharge()
	if(cell.charge == cell.maxcharge)
		// No point in recharging a weapon's cell that is already at 100%. That would just waste borg cell power for no reason.
		return
	if(isrobot(loc))
		var/mob/living/silicon/robot/R = loc
		if(R && R.cell)
			var/obj/item/ammo_casing/energy/shot = ammo_type[select] //Necessary to find cost of shot
			if(R.cell.use(shot.e_cost)) 		//Take power from the borg...
				cell.give(shot.e_cost)	//... to recharge the shot

/obj/item/gun/energy/proc/get_external_cell()
	if(istype(loc, /obj/item/rig_module))
		var/obj/item/rig_module/module = loc
		if(module.holder && module.holder.wearer)
			var/mob/living/carbon/human/H = module.holder.wearer
			if(istype(H) && H.back)
				var/obj/item/rig/suit = H.back
				if(istype(suit))
					return suit.cell
	return null
