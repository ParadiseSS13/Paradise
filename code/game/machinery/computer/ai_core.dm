/obj/structure/AIcore
	density = 1
	anchored = 0
	name = "AI core"
	icon = 'icons/mob/AI.dmi'
	icon_state = "0"
	max_integrity = 500
	var/state = 0
	var/datum/ai_laws/laws = null
	var/obj/item/circuitboard/circuit = null
	var/obj/item/mmi/brain = null

/obj/structure/AIcore/Destroy()
	QDEL_NULL(laws)
	QDEL_NULL(circuit)
	QDEL_NULL(brain)
	return ..()

/obj/structure/AIcore/attackby(obj/item/P, mob/user, params)
	switch(state)
		if(EMPTY_CORE)
			if(istype(P, /obj/item/circuitboard/aicore))
				if(!user.drop_item())
					return
				playsound(loc, P.usesound, 50, 1)
				to_chat(user, "<span class='notice'>You place the circuit board inside the frame.</span>")
				update_icon()
				state = CIRCUIT_CORE
				P.forceMove(src)
				circuit = P
				return
		if(SCREWED_CORE)
			if(istype(P, /obj/item/stack/cable_coil))
				var/obj/item/stack/cable_coil/C = P
				if(C.get_amount() >= 5)
					playsound(loc, 'sound/items/deconstruct.ogg', 50, 1)
					to_chat(user, "<span class='notice'>You start to add cables to the frame...</span>")
					if(do_after(user, 20, target = src) && state == SCREWED_CORE && C.use(5))
						to_chat(user, "<span class='notice'>You add cables to the frame.</span>")
						state = CABLED_CORE
						update_icon()
				else
					to_chat(user, "<span class='warning'>You need five lengths of cable to wire the AI core!</span>")
				return
		if(CABLED_CORE)
			if(istype(P, /obj/item/stack/sheet/rglass))
				var/obj/item/stack/sheet/rglass/G = P
				if(G.get_amount() >= 2)
					playsound(loc, 'sound/items/deconstruct.ogg', 50, 1)
					to_chat(user, "<span class='notice'>You start to put in the glass panel...</span>")
					if(do_after(user, 20, target = src) && state == CABLED_CORE && G.use(2))
						to_chat(user, "<span class='notice'>You put in the glass panel.</span>")
						state = GLASS_CORE
						update_icon()
				else
					to_chat(user, "<span class='warning'>You need two sheets of reinforced glass to insert them into the AI core!</span>")
				return

			if(istype(P, /obj/item/aiModule/purge))
				laws.clear_inherent_laws()
				to_chat(usr, "<span class='notice'>Law module applied.</span>")
				return

			if(istype(P, /obj/item/aiModule/freeform))
				var/obj/item/aiModule/freeform/M = P
				laws.add_inherent_law(M.newFreeFormLaw)
				to_chat(usr, "<span class='notice'>Added a freeform law.</span>")
				return

			if(istype(P, /obj/item/aiModule))
				var/obj/item/aiModule/M = P
				if(!M.laws)
					to_chat(usr, "<span class='warning'>This AI module can not be applied directly to AI cores.</span>")
					return
				laws = M.laws

			if(istype(P, /obj/item/mmi) && !brain)
				var/obj/item/mmi/M = P
				if(!M.brainmob)
					to_chat(user, "<span class='warning'>Sticking an empty [P] into the frame would sort of defeat the purpose.</span>")
					return
				if(M.brainmob.stat == DEAD)
					to_chat(user, "<span class='warning'>Sticking a dead [P] into the frame would sort of defeat the purpose.</span>")
					return

				if(!M.brainmob.client)
					to_chat(user, "<span class='warning'>Sticking an inactive [M.name] into the frame would sort of defeat the purpose.</span>")
					return

				if(jobban_isbanned(M.brainmob, "AI") || jobban_isbanned(M.brainmob, "nonhumandept"))
					to_chat(user, "<span class='warning'>This [P] does not seem to fit.</span>")
					return

				if(!M.brainmob.mind)
					to_chat(user, "<span class='warning'>This [M.name] is mindless!</span>")
					return

				if(istype(P, /obj/item/mmi/syndie))
					to_chat(user, "<span class='warning'>This MMI does not seem to fit!</span>")
					return

				if(!user.drop_item())
					return

				M.forceMove(src)
				brain = M
				to_chat(user, "<span class='notice'>You add [M.name] to the frame.</span>")
				update_icon()
				return

		if(AI_READY_CORE)
			if(istype(P, /obj/item/aicard))
				P.transfer_ai("INACTIVE", "AICARD", src, user)
				return
	return ..()

/obj/structure/AIcore/crowbar_act(mob/living/user, obj/item/I)
	if(state !=CIRCUIT_CORE || state != GLASS_CORE || !(state == CABLED_CORE && brain))
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	switch(state)
		if(CIRCUIT_CORE)
			to_chat(user, "<span class='notice'>You remove the circuit board.</span>")
			state = EMPTY_CORE
			circuit.forceMove(loc)
			circuit = null
			return
		if(GLASS_CORE)
			to_chat(user, "<span class='notice'>You remove the glass panel.</span>")
			state = CABLED_CORE
			new /obj/item/stack/sheet/rglass(loc, 2)
			return
		if(CABLED_CORE)
			if(brain)
				to_chat(user, "<span class='notice'>You remove the brain.</span>")
				brain.forceMove(loc)
				brain = null
	update_icon()

/obj/structure/AIcore/screwdriver_act(mob/living/user, obj/item/I)
	if(!(state in list(SCREWED_CORE, CIRCUIT_CORE, GLASS_CORE, AI_READY_CORE)))
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	switch(state)
		if(SCREWED_CORE)
			to_chat(user, "<span class='notice'>You unfasten the circuit board.</span>")
			state = CIRCUIT_CORE
		if(CIRCUIT_CORE)
			to_chat(user, "<span class='notice'>You screw the circuit board into place.</span>")
			state = SCREWED_CORE
		if(GLASS_CORE)
			to_chat(user, "<span class='notice'>You connect the monitor.</span>")
			if(!brain)
				var/open_for_latejoin = alert(user, "Would you like this core to be open for latejoining AIs?", "Latejoin", "Yes", "Yes", "No") == "Yes"
				var/obj/structure/AIcore/deactivated/D = new(loc)
				if(open_for_latejoin)
					empty_playable_ai_cores += D
			else
				if(brain.brainmob.mind)
					SSticker.mode.remove_cultist(brain.brainmob.mind, 1)
					SSticker.mode.remove_revolutionary(brain.brainmob.mind, 1)

				var/mob/living/silicon/ai/A = new /mob/living/silicon/ai(loc, laws, brain)
				if(A) //if there's no brain, the mob is deleted and a structure/AIcore is created
					A.rename_self("AI", 1)
			feedback_inc("cyborg_ais_created",1)
			qdel(src)
		if(AI_READY_CORE)
			to_chat(user, "<span class='notice'>You disconnect the monitor.</span>")
			state = GLASS_CORE
	update_icon()


/obj/structure/AIcore/wirecutter_act(mob/living/user, obj/item/I)
	if(state != CABLED_CORE)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(brain)
		to_chat(user, "<span class='warning'>Get that [brain.name] out of there first!</span>")
	else
		to_chat(user, "<span class='notice'>You remove the cables.</span>")
		state = SCREWED_CORE
		update_icon()
		var/obj/item/stack/cable_coil/A = new /obj/item/stack/cable_coil( loc )
		A.amount = 5

/obj/structure/AIcore/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	default_unfasten_wrench(user, I, 20)

/obj/structure/AIcore/update_icon()
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

/obj/structure/AIcore/deconstruct(disassembled = TRUE)
	if(state == GLASS_CORE)
		new /obj/item/stack/sheet/rglass(loc, 2)
	if(state >= CABLED_CORE)
		new /obj/item/stack/cable_coil(loc, 5)
	if(circuit)
		circuit.forceMove(loc)
		circuit = null
	new /obj/item/stack/sheet/plasteel(loc, 4)
	qdel(src)

/obj/structure/AIcore/welder_act(mob/user, obj/item/I)
	if(!state)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	WELDER_ATTEMPT_WELD_MESSAGE
	if(I.use_tool(src, user, 20, volume = I.tool_volume))
		to_chat(user, "<span class='notice'>You deconstruct the frame.</span>")
		new /obj/item/stack/sheet/plasteel(drop_location(), 4)
		qdel(src)

/obj/structure/AIcore/deactivated
	name = "inactive AI"
	icon_state = "ai-empty"
	anchored = TRUE
	state = AI_READY_CORE

/obj/structure/AIcore/deactivated/New()
	..()
	circuit = new(src)

/obj/structure/AIcore/deactivated/Destroy()
	if(src in empty_playable_ai_cores)
		empty_playable_ai_cores -= src
	return ..()

/client/proc/empty_ai_core_toggle_latejoin()
	set name = "Toggle AI Core Latejoin"
	set category = "Admin"

	var/list/cores = list()
	for(var/obj/structure/AIcore/deactivated/D in world)
		cores["[D] ([D.loc.loc])"] = D

	if(!cores.len)
		to_chat(src, "No deactivated AI cores were found.")

	var/id = input("Which core?", "Toggle AI Core Latejoin", null) as null|anything in cores
	if(!id) return

	var/obj/structure/AIcore/deactivated/D = cores[id]
	if(!D) return

	if(D in empty_playable_ai_cores)
		empty_playable_ai_cores -= D
		to_chat(src, "\The [id] is now <font color=\"#ff0000\">not available</font> for latejoining AIs.")
	else
		empty_playable_ai_cores += D
		to_chat(src, "\The [id] is now <font color=\"#008000\">available</font> for latejoining AIs.")


/*
This is a good place for AI-related object verbs so I'm sticking it here.
If adding stuff to this, don't forget that an AI need to cancel_camera() whenever it physically moves to a different location.
That prevents a few funky behaviors.
*/
//The type of interaction, the player performing the operation, the AI itself, and the card object, if any.


atom/proc/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	if(istype(card))
		if(card.flush)
			to_chat(user, "<span class='boldannounce'>ERROR</span>: AI flush is in progress, cannot execute transfer protocol.")
			return 0
	return 1


/obj/structure/AIcore/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	if(state != AI_READY_CORE || !..())
		return
 //Transferring a carded AI to a core.
	if(interaction == AI_TRANS_FROM_CARD)
		AI.control_disabled = 0
		AI.aiRadio.disabledAi = 0
		AI.forceMove(loc)//To replace the terminal.
		to_chat(AI, "You have been uploaded to a stationary terminal. Remote device connection restored.")
		to_chat(user, "<span class='boldnotice'>Transfer successful</span>: [AI.name] ([rand(1000,9999)].exe) installed and executed successfully. Local copy has been removed.</span>")
		qdel(src)
	else //If for some reason you use an empty card on an empty AI terminal.
		to_chat(user, "There is no AI loaded on this terminal!")