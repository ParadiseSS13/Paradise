#define VALID_REAGENTS list("sanguine_reagent", "osseous_reagent", "mutadone", "rezadone")

/obj/machinery/clonepod
	anchored = TRUE
	name = "cloning pod"
	desc = "An electronically-lockable pod for growing organic tissue."
	density = TRUE
	icon = 'icons/obj/cloning.dmi'
	icon_state = "pod_idle"

	//So that chemicals can be loaded into the pod.
	container_type = OPENCONTAINER
	//The linked cloning console
	var/obj/machinery/computer/cloning/console

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
			atom_say("Purged contaminant \"[R.name]\" from chemical storage.")

//Clonepod-specific procs

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
