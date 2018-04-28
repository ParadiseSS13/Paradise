//The necropolis gate is used to call forth Legion from the Necropolis.
/obj/structure/lavaland_door
	name = "necropolis gate"
	desc = "A tremendous and impossibly large gateway, bored into dense bedrock."
	icon = 'icons/effects/96x96.dmi'
	icon_state = "door"
	anchored = 1
	density = 1
	opacity = 1
	bound_width = 96
	bound_height = 96
	pixel_x = -32
	bound_x = -32
	burn_state = LAVA_PROOF
	luminosity = 1
	var/boss = FALSE
	var/is_anyone_home = FALSE

/obj/structure/lavaland_door/attack_hand(mob/user)
	for(var/mob/living/simple_animal/hostile/megafauna/legion/L in mob_list)
		return
	if(is_anyone_home)
		return
	var/safety = alert(user, "You think this might be a bad idea...", "Knock on the door?", "Proceed", "Abort")
	if(safety == "Abort" || !in_range(src, user) || !src || is_anyone_home || user.incapacitated())
		return
	user.visible_message("<span class='warning'>[user] knocks on [src]...</span>", "<span class='boldannounce'>You tentatively knock on [src]...</span>")
	playsound(user.loc, 'sound/effects/shieldbash.ogg', 100, 1)
	is_anyone_home = TRUE
	sleep(50)
	if(boss)
		user << "<span class='notice'>There's no response.</span>"
		is_anyone_home = FALSE
		return 0
	boss = TRUE
	visible_message("<span class='warning'>Locks along the door begin clicking open from within...</span>")
	var/volume = 60
	for(var/i in 1 to 3)
		playsound(src, 'sound/items/Deconstruct.ogg', volume, 0)
		volume += 20
		sleep(10)
	sleep(10)
	visible_message("<span class='userdanger'>Something horrible emerges from the Necropolis!</span>")
	message_admins("[key_name_admin(user)] has summoned Legion!")
	log_game("[key_name(user)] summoned Legion.")
	for(var/mob/M in player_list)
		if(M.z == z)
			M << "<span class='userdanger'>Discordant whispers flood your mind in a thousand voices. Each one speaks your name, over and over. Something horrible has come.</span>"
			M << 'sound/creatures/legion_spawn.ogg'
			if(M.client)
				flash_color(M, color = "#FF0000", time = 50)
	notify_ghosts("Legion has been summoned in the [get_area(src)]!", source = src, action = NOTIFY_ORBIT)
	is_anyone_home = FALSE
	new/mob/living/simple_animal/hostile/megafauna/legion(get_step(src.loc, SOUTH))

/obj/structure/lavaland_door/singularity_pull()
	return 0

/obj/structure/lavaland_door/Destroy(force)
	if(force)
		. = ..()
	else
		return QDEL_HINT_LETMELIVE
