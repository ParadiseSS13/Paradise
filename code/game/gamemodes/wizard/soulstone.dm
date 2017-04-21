/obj/item/device/soulstone
	name = "Soul Stone Shard"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "soulstone"
	item_state = "electronic"
	desc = "A fragment of the legendary treasure known simply as the 'Soul Stone'. The shard still flickers with a fraction of the full artifact's power."
	w_class = 1
	slot_flags = SLOT_BELT
	origin_tech = "bluespace=4;materials=4"
	var/imprinted = "empty"

	var/usability = TRUE // Can this soul stone be used by anyone, or only cultists/wizards?
	var/reusable = TRUE // Can this soul stone be used more than once?
	var/spent = FALSE // If the soul stone can only be used once, has it been used?

/obj/item/device/soulstone/proc/can_use(mob/living/user)
	if(iscultist(user) || iswizard(user) || usability)
		return TRUE

	return FALSE

/obj/item/device/soulstone/proc/was_used()
	if(!reusable)
		spent = TRUE
		name = "dull [name]"
		desc = "A fragment of the legendary treasure known simply as \
			the 'Soul Stone'. The shard lies still, dull and lifeless; \
			whatever spark it once held long extinguished."

/obj/item/device/soulstone/anybody
	usability = TRUE

/obj/item/device/soulstone/anybody/chaplain
	name = "mysterious old shard"
	reusable = FALSE

/obj/item/device/soulstone/pickup(mob/living/user)
	..()
	if(!can_use(user))
		to_chat(user, "<span class='danger'>An overwhelming feeling of dread comes over you as you pick up the soulstone. It would be wise to be rid of this quickly.</span>")
		user.Dizzy(120)

//////////////////////////////Capturing////////////////////////////////////////////////////////
/obj/item/device/soulstone/attack(mob/living/carbon/human/M as mob, mob/user as mob)
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
		to_chat(user, "<span class='cultlarge'>\"Come now, do not capture your fellow's soul.\</span>")
		return ..()

		M.create_attack_log("<font color='orange'>Has had their soul captured with [src.name] by [key_name(user)]</font>")
		user.create_attack_log("<font color='red'>Used the [src.name] to capture the soul of [key_name(M)]</font>")

	M.create_attack_log("<font color='orange'>Has had their soul captured with [src.name] by [key_name(user)]</font>")
	user.create_attack_log("<font color='red'>Used the [src.name] to capture the soul of [key_name(M)]</font>")
	log_attack("<font color='red'>[key_name(user)] used the [src.name] to capture the soul of [key_name(M)]</font>")

	transfer_soul("VICTIM", M, user)
	return

///////////////////Options for using captured souls///////////////////////////////////////
/obj/item/device/soulstone/attack_self(mob/user)
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

/obj/item/device/soulstone/Topic(href, href_list)
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
					to_chat(A, "<b>You have been released from your prison, but you are still bound to [usr.real_name]'s will. Help them succeed in their goals at all costs.</b>")
				else if(iscultist(usr))
					to_chat(A, "<b>You have been released from your prison, but you are still bound to the cult's will. Help them succeed in their goals at all costs.</b>")
				was_used()
	attack_self(U)

///////////////////////////Transferring to constructs/////////////////////////////////////////////////////
/obj/structure/constructshell
	name = "empty shell"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "construct"
	desc = "A wicked machine used by those skilled in magical arts. It is inactive"

/obj/structure/constructshell/examine(mob/user)
	if(..(user, 0))
		if(iscultist(user) || iswizard(user) || user.stat == DEAD)
			to_chat(user, "<span class='cult'>A construct shell, used to house bound souls from a soulstone.</span>")
			to_chat(user, "<span class='cult'>Placing a soulstone with a soul into this shell allows you to produce your choice of the following:</span>")
			to_chat(user, "<span class='cult'>An <b>Artificer</b>, which can produce <b>more shells and soulstones</b>, as well as fortifications.</span>")
			to_chat(user, "<span class='cult'>A <b>Wraith</b>, which does high damage and can jaunt through walls, though it is quite fragile.</span>")
			to_chat(user, "<span class='cult'>A <b>Juggernaut</b>, which is very hard to kill and can produce temporary walls, but is slow.</span>")

/obj/structure/constructshell/attackby(obj/item/O as obj, mob/user as mob, params)
	if(istype(O, /obj/item/device/soulstone))
		var/obj/item/device/soulstone/SS = O
		if(!SS.can_use(user))
			to_chat(user, "<span class='danger'>An overwhelming feeling of dread comes over you as you attempt to place the soulstone into the shell. It would be wise to be rid of this quickly.</span>")
			user.Dizzy(120)
			return
		SS.transfer_soul("CONSTRUCT",src,user)
		SS.was_used()
	else
		return ..()

////////////////////////////Proc for moving soul in and out off stone//////////////////////////////////////

/obj/item/proc/transfer_soul(var/choice as text, var/target, var/mob/U as mob).
	switch(choice)
		if("FORCE")
			var/obj/item/device/soulstone/C = src
			if(!iscarbon(target))		//TODO: Add sacrifice stoning for non-organics, just because you have no body doesnt mean you dont have a soul
				return 0
			if(contents.len)
				return 0
			var/mob/living/carbon/T = target
			if(T.client != null)
				for(var/obj/item/W in T)
					T.unEquip(W)
				C.init_shade(T, U)
				return 1
			else
				to_chat(U, "<span class='userdanger'>Capture failed!</span>: The soul has already fled its mortal frame. You attempt to bring it back...")
				return C.getCultGhost(T,U)

		if("VICTIM")
			var/mob/living/carbon/human/T = target
			var/obj/item/device/soulstone/C = src
			if(C.imprinted != "empty")
				to_chat(U, "<span class='danger'>Capture failed!</span>: The soul stone has already been imprinted with [C.imprinted]'s mind!")
			else
				if(T.stat == 0)
					to_chat(U, "<span class='danger'>Capture failed!</span>: Kill or maim the victim first!")
				else
					if(T.client == null)
						to_chat(U, "<span class='userdanger'>Capture failed!</span>: The soul has already fled its mortal frame. You attempt to bring it back...")
						C.getCultGhost(T,U)
					else
						if(C.contents.len)
							to_chat(U, "<span class='danger'>Capture failed!</span>: The soul stone is full! Use or free an existing soul to make room.")
						else
							for(var/obj/item/W in T)
								T.unEquip(W)
							C.init_shade(T, U, vic = 1)
							qdel(T)
		if("SHADE")
			var/mob/living/simple_animal/shade/T = target
			var/obj/item/device/soulstone/C = src
			if(T.stat == DEAD)
				to_chat(U, "<span class='danger'>Capture failed!</span>: The shade has already been banished!")
			else
				if(C.contents.len)
					to_chat(U, "<span class='danger'>Capture failed!</span>: The soul stone is full! Use or free an existing soul to make room.")
				else
					if(T.name != C.imprinted)
						to_chat(U, "<span class='danger'>Capture failed!</span>: The soul stone has already been imprinted with [C.imprinted]'s mind!")
					else
						T.loc = C //put shade in stone
						T.status_flags |= GODMODE
						T.canmove = 0
						T.health = T.maxHealth
						T.faction |= "\ref[U]"
						C.icon_state = "soulstone2"
						to_chat(T, "Your soul has been recaptured by the soul stone, its arcane energies are reknitting your ethereal form")
						to_chat(U, "<span class='notice'>Capture successful!</span>: [T.name]'s has been recaptured and stored within the soul stone.")
		if("CONSTRUCT")
			var/obj/structure/constructshell/T = target
			var/obj/item/device/soulstone/C = src
			var/mob/living/simple_animal/shade/A = locate() in C
			if(A)
				var/construct_class = alert(U, "Please choose which type of construct you wish to create.",,"Juggernaut","Wraith","Artificer")
				switch(construct_class)
					if("Juggernaut")
						var/mob/living/simple_animal/hostile/construct/armoured/Z = new /mob/living/simple_animal/hostile/construct/armoured (get_turf(T.loc))
						Z.key = A.key
						Z.faction |= "\ref[U]"
						if(iscultist(U))
							if(ticker.mode.name == "cult")
								ticker.mode:add_cultist(Z.mind)
							else
								ticker.mode.cult+=Z.mind
							ticker.mode.update_cult_icons_added(Z.mind)
						qdel(T)
						to_chat(Z, "<B>You are a Juggernaut. Though slow, your shell can withstand extreme punishment, create shield walls and even deflect energy weapons, and rip apart enemies and walls alike.</B>")
						to_chat(Z, "<B>You are still bound to serve your creator, follow their orders and help them complete their goals at all costs.</B>")
						Z.cancel_camera()
						qdel(C)

					if("Wraith")
						var/mob/living/simple_animal/hostile/construct/wraith/Z = new /mob/living/simple_animal/hostile/construct/wraith (get_turf(T.loc))
						Z.key = A.key
						Z.faction |= "\ref[U]"
						if(iscultist(U))
							if(ticker.mode.name == "cult")
								ticker.mode:add_cultist(Z.mind)
							else
								ticker.mode.cult+=Z.mind
							ticker.mode.update_cult_icons_added(Z.mind)
						qdel(T)
						to_chat(Z, "<B>You are a Wraith. Though relatively fragile, you are fast, deadly, and even able to phase through walls.</B>")
						to_chat(Z, "<B>You are still bound to serve your creator, follow their orders and help them complete their goals at all costs.</B>")
						Z.cancel_camera()
						qdel(C)

					if("Artificer")
						var/mob/living/simple_animal/hostile/construct/builder/Z = new /mob/living/simple_animal/hostile/construct/builder (get_turf(T.loc))
						Z.key = A.key
						Z.faction |= "\ref[U]"
						if(iscultist(U))
							if(ticker.mode.name == "cult")
								ticker.mode:add_cultist(Z.mind)
							else
								ticker.mode.cult+=Z.mind
							ticker.mode.update_cult_icons_added(Z.mind)
						qdel(T)
						to_chat(Z, "<B>You are an Artificer. You are incredibly weak and fragile, but you are able to construct fortifications, use magic missile, repair allied constructs (by clicking on them), </B><I>and most important of all create new constructs</I><B> (Use your Artificer spell to summon a new construct shell and Summon Soulstone to create a new soulstone).</B>")
						to_chat(Z, "<B>You are still bound to serve your creator, follow their orders and help them complete their goals at all costs.</B>")
						Z.cancel_camera()
						qdel(C)
			else
				to_chat(U, "<span class='danger'>Creation failed!</span>: The soul stone is empty! Go kill someone!")
	return

/proc/makeNewConstruct(var/mob/living/simple_animal/hostile/construct/ctype, var/mob/target, var/mob/stoner = null, cultoverride = 0)
	if(jobban_isbanned(target, "cultist") || jobban_isbanned(target, "Syndicate"))
		return
	var/mob/living/simple_animal/hostile/construct/newstruct = new ctype(get_turf(target))
	newstruct.faction |= "\ref[stoner]"
	newstruct.key = target.key
	if(stoner && iscultist(stoner) || cultoverride)
		if(ticker.mode.name == "cult")
			ticker.mode:add_cultist(newstruct.mind)
		else
			ticker.mode.cult+=newstruct.mind
		ticker.mode.update_cult_icons_added(newstruct.mind)
	if(stoner && iswizard(stoner))
		to_chat(newstruct, "<B>You are still bound to serve your creator, follow their orders and help them complete their goals at all costs.</B>")
	else if(stoner && iscultist(stoner))
		to_chat(newstruct, "<B>You are still bound to serve the cult, follow their orders and help them complete their goals at all costs.</B>")
	else
		to_chat(newstruct, "<B>You are still bound to serve your creator, follow their orders and help them complete their goals at all costs.</B>")
	newstruct.cancel_camera()

/obj/item/device/soulstone/proc/init_shade(mob/living/carbon/human/T, mob/U, vic = 0)
	new /obj/effect/decal/remains/human(T.loc) //Spawns a skeleton
	T.invisibility = 101
	var/atom/movable/overlay/animation = new /atom/movable/overlay( T.loc )
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = T
	flick("dust-h", animation)
	qdel(animation)
	var/mob/living/simple_animal/shade/S = new /mob/living/simple_animal/shade(src)
	S.status_flags |= GODMODE //So they won't die inside the stone somehow
	S.canmove = 0//Can't move out of the soul stone
	S.name = "Shade of [T.real_name]"
	S.real_name = "Shade of [T.real_name]"
	S.key = T.key
	if(U)
		S.faction |= "\ref[U]" //Add the master as a faction, allowing inter-mob cooperation
	if(U && iscultist(U))
		ticker.mode.add_cultist(S.mind, 0)
	S.cancel_camera()
	name = "soulstone: Shade of [T.real_name]"
	icon_state = "soulstone2"
	if(U && iswizard(U))
		to_chat(S, "Your soul has been captured! You are now bound to [U.real_name]'s will. Help them succeed in their goals at all costs.")
	else if(U && iscultist(U))
		to_chat(S, "Your soul has been captured! You are now bound to the cult's will. Help them succeed in their goals at all costs.")
	if(vic && U)
		to_chat(U, "<span class='info'><b>Capture successful!</b>:</span> [T.real_name]'s soul has been ripped from their body and stored within the soul stone.")

/obj/item/device/soulstone/proc/getCultGhost(mob/living/carbon/human/T, mob/U)
	var/mob/dead/observer/chosen_ghost

	for(var/mob/dead/observer/ghost in player_list) //We put them back in their body
		if(ghost.mind && ghost.mind.current == T && ghost.client)
			chosen_ghost = ghost
			break

	if(!chosen_ghost)	//Failing that, we grab a ghost
		var/list/consenting_candidates = pollCandidates("Would you like to play as a Shade?", "Cultist", null, ROLE_CULTIST, poll_time = 100)
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
	for(var/obj/item/W in T)
		T.unEquip(W)
	init_shade(T, U)
	qdel(T)
	return 1