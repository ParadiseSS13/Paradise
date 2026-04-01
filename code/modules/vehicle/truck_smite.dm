/obj/effect/immovablerod/smite/truck
	icon = 'icons/tgmc/objects/64x64.dmi'
	icon_state = "truck"

/obj/effect/immovablerod/smite/truck/New(atom/_start, atom/_end)
	playsound(_end, 'sound/effects/truck_horn.mp3', 100, TRUE)
	return ..()

/obj/effect/immovablerod/smite/truck/clong(turf/victim)
	for(var/mob/living/carbon/human/soon_to_be_isekaied as anything in victim)
		clong_thing(soon_to_be_isekaied)
		playsound(src, 'sound/effects/explosion1.ogg', 100, TRUE)

/obj/effect/immovablerod/smite/truck/clong_thing(mob/living/carbon/human/victim)
	if(!istype(victim) || !victim.mind)
		return // Somehow
	var/mob/living/carbon/human/walker
	for(var/obj/effect/landmark/ashwalker/spawn_spot in GLOB.landmarks_list)
		walker = new /mob/living/carbon/human/ashwalker(get_turf(spawn_spot))
		break

	// Gotta be able to talk the indigenous languages!
	walker.grant_all_babel_languages()
	walker.ckey = victim.ckey
	victim.ckey = null

	// Absolutely randomly body improvements
	walker.dna.SetSEState(GLOB.jumpblock, TRUE)
	walker.dna.SetSEState(GLOB.teleblock, TRUE)
	singlemutcheck(walker, GLOB.jumpblock, MUTCHK_FORCED)
	singlemutcheck(walker, GLOB.teleblock, MUTCHK_FORCED)
	walker.update_mutations()
	walker.gene_stability = 100

	// Gotta know magic in your new life!
	walker.mind.AddSpell(new /datum/spell/fireball)

	to_chat(walker, SPAN_USERDANGER("Welcome to your new life in your isekai world!"))

/datum/event/isekai
	name =  "Isekai truck"
	role_weights = list(ASSIGNMENT_CREW = 1)
	role_requirements = list(ASSIGNMENT_CREW = 1)

/datum/event/isekai/start()
	var/mob/living/carbon/human/chosen_one
	for(var/mob/living/carbon/human/ouch in GLOB.player_list)
		chosen_one = ouch

	message_admins(chosen_one)
	var/starting_turf_x = chosen_one.x + rand(10, 15) * pick(1, -1)
	var/starting_turf_y = chosen_one.y + rand(10, 15) * pick(1, -1)
	var/turf/start = locate(starting_turf_x, starting_turf_y, chosen_one.z)
	new /obj/effect/immovablerod/smite/truck(start, chosen_one)
