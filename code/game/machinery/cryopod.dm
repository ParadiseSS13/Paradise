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
	req_one_access = list(access_heads, access_armory) //Heads of staff or the warden can go here to claim recover items from their department that people went were cryodormed with.
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
	for(var/T in potential_theft_objectives)
		theft_cache += new T

/obj/machinery/computer/cryopod/attack_ai()
	attack_hand()

/obj/machinery/computer/cryopod/attack_hand(mob/user = usr)
	if(stat & (NOPOWER|BROKEN))
		return

	user.set_machine(src)
	add_fingerprint(usr)

	var/dat

	if(!( ticker ))
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

/obj/machinery/computer/cryopod/proc/dispense_item(obj/item/I)
	if(!(I in frozen_items))
		return
	I.forceMove(get_turf(src))
	objective_items -= I
	frozen_items -= I

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

/obj/structure/cryofeed/New()

	if(orient_right)
		icon_state = "cryo_rear-r"
	else
		icon_state = "cryo_rear"
	..()

//Cryopods themselves.
/obj/machinery/cryopod
	name = "cryogenic freezer"
	desc = "A man-sized pod for entering suspended animation."
	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "body_scanner_0"
	density = 1
	anchored = 1

	var/base_icon_state = "body_scanner_0"
	var/occupied_icon_state = "body_scanner_1"
	var/on_store_message = "has entered long-term storage."
	var/on_store_name = "Cryogenic Oversight"
	var/on_enter_occupant_message = "You feel cool air surround you. You go numb as your senses turn inward."
	var/allow_occupant_types = list(/mob/living/carbon/human)
	var/disallow_occupant_types = list()

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
		/obj/item/reagent_containers/hypospray/CMO,
		/obj/item/clothing/accessory/medal/gold/captain,
		/obj/item/clothing/gloves/color/black/krav_maga/sec,
		/obj/item/storage/internal,
		/obj/item/spacepod_key,
		/obj/item/nullrod
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
	for(var/obj/machinery/computer/cryopod/C in areaMaster.contents) //locate() is shit, this actually works, and there's a decent chance it's faster than locate()
		control_computer = C
		break

	// Don't send messages unless we *need* the computer, and less than five minutes have passed since last time we messaged
	if(!control_computer && urgent && last_no_computer_message + 5*60*10 < world.time)
		log_admin("Cryopod in [loc.loc] could not find control computer!")
		message_admins("Cryopod in [loc.loc] could not find control computer!")
		last_no_computer_message = world.time

	return control_computer != null

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

		// Allow a gap between entering the pod and actually despawning.
		if(world.time - time_entered < time_till_despawn)
			return

		if(!occupant.client && occupant.stat<2) //Occupant is living and has no client.
			if(!control_computer)
				if(!find_control_computer(urgent=1))
					return

			despawn_occupant()

#define CRYO_DESTROY 0
#define CRYO_PRESERVE 1
#define CRYO_OBJECTIVE 2

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
			control_computer.frozen_items += I
			if(preserve == CRYO_OBJECTIVE)
				control_computer.objective_items += I
			I.loc = null
		else
			I.forceMove(loc)

	// Skip past any cult sacrifice objective using this person
	if(GAMEMODE_IS_CULT && is_sacrifice_target(occupant.mind))
		var/datum/game_mode/cult/cult_mode = ticker.mode
		var/list/p_s_t = cult_mode.get_possible_sac_targets()
		if(p_s_t.len)
			cult_mode.sacrifice_target = pick(p_s_t)
			for(var/datum/mind/H in ticker.mode.cult)
				if(H.current)
					to_chat(H.current, "<span class='danger'>[ticker.cultdat.entity_name]</span> murmurs, <span class='cultlarge'>[occupant] is beyond your reach. Sacrifice [cult_mode.sacrifice_target.current] instead...</span></span>")
		else
			cult_mode.bypass_phase()

	//Update any existing objectives involving this mob.
	for(var/datum/objective/O in all_objectives)
		// We don't want revs to get objectives that aren't for heads of staff. Letting
		// them win or lose based on cryo is silly so we remove the objective.
		if(istype(O,/datum/objective/mutiny) && O.target == occupant.mind)
			qdel(O)
		else if(O.target && istype(O.target,/datum/mind))
			if(O.target == occupant.mind)
				if(O.owner && O.owner.current)
					to_chat(O.owner.current, "<BR><span class='userdanger'>You get the feeling your target is no longer within reach. Time for Plan [pick("A","B","C","D","X","Y","Z")]. Objectives updated!</span>")
					O.owner.current << 'sound/ambience/alarm4.ogg'
				O.target = null
				spawn(1) //This should ideally fire after the occupant is deleted.
					if(!O) return
					O.find_target()
					if(!(O.target))
						all_objectives -= O
						O.owner.objectives -= O
						qdel(O)
	if(occupant.mind && occupant.mind.assigned_role)
		//Handle job slot/tater cleanup.
		var/job = occupant.mind.assigned_role

		job_master.FreeRole(job)

		if(occupant.mind.objectives.len)
			occupant.mind.objectives.Cut()
			occupant.mind.special_role = null
		else
			if(ticker.mode.name == "AutoTraitor")
				var/datum/game_mode/traitor/autotraitor/current_mode = ticker.mode
				current_mode.possible_traitors.Remove(occupant)

	// Delete them from datacore.

	var/announce_rank = null
	if(PDA_Manifest.len)
		PDA_Manifest.Cut()
	for(var/datum/data/record/R in data_core.medical)
		if((R.fields["name"] == occupant.real_name))
			qdel(R)
	for(var/datum/data/record/T in data_core.security)
		if((T.fields["name"] == occupant.real_name))
			qdel(T)
	for(var/datum/data/record/G in data_core.general)
		if((G.fields["name"] == occupant.real_name))
			announce_rank = G.fields["rank"]
			qdel(G)

	if(orient_right)
		icon_state = "[base_icon_state]-r"
	else
		icon_state = base_icon_state

	//Make an announcement and log the person entering storage.
	control_computer.frozen_crew += "[occupant.real_name]"

	var/ailist[] = list()
	for(var/mob/living/silicon/ai/A in GLOB.living_mob_list)
		ailist += A
	if(ailist.len)
		var/mob/living/silicon/ai/announcer = pick(ailist)
		if (announce_rank)
			announcer.say(";[occupant.real_name] ([announce_rank]) [on_store_message]")
		else
			announcer.say(";[occupant.real_name] [on_store_message]")
	else
		if (announce_rank)
			announce.autosay("[occupant.real_name]  ([announce_rank]) [on_store_message]", "[on_store_name]")
		else
			announce.autosay("[occupant.real_name] [on_store_message]", "[on_store_name]")
	visible_message("<span class='notice'>\The [src] hums and hisses as it moves [occupant.real_name] into storage.</span>")

	// Ghost and delete the mob.
	if(!occupant.get_ghost(1))
		if(TOO_EARLY_TO_GHOST)
			occupant.ghostize(0) // Players despawned too early may not re-enter the game
		else
			occupant.ghostize(1)
	QDEL_NULL(occupant)
	name = initial(name)

#undef CRYO_DESTROY
#undef CRYO_PRESERVE
#undef CRYO_OBJECTIVE

/obj/machinery/cryopod/attackby(obj/item/I, mob/user, params)

	if(istype(I, /obj/item/grab))
		var/obj/item/grab/G = I

		if(occupant)
			to_chat(user, "<span class='notice'>[src] is in use.</span>")
			return

		if(!ismob(G.affecting))
			return

		if(!check_occupant_allowed(G.affecting))
			return

		var/willing = null //We don't want to allow people to be forced into despawning.
		var/mob/living/M = G.affecting
		time_till_despawn = initial(time_till_despawn)

		if(!istype(M) || M.stat == DEAD)
			to_chat(user, "<span class='notice'>Dead people can not be put into cryo.</span>")
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
					to_chat(user, "<span class='boldnotice'>[src] is in use.</span>")
					return

				take_occupant(M, willing)

			else //because why the fuck would you keep going if the mob isn't in the pod
				to_chat(user, "<span class='notice'>You stop putting [M] into the cryopod.</span>")
				return

			if(orient_right)
				icon_state = "[occupied_icon_state]-r"
			else
				icon_state = occupied_icon_state

			to_chat(M, "<span class='notice'>[on_enter_occupant_message]</span>")
			to_chat(M, "<span class='boldnotice'>If you ghost, log out or close your client now, your character will shortly be permanently removed from the round.</span>")

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
		to_chat(user, "<span class='boldnotice'>The cryo pod is already occupied!</span>")
		return


	var/mob/living/L = O
	if(!istype(L) || L.buckled)
		return

	if(L.stat == DEAD)
		to_chat(user, "<span class='notice'>Dead people can not be put into cryo.</span>")
		return

	for(var/mob/living/carbon/slime/M in range(1,L))
		if(M.Victim == L)
			to_chat(usr, "[L.name] will not fit into the cryo pod because [L.p_they()] [L.p_have()] a slime latched onto [L.p_their()] head.")
			return


	var/willing = null //We don't want to allow people to be forced into despawning.
	time_till_despawn = initial(time_till_despawn)

	if(L.client)
		if(alert(L,"Would you like to enter cryosleep?",,"Yes","No") == "Yes")
			if(!L) return
			willing = willing_time_divisor
	else
		willing = 1

	if(willing)
		if(!Adjacent(L))
			to_chat(user, "<span class='boldnotice'>You're not close enough to [src].</span>")
			return
		if(L == user)
			visible_message("[user] starts climbing into the cryo pod.")
		else
			visible_message("[user] starts putting [L] into the cryo pod.")

		if(do_after(user, 20, target = L))
			if(!L) return

			if(occupant)
				to_chat(user, "<span class='boldnotice'>\The [src] is in use.</span>")
				return
			take_occupant(L, willing)
		else
			to_chat(user, "<span class='notice'>You stop [L == user ? "climbing into the cryo pod." : "putting [L] into the cryo pod."]</span>")

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
	to_chat(E, "<span class='notice'>[on_enter_occupant_message]</span>")
	to_chat(E, "<span class='boldnotice'>If you ghost, log out or close your client now, your character will shortly be permanently removed from the round.</span>")
	occupant = E
	name = "[name] ([occupant.name])"
	time_entered = world.time
	if(findtext("[E.key]","@",1,2))
		var/FT = replacetext(E.key, "@", "")
		for(var/mob/dead/observer/Gh in GLOB.respawnable_list) //this may not be foolproof but it seemed like a better option than 'in world'
			if(Gh.key == FT)
				if(Gh.client && Gh.client.holder) //just in case someone has a byond name with @ at the start, which I don't think is even possible but whatever
					to_chat(Gh, "<span style='color: #800080;font-weight: bold;font-size:4;'>Warning: Your body has entered cryostorage.</span>")
	log_admin("<span class='notice'>[key_name(E)] entered a stasis pod.</span>")
	message_admins("[key_name_admin(E)] entered a stasis pod. (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)")
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

	name = initial(name)

/obj/machinery/cryopod/verb/move_inside()
	set name = "Enter Pod"
	set category = "Object"
	set src in oview(1)

	if(usr.stat != 0 || !check_occupant_allowed(usr))
		return

	if(occupant)
		to_chat(usr, "<span class='boldnotice'>\The [src] is in use.</span>")
		return

	for(var/mob/living/carbon/slime/M in range(1,usr))
		if(M.Victim == usr)
			to_chat(usr, "You're too busy getting your life sucked out of you.")
			return

	visible_message("[usr] starts climbing into [src].")

	if(do_after(usr, 20, target = usr))

		if(!usr || !usr.client)
			return

		if(occupant)
			to_chat(usr, "<span class='boldnotice'>\The [src] is in use.</span>")
			return

		usr.stop_pulling()
		usr.forceMove(src)
		occupant = usr
		time_till_despawn = initial(time_till_despawn) / willing_time_divisor

		if(orient_right)
			icon_state = "[occupied_icon_state]-r"
		else
			icon_state = occupied_icon_state

		to_chat(usr, "<span class='notice'>[on_enter_occupant_message]</span>")
		to_chat(usr, "<span class='boldnotice'>If you ghost, log out or close your client now, your character will shortly be permanently removed from the round.</span>")
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

	return


//Attacks/effects.
/obj/machinery/cryopod/blob_act()
	return //Sorta gamey, but we don't really want these to be destroyed.

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
	allow_occupant_types = list(/mob/living/silicon/robot)
	disallow_occupant_types = list(/mob/living/silicon/robot/drone)

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
	var/list/free_cryopods = list()
	for(var/obj/machinery/cryopod/P in GLOB.machines)
		if(!P.occupant && istype(get_area(P), /area/crew_quarters/sleep))
			free_cryopods += P
	var/obj/machinery/cryopod/target_cryopod = null
	if(free_cryopods.len)
		target_cryopod = safepick(free_cryopods)
		if(target_cryopod.check_occupant_allowed(person_to_cryo))
			target_cryopod.take_occupant(person_to_cryo, 1)
			return 1
	return 0
