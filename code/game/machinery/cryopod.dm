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
	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "cellconsole"
	circuit = /obj/item/circuitboard/cryopodcontrol
	density = 0
	interact_offline = 1
	req_one_access = list(ACCESS_HEADS, ACCESS_ARMORY) //Heads of staff or the warden can go here to claim recover items from their department that people went were cryodormed with.
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
	for(var/T in GLOB.potential_theft_objectives)
		theft_cache += new T

/obj/machinery/computer/cryopod/attack_ai()
	attack_hand()

/obj/machinery/computer/cryopod/attack_hand(mob/user = usr)
	if(stat & (NOPOWER|BROKEN))
		return

	user.set_machine(src)
	add_fingerprint(usr)

	var/dat

	if(!( SSticker ))
		return

	dat += "<hr/><br/><b>[storage_name]</b><br/>"
	dat += "<i>Welcome, [user.real_name].</i><br/><br/><hr/>"
	dat += "<a href='?src=[UID()];log=1'>View storage log</a>.<br>"
	if(allow_items)
		dat += "<a href='?src=[UID()];view=1'>View objects</a>.<br>"
		dat += "<a href='?src=[UID()];item=1'>Recover object</a>.<br>"
		dat += "<a href='?src=[UID()];allitems=1'>Recover all objects</a>.<br>"

	user << browse(dat, "window=cryopod_console")
	onclose(user, "cryopod_console")

/obj/machinery/computer/cryopod/Topic(href, href_list)
	if(..())
		return 1

	var/mob/user = usr

	add_fingerprint(user)

	if(href_list["log"])

		var/dat = "<b>Recently stored [storage_type]</b><br/><hr/><br/>"
		for(var/person in frozen_crew)
			dat += "[person]<br/>"
		dat += "<hr/>"

		user << browse(dat, "window=cryolog")

	if(href_list["view"])
		if(!allow_items) return

		var/dat = "<b>Recently stored objects</b><br/><hr/><br/>"
		for(var/obj/item/I in frozen_items)
			dat += "[I.name]<br/>"
		dat += "<hr/>"

		user << browse(dat, "window=cryoitems")

	else if(href_list["item"])
		if(!allowed(user))
			to_chat(user, "<span class='warning'>Access Denied.</span>")
			return
		if(!allow_items) return

		if(frozen_items.len == 0)
			to_chat(user, "<span class='notice'>There is nothing to recover from storage.</span>")
			return

		var/obj/item/I = input(usr, "Please choose which object to retrieve.","Object recovery",null) as null|anything in frozen_items
		if(!I)
			return

		if(!(I in frozen_items))
			to_chat(user, "<span class='notice'>\The [I] is no longer in storage.</span>")
			return

		visible_message("<span class='notice'>The console beeps happily as it disgorges [I].</span>")

		dispense_item(I)

	else if(href_list["allitems"])
		if(!allowed(user))
			to_chat(user, "<span class='warning'>Access Denied.</span>")
			return
		if(!allow_items)
			return

		if(frozen_items.len == 0)
			to_chat(user, "<span class='notice'>There is nothing to recover from storage.</span>")
			return

		visible_message("<span class='notice'>The console beeps happily as it disgorges the desired objects.</span>")

		for(var/obj/item/I in frozen_items)
			dispense_item(I)

	updateUsrDialog()
	return

/obj/machinery/computer/cryopod/proc/freeze_item(obj/item/I, preserve_status)
	frozen_items += I
	if(preserve_status == CRYO_OBJECTIVE)
		objective_items += I
	I.forceMove(src)
	RegisterSignal(I, COMSIG_MOVABLE_MOVED, .proc/item_got_removed)

/obj/machinery/computer/cryopod/proc/item_got_removed(obj/item/I)
	objective_items -= I
	frozen_items -= I
	UnregisterSignal(I, COMSIG_MOVABLE_MOVED)

/obj/machinery/computer/cryopod/proc/dispense_item(obj/item/I)
	if(!(I in frozen_items))
		return
	I.forceMove(get_turf(src)) // Will call item_got_removed due to the signal being registered to COMSIG_MOVABLE_MOVED

/obj/machinery/computer/cryopod/emag_act(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	if(!objective_items.len)
		visible_message("<span class='warning'>The console buzzes in an annoyed manner.</span>")
		playsound(src, 'sound/machines/buzz-sigh.ogg', 30, 1)
		return
	visible_message("<span class='warning'>The console sparks, and some items fall out!</span>")
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
	icon = 'icons/obj/cryogenic2.dmi'
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
	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "body_scanner_0"
	density = 1
	anchored = 1
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	flags = NODECONSTRUCT
	occupy_whitelist = list(/mob/living/carbon/human)
	var/base_icon_state = "body_scanner_0"
	var/occupied_icon_state = "body_scanner_1"
	var/on_store_message = "has entered long-term storage."
	var/on_store_name = "Cryogenic Oversight"
	var/on_enter_occupant_message = "You feel cool air surround you. You go numb as your senses turn inward."

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
		/obj/item/reagent_containers/hypospray/CMO,
		/obj/item/clothing/accessory/medal/gold/captain,
		/obj/item/clothing/gloves/color/black/krav_maga/sec,
		/obj/item/spacepod_key,
		/obj/item/nullrod,
		/obj/item/key,
		/obj/item/door_remote,
		/obj/item/autopsy_scanner,
		/obj/item/holosign_creator/atmos
	)
	// These items will NOT be preserved
	var/list/do_not_preserve_items = list (
		/obj/item/mmi/robotic_brain
	)

/obj/machinery/cryopod/right
	orient_right = 1
	icon_state = "body_scanner_0-r"

/obj/machinery/cryopod/New()
	announce = new /obj/item/radio/intercom(src)

	if(orient_right)
		icon_state = "[base_icon_state]-r"
	else
		icon_state = base_icon_state

	..()

/obj/machinery/cryopod/Initialize()
	..()

	find_control_computer()

/obj/machinery/cryopod/proc/find_control_computer(urgent=0)
	for(var/obj/machinery/computer/cryopod/C in get_area(src).contents)
		control_computer = C
		break

	// Don't send messages unless we *need* the computer, and less than five minutes have passed since last time we messaged
	if(!control_computer && urgent && last_no_computer_message + 5*60*10 < world.time)
		log_admin("Cryopod in [loc.loc] could not find control computer!")
		message_admins("Cryopod in [loc.loc] could not find control computer!")
		last_no_computer_message = world.time

	return control_computer != null

//Lifted from Unity stasis.dm and refactored. ~Zuhayr
/obj/machinery/cryopod/process()
	if(occupant)
		// Eject dead people
		if(occupant.stat == DEAD)
			unoccupy(force = TRUE)
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

// This function can not be undone; do not call this unless you are sure
// Also make sure there is a valid control computer
/obj/machinery/cryopod/proc/despawn_occupant()
	//Drop all items into the pod.
	for(var/obj/item/I in occupant)
		occupant.unEquip(I)
		I.forceMove(src)

		if(I.contents.len) //Make sure we catch anything not handled by qdel() on the items.
			if(should_preserve_item(I) != CRYO_DESTROY) // Don't remove the contents of things that need preservation
				continue
			for(var/obj/item/O in I.contents)
				if(istype(O, /obj/item/tank)) //Stop eating pockets, you fuck!
					continue
				O.forceMove(src)

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

	//Update any existing objectives involving this mob.
	if(occupant.mind)
		for(var/datum/objective/O in GLOB.all_objectives)
			if(O.target != occupant.mind)
				continue
			O.on_target_cryo()
	if(occupant.mind && occupant.mind.assigned_role)
		//Handle job slot/tater cleanup.
		var/job = occupant.mind.assigned_role

		SSjobs.FreeRole(job)

		if(occupant.mind.objectives.len)
			occupant.mind.objectives.Cut()
			occupant.mind.special_role = null
		else
			if(SSticker.mode.name == "AutoTraitor")
				var/datum/game_mode/traitor/autotraitor/current_mode = SSticker.mode
				current_mode.possible_traitors.Remove(occupant)

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

	//Make an announcement and log the person entering storage.
	control_computer.frozen_crew += "[occupant.real_name]"

	var/list/ailist = list()
	for(var/mob/living/silicon/ai/A in GLOB.silicon_mob_list)
		ailist += A
	if(length(ailist))
		var/mob/living/silicon/ai/announcer = pick(ailist)
		if(announce_rank)
			announcer.say(";[occupant.real_name] ([announce_rank]) [on_store_message]", ignore_languages = TRUE)
		else
			announcer.say(";[occupant.real_name] [on_store_message]", ignore_languages = TRUE)
	else
		if(announce_rank)
			announce.autosay("[occupant.real_name]  ([announce_rank]) [on_store_message]", "[on_store_name]")
		else
			announce.autosay("[occupant.real_name] [on_store_message]", "[on_store_name]")
	visible_message("<span class='notice'>[src] hums and hisses as it moves [occupant.real_name] into storage.</span>")

	// Ghost and delete the mob.
	if(!occupant.get_ghost(TRUE))
		if(TOO_EARLY_TO_GHOST)
			occupant.ghostize(FALSE) // Players despawned too early may not re-enter the game
		else
			occupant.ghostize(TRUE)
	QDEL_NULL(occupant)
	name = initial(name)

/obj/machinery/cryopod/verb/eject()
	set name = "Eject Pod"
	set category = "Object"
	set src in oview(1)

	if(usr.incapacitated())
		return
	unoccupy(usr)

/obj/machinery/cryopod/verb/move_inside()
	set name = "Enter Pod"
	set category = "Object"
	set src in oview(1)

	if(usr.incapacitated())
		return
	occupy(usr, usr)

//Attacks/effects.
/obj/machinery/cryopod/blob_act()
	return //Sorta gamey, but we don't really want these to be destroyed.

/obj/machinery/cryopod/can_occupy(mob/living/M, mob/user)
	var/mob/living/carbon/human/H = M
	if(!istype(H))
		return FALSE
	if(H.stat == DEAD)
		to_chat(user, "<span class='warning'>Dead people can not be put into cryogenic storage.</span>")
		return FALSE
	return ..()

/obj/machinery/cryopod/occupy(mob/living/M, mob/user, instant = FALSE)
	var/willing_factor = null
	if(!instant && M.client)
		if(alert(M, "Would you like to enter long-term storage?", , "Yes", "No") == "Yes")
			if(!M)
				return
			willing_factor = willing_time_divisor
	else
		willing_factor = 1

	if(!willing_factor)
		return

	. = ..()
	if(.)
		name = "[initial(name)] ([occupant.name])"
		time_entered = world.time
		time_till_despawn = initial(time_till_despawn) / willing_factor
		if(orient_right)
			icon_state = "[occupied_icon_state]-r"
		else
			icon_state = occupied_icon_state

		to_chat(M, "<span class='notice'>[on_enter_occupant_message]</span>")
		to_chat(M, "<span class='boldnotice'>If you ghost, log out or close your client now, your character will shortly be permanently removed from the round.</span>")
		add_fingerprint(M)

		if(M.key && M.key[1] == "@")
			var/clean_key = replacetext(M.key, "@", "")
			for(var/mob/dead/observer/G in GLOB.respawnable_list) //this may not be foolproof but it seemed like a better option than 'in world'
				if(G.key == clean_key && G.client?.holder) //just in case someone has a byond name with @ at the start, which I don't think is even possible but whatever
					to_chat(G, "<span style='color: #800080;font-weight: bold;font-size:4;'>Warning: Your body has entered cryostorage.</span>")
					break

		log_admin("<span class='notice'>[key_name(M)] entered a stasis pod.</span>")
		message_admins("[key_name_admin(M)] entered a stasis pod. [ADMIN_JMP(src)]")

/obj/machinery/cryopod/unoccupy(mob/user, force)
	if(!force && user != occupant)
		to_chat(user, "The cryopod is in use and locked!")
		return

	. = ..()
	if(.)
		if(orient_right)
			icon_state = "[base_icon_state]-r"
		else
			icon_state = base_icon_state

		//Eject any items that aren't meant to be in the pod.
		for(var/obj/item/I in contents - occupant - announce)
			I.forceMove(get_turf(src))

/obj/machinery/computer/cryopod/robot
	name = "robotic storage console"
	desc = "An interface between crew and the robotic storage systems"
	icon = 'icons/obj/robot_storage.dmi'
	icon_state = "console"
	circuit = /obj/item/circuitboard/robotstoragecontrol

	storage_type = "cyborgs"
	storage_name = "Robotic Storage Control"
	allow_items = 0

/obj/machinery/cryopod/robot
	name = "robotic storage unit"
	desc = "A storage unit for robots."
	icon = 'icons/obj/robot_storage.dmi'
	icon_state = "pod_0"
	base_icon_state = "pod_0"
	occupied_icon_state = "pod_1"
	on_store_message = "has entered robotic storage."
	on_store_name = "Robotic Storage Oversight"
	on_enter_occupant_message = "The storage unit broadcasts a sleep signal to you. Your systems start to shut down, and you enter low-power mode."
	occupy_whitelist = list(/mob/living/silicon/robot)
	occupy_blacklist = list(/mob/living/silicon/robot/drone)

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
	for(var/obj/machinery/cryopod/P in GLOB.machines)
		if(!P.occupant && istype(get_area(P), /area/crew_quarters/sleep))
			free_cryopods += P
	var/obj/machinery/cryopod/target_cryopod = null
	if(free_cryopods.len)
		target_cryopod = safepick(free_cryopods)
		if(target_cryopod.occupy(person_to_cryo, instant = TRUE))
			var/turf/T = get_turf(person_to_cryo)
			var/obj/effect/portal/SP = new /obj/effect/portal(T, null, null, 40)
			SP.name = "NT SSD Teleportation Portal"
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
