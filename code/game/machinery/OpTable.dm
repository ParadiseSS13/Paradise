/obj/machinery/optable
	name = "operating table"
	desc = "Used for advanced medical procedures."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "table2-idle"
	density = TRUE
	anchored = TRUE
	idle_power_consumption = 1
	active_power_consumption = 5
	can_buckle = TRUE // you can buckle someone if they have cuffs
	buckle_lying = TRUE
	var/mob/living/carbon/patient
	var/obj/machinery/computer/operating/computer
	var/no_icon_updates = FALSE //set this to TRUE if you don't want the icons ever changing
	var/list/injected_reagents = list()
	var/reagent_target_amount = 1
	var/inject_amount = 1


/obj/machinery/optable/Initialize(mapload)
	. = ..()
	for(dir in list(NORTH,EAST,SOUTH,WEST))
		computer = locate(/obj/machinery/computer/operating, get_step(src, dir))
		if(computer)
			computer.table = src
			break

/obj/machinery/optable/Destroy()
	if(computer)
		computer.table = null
		computer = null
	patient = null
	return ..()

/obj/machinery/optable/examine(mob/user)
	. = ..()
	. += "<span class='notice'><b>Click-drag</b> someone to the table to place them on top of the table.</span>"

/obj/machinery/optable/attack_hulk(mob/living/carbon/human/user, does_attack_animation = FALSE)
	if(user.a_intent == INTENT_HARM)
		..(user, TRUE)
		visible_message("<span class='warning'>[user] destroys [src]!</span>")
		qdel(src)
		return TRUE

/obj/machinery/optable/CanPass(atom/movable/mover, turf/target, height=0)
	if(height == 0)
		return TRUE
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return TRUE
	else
		return FALSE

/obj/machinery/optable/MouseDrop_T(atom/movable/O, mob/user)
	if(!ishuman(user) && !isrobot(user)) //Only Humanoids and Cyborgs can put things on this table
		return
	if(!check_table()) //If the Operating Table is occupied, you cannot put someone else on it
		return
	if(user.buckled || user.incapacitated()) //Is the person trying to use the table incapacitated or restrained?
		return
	if(!ismob(O) || !iscarbon(O)) //Only Mobs and Carbons can go on this table (no syptic patches please)
		return
	if(!user_buckle_mob(O, user, check_loc = FALSE))
		return
	take_patient(O, user)

/**
  * Updates the `patient` var to be the mob occupying the table
  */
/obj/machinery/optable/proc/update_patient()
	var/mob/living/carbon/C = locate(/mob/living/carbon, loc)
	if(C && IS_HORIZONTAL(C))
		patient = C
	else
		patient = null
	if(!no_icon_updates)
		if(C && C.pulse)
			icon_state = "table2-active"
		else
			icon_state = "table2-idle"

/obj/machinery/optable/Crossed(atom/movable/AM, oldloc)
	. = ..()
	if(iscarbon(AM) && LAZYLEN(injected_reagents))
		to_chat(AM, "<span class='danger'>You feel a series of tiny pricks!</span>")

/obj/machinery/optable/process()
	update_patient()
	if(LAZYLEN(injected_reagents))
		for(var/mob/living/carbon/C in get_turf(src))
			if(C.stat == DEAD)
				continue
			var/datum/reagents/R = C.reagents
			for(var/chemical in injected_reagents)
				R.check_and_add(chemical,reagent_target_amount,inject_amount)

/obj/machinery/optable/proc/take_patient(mob/living/carbon/new_patient, mob/living/carbon/user)
	if(new_patient == user)
		user.visible_message("[user] climbs on [src].","You climb on [src].")
	else
		visible_message("<span class='alert'>[new_patient] has been laid on [src] by [user].</span>")
	new_patient.resting = TRUE
	if(new_patient.s_active) //Close the container opened
		new_patient.s_active.close(new_patient)
	add_fingerprint(user)
	update_patient()

/obj/machinery/optable/verb/climb_on()
	set name = "Climb On Table"
	set category = "Object"
	set src in oview(1)
	if(usr.stat || !iscarbon(usr) || usr.restrained() || !check_table())
		return
	take_patient(usr, usr)

/obj/machinery/optable/attackby(obj/item/I, mob/living/carbon/user, params)
	if(istype(I, /obj/item/grab))
		var/obj/item/grab/G = I
		if(iscarbon(G.affecting))
			take_patient(G.affecting, user)
			qdel(G)
	else
		return ..()

/obj/machinery/optable/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_start_check(src, user, 0))
		return
	if(I.use_tool(src, user, 20, volume = I.tool_volume))
		to_chat(user, "<span class='notice'>You deconstruct the table.</span>")
		new /obj/item/stack/sheet/plasteel(loc, 5)
		qdel(src)

/obj/machinery/optable/proc/check_table()
	update_patient()
	if(patient != null)
		to_chat(usr, "<span class='notice'>The table is already occupied!</span>")
		return FALSE
	else
		return TRUE
