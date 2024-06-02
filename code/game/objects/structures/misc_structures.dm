//MISC structures- if it is less than 100 lines and doesn't fit in a category, toss it in here!

/*CURRENT CONTENTS:
	NT recruitment signpost
	Ninja Teleportation Console
*/

/obj/structure/signpost
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "signpost"
	anchored = TRUE
	density = TRUE

/obj/structure/ninjatele

	name = "Long-Distance Teleportation Console"
	desc = "A console used to send a Spider Clan operative long distances rapidly."
	icon = 'icons/obj/ninjaobjects.dmi'
	icon_state = "teleconsole"
	anchored = TRUE
	density = FALSE

/obj/structure/ninjatele/attack_hand(mob/user as mob)
	if(user.mind.special_role=="Ninja")
		switch(tgui_alert(user, "Phase Jaunt relay primed, target locked as [station_name()], initiate VOID-shift translocation? (Warning! Internals required!)", "Void Shift", list("Yes", "No")))
			if("Yes")
				if(user.z != src.z)
					return

				user.loc.loc.Exited(user)
				user.loc = pick(GLOB.carplist) // In the future, possibly make specific NinjaTele landmarks, and give him an option to teleport to North/South/East/West of SS13 instead of just hijacking a carpspawn.

				playsound(user.loc, 'sound/effects/phasein.ogg', 25, 1)
				playsound(user.loc, 'sound/effects/sparks2.ogg', 50, 1)
				new /obj/effect/temp_visual/dir_setting/ninja/phase(get_turf(user), user.dir)
				to_chat(user, "<span class='boldnotice'>VOID-Shift</span> translocation successful")

			if("No")
				to_chat(user, "<span class='danger'>Process aborted!</span>")
				return

			else
				to_chat(user, "<span class='danger'>FĆAL �Rr�R</span>: ŧer nt recgnized, c-cntr-r䣧-ç äcked.")

/obj/structure/respawner
	name = "\improper Long-Distance Cloning Machine"
	desc = "Top-of-the-line Nanotrasen technology allows for cloning of crew members from off-station upon bluespace request."
	icon = 'icons/obj/objects.dmi'
	icon_state = "borgcharger1(old)"
	anchored = TRUE
	density = TRUE
	/// An outfit for ghosts to spawn with
	var/datum/outfit/selected_outfit

/obj/structure/respawner/attack_ghost(mob/dead/observer/user)
	if(check_rights(R_EVENT))
		var/outfit_pick = tgui_alert(user, "Do you want to pick an outfit or respawn?", "Pick an Outfit?", list("Pick outfit", "Respawn", "Cancel"))
		if(!outfit_pick || outfit_pick == "Cancel")
			return
		if(outfit_pick == "Pick outfit")
			var/new_outfit = user.client.robust_dress_shop()
			if(!new_outfit)
				return
			log_admin("[key_name(user)] changed a respawner machine's outfit to [new_outfit].")
			message_admins("[key_name(user)] changed a respawner machine's outfit to [new_outfit].")
			if(new_outfit == "Naked")
				selected_outfit = null
				return
			selected_outfit = new_outfit
			return

	var/response = tgui_alert(user, "Are you sure you want to spawn here?\n(If you do this, you won't be able to be cloned!)", "Respawn?", list("Yes", "No"))
	if(response == "Yes")
		var/turf/respawner_location = get_turf(src)
		if(!respawner_location) // gotta check it still exists, else you'll get sent to nullspace
			return
		var/mob/living/carbon/human/new_human = user.incarnate_ghost()
		if(!new_human) // gotta check they haven't spawned in again yet, else we get runtimes and logspam
			return
		new_human.forceMove(respawner_location)
		log_admin("[key_name(new_human)] was incarnated by a respawner machine.")
		message_admins("[key_name_admin(new_human)] was incarnated by a respawner machine.")
		new_human.mind.offstation_role = TRUE // To prevent them being an antag objective
		if(selected_outfit)
			new_human.equipOutfit(selected_outfit)

/obj/structure/ghost_beacon
	name = "ethereal beacon"
	desc = "A structure that draws ethereal attention when active. Use an empty hand to activate."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "anomaly_crystal"
	anchored = TRUE
	density = TRUE
	var/active = FALSE
	var/ghost_alert_delay = 30 SECONDS
	var/last_ghost_alert
	var/alert_title = "Ethereal Beacon Active!"
	var/atom/attack_atom


/obj/structure/ghost_beacon/Initialize()
	. = ..()
	last_ghost_alert = world.time
	attack_atom = src
	if(active)
		START_PROCESSING(SSobj, src)

/obj/structure/ghost_beacon/Destroy()
	if(active)
		STOP_PROCESSING(SSobj, src)
	attack_atom = null
	return ..()

/obj/structure/ghost_beacon/attack_ghost(mob/dead/observer/user)
	if(user.can_advanced_admin_interact())
		attack_hand(user)
	else if(attack_atom != src)
		attack_atom.attack_ghost(user)

/obj/structure/ghost_beacon/attack_hand(mob/user)
	if(!is_admin(user))
		return
	to_chat(user, "<span class='notice'>You [active ? "disable" : "enable"] \the [src].</span>")
	if(active)
		STOP_PROCESSING(SSobj, src)
	else
		START_PROCESSING(SSobj, src)
	active = !active

/obj/structure/ghost_beacon/process()
	if(last_ghost_alert + ghost_alert_delay < world.time)
		notify_ghosts("[src] active in [get_area(src)].", 'sound/effects/ghost2.ogg', title = alert_title, source = attack_atom, action = (attack_atom == src ? NOTIFY_JUMP : NOTIFY_ATTACK))
		last_ghost_alert = world.time

/obj/structure/boulder
	name = "boulder"
	desc = "A large rock."
	icon = 'icons/obj/mining.dmi'
	icon_state = "boulder1"
	density = TRUE
	opacity = TRUE
	anchored = TRUE
