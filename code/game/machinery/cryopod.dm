#define CRYO_DESTROY 0
#define CRYO_PRESERVE 1
#define CRYO_OBJECTIVE 2

/*
 * Cryogenic refrigeration unit. Basically a despawner.
 * Stealing a lot of concepts/code from sleepers due to massive laziness.
 * The despawn tick will only fire if it's been more than time_till_despawned ticks
 * since time_entered, which is world.time when the occupant moves in.
 * ~ Zuhayr
 */


//Main cryopod console.

/obj/machinery/computer/cryopod
	name = "cryogenic oversight console"
	desc = "An interface between crew and the cryogenic storage oversight systems."
	icon = 'icons/obj/machines/cryogenic2.dmi'
	icon_state = "cellconsole"
	circuit = /obj/item/circuitboard/cryopodcontrol
	density = 0
	interact_offline = 1
	req_access = list(ACCESS_HEADS, ACCESS_ARMORY) //Heads of staff or the warden can go here to claim recover items from their department that people went were cryodormed with.
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	flags = NODECONSTRUCT
	var/mode = null

	//Used for logging people entering cryosleep and important items they are carrying.
	var/list/frozen_crew = list()
	var/list/frozen_items = list()

	// Used for containing rare items traitors need to steal, so it's not
	// game-over if they get iced
	var/list/objective_items = list()
	// A cache of theft datums so you don't have to re-create them for
	// each item check
	var/list/theft_cache = list()

	var/storage_type = "crewmembers"
	var/storage_name = "Cryogenic Oversight Control"
	var/allow_items = 1

/obj/machinery/computer/cryopod/New()
	..()
	for(var/T in GLOB.potential_theft_objectives + GLOB.potential_theft_objectives_hard + GLOB.potential_theft_objectives_medium /*+ GLOB.potential_theft_objectives_collect*/)
		theft_cache += new T

/obj/machinery/computer/cryopod/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/computer/cryopod/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/computer/cryopod/attack_hand(mob/user)
	if(..())
		return TRUE
	add_fingerprint(user)
	ui_interact(user)

	user.set_machine(src)
	add_fingerprint(usr)

/obj/machinery/computer/cryopod/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "CryopodConsole", name, 450, 530)
		ui.open()

/obj/machinery/computer/cryopod/ui_data(mob/user)
	var/list/data = list()
	data["allow_items"] = allow_items
	data["frozen_crew"] = frozen_crew
	data["frozen_items"] = list()

	if(allow_items)
		data["frozen_items"] = frozen_items

	if(!ishuman(user))
		return data

	var/obj/item/card/id/id_card
	var/mob/living/carbon/human/person = user

	id_card = person.get_id_card()
	if(id_card?.registered_name)
		data["account_name"] = id_card.registered_name

	return data

/obj/machinery/computer/cryopod/ui_act(action, params, datum/tgui/ui)
	if(..())
		return

	if(stat & (NOPOWER|BROKEN))
		return

	var/mob/user = ui.user

	add_fingerprint(user)

	if(!allowed(user))
		to_chat(user, span_warning("Access Denied."))
		return

	if(!allow_items)
		return

	switch(action)
		if("one_item")
			if(!params["item"])
				return

			var/obj/item/item = locateUID(params["item"])
			if(!item|| item.loc != src)
				to_chat(user, span_notice("[item] is no longer in storage."))
				return

			visible_message(span_notice("[src] beeps happily as it dispenses [item]."))
			dispense_item(item)

		if("all_items")
			visible_message(span_notice("[src] beeps happily as it dispenses the desired objects."))

			for(var/list/frozen_item in frozen_items)
				var/obj/item/item = locateUID(frozen_item["uid"])
				dispense_item(item)

	return TRUE

/obj/machinery/computer/cryopod/proc/freeze_item(obj/item/I, preserve_status)
	var/list/item = list()
	item["uid"] = I.UID()
	item["name"] = I.name

	frozen_items += list(item)
	if(preserve_status == CRYO_OBJECTIVE)
		objective_items += I
	I.forceMove(src)
	RegisterSignal(I, COMSIG_MOVABLE_MOVED, PROC_REF(item_got_removed))

/obj/machinery/computer/cryopod/proc/item_got_removed(obj/item/I)
	objective_items -= I
	for(var/list/sublist in frozen_items)
		if(sublist["uid"] != I.UID())
			continue
		frozen_items -= list(sublist)
	UnregisterSignal(I, COMSIG_MOVABLE_MOVED)

/obj/machinery/computer/cryopod/proc/dispense_item(obj/item/I)
	I.forceMove(get_turf(src)) // Will call item_got_removed due to the signal being registered to COMSIG_MOVABLE_MOVED

/obj/machinery/computer/cryopod/emag_act(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	if(!objective_items.len)
		visible_message(span_warning("The console buzzes in an annoyed manner."))
		playsound(src, 'sound/machines/buzz-sigh.ogg', 30, 1)
		return
	visible_message(span_warning("The console sparks, and some items fall out!"))
	do_sparks(5, 1, src)
	for(var/obj/item/I in objective_items)
		dispense_item(I)

/obj/item/circuitboard/cryopodcontrol
	name = "Circuit board (Cryogenic Oversight Console)"
	build_path = "/obj/machinery/computer/cryopod"
	origin_tech = "programming=1"

/obj/item/circuitboard/robotstoragecontrol
	name = "Circuit board (Robotic Storage Console)"
	build_path = "/obj/machinery/computer/cryopod/robot"
	origin_tech = "programming=1"

//Decorative structures to go alongside cryopods.
/obj/structure/cryofeed
	name = "cryogenic feed"
	desc = "A bewildering tangle of machinery and pipes."
	icon = 'icons/obj/machines/cryogenic2.dmi'
	icon_state = "cryo_rear"
	anchored = 1

	var/orient_right = null //Flips the sprite.

/obj/structure/cryofeed/right
	orient_right = 1
	icon_state = "cryo_rear-r"

/obj/structure/cryofeed/Initialize(mapload)
	. = ..()
	if(orient_right)
		icon_state = "cryo_rear-r"
	else
		icon_state = "cryo_rear"

//Cryopods themselves.
/obj/machinery/cryopod
	name = "cryogenic freezer"
	desc = "A man-sized pod for entering suspended animation."
	icon = 'icons/obj/machines/cryogenic2.dmi'
	icon_state = "bodyscanner-open"
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	flags = NODECONSTRUCT
	var/base_icon_state = "bodyscanner-open"
	var/occupied_icon_state = "bodyscanner"
	var/on_store_message = "помещен в криохранилище."
	var/on_store_name = "Cryogenic Oversight"
	var/on_enter_occupant_message = "You feel cool air surround you. You go numb as your senses turn inward."
	var/allow_occupant_types = list(/mob/living/carbon/human)
	var/disallow_occupant_types = list()
	var/syndicate = FALSE

	var/mob/living/occupant = null       // Person waiting to be despawned.
	var/orient_right = null       // Flips the sprite.
	// 15 minutes-ish safe period before being despawned.
	var/time_till_despawn = 9000 // This is reduced by 90% if a player manually enters cryo
	var/willing_time_divisor = 10
	var/time_entered = 0          // Used to keep track of the safe period.
	var/obj/item/radio/intercom/announce

	var/obj/machinery/computer/cryopod/control_computer
	var/last_no_computer_message = 0

	// These items are preserved when the process() despawn proc occurs.
	var/list/preserve_items = list(
		/obj/item/hand_tele,
		/obj/item/card/id/captains_spare,
		/obj/item/aicard,
		/obj/item/mmi,
		/obj/item/paicard,
		/obj/item/gun,
		/obj/item/pinpointer,
		/obj/item/clothing/shoes/magboots,
		/obj/item/areaeditor/blueprints,
		/obj/item/clothing/head/helmet/space,
		/obj/item/clothing/suit/space,
		/obj/item/clothing/suit/armor,
		/obj/item/defibrillator/compact,
		/obj/item/defibrillator/compact/advanced,
		/obj/item/reagent_containers/hypospray/CMO,
		/obj/item/clothing/accessory/medal/gold/captain,
		/obj/item/clothing/gloves/color/black/krav_maga/sec,
		/obj/item/clothing/gloves/color/black/forensics,
		/obj/item/spacepod_equipment/key,
		/obj/item/nullrod,
		/obj/item/key,
		/obj/item/door_remote,
		/obj/item/stamp,
		/obj/item/sensor_device/advanced
	)
	// These items will NOT be preserved
	var/list/do_not_preserve_items = list (
		/obj/item/mmi/robotic_brain
	)

//////
//Syndie cryopod.

/obj/machinery/cryopod/syndie
	icon_state = "cryo_s"
	base_icon_state = "cryo_s-open"
	occupied_icon_state = "cryo_s"
	dir = 8
	syndicate = TRUE

/obj/machinery/cryopod/New()
	announce = new /obj/item/radio/intercom(src)

	if(orient_right)
		icon_state = "[base_icon_state]-r"
	else
		icon_state = base_icon_state

	..()

/obj/machinery/cryopod/Initialize()
	..()
	set_light(1, 1, COLOR_LIGHT_GREEN)
	find_control_computer()

/obj/machinery/cryopod/proc/find_control_computer(urgent=0)
	var/area/A = get_area(src)
	for(var/obj/machinery/computer/cryopod/C in A.contents)
		control_computer = C
		break

	// Don't send messages unless we *need* the computer, and less than five minutes have passed since last time we messaged
	if(!control_computer && urgent && last_no_computer_message + 5*60*10 < world.time)
		log_and_message_admins("Cryopod in [COORD(src)] could not find control computer!")
		last_no_computer_message = world.time

	return control_computer != null

// So the user can use movement keys to get out of the cryopod
/obj/machinery/cryopod/relaymove(mob/user)
	if(user.incapacitated())
		return FALSE
	go_out()

/obj/machinery/cryopod/proc/check_occupant_allowed(mob/M)
	var/correct_type = 0
	for(var/type in allow_occupant_types)
		if(istype(M, type))
			correct_type = 1
			break

	if(!correct_type) return 0

	for(var/type in disallow_occupant_types)
		if(istype(M, type))
			return 0

	return 1

//Lifted from Unity stasis.dm and refactored. ~Zuhayr
/obj/machinery/cryopod/process()
	if(occupant)
		// Eject dead people
		if(occupant.stat == DEAD)
			go_out()
			return

		// Allow a gap between entering the pod and actually despawning.
		if(world.time - time_entered < time_till_despawn)
			return

		if(!occupant.client && occupant.stat<2) //Occupant is living and has no client.
			if(!control_computer)
				if(!find_control_computer(urgent=1))
					return

			despawn_occupant()

/obj/machinery/cryopod/proc/should_preserve_item(obj/item/I)
	for(var/datum/theft_objective/T in control_computer.theft_cache)
		if(istype(I, T.typepath) && T.check_special_completion(I))
			return CRYO_OBJECTIVE
	for(var/T in preserve_items)
		if(istype(I, T) && !(I.type in do_not_preserve_items))
			return CRYO_PRESERVE
	return CRYO_DESTROY

/obj/machinery/cryopod/proc/handle_contents(obj/item/I)
	if(length(I.contents)) //Make sure we catch anything not handled by qdel() on the items.
		if(should_preserve_item(I) != CRYO_DESTROY) // Don't remove the contents of things that need preservation
			return
		for(var/obj/item/O in I.contents)
			if(istype(O, /obj/item/tank)) //Stop eating pockets, you fuck!
				continue
			handle_contents(O)
			O.forceMove(src)

// This function can not be undone; do not call this unless you are sure
// Also make sure there is a valid control computer
/obj/machinery/cryopod/proc/despawn_occupant()
	//Drop all items into the pod.
	for(var/obj/item/I in occupant)
		occupant.drop_item_ground(I)
		I.forceMove(src)
		handle_contents(I)

	for(var/obj/machinery/computer/cloning/cloner in GLOB.machines)
		for(var/datum/dna2/record/R in cloner.records)
			if(occupant.mind == locate(R.mind))
				cloner.records.Remove(R)

	//Delete all items not on the preservation list.
	var/list/items = contents
	items -= occupant // Don't delete the occupant
	items -= announce // or the autosay radio.

	for(var/obj/item/I in items)
		if(istype(I, /obj/item/pda))
			var/obj/item/pda/P = I
			QDEL_NULL(P.id)
			qdel(P)
			continue

		var/preserve = should_preserve_item(I)
		if(preserve == CRYO_DESTROY)
			qdel(I)
		else if(control_computer && control_computer.allow_items)
			control_computer.freeze_item(I, preserve)
		else
			I.forceMove(loc)

	// Find a new sacrifice target if needed, if unable allow summoning
	if(is_sacrifice_target(occupant.mind))
		if(!SSticker.mode.cult_objs.find_new_sacrifice_target())
			SSticker.mode.cult_objs.ready_to_summon()

	// We should track when taipan players get despawned
	if(occupant.mind in GLOB.taipan_players_active)
		GLOB.taipan_players_active -= occupant.mind

	//Update any existing objectives involving this mob.
	if(occupant.mind)
		for(var/datum/objective/O in GLOB.all_objectives)
			if(O.target != occupant.mind)
				continue
			O.on_target_cryo()
		occupant.mind.remove_all_antag_datums()

	if(occupant.mind && occupant.mind.assigned_role)
		//Handle job slot/tater cleanup.
		var/job = occupant.mind.assigned_role
		if(istype(src, /obj/machinery/cryopod/syndie))
			free_taipan_role(job)
		SSjobs.FreeRole(job)

		if(occupant.mind.objectives.len)
			occupant.mind.objectives.Cut()
			occupant.mind.special_role = null

	// Delete them from datacore.

	var/announce_rank = null
	if(GLOB.PDA_Manifest.len)
		GLOB.PDA_Manifest.Cut()
	for(var/datum/data/record/R in GLOB.data_core.medical)
		if((R.fields["name"] == occupant.real_name))
			qdel(R)
	for(var/datum/data/record/T in GLOB.data_core.security)
		if((T.fields["name"] == occupant.real_name))
			qdel(T)
	for(var/datum/data/record/G in GLOB.data_core.general)
		if((G.fields["name"] == occupant.real_name))
			announce_rank = G.fields["rank"]
			qdel(G)

	if(orient_right)
		icon_state = "[base_icon_state]-r"
	else
		icon_state = base_icon_state

	//Make an announcement and log the person entering storage + their rank
	var/list/crew_member = list()
	crew_member["name"] = occupant.real_name
	if(announce_rank)
		crew_member["rank"] = announce_rank
	else
		crew_member["rank"] = "N/A"

	control_computer.frozen_crew += list(crew_member)

	if(!syndicate)
		var/list/ailist = list()
		for(var/thing in GLOB.ai_list)
			var/mob/living/silicon/ai/AI = thing
			if(AI.stat)
				continue
			ailist += AI
		if(length(ailist))
			var/mob/living/silicon/ai/announcer = pick(ailist)
			if (announce_rank)
				announcer.say("; [issilicon(occupant) ? "Юнит" : "Сотрудник"] [occupant.real_name] ([announce_rank]) [on_store_message]")
			else
				announcer.say("; [issilicon(occupant) ? "Юнит" : "Сотрудник"] [occupant.real_name] [on_store_message]")
		else
			if (announce_rank)
				announce.autosay("[issilicon(occupant) ? "Юнит" : "Сотрудник"] [occupant.real_name]  ([announce_rank]) [on_store_message]", "[on_store_name]")
			else
				announce.autosay("[issilicon(occupant) ? "Юнит" : "Сотрудник"] [occupant.real_name] [on_store_message]", "[on_store_name]")
		visible_message(span_notice("\The [src] hums and hisses as it moves [occupant.real_name] into storage."))

	// Ghost and delete the mob.
	if(!occupant.get_ghost(1))
		if(TOO_EARLY_TO_GHOST)
			occupant.ghostize(0) // Players despawned too early may not re-enter the game
		else
			occupant.ghostize(1)
	QDEL_NULL(occupant)
	name = initial(name)


/obj/machinery/cryopod/attackby(obj/item/I, mob/user, params)

	if(istype(I, /obj/item/grab))
		var/obj/item/grab/G = I

		if(occupant)
			to_chat(user, span_notice("[src] is in use."))
			return

		if(!ismob(G.affecting))
			return

		if(!check_occupant_allowed(G.affecting))
			return

		var/willing = null //We don't want to allow people to be forced into despawning.
		var/mob/living/M = G.affecting
		time_till_despawn = initial(time_till_despawn)

		if(!istype(M) || M.stat == DEAD)
			to_chat(user, span_notice("Dead people can not be put into cryo."))
			return

		if(M.client)
			if(alert(M,"Would you like to enter long-term storage?",,"Yes","No") == "Yes")
				if(!M || !G || !G.affecting) return
				willing = willing_time_divisor
		else
			willing = 1

		if(willing)

			visible_message("[user] starts putting [G.affecting.name] into [src].")

			if(do_after(user, 20, target = G.affecting))
				if(!M || !G || !G.affecting)
					return

				if(occupant)
					to_chat(user, span_boldnotice("[src] is in use."))
					return

				add_fingerprint(user)
				take_occupant(M, willing)

			else //because why the fuck would you keep going if the mob isn't in the pod
				to_chat(user, span_notice("You stop putting [M] into the cryopod."))
				return

			if(orient_right)
				icon_state = "[occupied_icon_state]-r"
			else
				icon_state = occupied_icon_state

			to_chat(M, span_notice("[on_enter_occupant_message]"))
			to_chat(M, span_boldnotice("If you ghost, log out or close your client now, your character will shortly be permanently removed from the round."))

			take_occupant(M, willing)
	else
		return ..()


/obj/machinery/cryopod/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)

	if(O.loc == user) //no you can't pull things out of your ass
		return
	if(user.incapacitated()) //are you cuffed, dying, lying, stunned or other
		return
	if(get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src)) // is the mob anchored, too far away from you, or are you too far away from the source
		return
	if(!ismob(O)) //humans only
		return
	if(!check_occupant_allowed(O))
		return
	if(!ishuman(user) && !isrobot(user)) //No ghosts or mice putting people into the sleeper
		return
	if(user.loc==null) // just in case someone manages to get a closet into the blue light dimension, as unlikely as that seems
		return
	if(!istype(user.loc, /turf) || !istype(O.loc, /turf)) // are you in a container/closet/pod/etc?
		return
	if(occupant)
		to_chat(user, span_boldnotice("The cryo pod is already occupied!"))
		return


	var/mob/living/L = O
	if(!istype(L) || L.buckled)
		return

	if(L.stat == DEAD)
		to_chat(user, span_notice("Dead people can not be put into cryo."))
		return

	if(!L.mind)
		to_chat(user, span_notice("Catatonic people are not allowed into cryo."))
		return

	if(L.has_buckled_mobs()) //mob attached to us
		to_chat(user, span_warning("[L] will not fit into [src] because [L.p_they()] [L.p_have()] a slime latched onto [L.p_their()] head."))
		return


	var/willing = null //We don't want to allow people to be forced into despawning.
	time_till_despawn = initial(time_till_despawn)

	if(L.client)
		if(alert(L,"Would you like to enter cryosleep?",,"Yes","No") == "Yes")
			if(!L) return
			willing = willing_time_divisor
	else
		willing = 1

	if(istype(L.loc, /obj/machinery/cryopod))
		return

	if(willing)
		if(!Adjacent(L) && !Adjacent(user))
			to_chat(user, span_boldnotice("You're not close enough to [src]."))
			return
		if(L == user)
			visible_message("[user] starts climbing into the cryo pod.")
		else
			visible_message("[user] starts putting [L] into the cryo pod.")

		if(do_after(user, 20, target = L))
			if(!L) return

			if(occupant)
				to_chat(user, span_boldnotice("\The [src] is in use."))
				return
			add_fingerprint(user)
			take_occupant(L, willing)
		else
			to_chat(user, span_notice("You stop [L == user ? "climbing into the cryo pod." : "putting [L] into the cryo pod."]"))

/obj/machinery/cryopod/proc/take_occupant(var/mob/living/carbon/E, var/willing_factor = 1)
	if(occupant)
		return
	if(!E)
		return
	E.forceMove(src)
	time_till_despawn = initial(time_till_despawn) / willing_factor
	if(orient_right)
		icon_state = "[occupied_icon_state]-r"
	else
		icon_state = occupied_icon_state
	to_chat(E, span_notice("[on_enter_occupant_message]"))
	to_chat(E, span_boldnotice("If you ghost, log out or close your client now, your character will shortly be permanently removed from the round."))
	occupant = E
	name = "[name] ([occupant.name])"
	time_entered = world.time
	if(findtext("[E.key]","@",1,2))
		var/FT = replacetext(E.key, "@", "")
		for(var/mob/dead/observer/Gh in GLOB.respawnable_list) //this may not be foolproof but it seemed like a better option than 'in world'
			if(Gh.key == FT)
				if(Gh.client && Gh.client.holder) //just in case someone has a byond name with @ at the start, which I don't think is even possible but whatever
					to_chat(Gh, "<span style='color: #800080;font-weight: bold;font-size:4;'>Warning: Your body has entered cryostorage.</span>")
	log_admin(span_notice("[key_name_log(E)] entered a stasis pod."))
	message_admins("[key_name_admin(E)] entered a stasis pod. [ADMIN_JMP(src)]")
	add_fingerprint(E)


/obj/machinery/cryopod/verb/eject()
	set name = "Eject Pod"
	set category = "Object"
	set src in oview(1)

	if(usr.stat != 0)
		return

	if(usr != occupant)
		to_chat(usr, "The cryopod is in use and locked!")
		return

	if(orient_right)
		icon_state = "[base_icon_state]-r"
	else
		icon_state = base_icon_state

	//Eject any items that aren't meant to be in the pod.
	var/list/items = contents
	if(occupant) items -= occupant
	if(announce) items -= announce

	for(var/obj/item/I in items)
		I.forceMove(get_turf(src))

	go_out()
	add_fingerprint(usr)

/obj/machinery/cryopod/verb/move_inside()
	set name = "Enter Pod"
	set category = "Object"
	set src in oview(1)

	if(usr.stat != 0 || !check_occupant_allowed(usr))
		return

	if(occupant)
		to_chat(usr, span_boldnotice("\The [src] is in use."))
		return

	if(usr.has_buckled_mobs()) //mob attached to us
		to_chat(usr, span_warning("[usr] will not fit into [src] because [usr.p_they()] [usr.p_have()] a slime latched onto [usr.p_their()] head."))
		return

	if(usr.incapacitated() || usr.buckled) //are you cuffed, dying, lying, stunned or other
		return

	visible_message("[usr] starts climbing into [src].")

	if(do_after(usr, 20, target = usr))

		if(!usr || !usr.client)
			return

		if(occupant)
			to_chat(usr, span_boldnotice("\The [src] is in use."))
			return

		usr.stop_pulling()
		usr.forceMove(src)
		occupant = usr
		time_till_despawn = initial(time_till_despawn) / willing_time_divisor

		if(orient_right)
			icon_state = "[occupied_icon_state]-r"
		else
			icon_state = occupied_icon_state

		to_chat(usr, span_notice("[on_enter_occupant_message]"))
		to_chat(usr, span_boldnotice("If you ghost, log out or close your client now, your character will shortly be permanently removed from the round."))
		occupant = usr
		time_entered = world.time

		add_fingerprint(usr)
		name = "[name] ([usr.name])"

	return

/obj/machinery/cryopod/proc/go_out()
	if(!occupant)
		return

	occupant.forceMove(get_turf(src))
	occupant = null

	if(orient_right)
		icon_state = "[base_icon_state]-r"
	else
		icon_state = base_icon_state

	name = initial(name)

	return


//Attacks/effects.
/obj/machinery/cryopod/blob_act()
	return //Sorta gamey, but we don't really want these to be destroyed.

/obj/machinery/computer/cryopod/robot
	name = "robotic storage console"
	desc = "An interface between crew and the robotic storage systems"
	icon = 'icons/obj/machines/robot_storage.dmi'
	icon_state = "console"
	circuit = /obj/item/circuitboard/robotstoragecontrol

	storage_type = "cyborgs"
	storage_name = "Robotic Storage Control"
	allow_items = 0

/obj/machinery/cryopod/robot
	name = "robotic storage unit"
	desc = "A storage unit for robots."
	icon = 'icons/obj/machines/robot_storage.dmi'
	icon_state = "pod_0"
	base_icon_state = "pod_0"
	occupied_icon_state = "pod_1"
	on_store_message = "помещен в робохранилище."
	on_store_name = "Robotic Storage Oversight"
	on_enter_occupant_message = "The storage unit broadcasts a sleep signal to you. Your systems start to shut down, and you enter low-power mode."
	allow_occupant_types = list(/mob/living/silicon/robot)
	disallow_occupant_types = list()

/obj/machinery/cryopod/robot/right
	orient_right = 1
	icon_state = "pod_0-r"

/obj/machinery/cryopod/robot/despawn_occupant()
	var/mob/living/silicon/robot/R = occupant
	if(!istype(R)) return ..()

	R.contents -= R.mmi
	qdel(R.mmi)
	for(var/obj/item/I in R.module) // the tools the borg has; metal, glass, guns etc
		for(var/obj/item/O in I) // the things inside the tools, if anything; mainly for janiborg trash bags
			O.loc = R
		qdel(I)
	if(R.module)
		R.module.remove_subsystems_and_actions(R)
		qdel(R.module)

	return ..()


/proc/cryo_ssd(var/mob/living/carbon/person_to_cryo)
	if(istype(person_to_cryo.loc, /obj/machinery/cryopod))
		return 0
	if(isobj(person_to_cryo.loc))
		var/obj/O = person_to_cryo.loc
		O.force_eject_occupant(person_to_cryo)
	var/list/free_cryopods = list()
	var/list/free_syndie_cryopods = list()
	for(var/obj/machinery/cryopod/P in GLOB.machines)
		if(!P.occupant && istype(get_area(P), /area/syndicate/unpowered/syndicate_space_base) && istype(P, /obj/machinery/cryopod/syndie))
			free_syndie_cryopods += P
		else if(!P.occupant && istype(get_area(P), /area/crew_quarters/sleep))
			free_cryopods += P
	var/obj/machinery/cryopod/target_cryopod = null
	if(free_cryopods.len)
		if(person_to_cryo.find_taipan_hud_number_by_job()) //Если вернёт хоть что то значит тайпановец. Иначе вернёт null
			target_cryopod = safepick(free_syndie_cryopods)
		else
			target_cryopod = safepick(free_cryopods)
		if(target_cryopod.check_occupant_allowed(person_to_cryo))
			var/turf/T = get_turf(person_to_cryo)
			var/obj/effect/portal/SP = new /obj/effect/portal(T, null, null, 40)
			SP.name = "NT SSD Teleportation Portal"
			target_cryopod.take_occupant(person_to_cryo, 1)
			return 1
	return 0

/proc/force_cryo_human(var/mob/living/carbon/person_to_cryo)
	if(!istype(person_to_cryo))
		return
	if(!istype(person_to_cryo.loc, /obj/machinery/cryopod))
		cryo_ssd(person_to_cryo)
	if(istype(person_to_cryo.loc, /obj/machinery/cryopod))
		var/obj/machinery/cryopod/P = person_to_cryo.loc
		P.despawn_occupant()

#undef CRYO_DESTROY
#undef CRYO_PRESERVE
#undef CRYO_OBJECTIVE
