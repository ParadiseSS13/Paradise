/obj/item/weapon/antag_spawner
	throw_speed = 1
	throw_range = 5
	w_class = 1.0
	var/used = 0

/obj/item/weapon/antag_spawner/proc/spawn_antag(var/client/C, var/turf/T, var/type = "")
	return

/obj/item/weapon/antag_spawner/proc/equip_antag(mob/target as mob)
	return
	

/obj/item/weapon/antag_spawner/borg_tele
	name = "Syndicate Cyborg Teleporter"
	desc = "A single-use teleporter used to deploy a Syndicate Cyborg on the field."
	icon = 'icons/obj/device.dmi'
	icon_state = "locator"
	var/TC_cost = 0
	var/checking = 0

/obj/item/weapon/antag_spawner/borg_tele/attack_self(mob/user as mob)
	if(used)
		user << "The teleporter is out of power."
		return
	if(!checking)
		checking = 1
		user << "<span class='notice'>The device is now checking for possible candidates.</span>"
		get_candidate_answer(user, get_candidates(BE_OPERATIVE))
	else
		user << "<span class='notice'>The device is already checking for possible candidates.</span>"
		return

/obj/item/weapon/antag_spawner/borg_tele/proc/get_candidate_answer(mob/user as mob, var/list/possiblecandidates = list())
	var/time_passed = world.time
	if(possiblecandidates.len <= 0)
		checking = 0
		user << "<span class='notice'>Unable to connect to Syndicate Command. Please wait and try again later or use the teleporter on your uplink to get your points refunded.</span>"
		return
	else
		var/possibleborg = pick(possiblecandidates)
		spawn(0)
			var/input = alert(possibleborg,"Do you want to spawn in as a cyborg for the Syndicate operatives?","Please answer in thirty seconds!","Yes","No")
			if(input == "Yes" && used == 0)
				if((world.time-time_passed)>300)
					return
				possiblecandidates -= possibleborg
				used = 1
				checking = 0
				spawn_antag(possibleborg, get_turf(src.loc), "syndieborg")
			else
				possiblecandidates -= possibleborg		
				get_candidate_answer(user, possiblecandidates)
				return
				
		sleep(300)
		if(checking)
			possiblecandidates -= possibleborg	
			get_candidate_answer(user, possiblecandidates)
			return				
			

/obj/item/weapon/antag_spawner/borg_tele/spawn_antag(var/client/C, var/turf/T, var/type = "")
	var/datum/effect/effect/system/spark_spread/S = new /datum/effect/effect/system/spark_spread
	S.set_up(4, 1, src)
	S.start()
	var/mob/living/silicon/robot/R = new /mob/living/silicon/robot/syndicate(T)
	R.key = C.key
	ticker.mode.syndicates += R.mind
	ticker.mode.update_synd_icons_added(R.mind)
	R.mind.special_role = "syndicate"
	R.faction = list("syndicate")
