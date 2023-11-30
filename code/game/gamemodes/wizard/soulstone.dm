// This whole file really needs reorganising at some point, or at the very least the construct stuff should be moved somewhere else.
/obj/item/soulstone
	name = "soul stone shard"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "soulstone"
	item_state = "electronic"
	belt_icon = "soulstone"
	var/icon_state_full = "soulstone2"
	desc = "A fragment of the legendary treasure known simply as the 'Soul Stone'. The shard still flickers with a fraction of the full artifact's power."
	w_class = WEIGHT_CLASS_TINY
	slot_flags = SLOT_FLAG_BELT
	origin_tech = "bluespace=4;materials=5"

	/// The body/brain of the player inside this construct, transferred over from the soulstone.
	var/atom/movable/held_body
	/// Does this soulstone ask the victim whether they want to be turned into a shade
	var/optional = FALSE
	/// Can this soul stone be used by anyone, or only cultists/wizards?
	var/usability = FALSE
	/// Can this soul stone be used more than once?
	var/reusable = TRUE
	/// If the soul stone can only be used once, has it been used?
	var/spent = FALSE

	/// For tracking during the 'optional' bit
	var/opt_in = FALSE
	var/purified = FALSE

/obj/item/soulstone/proc/add_held_body(atom/movable/body)
	held_body = body
	RegisterSignal(body, COMSIG_PARENT_QDELETING, PROC_REF(remove_held_body))

/obj/item/soulstone/proc/remove_held_body()
	SIGNAL_HANDLER
	held_body = null

/obj/item/soulstone/proc/can_use(mob/living/user)
	if(iscultist(user) && purified && !iswizard(user))
		return FALSE

	if(iscultist(user) || iswizard(user) || (HAS_MIND_TRAIT(user, TRAIT_HOLY) && purified) || usability)
		return TRUE

	return FALSE

/obj/item/soulstone/proc/was_used()
	if(!reusable)
		spent = TRUE
		name = "dull [name]"
		desc = "A fragment of the legendary treasure known simply as \
			the 'Soul Stone'. The shard lies still, dull and lifeless; \
			whatever spark it once held long extinguished."

/obj/item/soulstone/anybody
	usability = TRUE

/obj/item/soulstone/anybody/purified
	icon_state = "purified_soulstone"
	icon_state_full = "purified_soulstone2"
	purified = TRUE
	optional = TRUE

/obj/item/soulstone/anybody/purified/chaplain
	name = "mysterious old shard"
	reusable = FALSE

/obj/item/soulstone/pickup(mob/living/user)
	. = ..()
	if(iscultist(user) && purified && !iswizard(user))
		to_chat(user, "<span class='danger'>[src] reeks of holy magic. You will need to cleanse it with a ritual dagger before anything can be done with it.</span>")
		return
	if(HAS_MIND_TRAIT(user, TRAIT_HOLY))
		to_chat(user, "<span class='danger'>An overwhelming feeling of dread comes over you as you pick up [src]. It looks fragile enough to break with your hands.</span>")
		return
	if(!can_use(user))
		to_chat(user, "<span class='danger'>An overwhelming feeling of dread comes over you as you pick up [src].</span>")

/obj/item/soulstone/Destroy() //Stops the shade from being qdel'd immediately and their ghost being sent back to the arrival shuttle.
	for(var/mob/living/simple_animal/shade/A in src)
		A.death()
	remove_held_body()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/soulstone/process()
	. = ..()
	if(held_body)
		var/new_filter = isnull(get_filter("ray"))
		if(!purified)
			ray_filter_helper(1, 40,"#c926ae", 6, 20)
		else
			ray_filter_helper(1, 40,"#268dc9", 6, 20)
		if(new_filter)
			animate(get_filter("ray"), offset = 10, time = 10 SECONDS, loop = -1)
			animate(offset = 0, time = 10 SECONDS)

//////////////////////////////Capturing////////////////////////////////////////////////////////
/obj/item/soulstone/attack(mob/living/carbon/human/M, mob/living/user)
	if(M == user)
		return

	if(!can_use(user))
		user.Weaken(10 SECONDS)
		user.emote("scream")
		to_chat(user, "<span class='userdanger'>Your body is wracked with debilitating pain!</span>")
		return

	if(spent)
		to_chat(user, "<span class='warning'>There is no power left in the shard.</span>")
		return

	if(!ishuman(M)) //If target is not a human
		return ..()

	if(!M.mind)
		to_chat(user, "<span class='warning'>This being has no soul!</span>")
		return ..()

	if(jobban_isbanned(M, ROLE_CULTIST) || jobban_isbanned(M, ROLE_SYNDICATE))
		to_chat(user, "<span class='warning'>A mysterious force prevents you from trapping this being's soul.</span>")
		return ..()

	if(iscultist(user) && iscultist(M))
		to_chat(user, "<span class='cultlarge'>\"Come now, do not capture your fellow's soul.\"</span>")
		return ..()

	if(M.mind.offstation_role && M.mind.special_role != SPECIAL_ROLE_ERT)
		to_chat(user, "<span class='warning'>This being's soul seems worthless. Not even the stone will absorb it.</span>")
		return ..()

	if(optional)
		if(!M.ckey)
			to_chat(user, "<span class='warning'>They have no soul!</span>")
			return

		to_chat(user, "<span class='warning'>You attempt to channel [M]'s soul into [src]. You must give the soul some time to react and stand still...</span>")

		var/mob/player_mob = M
		var/ghost = M.get_ghost()
		if(ghost) // In case our player ghosted and we need to throw the alert at their ghost instead
			player_mob = ghost
		var/client/player_client = player_mob.client
		to_chat(player_mob, "<span class='warning'>[user] is trying to capture your soul into [src]! Click the button in the top right of the game window to respond.</span>")
		SEND_SOUND(player_client, sound('sound/misc/notice2.ogg'))
		window_flash(player_client)

		var/obj/screen/alert/notify_soulstone/A = player_mob.throw_alert("\ref[src]_soulstone_thingy", /obj/screen/alert/notify_soulstone)
		if(player_client.prefs && player_client.prefs.UI_style)
			A.icon = ui_style2icon(player_client.prefs.UI_style)

		// Pass the stuff to the alert itself
		A.stone = src
		A.stoner = user.real_name

		// Layer shenanigans to make the alert display the soulstone
		var/old_layer = layer
		var/old_plane = plane
		layer = FLOAT_LAYER
		plane = FLOAT_PLANE
		A.overlays += src
		layer = old_layer
		plane = old_plane

		// Give the victim 10 seconds to respond
		sleep(10 SECONDS)

		if(!opt_in)
			to_chat(user, "<span class='warning'>The soul resists your attempts at capturing it!</span>")
			return

		opt_in = FALSE

		if(spent)//checking one more time against shenanigans
			return

	add_attack_logs(user, M, "Stolestone'd with [name]")
	transfer_soul("VICTIM", M, user)
	return

/obj/item/soulstone/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/storage/bible) && !iscultist(user) && HAS_MIND_TRAIT(user, TRAIT_HOLY))
		if(purified)
			return
		to_chat(user, "<span class='notice'>You begin to exorcise [src].</span>")
		playsound(src, 'sound/hallucinations/veryfar_noise.ogg', 40, TRUE)
		if(do_after(user, 40, target = src))
			remove_filter("ray")
			usability = TRUE
			purified = TRUE
			optional = TRUE
			icon_state = "purified_soulstone"
			icon_state_full = "purified_soulstone2"
			for(var/mob/M in contents)
				if(M.mind)
					icon_state = "purified_soulstone2"
					if(iscultist(M))
						SSticker.mode.remove_cultist(M.mind, FALSE)
						to_chat(M, "<span class='userdanger'>An unfamiliar white light flashes through your mind, cleansing the taint of [SSticker.cultdat ? SSticker.cultdat.entity_title1 : "Nar'Sie"] \
									and the memories of your time as their servant with it.</span>")
						to_chat(M, "<span class='danger'>Assist [user], your saviour, and get vengeance on those who enslaved you!</span>")
					else
						to_chat(M, "<span class='danger'>Your soulstone has been exorcised, and you are now bound to obey [user]. </span>")

			for(var/mob/living/simple_animal/shade/EX in src)
				EX.holy = TRUE
				EX.icon_state = "shade_angelic"
			user.visible_message("<span class='notice'>[user] purifies [src]!</span>", "<span class='notice'>You purify [src]!</span>")

	else if(istype(O, /obj/item/melee/cultblade/dagger) && iscultist(user))
		if(!purified)
			return
		to_chat(user, "<span class='notice'>You begin to cleanse [src] of holy magic.</span>")
		if(do_after(user, 40, target = src))
			remove_filter("ray")
			usability = FALSE
			purified = FALSE
			optional = FALSE
			icon_state = "soulstone"
			icon_state_full = "soulstone2"
			for(var/mob/M in contents)
				if(M.mind)
					icon_state = "soulstone2"
					SSticker.mode.add_cultist(M.mind)
					to_chat(M, "<span class='cult'>Your shard has been cleansed of holy magic, and you are now bound to the cult's will. Obey them and assist in their goals.</span>")
			for(var/mob/living/simple_animal/shade/EX in src)
				EX.holy = FALSE
				EX.icon_state = SSticker.cultdat?.shade_icon_state
			to_chat(user, "<span class='notice'>You have cleansed [src] of holy magic.</span>")
	else
		..()

/obj/item/soulstone/attack_self(mob/living/user)
	var/mob/living/simple_animal/shade/S = locate(/mob/living/simple_animal/shade) in contents
	if(!in_range(src, user) || !S)
		return

	if(can_use(user))
		release_shades(user)
		return

	if(!HAS_MIND_TRAIT(user, TRAIT_HOLY))
		to_chat(user, "<span class='notice'>The shard feels too tough to shatter, you are not holy enough to free its captive!</span>")
		return

	if(!do_after_once(user, 10 SECONDS, FALSE, src) || !held_body)
		return

	user.visible_message("[user] shatters the soulstone apart! Releasing [held_body] from their prison!", "You shatter the soulstone holding [held_body], binding them free!", "You hear something shatter with a ghastly crack.")
	if(ismob(held_body))
		var/mob/M = held_body
		M.key = S.key
	else if(istype(held_body, /obj/item/organ/internal/brain))
		var/obj/item/organ/internal/brain/B = held_body
		B.brainmob.key = S.key
	S.cancel_camera()
	held_body.forceMove(get_turf(src))
	SSticker.mode.add_cult_immunity(held_body)
	remove_held_body()
	new /obj/effect/temp_visual/cult/sparks(get_turf(src))
	playsound(src, 'sound/effects/pylon_shatter.ogg', 40, TRUE)
	qdel(src)

/obj/item/soulstone/proc/release_shades(mob/user)
	for(var/mob/living/simple_animal/shade/A in src)
		A.forceMove(get_turf(user))
		A.cancel_camera()
		if(purified)
			icon_state = "purified_soulstone"
		else
			icon_state = "soulstone"
		name = initial(name)
		if(iscultist(A))
			to_chat(A, "<span class='userdanger'>You have been released from your prison, but you are still bound to the cult's will. Help them succeed in their goals at all costs.</span>")
		else
			to_chat(A, "<span class='userdanger'>You have been released from your prison, but you are still bound to your [purified ? "saviour" : "creator"]'s will.</span>")
		was_used()
		remove_filter("ray")
		STOP_PROCESSING(SSobj, src)

///////////////////////////Transferring to constructs/////////////////////////////////////////////////////
/obj/structure/constructshell
	name = "empty shell"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "construct-cult"
	desc = "A wicked machine used by those skilled in magical arts. It is inactive"
	/// Is someone currently placing a soulstone into the shell
	var/active = FALSE

/obj/structure/constructshell/examine(mob/user)
	. = ..()
	if(in_range(user, src) && (iscultist(user) || iswizard(user) || user.stat == DEAD))
		. += "<span class='cult'>A construct shell, used to house bound souls from a soulstone.</span>"
		. += "<span class='cult'>Placing a soulstone with a soul into this shell allows you to produce your choice of the following:</span>"
		. += "<span class='cultitalic'>An <b>Artificer</b>, which can produce <b>more shells and soulstones</b>, as well as fortifications.</span>"
		. += "<span class='cultitalic'>A <b>Wraith</b>, which does high damage and can jaunt through walls, though it is quite fragile.</span>"
		. += "<span class='cultitalic'>A <b>Juggernaut</b>, which is very hard to kill and can produce temporary walls, but is slow.</span>"

/obj/structure/constructshell/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/soulstone))
		var/obj/item/soulstone/SS = I
		if(!SS.can_use(user))
			to_chat(user, "<span class='danger'>An overwhelming feeling of dread comes over you as you attempt to place the soulstone into the shell.</span>")
			user.Confused(20 SECONDS)
			return
		SS.transfer_soul("CONSTRUCT", src, user)
		SS.was_used()
	else
		return ..()

////////////////////////////Proc for moving soul in and out off stone//////////////////////////////////////
// this whole proc is pain
/obj/item/soulstone/proc/transfer_soul(choice, target, mob/living/user)
	switch(choice)
		if("FORCE")
			var/mob/living/T = target
			T.grab_ghost(FALSE) // If they haven't DC'd or ahudded, put them back in their body
			if(T.client) // If there's someone in the body
				init_shade(T, user)
			else // Poll ghosts
				to_chat(user, "<span class='userdanger'>Capture failed!</span> The soul has already fled its mortal frame. You attempt to bring it back...")
				T.Paralyse(40 SECONDS)
				if(!get_cult_ghost(T, user, TRUE))
					add_held_body(T)
					T.forceMove(src) //If we can't get a ghost, shard the body anyways.
					START_PROCESSING(SSobj, src)

		if("VICTIM")
			var/mob/living/carbon/human/T = target
			if(T.stat == 0)
				to_chat(user, "<span class='danger'>Capture failed!</span> Kill or maim the victim first!")
			else
				if(!length(T.client_mobs_in_contents))
					to_chat(user, "<span class='warning'>They have no soul!</span>")
				else
					if(T.client == null)
						to_chat(user, "<span class='userdanger'>Capture failed!</span> The soul has already fled its mortal frame. You attempt to bring it back...")
						get_cult_ghost(T, user, get_new_player = !T.ghost_can_reenter())
					else
						if(length(contents))
							to_chat(user, "<span class='danger'>Capture failed!</span> The soul stone is full! Use or free an existing soul to make room.")
						else
							init_shade(T, user, TRUE)

		if("SHADE")
			var/mob/living/simple_animal/shade/T = target
			if(!can_use(user))
				user.Weaken(10 SECONDS)
				to_chat(user, "<span class='userdanger'>Your body is wracked with debilitating pain!</span>")
				return
			if(T.stat == DEAD)
				to_chat(user, "<span class='danger'>Capture failed!</span> The shade has already been banished!")
			if((iscultist(T) && purified) || (T.holy && !purified))
				to_chat(user, "<span class='danger'>Capture failed!</span> The shade recoils away from [src]!")
			else
				if(locate(/mob/living/simple_animal/shade) in contents)
					to_chat(user, "<span class='danger'>Capture failed!</span>: The soul stone is full! Use or free an existing soul to make room.")
				else
					T.forceMove(src) // Put the shade into the stone.
					T.health = T.maxHealth
					icon_state = icon_state_full
					name = "soulstone : [T.name]"
					to_chat(T, "<span class='notice'>Your soul has been recaptured by the soul stone, its arcane energies are reknitting your ethereal form</span>")
					to_chat(user, "<span class='notice'>Capture successful!</span> [T.name]'s has been recaptured and stored within the soul stone.")
					START_PROCESSING(SSobj, src)

		if("CONSTRUCT")
			var/obj/structure/constructshell/shell = target
			var/mob/living/simple_animal/shade/shade = locate() in src
			var/list/construct_types = list("Juggernaut" = /mob/living/simple_animal/hostile/construct/armoured,
											"Wraith" = /mob/living/simple_animal/hostile/construct/wraith,
											"Artificer" = /mob/living/simple_animal/hostile/construct/builder)
			/// Custom construct icons for different cults
			var/list/construct_icons = list("Juggernaut" = image(icon = 'icons/mob/cult.dmi', icon_state = SSticker.cultdat.get_icon("juggernaut")),
											"Wraith" = image(icon = 'icons/mob/cult.dmi', icon_state = SSticker.cultdat.get_icon("wraith")),
											"Artificer" = image(icon = 'icons/mob/cult.dmi', icon_state = SSticker.cultdat.get_icon("builder")))

			if(shade)
				var/construct_choice = show_radial_menu(user, shell, construct_icons, custom_check = CALLBACK(src, PROC_REF(radial_check), user), require_near = TRUE)
				var/picked_class = construct_types[construct_choice]
				if((picked_class && !QDELETED(shell) && !QDELETED(src)) && user.Adjacent(shell) && !user.incapacitated() && radial_check(user))
					var/mob/living/simple_animal/hostile/construct/C = new picked_class(shell.loc)
					C.init_construct(shade, src, shell)
					to_chat(C, C.playstyle_string)
					to_chat(C, "<span class='motd'>For more information, check the wiki page: ([GLOB.configuration.url.wiki_url]/index.php/Construct)</span>")
			else
				to_chat(user, "<span class='danger'>Creation failed!</span>: The soul stone is empty! Go kill someone!")

/obj/item/soulstone/proc/radial_check(mob/user)
	if(!ishuman(user)) // Should never happen, but just in case
		return FALSE

	var/mob/living/carbon/human/H = user
	if(!H.is_in_hands(src)) // Not holding the soulstone
		return FALSE
	return TRUE

/mob/living/simple_animal/hostile/construct/proc/init_construct(mob/living/simple_animal/shade/shade, obj/item/soulstone/SS, obj/structure/constructshell/shell)
	if(shade.mind)
		shade.mind.transfer_to(src)
	if(SS.purified)
		make_holy()
		// Replace regular soulstone summoning with purified soulstones
		if(is_type_in_list(/obj/effect/proc_holder/spell/aoe/conjure/build/soulstone, mob_spell_list))
			RemoveSpell(/obj/effect/proc_holder/spell/aoe/conjure/build/soulstone)
			AddSpell(new /obj/effect/proc_holder/spell/aoe/conjure/build/soulstone/holy)

	else if(iscultist(src)) // Re-grant cult actions, lost in the transfer
		var/datum/action/innate/cult/comm/CC = new
		var/datum/action/innate/cult/check_progress/D = new
		CC.Grant(src)
		D.Grant(src)
		SSticker.mode.cult_objs.study(src) // Display objectives again
		to_chat(src, "<span class='userdanger'>You are still bound to serve the cult, follow their orders and help them complete their goals at all costs.</span>")
	else
		to_chat(src, "<span class='userdanger'>You are still bound to serve your creator, follow their orders and help them complete their goals at all costs.</span>")
	SS.held_body.forceMove(src)
	add_held_body(SS.held_body)
	SS.remove_held_body()
	cancel_camera()
	qdel(shell)
	qdel(shade)
	qdel(SS)

/proc/make_new_construct(mob/living/simple_animal/hostile/construct/c_type, mob/target, mob/user, cult_override = FALSE, create_smoke = FALSE)
	if(jobban_isbanned(target, ROLE_CULTIST))
		return
	var/mob/living/simple_animal/hostile/construct/C = new c_type(get_turf(target))
	if(create_smoke)
		new /obj/effect/particle_effect/smoke/sleeping(target.loc)
	C.faction |= "\ref[user]"
	C.key = target.key
	if(user && iscultist(user) || cult_override)
		SSticker.mode.add_cultist(C.mind)
		SSticker.mode.update_cult_icons_added(C.mind)
	if(user && iscultist(user))
		to_chat(C, "<B>You are still bound to serve the cult, follow their orders and help them complete their goals at all costs.</B>")
	else
		to_chat(C, "<B>You are still bound to serve your creator, follow their orders and help them complete their goals at all costs.</B>")
	C.cancel_camera()

/obj/item/soulstone/proc/init_shade(mob/living/M, mob/user, forced = FALSE)
	START_PROCESSING(SSobj, src)
	var/type = get_shade_type()
	var/mob/living/simple_animal/shade/S = new type(src)
	S.name = "Shade of [M.real_name]"
	S.real_name = "Shade of [M.real_name]"
	S.key = M.key
	S.cancel_camera()
	name = "soulstone: [S.name]"
	icon_state = icon_state_full

	if(user)
		S.faction |= "\ref[user]" //Add the master as a faction, allowing inter-mob cooperation
		if(iswizard(user))
			SSticker.mode.update_wiz_icons_added(S.mind)
			S.mind.special_role = SPECIAL_ROLE_WIZARD_APPRENTICE
		if(iscultist(user))
			SSticker.mode.add_cultist(S.mind)
			S.mind.special_role = SPECIAL_ROLE_CULTIST
			S.mind.store_memory("<b>Serve the cult's will.</b>")
			to_chat(S, "<span class='userdanger'>Your soul has been captured! You are now bound to the cult's will. Help them succeed in their goals at all costs.</span>")
		else
			S.mind.store_memory("<b>Serve [user.real_name], your creator.</b>")
			to_chat(S, "<span class='userdanger'>Your soul has been captured! You are now bound to [user.real_name]'s will. Help them succeed in their goals at all costs.</span>")
	if(forced && user)
		to_chat(user, "<span class='info'><b>Capture successful!</b>:</span> [M.real_name]'s soul has been ripped from [user.p_their()] body and stored within the soul stone.")
	if(!isrobot(M))
		for(var/obj/item/I in M)
			M.unEquip(I)
	if(isbrain(M))
		var/obj/item/organ/internal/brain/brain_obj = M.loc
		add_held_body(brain_obj)
		brain_obj.forceMove(src)
	else
		add_held_body(M)
		M.forceMove(src)

/obj/item/soulstone/proc/get_shade_type()
	if(purified)
		return /mob/living/simple_animal/shade/holy
	return /mob/living/simple_animal/shade/cult

/obj/item/soulstone/proc/get_cult_ghost(mob/living/M, mob/user, get_new_player = FALSE)
	var/mob/dead/observer/chosen_ghost

	if(!get_new_player)
		for(var/mob/dead/observer/ghost in GLOB.player_list) // We put them back in their body
			if(ghost.mind && ghost.mind.current == M && ghost.client)
				chosen_ghost = ghost
				break

	if(!chosen_ghost) // Failing that, we grab a ghost
		var/list/consenting_candidates
		if(purified)
			consenting_candidates = SSghost_spawns.poll_candidates("Would you like to play as a Holy Shade?", ROLE_SENTIENT, FALSE, poll_time = 10 SECONDS, source = /mob/living/simple_animal/shade/holy, role_cleanname = "holy shade")
		else
			consenting_candidates = SSghost_spawns.poll_candidates("Would you like to play as a Shade?", ROLE_SENTIENT, FALSE, poll_time = 10 SECONDS, source = /mob/living/simple_animal/shade, role_cleanname = "shade")
		if(length(consenting_candidates))
			chosen_ghost = pick(consenting_candidates)
	if(!M)
		return FALSE
	if(!chosen_ghost)
		to_chat(user, "<span class='danger'>There were no spirits willing to become a shade.</span>")
		return FALSE
	if(length(contents)) //If they used the soulstone on someone else in the meantime
		return FALSE
	M.ckey = chosen_ghost.ckey
	dust_if_respawnable(chosen_ghost)
	init_shade(M, user)
	return TRUE
