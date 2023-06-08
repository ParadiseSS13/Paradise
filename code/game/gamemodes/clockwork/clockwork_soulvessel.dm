// Soul vessel (Posi Brain)
/obj/item/mmi/robotic_brain/clockwork
	name = "soul vessel"
	desc = "A heavy brass cube, three inches to a side, with a single protruding cogwheel."
	icon = 'icons/obj/clockwork.dmi'
	icon_state = "soul_vessel"
	blank_icon = "soul_vessel"
	searching_icon = "soul_vessel_search"
	occupied_icon = "soul_vessel_occupied"
	requires_master = FALSE
	ejected_flavor_text = "brass cube"
	dead_icon = "soul_vessel"
	clock = TRUE


/obj/item/mmi/robotic_brain/clockwork/proc/get_ghost(mob/living/M, mob/user)
	var/mob/dead/observer/chosen_ghost
	if(M.ghost_can_reenter())
		for(var/mob/dead/observer/ghost in GLOB.player_list)
			if(ghost.mind?.current == M && ghost.client)
				chosen_ghost = ghost
				break
	if(!chosen_ghost)
		icon_state = searching_icon
		searching = TRUE
		to_chat(user, "<span class='clocklarge'><b>Capture failed!</b></span> The soul has already fled its mortal frame. You attempt to bring it back...")
		var/list/candidates = SSghost_spawns.poll_candidates("Would you like to play as a Servant of Ratvar?", ROLE_CLOCKER, FALSE, poll_time = 10 SECONDS, source = /obj/item/mmi/robotic_brain/clockwork)
		if(length(candidates))
			chosen_ghost = pick(candidates)
		searching = FALSE
		if(!brainmob?.key)
			icon_state = blank_icon
	if(!M)
		return FALSE
	if(!chosen_ghost)
		visible_message("<span class='notice'>[src] buzzes quietly as the cog stops moving. Perhaps you could use it to capture another soul?</span>")
		return FALSE
	M.ckey = chosen_ghost.ckey
	transfer_personality(M)
	return TRUE


/obj/item/mmi/robotic_brain/clockwork/proc/try_to_transfer(mob/living/target, mob/user, obj/item/victim_brain)
	if(ishuman(target))
		for(var/obj/item/I in target)
			target.unEquip(I)
	if(target.client == null)
		target.dust()
		get_ghost(target, user)
	else
		target.dust()
		transfer_personality(target)
		to_chat(target, "<span class='clocklarge'><b>\"You belong to me now.\"</b></span>")
	if(victim_brain)
		QDEL_NULL(victim_brain)


/obj/item/mmi/robotic_brain/clockwork/transfer_personality(mob/candidate)
	searching = FALSE
	brainmob.key = candidate.key
	brainmob.name = "[pick(list("Nycun", "Oenib", "Havsbez", "Ubgry", "Fvreen"))]-[rand(10, 99)]"
	brainmob.real_name = brainmob.name
	name = "[src] ([brainmob.name])"
	brainmob.mind.assigned_role = "Soul Vessel Cube"
	visible_message("<span class='notice'>[src] chimes quietly.</span>")
	become_occupied(occupied_icon)
	if(SSticker.mode.add_clocker(brainmob.mind))
		brainmob.create_log(CONVERSION_LOG, "[brainmob.mind] been converted by [src.name]")


/obj/item/mmi/robotic_brain/clockwork/proc/init_transfer(mob/living/attacker, obj/item/victim_brain, mob/living/target_body)
	if(!isclocker(attacker))
		attacker.Weaken(5)
		attacker.emote("scream")
		to_chat(attacker, "<span class='userdanger'>Your body is wracked with debilitating pain!</span>")
		to_chat(attacker, "<span class='clocklarge'>\"Don't even try.\"</span>")
		return
	if(isdrone(attacker))
		to_chat(attacker, "<span class='warning'>You are not dexterous enough to do this!</span>")
		return
	if(brainmob.key)
		to_chat(attacker, "<span class='clock'>\"This vessel is filled, friend. Provide it with a body.\"</span>")
		return
	if(searching)
		to_chat(attacker, "<span class='clock'>\"Vessel is trying to catch a soul.\"</span>")
		return

	var/mob/living/living
	var/crosshair = target_body
	if(target_body)
		living = target_body
		if(living == attacker)
			return
		if(!living.mind)
			to_chat(attacker, "<span class='clock'>\"This body has no soul to catch.\"</span>")
			return
		if(living.stat == CONSCIOUS)
			to_chat(attacker, "<span class='warning'>[living] must be dead or unconscious for you to claim [living.p_their()] mind!</span>")
			return
		if(living.has_brain_worms())
			to_chat(attacker, "<span class='warning'>[living] is corrupted by an alien intelligence and cannot claim [living.p_their()] mind!</span>")
			return
	if(victim_brain)
		crosshair = victim_brain
		if(istype(victim_brain, /obj/item/mmi/robotic_brain))
			var/obj/item/mmi/robotic_brain/r_brain = victim_brain
			living = r_brain.brainmob
		if(istype(victim_brain, /obj/item/organ/internal/brain))
			var/obj/item/organ/internal/brain/o_brain = victim_brain
			living = o_brain.brainmob
		if(istype(victim_brain, /obj/item/organ/external/head))
			var/obj/item/organ/external/head/head = victim_brain
			var/obj/item/organ/internal/brain/h_brain = locate(/obj/item/organ/internal/brain) in head.contents
			if(!h_brain)
				to_chat(attacker, "<span class='warning'>There are no brains inside [head]!</span>")
				return
			crosshair = head
			victim_brain = h_brain
			living = h_brain.brainmob
		if(!living?.mind)
			to_chat(attacker, "<span class='clock'>\"This brain has no soul to catch.\"</span>")
			return
	if(jobban_isbanned(living, ROLE_CLOCKER) || jobban_isbanned(living, ROLE_SYNDICATE))
		to_chat(attacker, "<span class='warning'>A mysterious force prevents you from claiming [living]'s mind.</span>")
		return

	do_sparks(5, TRUE, crosshair)
	var/time = 4 SECONDS
	if(target_body)
		time = 9 SECONDS
		attacker.visible_message("<span class='warning'>[attacker] starts pressing [src] to [target_body]'s body, ripping through the surface</span>", \
		"<span class='clock'>You start extracting [target_body]'s consciousness from [target_body.p_their()] body.</span>")
	if(victim_brain)
		attacker.visible_message("<span class='warning'>[attacker] starts pressing [src] to [living]'s brain, ripping through the surface</span>", \
		"<span class='clock'>You start extracting [living]'s consciousness from [living.p_their()] brain.</span>")

	if(do_after(attacker, time, target = crosshair))
		if(brainmob.key)
			to_chat(attacker, "<span class='clock'>\"This vessel is filled, friend. Provide it with a body.\"</span>")
			return
		if(searching)
			to_chat(attacker, "<span class='clock'>\"Vessel is trying to catch a soul.\"</span>")
			return
		if(target_body && living.stat == CONSCIOUS)
			to_chat(attacker, "<span class='warning'>[living] must be dead or unconscious for you to claim [living.p_their()] mind!</span>")
			return
		if(target_body && living.has_brain_worms())
			to_chat(attacker, "<span class='warning'>[living] is corrupted by an alien intelligence and cannot claim [living.p_their()] mind!</span>")
			return
		to_chat(attacker, "<span class='clocklarge'>\"Keep doing it!\"</span>")
		try_to_transfer(living, attacker, victim_brain)
		return TRUE
	return FALSE


/obj/item/mmi/robotic_brain/clockwork/attack_self(mob/living/user)
	if(!isclocker(user))
		to_chat(user, "<span class='warning'>You fiddle around with [src], to no avail.</span>")
		return
	if(brainmob.key)
		to_chat(user, "<span class='clock'>\"This vessel is filled, friend. Provide it with a body.\"</span>")
		do_sparks(5, TRUE, user)
	else
		to_chat(user, "<span class='warning'>You have to find a body or brain to fill a vessel.</span>")


/obj/item/mmi/robotic_brain/clockwork/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/mmi/robotic_brain/clockwork))
		return FALSE

	// chaplain purifying
	if(istype(O, /obj/item/storage/bible) && !isclocker(user) && user.mind.isholy)
		to_chat(user, "<span class='notice'>You begin to exorcise [src].</span>")
		playsound(src, 'sound/hallucinations/veryfar_noise.ogg', 40, TRUE)
		if(do_after(user, 4 SECONDS, target = src))
			var/obj/item/mmi/robotic_brain/positronic/purified = new(get_turf(src))
			if(brainmob.key)
				SSticker.mode.remove_clocker(brainmob.mind)
				purified.transfer_identity(brainmob)
			QDEL_NULL(src)
			return TRUE
		return FALSE
	. = ..()


/obj/item/mmi/robotic_brain/attackby(obj/item/O, mob/user)
	// capturing robotic brains
	if(istype(O, /obj/item/mmi/robotic_brain/clockwork))
		var/obj/item/mmi/robotic_brain/clockwork/brain = O
		return brain.init_transfer(user, src)
	. = ..()


/obj/item/organ/internal/brain/attackby(obj/item/O, mob/user)
	// capturing organic brains
	if(istype(O, /obj/item/mmi/robotic_brain/clockwork))
		var/obj/item/mmi/robotic_brain/clockwork/brain = O
		return brain.init_transfer(user, src)
	. = ..()


/obj/item/organ/external/head/attackby(obj/item/O, mob/user)
	// heads have brains too!
	if(istype(O, /obj/item/mmi/robotic_brain/clockwork))
		var/obj/item/mmi/robotic_brain/clockwork/brain = O
		return brain.init_transfer(user, src)
	. = ..()


/obj/item/mmi/robotic_brain/clockwork/attack(mob/living/M, mob/living/user, def_zone)
	// catching souls of dead/unconscious humans and robots
	if(isrobot(M) || ishuman(M))
		return init_transfer(user, target_body = M)
	. = ..()
