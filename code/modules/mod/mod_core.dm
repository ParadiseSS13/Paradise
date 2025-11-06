/obj/item/mod/core
	name = "MOD core"
	desc = "A non-functional MOD core. Inform the admins if you see this."
	icon = 'icons/obj/clothing/modsuit/mod_construction.dmi'
	icon_state = "mod-core"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	/// MOD unit we are powering.
	var/obj/item/mod/control/mod

/obj/item/mod/core/Destroy()
	if(mod)
		uninstall()
	return ..()

/obj/item/mod/core/proc/install(obj/item/mod/control/mod_unit)
	mod = mod_unit
	mod.core = src
	forceMove(mod)

/obj/item/mod/core/proc/uninstall()
	mod.core = null
	mod = null

/obj/item/mod/core/proc/charge_source()
	return

/obj/item/mod/core/proc/charge_amount()
	return 0

/obj/item/mod/core/proc/max_charge_amount()
	return 1

/obj/item/mod/core/proc/add_charge(amount)
	return FALSE

/obj/item/mod/core/proc/subtract_charge(amount)
	return FALSE

/obj/item/mod/core/proc/check_charge(amount)
	return FALSE

/obj/item/mod/core/proc/update_charge_alert()
	mod.wearer.clear_alert("mod_charge")

/// Admin only.
/obj/item/mod/core/infinite
	name = "MOD infinite core"
	icon_state = "mod-core-infinite"
	desc = "A fusion core using the rare Infinium to sustain enough energy for the lifetime of the MOD's user. \
		This might be because of the slowly killing radiation inside, but those are just rumors."

/obj/item/mod/core/infinite/charge_source()
	return src

/obj/item/mod/core/infinite/charge_amount()
	return INFINITY

/obj/item/mod/core/infinite/max_charge_amount()
	return INFINITY

/obj/item/mod/core/infinite/add_charge(amount)
	return TRUE

/obj/item/mod/core/infinite/subtract_charge(amount)
	return TRUE

/obj/item/mod/core/infinite/check_charge(amount)
	return TRUE

/obj/item/mod/core/standard
	name = "MOD standard core"
	desc = "Using Thermo Generators to store and amplify power in the form of heat, this core acts as a power cell for your modsuit." //We don't have etherals
	icon_state = "mod-core-standard"
	/// Installed cell.
	var/obj/item/stock_parts/cell/cell

/obj/item/mod/core/standard/Destroy()
	if(cell)
		QDEL_NULL(cell)
	return ..()

/obj/item/mod/core/standard/install(obj/item/mod/control/mod_unit)
	. = ..()
	if(cell)
		install_cell(cell)
	RegisterSignal(mod, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(mod, COMSIG_CLICK_CTRL, PROC_REF(on_ctrl_click))
	RegisterSignal(mod, COMSIG_MOD_WEARER_SET, PROC_REF(on_wearer_set))
	if(mod.wearer)
		on_wearer_set(mod, mod.wearer)

/obj/item/mod/core/standard/uninstall()
	if(!QDELETED(cell))
		cell.forceMove(drop_location())
	UnregisterSignal(mod, list(COMSIG_PARENT_EXAMINE, COMSIG_CLICK_CTRL, COMSIG_MOD_WEARER_SET))
	if(mod.wearer)
		on_wearer_unset(mod, mod.wearer)
	return ..()

/obj/item/mod/core/proc/on_attackby(obj/item/attacking_item, mob/user, params)
	return

/obj/item/mod/core/standard/charge_source()
	return cell

/obj/item/mod/core/standard/charge_amount()
	var/obj/item/stock_parts/cell/charge_source = charge_source()
	return charge_source?.charge || 0

/obj/item/mod/core/standard/max_charge_amount(amount)
	var/obj/item/stock_parts/cell/charge_source = charge_source()
	return charge_source?.maxcharge || 1

/obj/item/mod/core/standard/add_charge(amount)
	var/obj/item/stock_parts/cell/charge_source = charge_source()
	if(!charge_source)
		return FALSE
	return charge_source.give(amount)

/obj/item/mod/core/standard/subtract_charge(amount)
	var/obj/item/stock_parts/cell/charge_source = charge_source()
	if(!charge_source)
		return FALSE
	return charge_source.use(amount, TRUE)

/obj/item/mod/core/standard/check_charge(amount)
	return charge_amount() >= amount

/obj/item/mod/core/standard/update_charge_alert()
	var/obj/item/stock_parts/cell/charge_source = charge_source()
	if(!charge_source)
		mod.wearer.throw_alert("mod_charge", /atom/movable/screen/alert/nocell)
		return
	var/remaining_cell = charge_amount() / max_charge_amount()
	switch(remaining_cell)
		if(0.75 to INFINITY)
			mod.wearer.clear_alert("mod_charge")
		if(0.5 to 0.75)
			mod.wearer.throw_alert("mod_charge", /atom/movable/screen/alert/lowcell, 1)
		if(0.25 to 0.5)
			mod.wearer.throw_alert("mod_charge", /atom/movable/screen/alert/lowcell, 2)
		if(0.01 to 0.25)
			mod.wearer.throw_alert("mod_charge", /atom/movable/screen/alert/lowcell, 3)
		else
			mod.wearer.throw_alert("mod_charge", /atom/movable/screen/alert/emptycell)

/obj/item/mod/core/standard/emp_act(severity)
	cell?.emp_act(severity)

/obj/item/mod/core/standard/proc/install_cell(new_cell)
	cell = new_cell
	cell.forceMove(src)
	RegisterSignal(src, COMSIG_ATOM_EXITED, PROC_REF(on_exit))
	RegisterSignal(cell, COMSIG_PARENT_QDELETING, PROC_REF(remove_cell))

/obj/item/mod/core/standard/proc/uninstall_cell()
	if(!cell)
		return
	UnregisterSignal(cell, COMSIG_PARENT_QDELETING)
	cell = null
	UnregisterSignal(src, COMSIG_ATOM_EXITED)

/obj/item/mod/core/standard/proc/on_exit(datum/source, obj/item/stock_parts/cell, direction)
	SIGNAL_HANDLER

	if(!istype(cell) || cell.loc == src)
		return
	uninstall_cell()

/obj/item/mod/core/standard/proc/remove_cell()
	SIGNAL_HANDLER // COMSIG_PARENT_QDELETING
	UnregisterSignal(cell, COMSIG_PARENT_QDELETING)
	cell = null

/obj/item/mod/core/standard/proc/on_examine(datum/source, mob/examiner, list/examine_text)
	SIGNAL_HANDLER

	if(!mod.open)
		return
	examine_text += cell ? "You could remove the cell while in hand or being worn with <b>Ctrl-Click</b>." : "You could use a <b>cell</b> on it to install one."

/obj/item/mod/core/standard/proc/on_ctrl_click(datum/source, mob/living/user)
	SIGNAL_HANDLER // COMSIG_CLICK_CTRL

	if(mod.seconds_electrified && charge_amount() && mod.shock(user))
		return COMPONENT_CANCEL_ATTACK_CHAIN
	if(mod.open && mod.loc == user)
		INVOKE_ASYNC(src, PROC_REF(mod_uninstall_cell), user)
		return COMPONENT_CANCEL_ATTACK_CHAIN
	return NONE

/obj/item/mod/core/standard/proc/mod_uninstall_cell(mob/living/user)
	if(!cell)
		to_chat(user, "<span class='warning'>No cell installed!</span>")
		return
	if(!do_after(user, 1.5 SECONDS, target = user))
		return
	to_chat(user, "<span class='notice'>You remove the cell.</span>")
	playsound(mod, 'sound/machines/click.ogg', 50, TRUE, SILENCED_SOUND_EXTRARANGE)
	var/obj/item/cell_to_move = cell
	cell_to_move.forceMove(drop_location())
	user.put_in_hands(cell_to_move)
	mod.update_charge_alert()

/obj/item/mod/core/standard/on_attackby(obj/item/attacking_item, mob/user, params)
	if(istype(attacking_item, /obj/item/stock_parts/cell))
		if(!mod.open)
			to_chat(user, "<span class='warning'>Open the cover first!</span>")
			playsound(mod, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
			return NONE
		if(cell)
			to_chat(user, "<span class='warning'>Cell already installed!</span>")
			playsound(mod, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
			return COMPONENT_SKIP_AFTERATTACK
		user.drop_item()
		install_cell(attacking_item)
		to_chat(user, "<span class='notice'>You install the cell.</span>")
		playsound(mod, 'sound/machines/click.ogg', 50, TRUE, SILENCED_SOUND_EXTRARANGE)
		mod.update_charge_alert()
		return COMPONENT_SKIP_AFTERATTACK
	return NONE

/obj/item/mod/core/standard/proc/on_wearer_set(datum/source, mob/user)
	SIGNAL_HANDLER

	RegisterSignal(mod.wearer, COMSIG_PROCESS_BORGCHARGER_OCCUPANT, PROC_REF(on_borg_charge))
	RegisterSignal(mod, COMSIG_MOD_WEARER_UNSET, PROC_REF(on_wearer_unset))

/obj/item/mod/core/standard/proc/on_wearer_unset(datum/source, mob/user)
	SIGNAL_HANDLER

	UnregisterSignal(mod.wearer, COMSIG_PROCESS_BORGCHARGER_OCCUPANT)
	UnregisterSignal(mod, COMSIG_MOD_WEARER_UNSET)

/obj/item/mod/core/standard/proc/on_borg_charge(datum/source, amount)
	SIGNAL_HANDLER

	add_charge(amount)
	mod.update_charge_alert()

/obj/item/mod/core/plasma
	name = "\improper MOD plasma core"
	desc = "Nanotrasen's attempt at capitalizing on their plasma research. These plasma cores are refueled \
		through plasma fuel, allowing for easy continued use by their mining squads."
	icon_state = "mod-core-plasma"
	/// How much charge we can store.
	var/maxcharge = 10000
	/// How much charge we are currently storing.
	var/charge = 10000
	/// Associated list of charge sources, only stacks allowed.
	var/list/charger_list = list(/obj/item/stack/ore/plasma, /obj/item/stack/sheet/mineral/plasma)

/obj/item/mod/core/plasma/attackby__legacy__attackchain(obj/item/attacking_item, mob/user, params)
	if(charge_plasma(attacking_item, user))
		return TRUE
	return ..()

/obj/item/mod/core/plasma/charge_source()
	return src

/obj/item/mod/core/plasma/charge_amount()
	return charge

/obj/item/mod/core/plasma/max_charge_amount()
	return maxcharge

/obj/item/mod/core/plasma/add_charge(amount)
	charge = min(maxcharge, charge + amount)
	return TRUE

/obj/item/mod/core/plasma/subtract_charge(amount)
	charge = max(0, charge - amount)
	return TRUE

/obj/item/mod/core/plasma/check_charge(amount)
	return charge_amount() >= amount

/obj/item/mod/core/plasma/update_charge_alert()
	var/remaining_plasma = charge_amount() / max_charge_amount()
	switch(remaining_plasma)
		if(0.75 to INFINITY)
			mod.wearer.clear_alert("mod_charge")
		if(0.5 to 0.75)
			mod.wearer.throw_alert("mod_charge", /atom/movable/screen/alert/lowcell, 1)
		if(0.25 to 0.5)
			mod.wearer.throw_alert("mod_charge", /atom/movable/screen/alert/lowcell, 2)
		if(0.01 to 0.25)
			mod.wearer.throw_alert("mod_charge", /atom/movable/screen/alert/lowcell, 3)
		else
			mod.wearer.throw_alert("mod_charge", /atom/movable/screen/alert/emptycell)

/obj/item/mod/core/plasma/on_attackby(obj/item/attacking_item, mob/user, params)
	charge_plasma(attacking_item, user)

/obj/item/mod/core/plasma/proc/charge_plasma(obj/item/stack/plasma, mob/user)
	var/charge_given = is_type_in_list(plasma, charger_list)
	if(!charge_given)
		return FALSE
	if(charge_amount() == max_charge_amount())
		to_chat(user, "<span class='notice'>[src] is already fully charged!</span>")
		// We didn't succeed but we don't want to treat it as an attackby
		return TRUE
	var/uses_needed = min(plasma.amount, ((max_charge_amount() - charge_amount()) / 2000))
	if(!plasma.use(uses_needed))
		return FALSE
	add_charge(uses_needed * 2000)
	to_chat(user, "<span class='notice'>You insert [plasma] in [src], recharging it.</span>")
	return TRUE
