/obj/machinery/computer
	name = "computer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer"
	density = 1
	anchored = 1.0
	use_power = IDLE_POWER_USE
	idle_power_usage = 300
	active_power_usage = 300
	var/obj/item/circuitboard/circuit = null //if circuit==null, computer can't disassembly
	var/processing = 0
	var/icon_keyboard = "generic_key"
	var/icon_screen = "generic"
	var/light_range_on = 2
	var/light_power_on = 1
	var/overlay_layer

/obj/machinery/computer/New()
	overlay_layer = layer
	..()

/obj/machinery/computer/Initialize()
	..()
	power_change()
	update_icon()

/obj/machinery/computer/process()
	if(stat & (NOPOWER|BROKEN))
		return 0
	return 1

/obj/machinery/computer/emp_act(severity)
	if(prob(20/severity)) set_broken()
	..()


/obj/machinery/computer/ex_act(severity)
	if(!(resistance_flags & INDESTRUCTIBLE))
		switch(severity)
			if(1.0)
				qdel(src)
				return
			if(2.0)
				if(prob(25))
					qdel(src)
					return
				if(prob(50))
					for(var/x in verbs)
						verbs -= x
					set_broken()
			if(3.0)
				if(prob(25))
					for(var/x in verbs)
						verbs -= x
					set_broken()

/obj/machinery/computer/bullet_act(var/obj/item/projectile/Proj)
	if(prob(Proj.damage))
		if((Proj.damage_type == BRUTE || Proj.damage_type == BURN))
			set_broken()
	..()

/obj/machinery/computer/blob_act()
	if(prob(75))
		for(var/x in verbs)
			verbs -= x
		set_broken()
		density = 0

/obj/machinery/computer/extinguish_light()
	set_light(0)
	visible_message("<span class='danger'>[src] grows dim, its screen barely readable.</span>")

/obj/machinery/computer/update_icon()
	overlays.Cut()
	if(stat & NOPOWER)
		if(icon_keyboard)
			overlays += image(icon,"[icon_keyboard]_off",overlay_layer)
		return

	if(stat & BROKEN)
		overlays += image(icon,"[icon_state]_broken",overlay_layer)
	else
		overlays += image(icon,icon_screen,overlay_layer)

	if(icon_keyboard)
		overlays += image(icon, icon_keyboard ,overlay_layer)


/obj/machinery/computer/power_change()
	..()
	update_icon()
	if((stat & (BROKEN|NOPOWER)))
		set_light(0)
	else
		set_light(light_range_on, light_power_on)

/obj/machinery/computer/proc/set_broken()
	if(!(resistance_flags & INDESTRUCTIBLE))
		stat |= BROKEN
		update_icon()

/obj/machinery/computer/proc/decode(text)
	// Adds line breaks
	text = replacetext(text, "\n", "<BR>")
	return text

/obj/machinery/computer/attack_ghost(mob/user)
	return attack_hand(user)

/obj/machinery/computer/attack_hand(mob/user)
	/* Observers can view computers, but not actually use them via Topic*/
	if(istype(user, /mob/dead/observer)) return 0
	return ..()

/obj/machinery/computer/attackby(obj/I, mob/user, params)
	if(istype(I, /obj/item/screwdriver) && circuit && !(resistance_flags & INDESTRUCTIBLE))
		var/obj/item/screwdriver/S = I
		playsound(src.loc, S.usesound, 50, 1)
		if(do_after(user, 20 * S.toolspeed, target = src))
			var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
			var/obj/item/circuitboard/M = new circuit( A )
			A.circuit = M
			A.anchored = 1
			for(var/obj/C in src)
				C.loc = src.loc
			if(src.stat & BROKEN)
				to_chat(user, "<span class='notice'>The broken glass falls out.</span>")
				new /obj/item/shard(loc)
				A.state = 3
				A.icon_state = "3"
			else
				to_chat(user, "<span class='notice'>You disconnect the monitor.</span>")
				A.state = 4
				A.icon_state = "4"
			qdel(src)
	else
		attack_hand(user)
	return

/obj/machinery/computer/attack_alien(mob/living/user)
	if(isalien(user) && user.a_intent == INTENT_HELP)
		var/mob/living/carbon/alien/humanoid/xeno = user
		if(xeno.has_fine_manipulation)
			return attack_hand(user)

	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	if(circuit)
		if(prob(80))
			user.visible_message("<span class='danger'>[user.name] smashes the [src.name] with its claws.</span>",\
			"<span class='danger'>You smash the [src.name] with your claws.</span>",\
			"<span class='danger'>You hear a smashing sound.</span>")
			set_broken()
			return
	user.visible_message("<span class='danger'>[user.name] smashes against the [src.name] with its claws.</span>",\
	"<span class='danger'>You smash against the [src.name] with your claws.</span>",\
	"<span class='danger'>You hear a clicking sound.</span>")
