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


/obj/structure/AIcore/attackby(obj/item/P as obj, mob/user as mob, params)
	switch(state)
		if(0)
			if(istype(P, /obj/item/weapon/wrench))
				playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
				if(do_after(user, 20))
					user << "\blue You wrench the frame into place."
					anchored = 1
					state = 1
			if(istype(P, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/WT = P
				if(!WT.isOn())
					user << "The welder must be on for this task."
					return
				playsound(loc, 'sound/items/Welder.ogg', 50, 1)
				if(do_after(user, 20))
					if(!src || !WT.remove_fuel(0, user)) return
					user << "\blue You deconstruct the frame."
					new /obj/item/stack/sheet/plasteel( loc, 4)
					qdel(src)
		if(1)
			if(istype(P, /obj/item/weapon/wrench))
				playsound(loc, 'sound/items/Ratchet.ogg', 50, 1)
				if(do_after(user, 20))
					user << "\blue You unfasten the frame."
					anchored = 0
					state = 0
			if(istype(P, /obj/item/weapon/circuitboard/aicore) && !circuit)
				playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
				user << "\blue You place the circuit board inside the frame."
				icon_state = "1"
				circuit = P
				user.drop_item()
				P.loc = src
			if(istype(P, /obj/item/weapon/screwdriver) && circuit)
				playsound(loc, 'sound/items/Screwdriver.ogg', 50, 1)
				user << "\blue You screw the circuit board into place."
				state = 2
				icon_state = "2"
			if(istype(P, /obj/item/weapon/crowbar) && circuit)
				playsound(loc, 'sound/items/Crowbar.ogg', 50, 1)
				user << "\blue You remove the circuit board."
				state = 1
				icon_state = "0"
				circuit.loc = loc
				circuit = null
		if(2)
			if(istype(P, /obj/item/weapon/screwdriver) && circuit)
				playsound(loc, 'sound/items/Screwdriver.ogg', 50, 1)
				user << "\blue You unfasten the circuit board."
				state = 1
				icon_state = "1"
			if(istype(P, /obj/item/stack/cable_coil))
				if(P:amount >= 5)
					playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
					if(do_after(user, 20))
						P:amount -= 5
						if(!P:amount) qdel(P)
						user << "\blue You add cables to the frame."
						state = 3
						icon_state = "3"
		if(3)
			if(istype(P, /obj/item/weapon/wirecutters))
				if (brain)
					user << "Get that brain out of there first"
				else
					playsound(loc, 'sound/items/Wirecutter.ogg', 50, 1)
					user << "\blue You remove the cables."
					state = 2
					icon_state = "2"
					var/obj/item/stack/cable_coil/A = new /obj/item/stack/cable_coil( loc )
					A.amount = 5

			if(istype(P, /obj/item/stack/sheet/rglass))
				if(P:amount >= 2)
					playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)
					if(do_after(user, 20))
						if (P)
							P:amount -= 2
							if(!P:amount) qdel(P)
							user << "\blue You put in the glass panel."
							state = 4
							icon_state = "4"

			if(istype(P, /obj/item/weapon/aiModule/core/full)) //Allows any full core boards to be applied to AI cores.
				var/obj/item/weapon/aiModule/core/M = P
				laws.clear_inherent_laws()
				for(var/templaw in M.laws)
					laws.add_inherent_law(templaw)
				usr << "<span class='notice'>Law module applied.</span>"

			if(istype(P, /obj/item/weapon/aiModule/reset/purge))
				laws.clear_inherent_laws()
				usr << "Law module applied."

			if(istype(P, /obj/item/weapon/aiModule/supplied/freeform) || istype(P, /obj/item/weapon/aiModule/core/freeformcore))
				var/obj/item/weapon/aiModule/supplied/freeform/M = P
				if(M.laws[1] == "")
					return
				laws.add_inherent_law(M.laws[1])
				usr << "<span class='notice'>Added a freeform law.</span>"

			if(istype(P, /obj/item/device/mmi) || istype(P, /obj/item/device/mmi/posibrain))
				if(!P:brainmob)
					user << "\red Sticking an empty [P] into the frame would sort of defeat the purpose."
					return
				if(P:brainmob.stat == 2)
					user << "\red Sticking a dead [P] into the frame would sort of defeat the purpose."
					return

				if(jobban_isbanned(P:brainmob, "AI") || jobban_isbanned(P:brainmob,"nonhumandept"))
					user << "\red This [P] does not seem to fit."
					return

				if(P:brainmob.mind)
					ticker.mode.remove_cultist(P:brainmob.mind, 1)
					ticker.mode.remove_revolutionary(P:brainmob.mind, 1)

				user.drop_item()
				P.loc = src
				brain = P
				usr << "Added [P]."
				icon_state = "3b"

			if(istype(P, /obj/item/weapon/crowbar) && brain)
				playsound(loc, 'sound/items/Crowbar.ogg', 50, 1)
				user << "\blue You remove the brain."
				brain.loc = loc
				brain = null
				icon_state = "3"

		if(4)
			if(istype(P, /obj/item/weapon/crowbar))
				playsound(loc, 'sound/items/Crowbar.ogg', 50, 1)
				user << "\blue You remove the glass panel."
				state = 3
				if (brain)
					icon_state = "3b"
				else
					icon_state = "3"
				new /obj/item/stack/sheet/rglass( loc, 2 )
				return

			if(istype(P, /obj/item/weapon/screwdriver))
				playsound(loc, 'sound/items/Screwdriver.ogg', 50, 1)
				user << "<span class='notice'>You connect the monitor.</span>"
				if(!brain)
					var/open_for_latejoin = alert(user, "Would you like this core to be open for latejoining AIs?", "Latejoin", "Yes", "Yes", "No") == "Yes"
					var/obj/structure/AIcore/deactivated/D = new(loc)
					if(open_for_latejoin)
						empty_playable_ai_cores += D
				else
					var/mob/living/silicon/ai/A = new /mob/living/silicon/ai ( loc, laws, brain )
					if(A) //if there's no brain, the mob is deleted and a structure/AIcore is created
						A.rename_self("ai", 1)
				feedback_inc("cyborg_ais_created",1)
				qdel(src)

/obj/structure/AIcore/deactivated
	name = "Inactive AI"
	icon = 'icons/mob/AI.dmi'
	icon_state = "ai-empty"
	anchored = 1
	state = 20//So it doesn't interact based on the above. Not really necessary.

/obj/structure/AIcore/deactivated/Destroy()
	empty_playable_ai_cores -= src
	return ..()

/obj/structure/AIcore/deactivated/attackby(var/obj/item/W, var/mob/user, params)
	if(istype(W, /obj/item/device/aicard))//Is it?
		var/obj/item/device/aicard/card = W
		card.transfer_ai("INACTIVE","AICARD",src,user)
	else if(istype(W, /obj/item/weapon/wrench))
		if(anchored)
			user.visible_message("\blue \The [user] starts to unbolt \the [src] from the plating...")
			if(!do_after(user,40))
				user.visible_message("\blue \The [user] decides not to unbolt \the [src].")
				return
			user.visible_message("\blue \The [user] finishes unfastening \the [src]!")
			anchored = 0
			return
		else
			user.visible_message("\blue \The [user] starts to bolt \the [src] to the plating...")
			if(!do_after(user,40))
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
		src << "No deactivated AI cores were found."

	var/id = input("Which core?", "Toggle AI Core Latejoin", null) as null|anything in cores
	if(!id) return

	var/obj/structure/AIcore/deactivated/D = cores[id]
	if(!D) return

	if(D in empty_playable_ai_cores)
		empty_playable_ai_cores -= D
		src << "\The [id] is now <font color=\"#ff0000\">not available</font> for latejoining AIs."
	else
		empty_playable_ai_cores += D
		src << "\The [id] is now <font color=\"#008000\">available</font> for latejoining AIs."


/*
This is a good place for AI-related object verbs so I'm sticking it here.
If adding stuff to this, don't forget that an AI need to cancel_camera() whenever it physically moves to a different location.
That prevents a few funky behaviors.
*/
//What operation to perform based on target, what ineraction to perform based on object used, target itself, user. The object used is src and calls this proc.
/obj/item/proc/transfer_ai(var/choice as text, var/interaction as text, var/target, var/mob/U as mob)
	if(!src:flush)
		switch(choice)
			if("AICORE")//AI mob.
				var/mob/living/silicon/ai/T = target
				switch(interaction)
					if("AICARD")
						var/obj/item/device/aicard/C = src
						if(C.contents.len)//If there is an AI on card.
							U << "\red <b>Transfer failed</b>: \black Existing AI found on this terminal. Remove existing AI to install a new one."
						else
							if (ticker.mode.name == "AI malfunction")
								var/datum/game_mode/malfunction/malf = ticker.mode
								for (var/datum/mind/malfai in malf.malf_ai)
									if (T.mind == malfai)
										U << "\red <b>ERROR</b>: \black Remote transfer interface disabled."//Do ho ho ho~
										return
							new /obj/structure/AIcore/deactivated(T.loc)//Spawns a deactivated terminal at AI location.
							T.aiRestorePowerRoutine = 0//So the AI initially has power.
							T.control_disabled = 1//Can't control things remotely if you're stuck in a card!
							T.loc = C//Throw AI into the card.
							C.name = "inteliCard - [T.name]"
							if (T.stat == 2)
								C.icon_state = "aicard-404"
							else
								C.icon_state = "aicard-full"
							T.cancel_camera()
							T << "You have been downloaded to a mobile storage device. Remote device connection severed."
							U << "\blue <b>Transfer successful</b>: \black [T.name] ([rand(1000,9999)].exe) removed from host terminal and stored within local memory."
					/*if("NINJASUIT")
						var/obj/item/clothing/suit/space/space_ninja/C = src
						if(C.AI)//If there is an AI on card.
							U << "\red <b>Transfer failed</b>: \black Existing AI found on this terminal. Remove existing AI to install a new one."
						else
							if (ticker.mode.name == "AI malfunction")
								var/datum/game_mode/malfunction/malf = ticker.mode
								for (var/datum/mind/malfai in malf.malf_ai)
									if (T.mind == malfai)
										U << "\red <b>ERROR</b>: \black Remote transfer interface disabled."
										return
							if(T.stat)//If the ai is dead/dying.
								U << "\red <b>ERROR</b>: \black [T.name] data core is corrupted. Unable to install."
							else
								new /obj/structure/AIcore/deactivated(T.loc)
								T.aiRestorePowerRoutine = 0
								T.control_disabled = 1
								T.loc = C
								C.AI = T
								T.cancel_camera()
								T << "You have been downloaded to a mobile storage device. Remote device connection severed."
								U << "\blue <b>Transfer successful</b>: \black [T.name] ([rand(1000,9999)].exe) removed from host terminal and stored within local memory."*/

			if("INACTIVE")//Inactive AI object.
				var/obj/structure/AIcore/deactivated/T = target
				switch(interaction)
					if("AICARD")
						var/obj/item/device/aicard/C = src
						var/mob/living/silicon/ai/A = locate() in C//I love locate(). Best proc ever.
						if(A)//If AI exists on the card. Else nothing since both are empty.
							A.control_disabled = 0
							A.loc = T.loc//To replace the terminal.
							C.icon_state = "aicard"
							C.name = "inteliCard"
							C.overlays.Cut()
							A.cancel_camera()
							A << "You have been uploaded to a stationary terminal. Remote device connection restored."
							U << "\blue <b>Transfer successful</b>: \black [A.name] ([rand(1000,9999)].exe) installed and executed succesfully. Local copy has been removed."
							qdel(T)
					/*if("NINJASUIT")
						var/obj/item/clothing/suit/space/space_ninja/C = src
						var/mob/living/silicon/ai/A = C.AI
						if(A)
							A.control_disabled = 0
							C.AI = null
							A.loc = T.loc
							A.cancel_camera()
							A << "You have been uploaded to a stationary terminal. Remote device connection restored."
							U << "\blue <b>Transfer succesful</b>: \black [A.name] ([rand(1000,9999)].exe) installed and executed succesfully. Local copy has been removed."
							del(T)*/
			if("AIFIXER")//AI Fixer terminal.
				var/obj/machinery/computer/aifixer/T = target
				switch(interaction)
					if("AICARD")
						var/obj/item/device/aicard/C = src
						if(!T.contents.len)
							if (!C.contents.len)
								U << "No AI to copy over!"//Well duh
							else for(var/mob/living/silicon/ai/A in C)
								C.icon_state = "aicard"
								C.name = "inteliCard"
								C.overlays.Cut()
								A.loc = T
								T.occupant = A
								A.control_disabled = 1
								if (A.stat == 2)
									T.overlays += image('icons/obj/computer.dmi', "ai-fixer-404")
								else
									T.overlays += image('icons/obj/computer.dmi', "ai-fixer-full")
								T.overlays -= image('icons/obj/computer.dmi', "ai-fixer-empty")
								A.cancel_camera()
								A << "You have been uploaded to a stationary terminal. Sadly, there is no remote access from here."
								U << "\blue <b>Transfer successful</b>: \black [A.name] ([rand(1000,9999)].exe) installed and executed succesfully. Local copy has been removed."
						else
							if(!C.contents.len && T.occupant && !T.active)
								C.name = "inteliCard - [T.occupant.name]"
								T.overlays += image('icons/obj/computer.dmi', "ai-fixer-empty")
								if (T.occupant.stat == 2)
									C.icon_state = "aicard-404"
									T.overlays -= image('icons/obj/computer.dmi', "ai-fixer-404")
								else
									C.icon_state = "aicard-full"
									T.overlays -= image('icons/obj/computer.dmi', "ai-fixer-full")
								T.occupant << "You have been downloaded to a mobile storage device. Still no remote access."
								U << "\blue <b>Transfer succesful</b>: \black [T.occupant.name] ([rand(1000,9999)].exe) removed from host terminal and stored within local memory."
								T.occupant.loc = C
								T.occupant.cancel_camera()
								T.occupant = null
							else if (C.contents.len)
								U << "\red <b>ERROR</b>: \black Artificial intelligence detected on terminal."
							else if (T.active)
								U << "\red <b>ERROR</b>: \black Reconstruction in progress."
							else if (!T.occupant)
								U << "\red <b>ERROR</b>: \black Unable to locate artificial intelligence."
					/*if("NINJASUIT")
						var/obj/item/clothing/suit/space/space_ninja/C = src
						if(!T.contents.len)
							if (!C.AI)
								U << "No AI to copy over!"
							else
								var/mob/living/silicon/ai/A = C.AI
								A.loc = T
								T.occupant = A
								C.AI = null
								A.control_disabled = 1
								T.overlays += image('icons/obj/computer.dmi', "ai-fixer-full")
								T.overlays -= image('icons/obj/computer.dmi', "ai-fixer-empty")
								A.cancel_camera()
								A << "You have been uploaded to a stationary terminal. Sadly, there is no remote access from here."
								U << "\blue <b>Transfer successful</b>: \black [A.name] ([rand(1000,9999)].exe) installed and executed succesfully. Local copy has been removed."
						else
							if(!C.AI && T.occupant && !T.active)
								if (T.occupant.stat)
									U << "\red <b>ERROR</b>: \black [T.occupant.name] data core is corrupted. Unable to install."
								else
									T.overlays += image('icons/obj/computer.dmi', "ai-fixer-empty")
									T.overlays -= image('icons/obj/computer.dmi', "ai-fixer-full")
									T.occupant << "You have been downloaded to a mobile storage device. Still no remote access."
									U << "\blue <b>Transfer successful</b>: \black [T.occupant.name] ([rand(1000,9999)].exe) removed from host terminal and stored within local memory."
									T.occupant.loc = C
									T.occupant.cancel_camera()
									T.occupant = null
							else if (C.AI)
								U << "\red <b>ERROR</b>: \black Artificial intelligence detected on terminal."
							else if (T.active)
								U << "\red <b>ERROR</b>: \black Reconstruction in progress."
							else if (!T.occupant)
								U << "\red <b>ERROR</b>: \black Unable to locate artificial intelligence."*/
			/*if("NINJASUIT")//Ninjasuit
				var/obj/item/clothing/suit/space/space_ninja/T = target
				switch(interaction)
					if("AICARD")
						var/obj/item/device/aicard/C = src
						if(T.s_initialized&&U==T.affecting)//If the suit is initialized and the actor is the user.

							var/mob/living/silicon/ai/A_T = locate() in C//Determine if there is an AI on target card. Saves time when checking later.
							var/mob/living/silicon/ai/A = T.AI//Deterine if there is an AI in suit.

							if(A)//If the host AI card is not empty.
								if(A_T)//If there is an AI on the target card.
									U << "\red <b>ERROR</b>: \black [A_T.name] already installed. Remove [A_T.name] to install a new one."
								else
									A.loc = C//Throw them into the target card. Since they are already on a card, transfer is easy.
									C.name = "inteliCard - [A.name]"
									C.icon_state = "aicard-full"
									T.AI = null
									A.cancel_camera()
									A << "You have been uploaded to a mobile storage device."
									U << "\blue <b>SUCCESS</b>: \black [A.name] ([rand(1000,9999)].exe) removed from host and stored within local memory."
							else//If host AI is empty.
								if(C.flush)//If the other card is flushing.
									U << "\red <b>ERROR</b>: \black AI flush is in progress, cannot execute transfer protocol."
								else
									if(A_T&&!A_T.stat)//If there is an AI on the target card and it's not inactive.
										A_T.loc = T//Throw them into suit.
										C.icon_state = "aicard"
										C.name = "inteliCard"
										C.overlays.Cut()
										T.AI = A_T
										A_T.cancel_camera()
										A_T << "You have been uploaded to a mobile storage device."
										U << "\blue <b>SUCCESS</b>: \black [A_T.name] ([rand(1000,9999)].exe) removed from local memory and installed to host."
									else if(A_T)//If the target AI is dead. Else just go to return since nothing would happen if both are empty.
										U << "\red <b>ERROR</b>: \black [A_T.name] data core is corrupted. Unable to install."*/

	else
		U << "\red <b>ERROR</b>: \black AI flush is in progress, cannot execute transfer protocol."
	return