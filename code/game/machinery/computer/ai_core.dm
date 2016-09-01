/obj/structure/AIcore
	density = 1
	anchored = 0
	name = "AI core"
	icon = 'icons/mob/AI.dmi'
	icon_state = "0"
	var/state = 0
	var/datum/ai_laws/laws = null
	var/obj/item/weapon/circuitboard/circuit = null
	var/obj/item/device/mmi/brain = null

/obj/structure/AIcore/Destroy()
	qdel(laws)
	qdel(circuit)
	qdel(brain)
	laws = null
	circuit = null
	brain = null
	return ..()

/obj/structure/AIcore/attackby(obj/item/P as obj, mob/user as mob, params)
	switch(state)
		if(0)
			if(istype(P, /obj/item/weapon/wrench))
				playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
				if(do_after(user, 20, target = src))
					to_chat(user, "\blue You wrench the frame into place.")
					anchored = 1
					state = 1
			if(istype(P, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/WT = P
				if(!WT.isOn())
					to_chat(user, "The welder must be on for this task.")
					return
				playsound(loc, 'sound/items/Welder.ogg', 50, 1)
				if(do_after(user, 20, target = src))
					if(!src || !WT.remove_fuel(0, user)) return
					to_chat(user, "\blue You deconstruct the frame.")
					new /obj/item/stack/sheet/plasteel(loc, 4)
					qdel(src)
		if(1)
			if(istype(P, /obj/item/weapon/wrench))
				playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
				if(do_after(user, 20, target = src))
					to_chat(user, "\blue You unfasten the frame.")
					anchored = 0
					state = 0
			if(istype(P, /obj/item/weapon/circuitboard/aicore) && !circuit)
				playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
				to_chat(user, "\blue You place the circuit board inside the frame.")
				icon_state = "1"
				circuit = P
				user.drop_item()
				P.loc = src
			if(istype(P, /obj/item/weapon/screwdriver) && circuit)
				playsound(loc, 'sound/items/Screwdriver.ogg', 50, 1)
				to_chat(user, "\blue You screw the circuit board into place.")
				state = 2
				icon_state = "2"
			if(istype(P, /obj/item/weapon/crowbar) && circuit)
				playsound(loc, 'sound/items/Crowbar.ogg', 50, 1)
				to_chat(user, "\blue You remove the circuit board.")
				state = 1
				icon_state = "0"
				circuit.loc = loc
				circuit = null
		if(2)
			if(istype(P, /obj/item/weapon/screwdriver) && circuit)
				playsound(loc, 'sound/items/Screwdriver.ogg', 50, 1)
				to_chat(user, "\blue You unfasten the circuit board.")
				state = 1
				icon_state = "1"
			if(istype(P, /obj/item/stack/cable_coil))
				if(P:amount >= 5)
					playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
					if(do_after(user, 20, target = src))
						P:amount -= 5
						if(!P:amount) qdel(P)
						to_chat(user, "\blue You add cables to the frame.")
						state = 3
						icon_state = "3"
		if(3)
			if(istype(P, /obj/item/weapon/wirecutters))
				if(brain)
					to_chat(user, "Get that brain out of there first")
				else
					playsound(loc, 'sound/items/Wirecutter.ogg', 50, 1)
					to_chat(user, "\blue You remove the cables.")
					state = 2
					icon_state = "2"
					var/obj/item/stack/cable_coil/A = new /obj/item/stack/cable_coil( loc )
					A.amount = 5

			if(istype(P, /obj/item/stack/sheet/rglass))
				if(P:amount >= 2)
					playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
					if(do_after(user, 20, target = src))
						if(P)
							P:amount -= 2
							if(!P:amount) qdel(P)
							to_chat(user, "\blue You put in the glass panel.")
							state = 4
							icon_state = "4"

			if(istype(P, /obj/item/weapon/aiModule/purge))
				laws.clear_inherent_laws()
				to_chat(usr, "<span class='notice'>Law module applied.</span>")
				return

			if(istype(P, /obj/item/weapon/aiModule/freeform))
				var/obj/item/weapon/aiModule/freeform/M = P
				laws.add_inherent_law(M.newFreeFormLaw)
				to_chat(usr, "<span class='notice'>Added a freeform law.</span>")
				return

			if(istype(P, /obj/item/weapon/aiModule))
				var/obj/item/weapon/aiModule/M = P
				if(!M.laws)
					to_chat(usr, "<span class='warning'>This AI module can not be applied directly to AI cores.</span>")
					return
				laws = M.laws

			if(istype(P, /obj/item/device/mmi) || istype(P, /obj/item/device/mmi/posibrain))
				if(!P:brainmob)
					to_chat(user, "\red Sticking an empty [P] into the frame would sort of defeat the purpose.")
					return
				if(P:brainmob.stat == 2)
					to_chat(user, "\red Sticking a dead [P] into the frame would sort of defeat the purpose.")
					return

				if(jobban_isbanned(P:brainmob, "AI") || jobban_isbanned(P:brainmob,"nonhumandept"))
					to_chat(user, "\red This [P] does not seem to fit.")
					return

				if(istype(P, /obj/item/device/mmi/syndie))
					to_chat(user, "<span class='warning'>This MMI does not seem to fit!</span>")
					return

				if(P:brainmob.mind)
					ticker.mode.remove_cultist(P:brainmob.mind, 1)
					ticker.mode.remove_revolutionary(P:brainmob.mind, 1)

				user.drop_item()
				P.loc = src
				brain = P
				to_chat(usr, "Added [P].")
				icon_state = "3b"

			if(istype(P, /obj/item/weapon/crowbar) && brain)
				playsound(loc, 'sound/items/Crowbar.ogg', 50, 1)
				to_chat(user, "\blue You remove the brain.")
				brain.loc = loc
				brain = null
				icon_state = "3"

		if(4)
			if(istype(P, /obj/item/weapon/crowbar))
				playsound(loc, 'sound/items/Crowbar.ogg', 50, 1)
				to_chat(user, "\blue You remove the glass panel.")
				state = 3
				if(brain)
					icon_state = "3b"
				else
					icon_state = "3"
				new /obj/item/stack/sheet/rglass( loc, 2 )
				return

			if(istype(P, /obj/item/weapon/screwdriver))
				playsound(loc, 'sound/items/Screwdriver.ogg', 50, 1)
				to_chat(user, "<span class='notice'>You connect the monitor.</span>")
				if(!brain)
					var/open_for_latejoin = alert(user, "Would you like this core to be open for latejoining AIs?", "Latejoin", "Yes", "Yes", "No") == "Yes"
					var/obj/structure/AIcore/deactivated/D = new(loc)
					if(open_for_latejoin)
						empty_playable_ai_cores += D
				else
					var/mob/living/silicon/ai/A = new /mob/living/silicon/ai ( loc, laws, brain )
					if(A) //if there's no brain, the mob is deleted and a structure/AIcore is created
						A.rename_self("AI", 1)
				feedback_inc("cyborg_ais_created",1)
				qdel(src)

/obj/structure/AIcore/deactivated
	name = "Inactive AI"
	icon = 'icons/mob/AI.dmi'
	icon_state = "ai-empty"
	anchored = 1
	state = 20//So it doesn't interact based on the above. Not really necessary.

/obj/structure/AIcore/deactivated/Destroy()
	if(src in empty_playable_ai_cores)
		empty_playable_ai_cores -= src
	return ..()

/obj/structure/AIcore/deactivated/attackby(var/obj/item/W, var/mob/user, params)
	if(istype(W, /obj/item/device/aicard))//Is it?
		var/obj/item/device/aicard/card = W
		card.transfer_ai("INACTIVE","AICARD",src,user)
	else if(istype(W, /obj/item/weapon/wrench))
		if(anchored)
			user.visible_message("\blue \The [user] starts to unbolt \the [src] from the plating...")
			if(!do_after(user,40, target = src))
				user.visible_message("\blue \The [user] decides not to unbolt \the [src].")
				return
			user.visible_message("\blue \The [user] finishes unfastening \the [src]!")
			anchored = 0
			return
		else
			user.visible_message("\blue \The [user] starts to bolt \the [src] to the plating...")
			if(!do_after(user,40, target = src))
				user.visible_message("\blue \The [user] decides not to bolt \the [src].")
				return
			user.visible_message("\blue \The [user] finishes fastening down \the [src]!")
			anchored = 1
			return
	else
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


atom/proc/transfer_ai(var/interaction, var/mob/user, var/mob/living/silicon/ai/AI, var/obj/item/device/aicard/card)
	if(istype(card))
		if(card.flush)
			to_chat(user, "<span class='boldannounce'>ERROR</span>: AI flush is in progress, cannot execute transfer protocol.")
			return 0
	return 1


/obj/structure/AIcore/deactivated/transfer_ai(var/interaction, var/mob/user, var/mob/living/silicon/ai/AI, var/obj/item/device/aicard/card)
	if(!..())
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
