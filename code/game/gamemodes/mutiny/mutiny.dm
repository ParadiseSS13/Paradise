#define MUTINY_RECRUITMENT_COOLDOWN 5

datum/game_mode/mutiny
	var/datum/mutiny_fluff/fluff
	var/datum/directive/current_directive
	var/obj/item/weapon/mutiny/auth_key/captain/captains_key
	var/obj/item/weapon/mutiny/auth_key/secondary/secondary_key
	var/obj/machinery/emergency_authentication_device/ead
	var/datum/mind/head_loyalist
	var/datum/mind/head_mutineer
	var/recruit_loyalist_cooldown = 0
	var/recruit_mutineer_cooldown = 0
	var/list/loyalists = list()
	var/list/mutineers = list()
	var/list/body_count = list()

	name = "mutiny"
	config_tag = "mutiny"
	required_players = 20
	ert_disabled = 1

	New()
		fluff = new(src)

	proc/reveal_directives()
		spawn(rand(1 MINUTES, 3 MINUTES))
			command_announcement.Announce("Incoming emergency directive: Captain's office fax machine, [station_name()].","Emergency Transmission")
			spawn(rand(3 MINUTES, 5 MINUTES))
				send_pda_message()
			spawn(rand(3 MINUTES, 5 MINUTES))
				fluff.announce_directives()
				spawn(rand(2 MINUTES, 3 MINUTES))

					var/list/reasons = list(
						"political instability",
						"quantum fluctuations",
						"hostile raiders",
						"derelict station debris",
						"REDACTED",
						"ancient alien artillery",
						"solar magnetic storms",
						"sentient time-travelling killbots",
						"gravitational anomalies",
						"wormholes to another dimension",
						"a telescience mishap",
						"radiation flares",
						"supermatter dust",
						"leaks into a negative reality",
						"antiparticle clouds",
						"residual bluespace energy",
						"suspected syndicate operatives",
						"malfunctioning von Neumann probe swarms",
						"shadowy interlopers",
						"a stranded Vox arkship",
						"haywire IPC constructs",
						"rogue Unathi exiles",
						"artifacts of eldritch horror",
						"a brain slug infestation",
						"killer bugs that lay eggs in the husks of the living",
						"a deserted transport carrying xenomorph specimens",
						"an emissary for the gestalt requesting a security detail",
						"a Tajaran slave rebellion",
						"radical Skrellian transevolutionaries",
						"classified security operations",
						"science-defying raw elemental chaos"
						)
					command_announcement.Announce("The presence of [pick(reasons)] in the region is tying up all available local emergency resources; emergency response teams cannot be called at this time.","Emergency Transmission")

	// Returns an array in case we want to expand on this later.
	proc/get_head_loyalist_candidates()
		var/list/candidates[0]
		for(var/mob/loyalist in player_list)
			if(loyalist.mind && loyalist.mind.assigned_role == "Captain")
				candidates+=loyalist.mind
		return candidates

	proc/get_head_mutineer_candidates()
		var/list/candidates[0]
		for(var/mob/mutineer in player_list)
			if(ROLE_MUTINEER in mutineer.client.prefs.be_special)
				if(!jobban_isbanned(mutineer, "mutineer") && !jobban_isbanned(mutineer,"Syndicate"))
					for(var/job in command_positions - "Captain")
						if(mutineer.mind && mutineer.mind.assigned_role == job)
							candidates+=mutineer.mind
		return candidates

	proc/get_directive_candidates()
		var/list/candidates[0]
		for(var/T in subtypesof(/datum/directive))
			var/datum/directive/D = new T(src)
//			to_chat(world, D.name)
			if (D.meets_prerequisites())
				candidates+=D
		return candidates

	proc/send_pda_message()
		var/obj/item/device/pda/pda = null
		for(var/obj/item/device/pda/P in head_mutineer.current)
			pda = P
			break

		if (!pda)
			return 0

		var/datum/data/pda/app/messenger/pdam = pda.find_program(/datum/data/pda/app/messenger)
		if(pdam)
			pdam.notify(fluff.get_pda_body(), 0)
		return 1

	proc/get_equipment_slots()
		return list(
			"left pocket" = slot_l_store,
			"right pocket" = slot_r_store,
			"backpack" = slot_in_backpack,
			"left hand" = slot_l_hand,
			"right hand" = slot_r_hand)

	proc/equip_head_loyalist()
		equip_head(head_loyalist, "loyalist", /mob/living/carbon/human/proc/recruit_loyalist)

	proc/equip_head_mutineer()
		equip_head(head_mutineer, "mutineer", /mob/living/carbon/human/proc/recruit_mutineer)

	proc/equip_head(datum/mind/head, faction, proc/recruitment_verb)
		var/mob/living/carbon/human/H = head.current
		to_chat(H, "You are the Head [capitalize(faction)]!")
		head.special_role = "head_[faction]"

		var/slots = get_equipment_slots()
		switch(faction)
			if("loyalist")
				if(captains_key) qdel(captains_key)
				captains_key = new(H)
				H.equip_in_one_of_slots(captains_key, slots)
			if("mutineer")
				if(secondary_key) qdel(secondary_key)
				secondary_key = new(H)
				H.equip_in_one_of_slots(secondary_key, slots)

		H.update_icons()
		H.verbs += recruitment_verb

	proc/add_loyalist(datum/mind/M)
		add_faction(M, "loyalist", loyalists)

	proc/add_mutineer(datum/mind/M)
		add_faction(M, "mutineer", mutineers)

	proc/add_faction(datum/mind/M, faction, list/faction_list)
		if(!can_be_recruited(M, faction))
			to_chat(M.current, "\red Recruitment canceled; your role has already changed.")
			to_chat(head_mutineer.current, "\red Could not recruit [M]. Their role has changed.")
			return

		if(M in loyalists)
			loyalists-=M

		if(M in mutineers)
			mutineers-=M

		M.special_role = faction
		faction_list+=M

		if(faction == "mutineer")
			to_chat(M.current, fluff.mutineer_tag("You have joined the mutineers!"))
			to_chat(head_mutineer.current, fluff.mutineer_tag("[M] has joined the mutineers!"))
		else
			to_chat(M.current, fluff.loyalist_tag("You have joined the loyalists!"))
			to_chat(head_loyalist.current, fluff.loyalist_tag("[M] has joined the loyalists!"))

		update_icon(M)

	proc/was_bloodbath()
		var/list/remaining_loyalists = loyalists - body_count
		if (!remaining_loyalists.len)
			return 1

		var/list/remaining_mutineers = mutineers - body_count
		if (!remaining_mutineers.len)
			return 1

		return 0

	proc/replace_nuke_with_ead()
		for(var/obj/machinery/nuclearbomb/N in world)
			ead = new(N.loc, src)
			qdel(N)

	proc/unbolt_vault_door()
		var/obj/machinery/door/airlock/vault = locate(/obj/machinery/door/airlock/vault)
		vault.unlock(1)

	proc/make_secret_transcript()
		var/obj/machinery/computer/telecomms/server/S = locate(/obj/machinery/computer/telecomms/server)
		if(!S) return

		var/obj/item/weapon/paper/crumpled/bloody/transcript = new(S.loc)
		transcript.name = "secret transcript"
		transcript.info = fluff.secret_transcript()

	proc/can_be_recruited(datum/mind/M, role)
		if(!M) return 0
		if(!M.special_role) return 1
		switch(role)
			if("loyalist")
				return M.special_role == "mutineer"
			if("mutineer")
				return M.special_role == "loyalist"

	proc/round_outcome()
		to_chat(world, "<center><h4>Breaking News</h4></center><br><hr>")
		if (was_bloodbath())
			to_chat(world, fluff.no_victory())
			return

		var/directives_completed = current_directive.directives_complete()
		var/ead_activated = ead.activated
		if (directives_completed && ead_activated)
			to_chat(world, fluff.loyalist_major_victory())
		else if (directives_completed && !ead_activated)
			to_chat(world, fluff.loyalist_minor_victory())
		else if (!directives_completed && ead_activated)
			to_chat(world, fluff.mutineer_minor_victory())
		else if (!directives_completed && !ead_activated)
			to_chat(world, fluff.mutineer_major_victory())

		world << sound('sound/machines/twobeep.ogg')

	proc/update_all_icons()
		spawn(0)
			for(var/datum/mind/M in mutineers)
				update_icon(M)

			for(var/datum/mind/M in loyalists)
				update_icon(M)
		return 1

	proc/update_icon(datum/mind/M)
		if(!M.current || !M.current.client)
			return 0

		for(var/image/I in head_loyalist.current.client.images)
			if(I.loc == M.current && (I.icon_state == "loyalist" || I.icon_state == "mutineer"))
				qdel(I)

		for(var/image/I in head_mutineer.current.client.images)
			if(I.loc == M.current && (I.icon_state == "loyalist" || I.icon_state == "mutineer"))
				qdel(I)

		if(M in loyalists)
			var/I = image('icons/mob/mob.dmi', loc=M.current, icon_state = "loyalist")
			head_loyalist.current.client.images += I

		if(M in mutineers)
			var/I = image('icons/mob/mob.dmi', loc=M.current, icon_state = "mutineer")
			head_mutineer.current.client.images += I

		return 1

/datum/game_mode/mutiny/announce()
	fluff.announce()

/datum/game_mode/mutiny/pre_setup()
	var/list/loyalist_candidates = get_head_loyalist_candidates()
	if(!loyalist_candidates || loyalist_candidates.len == 0)
		to_chat(world, "\red Mutiny mode aborted: no valid candidates for head loyalist.")
		return 0

	var/list/mutineer_candidates = get_head_mutineer_candidates()
	if(!mutineer_candidates || mutineer_candidates.len == 0)
		to_chat(world, "\red Mutiny mode aborted: no valid candidates for head mutineer.")
		return 0

	var/list/directive_candidates = get_directive_candidates()
	if(!directive_candidates || directive_candidates.len == 0)
		to_chat(world, "\red Mutiny mode aborted: no valid candidates for Directive X.")
		return 0

	head_loyalist = pick(loyalist_candidates)
	head_mutineer = pick(mutineer_candidates)
	current_directive = pick(directive_candidates)

	return 1

/datum/game_mode/mutiny/post_setup()
	equip_head_loyalist()
	equip_head_mutineer()

	loyalists+=head_loyalist
	mutineers+=head_mutineer

	replace_nuke_with_ead()
	current_directive.initialize()
	unbolt_vault_door()
	make_secret_transcript()

	update_all_icons()
	spawn(0)
		reveal_directives()
	..()

/mob/living/carbon/human/proc/recruit_loyalist()
	set name = "Recruit Loyalist"
	set category = "Mutiny"

	var/datum/game_mode/mutiny/mode = get_mutiny_mode()
	if (!mode || src != mode.head_loyalist.current)
		return

	var/list/candidates = list()
	for (var/mob/living/carbon/human/P in oview(src))
		if(!stat && P.client && mode.can_be_recruited(P.mind, "loyalist"))
			candidates += P

	if(!candidates.len)
		to_chat(src, "\red You aren't close enough to anybody that can be recruited.")
		return

	if(world.time < mode.recruit_loyalist_cooldown)
		to_chat(src, "\red Wait [MUTINY_RECRUITMENT_COOLDOWN] seconds before recruiting again.")
		return

	mode.recruit_loyalist_cooldown = world.time + (MUTINY_RECRUITMENT_COOLDOWN SECONDS)

	var/mob/living/carbon/human/M = input("Select a person to recruit", "Loyalist recruitment", null) as mob in candidates

	if (M)
		to_chat(src, "Attempting to recruit [M]...")
		log_admin("[key_name(src)] attempted to recruit [M] as a loyalist.")
		message_admins("\red [key_name_admin(src)] attempted to recruit [M] as a loyalist.")

		var/choice = alert(M, "Asked by [src]: Will you help me complete Directive X?", "Loyalist recruitment", "Yes", "No")
		if(choice == "Yes")
			mode.add_loyalist(M.mind)
		else if(choice == "No")
			to_chat(M, "\red You declined to join the loyalists.")
			to_chat(mode.head_loyalist.current, "\red <b>[M] declined to support the loyalists.</b>")

/mob/living/carbon/human/proc/recruit_mutineer()
	set name = "Recruit Mutineer"
	set category = "Mutiny"

	var/datum/game_mode/mutiny/mode = get_mutiny_mode()
	if (!mode || src != mode.head_mutineer.current)
		return

	var/list/candidates = list()
	for (var/mob/living/carbon/human/P in oview(src))
		if(!stat && P.client && mode.can_be_recruited(P.mind, "mutineer"))
			candidates += P

	if(!candidates.len)
		to_chat(src, "\red You aren't close enough to anybody that can be recruited.")
		return

	if(world.time < mode.recruit_mutineer_cooldown)
		to_chat(src, "\red Wait [MUTINY_RECRUITMENT_COOLDOWN] seconds before recruiting again.")
		return

	mode.recruit_mutineer_cooldown = world.time + (MUTINY_RECRUITMENT_COOLDOWN SECONDS)

	var/mob/living/carbon/human/M = input("Select a person to recruit", "Mutineer recruitment", null) as mob in candidates

	if (M)
		to_chat(src, "Attempting to recruit [M]...")
		log_admin("[key_name(src)] attempted to recruit [M] as a mutineer.")
		message_admins("\red [key_name_admin(src)] attempted to recruit [M] as a mutineer.")

		var/choice = alert(M, "Asked by [src]: Will you help me stop Directive X?", "Mutineer recruitment", "Yes", "No")
		if(choice == "Yes")
			mode.add_mutineer(M.mind)
		else if(choice == "No")
			to_chat(M, "\red You declined to join the mutineers.")
			to_chat(mode.head_mutineer.current, "\red <b>[M] declined to support the mutineers.</b>")

/proc/get_mutiny_mode()
	if(!ticker || !istype(ticker.mode, /datum/game_mode/mutiny))
		return null

	return ticker.mode
