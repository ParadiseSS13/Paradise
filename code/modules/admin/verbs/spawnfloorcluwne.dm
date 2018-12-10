/client/proc/spawn_floor_cluwne()
	set category = "Event"
	set name = "Unleash Floor Cluwne"
	set desc = "Pick a specific target or just let it select randomly and spawn the floor cluwne mob on the station. Be warned: spawning more than one may cause issues!"
	var/target

	if(!check_rights(R_EVENT))
		return

	var/confirm = alert("Are you sure you want to release a floor cluwne and kill alot of people?", "Confirm Massacre", "Yes", "No")
	if(confirm == "Yes")

		var/turf/T = get_turf(usr)
		target = input("Any specific target in mind? Please note only live, non cluwned, human targets are valid.", "Target", target) as null|anything in GLOB.player_list
		if(isnull(target))
			return
		if(target && ishuman(target))
			var/mob/living/carbon/human/H = target
			var/mob/living/simple_animal/hostile/floor_cluwne/FC = new /mob/living/simple_animal/hostile/floor_cluwne(T)
			FC.Acquire_Victim(H)
		else
			new /mob/living/simple_animal/hostile/floor_cluwne(T)
		log_admin("[key_name(usr)] spawned floor cluwne.")
		message_admins("[key_name(usr)] spawned floor cluwne.")
	else
		return
