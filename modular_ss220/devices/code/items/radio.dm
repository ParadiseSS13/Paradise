// Just renaming
/obj/item/radio
	name = "handheld radio"
	desc = "A basic shortwave radio that can communicate with local telecommunication networks."

// I don't want to mess up icons, so I'll just make an "alternate" version
/obj/item/radio/alternative
	name = "handheld radio"
	desc = "A basic shortwave radio that can communicate with local telecommunication networks. This model is painted in contrasted, visible colors."
	icon = 'modular_ss220/devices/icons/radio.dmi'
	icon_state = "walkietalkie"

/obj/item/radio/security
	name = "security handheld radio"
	desc = "A basic shortwave radio that can communicate with local telecommunication networks on security frequency. This model is painted in black colors."
	icon = 'modular_ss220/devices/icons/radio.dmi'
	icon_state = "walkietalkie_sec"
	frequency = SEC_FREQ

/obj/item/radio/tactical
	name = "tactical handheld radio"
	desc = "A tactical shortwave radio that used by some special forces. That can communicate with local telecommunication networks on allocated frequencies. This model is painted in gray camouflage."
	icon = 'modular_ss220/devices/icons/radio.dmi'
	icon_state = "walkietalkie_special"
	frequency = DTH_FREQ

// DO NOT PLACE IT IN MAINT SPAWNERS, PLEASE
/obj/item/radio/syndicate
	name = "suspecious handheld radio"
	desc = "A suspecious shortwave radio. This model is painted in reddish colors, there is some numbers and letters on back of it."
	icon = 'modular_ss220/devices/icons/radio.dmi'
	icon_state = "walkietalkie_syndie"
	frequency = SYNDTEAM_FREQ

/*
 *	Radio QoL improvement
 *	So players can Alt+click to enable dynamic and Ctrl+Shift+click to enable speaker
*/
/obj/item/radio/headset/examine(mob/user)
	. = ..()
	if(in_range(src, user) || loc == user)
		. += span_info("Alt-click on \the [name] to toggle broadcasting.")
		. += span_info("Ctrl-Shift-click on \the [src] to toggle speaker.")

/obj/item/radio/headset/AltClick(mob/user)
	if(!Adjacent(user))
		return
	if(!iscarbon(usr) && !isrobot(usr))
		return
	if(!istype(user) || user.incapacitated())
		to_chat(user, span_warning("You can't do that right now!"))
		return
	broadcasting = !broadcasting
	to_chat(user, span_notice("You toggle broadcasting [broadcasting ? "on" : "off"]."))

/obj/item/radio/headset/CtrlShiftClick(mob/user)
	if(!Adjacent(user))
		return
	if(!iscarbon(usr) && !isrobot(usr))
		return
	if(!istype(user) || user.incapacitated())
		to_chat(user, span_warning("You can't do that right now!"))
		return
	listening = !listening
	to_chat(user, span_notice("You toggle speaker [listening ? "on" : "off"]."))
