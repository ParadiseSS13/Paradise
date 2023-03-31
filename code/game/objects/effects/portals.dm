#define EFFECT_COOLDOWN 0.5 SECONDS

/obj/effect/portal
	name = "portal"
	desc = "Looks unstable. Best to test it with the clown."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "portal"

	var/obj/item/target = null
	/// The UID and `name` of the object that created this portal. For example, a wormhole jaunter.
	var/list/creation_obj_data
	/// The ckey of the mob which was responsible for the creation of the portal. For example, the mob who used a wormhole jaunter.
	var/creation_mob_ckey

	var/failchance = 5
	var/fail_icon = "portal1"

	var/precision = TRUE // how close to the portal you will teleport. FALSE = on the portal, TRUE = adjacent
	var/can_multitool_to_remove = FALSE
	var/ignore_tele_proof_area_setting = FALSE
	var/one_use = FALSE // Does this portal go away after one teleport?
	/// The time after which the effects should play again. Too many effects can lag the server
	var/effect_cooldown = 0

/obj/effect/portal/New(loc, turf/_target, obj/creation_object = null, lifespan = 300, mob/creation_mob = null)
	..()

	GLOB.portals += src

	target = _target
	if(creation_object)
		creation_obj_data = list(creation_object.UID(), "[creation_object.name]") // Store the name incase the object is deleted.
	else
		creation_obj_data = list(null, null)
	creation_mob_ckey = creation_mob?.ckey

	if(lifespan > 0)
		QDEL_IN(src, lifespan)

/obj/effect/portal/Destroy()
	GLOB.portals -= src
	var/obj/O = locateUID(creation_obj_data[1])
	if(!QDELETED(O))
		O.portal_destroyed(src)
	target = null
	return ..()

/obj/effect/portal/singularity_pull()
	return

/obj/effect/portal/singularity_act()
	return

/obj/effect/portal/Crossed(atom/movable/AM, oldloc)
	if(isobserver(AM))
		return ..()

	if(target && (get_turf(oldloc) == get_turf(target)))
		return ..()

	if(!teleport(AM))
		return ..()

/obj/effect/portal/attack_tk(mob/user)
	return

/obj/effect/portal/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(get_turf(user) == get_turf(src))
		teleport(user)
	if(Adjacent(user))
		user.forceMove(get_turf(src))

/obj/effect/portal/attack_ghost(mob/dead/observer/O)
	if(target)
		O.forceMove(target)

/obj/effect/portal/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(can_multitool_to_remove)
		qdel(src)
	else
		user.forceMove(get_turf(src))

/obj/effect/portal/proc/can_teleport(atom/movable/M)
	. = TRUE

	if(!istype(M))
		. = FALSE

	if(!M.simulated || iseffect(M))
		. = FALSE

/obj/effect/portal/proc/teleport(atom/movable/M)
	if(!can_teleport(M))
		return FALSE

	if(!target)
		qdel(src)
		return FALSE

	if(ismegafauna(M))
		var/creator_string = ""
		var/obj_name = creation_obj_data[2]
		if(creation_mob_ckey)
			creator_string = " created by [key_name_admin(GLOB.directory[creation_mob_ckey])][obj_name ? " using \a [obj_name]" : ""]"
		else if(obj_name)
			creator_string = " created by \a [obj_name]"
		message_admins("[M] has used a portal at [ADMIN_VERBOSEJMP(src)][creator_string].")

	if(prob(failchance))
		icon_state = fail_icon
		var/list/target_z = levels_by_trait(SPAWN_RUINS)
		target_z -= M.z
		if(!attempt_teleport(M, locate(rand(5, world.maxx - 5), rand(5, world.maxy -5), pick(target_z)), 0, FALSE)) // Try to send them to deep space.
			return FALSE
	else
		if(!attempt_teleport(M, target, precision)) // Try to send them to a turf adjacent to target.
			return FALSE
	if(one_use)
		qdel(src)

	return TRUE

/obj/effect/portal/proc/attempt_teleport(atom/movable/victim, turf/destination, variance = 0, force_teleport = TRUE)
	var/use_effects = world.time >= effect_cooldown
	var/effect = null // Will result in the default effect being used
	if(!use_effects)
		effect = NONE // No effect

	if(!do_teleport(victim, destination, variance, force_teleport, effect, effect, bypass_area_flag = ignore_tele_proof_area_setting))
		invalid_teleport()
		return FALSE
	effect_cooldown = world.time + EFFECT_COOLDOWN
	return TRUE

/obj/effect/portal/proc/invalid_teleport()
	visible_message("<span class='warning'>[src] flickers and fails due to bluespace interference!</span>")
	do_sparks(5, 0, loc)
	qdel(src)

/obj/effect/portal/redspace
	name = "redspace portal"
	desc = "A portal capable of bypassing bluespace interference."
	icon_state = "portal1"
	failchance = 0
	precision = 0
	ignore_tele_proof_area_setting = TRUE

/obj/effect/portal/redspace/lap_2
	name = "Lap 2 portal"
	desc = "A syndicate portal, bribing spacemen with the best thing: Greed and prestige."

/obj/effect/portal/redspace/lap_2/New(loc, turf/_target, obj/creation_object, lifespan, mob/creation_mob)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(generate_target), 2 SECONDS))

/obj/effect/portal/redspace/lap_2/can_teleport(atom/movable/A)
	generate_target()
	var/mob/living/M = A
	if(!istype(M))
		return FALSE
	if(GLOB.pizza_time == FALSE)
		to_chat(M, "<span class='warning'>Pizza time has not started, this should not exist!</span>")
		return FALSE
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(istype(H))
			var/obj/item/card/id/C = H.get_idcard(TRUE)
			var/datum/money_account/account = C.get_card_account()
			if(!C || !account)
				return FALSE
			var/datum/money_account_database/main_station/station_db = GLOB.station_money_database
			station_db.credit_account(account, 3000, "Lap 2 Challenge!", "Syndicate Bribes INC", FALSE)
			if(account.account_type == ACCOUNT_TYPE_PERSONAL)
				if(LAZYLEN(account.associated_nanobank_programs))
					for(var/datum/data/pda/app/nanobank/program as anything in account.associated_nanobank_programs)
						program.announce_payday(3000)
			H.stop_sound_channel(CHANNEL_ADMIN)
			var/sound/music = sound('sound/music/lap_2_please_dont_sue.ogg', channel = CHANNEL_ADMIN) //1 version, plays till round end, no syncing needed
			music.volume = 100 * H.client.prefs.get_channel_volume(CHANNEL_ADMIN)
			SEND_SOUND(H, music)
			addtimer(CALLBACK(src, PROC_REF(easy_anti_cheat), H, 3 SECONDS))
		else
			return FALSE
	return TRUE

/obj/effect/portal/redspace/lap_2/proc/generate_target() //temp
	var/target_turf
	for(var/tries in 0 to 10)
		var/list/candidate_turfs = get_area_turfs(/area/hallway/secondary/exit)
		while(length(candidate_turfs))
			var/turf/candidate = pick_n_take(candidate_turfs)
			if(!is_blocked_turf(candidate,TRUE))
				target_turf = candidate
				break
		if(target_turf)
			break
	if(!target_turf)
		CRASH("Unable to dunk someone into escape for lap 2")
	target = target_turf

/obj/effect/portal/redspace/lap_2/proc/easy_anti_cheat(mob/living/carbon/human/H)
	H.apply_status_effect(STATUS_EFFECT_LAP_2)
	to_chat(H, "<span class='colossus'>Entering space or teleporting WILL KILL YOU. Good luck!</span>")

/obj/effect/landmark/spawner/lap2 //If someone actually wants this this will get an icon
	name = "lap2spawn"
	icon_state = "Rev"


#undef EFFECT_COOLDOWN
