/obj/structure/ai_core
	density = TRUE
	name = "AI core"
	icon = 'icons/mob/AI.dmi'
	icon_state = "0"
	max_integrity = 500
	var/state = 0
	var/datum/ai_laws/laws = new /datum/ai_laws/crewsimov()
	var/obj/item/circuitboard/aicore/circuit = null
	var/obj/item/mmi/brain = null

/obj/structure/ai_core/Destroy()
	QDEL_NULL(laws)
	QDEL_NULL(circuit)
	QDEL_NULL(brain)
	return ..()

/obj/structure/ai_core/item_interaction(mob/living/user, obj/item/P, list/modifiers)
	switch(state)
		if(EMPTY_CORE)
			if(istype(P, /obj/item/circuitboard/aicore))
				if(!user.drop_item())
					return ITEM_INTERACT_COMPLETE
				playsound(loc, P.usesound, 50, 1)
				to_chat(user, SPAN_NOTICE("You place the circuit board inside the frame."))
				update_icon(UPDATE_ICON_STATE)
				state = CIRCUIT_CORE
				P.forceMove(src)
				circuit = P
				update_icon(UPDATE_ICON_STATE)
				return ITEM_INTERACT_COMPLETE
		if(SCREWED_CORE)
			if(istype(P, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C = P
				if(C.get_amount() >= 5)
					playsound(loc, 'sound/items/deconstruct.ogg', 50, 1)
					to_chat(user, SPAN_NOTICE("You start to add cables to the frame..."))
					if(do_after(user, 20, target = src) && state == SCREWED_CORE && C.use(5))
						to_chat(user, SPAN_NOTICE("You add cables to the frame."))
						state = CABLED_CORE
						update_icon(UPDATE_ICON_STATE)
				else
					to_chat(user, SPAN_WARNING("You need five lengths of cable to wire the AI core!"))
				return ITEM_INTERACT_COMPLETE
		if(CABLED_CORE)
			if(istype(P, /obj/item/stack/sheet/rglass))
				var/obj/item/stack/sheet/rglass/G = P
				if(G.get_amount() >= 2)
					playsound(loc, 'sound/items/deconstruct.ogg', 50, 1)
					to_chat(user, SPAN_NOTICE("You start to put in the glass panel..."))
					if(do_after(user, 20, target = src) && state == CABLED_CORE && G.use(2))
						to_chat(user, SPAN_NOTICE("You put in the glass panel."))
						state = GLASS_CORE
						update_icon(UPDATE_ICON_STATE)
				else
					to_chat(user, SPAN_WARNING("You need two sheets of reinforced glass to insert them into the AI core!"))
				return ITEM_INTERACT_COMPLETE

			if(istype(P, /obj/item/ai_module/purge))
				laws.clear_inherent_laws()
				to_chat(usr, SPAN_NOTICE("Law module applied."))
				return ITEM_INTERACT_COMPLETE

			if(istype(P, /obj/item/ai_module/freeform))
				var/obj/item/ai_module/freeform/M = P
				if(!M.newFreeFormLaw)
					to_chat(usr, "No law detected on module, please create one.")
					return ITEM_INTERACT_COMPLETE
				laws.add_supplied_law(M.lawpos, M.newFreeFormLaw)
				to_chat(usr, SPAN_NOTICE("Added a freeform law."))
				return ITEM_INTERACT_COMPLETE

			if(istype(P, /obj/item/ai_module/syndicate))
				var/obj/item/ai_module/syndicate/M = P
				if(!M.newFreeFormLaw)
					to_chat(usr, "No law detected on module, please create one.")
					return ITEM_INTERACT_COMPLETE
				laws.add_ion_law(M.newFreeFormLaw)
				to_chat(usr, SPAN_NOTICE("Added a hacked law."))
				return ITEM_INTERACT_COMPLETE

			if(istype(P, /obj/item/ai_module))
				var/obj/item/ai_module/M = P
				if(!M.laws)
					to_chat(usr, SPAN_WARNING("This AI module can not be applied directly to AI cores."))
					return ITEM_INTERACT_COMPLETE
				laws = M.laws
				to_chat(usr, SPAN_NOTICE("Added [M.laws.name] laws."))
				return ITEM_INTERACT_COMPLETE

			if(istype(P, /obj/item/mmi) && !brain)
				var/obj/item/mmi/M = P
				if(!M.brainmob)
					to_chat(user, SPAN_WARNING("Sticking an empty [P] into the frame would sort of defeat the purpose."))
					return ITEM_INTERACT_COMPLETE
				if(M.brainmob.stat == DEAD)
					to_chat(user, SPAN_WARNING("Sticking a dead [P] into the frame would sort of defeat the purpose."))
					return ITEM_INTERACT_COMPLETE

				if(!M.brainmob.client)
					to_chat(user, SPAN_WARNING("Sticking an inactive [M.name] into the frame would sort of defeat the purpose."))
					return ITEM_INTERACT_COMPLETE

				if(jobban_isbanned(M.brainmob, "AI") || jobban_isbanned(M.brainmob, "nonhumandept"))
					to_chat(user, SPAN_WARNING("This [P] does not seem to fit."))
					return ITEM_INTERACT_COMPLETE

				if(!M.brainmob.mind)
					to_chat(user, SPAN_WARNING("This [M.name] is mindless!"))
					return ITEM_INTERACT_COMPLETE

				if(istype(P, /obj/item/mmi/syndie))
					to_chat(user, SPAN_WARNING("This MMI does not seem to fit!"))
					return ITEM_INTERACT_COMPLETE

				if(!user.drop_item())
					return ITEM_INTERACT_COMPLETE

				M.forceMove(src)
				brain = M
				to_chat(user, SPAN_NOTICE("You add [M.name] to the frame."))
				update_icon(UPDATE_ICON_STATE)
				return ITEM_INTERACT_COMPLETE

	return ..()

/obj/structure/ai_core/crowbar_act(mob/living/user, obj/item/I)
	if(state !=CIRCUIT_CORE && state != GLASS_CORE && !(state == CABLED_CORE && brain))
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	switch(state)
		if(CIRCUIT_CORE)
			to_chat(user, SPAN_NOTICE("You remove the circuit board."))
			state = EMPTY_CORE
			circuit.forceMove(loc)
			circuit = null
			update_icon(UPDATE_ICON_STATE)
			return
		if(GLASS_CORE)
			to_chat(user, SPAN_NOTICE("You remove the glass panel."))
			state = CABLED_CORE
			new /obj/item/stack/sheet/rglass(loc, 2)
			update_icon(UPDATE_ICON_STATE)
			return
		if(CABLED_CORE)
			if(brain)
				to_chat(user, SPAN_NOTICE("You remove the brain."))
				brain.forceMove(loc)
				brain = null
	update_icon(UPDATE_ICON_STATE)

/obj/structure/ai_core/screwdriver_act(mob/living/user, obj/item/I)
	if(!(state in list(SCREWED_CORE, CIRCUIT_CORE, GLASS_CORE, AI_READY_CORE)))
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	switch(state)
		if(SCREWED_CORE)
			to_chat(user, SPAN_NOTICE("You unfasten the circuit board."))
			state = CIRCUIT_CORE
		if(CIRCUIT_CORE)
			to_chat(user, SPAN_NOTICE("You screw the circuit board into place."))
			state = SCREWED_CORE
		if(GLASS_CORE)
			var/area/R = get_area(src)
			message_admins("[key_name_admin(usr)] has completed an AI core in [R]: [ADMIN_COORDJMP(loc)].")
			log_game("[key_name(usr)] has completed an AI core in [R]: [COORD(loc)].")
			to_chat(user, SPAN_NOTICE("You connect the monitor."))
			if(!brain)
				var/open_for_latejoin = tgui_alert(user, "Would you like this core to be open for latejoining AIs?", "Latejoin", list("Yes", "No")) == "Yes"
				var/obj/structure/ai_core/deactivated/D = new(loc)
				if(open_for_latejoin)
					GLOB.empty_playable_ai_cores += D
			else
				if(brain.brainmob.mind)
					brain.brainmob.mind.remove_antag_datum(/datum/antagonist/cultist)
					SSticker.mode.remove_revolutionary(brain.brainmob.mind, 1)

				var/mob/living/silicon/ai/A = new /mob/living/silicon/ai(loc, laws, brain)
				// Stop holding onto the laws so we don't qdel them and make the AI randomly lose its laws when GC gives up and hard deletes them.
				laws = null
				if(A) //if there's no brain, the mob is deleted and a structure/AIcore is created
					A.rename_self("AI", 1)
			SSblackbox.record_feedback("amount", "ais_created", 1)
			qdel(src)
		if(AI_READY_CORE)
			to_chat(user, SPAN_NOTICE("You disconnect the monitor."))
			state = GLASS_CORE
	update_icon(UPDATE_ICON_STATE)


/obj/structure/ai_core/wirecutter_act(mob/living/user, obj/item/I)
	if(state != CABLED_CORE)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(brain)
		to_chat(user, SPAN_WARNING("Get that [brain.name] out of there first!"))
	else
		to_chat(user, SPAN_NOTICE("You remove the cables."))
		state = SCREWED_CORE
		update_icon(UPDATE_ICON_STATE)
		var/obj/item/stack/cable_coil/A = new /obj/item/stack/cable_coil( loc )
		A.amount = 5

/obj/structure/ai_core/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I, 20)

/obj/structure/ai_core/update_icon_state()
	switch(state)
		if(EMPTY_CORE)
			icon_state = "0"
		if(CIRCUIT_CORE)
			icon_state = "1"
		if(SCREWED_CORE)
			icon_state = "2"
		if(CABLED_CORE)
			if(brain)
				icon_state = "3b"
			else
				icon_state = "3"
		if(GLASS_CORE)
			icon_state = "4"
		if(AI_READY_CORE)
			icon_state = "ai-empty"

/obj/structure/ai_core/deconstruct(disassembled = TRUE)
	if(state == GLASS_CORE)
		new /obj/item/stack/sheet/rglass(loc, 2)
	if(state >= CABLED_CORE)
		new /obj/item/stack/cable_coil(loc, 5)
	if(circuit)
		circuit.forceMove(loc)
		circuit = null
	new /obj/item/stack/sheet/plasteel(loc, 4)
	qdel(src)

/obj/structure/ai_core/welder_act(mob/user, obj/item/I)
	if(state)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	WELDER_ATTEMPT_WELD_MESSAGE
	if(I.use_tool(src, user, 20, volume = I.tool_volume))
		to_chat(user, SPAN_NOTICE("You deconstruct the frame."))
		new /obj/item/stack/sheet/plasteel(drop_location(), 4)
		qdel(src)

/obj/structure/ai_core/deactivated
	name = "inactive AI"
	icon_state = "ai-empty"
	anchored = TRUE
	state = AI_READY_CORE

/obj/structure/ai_core/deactivated/Initialize(mapload)
	. = ..()
	circuit = new(src)

/obj/structure/ai_core/deactivated/Destroy()
	if(src in GLOB.empty_playable_ai_cores)
		GLOB.empty_playable_ai_cores -= src
	return ..()

USER_VERB(empty_ai_core_toggle_latejoin, R_ADMIN, "Toggle AI Core Latejoin", "Toggle AI Core Latejoin", VERB_CATEGORY_ADMIN)
	var/list/cores = list()
	for(var/obj/structure/ai_core/deactivated/D in world)
		cores["[D] ([D.loc.loc])"] = D

	if(!length(cores))
		to_chat(client, "No deactivated AI cores were found.")

	var/id = input(client, "Which core?", "Toggle AI Core Latejoin", null) as null|anything in cores
	if(!id) return

	var/obj/structure/ai_core/deactivated/D = cores[id]
	if(!D) return

	if(D in GLOB.empty_playable_ai_cores)
		GLOB.empty_playable_ai_cores -= D
		to_chat(client, "\The [id] is now <font color=\"#ff0000\">not available</font> for latejoining AIs.")
	else
		GLOB.empty_playable_ai_cores += D
		to_chat(client, "\The [id] is now <font color=\"#008000\">available</font> for latejoining AIs.")

/*
This is a good place for AI-related object verbs so I'm sticking it here.
If adding stuff to this, don't forget that an AI need to cancel_camera() whenever it physically moves to a different location.
That prevents a few funky behaviors.
*/
//The type of interaction, the player performing the operation, the AI itself, and the card object, if any.


/atom/proc/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	if(istype(card))
		if(card.flush)
			to_chat(user, "[SPAN_BOLDANNOUNCEIC("ERROR")]: AI flush is in progress, cannot execute transfer protocol.")
			return 0
	return 1


/obj/structure/ai_core/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	if(state != AI_READY_CORE || !..())
		return
 //Transferring a carded AI to a core.
	if(interaction == AI_TRANS_FROM_CARD)
		AI.control_disabled = FALSE
		AI.aiRadio.disabledAi = FALSE
		AI.forceMove(loc)//To replace the terminal.
		to_chat(AI, "You have been uploaded to a stationary terminal. Remote device connection restored.")
		to_chat(user, SPAN_BOLDNOTICE("Transfer successful</span>: [AI.name] ([rand(1000,9999)].exe) installed and executed successfully. Local copy has been removed."))
		if(!AI.builtInCamera && GetComponent(/datum/component/ducttape))
			AI.builtInCamera = new /obj/machinery/camera/portable(AI)
			AI.builtInCamera.c_tag = AI.name
			AI.builtInCamera.network = list("SS13")
		qdel(src)
	else //If for some reason you use an empty card on an empty AI terminal.
		to_chat(user, "There is no AI loaded on this terminal!")

