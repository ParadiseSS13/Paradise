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

/obj/item/weapon/antag_spawner/slaughter_demon //Warning edgiest item in the game
	name = "vial of blood"
	desc = "A magically infused bottle of blood, distilled from countless murder victims. Used in unholy rituals to attract horrifying creatures."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"
	var/checking = 0


/obj/item/weapon/antag_spawner/slaughter_demon/attack_self(mob/user as mob)
	//var/list/demon_candidates = get_candidates(BE_ALIEN)
	if(user.z != 1)
		user << "<span class='notice'>You should probably wait until you reach the station.</span>"
		return
	if(!checking)
		user << "<span class='notice'>You ready yourself to shatter the bottle...</span>"
		get_candidate_answer(user, get_candidates(BE_ALIEN))
	else
		user << "<span class='notice'>You are already thinking about shattering the bottle.</span>"
		return


/obj/item/weapon/antag_spawner/slaughter_demon/proc/get_candidate_answer(mob/user as mob, var/list/possiblecandidates = list())
	var/time_passed = world.time
	if(possiblecandidates.len <= 0)
		checking = 0
		user << "<span class='notice'>You can't seem to work up the nerve to shatter the bottle. Perhaps you should try again later..</span>"
		return
	else
		var/demon_candidates = pick(possiblecandidates)
		spawn(0)
			var/input = alert(demon_candidates,"Do you want to spawn in as a Slaughter Demon?","Please answer in thirty seconds!","Yes","No")
			if(input == "Yes" && used == 0)
				if((world.time-time_passed)>300)
					return
				possiblecandidates -= demon_candidates
				used = 1
				checking = 0
				spawn_antag(demon_candidates, get_turf(src.loc), "Slaughter Demon")
				user << "<span class='notice'>You shatter the bottle, no turning back now!</span>"
				user << "<span class='notice'>You sense a dark presence lurking just beyond the veil...</span>"
				playsound(user.loc, 'sound/effects/Glassbr1.ogg', 100, 1)
				playsound(user.loc,'sound/hallucinations/im_here1.ogg', 50, -1)//Paradise Port:THIS IS OVERKILL -AB
				qdel(src)
			else
				possiblecandidates -= demon_candidates
				get_candidate_answer(user, possiblecandidates)
				return

		sleep(300)
		if(checking)
			possiblecandidates -= demon_candidates
			get_candidate_answer(user, possiblecandidates)
			return


/obj/item/weapon/antag_spawner/slaughter_demon/spawn_antag(var/client/C, var/turf/T, var/type = "")

	var /obj/effect/dummy/slaughter/holder = new /obj/effect/dummy/slaughter(T)
	var/mob/living/simple_animal/slaughter/S = new /mob/living/simple_animal/slaughter/(holder)
	S.vialspawned = TRUE
	S.phased = TRUE
	S.key = C.key
	S.mind.assigned_role = "Slaughter Demon"
	S.mind.special_role = "Slaughter Demon"
	ticker.mode.traitors += S.mind
	var/datum/objective/assassinate/KillDaWiz = new /datum/objective/assassinate
	KillDaWiz.owner = S:mind
	KillDaWiz:target = usr:mind
	KillDaWiz.explanation_text = "Kill [usr.real_name], the one who was foolish enough to summon you."
	S.mind.objectives += KillDaWiz
	var/datum/objective/slaughter/objective = new
	objective.owner = S:mind
	//Paradise port:i changed ther verbage..might want to do so on the above kill objective. Maybe save the wizard for last...
	S.mind.objectives += objective
	S << "<B>Objective #[1]</B>: [KillDaWiz.explanation_text]"
	S << "<B>Objective #[2]</B>: [objective.explanation_text]"