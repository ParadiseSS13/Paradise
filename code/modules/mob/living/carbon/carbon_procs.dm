/mob/living/carbon/Initialize(mapload)
	. = ..()
	GLOB.carbon_list += src
	if(!loc && !(flags & ABSTRACT))
		stack_trace("Carbon mob being instantiated in nullspace")

/mob/living/carbon/Destroy()
	// This clause is here due to items falling off from limb deletion
	for(var/obj/item in get_all_slots())
		if(QDELETED(item))
			continue
		drop_item_to_ground(item, silent = TRUE)
		qdel(item)
	QDEL_LIST_CONTENTS(internal_organs)
	QDEL_LAZYLIST(stomach_contents)
	QDEL_LAZYLIST(processing_patches)
	GLOB.carbon_list -= src
	if(in_throw_mode)
		toggle_throw_mode()
	return ..()

/mob/living/carbon/ghostize(flags = GHOST_FLAGS_DEFAULT, ghost_name, ghost_color)
	if(in_throw_mode)
		toggle_throw_mode()
	return ..()

/mob/living/carbon/handle_atom_del(atom/A)
	LAZYREMOVE(processing_patches, A)
	return ..()

/mob/living/carbon/blob_act(obj/structure/blob/B)
	if(stat == DEAD)
		return
	else
		show_message("<span class='userdanger'>The blob attacks!</span>")
		adjustBruteLoss(10)

/mob/living/carbon/Move(NewLoc, direct)
	. = ..()
	if(.)
		if(nutrition && stat != DEAD)
			adjust_nutrition(-(hunger_drain * 0.1))
			if(m_intent == MOVE_INTENT_RUN)
				adjust_nutrition(-(hunger_drain * 0.1))
		if(HAS_TRAIT(src, TRAIT_FAT) && m_intent == MOVE_INTENT_RUN && bodytemperature <= 360)
			bodytemperature += 2

		// Moving around increases germ_level faster
		if(germ_level < GERM_LEVEL_MOVE_CAP && prob(8))
			germ_level++

#define STOMACH_ATTACK_DELAY 4

/mob/living/carbon/relaymove(mob/user, direction)
	if(LAZYLEN(stomach_contents))
		if(user in stomach_contents)
			if(last_stomach_attack + STOMACH_ATTACK_DELAY > world.time)
				return

			last_stomach_attack = world.time
			for(var/mob/M in hearers(4, src))
				if(M.client)
					M.show_message(text("<span class='warning'>You hear something rumbling inside [src]'s stomach...</span>"), 2)

			var/obj/item/I = user.get_active_hand()
			if(I && I.force)
				var/d = rand(round(I.force / 4), I.force)

				if(ishuman(src))
					var/mob/living/carbon/human/H = src
					var/obj/item/organ/external/organ = H.get_organ("chest")
					if(istype(organ))
						if(organ.receive_damage(d, 0))
							H.UpdateDamageIcon()

					H.updatehealth("stomach attack")

				else
					take_organ_damage(d)

				for(var/mob/M in viewers(user, null))
					if(M.client)
						M.show_message(text("<span class='warning'><b>[user] attacks [src]'s stomach wall with [I]!</b></span>"), 2)
				playsound(user.loc, 'sound/effects/attackblob.ogg', 50, 1)

				if(prob(getBruteLoss() - 50))
					gib()

#undef STOMACH_ATTACK_DELAY

/mob/living/carbon/proc/has_mutated_organs()
	return FALSE


/mob/living/carbon/proc/vomit(lost_nutrition = 10, blood = 0, should_confuse = TRUE, distance = 0, message = 1)
	. = TRUE

	if(stat == DEAD || ismachineperson(src)) // Dead people and IPCs do not vomit particulates
		return FALSE

	if(should_confuse)
		if(blood)
			KnockDown(10 SECONDS)
		AdjustConfused(8 SECONDS)
		Slowed(8 SECONDS, 1)

	if(!blood && nutrition < 100) // Nutrition vomiting while already starving
		if(message)
			visible_message("<span class='warning'>[src] dry heaves!</span>", \
							"<span class='userdanger'>You try to throw up, but there's nothing in your stomach!</span>")
		if(should_confuse)
			KnockDown(20 SECONDS)
			AdjustConfused(20 SECONDS)
		return

	if(message)
		visible_message("<span class='danger'>[src] throws up!</span>", \
						"<span class='userdanger'>You throw up!</span>")

	playsound(get_turf(src), 'sound/effects/splat.ogg', 50, 1)
	var/turf/T = get_turf(src)
	for(var/i = 0 to distance)
		if(blood)
			if(T)
				add_splatter_floor(T)
			blood_volume = max(blood_volume - lost_nutrition, 0)
			if(should_confuse)
				adjustBruteLoss(3)
		else
			if(T)
				T.add_vomit_floor()
			adjust_nutrition(-lost_nutrition)
			if(should_confuse)
				adjustToxLoss(-3)

		// Try to infect the people we hit with our viruses
		for(var/mob/living/carbon/to_infect in T.contents)
			for(var/datum/disease/illness in viruses)
				to_infect.ContractDisease(illness)

		T = get_step(T, dir)
		if(T.is_blocked_turf())
			break

/mob/living/carbon/gib()
	. = death(1)
	if(!.)
		return
	for(var/obj/item/organ/internal/I in internal_organs)
		if(isturf(loc))
			I.remove(src)
			I.forceMove(get_turf(src))
			I.throw_at(get_edge_target_turf(src,pick(GLOB.alldirs)),rand(1,3),5)

	for(var/mob/M in src)
		LAZYREMOVE(stomach_contents, M)
		M.forceMove(drop_location())
		visible_message("<span class='danger'>[M] bursts out of [src]!</span>")

///Adds to the parent by also adding functionality to propagate shocks through pulling and doing some fluff effects.
/mob/living/carbon/electrocute_act(shock_damage, source, siemens_coeff = 1, flags = NONE)
	. = ..()
	if(!.)
		return
	//Propagation through pulling
	if(!(flags & SHOCK_ILLUSION))
		var/list/shocking_queue = list()
		if(iscarbon(pulling) && source != pulling)
			shocking_queue += pulling
		if(iscarbon(pulledby) && source != pulledby)
			shocking_queue += pulledby
		if(iscarbon(buckled) && source != buckled)
			shocking_queue += buckled
		for(var/mob/living/carbon/carried in buckled_mobs)
			if(source != carried)
				shocking_queue += carried
		//Found our victims, now lets shock them all
		for(var/victim in shocking_queue)
			var/mob/living/carbon/C = victim
			C.electrocute_act(shock_damage * 0.75, src, 1, flags)

	// Minor shock - Jitters and Stutters
	var/jitter_amount = 0
	if(shock_damage >= SHOCK_MINOR)
		jitter_amount = shock_damage
		AdjustStuttering(4 SECONDS)

	// Moderate shock - Stun, knockdown, funny effect
	var/should_stun = FALSE
	var/stun_dur = 0 SECONDS
	var/icon/overlay_icon = null
	if(shock_damage >= SHOCK_MODERATE)
		should_stun = (!(flags & SHOCK_TESLA) || siemens_coeff > 0.5) && !(flags & SHOCK_NOSTUN)
		if(should_stun)
			stun_dur = max((shock_damage / 50) * 1 SECONDS, 4 SECONDS)
			Stun(stun_dur)
		if(shock_damage >= SHOCK_FLASH) // Arc flash explosion is instant, don't wait for the secondary shock and bypass the effect
			stun_dur = 0
		else
			overlay_icon = new('icons/effects/effects.dmi', "electrocution")
			overlays += overlay_icon
		emote("scream")
		AdjustStuttering(4 SECONDS)

	// Major Shock - YEET
	var/throw_distance = 0
	var/throw_dir = null
	if(shock_damage >= SHOCK_MAJOR && !(flags & SHOCK_ILLUSION))
		do_sparks(3, TRUE, src)
		AdjustStuttering(4 SECONDS)
		if(isatom(source))
			var/atom/shock_source = source
			throw_dir = get_dir(shock_source.loc, src)
			throw_distance = round(shock_damage / 10)

	addtimer(CALLBACK(src, PROC_REF(secondary_shock), jitter_amount, should_stun, throw_dir, throw_distance, overlay_icon), stun_dur)
	return shock_damage

/// Called after electrocute_act to apply secondary effects
/mob/living/carbon/proc/secondary_shock(jitter_amount, should_stun, throw_dir, throw_distance, overlay_icon)
	if(jitter_amount)
		AdjustJitter(jitter_amount)
	if(overlay_icon)
		overlays -= overlay_icon
	if(should_stun)
		KnockDown(6 SECONDS)
	if(throw_dir && throw_distance && !HAS_TRAIT(src, TRAIT_MAGPULSE)) // Don't yeet if they're wearing magboots
		var/turf/general_direction = get_edge_target_turf(src, throw_dir)
		src.throw_at(general_direction, throw_distance, throw_distance)

/mob/living/carbon/swap_hand()
	if(SEND_SIGNAL(src, COMSIG_MOB_SWAPPING_HANDS, get_active_hand()) == COMPONENT_BLOCK_SWAP)
		return
	hand = !hand
	update_hands_hud()
	r_hand?.on_hands_swap(src, hand == HAND_BOOL_RIGHT)
	l_hand?.on_hands_swap(src, hand == HAND_BOOL_LEFT)
	SEND_SIGNAL(src, COMSIG_CARBON_SWAP_HANDS)


/mob/living/carbon/activate_hand(selhand)
	if(selhand != hand)
		swap_hand()
		return TRUE
	return FALSE

/mob/living/carbon/proc/help_shake_act(mob/living/carbon/M)
	if(health < HEALTH_THRESHOLD_CRIT)
		return
	if(SEND_SIGNAL(src, COMSIG_CARBON_PRE_MISC_HELP, M) & COMPONENT_BLOCK_MISC_HELP)
		return
	if(src == M && ishuman(src))
		check_self_for_injuries()
		return
	if(player_logged)
		M.visible_message("<span class='notice'>[M] shakes [src], but [p_they()] [p_do()] not respond. Probably suffering from SSD.</span>", \
		"<span class='notice'>You shake [src], but [p_theyre()] unresponsive. Probably suffering from SSD.</span>")
	if(IS_HORIZONTAL(src)) // /vg/: For hugs. This is how update_icon figgers it out, anyway.  - N3X15
		add_attack_logs(M, src, "Shaked", ATKLOG_ALL)
		if(ishuman(src))
			var/mob/living/carbon/human/H = src
			if(H.w_uniform)
				H.w_uniform.add_fingerprint(M)
		AdjustSleeping(-10 SECONDS)
		AdjustParalysis(-6 SECONDS)
		AdjustStunned(-6 SECONDS)
		AdjustWeakened(-6 SECONDS)
		AdjustKnockDown(-6 SECONDS)
		adjustStaminaLoss(-10)
		resting = FALSE
		stand_up() // help them up if possible
		playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
		if(!player_logged)
			M.visible_message( \
				"<span class='notice'>[M] shakes [src] trying to wake [p_them()] up!</span>",\
				"<span class='notice'>You shake [src] trying to wake [p_them()] up!</span>",\
				)
		return
	// If it has any of the highfive statuses, dap, handshake, etc
	var/datum/status_effect/effect = has_status_effect_type(STATUS_EFFECT_HIGHFIVE)
	if(istype(effect, STATUS_EFFECT_OFFERING_EFTPOS))
		to_chat(M, "<span class='warning'>You need to have your ID in hand to scan it!</span>")
		return
	else if(effect)
		M.apply_status_effect(effect.type)
		return
	// BEGIN HUGCODE - N3X
	playsound(get_turf(src), 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
	if(M.zone_selected == "head")
		M.visible_message(\
		"<span class='notice'>[M] pats [src] on the head.</span>",\
		"<span class='notice'>You pat [src] on the head.</span>",\
		)
		return
	M.visible_message(\
	"<span class='notice'>[M] gives [src] a [pick("hug","warm embrace")].</span>",\
	"<span class='notice'>You hug [src].</span>",\
	)
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if(H.wear_suit)
			H.wear_suit.add_fingerprint(M)
		else if(H.w_uniform)
			H.w_uniform.add_fingerprint(M)

/**
  * Handles patting out a fire on someone.
  *
  * Removes 0.5 fire stacks per pat, with a 30% chance of the user burning their hand if they don't have adequate heat resistance.
  * Arguments:
  * * src - The mob doing the patting
  * * target - The mob who is currently on fire
  */
/mob/living/carbon/proc/pat_out(mob/living/target)
	if(target == src) // stop drop and roll, no trying to put out fire on yourself for free.
		to_chat(src, "<span class='warning'>Stop drop and roll!</span>")
		return
	var/self_message = "<span class='warning'>You try to extinguish [target]!</span>"
	if(prob(30) && ishuman(src)) // 30% chance of burning your hands
		var/mob/living/carbon/human/H = src
		var/protected = FALSE // Protected from the fire
		if((H.gloves?.max_heat_protection_temperature > 360) || HAS_TRAIT(H, TRAIT_RESISTHEAT) || HAS_TRAIT(H, TRAIT_RESISTHEATHANDS))
			protected = TRUE

		var/obj/item/organ/external/active_hand = H.get_active_hand()
		if(active_hand && !protected) // Wouldn't really work without a hand
			active_hand.receive_damage(0, 5)
			self_message = "<span class='danger'>You burn your hand trying to extinguish [target]!</span>"
			H.update_icons()

	visible_message("<span class='warning'>[src] tries to extinguish [target]!</span>", self_message)
	playsound(target, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
	target.adjust_fire_stacks(-0.5)

/mob/living/carbon/proc/check_self_for_injuries()
	var/mob/living/carbon/human/H = src
	visible_message("<span class='notice'>[src] examines [H.p_themselves()].</span>", \
		"<span class='notice'>You check yourself for injuries.</span>" \
		)
	var/list/status_list = list()

	var/list/missing = list("head", "chest", "groin", "l_arm", "r_arm", "l_hand", "r_hand", "l_leg", "r_leg", "l_foot", "r_foot")
	for(var/X in H.bodyparts)
		var/obj/item/organ/external/LB = X
		missing -= LB.limb_name
		var/status
		var/brutedamage = LB.brute_dam
		var/burndamage = LB.burn_dam

		switch(brutedamage)
			if(0.1 to 20)
				status = "bruised"
			if(20 to 40)
				status = "battered"
			if(40 to INFINITY)
				status = "mangled"
		if(brutedamage > 0.1 && (burndamage > 0.1 || LB.status & ORGAN_BURNT))
			status += " and "

		if(LB.status & ORGAN_BURNT)
			status += "critically burnt" + (LB.status & ORGAN_SALVED ? ", but salved" : "")
		else
			switch(burndamage)
				if(0.1 to 10)
					status += "numb"
				if(10 to 40)
					status += "blistered"
				if(40 to INFINITY)
					status += "peeling away"

		if(LB.status & ORGAN_MUTATED)
			status = "weirdly shapen"

		var/msg = "<span class='notice'>Your [LB.name] is OK.</span>"
		if(!isnull(status))
			msg = "<span class='warning'>Your [LB.name] is [status].</span>"
		status_list += msg

		for(var/obj/item/I in LB.embedded_objects)
			status_list += "\t<a href='byond://?src=[UID()];embedded_object=[I.UID()];embedded_limb=[LB.UID()]' class='warning'>There is \a [I] embedded in your [LB.name]!</a>"

	for(var/t in missing)
		status_list += "<span class='boldannounceic'>Your [parse_zone(t)] is missing!</span>"

	if(H.bleed_rate)
		status_list += "<span class='danger'>You are bleeding!</span>"
	if(staminaloss)
		if(staminaloss > 30)
			status_list += "<span class='notice'>You're completely exhausted.</span>"
		else
			status_list += "<span class='notice'>You feel fatigued.</span>"

	to_chat(src, chat_box_examine(status_list.Join("<br>")))

	if(HAS_TRAIT(H, TRAIT_SKELETONIZED) && (!H.w_uniform) && (!H.wear_suit))
		H.play_xylophone()

/mob/living/carbon/can_be_flashed(intensity = 1, override_blindness_check = 0)
	var/obj/item/organ/internal/eyes/E = get_int_organ(/obj/item/organ/internal/eyes)
	. = ..()

	if((E?.status & ORGAN_DEAD) || E?.is_broken() || !.)
		return FALSE

/mob/living/carbon/flash_eyes(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0, laser_pointer = FALSE, type = /atom/movable/screen/fullscreen/stretch/flash)
	//Parent proc checks if a mob can_be_flashed()
	. = ..()

	SEND_SIGNAL(src, COMSIG_CARBON_FLASH_EYES, laser_pointer)
	var/damage = intensity - check_eye_prot()
	var/extra_damage = 0
	if(.)
		if(visual)
			return

		//Checks that shouldn't stop flashing, but should stop eye damage, so they go here instead of in can_be_flashed()
		var/obj/item/organ/internal/eyes/E = get_int_organ(/obj/item/organ/internal/eyes)
		if(!E || E.weld_proof)
			return

		var/extra_darkview = 0
		if(E.see_in_dark)
			extra_darkview = max(E.see_in_dark - 2, 0)
			extra_damage = extra_darkview

		var/light_amount = 10 // assume full brightness
		if(isturf(loc))
			var/turf/T = loc
			light_amount = round(T.get_lumcount() * 10)

		// a dark view of 8, in full darkness, will result in maximum 1st tier damage
		var/extra_prob = (10 - light_amount) * extra_darkview

		switch(damage)
			if(1)
				to_chat(src, "<span class='warning'>Your eyes sting a little.</span>")
				var/minor_damage_multiplier = min(40 + extra_prob, 100) / 100
				var/minor_damage = minor_damage_multiplier * (1 + extra_damage)
				E.receive_damage(minor_damage, 1)
			if(2)
				to_chat(src, "<span class='warning'>Your eyes burn.</span>")
				E.receive_damage(rand(2, 4) + extra_damage, 1)

			else
				to_chat(src, "Your eyes itch and burn severely!</span>")
				E.receive_damage(rand(12, 16) + extra_damage, 1)

		if(E.damage > E.min_bruised_damage)
			AdjustEyeBlind(damage STATUS_EFFECT_CONSTANT)
			AdjustEyeBlurry(damage * rand(6 SECONDS, 12 SECONDS))

			if(E.damage > (E.min_bruised_damage + E.min_broken_damage) / 2)
				if(!E.is_robotic())
					to_chat(src, "<span class='warning'>Your eyes start to burn badly!</span>")
				else //snowflake conditions piss me off for the record
					to_chat(src, "<span class='warning'>The flash blinds you!</span>")

			else if(E.damage >= E.min_broken_damage)
				to_chat(src, "<span class='warning'>You can't see anything!</span>")

			else
				to_chat(src, "<span class='warning'>Your eyes are really starting to hurt. This can't be good for you!</span>")
		return 1

	else if(damage == 0) // just enough protection
		if(prob(20))
			to_chat(src, "<span class='notice'>Something bright flashes in the corner of your vision!</span>")


/mob/living/carbon/proc/tintcheck()
	return 0

/mob/living/carbon/proc/create_dna()
	if(!dna)
		dna = new()

/mob/living/carbon/proc/getDNA()
	return dna

/mob/living/carbon/proc/setDNA(datum/dna/newDNA)
	dna = newDNA


GLOBAL_LIST_INIT(ventcrawl_machinery, list(/obj/machinery/atmospherics/unary/vent_pump, /obj/machinery/atmospherics/unary/vent_scrubber))

/mob/living/handle_ventcrawl(atom/clicked_on) // Why is this proc even in carbon.dm ...
	if(!Adjacent(clicked_on))
		return

	var/ventcrawlerlocal = VENTCRAWLER_NONE
	if(ventcrawler)
		ventcrawlerlocal = ventcrawler

	if(ventcrawlerlocal == VENTCRAWLER_NONE) // You can't ventcrawl.
		return

	if(stat)
		to_chat(src, "You must be conscious to do this!")
		return

	if(!(mobility_flags & MOBILITY_MOVE))
		to_chat(src, "You can't vent crawl while you cannot move!")
		return

	if(has_buckled_mobs())
		to_chat(src, "<span class='warning'>You can't vent crawl with other creatures on you!</span>")
		return

	if(buckled)
		to_chat(src, "<span class='warning'>You can't vent crawl while buckled!</span>")
		return

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if(H.w_uniform && istype(H.w_uniform, /obj/item/clothing/under/rank/engineering/atmospheric_technician/contortionist))//IMMA SPCHUL SNOWFLAKE
			var/obj/item/clothing/under/rank/engineering/atmospheric_technician/contortionist/C = H.w_uniform
			if(!C.check_clothing(src))//return values confuse me right now
				return

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if(H.w_uniform && istype(H.w_uniform, /obj/item/clothing/under/plasmaman/atmospherics/contortionist))
			var/obj/item/clothing/under/plasmaman/atmospherics/contortionist/C = H.w_uniform
			if(!C.check_clothing(src))
				return


	var/obj/machinery/atmospherics/unary/vent_found

	if(clicked_on)
		vent_found = clicked_on
		if(!istype(vent_found) || !vent_found.can_crawl_through())
			vent_found = null


	if(!vent_found)
		for(var/obj/machinery/atmospherics/machine in range(1, src))
			if(is_type_in_list(machine, GLOB.ventcrawl_machinery) && machine.can_crawl_through())
				vent_found = machine
				break

	if(!vent_found)
		to_chat(src, "<span class='warning'>This ventilation duct is not connected to anything!</span>")
		return

	if(!vent_found.parent || !(length(vent_found.parent.members) || vent_found.parent.other_atmosmch))
		return

	visible_message("<span class='notice'>[src] begins climbing into the ventilation system...</span>", \
					"<span class='notice'>You begin climbing into the ventilation system...</span>")

#ifdef GAME_TESTS
	var/ventcrawl_delay = 0 SECONDS
#else
	var/ventcrawl_delay = 4.5 SECONDS
#endif
	if(ismorph(src))
		if(!do_after(src, ventcrawl_delay, target = src, hidden = TRUE))
			return
	else
		if(!do_after(src, ventcrawl_delay, target = src))
			return
	if(!vent_found.can_crawl_through() || QDELETED(vent_found))
		to_chat(src, "<span class='warning'>You can't vent crawl through that!</span>")
		return

	if(has_buckled_mobs())
		to_chat(src, "<span class='warning'>You can't vent crawl with other creatures on you!</span>")
		return

	if(buckled)
		to_chat(src, "<span class='warning'>You cannot crawl into a vent while buckled to something!</span>")
		return

	if(iscarbon(src) && length(contents) && ventcrawlerlocal < VENTCRAWLER_ALWAYS) // If we're here you can only ventcrawl while completely nude
		for(var/obj/item/I in contents)
			if(istype(I, /obj/item/bio_chip))
				continue
			if(istype(I, /obj/item/reagent_containers/patch))
				continue
			if(I.flags & ABSTRACT)
				continue

			to_chat(src, "<span class='warning'>You can't crawl around in the ventilation ducts with items!</span>")
			return

	visible_message("<b>[src] scrambles into the ventilation ducts!</b>", "You climb into the ventilation system.")
	forceMove(vent_found)
	add_ventcrawl(vent_found)

/mob/living/proc/add_ventcrawl(obj/machinery/atmospherics/starting_machine, obj/machinery/atmospherics/target_move)
	if(!istype(starting_machine) || !starting_machine.returnPipenet(target_move) || !starting_machine.can_see_pipes())
		return
	var/datum/pipeline/pipenet = starting_machine.returnPipenet(target_move)
	pipenet.add_ventcrawler(src)
	add_ventcrawl_images(pipenet)


/mob/living/proc/add_ventcrawl_images(datum/pipeline/pipenet)
	var/list/totalMembers = list()
	totalMembers |= pipenet.members
	totalMembers |= pipenet.other_atmosmch
	for(var/obj/machinery/atmospherics/A in totalMembers)
		if(!A.pipe_image)
			A.update_pipe_image()
		pipes_shown += A.pipe_image
		if(client)
			client.images += A.pipe_image

/mob/living/proc/remove_ventcrawl()
	SEND_SIGNAL(src, COMSIG_LIVING_EXIT_VENTCRAWL)
	remove_ventcrawl_images()

/mob/living/proc/remove_ventcrawl_images()
	if(client)
		for(var/image/current_image in pipes_shown)
			client.images -= current_image
		client.eye = src

	pipes_shown.len = 0

//OOP
/atom/proc/update_pipe_vision()
	return

/mob/living/update_pipe_vision(obj/machinery/atmospherics/target_move)
	if(!client)
		pipes_shown.Cut()
		return
	if(length(pipes_shown) && !target_move)
		if(!is_ventcrawling(src))
			remove_ventcrawl()
	else
		if(is_ventcrawling(src))
			var/obj/machinery/atmospherics/atmos_machine = loc
			if(!atmos_machine.can_see_pipes())
				return
			if(target_move)
				remove_ventcrawl_images()
			var/obj/machinery/atmospherics/current_pipe = loc
			var/datum/pipeline/pipenet = current_pipe.returnPipenet(target_move)
			add_ventcrawl_images(pipenet)


//Throwing stuff

/mob/living/carbon/throw_impact(atom/hit_atom, throwingdatum, speed = 1)
	. = ..()
	if(has_status_effect(STATUS_EFFECT_CHARGING))
		var/hit_something = FALSE
		if(ismovable(hit_atom))
			var/atom/movable/AM = hit_atom
			var/atom/throw_target = get_edge_target_turf(AM, dir)
			if(!AM.anchored || ismecha(AM))
				if(!HAS_TRAIT(src, TRAIT_PLAGUE_ZOMBIE))
					AM.throw_at(throw_target, 5, 12, src)
				hit_something = TRUE
		if(isobj(hit_atom))
			var/obj/O = hit_atom
			O.take_damage(150, BRUTE)
			hit_something = TRUE
		if(isliving(hit_atom))
			var/mob/living/L = hit_atom
			shake_camera(L, 4, 3)
			if(HAS_TRAIT(src, TRAIT_PLAGUE_ZOMBIE))
				var/obj/item/I = src.get_active_hand()
				if(I)
					I.attack(L, src)
				L.KnockDown(1 SECONDS)
			else
				L.adjustBruteLoss(60)
				L.KnockDown(12 SECONDS)
				L.Confused(10 SECONDS)
			hit_something = TRUE
		if(isturf(hit_atom))
			var/turf/T = hit_atom
			if(iswallturf(T))
				T.dismantle_wall(TRUE)
				hit_something = TRUE
		if(hit_something)
			playsound(get_turf(src), 'sound/effects/meteorimpact.ogg', 100, TRUE)
			visible_message("<span class='danger'>[src] slams into [hit_atom]!</span>", "<span class='userdanger'>You slam into [hit_atom]!</span>")
		return
	if(has_status_effect(STATUS_EFFECT_IMPACT_IMMUNE))
		return

	var/damage = 10 + 1.5 * speed // speed while thrower is standing still is 2, while walking with an aggressive grab is 2.4, highest speed is 14

	hit_atom.hit_by_thrown_mob(src, throwingdatum, damage, FALSE, FALSE)

/mob/living/carbon/hit_by_thrown_mob(mob/living/C, datum/thrownthing/throwingdatum, damage, mob_hurt, self_hurt)
	for(var/obj/item/dualsaber/D in contents)
		if(HAS_TRAIT(D, TRAIT_WIELDED) && D.force)
			visible_message("<span class='danger'>[src] impales [C] with [D], before dropping them on the ground!</span>")
			C.apply_damage(100, BRUTE, "chest", sharp = TRUE, used_weapon = "Impaled on [D].")
			C.Stun(2 SECONDS) //Punishment. This could also be used by a traitor to throw someone into a dsword to kill them, but hey, teamwork!
			C.KnockDown(6 SECONDS)
			D.melee_attack_chain(src, C) //attack animation / jedi spin
			C.emote("scream")
			return
	. = ..()
	KnockDown(3 SECONDS)

/mob/living/carbon/proc/toggle_throw_mode()
	if(in_throw_mode)
		throw_mode_off()
	else
		throw_mode_on()
	var/obj/item/I = get_active_hand()
	if(I)
		SEND_SIGNAL(I, COMSIG_CARBON_TOGGLE_THROW, in_throw_mode)

/mob/living/carbon/proc/throw_mode_off()
	in_throw_mode = FALSE
	if(throw_icon) //in case we don't have the HUD and we use the hotkey
		throw_icon.icon_state = "act_throw_off"
	remove_mousepointer(MP_THROW_MODE_PRIORITY)

/mob/living/carbon/proc/throw_mode_on()
	SIGNAL_HANDLER //This signal is here so we can turn throw mode back on via carp when an object is caught
	in_throw_mode = TRUE
	if(throw_icon)
		throw_icon.icon_state = "act_throw_on"
	add_mousepointer(MP_THROW_MODE_PRIORITY, 'icons/mouse_icons/cult_target.dmi')

/mob/proc/throw_item(atom/target)
	return

/mob/living/carbon/throw_item(atom/target)
	if(!target || !isturf(loc) || is_screen_atom(target))
		throw_mode_off()
		return

	var/obj/item/I = get_active_hand()

	if(!I || I.override_throw(src, target) || (I.flags & NODROP))
		throw_mode_off()
		return

	throw_mode_off()
	var/atom/movable/thrown_thing

	if(istype(I, /obj/item/grab))
		var/obj/item/grab/G = I
		var/mob/throwable_mob = G.get_mob_if_throwable() //throw the person instead of the grab
		qdel(G)	//We delete the grab.
		if(throwable_mob)
			thrown_thing = throwable_mob
			if(HAS_TRAIT(src, TRAIT_PACIFISM))
				to_chat(src, "<span class='notice'>You gently let go of [throwable_mob].</span>")
				return
			var/turf/start_T = get_turf(loc) //Get the start and target tile for the descriptors
			var/turf/end_T = get_turf(target)
			throwable_mob.forceMove(start_T)
			if(start_T && end_T)
				var/start_T_descriptor = "<font color='#6b5d00'>tile at [start_T.x], [start_T.y], [start_T.z] in area [get_area(start_T)]</font>"
				var/end_T_descriptor = "<font color='#6b4400'>tile at [end_T.x], [end_T.y], [end_T.z] in area [get_area(end_T)]</font>"

				add_attack_logs(src, throwable_mob, "Thrown from [start_T_descriptor] with the target [end_T_descriptor]")

	else if(!(I.flags & ABSTRACT)) //can't throw abstract items
		thrown_thing = I
		drop_item_to_ground(I, silent = TRUE)

		if(HAS_TRAIT(src, TRAIT_PACIFISM) && I.throwforce)
			to_chat(src, "<span class='notice'>You set [I] down gently on the ground.</span>")
			return

	if(QDELETED(thrown_thing))
		return

	if(!HAS_TRAIT(thrown_thing, TRAIT_NO_THROWN_MESSAGE))
		visible_message("<span class='danger'>[src] has thrown [thrown_thing].</span>")
	newtonian_move(get_dir(target, src))
	thrown_thing.throw_at(target, thrown_thing.throw_range, thrown_thing.throw_speed, src, null, null, null, move_force)
	thrown_thing.scatter_atom()

/mob/living/carbon/can_use_hands()
	if(handcuffed)
		return FALSE
	if(buckled && ! istype(buckled, /obj/structure/chair)) // buckling does not restrict hands
		return FALSE
	return TRUE

/mob/living/carbon/restrained()
	if(get_restraining_item())
		return TRUE
	return FALSE

/mob/living/carbon/get_restraining_item()
	return handcuffed

/mob/living/carbon/unequip_to(obj/item/target, atom/destination, force = FALSE, silent = FALSE, drop_inventory = TRUE, no_move = FALSE)
	. = ..()

	if(!. || !target) //We don't want to set anything to null if the parent returned 0.
		return

	if(target == back)
		back = null
		update_inv_back()
	else if(target == wear_mask)
		if(ishuman(src)) //If we don't do this hair won't be properly rebuilt.
			return
		wear_mask = null
		update_inv_wear_mask()
	else if(target == handcuffed)
		handcuffed = null
		if(buckled && buckled.buckle_requires_restraints)
			unbuckle()
		update_handcuffed()
	else if(target == legcuffed)
		legcuffed = null
		toggle_move_intent()
		update_inv_legcuffed()

/mob/living/carbon/update_inv_legcuffed()
	clear_alert("legcuffed")
	if(!legcuffed)
		return
	throw_alert("legcuffed", /atom/movable/screen/alert/restrained/legcuffed, new_master = legcuffed)
	if(m_intent != MOVE_INTENT_WALK)
		m_intent = MOVE_INTENT_WALK
		if(hud_used?.move_intent)
			hud_used.move_intent.icon_state = "walking"

/mob/living/carbon/get_item_by_slot(slot_id)
	switch(slot_id)
		if(ITEM_SLOT_BACK)
			return back
		if(ITEM_SLOT_MASK)
			return wear_mask
		if(ITEM_SLOT_OUTER_SUIT)
			return wear_suit
		if(ITEM_SLOT_LEFT_HAND)
			return l_hand
		if(ITEM_SLOT_RIGHT_HAND)
			return r_hand
		if(ITEM_SLOT_HANDCUFFED)
			return handcuffed
		if(ITEM_SLOT_LEGCUFFED)
			return legcuffed
	return null

/mob/living/carbon/get_slot_by_item(obj/item/looking_for)
	if(looking_for == back)
		return ITEM_SLOT_BACK

	// if(back && (looking_for in back))
	// 	return ITEM_SLOT_BACKPACK

	if(looking_for == wear_mask)
		return ITEM_SLOT_MASK

	if(looking_for == head)
		return ITEM_SLOT_HEAD

	return ..()

//generates realistic-ish pulse output based on preset levels
/mob/living/carbon/proc/get_pulse()
	var/temp = 0
	switch(pulse)
		if(PULSE_NONE)
			return "0"
		if(PULSE_SLOW)
			temp = rand(40, 60)
			return num2text(temp)
		if(PULSE_NORM)
			temp = rand(60, 90)
			return num2text(temp)
		if(PULSE_FAST)
			temp = rand(90, 120)
			return num2text(temp)
		if(PULSE_2FAST)
			temp = rand(120, 160)
			return num2text(temp)
		if(PULSE_THREADY)
			return ">250"

/mob/living/carbon/proc/canBeHandcuffed()
	return FALSE

/mob/living/carbon/fall()
	..()
	loc.handle_fall()//it's loc so it doesn't call the mob's handle_fall which does nothing

/mob/living/carbon/is_muzzled()
	return(istype(wear_mask, /obj/item/clothing/mask/muzzle))

/mob/living/carbon/is_facehugged()
	return istype(wear_mask, /obj/item/clothing/mask/facehugger)

/mob/living/carbon/resist_buckle()
	INVOKE_ASYNC(src, PROC_REF(resist_muzzle))
	var/breakout_time = 0
	var/obj/item/restraints = get_restraining_item()

	if(istype(restraints, /obj/item/clothing/suit/straight_jacket))
		var/obj/item/clothing/suit/straight_jacket/jacket = restraints
		jacket.breakouttime = breakout_time

	else if(istype(restraints, /obj/item/restraints))
		var/obj/item/restraints/cuffs = restraints
		breakout_time = cuffs.breakouttime

	else if(isstructure(buckled))
		var/obj/structure/struct = buckled
		breakout_time = struct.unbuckle_time

	if(!breakout_time)
		buckled.user_unbuckle_mob(src, src)
		return

	if(has_status_effect(STATUS_EFFECT_UNBUCKLE))
		to_chat(src, "<span class='notice'>You are already trying to unbuckle!</span>")
		return
	apply_status_effect(STATUS_EFFECT_UNBUCKLE)

	visible_message("<span class='warning'>[src] attempts to unbuckle [p_themselves()]!</span>",
				"<span class='notice'>You attempt to unbuckle yourself... (This will take around [breakout_time / 10] seconds and you need to stay still.)</span>")
	if(!do_after(src, breakout_time, FALSE, src, allow_moving = TRUE, extra_checks = list(CALLBACK(src, PROC_REF(buckle_check))), allow_moving_target = TRUE, hidden = TRUE))
		if(src && buckled)
			to_chat(src, "<span class='warning'>You fail to unbuckle yourself!</span>")
	else
		if(!buckled)
			return
		buckled.user_unbuckle_mob(src, src)

	remove_status_effect(STATUS_EFFECT_UNBUCKLE)

/mob/living/carbon/proc/buckle_check()
	if(!buckled) // No longer buckled
		return TRUE
	return FALSE

/mob/living/carbon/proc/muzzle_check()
	if(!is_muzzled()) // No longer muzzled
		return TRUE
	return FALSE

/mob/living/carbon/resist_fire()
	if(IsKnockedDown())
		return
	fire_stacks -= 5
	Weaken (2 SECONDS, TRUE) //Your busy dying from fire, no way you could be able to roll and reach for a snack in your bag
	KnockDown(6 SECONDS, TRUE) //Ok now you can have that snack if you want
	spin(32, 2)
	visible_message("<span class='danger'>[src] rolls on the floor, trying to put [p_themselves()] out!</span>",
		"<span class='notice'>You stop, drop, and roll!</span>")
	addtimer(CALLBACK(src, PROC_REF(extinguish_roll), 3 SECONDS))

/mob/living/carbon/proc/extinguish_roll()
	if(fire_stacks <= 0)
		visible_message("<span class='danger'>[src] has successfully extinguished [p_themselves()]!</span>","<span class='notice'>You extinguish yourself.</span>")
		ExtinguishMob()

/mob/living/carbon/resist_restraints(attempt_breaking)
	INVOKE_ASYNC(src, PROC_REF(resist_muzzle))
	if(wear_suit && wear_suit.breakouttime)
		wear_suit.resist_restraints(src, attempt_breaking)
		return

	var/obj/item/restraints/cuffs
	if(handcuffed)
		cuffs = handcuffed
	else if(legcuffed)
		cuffs = legcuffed

	if(!cuffs)
		return
	cuff_resist(cuffs, attempt_breaking)

/mob/living/carbon/resist_muzzle()
	if(!istype(wear_mask, /obj/item/clothing/mask/muzzle))
		return
	var/obj/item/clothing/mask/muzzle/I = wear_mask
	var/time = I.resist_time
	if(I.resist_time == 0)//if it's 0, you can't get out of it
		to_chat(src, "[I] is too well made, you'll need hands for this one!")
		return
	if(has_status_effect(STATUS_EFFECT_REMOVE_MUZZLE))
		to_chat(src, "<span class='notice'>You are already trying to remove [I]!</span>")
		return
	apply_status_effect(STATUS_EFFECT_REMOVE_MUZZLE)
	visible_message("<span class='warning'>[src] gnaws on [I], trying to remove it!</span>")
	to_chat(src, "<span class='notice'>You attempt to remove [I]... (This will take around [time/10] seconds and you need to stand still.)</span>")
	if(do_after(src, time, FALSE, src, extra_checks = list(CALLBACK(src, PROC_REF(muzzle_check))), hidden = TRUE))
		visible_message("<span class='warning'>[src] removes [I]!</span>")
		to_chat(src, "<span class='notice'>You get rid of [I]!</span>")
		if(I.security_lock)
			I.do_break()
		drop_item_to_ground(I)
	remove_status_effect(STATUS_EFFECT_REMOVE_MUZZLE)

/mob/living/carbon/proc/cuff_resist(obj/item/restraints/restraints, break_cuffs)
	var/effective_breakout_time = restraints.breakouttime
	if(break_cuffs)
		effective_breakout_time = 5 SECONDS

	if(has_status_effect(STATUS_EFFECT_REMOVE_CUFFS))
		to_chat(src, "<span class='notice'>You are already trying to [break_cuffs ? "break" : "remove"] [restraints].</span>")
		return

	apply_status_effect(STATUS_EFFECT_REMOVE_CUFFS)

	restraints.attempt_resist_restraints(src, break_cuffs, effective_breakout_time)

//called when we get cuffed/uncuffed
/mob/living/carbon/proc/update_handcuffed()
	SEND_SIGNAL(src, COMSIG_CARBON_UPDATE_HANDCUFFED, handcuffed)
	if(handcuffed)
		drop_r_hand()
		drop_l_hand()
		stop_pulling()
		throw_alert("handcuffed", /atom/movable/screen/alert/restrained/handcuffed, new_master = handcuffed)
		ADD_TRAIT(src, TRAIT_RESTRAINED, "handcuffed")
	else
		REMOVE_TRAIT(src, TRAIT_RESTRAINED, "handcuffed")
		clear_alert("handcuffed")
		changeNext_move(CLICK_CD_RAPID) //reset click cooldown from handcuffs
	update_action_buttons_icon() //some of our action buttons might be unusable when we're handcuffed.
	update_inv_handcuffed()
	update_hands_hud()

// Called to escape a cryocell
/mob/living/carbon/proc/cryo_resist(obj/machinery/atmospherics/unary/cryo_cell/cell)
	var/effective_breakout_time = 1 MINUTES
	if(stat != UNCONSCIOUS)
		effective_breakout_time = 5 SECONDS

	if(has_status_effect(STATUS_EFFECT_EXIT_CRYOCELL))
		to_chat(src, "<span class='notice'>You are already trying to exit [cell].</span>")
		return

	apply_status_effect(STATUS_EFFECT_EXIT_CRYOCELL)
	cell.attempt_escape(src, effective_breakout_time)

/mob/living/carbon/get_standard_pixel_y_offset()
	if(IS_HORIZONTAL(src))
		if(buckled)
			return buckled.buckle_offset
		else
			return PIXEL_Y_OFFSET_LYING
	return initial(pixel_y)

/mob/living/carbon/emp_act(severity)
	..()
	if(HAS_TRAIT(src, TRAIT_EMP_IMMUNE))
		return
	if(HAS_TRAIT(src, TRAIT_EMP_RESIST))
		severity = clamp(severity, EMP_LIGHT, EMP_WEAKENED)
	for(var/X in internal_organs)
		var/obj/item/organ/internal/O = X
		O.emp_act(severity)

/mob/living/carbon/get_status_tab_items()
	var/list/status_tab_data = ..()
	. = status_tab_data
	var/obj/item/organ/internal/alien/plasmavessel/vessel = get_int_organ(/obj/item/organ/internal/alien/plasmavessel)
	if(vessel)
		status_tab_data[++status_tab_data.len] = list("Plasma Stored:", "[vessel.stored_plasma]/[vessel.max_plasma]")

/mob/living/carbon/get_all_slots()
	return list(l_hand,
				r_hand,
				handcuffed,
				legcuffed,
				back,
				wear_mask)
/**
 * Clears a carbon mob's handcuffs and legcuffs, dropping them to the ground.
 *
 * Arguments:
 * * show_message - if TRUE, will display a visible message when restraints are removed. FALSE by default.
 *
 * Returns:
 * * TRUE if handcuffs or legcuffs were removed, FALSE otherwise
 */
/mob/living/carbon/proc/clear_restraints(show_message = FALSE)
	. = clear_handcuffs(show_message)
	. |= clear_legcuffs(show_message)

/**
 * Removes a carbon's handcuffs, dropping them to the ground. Calls update_handcuffed(). Unbuckles if handcuffs were necessary for the buckle (pipe buckling, etc.)
 *
 * Arguments:
 * * show_message - if TRUE, will display a visible message when restraints are removed. FALSE by default.
 *
 * Returns:
 * * TRUE if handcuffs existed and were successfully removed, FALSE otherwise
 */
/mob/living/carbon/proc/clear_handcuffs(show_message = FALSE)
	if(!handcuffed)
		return FALSE

	var/obj/item/W = handcuffed
	if(isnull(W))
		return FALSE

	handcuffed = null
	if(buckled && buckled.buckle_requires_restraints)
		unbuckle()
	update_handcuffed()

	if(client)
		client.screen -= W

	if(show_message)
		visible_message("<span class='warning'>[src] slips out of [W]!</span>")

	W.forceMove(drop_location())
	W.dropped(src)
	if(W)
		W.layer = initial(W.layer)
		W.plane = initial(W.plane)

	return TRUE

/**
 * Removes a carbon's legcuffs, dropping them to the ground. Calls update_inv_legcuffed().
 *
 * Arguments:
 * * show_message - if TRUE, will display a visible message when restraints are removed. FALSE by default.
 *
 * Returns:
 * * TRUE if legcuffs existed and were successfully removed, FALSE otherwise
 */
/mob/living/carbon/proc/clear_legcuffs(show_message = FALSE)
	if(!legcuffed)
		return FALSE

	var/obj/item/W = legcuffed
	if(isnull(W))
		return FALSE

	legcuffed = null
	toggle_move_intent()
	update_inv_legcuffed()

	if(client)
		client.screen -= W

	if(show_message)
		visible_message("<span class='warning'>[W] falls off of [src]!</span>")

	W.forceMove(drop_location())
	W.dropped(src)
	if(W)
		W.layer = initial(W.layer)
		W.plane = initial(W.plane)

	return TRUE


/mob/living/carbon/proc/slip(description, knockdown, tilesSlipped, walkSafely, slipAny, slipVerb = "slip")
	if(HAS_TRAIT(src, TRAIT_FLYING) || buckled || (walkSafely && m_intent == MOVE_INTENT_WALK))
		return FALSE

	if(IS_HORIZONTAL(src) && !tilesSlipped)
		return FALSE

	if(!(slipAny))
		if(ishuman(src))
			var/mob/living/carbon/human/H = src
			if(HAS_TRAIT(H, TRAIT_NOSLIP))
				return FALSE

	if(tilesSlipped)
		for(var/i in 1 to tilesSlipped)
			spawn(i)
				step(src, dir)

	stop_pulling()
	to_chat(src, "<span class='notice'>You [slipVerb]ped on [description]!</span>")
	playsound(loc, 'sound/misc/slip.ogg', 50, TRUE, -3)
	// Something something don't run with scissors
	moving_diagonally = 0 //If this was part of diagonal move slipping will stop it.
	KnockDown(knockdown)
	return TRUE

/mob/living/carbon/proc/shock_reduction()
	return 0

/mob/living/carbon/proc/can_eat(flags = 255)
	return TRUE

/mob/living/carbon/proc/eat(obj/item/food/to_eat, mob/user, bitesize_override)
	if(!istype(to_eat))
		return FALSE

	var/fullness = nutrition + 10
	if(istype(to_eat, /obj/item/food))
		for(var/datum/reagent/consumable/C in reagents.reagent_list) // We add the nutrition value of what we're currently digesting
			fullness += C.nutriment_factor * C.volume / (C.metabolization_rate * metabolism_efficiency)

	if(user == src)
		if(!selfFeed(to_eat, fullness))
			return FALSE
	else
		if(!forceFed(to_eat, user, fullness))
			return FALSE

	consume(to_eat, bitesize_override)
	SSticker.score.score_food_eaten++
	return TRUE

/mob/living/carbon/proc/drink(obj/item/reagent_containers/drinks/to_drink, mob/user, drinksize_override)
	if(user == src)
		if(!selfDrink(to_drink))
			return FALSE
	else if(!forceFed(to_drink, user, nutrition))
		return FALSE

	if(to_drink.consume_sound)
		playsound(loc, to_drink.consume_sound, rand(10, 50), TRUE)
	if(to_drink.reagents.total_volume)
		taste(to_drink.reagents)
		var/drink_size = max(initial(to_drink.amount_per_transfer_from_this), 5)
		if(drinksize_override)
			drink_size = drinksize_override
		to_drink.reagents.reaction(src, REAGENT_INGEST)
		to_drink.reagents.trans_to(src, drink_size)

	SSticker.score.score_food_eaten++
	return TRUE

/mob/living/carbon/proc/selfFeed(obj/item/food/to_eat, fullness)
	if(to_eat.junkiness && satiety < -150 && nutrition > NUTRITION_LEVEL_STARVING + 50)
		to_chat(src, "<span class='notice'>You don't feel like eating any more junk food at the moment.</span>")
		return FALSE

	var/list/reaction_msg = list()
	if(fullness <= 50)
		reaction_msg += "You hungrily chew out a piece of [to_eat] and gobble it!"
		to_chat(src, "<span class='warning'></span>")
	else if(fullness > 50 && fullness < 150)
		reaction_msg += "You hungrily begin to eat [to_eat]."
	else if(fullness > 150 && fullness < 500)
		reaction_msg += "You take a bite of [to_eat]."
	else if(fullness > 500 && fullness < 600)
		reaction_msg += "You unwillingly chew a bit of [to_eat]."
	else if(fullness > (600 * (1 + overeatduration / 2000))) // The more you eat - the more you can eat
		to_chat(src, "<span class='warning'>You cannot force any more of [to_eat] to go down your throat.</span>")
		return FALSE

	to_chat(src, "<span class='notice'>[jointext(reaction_msg, " ")]</span>")

	return TRUE

/mob/living/carbon/proc/selfDrink(obj/item/reagent_containers/drinks/toDrink, mob/user)
	return TRUE

/mob/living/carbon/proc/forceFed(obj/item/reagent_containers/to_eat, mob/user, fullness)
	if(fullness > (600 * (1 + overeatduration / 1000)))
		visible_message("<span class='warning'>[user] cannot force anymore of [to_eat] down [src]'s throat.</span>")
		return FALSE

	visible_message("<span class='warning'>[user] attempts to force [src] to swallow [to_eat].</span>")
	if(!do_after(user, 3 SECONDS, TRUE, src))
		return FALSE
	forceFedAttackLog(to_eat, user)
	visible_message("<span class='warning'>[user] forces [src] to swallow [to_eat].</span>")
	return TRUE

/mob/living/carbon/proc/forceFedAttackLog(obj/item/reagent_containers/to_eat, mob/user)
	add_attack_logs(user, src, "Fed [to_eat]. Reagents: [to_eat.reagents.log_list(to_eat)]", to_eat.reagents.harmless_helper() ? ATKLOG_ALMOSTALL : null)

/*TO DO - If/when stomach organs are introduced, override this at the human level sending the item to the stomach
so that different stomachs can handle things in different ways VB*/
/mob/living/carbon/proc/consume(obj/item/food/to_eat, bitesize_override)
	var/this_bite = bitesize_override || to_eat.bitesize
	if(!to_eat.reagents)
		return
	if(satiety > -200)
		satiety -= to_eat.junkiness
	if(to_eat.consume_sound)
		playsound(loc, to_eat.consume_sound, rand(10, 50), TRUE)
	if(to_eat.reagents.total_volume)
		taste(to_eat.reagents)
		var/fraction = min(this_bite / to_eat.reagents.total_volume, 1)
		to_eat.reagents.reaction(src, REAGENT_INGEST, fraction)
		to_eat.reagents.trans_to(src, this_bite)

/mob/living/carbon/get_access()
	. = ..()

	var/obj/item/RH = get_active_hand()
	if(RH)
		. |= RH.GetAccess()

	var/obj/item/LH = get_inactive_hand()
	if(LH)
		. |= LH.GetAccess()

/mob/living/carbon/proc/can_breathe_gas()
	if(HAS_TRAIT(src, TRAIT_NOBREATH) || wear_mask?.flags & BLOCK_GAS_SMOKE_EFFECT || head?.flags & BLOCK_GAS_SMOKE_EFFECT || internal)
		return FALSE

	return TRUE

//to recalculate and update the mob's total tint from tinted equipment it's wearing.
/mob/living/carbon/proc/update_tint()
	var/tinttotal = get_total_tint()
	if(tinttotal >= TINT_BLIND)
		become_blind("tint")
	else if(tinttotal >= TINT_IMPAIR)
		overlay_fullscreen("tint", /atom/movable/screen/fullscreen/stretch/impaired, 2)
		cure_blind("tint")
	else
		clear_fullscreen("tint", 0)
		cure_blind("tint")

/mob/living/carbon/proc/get_total_tint()
	. = 0
	if(istype(head, /obj/item/clothing/head))
		var/obj/item/clothing/head/HT = head
		. += HT.tint
	if(ismask(wear_mask))
		var/obj/item/clothing/mask/worn_mask = wear_mask
		. += worn_mask.tint

	var/obj/item/organ/internal/eyes/E = get_organ_slot("eyes")
	if(E)
		. += E.tint

/mob/living/carbon/human/get_total_tint()
	. = ..()
	if(glasses)
		var/obj/item/clothing/glasses/G = glasses
		. += G.tint


//handle stuff to update when a mob equips/unequips a mask.
/mob/living/proc/wear_mask_update(obj/item/clothing/C, toggle_off = 1)
	update_inv_wear_mask()

/mob/living/carbon/wear_mask_update(obj/item/clothing/C, toggle_off = 1)
	if(istype(C) && (C.tint || initial(C.tint)))
		update_tint()
	update_inv_wear_mask()

//handle stuff to update when a mob equips/unequips a headgear.
/mob/living/carbon/proc/head_update(obj/item/I, forced)
	if(isclothing(I))
		var/obj/item/clothing/C = I
		if(C.tint || initial(C.tint))
			update_tint()
		update_sight()
	if(I.flags_inv & HIDEMASK || forced)
		update_inv_wear_mask()
	update_inv_head()

/mob/living/carbon/update_sight()
	if(!client)
		return

	if(stat == DEAD)
		grant_death_vision()
		return

	see_invisible = initial(see_invisible)
	see_in_dark = initial(see_in_dark)
	sight = initial(sight)
	lighting_alpha = initial(lighting_alpha)

	if(client.eye != src)
		var/atom/A = client.eye
		if(A.update_remote_sight(src)) //returns 1 if we override all other sight updates.
			return

	if(HAS_TRAIT(src, TRAIT_THERMAL_VISION))
		sight |= (SEE_MOBS)
		lighting_alpha = min(lighting_alpha, LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)

	if(HAS_TRAIT(src, TRAIT_XRAY_VISION))
		sight |= (SEE_TURFS|SEE_MOBS|SEE_OBJS)
		see_in_dark = max(see_in_dark, 8)

	if(HAS_TRAIT(src, TRAIT_MESON_VISION))
		sight |= SEE_TURFS
		lighting_alpha = min(lighting_alpha, LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)

	if(HAS_TRAIT(src, TRAIT_NIGHT_VISION))
		see_in_dark = max(see_in_dark, 8)
		lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE

	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_SIGHT)
	sync_lighting_plane_alpha()

/mob/living/carbon/ExtinguishMob()
	for(var/X in get_equipped_items())
		var/obj/item/I = X
		I.acid_level = 0 //washes off the acid on our clothes
		I.extinguish() //extinguishes our clothes
	..()

/mob/living/carbon/clean_blood(radiation_clean = FALSE, clean_hands = TRUE, clean_mask = TRUE, clean_feet = TRUE)
	if(head)
		if(head.clean_blood(radiation_clean))
			update_inv_head()
		if(head.flags_inv & HIDEMASK)
			clean_mask = FALSE
	if(wear_suit)
		if(wear_suit.clean_blood(radiation_clean))
			update_inv_wear_suit()
		if(wear_suit.flags_inv & HIDESHOES)
			clean_feet = FALSE
		if(wear_suit.flags_inv & HIDEGLOVES)
			clean_hands = FALSE
	..(clean_hands, clean_mask, clean_feet)

/mob/living/carbon/fall_and_crush(turf/target_turf, crush_damage, should_crit, crit_damage_factor, datum/tilt_crit/forced_crit, weaken_time, knockdown_time, ignore_gravity, should_rotate = TRUE, angle)
	// keep most of what's passed in, but don't change the angle
	. = ..(target_turf, crush_damage, should_crit, crit_damage_factor, forced_crit, weaken_time, knockdown_time, should_rotate = FALSE, rightable = FALSE)
	KnockDown(10 SECONDS)

/mob/living/carbon/rename_character(oldname, newname)
	. = ..()
	if(!.)
		return

	for(var/obj/item/organ/internal/IO in internal_organs)
		if(IO.dna?.real_name == oldname)
			IO.dna.real_name = newname

/// Returns TRUE if an air tank compatible mask or breathing tube is equipped.
/mob/living/carbon/proc/can_breathe_internals()
	return can_breathe_tube() || can_breathe_mask() || can_breathe_helmet()

/// Returns TRUE if an air tank compatible helmet is equipped.
/mob/living/carbon/proc/can_breathe_helmet()
	return (isclothing(head) && (head.flags & AIRTIGHT))

/// Returns TRUE if an air tank compatible mask is equipped.
/mob/living/carbon/proc/can_breathe_mask()
	return (isclothing(wear_mask) && (wear_mask.flags & AIRTIGHT))

/// Returns TRUE if a breathing tube is equipped.
/mob/living/carbon/proc/can_breathe_tube()
	return get_organ_slot("breathing_tube")

/mob/living/carbon/proc/lazrevival(mob/living/carbon/M)
	if(M.get_ghost()) // ghosted after the timer expires.
		M.visible_message("<span class='warning'>[M]'s body stops twitching as the Lazarus Reagent loses potency.</span>")
		return

	// If the ghost has re-entered the body, perform the revival!
	M.visible_message("<span class='success'>[M] gasps as they return to life!</span>")
	M.adjustCloneLoss(50)
	M.setOxyLoss(0)
	M.adjustBruteLoss(rand(0, 15))
	M.adjustToxLoss(rand(0, 15))
	M.adjustFireLoss(rand(0, 15))
	M.do_jitter_animation(200)

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/necrosis_prob = 15 * H.decaylevel
		H.decaylevel = 0
		for(var/obj/item/organ/O in (H.bodyparts | H.internal_organs))
			if(prob(necrosis_prob) && !O.is_robotic() && !O.vital)
				O.necrotize(FALSE)
				if(O.status & ORGAN_DEAD)
					O.germ_level = INFECTION_LEVEL_THREE
		H.update_body()

	M.grab_ghost()
	M.update_revive()
	add_attack_logs(M, M, "Revived with Lazarus Reagent")
	SSblackbox.record_feedback("tally", "players_revived", 1, "lazarus_reagent")

/mob/living/carbon/is_inside_mob(atom/thing)
	if(!(..()))
		return FALSE
	if(head && head.UID() == thing.UID())
		return FALSE
	if(wear_suit && wear_suit.UID() == thing.UID())
		return FALSE
	return TRUE

/mob/living/carbon/proc/get_thermal_protection() // Xenos got nothin
	return 0

/mob/living/carbon/vv_get_dropdown()
	. = ..()

	VV_DROPDOWN_OPTION(VV_HK_GIVEMARTIALART, "Give Martial Art")
	VV_DROPDOWN_OPTION(VV_HK_ADDORGAN, "Add Organ")
	VV_DROPDOWN_OPTION(VV_HK_REMORGAN, "Remove Organ")

/mob/living/carbon/vv_do_topic(list/href_list)
	. = ..()

	if(!.)
		return

	if(href_list[VV_HK_GIVEMARTIALART])
		if(!check_rights(R_SERVER|R_EVENT))
			return

		var/list/artpaths = subtypesof(/datum/martial_art)
		var/list/artnames = list()
		for(var/i in artpaths)
			var/datum/martial_art/M = i
			artnames[initial(M.name)] = M

		var/result = tgui_input_list(usr, "Choose the martial art to teach", "JUDO CHOP", artnames)
		if(!usr)
			return
		if(QDELETED(src))
			to_chat(usr, "<span class='notice'>Mob doesn't exist anymore.</span>")
			return

		if(result)
			var/chosenart = artnames[result]
			var/datum/martial_art/MA = new chosenart
			MA.teach(src)

		href_list["datumrefresh"] = UID()
	else if(href_list[VV_HK_ADDORGAN])
		if(!check_rights(R_SPAWN))
			return

		var/new_organ = tgui_input_list(usr, "Please choose an organ to add.", "Organ", subtypesof(/obj/item/organ))
		if(!new_organ)
			return

		if(QDELETED(src))
			to_chat(usr, "<span class='notice'>Mob doesn't exist anymore.</span>")
			return

		if(locateUID(new_organ) in internal_organs)
			to_chat(usr, "<span class='notice'>Mob already has that organ.</span>")
			return
		var/obj/item/organ/internal/organ = new new_organ
		organ.insert(src)
		message_admins("[key_name_admin(usr)] has given [key_name_admin(src)] the organ [new_organ]")
		log_admin("[key_name(usr)] has given [key_name(src)] the organ [new_organ]")

	else if(href_list[VV_HK_REMORGAN])
		if(!check_rights(R_SPAWN))	return

		var/obj/item/organ/internal/rem_organ = tgui_input_list(usr, "Please choose an organ to remove.", "Organ", internal_organs)

		if(QDELETED(src))
			to_chat(usr, "<span class='notice'>Mob doesn't exist anymore.</span>")
			return

		if(!(rem_organ in internal_organs))
			to_chat(usr, "<span class='notice'>Mob does not have that organ.</span>")
			return

		to_chat(usr, "<span class='notice'>Removed [rem_organ] from [src].</span>")
		rem_organ.remove(src)
		message_admins("[key_name_admin(usr)] has removed the organ [rem_organ] from [key_name_admin(src)]")
		log_admin("[key_name(usr)] has removed the organ [rem_organ] from [key_name(src)]")
		qdel(rem_organ)
