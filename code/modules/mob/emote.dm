#define EMOTE_COOLDOWN 20		//Time in deciseconds that the cooldown lasts

//Emote Cooldown System (it's so simple!)
/mob/proc/handle_emote_CD(cooldown = EMOTE_COOLDOWN)
	if(emote_cd == 2) return 1			// Cooldown emotes were disabled by an admin, prevent use
	if(src.emote_cd == 1) return 1		// Already on CD, prevent use

	src.emote_cd = 1		// Starting cooldown
	spawn(cooldown)
		if(emote_cd == 2) return 1		// Don't reset if cooldown emotes were disabled by an admin during the cooldown
		src.emote_cd = 0				// Cooldown complete, ready for more!

	return 0		// Proceed with emote
//--FalseIncarnate

// All mobs should have custom emote, really..
/mob/proc/custom_emote(var/m_type=1,var/message = null)

	if(stat || !use_me && usr == src)
		if(usr)
			to_chat(usr, "You are unable to emote.")
		return

	var/muzzled = istype(src.wear_mask, /obj/item/clothing/mask/muzzle)
	if(m_type == 2 && muzzled) return

	var/input
	if(!message)
		input = sanitize(copytext(input(src,"Choose an emote to display.") as text|null,1,MAX_MESSAGE_LEN))
	else
		input = message
	if(input)
		message = "<B>[src]</B> [input]"
	else
		return


	if (message)
		log_emote("[name]/[key] : [message]")

 //Hearing gasp and such every five seconds is not good emotes were not global for a reason.
 // Maybe some people are okay with that.

		for(var/mob/M in player_list)
			if (!M.client)
				continue //skip monkeys and leavers
			if (istype(M, /mob/new_player))
				continue
			if(findtext(message," snores.")) //Because we have so many sleeping people.
				break
			if(M.stat == 2 && (M.client.prefs.toggles & CHAT_GHOSTSIGHT) && !(M in viewers(src,null)))
				M.show_message(message)


		// Type 1 (Visual) emotes are sent to anyone in view of the item
		if (m_type & 1)
			var/list/can_see = get_mobs_in_view(1,src)  //Allows silicon & mmi mobs carried around to see the emotes of the person carrying them around.
			can_see |= viewers(src,null)
			for (var/mob/O in can_see)

				if(O.status_flags & PASSEMOTES)

					for(var/obj/item/weapon/holder/H in O.contents)
						H.show_message(message, m_type)

					for(var/mob/living/M in O.contents)
						M.show_message(message, m_type)

				O.show_message(message, m_type)

		// Type 2 (Audible) emotes are sent to anyone in hear range
		// of the *LOCATION* -- this is important for pAIs to be heard
		else if (m_type & 2)
			for (var/mob/O in get_mobs_in_view(7,src))

				if(O.status_flags & PASSEMOTES)

					for(var/obj/item/weapon/holder/H in O.contents)
						H.show_message(message, m_type)

					for(var/mob/living/M in O.contents)
						M.show_message(message, m_type)

				O.show_message(message, m_type)

/mob/proc/emote_dead(var/message)

	if(client.prefs.muted & MUTE_DEADCHAT)
		to_chat(src, "\red You cannot send deadchat emotes (muted).")
		return

	if(!(client.prefs.toggles & CHAT_DEAD))
		to_chat(src, "\red You have deadchat muted.")
		return

	if(!src.client.holder)
		if(!config.dsay_allowed)
			to_chat(src, "\red Deadchat is globally muted")
			return


	var/input
	if(!message)
		input = sanitize(copytext(input(src, "Choose an emote to display.") as text|null, 1, MAX_MESSAGE_LEN))
	else
		input = message

	if(input)
		message = "<span class='game deadsay'><span class='prefix'>DEAD:</span> <b>[src]</b> [message]</span>"
	else
		return


	if(message)
		log_emote("Ghost/[src.key] : [message]")

		for(var/mob/M in player_list)
			if(istype(M, /mob/new_player))
				continue

			if(check_rights(R_ADMIN|R_MOD, 0, M) && (M.client.prefs.toggles & CHAT_DEAD)) // Show the emote to admins/mods
				to_chat(M, message)

			else if(M.stat == DEAD && (M.client.prefs.toggles & CHAT_DEAD)) // Show the emote to regular ghosts with deadchat toggled on
				M.show_message(message, 2)
