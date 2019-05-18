/obj/item/implant/explosive
	name = "microbomb implant"
	desc = "And boom goes the weasel."
	icon_state = "explosive"
	origin_tech = "materials=2;combat=3;biotech=4;syndicate=4"
	var/weak = 2
	var/medium = 0.8
	var/heavy = 0.4
	var/delay = 7

/obj/item/implant/explosive/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Robust Corp RX-78 Employee Management Implant<BR>
				<b>Life:</b> Activates upon death.<BR>
				<b>Important Notes:</b> Explodes<BR>
				<HR>
				<b>Implant Details:</b><BR>
				<b>Function:</b> Contains a compact, electrically detonated explosive that detonates upon receiving a specially encoded signal or upon host death.<BR>
				<b>Special Features:</b> Explodes<BR>
				"}
	return dat

/obj/item/implant/explosive/trigger(emote, mob/source, force)
	if(force && emote == "deathgasp")
		activate("death")

/obj/item/implant/explosive/activate(cause)
	if(!cause || !imp_in)	return 0
	if(cause == "action_button" && alert(imp_in, "Are you sure you want to activate your microbomb implant? This will cause you to explode!", "Microbomb Implant Confirmation", "Yes", "No") != "Yes")
		return 0
	heavy = round(heavy)
	medium = round(medium)
	weak = round(weak)
	to_chat(imp_in, "<span class='notice'>You activate your microbomb implant.</span>")
//If the delay is short, just blow up already jeez
	if(delay <= 7)
		explosion(src,heavy,medium,weak,weak, flame_range = weak)
		if(imp_in)
			imp_in.gib()
		qdel(src)
		return
	timed_explosion()

/obj/item/implant/explosive/implant(mob/source)
	var/obj/item/implant/explosive/imp_e = locate(src.type) in source
	if(imp_e && imp_e != src)
		imp_e.heavy += heavy
		imp_e.medium += medium
		imp_e.weak += weak
		imp_e.delay += delay
		qdel(src)
		return 1

	return ..()

/obj/item/implant/explosive/proc/timed_explosion()
	imp_in.visible_message("<span class = 'warning'>[imp_in] starts beeping ominously!</span>")
	playsound(loc, 'sound/items/timer.ogg', 30, 0)
	sleep(delay/4)
	if(imp_in && imp_in.stat)
		imp_in.visible_message("<span class = 'warning'>[imp_in] doubles over in pain!</span>")
		imp_in.Weaken(7)
	playsound(loc, 'sound/items/timer.ogg', 30, 0)
	sleep(delay/4)
	playsound(loc, 'sound/items/timer.ogg', 30, 0)
	sleep(delay/4)
	playsound(loc, 'sound/items/timer.ogg', 30, 0)
	sleep(delay/4)
	explosion(src,heavy,medium,weak,weak, flame_range = weak)
	if(imp_in)
		imp_in.gib()
	qdel(src)

/obj/item/implant/explosive/macro
	name = "macrobomb implant"
	desc = "And boom goes the weasel. And everything else nearby."
	icon_state = "explosive"
	origin_tech = "materials=3;combat=5;biotech=4;syndicate=5"
	weak = 16
	medium = 8
	heavy = 4
	delay = 70

/obj/item/implant/explosive/macro/activate(cause)
	if(!cause || !imp_in)	return 0
	if(cause == "action_button" && alert(imp_in, "Are you sure you want to activate your macrobomb implant? This will cause you to explode and gib!", "Macrobomb Implant Confirmation", "Yes", "No") != "Yes")
		return 0
	to_chat(imp_in, "<span class='notice'>You activate your macrobomb implant.</span>")
	timed_explosion()

/obj/item/implant/explosive/macro/implant(mob/source)
	var/obj/item/implant/explosive/imp_e = locate(src.type) in source
	if(imp_e && imp_e != src)
		return 0
	imp_e = locate(/obj/item/implant/explosive) in source
	if(imp_e && imp_e != src)
		heavy += imp_e.heavy
		medium += imp_e.medium
		weak += imp_e.weak
		delay += imp_e.delay
		qdel(imp_e)

	return ..()


/obj/item/implanter/explosive
	name = "implanter (explosive)"

/obj/item/implanter/explosive/New()
	imp = new /obj/item/implant/explosive(src)
	..()


/obj/item/implantcase/explosive
	name = "implant case - 'Explosive'"
	desc = "A glass case containing an explosive implant."

/obj/item/implantcase/explosive/New()
	imp = new /obj/item/implant/explosive(src)
	..()


/obj/item/implanter/explosive_macro
	name = "implanter (macro-explosive)"

/obj/item/implanter/explosive_macro/New()
	imp = new /obj/item/implant/explosive/macro(src)
	..()


// Dust implant, for CC officers. Prevents gear theft if they die.

/obj/item/implant/dust
	name = "duster implant"
	desc = "An alarm which monitors host vital signs, transmitting a radio message and dusting the corpse on death."
	icon = 'icons/effects/blood.dmi'
	icon_state = "remains"

/obj/item/implant/dust/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Ultraviolet Corp XX-13 Security Implant<BR>
				<b>Life:</b> Activates upon death.<BR>
				<b>Important Notes:</b> Vaporizes organic matter<BR>
				<HR>
				<b>Implant Details:</b><BR>
				<b>Function:</b> Contains a compact, electrically activated heat source that turns its host to ash upon activation, or their death. <BR>
				<b>Special Features:</b> Vaporizes<BR>
				"}
	return dat

/obj/item/implant/dust/trigger(emote, mob/source, force)
	if(force && emote == "deathgasp")
		activate("death")

/obj/item/implant/dust/activate(cause)
	if(!cause || !imp_in || cause == "emp")
		return 0
	if(cause == "action_button" && alert(imp_in, "Are you sure you want to activate your dusting implant? This will turn you to ash!", "Dusting Confirmation", "Yes", "No") != "Yes")
		return 0
	to_chat(imp_in, "<span class='notice'>Your dusting implant activates!</span>")
	imp_in.visible_message("<span class = 'warning'>[imp_in] burns up in a flash!</span>")
	for(var/obj/item/I in imp_in.contents)
		if(I == src)
			continue
		if(I.flags & NODROP)
			qdel(I)
	imp_in.dust()

/obj/item/implant/dust/emp_act(severity)
	return

/obj/item/implanter/dust
	name = "implanter (Dust-on-death)"

/obj/item/implanter/dust/New()
	imp = new /obj/item/implant/dust(src)
	..()