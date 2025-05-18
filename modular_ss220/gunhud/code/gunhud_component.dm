#define GET_FUEL reagents.get_reagent_amount("fuel")

/datum/component/gunhud
	var/atom/movable/screen/ammo_counter/hud

/datum/component/gunhud/Initialize()
	. = ..()
	if(!istype(parent, /obj/item/gun) && !istype(parent, /obj/item/weldingtool) || istype(parent, /obj/item/gun/projectile/revolver))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(wake_up))

/datum/component/gunhud/Destroy()
	turn_off()
	return ..()

/datum/component/gunhud/proc/wake_up(datum/source, mob/user, slot)
	SIGNAL_HANDLER

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.get_active_hand() == parent || H.get_inactive_hand() == parent)
			if(H.hud_used)
				hud = H.hud_used.ammo_counter
				turn_on()
		else
			turn_off()

/datum/component/gunhud/proc/turn_on()
	SIGNAL_HANDLER

	RegisterSignal(parent, COMSIG_PARENT_PREQDELETED, PROC_REF(turn_off))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(turn_off))
	RegisterSignal(parent, COMSIG_UPDATE_GUNHUD, PROC_REF(update_hud))

	hud.turn_on()
	update_hud()

/datum/component/gunhud/proc/turn_off()
	SIGNAL_HANDLER

	UnregisterSignal(parent, COMSIG_PARENT_PREQDELETED)
	UnregisterSignal(parent, COMSIG_ITEM_DROPPED)
	UnregisterSignal(parent, COMSIG_UPDATE_GUNHUD)

	if(hud)
		hud.turn_off()
		hud = null

/datum/component/gunhud/proc/update_hud()
	SIGNAL_HANDLER
	if(istype(parent, /obj/item/gun/projectile))
		var/obj/item/gun/projectile/pew = parent
		hud.maptext = null
		hud.icon_state = "backing"
		var/backing_color = COLOR_CYAN
		if(!pew.magazine)
			hud.set_hud(backing_color, "oe", "te", "he", "no_mag")
			return
		if(!pew.get_ammo())
			hud.set_hud(backing_color, "oe", "te", "he", "empty_flash")
			return

		var/indicator
		var/rounds = num2text(pew.get_ammo(TRUE))
		var/oth_o
		var/oth_t
		var/oth_h

		switch(length(rounds))
			if(1)
				oth_o = "o[rounds[1]]"
			if(2)
				oth_o = "o[rounds[2]]"
				oth_t = "t[rounds[1]]"
			if(3)
				oth_o = "o[rounds[3]]"
				oth_t = "t[rounds[2]]"
				oth_h = "h[rounds[1]]"
			else
				oth_o = "o9"
				oth_t = "t9"
				oth_h = "h9"
		hud.set_hud(backing_color, oth_o, oth_t, oth_h, indicator)
		return

	if(istype(parent, /obj/item/gun/energy))
		var/obj/item/gun/energy/pew = parent
		hud.icon_state = "eammo_counter"
		hud.cut_overlays()
		hud.maptext_x = -12
		var/obj/item/ammo_casing/energy/shot = pew.ammo_type[pew.select]
		var/batt_percent = FLOOR(clamp(pew.cell.charge / pew.cell.maxcharge, 0, 1) * 100, 1)
		var/shot_cost_percent = FLOOR(clamp(shot.e_cost / pew.cell.maxcharge, 0, 1) * 100, 1)
		if(batt_percent > 99 || shot_cost_percent > 99)
			hud.maptext_x = -12
		else
			hud.maptext_x = -8
		if(!pew.can_shoot())
			hud.icon_state = "eammo_counter_empty"
			hud.maptext = MAPTEXT("<div align='center' valign='middle' style='position:relative'><font color='[COLOR_RED]'><b>[batt_percent]%</b></font><br><font color='[COLOR_CYAN]'>[shot_cost_percent]%</font></div>")
			return
		if(batt_percent <= 25)
			hud.maptext = MAPTEXT("<div align='center' valign='middle' style='position:relative'><font color='[COLOR_YELLOW]'><b>[batt_percent]%</b></font><br><font color='[COLOR_CYAN]'>[shot_cost_percent]%</font></div>")
			return
		hud.maptext = MAPTEXT("<div align='center' valign='middle' style='position:relative'><font color='[COLOR_GREEN]'><b>[batt_percent]%</b></font><br><font color='[COLOR_CYAN]'>[shot_cost_percent]%</font></div>")
		return

	if(istype(parent, /obj/item/weldingtool))
		var/obj/item/weldingtool/welder = parent
		hud.maptext = null
		var/backing_color = "#FF7B00"
		hud.icon_state = "backing"

		if(welder.GET_FUEL < 1)
			hud.set_hud(backing_color, "oe", "te", "he", "empty_flash")
			return

		var/indicator
		var/fuel
		var/oth_o
		var/oth_t
		var/oth_h

		if(welder.tool_enabled)
			indicator = "flame_on"
		else
			indicator = "flame_off"

		fuel = num2text(round(welder.GET_FUEL))

		switch(length(fuel))
			if(1)
				oth_o = "o[fuel[1]]"
			if(2)
				oth_o = "o[fuel[2]]"
				oth_t = "t[fuel[1]]"
			if(3)
				oth_o = "o[fuel[3]]"
				oth_t = "t[fuel[2]]"
				oth_h = "h[fuel[1]]"
			else
				oth_o = "o9"
				oth_t = "t9"
				oth_h = "h9"
		hud.set_hud(backing_color, oth_o, oth_t, oth_h, indicator)

/obj/item/proc/add_gunhud()
	return

/obj/item/gun/projectile/add_gunhud()
	AddComponent(/datum/component/gunhud)

/obj/item/gun/projectile/revolver/add_gunhud()
	return

/obj/item/gun/energy/add_gunhud()
	AddComponent(/datum/component/gunhud)

/obj/item/weldingtool/add_gunhud()
	AddComponent(/datum/component/gunhud)

/obj/item/gun/projectile/Initialize(mapload)
	. = ..()
	add_gunhud()

/obj/item/gun/energy/Initialize(mapload)
	. = ..()
	add_gunhud()

/obj/item/weldingtool/Initialize(mapload)
	. = ..()
	add_gunhud()

#undef GET_FUEL
