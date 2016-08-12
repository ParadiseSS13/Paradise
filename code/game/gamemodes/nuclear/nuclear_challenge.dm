#define CHALLENGE_TIME_LIMIT 6000
#define MIN_CHALLENGE_PLAYERS 50
#define CHALLENGE_SHUTTLE_DELAY 15000 //25 minutes, so the ops have at least 5 minutes before the shuttle is callable.

/obj/item/device/nuclear_challenge
	name = "Declaration of War (Challenge Mode)"
	icon_state = "gangtool-red"
	item_state = "walkietalkie"
	desc = "Use to send a declaration of hostilities to the target, delaying your shuttle departure for 20 minutes while they prepare for your assault.  \
	Such a brazen move will attract the attention of powerful benefactors within the Syndicate, who will supply your team with a massive amount of bonus telecrystals.  \
	Must be used within five minutes, or your benefactors will lose interest."
	var/declaring_war = 0



/obj/item/device/nuclear_challenge/attack_self(mob/living/user)
	if(declaring_war)
		return
	if(player_list.len < MIN_CHALLENGE_PLAYERS)
		to_chat(user, "The enemy crew is too small to be worth declaring war on.")
		return
	if(!is_admin_level(user.z))
		to_chat(user, "You have to be at your base to use this.")
		return

	if(world.time > CHALLENGE_TIME_LIMIT)
		to_chat(user, "It's too late to declare hostilities. Your benefactors are already busy with other schemes. You'll have to make  do with what you have on hand.")
		return

	declaring_war = 1
	var/are_you_sure = alert(user, "Consult your team carefully before you declare war on [station_name()]]. Are you sure you want to alert the enemy crew?", "Declare war?", "Yes", "No")
	if(are_you_sure == "No")
		to_chat(user, "On second thought, the element of surprise isn't so bad after all.")
		declaring_war = 0
		return

	var/war_declaration = "[user.real_name] has declared his intent to utterly destroy [station_name()] with a nuclear device, and dares the crew to try and stop them."
	command_announcement.Announce(war_declaration, "Declaration of War", 'sound/effects/siren.ogg')
	to_chat(user, "You've attracted the attention of powerful forces within the syndicate. A bonus bundle of telecrystals has been granted to your team. Great things await you if you complete the mission.")

	for(var/obj/machinery/computer/shuttle/syndicate/S in machines)
		S.challenge = TRUE

	var/obj/item/device/radio/uplink/U = new /obj/item/device/radio/uplink(get_turf(user))
	U.hidden_uplink.uplink_owner= "[user.key]"
	U.hidden_uplink.uses = 280
	config.shuttle_refuel_delay = CHALLENGE_SHUTTLE_DELAY
	qdel(src)


#undef CHALLENGE_TIME_LIMIT
#undef MIN_CHALLENGE_PLAYERS
#undef CHALLENGE_SHUTTLE_DELAY
