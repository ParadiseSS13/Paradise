/obj/machinery/anomaly_refinery
	name = "anomaly refinery"
	desc = "An advanced machine capable of implosion-compressing raw anomaly cores into finished artifacts. Also equipped with state of the art anomaly-analysis software."
	icon = 'icons/obj/machines/research.dmi'
	base_icon_state = "explosive_compressor"
	icon_state = "explosive_compressor"
	density = TRUE

	/// The raw core inserted in the machine.
	var/obj/item/raw_anomaly_core/inserted_core
	/// The refined core produced by the machine
	var/obj/item/assembly/signaler/anomaly/refined_core
	/// The message produced by the explosive compressor at the end of the compression test.
	var/test_status = ""
	/// Linked tachyon-doppler array
	var/obj/machinery/doppler_array/linked_doppler

/obj/machinery/anomaly_refinery/Initialize(mapload)
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/anomaly_refinery(src)
	component_parts += new /obj/item/stock_parts/scanning_module(src)
	component_parts += new /obj/item/stack/sheet/glass(src)
	component_parts += new /obj/item/stack/cable_coil(src, 2)
	RefreshParts()
	// Try to link to tachyon-doppler array on initialize. Link to the first doppler it can find.
	for(var/obj/machinery/doppler_array/doppler in view(3, src))
		linked_doppler = doppler
		linked_doppler.linked_machines |= src
		return

/obj/machinery/anomaly_refinery/examine(mob/user)
	. = ..()
	if(inserted_core)
		. += "There is [inserted_core] in [src]."
		. += "[inserted_core]'s causality point corresponds to an explosive of size [inserted_core.target_explosion_size]."
	if(refined_core)
		. += "There is a [refined_core] in [src]."

/obj/machinery/anomaly_refinery/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(!istype(used, /obj/item/raw_anomaly_core))
		return ..()
	if(refined_core)
		to_chat(user, "<span class='warning'>There is already a core in [src]!</span>")
		return ITEM_INTERACT_COMPLETE
	if(used.flags & NODROP || !user.drop_item() || !used.forceMove(src))
		to_chat(user, "<span class='warning'>[used] is stuck to your hand!</span>")
		return ITEM_INTERACT_COMPLETE
	inserted_core = used
	to_chat(user, "<span class='notice'>You insert [used] into [src].</span>")
	atom_say("Analyzing... [inserted_core]'s causality point corresponds to an explosive of size [inserted_core.target_explosion_size].")
	return ITEM_INTERACT_COMPLETE

/obj/machinery/anomaly_refinery/attack_hand(mob/user)
	if(..())
		return
	add_fingerprint(user)
	if(refined_core)
		user.put_in_active_hand(refined_core)
		refined_core = null
		return
	if(inserted_core)
		user.put_in_active_hand(inserted_core)
		inserted_core = null
		return

/obj/machinery/anomaly_refinery/screwdriver_act(mob/user, obj/item/I)
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	. = TRUE
	default_deconstruction_screwdriver(user, icon_state, icon_state, I)

/obj/machinery/anomaly_refinery/crowbar_act(mob/user, obj/item/I)
	if(default_deconstruction_crowbar(user, I))
		return TRUE

/obj/machinery/anomaly_refinery/multitool_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(!I.multitool_check_buffer(user))
		return
	if(panel_open)
		var/obj/item/multitool/multi = I
		if(!istype(multi.buffer, /obj/machinery/doppler_array))
			to_chat(user, "<span class='notice'>You cannot link [multi.buffer] to [src]!</span>")
			return
		linked_doppler = multi.buffer
		linked_doppler.linked_machines |= src
		to_chat(user, "<span class='notice'>You link [multi.buffer] to [src].</span>")

/obj/machinery/anomaly_refinery/proc/refine_core(explosion_size)
	if(!inserted_core)
		return
	if(inserted_core.target_explosion_size != explosion_size)
		atom_say("Temporal displacement detected. Criticality status: FAILURE.")
		return
	inserted_core = null
	if(emagged)
		atom_say("Temporal displacement detected. Criticality status: SUCCESS.")
		atom_say("ERROR: CONTAINMENT STATUS - NONFUNCTIONAL.")
		var/list/types = list(/obj/effect/anomaly/flux, /obj/effect/anomaly/cryo, /obj/effect/anomaly/grav, /obj/effect/anomaly/pyro, /obj/effect/anomaly/bluespace, /obj/effect/anomaly/bhole)
		var/released_anomaly = pick(types)
		new released_anomaly(get_turf(src))
		return
	var/list/types = list(/obj/item/assembly/signaler/anomaly/pyro,
		/obj/item/assembly/signaler/anomaly/cryo,
		/obj/item/assembly/signaler/anomaly/grav,
		/obj/item/assembly/signaler/anomaly/flux,
		/obj/item/assembly/signaler/anomaly/bluespace,
		/obj/item/assembly/signaler/anomaly/vortex)
	var/A = pick(types)
	refined_core = new A(src)
	atom_say("Temporal displacement detected. Criticality status: SUCCESS.")

/obj/machinery/anomaly_refinery/emag_act(mob/user)
	. = ..()
	emagged = TRUE
	atom_say("ERROR: CONTAINMENT STATUS - NONFUNCTIONAL.")
