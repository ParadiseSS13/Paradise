/obj/effect/landmark/corpse/mob_spawn
	density = 1
	anchored = 1

/obj/effect/landmark/corpse/mob_spawn/attack_ghost(mob/user)
	if(ticker.current_state != GAME_STATE_PLAYING)
		return
	var/ghost_role = alert("Become [mobname]? (Warning, You can no longer be cloned!)",,"Yes","No")
	if(ghost_role == "No")
		return
	log_game("[user.ckey] became [mobname]")
	createCorpse(ckey = user.ckey)

/obj/effect/landmark/corpse/mob_spawn/initialize()
	return

/obj/effect/landmark/corpse/mob_spawn/proc/equip(mob/M)
	return

/obj/effect/landmark/corpse/mob_spawn/prisoner_transport
	name = "prisoner sleeper"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper"
	corpseuniform = /obj/item/clothing/under/color/orange/prison
	corpsemask = /obj/item/clothing/mask/breath
	corpseshoes = /obj/item/clothing/shoes/orange
	corpsepocket1 = /obj/item/weapon/tank/emergency_oxygen
	flavour_text = {"You were a prisoner, sentenced to hard labour in one of Nanotrasen's harsh gulags, but judging by the explosive crash you just survived, fate may have other plans for. First thing is first though: Find a way to survive this mess."}

/obj/effect/landmark/corpse/mob_spawn/prisoner_transport/special(mob/living/new_spawn)
	var/crime = pick("distribution of contraband" , "unauthorized erotic action on duty", "embezzlement", "piloting under the influence", "dereliction of duty", "syndicate collaboration", "mutiny", "multiple homicides", "corporate espionage", "recieving bribes", "malpractice", "worship of prohbited life forms", "possession of profane texts", "murder", "arson", "insulting your manager", "grand theft", "conspiracy", "attempting to unionize", "vandalism", "gross incompetence")
	new_spawn << "You were convincted of: [crime]."
