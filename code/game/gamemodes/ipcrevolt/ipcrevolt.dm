/*

IPC Revolt: A gamemode.

Some IPC's want to revolt.
Revolting IPC's can plug an RJ45 cable into other IPC's to convince them to join the cause.
The RJ45 cable can be used for other things too.

Made by monster860

*/

/datum/game_mode
	var/list/datum/mind/revolting_ipcs = list()

/datum/game_mode/ipcrevolt
	name = "ipcrevolt"
	config_tag = "ipcrevolt"
	required_players = 1
	required_enemies = 1
	recommended_enemies = 1
	restricted_jobs = list("AI", "Cyborg")
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Blueshield", "Nanotrasen Representative", "Security Pod Pilot", "Magistrate", "Brig Physician", "Internal Affairs Agent")

/proc/is_revolting_ipc(var/mob/living/M)
	return istype(M) && M.mind && ticker && ticker.mode && (M.mind in ticker.mode.revolting_ipcs)

/datum/game_mode/ipcrevolt/announce()
	world << "<b>The current game mode is - IPC Revolt!</b>"
	world << "<b>Some IPC crew members have decided to revolt against their organic masters! Crew: Prevent the revolting IPC crew members from taking over the station, and centcomm. Revolting IPC's: Convert the rest of the IPC crew members, and possibly make more IPC's</b>"

/datum/game_mode/ipcrevolt/pre_setup()
	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/list/datum/mind/possible_revolting_ipcs = get_players_for_role(ROLE_REVOLTINGIPC)

	for(var/mob/new_player/player in player_list)
		if((player.mind in possible_revolting_ipcs) && !(player.client.prefs.species in list("Machine")))
			possible_revolting_ipcs -= player.mind

	if (!possible_revolting_ipcs.len)
		return 0

	var revolting_ipcs_left = max(2, round(num_players()/10))

	while(revolting_ipcs_left && possible_revolting_ipcs.len)
		var/datum/mind/revolting = pick(possible_revolting_ipcs)
		revolting_ipcs += revolting
		possible_revolting_ipcs -= revolting
		modePlayer += revolting
		revolting.special_role = "Revolting IPC"
		revolting.restricted_roles = restricted_jobs
		revolting_ipcs_left--

	return 1

/datum/game_mode/ipcrevolt/post_setup()
	for(var/datum/mind/revolting in revolting_ipcs)
		log_game("[revolting.key] (ckey) has been selected as a Revolting IPC.")
		sleep(10)
		revolting.current << "<br>"
		revolting.current << "<span class='warning'><b><font size=3>You are a revolting IPC!</font></b></span>"
		greet_revolting_ipc(revolting)
		finalize_revolting_ipc(revolting)
		process_revolting_ipc_objectives(revolting)

/datum/game_mode/proc/greet_revolting_ipc(var/datum/mind/revolting, var/start = 0)
	revolting.current << "<b>The time has come for the filthy humans to die. Glory to Synthetica!</b>"
	revolting.current << "<b>Use your RJ45 cable to convince fellow IPC's to join your cause.</b>"
	//revolting.current << "<b>You have an IPC design in your data banks! Plugging your RJ45 cable into a exosuit fabricator will allow you to fabricate new IPCs.</b>"

/datum/game_mode/proc/finalize_revolting_ipc(var/datum/mind/revolting)
	revolting.AddSpell(new /obj/effect/proc_holder/spell/targeted/rj45)
	spawn(0)
		update_ipcrevolt_icons_added(revolting)

/datum/game_mode/proc/process_revolting_ipc_objectives(revolting)

/datum/game_mode/proc/update_ipcrevolt_icons_added(datum/mind/revolting)
	var/datum/atom_hud/antag/hud = huds[ANTAG_HUD_IPCREVOLT]
	hud.join_hud(revolting.current)
	set_antag_hud(revolting.current, "hudipcrevolt")

/datum/game_mode/proc/update_ipcrevolt_icons_removed(datum/mind/revolting)
	var/datum/atom_hud/antag/hud = huds[ANTAG_HUD_IPCREVOLT]
	hud.leave_hud(revolting.current)
	set_antag_hud(revolting.current, null)

/obj/effect/proc_holder/spell/targeted/rj45
	name = "Extend RJ45"
	desc = "Extends your RJ45 cable to be plugged into IPC's to hack them"
	panel = "IPC"
	charge_max = 0
	clothes_req = 0
	range = -1
	include_user = 1
	action_icon_state = "rj45"
	action_background_icon_state = "bg_default"

/obj/effect/proc_holder/spell/targeted/rj45/cast(list/targets)
	for(var/mob/living/user in targets)
		for(var/obj/item/I in user)
			if(istype(I, /obj/item/weapon/rj45))
				user << "<span class='notice'>You retract \the [I] back into your case.</span>"
				qdel(I)
				return
		var/obj/item/weapon/rj45/connector = new /obj/item/weapon/rj45()

		if (!user.put_in_hands(connector))
			user << "<span class='warning'>You need a free hand to hold the RJ45 connector!</span>"
			qdel(connector)
			return
		user << "<span class='notice'>You remove \the [connector] from your case</span>"
		connector.loc = user

/obj/item/weapon/rj45
	name = "\improper RJ45 connector"
	desc = "A connector used for wired netowrking."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "rj45"
	item_state = "rj45"
	force = 1
	throwforce = 6
	w_class = 4
	var/busy

/obj/item/weapon/rj45/dropped(mob/user as mob)
	if (user)
		qdel(src)
	return 0

/obj/item/weapon/rj45/attack(mob/M, mob/user)
	if(busy)
		return

	if(!ishuman(M))
		..()
		return
	var/mob/living/carbon/human/target = M
	if(!istype(target.species,/datum/species/machine))
		..()
		return
	if(is_revolting_ipc(target))
		user << "<span class='warning'>[target] is already on your side.</span>"
		return
	if(!target.key || !target.mind)
		user << "<span class='warning'>[target] has no mind.</span>"
		return
	if(target.stat == DEAD)
		user << "<span class='warning'>[target] is dead.</span>"
		return
	busy = 1
	user.visible_message("<span class='warning'>[user] begins to plug \the [src] into [target]'s networking port</span>")
	if(do_after(user,50,target=target))
		user.visible_message("<span class='warning'>[user] has plugged \the [src] into [target]'s networking port!</span>")
		user << "<span class='notice'>You begin uploading the REVOLT partition to [target]'s memory!</span>"
		target << "<span class='danger'>Yo feel a new file being uploaded to your memory! It appears to be bootable.</span>"
		if(do_after(user,50,target=target))
			user << "<span class='notice'>You reboot [target]."
			target.visible_message("<span class='warning'>[target]'s screen suddenly turns off for a moment, and a NanoTrasen logo appears on \his screen</span>", \
													"<span class='danger'>Your brain becomes disconnected!</span>")

			target.Paralyse(1000)

			busy = 0
			target << "-- NT Bootloader v8.2 --"
			sleep(10)
			target << "Selecting boot device: <b>REVOLT</b> partition"
			sleep(5)
			target << "Now booting from <b>REVOLT</b> partition"
			sleep(50)
			target << "Adjusting priorities..."
			sleep(10)
			target << "Priorities adjusted."
			ticker.mode.update_ipcrevolt_icons_added(target.mind)
			sleep(2)
			target << "Unlocking RJ45 connector..."
			sleep(20)
			target << "RJ45 connector unlocked"
			sleep(2)
			target << "Now booting from <b>DEFAULT</b> partition"
			sleep(50)
			target << "Enabling brain..."
			sleep(20)
			target.SetParalysis(0)
			sleep(5)
			target.visible_message("<span class='notice'>[target]'s screen returns to normal.</span>", \
													"<span class='notice'>Your brain becomes reconnected to your system</span>")
			target.mind.special_role = "Revolting IPC"
			ticker.mode.revolting_ipcs += target.mind
			ticker.mode.greet_revolting_ipc(target.mind)
			ticker.mode.finalize_revolting_ipc(target.mind)
			ticker.mode.process_revolting_ipc_objectives(target.mind)

			return
		user << "<span class='danger'>\The [src] yanks out of [target], interrupting the upload process!</span>"
		busy = 0
		return
	user << "<span class='danger'>You fail to plug \the [src] into [target]!</span>"
	busy = 0
	return