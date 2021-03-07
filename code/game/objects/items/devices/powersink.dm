#define DISCONNECTED	0
#define CLAMPED_OFF		1
#define OPERATING		2

// Powersink - used to drain station power

/obj/item/powersink
	name = "power sink"
	desc = "A nulling power sink which drains energy from electrical systems."
	icon = 'icons/obj/device.dmi'
	icon_state = "powersink0"
	item_state = "electronic"
	w_class = WEIGHT_CLASS_BULKY
	flags = CONDUCT
	throwforce = 5
	throw_speed = 1
	throw_range = 2
	materials = list(MAT_METAL=750)
	origin_tech = "powerstorage=5;syndicate=5"
	var/drain_rate = 2000000	// amount of power to drain per tick
	var/power_drained = 0 		// has drained this much power
	var/max_power = 6e8		// maximum power that can be drained before exploding
	var/mode = 0		// 0 = off, 1=clamped (off), 2=operating
	var/admins_warned = FALSE // stop spam, only warn the admins once that we are about to boom

	var/obj/structure/cable/attached		// the attached cable

/obj/item/powersink/Destroy()
	STOP_PROCESSING(SSobj, src)
	attached = null
	return ..()

/obj/item/powersink/update_icon()
	icon_state = "powersink[mode == OPERATING]"

/obj/item/powersink/proc/set_mode(value)
	if(value == mode)
		return
	switch(value)
		if(DISCONNECTED)
			attached = null
			if(mode == OPERATING)
				STOP_PROCESSING(SSobj, src)
			anchored = FALSE
			density = FALSE

		if(CLAMPED_OFF)
			if(!attached)
				return
			if(mode == OPERATING)
				STOP_PROCESSING(SSobj, src)
			anchored = TRUE
			density = TRUE

		if(OPERATING)
			if(!attached)
				return
			START_PROCESSING(SSobj, src)
			anchored = TRUE
			density = TRUE

	mode = value
	update_icon()
	set_light(0)

/obj/item/powersink/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(mode == DISCONNECTED)
		var/turf/T = loc
		if(isturf(T) && !T.intact)
			attached = locate() in T
			if(!attached)
				to_chat(user, "No exposed cable here to attach to.")
				return
			else
				set_mode(CLAMPED_OFF)
				visible_message("<span class='notice'>[user] attaches [src] to the cable!</span>")
				message_admins("Power sink activated by [key_name_admin(user)] at ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)")
				log_game("Power sink activated by [key_name(user)] at ([x],[y],[z])")
		else
			to_chat(user, "Device must be placed over an exposed cable to attach to it.")
	else
		set_mode(DISCONNECTED)
		src.visible_message("<span class='notice'>[user] detaches [src] from the cable!</span>")

/obj/item/powersink/attack_ai()
	return

/obj/item/powersink/attack_hand(var/mob/user)
	switch(mode)
		if(DISCONNECTED)
			..()
		if(CLAMPED_OFF)
			user.visible_message( \
				"[user] activates \the [src]!", \
				"<span class='notice'>You activate \the [src].</span>",
				"<span class='italics'>You hear a click.</span>")
			message_admins("Power sink activated by [ADMIN_LOOKUPFLW(user)] at [ADMIN_VERBOSEJMP(src)]")
			log_game("Power sink activated by [key_name(user)] at [AREACOORD(src)]")
			set_mode(OPERATING)

		if(OPERATING)
			user.visible_message( \
				"[user] deactivates \the [src]!", \
				"<span class='notice'>You deactivate \the [src].</span>",
				"<span class='italics'>You hear a click.</span>")
			set_mode(CLAMPED_OFF)

/obj/item/powersink/process()
	if(!attached)
		set_mode(DISCONNECTED)
		return

	var/datum/powernet/PN = attached.powernet
	if(PN)
		set_light(5)

		// found a powernet, so drain up to max power from it

		var/drained = min (drain_rate, attached.newavail())
		attached.add_delayedload(drained)
		power_drained += drained

		// if tried to drain more than available on powernet
		// now look for APCs and drain their cells
		if(drained < drain_rate)
			for(var/obj/machinery/power/terminal/T in PN.nodes)
				if(istype(T.master, /obj/machinery/power/apc))
					var/obj/machinery/power/apc/A = T.master
					if(A.operating && A.cell)
						A.cell.charge = max(0, A.cell.charge - 50)
						power_drained += 50
						if(A.charging == 2) // If the cell was full
							A.charging = 1 // It's no longer full
				if(drained >= drain_rate)
					break

	if(power_drained > max_power * 0.98)
		if (!admins_warned)
			admins_warned = TRUE
			message_admins("Power sink at ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>) is 95% full. Explosion imminent.")
		playsound(src, 'sound/effects/screech.ogg', 100, 1, 1)

	if(power_drained >= max_power)
		STOP_PROCESSING(SSobj, src)
		explosion(src.loc, 4,8,16,32)
		qdel(src)

#undef DISCONNECTED
#undef CLAMPED_OFF
#undef OPERATING
