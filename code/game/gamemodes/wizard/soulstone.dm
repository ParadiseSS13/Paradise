/obj/item/soulstone
	name = "Soul Stone Shard"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "soulstone"
	item_state = "electronic"
	desc = "A fragment of the legendary treasure known simply as the 'Soul Stone'. The shard still flickers with a fraction of the full artifact's power."
	w_class = WEIGHT_CLASS_TINY
	slot_flags = SLOT_BELT
	origin_tech = "bluespace=4;materials=5"

	var/optional = FALSE //does this soulstone ask the victim whether they want to be turned into a shade
	var/usability = FALSE // Can this soul stone be used by anyone, or only cultists/wizards?
	var/reusable = TRUE // Can this soul stone be used more than once?
	var/spent = FALSE // If the soul stone can only be used once, has it been used?

	var/opt_in = FALSE // for tracking during the 'optional' bit

/obj/item/soulstone/proc/can_use(mob/living/user)
	if(iscultist(user) || iswizard(user) || usability)
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

/obj/item/soulstone/anybody/chaplain
	name = "mysterious old shard"
	reusable = FALSE
	optional = TRUE

/obj/item/soulstone/pickup(mob/living/user)
	. = ..()
	if(!can_use(user))
		to_chat(user, "<span class='danger'>An overwhelming feeling of dread comes over you as you pick up the soulstone. It would be wise to be rid of this quickly.</span>")
		user.Dizzy(120)

//////////////////////////////Capturing////////////////////////////////////////////////////////
/obj/item/soulstone/attack(mob/living/carbon/human/M as mob, mob/user as mob)
	if(!can_use(user))
		user.Paralyse(5)
		to_chat(user, "<span class='userdanger'>Your body is wracked with debilitating pain!</span>")
		return

	if(spent)
		to_chat(user, "<span class='warning'>There is no power left in the shard.</span>")
		return

	if(!ishuman(M)) //If target is not a human
		return ..()

	if(M.has_brain_worms()) //Borer stuff - RR
		to_chat(user, "<span class='warning'>This being is corrupted by an alien intelligence and cannot be soul trapped.</span>")
		return ..()

	if(jobban_isbanned(M, "cultist") || jobban_isbanned(M, "Syndicate"))
		to_chat(user, "<span class='warning'>A mysterious force prevents you from trapping this being's soul.</span>")
		return ..()

	if(iscultist(user) && iscultist(M))
		to_chat(user, "<span class='cultlarge'>\"Come now, do not capture your fellow's soul.\"</span>")
		return ..()

		M.create_attack_log("<font color='orange'>Has had their soul captured with [src.name] by [key_name(user)]</font>")
		user.create_attack_log("<font color='red'>Used the [src.name] to capture the soul of [key_name(M)]</font>")

	if(optional)
		if(!M.ckey)
			to_chat(user, "<span class='warning'>They have no soul!</span>")
			return

		to_chat(user, "<span class='warning'>You attempt to channel [M]'s soul into [src]. You must give the soul some time to react and stand still...</span>")

		var/mob/player_mob = M
		if(M.get_ghost())//in case our player ghosted and we need to throw the alert at their ghost instead
			player_mob = M.get_ghost()
		var/client/player_client = player_mob.client
		to_chat(player_mob, "<span class='warning'>[user] is trying to capture your soul into [src]! Click the button in the top right of the game window to respond.</span>")
		player_client << 'sound/misc/notice2.ogg'
		window_flash(player_client)

		var/obj/screen/alert/notify_soulstone/A = player_mob.throw_alert("\ref[src]_soulstone_thingy", /obj/screen/alert/notify_soulstone)
		if(player_client.prefs && player_client.prefs.UI_style)
			A.icon = ui_style2icon(player_client.prefs.UI_style)

		//pass the stuff to the alert itself
		A.stone = src
		A.stoner = user.real_name

		//layer shenanigans to make the alert display the soulstone
		var/old_layer = layer
		var/old_plane = plane
		layer = FLOAT_LAYER
		plane = FLOAT_PLANE
		A.overlays += src
		layer = old_layer
		plane = old_plane

		//give the victim 10 seconds to respond
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

///////////////////Options for using captured souls///////////////////////////////////////
/obj/item/soulstone/attack_self(mob/user)
	if(!in_range(src, user))
		return

	if(!can_use(user))
		user.Paralyse(5)
		to_chat(user, "<span class='userdanger'>Your body is wracked with debilitating pain!</span>")
		return

	user.set_machine(src)
	var/dat = "<TT><B>Soul Stone</B><BR>"
	for(var/mob/living/simple_animal/shade/A in src)
		dat += "Captured Soul: [A.name]<br>"
		dat += {"<A href='byond://?src=[UID()];choice=Summon'>Summon Shade</A>"}
		dat += "<br>"
		dat += {"<a href='byond://?src=[UID()];choice=Close'> Close</a>"}
	user << browse(dat, "window=aicard")
	onclose(user, "aicard")
	return

/obj/item/soulstone/Topic(href, href_list)
	var/mob/U = usr
	if(!in_range(src, U) || U.machine != src || !can_use(usr))
		U << browse(null, "window=aicard")
		U.unset_machine()
		return

	add_fingerprint(U)
	U.set_machine(src)

	switch(href_list["choice"])//Now we switch based on choice.
		if("Close")
			U << browse(null, "window=aicard")
			U.unset_machine()
			return

		if("Summon")
			for(var/mob/living/simple_animal/shade/A in src)
				A.status_flags &= ~GODMODE
				A.canmove = 1
				A.forceMove(get_turf(usr))
				A.cancel_camera()
				icon_state = "soulstone"
				name = initial(name)
				if(iswizard(usr) || usability)
					to_chat(A, "<b>You have been released from your prison, but you are still bound to [usr.real_name]'s will. Help [usr.p_them()] succeed in [usr.p_their()] goals at all costs.</b>")
				else if(iscultist(usr))
					to_chat(A, "<b>You have been released from your prison, but you are still bound to the cult's will. Help [usr.p_them()] succeed in [usr.p_their()] goals at all costs.</b>")
				was_used()
	attack_self(U)

///////////////////////////Transferring to constructs/////////////////////////////////////////////////////
/obj/structure/constructshell
	name = "empty shell"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "construct-cult"
	desc = "A wicked machine used by those skilled in magical arts. It is inactive"

/obj/structure/constructshell/examine(mob/user)
	. = ..()
	if(in_range(user, src) && (iscultist(user) || iswizard(user) || user.stat == DEAD))
		. += "<span class='cult'>A construct shell, used to house bound souls from a soulstone.</span>"
		. += "<span class='cult'>Placing a soulstone with a soul into this shell allows you to produce your choice of the following:</span>"
		. += "<span class='cult'>An <b>Artificer</b>, which can produce <b>more shells and soulstones</b>, as well as fortifications.</span>"
		. += "<span class='cult'>A <b>Wraith</b>, which does high damage and can jaunt through walls, though it is quite fragile.</span>"
		. += "<span class='cult'>A <b>Juggernaut</b>, which is very hard to kill and can produce temporary walls, but is slow.</span>"

/obj/structure/constructshell/attackby(obj/item/O as obj, mob/user as mob, params)
	if(istype(O, /obj/item/soulstone))
		var/obj/item/soulstone/SS = O
		if(!SS.can_use(user))
			to_chat(user, "<span class='danger'>An overwhelming feeling of dread comes over you as you attempt to place the soulstone into the shell. It would be wise to be rid of this quickly.</span>")
			user.Dizzy(120)
			return
		SS.transfer_soul("CONSTRUCT",src,user)
		SS.was_used()
	else
		return ..()

////////////////////////////Proc for moving soul in and out off stone//////////////////////////////////////

/obj/item/proc/transfer_soul(var/choice as text, var/target, var/mob/U as mob)
	switch(choice)
		if("FORCE")
			var/obj/item/soulstone/SS = src
			var/mob/living/T = target
			if(T.client != null)
				SS.init_shade(T, U)
			else
				to_chat(U, "<span class='userdanger'>Capture failed!</span>: The soul has already fled its mortal frame. You attempt to bring it back...")
				T.Paralyse(20)
				if(!SS.getCultGhost(T,U))
					T.dust() //If we can't get a ghost, kill the sacrifice anyway.

		if("VICTIM")
			var/mob/living/carbon/human/T = target
			var/obj/item/soulstone/SS = src
			if(T.stat == 0)
				to_chat(U, "<span class='danger'>Capture failed!</span>: Kill or maim the victim first!")
			else
				if(!T.client_mobs_in_contents?.len)
					to_chat(U, "<span class='warning'>They have no soul!</span>")
				else
					if(T.client == null)
						to_chat(U, "<span class='userdanger'>Capture failed!</span>: The soul has already fled its mortal frame. You attempt to bring it back...")
						SS.getCultGhost(T,U)
					else
						if(SS.contents.len)
							to_chat(U, "<span class='danger'>Capture failed!</span>: The soul stone is full! Use or free an existing soul to make room.")
						else
							SS.init_shade(T, U, vic = 1)

		if("SHADE")
			var/mob/living/simple_animal/shade/T = target
			var/obj/item/soulstone/SS = src
			if(!SS.can_use(U))
				U.Paralyse(5)
				to_chat(U, "<span class='userdanger'>Your body is wracked with debilitating pain!</span>")
				return
			if(T.stat == DEAD)
				to_chat(U, "<span class='danger'>Capture failed!</span>: The shade has already been banished!")
			else
				if(SS.contents.len)
					to_chat(U, "<span class='danger'>Capture failed!</span>: The soul stone is full! Use or free an existing soul to make room.")
				else
					T.loc = SS //put shade in stone
					T.status_flags |= GODMODE
					T.canmove = 0
					T.health = T.maxHealth
					T.faction |= "\ref[U]"
					SS.icon_state = "soulstone2"
					to_chat(T, "Your soul has been recaptured by the soul stone, its arcane energies are reknitting your ethereal form")
					to_chat(U, "<span class='notice'>Capture successful!</span>: [T.name]'s has been recaptured and stored within the soul stone.")
		if("CONSTRUCT")
			var/obj/structure/constructshell/T = target
			var/obj/item/soulstone/SS = src
			var/mob/living/simple_animal/shade/SH = locate() in SS
			if(SH)
				var/construct_class = alert(U, "Please choose which type of construct you wish to create.",,"Juggernaut","Wraith","Artificer")
				switch(construct_class)
					if("Juggernaut")
						var/mob/living/simple_animal/hostile/construct/armoured/C = new /mob/living/simple_animal/hostile/construct/armoured (get_turf(T.loc))
						to_chat(C, "<B>You are a Juggernaut. Though slow, your shell can withstand extreme punishment, create shield walls and even deflect energy weapons, and rip apart enemies and walls alike.</B>")
						init_construct(C,SH,SS,T)

					if("Wraith")
						var/mob/living/simple_animal/hostile/construct/wraith/C = new /mob/living/simple_animal/hostile/construct/wraith (get_turf(T.loc))
						to_chat(C, "<B>You are a Wraith. Though relatively fragile, you are fast, deadly, and even able to phase through walls.</B>")
						init_construct(C,SH,SS,T)

					if("Artificer")
						var/mob/living/simple_animal/hostile/construct/builder/C = new /mob/living/simple_animal/hostile/construct/builder (get_turf(T.loc))
						to_chat(C, "<B>You are an Artificer. You are incredibly weak and fragile, but you are able to construct fortifications, use magic missile, repair allied constructs (by clicking on them), </B><I>and most important of all create new constructs</I><B> (Use your Artificer spell to summon a new construct shell and Summon Soulstone to create a new soulstone).</B>")
						init_construct(C,SH,SS,T)
			else
				to_chat(U, "<span class='danger'>Creation failed!</span>: The soul stone is empty! Go kill someone!")
	return

/proc/init_construct(mob/living/simple_animal/hostile/construct/C, mob/living/simple_animal/shade/SH, obj/item/soulstone/SS, obj/structure/constructshell/T)
	SH.mind.transfer_to(C)
	if(iscultist(C))
		var/datum/action/innate/cultcomm/CC = new()
			CC.Grant(C) //We have to grant the cult comms again because they're lost during the mind transfer.
	qdel(T)
	qdel(SH)
	to_chat(C, "<B>You are still bound to serve your creator, follow their orders and help them complete their goals at all costs.</B>")
	C.cancel_camera()
	qdel(SS)

/proc/makeNewConstruct(var/mob/living/simple_animal/hostile/construct/ctype, var/mob/target, var/mob/stoner = null, cultoverride = 0)
	if(jobban_isbanned(target, "cultist") || jobban_isbanned(target, "Syndicate"))
		return
	var/mob/living/simple_animal/hostile/construct/newstruct = new ctype(get_turf(target))
	newstruct.faction |= "\ref[stoner]"
	newstruct.key = target.key
	if(stoner && iscultist(stoner) || cultoverride)
		if(SSticker.mode.name == "cult")
			SSticker.mode:add_cultist(newstruct.mind)
		else
			SSticker.mode.cult+=newstruct.mind
		SSticker.mode.update_cult_icons_added(newstruct.mind)
	if(stoner && iswizard(stoner))
		to_chat(newstruct, "<B>You are still bound to serve your creator, follow their orders and help them complete their goals at all costs.</B>")
	else if(stoner && iscultist(stoner))
		to_chat(newstruct, "<B>You are still bound to serve the cult, follow their orders and help them complete their goals at all costs.</B>")
	else
		to_chat(newstruct, "<B>You are still bound to serve your creator, follow their orders and help them complete their goals at all costs.</B>")
	newstruct.cancel_camera()

/obj/item/soulstone/proc/init_shade(mob/living/T, mob/U, vic = 0)
	new /obj/effect/decal/remains/human(T.loc) //Spawns a skeleton
	T.invisibility = 101
	var/atom/movable/overlay/animation = new /atom/movable/overlay( T.loc )
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = T
	flick("dust-h", animation)
	qdel(animation)
	var/path = get_shade_type()
	var/mob/living/simple_animal/shade/S = new path(src)
	S.status_flags |= GODMODE //So they won't die inside the stone somehow
	S.canmove = 0//Can't move out of the soul stone
	S.name = "Shade of [T.real_name]"
	S.real_name = "Shade of [T.real_name]"
	S.key = T.key
	S.cancel_camera()
	name = "soulstone: Shade of [T.real_name]"
	icon_state = "soulstone2"
	if(U)
		S.faction |= "\ref[U]" //Add the master as a faction, allowing inter-mob cooperation
		if(iswizard(U))
			SSticker.mode.update_wiz_icons_added(S.mind)
			S.mind.special_role = SPECIAL_ROLE_WIZARD_APPRENTICE
		if(iscultist(U))
			SSticker.mode.add_cultist(S.mind, 0)
			S.mind.special_role = SPECIAL_ROLE_CULTIST
			S.mind.store_memory("<b>Serve the cult's will.</b>")
			to_chat(S, "Your soul has been captured! You are now bound to the cult's will. Help them succeed in their goals at all costs.")
		else
			S.mind.store_memory("<b>Serve [U.real_name], your creator.</b>")
			to_chat(S, "Your soul has been captured! You are now bound to [U.real_name]'s will. Help them succeed in their goals at all costs.")
	if(vic && U)
		to_chat(U, "<span class='info'><b>Capture successful!</b>:</span> [T.real_name]'s soul has been ripped from [U.p_their()] body and stored within the soul stone.")
	if(isrobot(T))//Robots have to dust or else they spill out an empty robot brain, and unequiping them spills robot components that shouldn't spawn.
		T.dust()
	else
		for(var/obj/item/W in T)
			T.unEquip(W)
		qdel(T)

/obj/item/soulstone/proc/get_shade_type()
	return /mob/living/simple_animal/shade/cult
	
/obj/item/soulstone/anybody/get_shade_type()
	return /mob/living/simple_animal/shade

/obj/item/soulstone/proc/getCultGhost(mob/living/T, mob/U)
	var/mob/dead/observer/chosen_ghost

	for(var/mob/dead/observer/ghost in GLOB.player_list) //We put them back in their body
		if(ghost.mind && ghost.mind.current == T && ghost.client)
			chosen_ghost = ghost
			break

	if(!chosen_ghost)	//Failing that, we grab a ghost
		var/list/consenting_candidates = pollCandidates("Would you like to play as a Shade?", ROLE_CULTIST, FALSE, poll_time = 100)
		if(consenting_candidates.len)
			chosen_ghost = pick(consenting_candidates)
	if(!T)
		return 0
	if(!chosen_ghost)
		to_chat(U, "<span class='danger'>There were no spirits willing to become a shade.</span>")
		return 0
	if(contents.len) //If they used the soulstone on someone else in the meantime
		return 0
	T.ckey = chosen_ghost.ckey
	init_shade(T, U)
	return 1
