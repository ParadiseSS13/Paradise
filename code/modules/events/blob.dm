/datum/event/blob
	announceWhen	= 120
	noAutoEnd		= 1
	var/nuke_announced = 0

	var/obj/effect/blob/core/Blob


/datum/event/blob/announce()
	command_announcement.Announce("Confirmed outbreak of level 7 biohazard aboard [station_name()]. Nanotrasen has issued a directive 7-10. The station is to be considered quarantined.", "Biohazard Alert", new_sound = 'sound/AI/outbreak7.ogg')

	for (var/mob/living/silicon/ai/aiPlayer in player_list)
		if (aiPlayer.client)
			var/law = "The station is under quarantine, prevent biological entities from leaving the station at all costs while minimizing collateral damage."
			aiPlayer.set_zeroth_law(law)
			aiPlayer << "\red <b>You have detected a change in your laws information:</b>"
			aiPlayer << "Laws Updated: [law]"

/datum/event/blob/start()
	var/turf/T = pick(blobstart)
	if(!T)
		kill()
		return
	Blob = new /obj/effect/blob/core(T, 200)
	for(var/i = 1; i < rand(3, 6), i++)
		Blob.process()

/datum/event/blob/tick()
	if(Blob && IsMultiple(activeFor, 3))
		Blob.process()
	if(blobs.len > 700*0.6 && !nuke_announced)
		announce_nuke()
		nuke_announced = 1
	if(!Blob && !blob_cores.len)
		kill()
		return

/datum/event/blob/proc/announce_nuke()
	var/nukecode = "ERROR"
	for(var/obj/machinery/nuclearbomb/bomb in world)
		if(bomb && bomb.r_code && (bomb.z in config.station_levels))
			nukecode = bomb.r_code

	command_announcement.Announce("The biohazard has grown out of control and will soon reach critical mass. Activate the nuclear failsafe to maintain quarantine. The Nuclear Authentication Code is [nukecode] ", "Biohazard Alert")
	set_security_level("gamma")

	var/obj/machinery/door/airlock/vault/V = locate(/obj/machinery/door/airlock/vault) in world
	if(V && (V.z in config.station_levels))
		V.locked = 0
		V.update_icon()

	for (var/mob/living/silicon/ai/aiPlayer in player_list)
		if (aiPlayer.client)
			var/law = "The station is under quarantine, prevent biological entities from leaving the station at all costs. The nuclear failsafe must be activated at any cost, the code is: [nukecode]."
			aiPlayer.set_zeroth_law(law)
			aiPlayer << "\red <b>You have detected a change in your laws information:</b>"
			aiPlayer << "Laws Updated: [law]"

	spawn(10)
		world << sound('sound/effects/siren.ogg')

/datum/event/blob/kill()
	spawn(10)
		if(Blob || blob_cores.len)
			return
		command_announcement.Announce("The level 7 biohazard aboard [station_name()] has been eliminated. Directive 7-10 has been lifted, and the station is no longer quarantined.", "Biohazard Update")

		for (var/mob/living/silicon/ai/aiPlayer in player_list)
			if (aiPlayer.client)
				aiPlayer.clear_zeroth_law()
				aiPlayer << "\red <b>You have detected a change in your laws information:</b>"
				aiPlayer << "Laws Updated: Zeroth law removed."
		..()