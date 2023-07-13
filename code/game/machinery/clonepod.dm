#define VALID_REAGENTS list("sanguine_reagent", "osseous_reagent", "mutadone", "rezadone")

//Balance tweaks go here vv
#define BIOMASS_BASE_COST 250
//These ones are also used for dead limbs/organs
#define BIOMASS_NEW_LIMB_COST 200 //A limb can have 100 brute damage and 100 burn damage, so 100*the values for those gets 200
#define BIOMASS_NEW_ORGAN_COST 100
#define BIOMASS_BURN_WOUND_COST 25
//These 3 are for every point of the respective damage type
#define BIOMASS_BRUTE_COST 0.5
#define BIOMASS_BURN_COST 0.5
#define BIOMASS_ORGAN_DAMAGE_COST 1
#define SANGUINE_IB_COST 5
#define OSSEOUS_BONE_COST 5


/obj/machinery/clonepod
	anchored = TRUE
	name = "cloning pod"
	desc = "An electronically-lockable pod for growing organic tissue."
	density = TRUE
	icon = 'icons/obj/cloning.dmi'
	icon_state = "pod_idle"

	//So that chemicals can be loaded into the pod.
	container_type = OPENCONTAINER
	//The linked cloning console.
	var/obj/machinery/computer/cloning/console
	//Whether or not we're cloning someone.
	var/currently_cloning = FALSE
	//The progress on the current clone.
	//Measured from 0-100, where 0-20 has no body, and 21-100 gradually builds on limbs every 10. (r_arm, r_hand, l_arm, l_hand, r_leg, r_foot, l_leg, l_foot)
	var/clone_progress = 0
	//The speed at which we clone. Each processing cycle will advance clone_progress by this amount.
	var/speed_modifier = 1
	//Our price modifier, multiplied with the base cost to get the true cost.
	var/price_modifier = 1
	//The cloning_data datum which shows the patient's current status.
	var/datum/cloning_data/patient_data
	//The cloning_data datum which shows the status we want the patient to be in.
	var/datum/cloning_data/desired_data

/obj/machinery/clonepod/Initialize(mapload)
	. = ..()

	if(!console && mapload)
		console = pick(locate(/obj/machinery/computer/cloning, orange(5, src))) //again, there shouldn't be multiple consoles, mappers

	component_parts = list()
	component_parts += new /obj/item/circuitboard/clonepod(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stock_parts/scanning_module(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	component_parts += new /obj/item/reagent_containers/glass/beaker/large/(null)
	create_reagents()
	update_icon()

/obj/machinery/clonepod/biomass/Initialize(mapload)
	. = ..()

/obj/machinery/clonepod/upgraded/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/clonepod(null)
	component_parts += new /obj/item/stock_parts/scanning_module/phasic(null)
	component_parts += new /obj/item/stock_parts/scanning_module/phasic(null)
	component_parts += new /obj/item/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/stack/sheet/glass(null)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	component_parts += new /obj/item/stack/cable_coil(null, 1)
	component_parts += new /obj/item/reagent_containers/glass/beaker/bluespace/(null)
	update_icon()

/obj/machinery/clonepod/examine(mob/user)
	. = ..()

/obj/machinery/clonepod/attack_ai(mob/user)
	return examine(user)

//Process
/obj/machinery/clonepod/process()
	//Basically just isolate_reagent() with extra functionality.
	for(var/A in reagents.reagent_list)
		var/datum/reagent/R = A
		if(!(R.id in VALID_REAGENTS))
			reagents.del_reagent(R.id)
			reagents.update_total()
			atom_say("Purged contaminant from chemical storage.")

	if(currently_cloning)
		clone_progress += speed_modifier
		switch(clone_progress)
			if(0 to 20)
				return
			if(21 to 30)
				return
			if(31 to 40)
				return

//Clonepod-specific procs
//This just begins the cloning process. Called by the cloning console.
/obj/machinery/clonepod/proc/begin_cloning(datum/cloning_data/_patient_data, datum/cloning_data/_desired_data)
	currently_cloning = TRUE
	patient_data = _patient_data
	desired_data = _desired_data

//This gets the cost of cloning, in a list with the form (biomass, sanguine reagent, osseous reagent).
/obj/machinery/clonepod/proc/get_cloning_cost(datum/cloning_data/_patient_data, datum/cloning_data/_desired_data)
	var/datum/cloning_data/p_data = _patient_data
	var/datum/cloning_data/d_data = _desired_data
	//Biomass, sanguine reagent, osseous reagent
	var/list/cloning_cost = list((price_modifier*BIOMASS_BASE_COST), 0, 0)

	if(!istype(p_data) || !istype(d_data))
		return //this shouldn't happen but whatever

	for(var/limb in p_data.limbs)
		var/list/patient_limb_info = p_data.limbs[limb]
		var/patient_limb_status = patient_limb_info[3]

		var/list/desired_limb_info = d_data.limbs[limb]
		var/desired_limb_status = desired_limb_info[3]

		if(p_data.limbs[limb][4] && !d_data.limbs[limb][4]) //if the limb is missing on the patient and we want it to not be
			cloning_cost[1] += BIOMASS_NEW_LIMB_COST * price_modifier
			continue //then continue - since we're replacing the limb, we don't need to fix its damages

		if((patient_limb_status & ORGAN_DEAD) && !(desired_limb_status & ORGAN_DEAD)) //if the patient's limb is dead and we don't want it to be
			cloning_cost[1] += BIOMASS_NEW_LIMB_COST * price_modifier
			continue //as above

		var/brute_damage_diff = patient_limb_info[1] - desired_limb_info[1]
		cloning_cost[1] += BIOMASS_BRUTE_COST * brute_damage_diff * price_modifier

		var/burn_damage_diff = patient_limb_info[2] - desired_limb_info[2]
		cloning_cost[1] += BIOMASS_BURN_COST * burn_damage_diff * price_modifier

		if((patient_limb_status & ORGAN_BURNT) && !(desired_limb_status & ORGAN_BURNT)) //if the patient's limb has a burn wound and we don't want it to
			cloning_cost[1] += BIOMASS_BURN_WOUND_COST * price_modifier

		if((patient_limb_status & ORGAN_INT_BLEEDING) && !(desired_limb_status & ORGAN_INT_BLEEDING)) //if the patient's limb has IB and we want it to not be
			cloning_cost[2] += SANGUINE_IB_COST * price_modifier

		if((patient_limb_status & ORGAN_BROKEN) && !(desired_limb_status & ORGAN_BROKEN)) //if the patient's limb is broken and we want it to not be
			cloning_cost[3] += OSSEOUS_BONE_COST * price_modifier

	for(var/organ in p_data.organs)
		var/list/patient_organ_info = p_data.organs[organ]
		var/patient_organ_status = patient_organ_info[2]

		var/list/desired_organ_info = d_data.organs[organ]
		var/desired_organ_status = desired_organ_info[2]

		if(organ == "heart")
			continue //The heart is always replaced in cloning because heart necrosis is why defibs stop working after 5 minutes.
					 //The cost of this is factored into BIOMASS_BASE_COST, so we don't account for it here.

		if((desired_organ_status & ORGAN_DEAD) && !(patient_organ_status & ORGAN_DEAD)) //if the patient's organ is dead and we want it to not be
			cloning_cost[1] += BIOMASS_NEW_ORGAN_COST * price_modifier
			continue //.. then continue, because if we replace the organ we don't need to fix its damages

		var/organ_damage_diff = patient_organ_info[1] - desired_organ_info[1]
		cloning_cost[1] += BIOMASS_ORGAN_DAMAGE_COST * organ_damage_diff * price_modifier

	cloning_cost[1] = round(cloning_cost[1]) //no decimal-point amounts of biomass!

	return cloning_cost

//Attackby and x_acts
/obj/machinery/clonepod/attackby(obj/item/I, mob/user, params)
	if(exchange_parts(user, I))
		return

	if(is_open_container(I))
		return

	return ..()

/obj/machinery/clonepod/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	default_deconstruction_crowbar(user, I)

/obj/machinery/clonepod/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!I.multitool_check_buffer(user))
		return
	var/obj/item/multitool/M = I
	M.set_multitool_buffer(user, src)

/obj/machinery/clonepod/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	default_deconstruction_screwdriver(user, null, null, I)
	update_icon()

/obj/machinery/clonepod/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(anchored)
		WRENCH_UNANCHOR_MESSAGE
		anchored = FALSE
	else
		WRENCH_ANCHOR_MESSAGE
		anchored = TRUE

/obj/machinery/clonepod/emag_act(user)

/obj/machinery/clonepod/cmag_act(mob/user)
	if(HAS_TRAIT(src, TRAIT_CMAGGED))
		return
	playsound(src, "sparks", 75, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	to_chat(user, "<span class='warning'>A droplet of bananium ooze seeps into the synthmeat storage chamber...</span>")
	ADD_TRAIT(src, TRAIT_CMAGGED, CLOWN_EMAG)

/obj/machinery/clonepod/emp_act(severity)
	..()

/obj/machinery/clonepod/ex_act(severity)
	..()


//Icon stuff
/obj/machinery/clonepod/update_icon_state()
	//TODO: this logic. lol

/obj/machinery/clonepod/update_overlays()
	. = ..()
	if(panel_open)
		. += "panel_open"

#undef VALID_REAGENTS

#undef BIOMASS_BASE_COST
#undef BIOMASS_NEW_LIMB_COST
#undef BIOMASS_NEW_ORGAN_COST
#undef BIOMASS_BURN_WOUND_COST
#undef BIOMASS_BRUTE_COST
#undef BIOMASS_BURN_COST
#undef BIOMASS_ORGAN_DAMAGE_COST
#undef SANGUINE_IB_COST
#undef OSSEOUS_BONE_COST
/*
 *	Manual -- A big ol' manual. jimkil TODO: rewrite this
 */

/obj/item/paper/Cloning
	name = "paper - 'H-87 Cloning Apparatus Manual"
	info = {"<h4>Getting Started</h4>
	Congratulations, your station has purchased the H-87 industrial cloning device!<br>
	Using the H-87 is almost as simple as brain surgery! Simply insert the target humanoid into the scanning chamber and select the scan option to create a new profile!<br>
	<b>That's all there is to it!</b><br>
	<i>Notice, cloning system cannot scan inorganic life or small primates.  Scan may fail if subject has suffered extreme brain damage.</i><br>
	<p>Clone profiles may be viewed through the profiles menu. Scanning implants a complementary HEALTH MONITOR BIO-CHIP into the subject, which may be viewed from each profile.
	Profile Deletion has been restricted to \[Station Head\] level access.</p>
	<h4>Cloning from a profile</h4>
	Cloning is as simple as pressing the CLONE option at the bottom of the desired profile.<br>
	Per your company's EMPLOYEE PRIVACY RIGHTS agreement, the H-87 has been blocked from cloning crewmembers while they are still alive.<br>
	<br>
	<p>The provided CLONEPOD SYSTEM will produce the desired clone.  Standard clone maturation times (With SPEEDCLONE technology) are roughly 90 seconds.
	The cloning pod may be unlocked early with any \[Medical Researcher\] ID after initial maturation is complete.</p><br>
	<i>Please note that resulting clones may have a small DEVELOPMENTAL DEFECT as a result of genetic drift.</i><br>
	<h4>Profile Management</h4>
	<p>The H-87 (as well as your station's standard genetics machine) can accept STANDARD DATA DISKETTES.
	These diskettes are used to transfer genetic information between machines and profiles.
	A load/save dialog will become available in each profile if a disk is inserted.</p><br>
	<i>A good diskette is a great way to counter aforementioned genetic drift!</i><br>
	<br>
	<font size=1>This technology produced under license from Thinktronic Systems, LTD.</font>"}
