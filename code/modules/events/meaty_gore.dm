#define NEED_PLAYERS 40

/datum/event/meteor_wave/gore/announce()
		GLOB.minor_announcement.Announce("Unknown biological debris have been detected near [station_name()], please stand-by.", "Debris Alert")

/datum/event/meteor_wave/gore/setup()
	waves = 3

/datum/event/meteor_wave/gore/get_meteor_count()
	return rand(5, 8)

/datum/event/meteor_wave/gore/get_meteors()
	return GLOB.meteors_gore

/datum/event/meteor_wave/gore/end()
	GLOB.minor_announcement.Announce("The station has cleared the debris.", "Debris Alert")

	/***************************************\
	|*********Stowaway Changelings***********|
	\***************************************/

/datum/event/meteor_wave/gore/ling
	var/changelings_amount
	var/list/candidates

	var/spawncount

/datum/event/meteor_wave/gore/ling/announce()
	return //TSS SECRET

/datum/event/meteor_wave/gore/ling/setup()
	changelings_amount = round(TGS_CLIENT_COUNT / 40) //120 players for 3 changelings
	if(changelings_amount < 1 /*&& TGS_CLIENT_COUNT >= NEED_PLAYERS*/)
		changelings_amount = 1
	spawncount = changelings_amount

	var/image/img = image('icons/mob/actions/actions.dmi', "chameleon_outfit")
	candidates = SSghost_spawns.poll_candidates("Do you want to play as a Stowaway Changeling?", ROLE_CHANGELING, TRUE, source = img, poll_time = 40 SECONDS)

	if(!length(candidates) /*|| TGS_CLIENT_COUNT < NEED_PLAYERS*/ || GAMEMODE_IS_CULT || GAMEMODE_IS_NUCLEAR || GAMEMODE_IS_REVOLUTION) //i just love idea of gamemodes combination, but boring contributors (and some balancers guys) says no...
		message_admins("Stowaway Changelings had no volunteers or gamemode is not valid or is too few clients ([TGS_CLIENT_COUNT]) and was canceled.")
		log_admin("Stowaway Changelings had no volunteers or gamemode is not valid or is too few clients ([TGS_CLIENT_COUNT]) and was canceled.")
		//just imagine... CULTIST CHANGELING... NUKIES AND CHANGELINGS... REVOLUTION CHANGELING... eh... SHADOWLING THRALL (yep they're deleted) CHANGELING MUHAHAHAHAHHAHA
		var/datum/event_container/EC = SSevents.event_containers[EVENT_LEVEL_MODERATE] //no lings? okay, go and get compensation!
		EC.next_event_time = world.time + (60 * 10)
		return kill()

	waves = rand(1,2)

	message_admins("Candidates [length(candidates)]")
	INVOKE_ASYNC(src, PROC_REF(wrap_end))

/datum/event/meteor_wave/gore/ling/get_meteor_count()
	return rand(2, 4)

/datum/event/meteor_wave/gore/ling/get_meteors()
	return GLOB.meteors_gore

/datum/event/meteor_wave/gore/ling/end()
	for(var/mob/M in GLOB.dead_mob_list)
		M.clear_alert("\ref[src]_augury")
	QDEL_NULL(screen_alert)
	//seeeeeeecret

/datum/event/meteor_wave/gore/ling/proc/wrap_end()
	var/spawncounter = changelings_amount
	while(spawncounter)
		spawn_meteor(list(/obj/effect/meteor/meaty/ling), pick_n_take(candidates))
		spawncounter--

	//true end
