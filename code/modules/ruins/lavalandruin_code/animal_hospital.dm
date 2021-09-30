/obj/item/paper/fluff/henderson_report
	name = "Important Notice - Mrs. Henderson"
	info = "Nothing of interest to report."

/obj/effect/mob_spawn/human/doctor/alive/lavaland
	name = "broken rejuvenation pod"
	desc = "A small sleeper typically used to instantly restore minor wounds. This one seems broken, and its occupant is comatose."
	mob_name = "a translocated vet"
	description = "You are an intern working in an animal hospital that suddenly got transported to lavaland. Good luck."
	flavour_text = "What...? Where are you? Where are the others? This is still the animal hospital - you should know, you've been an intern here for weeks - but \
	everyone's gone. One of the cats scratched you just a few minutes ago. That's why you were in the pod - to heal the scratch. The scabs are still fresh; you see them right now. So where is \
	everyone? Where did they go? What happened to the hospital? And is that smoke you smell? You need to find someone else. Maybe they can tell you what happened."
	assignedrole = "Translocated Vet"
	allow_species_pick = TRUE

/obj/effect/mob_spawn/human/doctor/alive/lavaland/Destroy()
	var/obj/structure/fluff/empty_sleeper/S = new(drop_location())
	S.setDir(dir)
	return ..()
