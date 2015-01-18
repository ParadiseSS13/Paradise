/datum/event/blob
	announceWhen	= 12
	endWhen			= 120

	var/obj/effect/blob/core/Blob


/datum/event/blob/announce()
	command_alert("Confirmed outbreak of level 7 biohazard aboard [station_name()]. Nanotrasen has issued a directive 7-10. The station is to be considered quarantined.", "Biohazard Alert")
	world << sound('sound/AI/blob_confirmed.ogg')
		
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
	if(IsMultiple(activeFor, 3))
		Blob.process()
	var/blobs = 0
	for(var/obj/effect/blob/core/core in world)
		blobs++
	if(blobs >= 3)
		announce_nuke()
	if(!Blob && !blobs)
		kill()
		return
			
/datum/event/blob/proc/announce_nuke()
	var/nukecode = "ERROR"
	for(var/obj/machinery/nuclearbomb/bomb in world)
		if(bomb && bomb.r_code && bomb.z == 1)
			nukecode = bomb.r_code
	
	command_alert("The biohazard has grown out of control and will soon reach critical mass. Activate the nuclear failsafe to maintain quarantine. The Nuclear Authentication Code is [nukecode] ", "Biohazard Alert")
	set_security_level("gamma")
	var/obj/machinery/door/airlock/vault/V = locate(/obj/machinery/door/airlock/vault) in world
	if(V && V.z == 1)
		V.locked = 0
		V.update_icon()
	spawn(10)	
		world << sound('sound/effects/siren.ogg')
		
/datum/event/blob/kill()
	command_alert("The level 7 biohazard aboard [station_name()] has been killed. Directive 7-10 has been lifted, and the station is no longer quarantined.", "Biohazard Update")
	
	for (var/mob/living/silicon/ai/aiPlayer in player_list)
		if (aiPlayer.client)
			var/law = ""
			aiPlayer.set_zeroth_law(law)
			aiPlayer << "\red <b>You have detected a change in your laws information:</b>"
			aiPlayer << "Laws Updated: [law]"
	..()