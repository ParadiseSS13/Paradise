/datum/event/tear/honk
	name = "honkmensional tear"
	notify_title = "Honkmensional Tear"
	notify_image = "clowngoblin"
	var/obj/effect/tear/honk/HE

/datum/event/tear/honk/spawn_tear(location)
	HE = new /obj/effect/tear/honk(location)

/datum/event/tear/honk/announce(false_alarm)
	var/area/target_area = impact_area
	if(!target_area)
		if(false_alarm)
			target_area = findEventArea()
			if(isnull(target_area))
				log_debug("Tried to announce a false-alarm honk tear without a valid area!")
				kill()
		else
			log_debug("Tried to announce a honk tear without a valid area!")
			kill()
			return
	GLOB.minor_announcement.Announce("A Honknomoly has opened. Expected location: [target_area.name].", "Honknomoly Alert", 'sound/items/airhorn.ogg')

/datum/event/tear/honk/end()
	if(HE)
		qdel(HE)

/obj/effect/tear/honk
	name = "honkmensional tear"
	desc = "A tear in the dimensional fabric of sanity."
	leader = /mob/living/basic/clown/goblin/cluwne
	possible_mobs = list(
		/mob/living/basic/clown,
		/mob/living/basic/clown/goblin
	)
