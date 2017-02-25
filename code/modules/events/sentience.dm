/datum/round_event_control/sentience
	name = "Sentience"
	typepath = /datum/round_event/ghost_role/sentience
	weight = 5

/datum/round_event/ghost_role/sentience
	minimum_required = 1
	role_name = "random animal"

/datum/round_event/ghost_role/sentience/spawn_role()
	var/list/mob/dead/observer/candidates
	candidates = get_candidates(ROLE_SENTIENT, null, ROLE_SENTIENT)

	// find our chosen mob to breathe life into
	// Mobs have to be simple animals, mindless and on station
	var/list/potential = list()
	for(var/mob/living/simple_animal/L in living_mob_list)
		var/turf/T = get_turf(L)
		if(T.z != ZLEVEL_STATION)
			continue
		if(!(L in player_list) && !L.mind)
			potential += L

	var/mob/living/simple_animal/SA = pick(potential)
	var/mob/dead/observer/SG = pick(candidates)

	if(!SA || !SG)
		return FALSE

	SA.key = SG.key
	SA.languages_spoken |= HUMAN
	SA.languages_understood |= HUMAN
	SA.sentience_act()

	SA.maxHealth = min(SA.maxHealth, 200)
	SA.health = SA.maxHealth
	SA.del_on_death = FALSE

	SA << "<span class='warning'>Due to freak radiation and/or chemicals \
		and/or lucky chance, you have gained sentience!</span>"
	SA << "<span class='userdanger'>Hello world! What you do with your free \
		will is up to you.</span>"
