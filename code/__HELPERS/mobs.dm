proc/GetOppositeDir(var/dir)
	switch(dir)
		if(NORTH)     return SOUTH
		if(SOUTH)     return NORTH
		if(EAST)      return WEST
		if(WEST)      return EAST
		if(SOUTHWEST) return NORTHEAST
		if(NORTHWEST) return SOUTHEAST
		if(NORTHEAST) return SOUTHWEST
		if(SOUTHEAST) return NORTHWEST
	return 0

proc/random_underwear(gender, species = "Human")
	var/list/pick_list = list()
	switch(gender)
		if(MALE)	pick_list = underwear_m
		if(FEMALE)	pick_list = underwear_f
		else		pick_list = underwear_list
	return pick_species_allowed_underwear(pick_list, species)

proc/random_undershirt(gender, species = "Human")
	var/list/pick_list = list()
	switch(gender)
		if(MALE)	pick_list = undershirt_m
		if(FEMALE)	pick_list = undershirt_f
		else		pick_list = undershirt_list
	return pick_species_allowed_underwear(pick_list, species)

proc/random_socks(gender, species = "Human")
	var/list/pick_list = list()
	switch(gender)
		if(MALE)	pick_list = socks_m
		if(FEMALE)	pick_list = socks_f
		else		pick_list = socks_list
	return pick_species_allowed_underwear(pick_list, species)

proc/pick_species_allowed_underwear(list/all_picks, species)
	var/list/valid_picks = list()
	for(var/test in all_picks)
		var/datum/sprite_accessory/S = all_picks[test]
		if(!(species in S.species_allowed))
			continue
		valid_picks += test

	if(!valid_picks.len) valid_picks += "Nude"

	return pick(valid_picks)

proc/random_hair_style(var/gender, species = "Human", var/datum/robolimb/robohead)
	var/h_style = "Bald"
	var/list/valid_hairstyles = list()
	for(var/hairstyle in hair_styles_list)
		var/datum/sprite_accessory/S = hair_styles_list[hairstyle]

		if(hairstyle == "Bald") //Just in case.
			valid_hairstyles += hairstyle
			continue
		if((gender == MALE && S.gender == FEMALE) || (gender == FEMALE && S.gender == MALE))
			continue
		if(species == "Machine") //If the user is a species who can have a robotic head...
			if(!robohead)
				robohead = all_robolimbs["Morpheus Cyberkinetics"]
			if((species in S.species_allowed) && robohead.is_monitor && ((S.models_allowed && (robohead.company in S.models_allowed)) || !S.models_allowed)) //If this is a hair style native to the user's species, check to see if they have a head with an ipc-style screen and that the head's company is in the screen style's allowed models list.
				valid_hairstyles += hairstyle //Give them their hairstyles if they do.
			else
				if(!robohead.is_monitor && ("Human" in S.species_allowed)) /*If the hairstyle is not native to the user's species and they're using a head with an ipc-style screen, don't let them access it.
																			But if the user has a robotic humanoid head and the hairstyle can fit humans, let them use it as a wig. */
					valid_hairstyles += hairstyle
		else //If the user is not a species who can have robotic heads, use the default handling.
			if(species in S.species_allowed) //If the user's head is of a species the hairstyle allows, add it to the list.
				valid_hairstyles += hairstyle

	if(valid_hairstyles.len)
		h_style = pick(valid_hairstyles)

	return h_style

proc/random_facial_hair_style(var/gender, species = "Human", var/datum/robolimb/robohead)
	var/f_style = "Shaved"
	var/list/valid_facial_hairstyles = list()
	for(var/facialhairstyle in facial_hair_styles_list)
		var/datum/sprite_accessory/S = facial_hair_styles_list[facialhairstyle]

		if(facialhairstyle == "Shaved") //Just in case.
			valid_facial_hairstyles += facialhairstyle
			continue
		if((gender == MALE && S.gender == FEMALE) || (gender == FEMALE && S.gender == MALE))
			continue
		if(species == "Machine") //If the user is a species who can have a robotic head...
			if(!robohead)
				robohead = all_robolimbs["Morpheus Cyberkinetics"]
			if((species in S.species_allowed) && robohead.is_monitor && ((S.models_allowed && (robohead.company in S.models_allowed)) || !S.models_allowed)) //If this is a facial hair style native to the user's species, check to see if they have a head with an ipc-style screen and that the head's company is in the screen style's allowed models list.
				valid_facial_hairstyles += facialhairstyle //Give them their facial hairstyles if they do.
			else
				if(!robohead.is_monitor && ("Human" in S.species_allowed)) /*If the facial hairstyle is not native to the user's species and they're using a head with an ipc-style screen, don't let them access it.
																			But if the user has a robotic humanoid head and the facial hairstyle can fit humans, let them use it as a wig. */
					valid_facial_hairstyles += facialhairstyle
		else //If the user is not a species who can have robotic heads, use the default handling.
			if(species in S.species_allowed) //If the user's head is of a species the facial hair style allows, add it to the list.
				valid_facial_hairstyles += facialhairstyle

	if(valid_facial_hairstyles.len)
		f_style = pick(valid_facial_hairstyles)

	return f_style

proc/random_head_accessory(species = "Human")
	var/ha_style = "None"
	var/list/valid_head_accessories = list()
	for(var/head_accessory in head_accessory_styles_list)
		var/datum/sprite_accessory/S = head_accessory_styles_list[head_accessory]

		if(!(species in S.species_allowed))
			continue
		valid_head_accessories += head_accessory

	if(valid_head_accessories.len)
		ha_style = pick(valid_head_accessories)

	return ha_style

proc/random_marking_style(var/location = "body", species = "Human", var/datum/robolimb/robohead, var/body_accessory, var/alt_head)
	var/m_style = "None"
	var/list/valid_markings = list()
	for(var/marking in marking_styles_list)
		var/datum/sprite_accessory/body_markings/S = marking_styles_list[marking]
		if(S.name == "None")
			valid_markings += marking
			continue
		if(S.marking_location != location) //If the marking isn't for the location we desire, skip.
			continue
		if(!(species in S.species_allowed)) //If the user's head is not of a species the marking style allows, skip it. Otherwise, add it to the list.
			continue
		if(location == "tail")
			if(!body_accessory)
				if(S.tails_allowed)
					continue
			else
				if(!S.tails_allowed || !(body_accessory in S.tails_allowed))
					continue
		if(location == "head")
			var/datum/sprite_accessory/body_markings/head/M = marking_styles_list[S.name]
			if(species == "Machine")//If the user is a species that can have a robotic head...
				if(!robohead)
					robohead = all_robolimbs["Morpheus Cyberkinetics"]
				if(!(S.models_allowed && (robohead.company in S.models_allowed))) //Make sure they don't get markings incompatible with their head.
					continue
			else if(alt_head && alt_head != "None") //If the user's got an alt head, validate markings for that head.
				if(!("All" in M.heads_allowed) && !(alt_head in M.heads_allowed))
					continue
			else
				if(M.heads_allowed && !("All" in M.heads_allowed))
					continue
		valid_markings += marking

	if(valid_markings.len)
		m_style = pick(valid_markings)

	return m_style

proc/random_body_accessory(species = "Vulpkanin")
	var/body_accessory = null
	var/list/valid_body_accessories = list()
	for(var/B in body_accessory_by_name)
		var/datum/body_accessory/A = body_accessory_by_name[B]
		if(!istype(A))
			valid_body_accessories += "None" //The only null entry should be the "None" option.
			continue
		if(species in A.allowed_species) //If the user is not of a species the body accessory style allows, skip it. Otherwise, add it to the list.
			valid_body_accessories += B

	if(valid_body_accessories.len)
		body_accessory = pick(valid_body_accessories)

	return body_accessory

proc/random_name(gender, species = "Human")

	var/datum/species/current_species
	if(species)
		current_species = all_species[species]

	if(!current_species || current_species.name == "Human")
		if(gender==FEMALE)
			return capitalize(pick(first_names_female)) + " " + capitalize(pick(last_names))
		else
			return capitalize(pick(first_names_male)) + " " + capitalize(pick(last_names))
	else
		return current_species.get_random_name(gender)

proc/random_skin_tone(species = "Human")
	if(species == "Human" || species == "Drask")
		switch(pick(60;"caucasian", 15;"afroamerican", 10;"african", 10;"latino", 5;"albino"))
			if("caucasian")		. = -10
			if("afroamerican")	. = -115
			if("african")		. = -165
			if("latino")		. = -55
			if("albino")		. = 34
			else				. = rand(-185, 34)
		return min(max(. + rand(-25, 25), -185), 34)
	else if(species == "Vox")
		. = rand(1, 6)
		return .

proc/skintone2racedescription(tone, species = "Human")
	if(species == "Human")
		switch(tone)
			if(30 to INFINITY)		return "albino"
			if(20 to 30)			return "pale"
			if(5 to 15)				return "light skinned"
			if(-10 to 5)			return "white"
			if(-25 to -10)			return "tan"
			if(-45 to -25)			return "darker skinned"
			if(-65 to -45)			return "brown"
			if(-INFINITY to -65)	return "black"
			else					return "unknown"
	else if(species == "Vox")
		switch(tone)
			if(2)					return "dark green"
			if(3)					return "brown"
			if(4)					return "gray"
			if(5)					return "emerald"
			if(6)					return "azure"
			else					return "green"
	else
		return "unknown"

proc/age2agedescription(age)
	switch(age)
		if(0 to 1)			return "infant"
		if(1 to 3)			return "toddler"
		if(3 to 13)			return "child"
		if(13 to 19)		return "teenager"
		if(19 to 30)		return "young adult"
		if(30 to 45)		return "adult"
		if(45 to 60)		return "middle-aged"
		if(60 to 70)		return "aging"
		if(70 to INFINITY)	return "elderly"
		else				return "unknown"


/*
Proc for attack log creation, because really why not
1 argument is the actor
2 argument is the target of action
3 is the description of action(like punched, throwed, or any other verb)
4 is the tool with which the action was made(usually item)
5 is additional information, anything that needs to be added
6 is whether the attack should be logged to the log file and shown to admins
*/

/proc/add_logs(mob/user, mob/target, what_done, var/object=null, var/addition=null, var/admin=1)
	var/list/ignore=list("shaked","CPRed","grabbed","punched")
	if(!user)
		return
	if(ismob(user))
		user.store_log("\[[time_stamp()]\] <font color='red'>Has [what_done] [key_name(target)][object ? " with [object]" : " "][addition]</font>")
	if(ismob(target))
		target.store_log("\[[time_stamp()]\] <font color='orange'>Has been [what_done] by [key_name(user)][object ? " with [object]" : " "][addition]</font>")
	if(admin)
		log_attack("<font color='red'>[key_name(user)] [what_done] [key_name(target)][object ? " with [object]" : " "][addition]</font>")
	if(istype(target) && (target.client || target.player_logged))
		if(what_done in ignore) return
		if(target == user) return
		if(!admin) return
		msg_admin_attack("[key_name_admin(user)] [what_done] [key_name_admin(target)][object ? " with [object]" : " "][addition]")

/proc/do_mob(var/mob/user, var/mob/target, var/time = 30, var/uninterruptible = 0, progress = 1)
	if(!user || !target)
		return 0
	var/user_loc = user.loc

	var/drifting = 0
	if(!user.Process_Spacemove(0) && user.inertia_dir)
		drifting = 1

	var/target_loc = target.loc

	var/holding = user.get_active_hand()
	var/datum/progressbar/progbar
	if(progress)
		progbar = new(user, time, target)

	var/endtime = world.time+time
	var/starttime = world.time
	. = 1
	while(world.time < endtime)
		sleep(1)
		if(progress)
			progbar.update(world.time - starttime)
		if(!user || !target)
			. = 0
			break
		if(uninterruptible)
			continue

		if(drifting && !user.inertia_dir)
			drifting = 0
			user_loc = user.loc

		if((!drifting && user.loc != user_loc) || target.loc != target_loc || user.get_active_hand() != holding || user.incapacitated() || user.lying )
			. = 0
			break
	if(progress)
		qdel(progbar)

/proc/do_after(mob/living/user, delay, needhand = 1, atom/target = null, progress = 1)
	if(!user)
		return 0
	var/atom/Tloc = null
	if(target)
		Tloc = target.loc

	var/atom/Uloc = user.loc

	var/drifting = 0
	if(!user.Process_Spacemove(0) && user.inertia_dir)
		drifting = 1

	var/holding = user.get_active_hand()

	var/holdingnull = 1 //User's hand started out empty, check for an empty hand
	if(holding)
		holdingnull = 0 //Users hand started holding something, check to see if it's still holding that

	var/datum/progressbar/progbar
	if(progress)
		progbar = new(user, delay, target)

	var/endtime = world.time + delay
	var/starttime = world.time
	. = 1
	while(world.time < endtime)
		sleep(1)
		if(progress)
			progbar.update(world.time - starttime)

		if(drifting && !user.inertia_dir)
			drifting = 0
			Uloc = user.loc

		if(!user || user.incapacitated(ignore_restraints = 1, ignore_grab = 1, ignore_lying = 1) || (!drifting && user.loc != Uloc))
			. = 0
			break

		if(Tloc && (!target || Tloc != target.loc))
			. = 0
			break

		if(needhand)
			//This might seem like an odd check, but you can still need a hand even when it's empty
			//i.e the hand is used to pull some item/tool out of the construction
			if(!holdingnull)
				if(!holding)
					. = 0
					break
			if(user.get_active_hand() != holding)
				. = 0
				break
	if(progress)
		qdel(progbar)

/proc/admin_mob_info(mob/M, mob/user = usr)
	if(!ismob(M))
		to_chat(user, "This can only be used on instances of type /mob")
		return

	var/location_description = ""
	var/special_role_description = ""
	var/health_description = ""
	var/gender_description = ""
	var/turf/T = get_turf(M)

	//Location
	if(isturf(T))
		if(isarea(T.loc))
			location_description = "([M.loc == T ? "at coordinates " : "in [M.loc] at coordinates "] [T.x], [T.y], [T.z] in area <b>[T.loc]</b>)"
		else
			location_description = "([M.loc == T ? "at coordinates " : "in [M.loc] at coordinates "] [T.x], [T.y], [T.z])"

	//Job + antagonist
	if(M.mind)
		special_role_description = "Role: <b>[M.mind.assigned_role]</b>; Antagonist: <font color='red'><b>[M.mind.special_role]</b></font>; Has been rev: [(M.mind.has_been_rev)?"Yes":"No"]"
	else
		special_role_description = "Role: <i>Mind datum missing</i> Antagonist: <i>Mind datum missing</i>; Has been rev: <i>Mind datum missing</i>;"

	//Health
	if(isliving(M))
		var/mob/living/L = M
		var/status
		switch(M.stat)
			if(CONSCIOUS)
				status = "Alive"
			if(UNCONSCIOUS)
				status = "<font color='orange'><b>Unconscious</b></font>"
			if(DEAD)
				status = "<font color='red'><b>Dead</b></font>"
		health_description = "Status = [status]"
		health_description += "<BR>Oxy: [L.getOxyLoss()] - Tox: [L.getToxLoss()] - Fire: [L.getFireLoss()] - Brute: [L.getBruteLoss()] - Clone: [L.getCloneLoss()] - Brain: [L.getBrainLoss()]"
	else
		health_description = "This mob type has no health to speak of."

	//Gener
	switch(M.gender)
		if(MALE, FEMALE)
			gender_description = "[M.gender]"
		else
			gender_description = "<font color='red'><b>[M.gender]</b></font>"

	to_chat(user, "<b>Info about [M.name]:</b> ")
	to_chat(user, "Mob type = [M.type]; Gender = [gender_description] Damage = [health_description]")
	to_chat(user, "Name = <b>[M.name]</b>; Real_name = [M.real_name]; Mind_name = [M.mind?"[M.mind.name]":""]; Key = <b>[M.key]</b>;")
	to_chat(user, "Location = [location_description];")
	to_chat(user, "[special_role_description]")
	to_chat(user, "(<a href='?src=[usr.UID()];priv_msg=\ref[M]'>PM</a>) (<A HREF='?_src_=holder;adminplayeropts=\ref[M]'>PP</A>) (<A HREF='?_src_=vars;Vars=[M.UID()]'>VV</A>) (<A HREF='?_src_=holder;subtlemessage=\ref[M]'>SM</A>) (<A HREF='?_src_=holder;adminplayerobservefollow=\ref[M]'>FLW</A>) (<A HREF='?_src_=holder;secretsadmin=check_antagonist'>CA</A>)")

// Gets the first mob contained in an atom, and warns the user if there's not exactly one
/proc/get_mob_in_atom_with_warning(atom/A, mob/user = usr)
	if(!istype(A))
		return null
	if(ismob(A))
		return A

	. = null
	for(var/mob/M in A)
		if(!.)
			. = M
		else
			to_chat(user, "<span class='warning'>Multiple mobs in [A], using first mob found...</span>")
			break
	if(!.)
		to_chat(user, "<span class='warning'>No mob located in [A].</span>")
