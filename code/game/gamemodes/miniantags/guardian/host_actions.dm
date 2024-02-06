/**
 * # Base guardian host action
 *
 * These are used by guardian hosts to interact with their guardians. These are not buttons that guardians themselves use.
 */
/datum/action/guardian
	name = "Generic guardian host action"
	icon_icon = 'icons/mob/guardian.dmi'
	button_icon_state = "base"
	var/mob/living/simple_animal/hostile/guardian/guardian

/datum/action/guardian/Grant(mob/M, mob/living/simple_animal/hostile/guardian/G)
	if(!G || !istype(G))
		stack_trace("/datum/action/guardian created with no guardian to link to.")
		qdel(src)
	guardian = G
	return ..()

/**
 * # Communicate action
 *
 * Allows the guardian host to communicate with their guardian.
 */
/datum/action/guardian/communicate
	name = "Communicate"
	desc = "Communicate telepathically with your guardian."
	button_icon_state = "communicate"

/datum/action/guardian/communicate/Trigger(left_click)
	var/input = stripped_input(owner, "Enter a message to tell your guardian:", "Message", "")
	if(!input || !guardian)
		return

	// Show the message to our guardian and to host.
	to_chat(guardian, "<span class='changeling'><i>[owner]:</i> [input]</span>")
	to_chat(owner, "<span class='changeling'><i>[owner]:</i> [input]</span>")
	log_say("(HOST to [key_name(guardian)]): [input]", owner)
	owner.create_log(SAY_LOG, "HOST to GUARDIAN: [input]", guardian)

	// Show the message to any ghosts/dead players.
	for(var/mob/M in GLOB.dead_mob_list)
		if(M && M.client && M.stat == DEAD && !isnewplayer(M))
			to_chat(M, "<span class='changeling'><i>Guardian Communication from <b>[owner]</b> ([ghost_follow_link(owner, ghost=M)]): [input]</i>")

/**
 * # Recall guardian action
 *
 * Allows the guardian host to recall their guardian.
 */
/datum/action/guardian/recall
	name = "Recall Guardian"
	desc = "Forcibly recall your guardian."
	button_icon_state = "recall"

/datum/action/guardian/recall/Trigger(left_click)
	guardian.Recall()

/**
 * # Reset guardian action
 *
 * Allows the guardian host to exchange their guardian's player for another.
 */
/datum/action/guardian/reset_guardian
	name = "Replace Guardian Player"
	desc = "Replace your guardian's player with a ghost. This can only be done once."
	button_icon_state = "reset"
	var/cooldown_timer

/datum/action/guardian/reset_guardian/IsAvailable()
	if(cooldown_timer)
		return FALSE
	return TRUE

/datum/action/guardian/reset_guardian/Trigger(left_click)
	if(cooldown_timer)
		to_chat(owner, "<span class='warning'>This ability is still recharging.</span>")
		return

	var/confirm = alert("Are you sure you want replace your guardian's player?", "Confirm", "Yes", "No")
	if(confirm == "No")
		return

	// Do this immediately, so the user can't spam a bunch of polls.
	cooldown_timer = addtimer(CALLBACK(src, PROC_REF(reset_cooldown)), 5 MINUTES)
	UpdateButtonIcon()

	to_chat(owner, "<span class='danger'>Searching for a replacement ghost...</span>")
	var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Do you want to play as [guardian.real_name]?", ROLE_GUARDIAN, FALSE, 15 SECONDS, source = guardian)

	if(!length(candidates))
		to_chat(owner, "<span class='danger'>There were no ghosts willing to take control of your guardian. You can try again in 5 minutes.</span>")
		return
	if(QDELETED(guardian)) // Just in case
		return

	var/mob/dead/observer/new_stand = pick(candidates)
	to_chat(guardian, "<span class='danger'>Your user reset you, and your body was taken over by a ghost. Looks like they weren't happy with your performance.</span>")
	to_chat(owner, "<span class='danger'>Your guardian has been successfully reset.</span>")
	message_admins("[key_name_admin(new_stand)] has taken control of ([key_name_admin(guardian)])")
	guardian.ghostize()
	guardian.key = new_stand.key
	dust_if_respawnable(new_stand)
	qdel(src)

/obj/effect/proc_holder/spell/summon_guardian_beacon
	name = "Place Teleportation Beacon"
	desc = "Mark a floor as your beacon point, allowing you to warp targets to it. Your beacon requires an anchor, will not work on space tiles."
	clothes_req = FALSE
	base_cooldown = 300 SECONDS
	action_icon_state = "no_state"
	action_background_icon_state = "reset"
	action_icon = 'icons/mob/guardian.dmi'

/obj/effect/proc_holder/spell/summon_guardian_beacon/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/effect/proc_holder/spell/summon_guardian_beacon/cast(list/targets, mob/living/user = usr)
	var/target = targets[1]
	var/mob/living/simple_animal/hostile/guardian/healer/guardian_user = user
	var/turf/beacon_loc = get_turf(target)
	if(isfloorturf(beacon_loc) && !islava(beacon_loc) && !ischasm(beacon_loc))
		QDEL_NULL(guardian_user.beacon)
		guardian_user.beacon = new(beacon_loc)
		to_chat(guardian_user, "<span class='notice'>Beacon placed! You may now warp targets to it, including your user, via <b>Alt Click</b>.</span>")

	return TRUE

/obj/effect/proc_holder/spell/surveillance_snare
	name = "Set Surveillance Snare"
	desc = "Places an invisible Surveillance Snare on the ground, if someone walks over it you'll be alerted. Max of 6 snares active at a time"
	clothes_req = FALSE
	base_cooldown = 3 SECONDS
	action_icon_state = "no_state"
	action_background_icon_state = "reset"
	action_icon = 'icons/mob/guardian.dmi'

/obj/effect/proc_holder/spell/surveillance_snare/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/effect/proc_holder/spell/surveillance_snare/cast(list/targets, mob/living/user = usr)
	var/target = targets[1]
	var/mob/living/simple_animal/hostile/guardian/ranged/guardian_user = user
	if(length(guardian_user.snares) < 6)
		var/turf/snare_loc = get_turf(target)
		var/obj/item/effect/snare/S = new /obj/item/effect/snare(snare_loc)
		S.spawner = guardian_user
		S.name = "[get_area(snare_loc)] trap ([snare_loc.x],[snare_loc.y],[snare_loc.z])"
		guardian_user.snares |= S
		to_chat(guardian_user, "<span class='notice'>Surveillance trap deployed!</span>")
		return TRUE
	else
		to_chat(guardian_user, "<span class='notice'>You have too many traps deployed. Delete one to place another.</span>")
		var/picked_snare = input(guardian_user, "Pick which trap to disarm", "Disarm Trap") as null|anything in guardian_user.snares
		if(picked_snare)
			guardian_user.snares -= picked_snare
			qdel(picked_snare)
			to_chat(src, "<span class='notice'>Snare disarmed.</span>")
			revert_cast()

/obj/effect/proc_holder/spell/choose_battlecry
	name = "Change battlecry"
	desc = "Changes your battlecry."
	clothes_req = FALSE
	base_cooldown = 1 SECONDS
	action_icon_state = "no_state"
	action_background_icon_state = "communicate"
	action_icon = 'icons/mob/guardian.dmi'

/obj/effect/proc_holder/spell/choose_battlecry/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/effect/proc_holder/spell/choose_battlecry/cast(list/targets, mob/living/user = usr)
	var/mob/living/simple_animal/hostile/guardian/punch/guardian_user = user
	var/input = stripped_input(guardian_user, "What do you want your battlecry to be? Max length of 5 characters.", ,"", 6)
	if(!input)
		revert_cast()
		return
	guardian_user.battlecry = input

/**
 * Takes the action button off cooldown and makes it available again.
 */
/datum/action/guardian/reset_guardian/proc/reset_cooldown()
	cooldown_timer = null
	UpdateButtonIcon()

/**
 * Grants all existing `/datum/action/guardian` type actions to the src mob.
 *
 * Called whenever the host gains their gauardian.
 */
/mob/living/proc/grant_guardian_actions(mob/living/simple_animal/hostile/guardian/G)
	if(!G || !istype(G))
		return
	for(var/action in subtypesof(/datum/action/guardian))
		var/datum/action/guardian/A = new action
		A.Grant(src, G)

/**
 * Removes all `/datum/action/guardian` type actions from the src mob.
 *
 * Called whenever the host loses their guardian.
 */
/mob/living/proc/remove_guardian_actions()
	for(var/action in actions)
		var/datum/action/A = action
		if(istype(A, /datum/action/guardian))
			A.Remove(src)
