/obj/item/gun/energy
	name = "generic energy gun"
	desc = "If you can see this, make a bug report on GitHub, something went wrong!"
	icon = 'icons/obj/guns/energy.dmi'
	icon_state = "energy"
	fire_sound_text = "laser blast"

	/// What type of power cell this uses
	var/obj/item/stock_parts/cell/cell
	/// The specific type of power cell this gun has.
	var/cell_type = /obj/item/stock_parts/cell/energy_gun
	var/modifystate = 0
	/// What projectiles can this gun shoot?
	var/list/ammo_type = list(/obj/item/ammo_casing/energy)
	/// The state of the select fire switch. Determines from the ammo_type list what kind of shot is fired next.
	var/select = 1
	/// If set to FALSE, the gun cannot be recharged in a recharger.
	var/can_charge = TRUE
	/// How many lights are there on the gun's item sprite indicating the charge level?
	var/charge_sections = 4
	/// How many lights are there on the gun's in-hand sprite indicating the charge level?
	var/inhand_charge_sections = 4
	ammo_x_offset = 2
	/// If this gun uses a stateful charge bar for more detail
	var/shaded_charge = FALSE
	/// Does this gun recharge itself? Some guns (such as the M1911-P) do not use this and instead have a cell type that self-charges.
	var/selfcharge = FALSE
	var/charge_tick = 0
	var/charge_delay = 4
	/// Do you want the gun to fit into a turret, defaults to TRUE, used for if a energy gun is too strong to be in a turret, or does not make sense to be in one.
	var/can_fit_in_turrets = TRUE
	var/new_icon_state
	/// If the item uses a shared set of overlays instead of being based on icon_state
	var/overlay_set
	/// Used when updating icon and overlays to determine the energy pips
	var/ratio
	/// Can it use a lens
	var/can_be_lensed = TRUE
	/// Current lens
	var/obj/item/smithed_item/lens/current_lens
	/// The max damage multiplier a lens can apply to a energy gun. Use sparingly, primarly for stamina based weapons.
	var/lens_damage_cap = 999

/obj/item/gun/energy/examine(mob/user)
	. = ..()
	if(cell)
		. += "<span class='notice'>It is [round(cell.percent())]% charged.</span>"
	. += "<span class='notice'>Energy weapons can fire through windows and other see-through surfaces. [can_charge ? "Can be recharged with a recharger" : "Cannot be recharged in a recharger."]</span>"
	if(current_lens)
		. += "<span class='notice'>Has a lens currently attached.</span>"
		. += "<span class='notice'>Lenses can be removed with Alt-Click.</span>"

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

/obj/item/gun/energy/Initialize(mapload, ...)
	. = ..()
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
	RegisterSignal(src, COMSIG_LENS_ATTACH, PROC_REF(attach_lens))
	RegisterSignal(src, COMSIG_CLICK_ALT, PROC_REF(detach_lens))

/obj/item/gun/energy/attackby__legacy__attackchain(obj/item/I, mob/living/user, params)
	..()
	if(istype(I, /obj/item/smithed_item/lens))
		SEND_SIGNAL(src, COMSIG_LENS_ATTACH, I, user)

/obj/item/gun/energy/proc/attach_lens(atom/source, obj/item/smithed_item/lens/new_lens, mob/user)
	SIGNAL_HANDLER // COMSIG_LENS_ATTACH
	if(!Adjacent(user))
		return
	if(!can_be_lensed)
		return
	if(!istype(new_lens))
		return
	if(current_lens)
		to_chat(user, "<span class='notice'>Your [src] already has a lens.</span>")
		return
	if(new_lens.flags & NODROP || !user.transfer_item_to(new_lens, src))
		to_chat(user, "<span class='warning'>[new_lens] is stuck to your hand!</span>")
		return
	current_lens = new_lens
	new_lens.on_attached(src)

/obj/item/gun/energy/proc/detach_lens(atom/source, mob/user)
	SIGNAL_HANDLER // COMSIG_CLICK_ALT
	if(!Adjacent(user))
		return
	if(!current_lens)
		to_chat(user, "<span class='notice'>Your [src] has no lens to remove.</span>")
		return
	user.put_in_hands(current_lens)
	current_lens.on_detached()

/obj/item/gun/energy/proc/update_ammo_types()
	var/obj/item/ammo_casing/energy/shot
	select = clamp(select, 1, length(ammo_type)) // If we decrease ammo types while selecting a removed one, we want to make sure it doesnt try to select an out of bounds index
	for(var/i = 1, i <= length(ammo_type), i++)
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
		cell.give(100) //... to recharge the shot
		on_recharge()
		update_icon()

/obj/item/gun/energy/proc/on_recharge()
	newshot()

/obj/item/gun/energy/attack_self__legacy__attackchain(mob/living/user as mob)
	if(length(ammo_type) > 1)
		select_fire(user)
		update_icon()
		if(ishuman(user)) //This has to be here or else if you toggle modes by clicking the gun in hand
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
	..()
	if(current_lens)
		user.changeNext_move(CLICK_CD_RANGE / current_lens.fire_rate_mult)
	return

/obj/item/gun/energy/shoot_live_shot(mob/living/user, atom/target, pointblank = FALSE, message = TRUE)
	..()
	if(current_lens)
		current_lens.damage_lens()

/obj/item/gun/energy/proc/select_fire(mob/living/user)
	select++
	if(select > length(ammo_type))
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

/obj/item/gun/energy/update_icon(updates=ALL)
	..()
	var/mob/living/carbon/human/user = loc
	if(istype(user))
		if(user.hand) //this is kinda ew but whatever
			user.update_inv_r_hand()
		else
			user.update_inv_l_hand()

/obj/item/gun/energy/update_icon_state()
	icon_state = initial(icon_state)
	ratio = CEILING((cell.charge / cell.maxcharge) * charge_sections, 1)
	var/inhand_ratio = CEILING((cell.charge / cell.maxcharge) * inhand_charge_sections, 1)
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	var/new_inhand_icon_state = initial(inhand_icon_state) ? null : icon_state
	var/new_worn_icon_state = initial(worn_icon_state) ? null : icon_state
	new_icon_state = "[icon_state]_charge"
	if(modifystate)
		new_icon_state += "_[shot.select_name]"
		if(new_inhand_icon_state)
			new_inhand_icon_state += "[shot.select_name]"
		if(new_worn_icon_state)
			new_worn_icon_state += "[shot.select_name]"
	if(new_inhand_icon_state)
		new_inhand_icon_state += "[inhand_ratio]"
		inhand_icon_state = new_inhand_icon_state
	if(new_worn_icon_state)
		new_worn_icon_state += "[inhand_ratio]"
		worn_icon_state = new_worn_icon_state
	icon_state = current_skin || initial(icon_state)

/obj/item/gun/energy/update_overlays()
	. = ..()
	var/overlay_name = overlay_set ? overlay_set : icon_state
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	if(modifystate)
		. += "[overlay_name]_[shot.select_name]"
	if(cell.charge < shot.e_cost)
		. += "[overlay_name]_empty"
	else
		if(!shaded_charge)
			for(var/i = ratio, i >= 1, i--)
				. += image(icon = icon, icon_state = new_icon_state, pixel_x = ammo_x_offset * (i -1))
		else
			. += image(icon = icon, icon_state = "[overlay_name]_[modifystate ? "[shot.select_name]_" : ""]charge[ratio]")
	if(gun_light && can_flashlight)
		var/iconF = "flight"
		if(gun_light.on)
			iconF = "flight_on"
		. += image(icon = icon, icon_state = iconF, pixel_x = flight_x_offset, pixel_y = flight_y_offset)
	if(bayonet && can_bayonet)
		. += knife_overlay

/obj/item/gun/energy/ui_action_click()
	toggle_gunlight()

/obj/item/gun/energy/suicide_act(mob/user)
	if(can_shoot())
		user.visible_message("<span class='suicide'>[user] is putting the barrel of [src] in [user.p_their()] mouth.  It looks like [user.p_theyre()] trying to commit suicide!</span>")
		sleep(25)
		if(user.is_holding(src))
			user.visible_message("<span class='suicide'>[user] melts [user.p_their()] face off with [src]!</span>")
			playsound(loc, fire_sound, 50, TRUE, -1)
			var/obj/item/ammo_casing/energy/shot = ammo_type[select]
			cell.use(shot.e_cost)
			update_icon()
			return FIRELOSS
		else
			user.visible_message("<span class='suicide'>[user] panics and starts choking to death!</span>")
			return OXYLOSS
	else
		user.visible_message("<span class='suicide'>[user] is pretending to blow [user.p_their()] brains out with [src]! It looks like [user.p_theyre()] trying to commit suicide!</b></span>")
		playsound(loc, 'sound/weapons/empty.ogg', 50, TRUE, -1)
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

/obj/item/gun/energy/cyborg_recharge(coeff, emagged)
	if(cell.charge < cell.maxcharge)
		var/obj/item/ammo_casing/energy/E = ammo_type[select]
		cell.give(E.e_cost * coeff)
		on_recharge()
		update_icon()
	else
		charge_tick = 0
