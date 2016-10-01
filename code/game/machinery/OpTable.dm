/obj/machinery/optable
	name = "Operating Table"
	desc = "Used for advanced medical procedures."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "table2-idle"
	density = 1
	anchored = 1.0
	use_power = 1
	idle_power_usage = 1
	active_power_usage = 5
	var/mob/living/carbon/human/victim = null
	var/strapped = 0.0

	var/obj/machinery/computer/operating/computer = null
	buckle_lying = 90
	var/no_icon_updates = 0 //set this to 1 if you don't want the icons ever changing

/obj/machinery/optable/New()
	..()
	for(dir in list(NORTH,EAST,SOUTH,WEST))
		computer = locate(/obj/machinery/computer/operating, get_step(src, dir))
		if(computer)
			computer.table = src
			break

/obj/machinery/optable/ex_act(severity)
	switch(severity)
		if(1.0)
			//SN src = null
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				//SN src = null
				qdel(src)
				return
		if(3.0)
			if(prob(25))
				src.density = 0
		else
	return

/obj/machinery/optable/blob_act()
	if(prob(75))
		qdel(src)

/obj/machinery/optable/attack_hand(mob/user as mob)
	if(HULK in usr.mutations)
		to_chat(usr, text("\blue You destroy the table."))
		visible_message("\red [usr] destroys the operating table!")
		src.density = 0
		qdel(src)
	return

/obj/machinery/optable/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1

	if(istype(mover) && mover.checkpass(PASSTABLE))
		return 1
	else
		return 0


/obj/machinery/optable/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if(usr.stat || (!ishuman(user) && !isrobot(user)) || user.restrained() || !check_table(user) || user.weakened || user.stunned)
		return

	if(!ismob(O)) //humans only
		return

	if(istype(O, /mob/living/simple_animal) || istype(O, /mob/living/silicon)) //animals and robots dont fit
		return

	var/mob/living/L = O
	take_victim(L,usr)
	return

/obj/machinery/optable/proc/check_victim()
	if(locate(/mob/living/carbon/human, src.loc))
		var/mob/living/carbon/human/M = locate(/mob/living/carbon/human, src.loc)
		if(M.lying)
			src.victim = M
			if(!no_icon_updates)
				icon_state = M.pulse ? "table2-active" : "table2-idle"
			return 1
	src.victim = null
	if(!no_icon_updates)
		icon_state = "table2-idle"
	return 0

/obj/machinery/optable/process()
	check_victim()

/obj/machinery/optable/proc/take_victim(mob/living/carbon/C, mob/living/carbon/user as mob)
	if(C == user)
		user.visible_message("[user] climbs on the operating table.","You climb on the operating table.")
	else
		visible_message("<span class='alert'>[C] has been laid on the operating table by [user].</span>")
	if(C.client)
		C.client.perspective = EYE_PERSPECTIVE
		C.client.eye = src
	C.resting = 1
	C.update_canmove()
	C.loc = src.loc
	if(user.pulling == C)
		user.stop_pulling()
	for(var/obj/O in src)
		O.loc = src.loc
	src.add_fingerprint(user)
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		src.victim = H
		if(!no_icon_updates)
			icon_state = H.pulse ? "table2-active" : "table2-idle"
	else
		if(!no_icon_updates)
			icon_state = "table2-idle"

/obj/machinery/optable/verb/climb_on()
	set name = "Climb On Table"
	set category = "Object"
	set src in oview(1)

	if(usr.stat || !ishuman(usr) || usr.restrained() || !check_table(usr))
		return

	take_victim(usr,usr)

/obj/machinery/optable/attackby(obj/item/weapon/W as obj, mob/living/carbon/user as mob, params)
	if(istype(W, /obj/item/weapon/grab))
		if(iscarbon(W:affecting))
			take_victim(W:affecting,usr)
			qdel(W)
			return
	if(istype(W, /obj/item/weapon/wrench))
		playsound(src.loc, 'sound/items/Ratchet.ogg', 50, 1)
		if(do_after(user, 20, target = src))
			to_chat(user, "<span class='notice'>You deconstruct the table.</span>")
			new /obj/item/stack/sheet/plasteel(loc, 5)
			qdel(src)


/obj/machinery/optable/proc/check_table(mob/living/carbon/patient as mob)
	if(src.victim && get_turf(victim) == get_turf(src) && victim.lying)
		to_chat(usr, "<span class='notice'>The table is already occupied!</span>")
		return 0

	if(patient.buckled)
		to_chat(usr, "<span class='notice'>Unbuckle first!</span>")
		return 0

	return 1
