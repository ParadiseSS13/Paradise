/*
 * Cryogenic refrigeration unit. Basically a despawner.
 * Stealing a lot of concepts/code from sleepers due to massive laziness.
 * The despawn tick will only fire if it's been more than time_till_despawned ticks
 * since time_entered, which is world.time when the occupant moves in.
 * ~ Zuhayr
 */

//Used for logging people entering cryosleep and important items they are carrying.
var/global/list/frozen_crew = list()
var/global/list/frozen_items = list()

//Main cryopod console.

/obj/machinery/computer/cryopod
	name = "cryogenic oversight console"
	desc = "An interface between crew and the cryogenic storage oversight systems."
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "cellconsole"
	circuit = "/obj/item/weapon/circuitboard/cryopodcontrol"
	var/mode = null

/obj/machinery/computer/cryopod/attack_paw()
	src.attack_hand()

/obj/machinery/computer/cryopod/attack_ai()
	src.attack_hand()

obj/machinery/computer/cryopod/attack_hand(mob/user = usr)
	if(stat & (NOPOWER|BROKEN))
		return

	user.set_machine(src)
	src.add_fingerprint(usr)

	var/dat

	if (!( ticker ))
		return

	dat += "<hr/><br/><b>Cryogenic Oversight Control</b><br/>"
	dat += "<i>Welcome, [user.real_name].</i><br/><br/><hr/>"
	dat += "<a href='?src=\ref[src];log=1'>View storage log</a>.<br>"
	dat += "<a href='?src=\ref[src];item=1'>Recover object</a>.<br>"
	dat += "<a href='?src=\ref[src];allitems=1'>Recover all objects</a>.<br>"
	dat += "<a href='?src=\ref[src];crew=1'>Revive crew</a>.<br/><hr/>"

	user << browse(dat, "window=cryopod_console")
	onclose(user, "cryopod_console")

obj/machinery/computer/cryopod/Topic(href, href_list)

	if(..())
		return

	var/mob/user = usr

	src.add_fingerprint(user)

	if(href_list["log"])

		var/dat = "<b>Recently stored crewmembers</b><br/><hr/><br/>"
		for(var/person in frozen_crew)
			dat += "[person]<br/>"
		dat += "<hr/>"

		user << browse(dat, "window=cryolog")

	else if(href_list["item"])

		if(frozen_items.len == 0)
			user << "\blue There is nothing to recover from storage."
			return

		var/obj/item/I = input(usr, "Please choose which object to retrieve.","Object recovery",null) as obj in frozen_items

		if(!I || frozen_items.len == 0)
			user << "\blue There is nothing to recover from storage."
			return

		visible_message("\blue The console beeps happily as it disgorges \the [I].", 3)

		I.loc = get_turf(src)
		frozen_items -= I

	else if(href_list["allitems"])

		if(frozen_items.len == 0)
			user << "\blue There is nothing to recover from storage."
			return

		visible_message("\blue The console beeps happily as it disgorges the desired objects.", 3)

		for(var/obj/item/I in frozen_items)
			I.loc = get_turf(src)
			frozen_items -= I

	else if(href_list["crew"])
		user << "\red Functionality unavailable at this time."

	src.updateUsrDialog()
	return

/obj/item/weapon/circuitboard/cryopodcontrol
	name = "Circuit board (Cryogenic Oversight Console)"
	build_path = "/obj/machinery/computer/cryopod"
	origin_tech = "programming=3"

//Decorative structures to go alongside cryopods.
/obj/structure/cryofeed

	name = "\improper cryogenic feed"
	desc = "A bewildering tangle of machinery and pipes."
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "cryo_rear"
	anchored = 1

	var/orient_right = null //Flips the sprite.

/obj/structure/cryofeed/right
	orient_right = 1
	icon_state = "cryo_rear-r"

/obj/structure/cryofeed/New()

	if(orient_right)
		icon_state = "cryo_rear-r"
	else
		icon_state = "cryo_rear"
	..()

//Cryopods themselves.
/obj/machinery/cryopod
	name = "\improper cryogenic freezer"
	desc = "A man-sized pod for entering suspended animation."
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "body_scanner_0"
	density = 1
	anchored = 1

	var/mob/occupant = null      // Person waiting to be despawned.
	var/orient_right = null      // Flips the sprite.
	var/time_till_despawn = 9000 // 15 minutes-ish safe period before being despawned.
	var/time_entered = 0         // Used to keep track of the safe period.
	var/obj/item/device/radio/intercom/announce //

	// These items are preserved when the process() despawn proc occurs.
	var/list/preserve_items = list(
		/obj/item/weapon/hand_tele,
		/obj/item/weapon/card/id/captains_spare,
		/obj/item/device/aicard,
		/obj/item/device/mmi,
		/obj/item/device/paicard,
		/obj/item/weapon/gun,
		/obj/item/weapon/pinpointer,
		/obj/item/clothing/suit,
		/obj/item/clothing/shoes/magboots,
		/obj/item/blueprints,
		/obj/item/clothing/head/helmet/space/
	)

/obj/machinery/cryopod/right
	orient_right = 1
	icon_state = "body_scanner_0-r"

/obj/machinery/cryopod/New()

	announce = new /obj/item/device/radio/intercom(src)

	if(orient_right)
		icon_state = "body_scanner_0-r"
	else
		icon_state = "body_scanner_0"
	..()

//Lifted from Unity stasis.dm and refactored. ~Zuhayr
/obj/machinery/cryopod/process()
	if(occupant)

		//Allow a ten minute gap between entering the pod and actually despawning.
		if(world.time - time_entered < time_till_despawn)
			return

		if(!occupant.client && occupant.stat<2) //Occupant is living and has no client.

			//Drop all items into the pod.
			for(var/obj/item/W in occupant)
				occupant.drop_from_inventory(W)
				W.loc = src

				if(W.contents.len) //Make sure we catch anything not handled by del() on the items.
					for(var/obj/item/O in W.contents)
						O.loc = src

			//Delete all items not on the preservation list.
			var/list/items = src.contents
			items -= occupant // Don't delete the occupant
			items -= announce // or the autosay radio.

			for(var/obj/item/W in items)
				var/preserve = null
				for(var/T in preserve_items)
					if(istype(W,T))
						preserve = 1
						break

				if(!preserve)
					del(W)
				else
					frozen_items += W

			//Update any existing objectives involving this mob.
			for(var/datum/objective/O in all_objectives)
				if(istype(O,/datum/objective/mutiny) && O.target == occupant.mind) //We don't want revs to get objectives that aren't for heads of staff. Letting them win or lose based on cryo is silly so we remove the objective.
					del(O) //TODO: Update rev objectives on login by head (may happen already?) ~ Z
				else if(O.target && istype(O.target,/datum/mind))
					if(O.target == occupant.mind)
						if(O.owner && O.owner.current)
							O.owner.current << "\red You get the feeling your target is no longer within your reach. Time for Plan [pick(list("A","B","C","D","X","Y","Z"))]..."
						O.target = null
						spawn(1) //This should ideally fire after the occupant is deleted.
							if(!O) return
							O.find_target()
							if(!(O.target))
								all_objectives -= O
								O.owner.objectives -= O
								del(O)

			//Handle job slot/tater cleanup.
			var/job = occupant.mind.assigned_role

			job_master.FreeRole(job)

			if(occupant.mind.objectives.len)
				del(occupant.mind.objectives)
				occupant.mind.special_role = null
			else
				if(ticker.mode.name == "AutoTraitor")
					var/datum/game_mode/traitor/autotraitor/current_mode = ticker.mode
					current_mode.possible_traitors.Remove(occupant)

			// Delete them from datacore.
			
			if(PDA_Manifest.len)
				PDA_Manifest.Cut()
			for(var/datum/data/record/R in data_core.medical)
				if ((R.fields["name"] == occupant.real_name))
					del(R)
			for(var/datum/data/record/T in data_core.security)
				if ((T.fields["name"] == occupant.real_name))
					del(T)
			for(var/datum/data/record/G in data_core.general)
				if ((G.fields["name"] == occupant.real_name))
					del(G)

			if(orient_right)
				icon_state = "body_scanner_0-r"
			else
				icon_state = "body_scanner_0"

			//TODO: Check objectives/mode, update new targets if this mob is the target, spawn new antags?

			//This should guarantee that ghosts don't spawn.
			occupant.ckey = null

			//Make an announcement and log the person entering storage.
			frozen_crew += "[occupant.real_name]"

			announce.autosay("[occupant.real_name] has entered long-term storage.", "Cryogenic Oversight")
			visible_message("\blue The crypod hums and hisses as it moves [occupant.real_name] into storage.", 3)

			// Delete the mob.
			del(occupant)
			occupant = null


	return


/obj/machinery/cryopod/attackby(var/obj/item/weapon/G as obj, var/mob/user as mob)

	if(istype(G, /obj/item/weapon/grab))

		if(occupant)
			user << "\blue The cryo pod is in use."
			return

		if(!ismob(G:affecting))
			return

		var/willing = null //We don't want to allow people to be forced into despawning.
		var/mob/M = G:affecting

		if(M.client)
			if(alert(M,"Would you like to enter cryosleep?",,"Yes","No") == "Yes")
				if(!M || !G || !G:affecting) return
				willing = 1
		else
			willing = 1

		if(willing)

			visible_message("[user] starts putting [G:affecting:name] into the cryo pod.", 3)

			if(do_after(user, 20))
				if(!M || !G || !G:affecting) return

				M.loc = src

				if(M.client)
					M.client.perspective = EYE_PERSPECTIVE
					M.client.eye = src

			if(orient_right)
				icon_state = "body_scanner_1-r"
			else
				icon_state = "body_scanner_1"

			M << "\blue You feel cool air surround you. You go numb as your senses turn inward."
			M << "\blue <b>If you ghost, log out or close your client now, your character will shortly be permanently removed from the round.</b>"
			occupant = M
			time_entered = world.time

			// Book keeping!
			log_admin("[key_name_admin(M)] has entered a stasis pod.")
			message_admins("\blue [key_name_admin(M)] has entered a stasis pod.")

			//Despawning occurs when process() is called with an occupant without a client.
			src.add_fingerprint(M)

/obj/machinery/cryopod/verb/eject()
	set name = "Eject Pod"
	set category = "Object"
	set src in oview(1)
	if(usr.stat != 0)
		return

	if(orient_right)
		icon_state = "body_scanner_0-r"
	else
		icon_state = "body_scanner_0"

	src.go_out()
	add_fingerprint(usr)
	return

/obj/machinery/cryopod/verb/move_inside()
	set name = "Enter Pod"
	set category = "Object"
	set src in oview(1)

	if(usr.stat != 0 || !(ishuman(usr) || ismonkey(usr)))
		return

	if(src.occupant)
		usr << "\blue <B>The cryo pod is in use.</B>"
		return

	for(var/mob/living/carbon/slime/M in range(1,usr))
		if(M.Victim == usr)
			usr << "You're too busy getting your life sucked out of you."
			return

	visible_message("[usr] starts climbing into the cryo pod.", 3)

	if(do_after(usr, 20))

		if(!usr || !usr.client)
			return

		if(src.occupant)
			usr << "\blue <B>The cryo pod is in use.</B>"
			return

		usr.stop_pulling()
		usr.client.perspective = EYE_PERSPECTIVE
		usr.client.eye = src
		usr.loc = src
		src.occupant = usr

		if(orient_right)
			icon_state = "body_scanner_1-r"
		else
			icon_state = "body_scanner_1"

		usr << "\blue You feel cool air surround you. You go numb as your senses turn inward."
		usr << "\blue <b>If you ghost, log out or close your client now, your character will shortly be permanently removed from the round.</b>"
		occupant = usr
		time_entered = world.time

		src.add_fingerprint(usr)

	return

/obj/machinery/cryopod/proc/go_out()

	if(!occupant)
		return

	if(occupant.client)
		occupant.client.eye = src.occupant.client.mob
		occupant.client.perspective = MOB_PERSPECTIVE

	occupant.loc = get_turf(src)
	occupant = null

	if(orient_right)
		icon_state = "body_scanner_0-r"
	else
		icon_state = "body_scanner_0"

	return


//Attacks/effects.
/obj/machinery/cryopod/blob_act()
	return //Sorta gamey, but we don't really want these to be destroyed.
