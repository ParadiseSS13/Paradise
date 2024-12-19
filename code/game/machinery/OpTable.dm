/obj/machinery/optable
	name = "operating table"
	desc = "Used for advanced medical procedures."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "table2-idle"
	density = TRUE
	anchored = TRUE
	interact_offline = TRUE
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
	for(var/direction in list(NORTH,EAST,SOUTH,WEST))
		computer = locate(/obj/machinery/computer/operating, get_step(src, direction))
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

/obj/machinery/optable/CanPass(atom/movable/mover, border_dir)
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return TRUE
	if(isliving(mover))
		var/mob/living/our_mover = mover
		if(IS_HORIZONTAL(our_mover) && HAS_TRAIT(our_mover, TRAIT_CONTORTED_BODY))
			return TRUE
	else
		return FALSE

/obj/machinery/optable/MouseDrop_T(atom/movable/O, mob/user)
	return take_patient(O, user)

/obj/machinery/optable/post_unbuckle_mob(mob/living/M)
	. = ..()
	if(M == patient)
		patient = null
		update_appearance(UPDATE_ICON_STATE)

/obj/machinery/optable/proc/take_patient(mob/living/carbon/new_patient, mob/living/carbon/user)
	if((!ishuman(user) && !isrobot(user)) || !istype(new_patient))
		return
	if(patient in buckled_mobs)
		to_chat(user, "<span class='notice'>The table is already occupied!</span>")
		return

	// Attempt to settle the patient in
	if(!user_buckle_mob(new_patient, user, check_loc = FALSE))
		return // User is incapacitated, patient is already buckled to something else, etc.

	patient = new_patient

	if(length(injected_reagents))
		to_chat(new_patient, "<span class='danger'>You feel a series of tiny pricks!</span>")

	update_appearance(UPDATE_ICON_STATE)

	return TRUE

/obj/machinery/optable/process()

	if(!length(injected_reagents) || !patient || patient.stat == DEAD)
		return

	update_appearance(UPDATE_ICON_STATE)

	for(var/chemical in injected_reagents)
		patient.reagents.check_and_add(chemical, reagent_target_amount, inject_amount)

/obj/machinery/optable/update_icon_state()
	if(no_icon_updates)
		return
	if(patient?.pulse)
		icon_state = "table2-active"
	else
		icon_state = "table2-idle"

/obj/machinery/optable/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_start_check(src, user, 0))
		return
	if(I.use_tool(src, user, 20, volume = I.tool_volume))
		to_chat(user, "<span class='notice'>You deconstruct the table.</span>")
		new /obj/item/stack/sheet/plasteel(loc, 5)
		qdel(src)
