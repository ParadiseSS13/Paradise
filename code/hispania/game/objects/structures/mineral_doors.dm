/obj/structure/mineral_door/meatdoor
	name = "meat door"
	icon_state = "meat"
	icon = 'icons/hispania/obj/doors.dmi'
	hardness = 1.5
	close_delay = 100
	openSound = 'sound/effects/attackblob.ogg'
	closeSound = 'sound/effects/attackblob.ogg'
	damageSound = 'sound/effects/attackblob.ogg'
	sheetType = null

/obj/structure/mineral_door/meatdoor/fangdoor
	name = "fang door"
	icon_state = "fang"

GLOBAL_DATUM(naga_gate, /obj/structure/necropolis_gate/naga_boss)
/obj/structure/necropolis_gate/naga_boss
	name = "Weird looking door"
	desc = "A tremendous, impossibly large gateway, set into a massive tower of stone."
	sight_blocker_distance = 2

/obj/structure/necropolis_gate/naga_boss/attack_hand(mob/user)
	if(!open && !changing_openness)
		var/safety = alert(user, "You think this might be a bad idea...", "Open the door?", "Proceed", "Abort")
		if(safety == "Abort" || !in_range(src, user) || !src || open || changing_openness || user.incapacitated())
			return
		user.visible_message("<span class='warning'>[user] knocks on [src]...</span>", "<span class='boldannounce'>You tentatively open [src]...</span>")
		playsound(user.loc, 'sound/misc/e1m1.ogg', 100, 1) //Good Luck
		sleep(50)
	return ..()

/obj/structure/necropolis_gate/naga_boss/toggle_the_gate(mob/user, wendigo_damage)
	if(open)
		return
	. = ..()
	if(.)
		locked = TRUE
		var/turf/T = get_turf(src)
		visible_message("<span class='userdanger'>Something horrible emerges from Research Facility!</span>")
		if(wendigo_damage)
			message_admins("The Wendigo took damage while the necropolis gate was closed, and has released itself!")
			log_game("The Wendigo took damage while the necropolis gate was closed and released itself.")
		else
			message_admins("[user ? ADMIN_LOOKUPFLW(user):"Unknown"] has released The Wendigo!")
			log_game("[user ? key_name(user) : "Unknown"] released The Wendigo.")

		var/sound/legion_sound = sound('sound/creatures/legion_spawn.ogg')
		for(var/mob/M in GLOB.player_list)
			if(M.z == z)
				to_chat(M, "<span class='userdanger'>Discordant whispers flood your mind in a thousand voices. Each one speaks your name, over and over. They want your help to be free.</span>")
				M.playsound_local(T, null, 100, FALSE, 0, FALSE, pressure_affected = FALSE, S = legion_sound)
				flash_color(M, flash_color = "#891800", flash_time = 50)
		var/mutable_appearance/release_overlay = mutable_appearance('icons/effects/effects.dmi', "legiondoor")
		notify_ghosts("The Wendigo has been released in the [get_area(src)]!", source = src, alert_overlay = release_overlay, action = NOTIFY_JUMP)
