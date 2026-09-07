USER_CONTEXT_MENU(possess_object, R_POSSESS, "\[Admin\] Possess Obj", obj/O as obj in world)
	if(istype(O,/obj/singularity))
		if(GLOB.configuration.general.forbid_singulo_possession) // I love how this needs to exist
			to_chat(client, "It is forbidden to possess singularities.")
			return

	var/turf/T = get_turf(O)

	var/confirm = alert(client, "Are you sure you want to possess [O]?", "Confirm possession", "Yes", "No")

	if(confirm != "Yes")
		return
	if(T)
		log_admin("[key_name(client)] has possessed [O] ([O.type]) at ([T.x], [T.y], [T.z])")
		message_admins("[key_name_admin(client)] has possessed [O] ([O.type]) at ([T.x], [T.y], [T.z])", 1)
	else
		log_admin("[key_name(client)] has possessed [O] ([O.type]) at an unknown location")
		message_admins("[key_name_admin(client)] has possessed [O] ([O.type]) at an unknown location", 1)

	var/mob/client_mob = client.mob

	if(!client_mob.control_object) //If you're not already possessing something...
		client_mob.name_archive = client_mob.real_name

	client_mob.loc = O
	client_mob.real_name = O.name
	client_mob.name = O.name
	client_mob.client.eye = O
	client_mob.control_object = O
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Possess Object") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

USER_CONTEXT_MENU(release_object, R_POSSESS, "\[Admin\] Release Obj", obj/O as obj in world)
	var/mob/client_mob = client.mob
	if(client_mob.control_object && client_mob.name_archive) //if you have a name archived and if you are actually relassing an object
		client_mob.real_name = client_mob.name_archive
		client_mob.name = client_mob.real_name
		if(ishuman(client_mob))
			var/mob/living/carbon/human/H = client_mob
			H.name = H.get_visible_name()

	client_mob.loc = O.loc // Appear where the object you were controlling is -- TLE
	client_mob.client.eye = client_mob
	client_mob.control_object = null
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Release Object") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
