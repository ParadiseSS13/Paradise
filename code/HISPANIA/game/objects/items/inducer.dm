/obj/item/inducer
	name = "inducer"
	desc = "A tool for inductively charging internal power cells."
	icon = 'icons/hispania/obj/tools.dmi'
	icon_state = "inducer-engi"
	item_state = "inducer-engi"
	lefthand_file = 'icons/hispania/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/hispania/mob/inhands/equipment/tools_righthand.dmi'
	origin_tech = "powerstorage=4;materials=4;engineering=4"
	force = 7
	flags =  CONDUCT
	var/opened = FALSE
	var/cell_type = /obj/item/stock_parts/cell/high
	var/obj/item/stock_parts/cell/cell
	var/powertransfer = null
	var/ratio = 0.1
	var/recharging = FALSE
	var/area/myarea
	var/mintransfer = 1000


/obj/item/inducer/Initialize()
	. = ..()
	if(!cell && cell_type)
		cell = new cell_type
	START_PROCESSING(SSobj, src)
	update_icon()

/obj/item/inducer/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/inducer/process()
	if(!cell)
		return
	if(cell.percent() >= 100)
		return
	if(recharging)
		return
	myarea = get_area(src)
	var/pow_chan
	for(var/c in list(EQUIP))
		if(myarea.powered(c))
			pow_chan = c
			break
	if(pow_chan)
		cell.give(50)
		myarea.use_power(200)
	update_icon()

/obj/item/inducer/proc/induce(obj/item/stock_parts/cell/target, coefficient)
	powertransfer = min(mintransfer, (cell.maxcharge * ratio))
	var/totransfer = min(cell.charge,(powertransfer * coefficient))
	var/transferred = target.give(totransfer)
	cell.use(transferred)
	cell.update_icon()
	target.update_icon()

/obj/item/inducer/get_cell()
	return cell

/obj/item/inducer/emp_act(severity)
	. = ..()
	if(cell)
		cell.emp_act(severity)

/obj/item/inducer/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/screwdriver))
		playsound(loc, W.usesound, 100, 1)
		if(!opened)
			to_chat(user, "<span class='notice'>You unscrew the battery compartment.</span>")
			opened = TRUE
			update_icon()
			return
		else
			to_chat(user, "<span class='notice'>You close the battery compartment.</span>")
			opened = FALSE
			update_icon()
			return
	if(istype(W, /obj/item/stock_parts/cell))
		if(opened)
			if(!cell)
				if(!user.drop_item(W, src))
					return
				to_chat(user, "<span class='notice'>You insert [W] into [src].</span>")
				W.loc = src
				cell = W
				update_icon()
				return
			else
				to_chat(user, "<span class='notice'>[src] already has \a [cell] installed!</span>")
				return

	if(afterattack(W, user))
		return

	return ..()

/obj/item/inducer/afterattack(atom/movable/A as mob|obj, mob/user as mob, flag, params)
	if(user.a_intent == INTENT_HARM)
		return FALSE

	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to use [src]!</span>")
		return FALSE

	if(!cell)
		to_chat(user, "<span class='warning'>[src] doesn't have a power cell installed!</span>")
		return FALSE

	if(!cell.charge)
		to_chat(user, "<span class='warning'>[src]'s battery is dead!</span>")
		return FALSE

	if(!isturf(A) && user.loc == A)
		return FALSE

	if(istype(A, /turf))
		recharging = FALSE
		return FALSE

	if(recharging)
		return TRUE
	else
		recharging = TRUE

	var/obj/item/stock_parts/cell/C = A.get_cell()
	if(!C)
		recharging = FALSE
		return FALSE
	var/obj/O
	var/coefficient = 1
	if(istype(A, /obj/item/gun/energy))
		to_chat(user,"<span class='warning'>Error unable to interface with device</span>")
		return FALSE
	if(istype(A, /obj))
		O = A
	if(C)
		var/done_any = FALSE
		if(C.charge >= C.maxcharge)
			to_chat(user, "<span class='notice'>[A] is fully charged!</span>")
			recharging = FALSE
			return TRUE
		user.visible_message("[user] starts recharging [A] with [src].","<span class='notice'>You start recharging [A] with [src].</span>")
		while(C.charge < C.maxcharge)
			if(do_after(user, 20, target = user) && cell.charge)
				done_any = TRUE
				induce(C, coefficient)
				do_sparks(1, FALSE, A)
				user.Beam(A,icon_state="purple_lightning",icon = 'icons/effects/effects.dmi',time=5)
				playsound(src, 'sound/magic/lightningshock.ogg', 40, 1)
				if(O)
					O.update_icon()
			else
				break
		if(done_any) // Only show a message if we succeeded at least once
			user.visible_message("[user] recharged [A]!","<span class='notice'>You recharged [A]!</span>")
			recharging = FALSE
			done_any = FALSE
		recharging = FALSE
		return TRUE
	recharging = FALSE

/obj/item/inducer/attack(mob/M, mob/user)
	if(user.a_intent == INTENT_HARM)
		return ..()
	if(recharging)
		return
	if(afterattack(M, user))
		return
	return ..()

/obj/item/inducer/attack_obj(obj/O, mob/living/carbon/user)
	if(user.a_intent == INTENT_HARM)
		return ..()
	if(recharging)
		return
	if(afterattack(O, user))
		return
	return ..()

/obj/item/inducer/attack_self(mob/user)
	if(opened && cell)
		user.visible_message("[user] removes [cell] from [src]!","<span class='notice'>You remove [cell].</span>")
		cell.update_icon()
		user.put_in_hands(cell)
		cell = null
		update_icon()

/obj/item/inducer/examine(mob/living/M)
	..()
	if(cell)
		to_chat(M, "<span class='notice'>Its display shows: [DisplayPower(cell.charge)].</span>")
	else
		to_chat(M,"<span class='notice'>Its display is dark.</span>")
	if(opened)
		to_chat(M,"<span class='notice'>Its battery compartment is open.</span>")

/obj/item/inducer/update_icon()
	cut_overlays()
	if(opened)
		if(!cell)
			add_overlay("inducer-nobat")
		else
			add_overlay("inducer-bat")


/obj/item/inducer/sci
	icon_state = "inducer-sci"
	item_state = "inducer-sci"
	desc = "A tool for inductively charging internal power cells. This one has a science color scheme, and is less potent than its engineering counterpart."
	origin_tech = "powerstorage=4;materials=4;engineering=3"
	cell_type = null
	ratio = 0.05
	opened = TRUE
	mintransfer = 500

/obj/item/inducer/sci/Initialize()
	. = ..()
	update_icon()
