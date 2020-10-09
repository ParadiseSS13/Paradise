/obj/item/inducer
	name = "inducer"
	desc = "A tool for inductively charging internal power cells."
	icon = 'icons/hispania/obj/tools.dmi'
	icon_state = "inducer-sci"
	item_state = "inducer-sci"
	lefthand_file = 'icons/hispania/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/hispania/mob/inhands/equipment/tools_righthand.dmi'
	origin_tech = "powerstorage=4;materials=4;engineering=4"
	force = 7
	flags =  CONDUCT
	var/obj/item/stock_parts/cell/cell
	var/powertransfer = null
	var/ratio = 0.15 //<15%> determina que porcentaje de la carga maxima promedio recargada (la mitad de la del objetivo entre la interna)
	var/coefficient_base = 1.1 //determina que porcentje de energia, del a bateria interna, se pierde al inducir, 10%
	var/mintransfer = 250 //determina el valor minimo de la energia inducida
	var/on = FALSE
	var/recharging = FALSE

/obj/item/inducer/attack_obj(obj/O, mob/living/carbon/user)
	if(user.a_intent == INTENT_HARM)
		return ..()
	if(recharging)
		return
	if(afterattack(O, user))
		return
	return ..()

/obj/item/inducer/emp_act(severity)
	. = ..()
	if(cell)
		cell.emp_act(severity)

/obj/item/inducer/proc/induce(obj/item/stock_parts/cell/target, coefficient)
	var/promcharge = (target.maxcharge + cell.maxcharge)/2
	powertransfer = max(mintransfer, (promcharge * ratio))
	var/totransfer = min((cell.charge/coefficient), powertransfer)
	var/transferred = target.give(totransfer)
	cell.use(transferred * coefficient)
	cell.update_icon()
	target.update_icon()

/obj/item/inducer/proc/invertinduce(obj/item/stock_parts/cell/target, coefficient)
	var/promcharge = (target.maxcharge + cell.maxcharge)/2
	powertransfer = max(mintransfer, (promcharge * ratio))
	var/totransfer = min((target.charge/coefficient), powertransfer)
	var/transferred = cell.give(totransfer)
	target.use(transferred * coefficient)
	cell.update_icon()
	target.update_icon()

/obj/item/inducer/attack(mob/M, mob/user)
	if(user.a_intent == INTENT_HARM)
		return ..()
	if(recharging)
		return
	if(afterattack(M, user))
		return
	return ..()

/obj/item/inducer/sci
	var/powered = FALSE
	var/coeff = 17 //multiplica al consumo energetico de la estacion
	var/opened = TRUE

/obj/item/inducer/sci/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)
	update_icon()

/obj/item/inducer/sci/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/inducer/sci/process()
	if(!on)
		return
	if(opened)
		return
	if(!cell)
		return
	if(cell.percent() >= 100)
		return
	if(recharging)
		return
	var/area/myarea = get_area(src)
	if(myarea)
		var/pow_chan
		for(var/c in list(EQUIP))
			if(myarea.powered(c))
				pow_chan = c
				powered = TRUE
				break
			else
				if(powered)
					powered = FALSE
					visible_message("<span class='warning'>the area is unpowered, [src]'s self charge turns off temporarily.</span>")
		if(pow_chan)
			var/self_charge = (cell.chargerate)/8	//1.25% por tick casi siempre
			var/delta = min(self_charge, (cell.maxcharge - cell.charge))
			cell.give(delta)
			myarea.use_power((delta * coeff), pow_chan)
			cell.update_icon()
	update_icon()

/obj/item/inducer/sci/get_cell()
	return cell

/obj/item/inducer/sci/attackby(obj/item/W, mob/user)
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
				to_chat(user, "<span class='notice'>[src] already has a [cell] installed!</span>")
				return

	if(afterattack(W, user))
		return

	return ..()

/obj/item/inducer/sci/afterattack(atom/movable/A as mob|obj, mob/user as mob, flag, params)
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

	if(opened)
		to_chat(user,"<span class='warning'>Its battery compartment is open.</span>")
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
	var/coefficient = coefficient_base
	if(istype(A, /obj/item/gun/energy))
		recharging = FALSE
		to_chat(user,"<span class='warning'>Error unable to interface with device</span>")
		return FALSE

	if(istype(A, /obj))
		if(istype(A, /obj/machinery/power/apc))
			coefficient = coefficient_base/GLOB.CELLRATE
		O = A
	if(C)
		var/done_any = FALSE
		if(C.charge >= C.maxcharge)
			to_chat(user, "<span class='notice'>[A] is fully charged!</span>")
			recharging = FALSE
			return TRUE
		user.visible_message("[user] starts recharging [A] with [src].","<span class='notice'>You start recharging [A] with [src].</span>")
		while(C.charge < C.maxcharge)
			if(do_after(user, 20, target = user) && cell.charge && !opened)
				done_any = TRUE
				induce(C, coefficient)
				do_sparks(1, FALSE, A)
				user.Beam(A,icon_state="purple_lightning",icon = 'icons/effects/effects.dmi',time=5)
				playsound(src, 'sound/magic/lightningshock.ogg', 25, 1)
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

/obj/item/inducer/sci/attack_self(mob/user)
	if(!opened || (opened && !cell))
		on = !on
		if(on)
			powered = TRUE
			to_chat(user,"<span class='notice'>you turn on the self charge.</span>")
		else
			powered = FALSE
			to_chat(user,"<span class='notice'>you turn off the self charge.</span>")
		update_icon()
	if(opened && cell && on)
		if(istype(user, /mob/living/carbon))
			var/mob/living/carbon/C = user
			C.electrocute_act(35, user, 1)
			playsound(get_turf(user), 'sound/magic/lightningshock.ogg', 50, 1, -1)
			new/obj/effect/temp_visual/revenant/cracks(user.loc)
			to_chat(user, "<span class='warning'>[src] electrocutes you!</span>")
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				if(H.get_int_organ(/obj/item/organ/internal/cell) && H.nutrition < 450)
					H.set_nutrition(min(H.nutrition + 50, 450))
			return
	if(opened && cell)
		user.visible_message("[user] removes [cell] from [src]!","<span class='notice'>You remove [cell].</span>")
		cell.update_icon()
		user.put_in_hands(cell)
		cell = null
		update_icon()

/obj/item/inducer/sci/examine(mob/living/M)
	..()
	if(on)
		to_chat(M,"<span class='notice'>the self charge is on.</span>")
	else
		to_chat(M,"<span class='notice'>the self charge is off.</span>")
	if(cell)
		to_chat(M, "<span class='notice'>Its display shows: [DisplayPower(cell.charge)] ([round(cell.percent() )]%).</span>")
	else
		to_chat(M,"<span class='notice'>Its display is dark.</span>")
	if(opened)
		to_chat(M,"<span class='notice'>Its battery compartment is open.</span>")

/obj/item/inducer/sci/update_icon()
	cut_overlays()
	if(!cell)
		add_overlay("inducer-unpowered")
		if(opened)
			add_overlay("inducer-nobat")
	else
		if(on)
			if(cell.percent() >= 100)
				add_overlay("inducer-charged")
			else
				if(powered)
					add_overlay("inducer-on")
				else
					add_overlay("inducer-unpowered")
		else
			add_overlay("inducer-off")
		if(opened)
			add_overlay("inducer-bat")

/obj/item/inducer/apc
	name = "APC's inducer"
	desc = "A tool for inductively charging APC's."
	icon_state = "inducer-engi"
	item_state = "inducer-engi"
	origin_tech = "powerstorage=4;materials=3;engineering=3"
	var/cell_type = /obj/item/stock_parts/cell
	ratio = 0.15 //<30%> determina que porcentaje de la carga maxima promedio recargada (la mitad de la del objetivo entre la interna)
	coefficient_base = 1.1 //determina que porcentje de energia, del a bateria interna, se pierde al inducir, 10%
	mintransfer = 50 //determina el valor minimo de la energia inducida
	on = TRUE

/obj/item/inducer/apc/Initialize()
	. = ..()
	if(!cell && cell_type)
		cell = new cell_type
		cell.charge = 500
	START_PROCESSING(SSobj, src)
	cell.update_icon()
	update_icon()

/obj/item/inducer/apc/attack_self(mob/user)
	on = !on
	if(on)
		to_chat(user,"<span class='notice'>switched to emission mode.</span>")
	else
		to_chat(user,"<span class='notice'>switched to suction mode.</span>")
	update_icon()

/obj/item/inducer/apc/update_icon()
	cut_overlays()
	if(on)
		if(cell.percent() >= 100)
			add_overlay("inducer-charged")
		else
			add_overlay("inducer-on")
	else
		add_overlay("inducer-unpowered")

/obj/item/inducer/apc/proc/DisplayPower(powerused)
	return "[powerused/2] kW"

/obj/item/inducer/apc/examine(mob/living/M)
	..()
	if(on)
		to_chat(M,"<span class='notice'>Emission mode is activate.</span>")
	else
		to_chat(M,"<span class='notice'>Suction mode is activate.</span>")
	if(cell)
		to_chat(M, "<span class='notice'>Its display shows: [DisplayPower(cell.charge)] ([round(cell.percent() )]%).</span>")
	else
		to_chat(M,"<span class='notice'>Its display is dark.</span>")

/obj/item/inducer/apc/attackby(obj/item/W, mob/user)
	if(afterattack(W, user))
		return
	return ..()

/obj/item/inducer/apc/afterattack(obj/machinery/power/apc/A as obj, mob/user as mob, flag, params)
	if(!flag)
		return FALSE

	if(user.a_intent == INTENT_HARM)
		return FALSE

	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You don't have the dexterity to use [src]!</span>")
		return FALSE

	if(!cell)
		to_chat(user, "<span class='warning'>[src] doesn't have a power cell installed!</span>")
		return FALSE

	if(istype(A, /turf))
		recharging = FALSE
		return FALSE

	if(ismob(A))
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
	var/coefficient = coefficient_base

	if(C)
		if(on)
			if(!cell.charge)
				to_chat(user, "<span class='warning'>[src] has no charge!</span>")
				recharging = FALSE
				return FALSE

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
					playsound(src, 'sound/magic/lightningshock.ogg', 25, 1)
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
		if(!on)
			if(!C.charge)
				to_chat(user, "<span class='warning'>[A]'s battery is dead!</span>")
				recharging = FALSE
				return TRUE
			var/done_any = FALSE

			if(cell.charge >= cell.maxcharge)
				to_chat(user, "<span class='notice'>[src] is fully charged!</span>")
				recharging = FALSE
				return TRUE
			user.visible_message("[user] starts recharging [src] with [A].","<span class='notice'>You start recharging [src] with [A].</span>")
			while(cell.charge < cell.maxcharge)
				if(do_after(user, 15, target = user) && C.charge)
					done_any = TRUE
					invertinduce(C, coefficient)
					do_sparks(1, FALSE, A)
					playsound(src, 'sound/magic/lightningshock.ogg', 25, 1)
					if(O)
						O.update_icon()
				else
					break
			if(done_any) // Only show a message if we succeeded at least once
				user.visible_message("[user] recharged [src]!","<span class='notice'>You recharged [src]!</span>")
				recharging = FALSE
				done_any = FALSE
			recharging = FALSE
			return TRUE
	recharging = FALSE
