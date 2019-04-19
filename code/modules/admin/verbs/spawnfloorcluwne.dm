/client/proc/spawn_floor_cluwne()
	set category = "Event"
	set name = "Unleash Floor Cluwne"
	set desc = "Pick a specific target or just let it select randomly and spawn the floor cluwne mob on the station. Be warned: spawning more than one may cause issues!"
	var/mob/living/carbon/human/target

	if(!check_rights(R_EVENT))
		return

	var/confirm = alert("Are you sure you want to release a floor cluwne and kill a lot of people?", "Confirm Massacre", "Yes", "No")
	if(confirm == "Yes")

		var/turf/T = get_turf(usr)
		var/list/potential_targets = list()
		for(var/mob/M in GLOB.player_list)
			var/mob/living/carbon/human/H = M
			if(!istype(H))
				continue
			if(H.mind.assigned_role == "Cluwne")
				continue
			potential_targets += H
		if(!potential_targets.len) //You're probably the only player on this damn station, spawn it yourself
			to_chat(src, "<span class='notice'>No valid targets!</span>")
			return
		target = input("Any specific target in mind? Please note only live, non cluwned, human targets are valid.", "Target", target) as null|anything in potential_targets
		var/mob/living/simple_animal/hostile/floor_cluwne/FC = new /mob/living/simple_animal/hostile/floor_cluwne(T)
		if(target)
			FC.Acquire_Victim(target)
		log_admin("[key_name(usr)] spawned floor cluwne[target ? ", initially targetting [target]": null].")
		message_admins("[key_name(usr)] spawned floor cluwne[target ? ", initially targetting [target]": null].")
