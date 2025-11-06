/mob/living/Initialize(mapload)
	. = ..()
	var/datum/atom_hud/data/human/medical/advanced/medhud = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	medhud.add_to_hud(src)
	register_init_signals()
	faction += "\ref[src]"
	determine_move_and_pull_forces()
	GLOB.mob_living_list += src
	if(advanced_bullet_dodge_chance)
		RegisterSignal(src, COMSIG_ATOM_PREHIT, PROC_REF(advanced_bullet_dodge))

	for(var/initial_trait in initial_traits)
		ADD_TRAIT(src, initial_trait, INNATE_TRAIT)

	AddElement(/datum/element/strippable)
	RegisterSignal(src, COMSIG_STRIPPABLE_REQUEST_ITEMS, PROC_REF(get_strippable_items))

// Used to determine the forces dependend on the mob size
// Will only change the force if the force was not set in the mob type itself
/mob/living/proc/determine_move_and_pull_forces()
	var/value
	switch(mob_size)
		if(MOB_SIZE_TINY)
			value = MOVE_FORCE_EXTREMELY_WEAK
		if(MOB_SIZE_SMALL)
			value = MOVE_FORCE_WEAK
		if(MOB_SIZE_HUMAN)
			value = MOVE_FORCE_NORMAL
		if(MOB_SIZE_LARGE)
			value = MOVE_FORCE_NORMAL // For now
	if(!move_force)
		move_force = value
	if(!pull_force)
		pull_force = value
	if(!move_resist)
		move_resist = value

/mob/living/prepare_huds()
	..()
	prepare_data_huds()

/mob/living/proc/prepare_data_huds()
	med_hud_set_health()
	med_hud_set_status()

/mob/living/Destroy()
	if(ranged_ability)
		ranged_ability.remove_ranged_ability(src)
	remove_from_all_data_huds()
	GLOB.mob_living_list -= src
	if(LAZYLEN(status_effects))
		for(var/s in status_effects)
			var/datum/status_effect/S = s
			if(S.on_remove_on_mob_delete) //the status effect calls on_remove when its mob is deleted
				qdel(S)
			else
				S.be_replaced()
	QDEL_NULL(middleClickOverride)
	if(mind?.current == src)
		mind.unbind()
	UnregisterSignal(src, COMSIG_ATOM_PREHIT)
	return ..()

/mob/living/ghostize(flags = GHOST_FLAGS_DEFAULT, ghost_name, ghost_color)
	. = ..()
	SEND_SIGNAL(src, COMSIG_LIVING_GHOSTIZED)

/// Legacy method for simplemobs to handle turning off their AI.
/// Unrelated to and unused for AI controllers, which handle their
/// AI cooperation with signals.
/mob/living/proc/sentience_act()
	return

/mob/living/proc/OpenCraftingMenu()
	return

//Generic Bump(). Override MobBump() and ObjBump() instead of this.
/mob/living/Bump(atom/A)
	if(..()) //we are thrown onto something
		return
	if(buckled || now_pushing)
		return
	if(ismob(A))
		if(MobBump(A))
			return
	if(isobj(A))
		if(ObjBump(A))
			return
	if(istype(A, /atom/movable))
		if(PushAM(A, move_force))
			return

//Called when we bump into a mob
/mob/living/proc/MobBump(mob/M)
	if(m_intent == MOVE_INTENT_WALK)
		return TRUE
	//Even if we don't push/swap places, we "touched" them, so spread fire
	spreadFire(M)

	SEND_SIGNAL(src, COMSIG_LIVING_MOB_BUMP, M)

	// No pushing if we're already pushing past something, or if the mob we're pushing into is anchored.
	if(now_pushing || M.anchored)
		return TRUE

	//Should stop you pushing a restrained person out of the way
	if(isliving(M))
		var/mob/living/L = M
		if(L.pulledby && L.pulledby != src && L.restrained())
			if(!(world.time % 5))
				to_chat(src, "<span class='warning'>[L] is restrained, you cannot push past.</span>")
			return TRUE

		if(pulledby == L && (a_intent != INTENT_HELP || L.a_intent != INTENT_HELP)) //prevents boosting the person pulling you, but you can still move through them on help intent
			return TRUE

		if(L.pulling)
			if(ismob(L.pulling))
				var/mob/P = L.pulling
				if(P.restrained())
					if(!(world.time % 5))
						to_chat(src, "<span class='warning'>[L] is restrained, you cannot push past.</span>")
					return TRUE

	if(moving_diagonally) //no mob swap during diagonal moves.
		return TRUE

	if(has_status_effect(STATUS_EFFECT_UNBALANCED))
		// Don't swap while being shoved by air.
		return TRUE

	if(a_intent == INTENT_HELP) // Help intent doesn't mob swap a mob pulling a structure
		if(isstructure(M.pulling) || isstructure(pulling))
			return TRUE
	//Let us check if the person has riot equipment. We should not move past them or push them, unless they are on *walk* intent. This is so officers batoning on help can't me moved past.
	var/riot_equipment_used = (M.r_hand?.GetComponent(/datum/component/parry) || M.l_hand?.GetComponent(/datum/component/parry))

	if(!M.buckled && !M.has_buckled_mobs())
		var/mob_swap
		//the puller can always swap with it's victim if on grab intent
		if(length(M.grabbed_by) && a_intent == INTENT_GRAB)
			mob_swap = TRUE
		//restrained people act if they were on 'help' intent to prevent a person being pulled from being seperated from their puller
		else if(((M.restrained() || M.a_intent == INTENT_HELP) && !(riot_equipment_used && M.m_intent == MOVE_INTENT_RUN)) && (restrained() || a_intent == INTENT_HELP))
			mob_swap = TRUE
		if(mob_swap)
			//switch our position with M
			if(loc && !loc.Adjacent(M.loc))
				return TRUE
			now_pushing = TRUE
			var/oldloc = loc
			var/oldMloc = M.loc

			var/M_passmob = (M.pass_flags & PASSMOB) // we give PASSMOB to both mobs to avoid bumping other mobs during swap.
			var/src_passmob = (pass_flags & PASSMOB)
			M.pass_flags |= PASSMOB
			pass_flags |= PASSMOB

			M.Move(oldloc)
			Move(oldMloc)

			if(!src_passmob)
				pass_flags &= ~PASSMOB
			if(!M_passmob)
				M.pass_flags &= ~PASSMOB

			now_pushing = FALSE
			return TRUE

	// okay, so we didn't switch. but should we push?
	// not if he's not CANPUSH of course
	if(!(M.status_flags & CANPUSH))
		return TRUE
	//anti-riot equipment is also anti-push
	if(riot_equipment_used)
		return TRUE

//Called when we bump into an obj
/mob/living/proc/ObjBump(obj/O)
	return

//Called when we want to push an atom/movable
/mob/living/proc/PushAM(atom/movable/AM, force = move_force)

	if(isstructure(AM) && AM.pulledby)
		if(a_intent == INTENT_HELP && AM.pulledby != src) // Help intent doesn't push other peoples pulled structures
			return FALSE
		if(get_dist(get_step(AM, get_dir(src, AM)), AM.pulledby)>1)//Release pulled structures beyond 1 distance
			AM.pulledby.stop_pulling()

	if(now_pushing)
		return TRUE
	if(moving_diagonally) // no pushing during diagonal moves
		return TRUE
	if(!client && (mob_size < MOB_SIZE_SMALL))
		return
	now_pushing = TRUE
	var/t = get_dir(src, AM)
	var/push_anchored = FALSE
	if((AM.move_resist * MOVE_FORCE_CRUSH_RATIO) <= force)
		if(move_crush(AM, move_force, t))
			push_anchored = TRUE
	if((AM.move_resist * MOVE_FORCE_FORCEPUSH_RATIO) <= force)			//trigger move_crush and/or force_push regardless of if we can push it normally
		if(force_push(AM, move_force, t, push_anchored))
			push_anchored = TRUE
	if((AM.anchored && !push_anchored) || (force < (AM.move_resist * MOVE_FORCE_PUSH_RATIO)))
		now_pushing = FALSE
		return
	if(istype(AM, /obj/structure/window))
		var/obj/structure/window/W = AM
		if(W.fulltile)
			for(var/obj/structure/window/win in get_step(W,t))
				now_pushing = FALSE
				return
	if(pulling == AM)
		stop_pulling()
	var/current_dir
	if(isliving(AM))
		var/mob/living/living_mob = AM
		if(!living_mob.buckled)
			current_dir = AM.dir
	if(AM.Move(get_step(AM.loc, t), t, glide_size))
		Move(get_step(loc, t), t)
	if(current_dir)
		AM.setDir(current_dir)
	now_pushing = FALSE

/mob/living/examine(mob/user)
	. = ..()
	if(stat != DEAD)
		return
	if(!user.reagent_vision())
		return
	var/datum/surgery/dissection
	for(var/datum/surgery/dissect/D in surgeries)
		dissection = D
	if(dissection)
		. += "<span class='notice'>You detect the next dissection step will be: [dissection.get_surgery_step()]</span>"
	if(surgery_container && !contains_xeno_organ)
		. += "<span class='warning'>[src] looks like [p_they()] [p_have()] had [p_their()] organs dissected!</span>"


/mob/living/item_interaction(mob/living/user, obj/item/I, list/modifiers)
	if(length(surgeries))
		if(user.a_intent == INTENT_HELP)
			for(var/datum/surgery/S in surgeries)
				if(S.next_step(user, src))
					return ITEM_INTERACT_COMPLETE

	return ..()

/mob/living/CanPathfindPass(to_dir, datum/can_pass_info/pass_info)
	return TRUE // Unless you're a mule, something's trying to run you over.

/mob/living/proc/can_track(mob/living/user)
	//basic fast checks go first. When overriding this proc, I recommend calling ..() at the end.
	var/turf/T = get_turf(src)
	if(!T)
		return FALSE
	if(!is_level_reachable(T.z))
		return FALSE
	if(!isnull(user) && src == user)
		return FALSE
	if(invisibility || alpha == 0)//cloaked
		return FALSE
	if(HAS_TRAIT(src, TRAIT_AI_UNTRACKABLE))
		return FALSE
	if(user && user.is_jammed())
		return FALSE
	// Now, are they viewable by a camera? (This is last because it's the most intensive check)
	if(!near_camera(src))
		return FALSE

	return TRUE

/mob/living/proc/is_jammed()
	for(var/obj/item/jammer/jammer in GLOB.active_jammers)
		if(atoms_share_level(get_turf(src), get_turf(jammer)) && get_dist(get_turf(src), get_turf(jammer)) < jammer.range)
			return TRUE
	return FALSE

//mob verbs are a lot faster than object verbs
//for more info on why this is not atom/pull, see examinate() in mob.dm
/mob/living/verb/pulled(atom/movable/AM as mob|obj in oview(1))
	set name = "Pull"
	set category = null
	if(istype(AM) && Adjacent(AM))
		start_pulling(AM, show_message = TRUE)
	else
		stop_pulling()

/mob/living/stop_pulling()
	if(pulling)
		var/atom/pullee = pulling
		..()
		for(var/log_pulltype in GLOB.log_pulltypes)
			if(istype(pullee, log_pulltype))
				create_log(MISC_LOG, "Stopped pulling", pullee)
				break
	if(pullin)
		pullin.update_icon(UPDATE_ICON_STATE)

/mob/living/verb/stop_pulling1()
	set name = "Stop Pulling"
	set category = "IC"
	stop_pulling()

//same as above
/mob/living/pointed(atom/A as mob|obj|turf in view())
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		return FALSE
	if(HAS_TRAIT(src, TRAIT_FAKEDEATH))
		return FALSE
	return ..()

/mob/living/run_pointed(atom/A)
	if(!..())
		return FALSE

	var/obj/item/hand_item = get_active_hand()
	if(istype(hand_item) && hand_item.run_pointed_on_item(src, A))
		return TRUE
	var/pointed_object = "\the [A]"
	if(A.loc in src)
		pointed_object += " inside [A.loc]"

	visible_message("<b>[src]</b> points to [pointed_object].")
	return TRUE

/mob/living/verb/succumb()
	set hidden = TRUE
	// if you use the verb you better mean it
	do_succumb(FALSE)

/mob/living/proc/do_succumb(cancel_on_no_words)
	if(stat == DEAD)
		to_chat(src, "<span class='notice'>It's too late, you're already dead!</span>")
		return
	if(health >= HEALTH_THRESHOLD_SUCCUMB)
		to_chat(src, "<span class='warning'>You are unable to succumb to death! This life continues!</span>")
		return

	last_words = null // In case we kept some from last time
	var/final_words = tgui_input_text(src, "Do you have any last words?", "Goodnight, Sweet Prince", encode = FALSE)

	if(isnull(final_words) && cancel_on_no_words)
		to_chat(src, "<span class='notice'>You decide you aren't quite ready to die.</span>")
		return

	if(stat == DEAD)
		return

	if(health >= HEALTH_THRESHOLD_SUCCUMB)
		to_chat(src, "<span class='warning'>You are unable to succumb to death! This life continues!</span>")
		return

	if(!isnull(final_words))
		create_log(MISC_LOG, "gave their final words, [last_words]")
		last_words = final_words
		whisper(final_words)

	add_attack_logs(src, src, "[src] has [!isnull(final_words) ? "whispered [p_their()] final words" : "succumbed to death"] with [round(health, 0.1)] points of health!")

	create_log(MISC_LOG, "has succumbed to death with [round(health, 0.1)] points of health")
	adjustOxyLoss(max(health - HEALTH_THRESHOLD_DEAD, 0))
	// super check for weird mobs, including ones that adjust hp
	// we don't want to go overboard and gib them, though
	for(var/i in 1 to 5)
		if(health < HEALTH_THRESHOLD_DEAD)
			break
		take_overall_damage(max(5, health - HEALTH_THRESHOLD_DEAD), 0)

	if(!isnull(final_words))
		addtimer(CALLBACK(src, PROC_REF(death)), 1 SECONDS)
	else
		death()
	to_chat(src, "<span class='notice'>You have given up life and succumbed to death.</span>")
	apply_status_effect(STATUS_EFFECT_RECENTLY_SUCCUMBED)

/mob/living/proc/InCritical()
	return (health < HEALTH_THRESHOLD_CRIT && health > HEALTH_THRESHOLD_DEAD && stat == UNCONSCIOUS)

/mob/living/ex_act(severity)
	..()
	flash_eyes()

/mob/living/acid_act(acidpwr, acid_volume)
	take_organ_damage(acidpwr * min(1, acid_volume * 0.1))
	to_chat(src, "<span class='userdanger'>The acid burns you!</span>")
	playsound(src, 'sound/weapons/sear.ogg', 50, TRUE)
	return 1

/mob/living/welder_act(mob/user, obj/item/I)
	if(!I.tool_use_check(user, 0, TRUE))
		return
	if(IgniteMob())
		message_admins("[key_name_admin(user)] set [key_name_admin(src)] on fire with [I]")
		log_game("[key_name(user)] set [key_name(src)] on fire with [I]")

/mob/living/proc/updatehealth(reason = "none given")
	if(status_flags & GODMODE)
		health = maxHealth
		set_stat(CONSCIOUS)
		return
	health = maxHealth - getOxyLoss() - getToxLoss() - getFireLoss() - getBruteLoss() - getCloneLoss()

	SEND_SIGNAL(src, COMSIG_LIVING_HEALTH_UPDATE)
	update_stat("updatehealth([reason])")
	med_hud_set_health()
	med_hud_set_status()
	update_health_hud()
	update_stamina_hud()


//This proc is used for mobs which are affected by pressure to calculate the amount of pressure that actually
//affects them once clothing is factored in. ~Errorage
/mob/living/proc/calculate_affecting_pressure(pressure)
	return 0

/mob/living/proc/adjustBodyTemp(actual, desired, incrementboost)
	var/temperature = actual
	var/difference = abs(actual-desired)	//get difference
	var/increments = difference/10 //find how many increments apart they are
	var/change = increments*incrementboost	// Get the amount to change by (x per increment)

	// Too cold
	if(actual < desired)
		temperature += change
		if(actual > desired)
			temperature = desired
	// Too hot
	if(actual > desired)
		temperature -= change
		if(actual < desired)
			temperature = desired

	return temperature


/mob/proc/get_contents()
	return


//Recursive function to find everything a mob is holding.
/mob/living/get_contents(obj/item/storage/Storage = null)
	var/list/L = list()

	if(Storage) //If it called itself
		L += Storage.return_inv()

		//Leave this commented out, it will cause storage items to exponentially add duplicate to the list
		//for(var/obj/item/storage/S in Storage.return_inv()) //Check for storage items
		//	L += get_contents(S)

		for(var/obj/item/gift/G in Storage.return_inv()) //Check for gift-wrapped items
			L += G.gift
			if(isstorage(G.gift))
				L += get_contents(G.gift)

		for(var/obj/item/small_delivery/D in Storage.return_inv()) //Check for package wrapped items
			L += D.wrapped
			if(isstorage(D.wrapped)) //this should never happen
				L += get_contents(D.wrapped)
		return L

	else

		L += contents
		for(var/obj/item/storage/S in contents)	//Check for storage items
			L += get_contents(S)
		for(var/obj/item/mod/control/C in contents) //Check for modsuit storage
			for(var/obj/item/mod/module/storage/MS in C.contents)
				for(var/obj/item/storage/MSB in MS.contents)
					L += get_contents(MSB)
		for(var/obj/item/clothing/suit/storage/S in contents)//Check for labcoats and jackets
			L += get_contents(S)
		for(var/obj/item/clothing/accessory/storage/S in contents)//Check for holsters
			L += get_contents(S)
		for(var/obj/item/bio_chip/storage/I in contents) //Check for storage implants.
			L += I.get_contents()
		for(var/obj/item/gift/G in contents) //Check for gift-wrapped items
			L += G.gift
			if(isstorage(G.gift))
				L += get_contents(G.gift)

		for(var/obj/item/small_delivery/D in contents) //Check for package wrapped items
			L += D.wrapped
			if(isstorage(D.wrapped)) //this should never happen
				L += get_contents(D.wrapped)
		for(var/obj/item/folder/F in contents)
			L += F.contents //Folders can't store any storage items.
		for(var/obj/item/organ/internal/headpocket/pocket in contents)
			L += pocket.contents //Checks for items in headpockets
		return L

/mob/living/proc/check_contents_for(A)
	var/list/L = get_contents()

	for(var/obj/B in L)
		if(B.type == A)
			return 1
	return 0

// Living mobs use can_inject() to make sure that the mob is not syringe-proof in general.
/mob/living/proc/can_inject(mob/user, error_msg, target_zone, penetrate_thick)
	return TRUE

/mob/living/is_injectable(mob/user, allowmobs = TRUE)
	return (allowmobs && reagents && can_inject(user))

/mob/living/is_drawable(mob/user, allowmobs = TRUE)
	return (allowmobs && reagents && can_inject(user))

/mob/living/proc/restore_all_organs()
	return

/mob/living/proc/revive()
	rejuvenate()
	if(iscarbon(src))
		var/mob/living/carbon/C = src

		if(C.handcuffed && !initial(C.handcuffed))
			C.drop_item_to_ground(C.handcuffed)
		C.handcuffed = initial(C.handcuffed)
		C.update_handcuffed()

		if(C.legcuffed && !initial(C.legcuffed))
			C.drop_item_to_ground(C.legcuffed)
		C.legcuffed = initial(C.legcuffed)
		C.update_inv_legcuffed()

		if(C.reagents)
			C.reagents.clear_reagents()
			QDEL_LIST_CONTENTS(C.reagents.addiction_list)
			C.reagents.addiction_threshold_accumulated.Cut()

		QDEL_LIST_CONTENTS(C.processing_patches)

// rejuvenate: Called by `revive` to get the mob into a revivable state
// the admin "rejuvenate" command calls `revive`, not this proc.
/mob/living/proc/rejuvenate()
	var/mob/living/carbon/human/human_mob = null //Get this declared for use later.

	// shut down various types of badness
	setToxLoss(0)
	setOxyLoss(0)
	setCloneLoss(0)
	setBrainLoss(0)
	setStaminaLoss(0)
	SetSleeping(0)
	SetParalysis(0, TRUE)
	SetStunned(0, TRUE)
	SetWeakened(0, TRUE)
	SetSlowed(0)
	SetImmobilized(0)
	SetKnockDown(0)
	SetLoseBreath(0)
	SetDizzy(0)
	SetJitter(0)
	SetStuttering(0)
	SetConfused(0)
	SetDrowsy(0)
	radiation = 0
	SetDruggy(0)
	SetHallucinate(0)
	set_nutrition(NUTRITION_LEVEL_FED + 50)
	bodytemperature = 310
	cure_blind()
	cure_nearsighted()
	CureMute()
	CureDeaf()
	CureEpilepsy()
	CureCoughing()
	CureNervous()
	CureParaplegia()
	SetEyeBlind(0)
	SetEyeBlurry(0)
	SetDeaf(0)
	heal_overall_damage(1000, 1000)
	ExtinguishMob()
	SEND_SIGNAL(src, COMSIG_LIVING_CLEAR_STUNS)
	fire_stacks = 0
	on_fire = 0
	suiciding = 0
	if(buckled) //Unbuckle the mob and clear the alerts.
		unbuckle(force = TRUE)

	if(iscarbon(src))
		var/mob/living/carbon/C = src
		C.handcuffed = initial(C.handcuffed)

		for(var/thing in C.viruses)
			var/datum/disease/D = thing
			D.cure(0)

		// restore all of the human's blood and reset their shock stage
		if(ishuman(src))
			human_mob = src
			human_mob.set_heartattack(FALSE)
			human_mob.restore_blood()
			human_mob.decaylevel = 0
			human_mob.remove_all_embedded_objects()
	SEND_SIGNAL(src, COMSIG_LIVING_AHEAL)
	restore_all_organs()
	surgeries.Cut() //End all surgeries.
	if(stat == DEAD)
		update_revive()
	else if(stat == UNCONSCIOUS)
		WakeUp()

	update_fire()
	regenerate_icons()
	restore_blood()
	if(human_mob)
		human_mob.update_eyes()
		human_mob.update_dna()

	resting = FALSE
	stand_up() // wake the fuck up badmin, we've got an "event" to burn
	return

/mob/living/proc/remove_CC()
	SetWeakened(0)
	SetKnockDown(0)
	SetStunned(0)
	SetParalysis(0)
	SetImmobilized(0)
	SetSleeping(0)
	setStaminaLoss(0)
	SetSlowed(0)

/mob/living/proc/UpdateDamageIcon()
	return

/mob/living/get_spacemove_backup(movement_dir)
	if(movement_dir == 0 && has_status_effect(STATUS_EFFECT_UNBALANCED))
		return
	return ..()

/mob/living/Move(atom/newloc, direct = 0, glide_size_override = 0, update_dir = TRUE)
	if(buckled && buckled.loc != newloc) //not updating position
		if(!buckled.anchored)
			return buckled.Move(newloc, direct)
		else
			return 0

	var/atom/movable/pullee = pulling
	if(pullee && get_dist(src, pullee) > 1)
		stop_pulling()
	if(pullee && !isturf(pullee.loc) && pullee.loc != loc)
		log_game("DEBUG: [src]'s pull on [pullee] was broken despite [pullee] being in [pullee.loc]. Pull stopped manually.")
		stop_pulling()
	if(restrained() || HAS_TRAIT(src, TRAIT_CANNOT_PULL))
		stop_pulling()

	. = ..()
	if(.)
		step_count++

	if(s_active && !(s_active in contents) && get_turf(s_active) != get_turf(src))	//check !( s_active in contents) first so we hopefully don't have to call get_turf() so much.
		s_active.close(src)

/mob/living/proc/makeTrail(turf/turf_to_trail_on)
	if(!has_gravity(src))
		return
	if(!isturf(loc))
		return
	var/trail_type = getTrail()
	if(!trail_type)
		return
	var/brute_ratio = round(getBruteLoss() / maxHealth, 0.1)
	if(!blood_volume && !(blood_volume > max(BLOOD_VOLUME_NORMAL * (1 - brute_ratio * 0.25), 0)))	// Okay let's dive into the maths. For every 50 brute damage taken, the minimal blood level you can have decreases by 12,5%
		return
	blood_volume = max(blood_volume - max(1, brute_ratio * 2), 0)								// The amount of blood lost per tile of movement is always at least 1cl, and every 50 damage after reaching 50 brute damage taken will increase the bleed by 1cl per tile
	var/newdir = get_dir(turf_to_trail_on, loc)
	if(newdir != dir)
		newdir |= dir
		if(newdir == (NORTH|SOUTH))
			newdir = NORTH
		else if(newdir == (EAST|WEST))
			newdir = EAST
	if(IS_DIR_CARDINAL(newdir) && prob(50))
		newdir = turn(get_dir(turf_to_trail_on, loc), 180)
	var/blood_exists = locate(/obj/effect/decal/cleanable/trail_holder) in loc //checks for blood splatter already on the floor
	if(!blood_exists)
		new /obj/effect/decal/cleanable/trail_holder(loc)
	for(var/obj/effect/decal/cleanable/trail_holder/existing_trail in loc)
		if((!(newdir in existing_trail.existing_dirs) || trail_type == "trails_1" || trail_type == "trails_2") && length(existing_trail.existing_dirs) <= 16) //maximum amount of overlays is 16 (all light & heavy directions filled)
			existing_trail.existing_dirs += newdir
			existing_trail.overlays.Add(image('icons/effects/blood.dmi', trail_type, dir = newdir))
			existing_trail.transfer_mob_blood_dna(src)
			if(ishuman(src))
				var/mob/living/carbon/human/H = src
				if(H.dna.species.blood_color)
					existing_trail.color = H.dna.species.blood_color
			else if(isalien(src))
				existing_trail.color = "#05EE05"
			else
				existing_trail.color = "#A10808"

/mob/living/carbon/human/makeTrail(turf/T)

	if((NO_BLOOD in dna.species.species_traits) || dna.species.exotic_blood || !bleed_rate || bleedsuppress)
		return
	..()

/mob/living/proc/getTrail()
	if(getBruteLoss() < 300)
		return pick("ltrails_1", "ltrails_2")
	else
		return pick("trails_1", "trails_2")

/mob/living/experience_pressure_difference(flow_x, flow_y, pressure_resistance_prob_delta = 0)
	if(buckled)
		return
	..()

/*//////////////////////
	START RESIST PROCS
*///////////////////////

/mob/living/can_resist()
	return !((next_move > world.time) || incapacitated(ignore_restraints = TRUE))

/mob/living/verb/resist()
	set name = "Resist"
	set category = "IC"

	DEFAULT_QUEUE_OR_CALL_VERB(VERB_CALLBACK(src, PROC_REF(run_resist)))

///proc extender of [/mob/living/verb/resist] meant to make the process queable if the server is overloaded when the verb is called
/mob/living/proc/run_resist()
	if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))
		var/obj/C = loc
		C.container_resist(src)
		return
	if(!can_resist())
		return
	changeNext_move(CLICK_CD_RESIST)

	SEND_SIGNAL(src, COMSIG_LIVING_RESIST, src)

	if(!restrained())
		if(resist_grab())
			return

	//unbuckling yourself
	if(buckled)
		resist_buckle()

	//Breaking out of a container (Locker, sleeper, cryo...)
	else if(isobj(loc))
		var/obj/C = loc
		C.container_resist(src)

	else if(mobility_flags & MOBILITY_MOVE)
		if(on_fire)
			resist_fire() //stop, drop, and roll
		else
			resist_restraints() //trying to remove cuffs.

/*////////////////////
	RESIST SUBPROCS
*/////////////////////
/mob/living/proc/resist_grab()
	var/resisting = 0
	if(HAS_TRAIT(src, TRAIT_IMMOBILIZED))
		return FALSE //You can't move, so you can't resist
	for(var/X in grabbed_by)
		var/obj/item/grab/G = X
		resisting++
		switch(G.state)
			if(GRAB_PASSIVE)
				qdel(G)

			if(GRAB_AGGRESSIVE)
				if(prob(60))
					visible_message("<span class='danger'>[src] has broken free of [G.assailant]'s grip!</span>")
					qdel(G)

			if(GRAB_NECK)
				if(prob(5))
					visible_message("<span class='danger'>[src] has broken free of [G.assailant]'s headlock!</span>")
					qdel(G)

	if(resisting)
		visible_message("<span class='danger'>[src] resists!</span>")
		return 1

/mob/living/proc/resist_buckle()
	spawn(0)
		resist_muzzle()
	buckled.user_unbuckle_mob(src,src)

/mob/living/proc/resist_muzzle()
	return

/mob/living/proc/resist_fire()
	return

/mob/living/proc/resist_restraints()
	spawn(0)
		resist_muzzle()
	return

/*//////////////////////
	END RESIST PROCS
*///////////////////////

/// Unbuckle the mob from whatever it is buckled to.
/mob/living/proc/unbuckle(force)
	buckled.unbuckle_mob(src, force)

/mob/living/proc/Exhaust()
	to_chat(src, "<span class='notice'>You're too exhausted to keep going...</span>")
	Weaken(10 SECONDS)

/mob/living/proc/get_visible_name()
	return name

/mob/living/proc/is_facehugged()
	return FALSE

/mob/living/update_gravity(has_gravity)
	if(SSticker.current_state < GAME_STATE_PREGAME)
		return
	if(has_gravity)
		clear_alert("weightless")
	else
		throw_alert("weightless", /atom/movable/screen/alert/weightless)
	if(!HAS_TRAIT(src, TRAIT_FLYING))
		float(!has_gravity)

/mob/living/proc/float(on)
	if(throwing)
		return
	var/fixed = FALSE
	if(anchored || (buckled && buckled.anchored))
		fixed = TRUE
	if(on && !floating && !fixed)
		animate(src, pixel_y = pixel_y + 2, time = 10, loop = -1)
		animate(pixel_y = pixel_y - 2, time = 10, loop = -1)
		floating = TRUE
	else if(((!on || fixed) && floating))
		animate(src, pixel_y = get_standard_pixel_y_offset(), time = 10)
		floating = FALSE

/mob/living/proc/can_use_vents()
	return "You can't fit into that vent."

//Checks for anything other than eye protection that would stop flashing. Overridden in carbon.dm and human.dm
/mob/living/proc/can_be_flashed(intensity = 1, override_blindness_check = 0)
	if((check_eye_prot() >= intensity) || (!override_blindness_check && (HAS_TRAIT(src, TRAIT_BLIND))) || HAS_TRAIT(src, TRAIT_FLASH_PROTECTION))
		return FALSE

	return TRUE

//called when the mob receives a bright flash
/mob/living/proc/flash_eyes(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0, laser_pointer = FALSE, type = /atom/movable/screen/fullscreen/stretch/flash)
	SIGNAL_HANDLER
	if(can_be_flashed(intensity, override_blindness_check))
		overlay_fullscreen("flash", type)
		addtimer(CALLBACK(src, PROC_REF(clear_fullscreen), "flash", 25), 25)
		return 1

/mob/living/proc/check_eye_prot()
	return 0

/mob/living/proc/check_ear_prot()
	return

/mob/living/singularity_act()
	investigate_log("([key_name(src)]) has been consumed by the singularity.",INVESTIGATE_SINGULO) //Oh that's where the clown ended up!
	gib()
	return 20

/mob/living/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_SIX) //your puny magboots/wings/whatever will not save you against supermatter singularity
		throw_at(S, 14, 3, src, TRUE)
	else if(!mob_negates_gravity())
		step_towards(src,S)

/mob/living/narsie_act()
	if(client)
		make_new_construct(/mob/living/simple_animal/hostile/construct/harvester, src, cult_override = TRUE, create_smoke = TRUE)
	spawn_dust()
	gib()

/mob/living/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!used_item)
		used_item = get_active_hand()
		if(!visual_effect_icon && used_item?.attack_effect_override)
			visual_effect_icon = used_item.attack_effect_override
	..()
	floating = FALSE // If we were without gravity, the bouncing animation got stopped, so we make sure we restart the bouncing after the next movement.

/mob/living/proc/do_jitter_animation(jitteriness, loop_amount = 6)
	var/amplitude = min(4, (jitteriness / 100) + 1)
	var/pixel_x_diff = rand(-amplitude, amplitude)
	var/pixel_y_diff = rand(-amplitude / 3, amplitude / 3)
	animate(src, pixel_x = pixel_x_diff, pixel_y = pixel_y_diff , time = 2, loop = loop_amount, flags = ANIMATION_RELATIVE|ANIMATION_PARALLEL)
	animate(pixel_x = -pixel_x_diff , pixel_y = -pixel_y_diff , time = 2, flags = ANIMATION_RELATIVE)
	floating = FALSE // If we were without gravity, the bouncing animation got stopped, so we make sure we restart the bouncing after the next movement.


/mob/living/proc/get_temperature(datum/gas_mixture/environment)
	var/loc_temp = T0C
	if(ismecha(loc))
		var/obj/mecha/M = loc
		var/datum/gas_mixture/cabin = M.return_obj_air()
		if(cabin)
			loc_temp = cabin.temperature()
		else
			loc_temp = environment.temperature()

	else if(istype(loc, /obj/structure/transit_tube_pod))
		loc_temp = environment.temperature()

	else if(isspaceturf(get_turf(src)))
		var/turf/heat_turf = get_turf(src)
		loc_temp = heat_turf.temperature

	else if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))
		var/obj/machinery/atmospherics/unary/cryo_cell/C = loc

		if(C.air_contents.total_moles() < 10)
			loc_temp = environment.temperature()
		else
			loc_temp = C.air_contents.temperature()

	else
		loc_temp = environment.temperature()

	return loc_temp

/mob/living/proc/get_standard_pixel_x_offset()
	return initial(pixel_x)

/mob/living/proc/get_standard_pixel_y_offset()
	return initial(pixel_y)

/mob/living/proc/spawn_dust()
	new /obj/effect/decal/cleanable/ash(loc)

//used in datum/reagents/reaction() proc
/mob/living/proc/get_permeability_protection()
	return 0

/mob/living/proc/attempt_harvest(obj/item/I, mob/user)
	if(user.a_intent == INTENT_HARM && stat == DEAD && butcher_results && I.sharp) //can we butcher it?
		to_chat(user, "<span class='notice'>You begin to butcher [src]...</span>")
		playsound(loc, 'sound/weapons/slice.ogg', 50, TRUE, -1)
		if(user.mind && HAS_TRAIT(user.mind, TRAIT_BUTCHER))
			if(do_mob(user, src, 3 SECONDS) && Adjacent(I))
				harvest(user)
		else
			if(do_mob(user, src, 8 SECONDS) && Adjacent(I))
				harvest(user)
		return TRUE

/mob/living/proc/harvest(mob/living/user)
	if(QDELETED(src))
		return
	if(butcher_results)
		for(var/path in butcher_results)
			for(var/i = 1, i <= butcher_results[path], i++)
				new path(loc)
			butcher_results.Remove(path) //In case you want to have things like simple_animals drop their butcher results on gib, so it won't double up below.
		visible_message("<span class='notice'>[user] butchers [src].</span>")
		gib()

/mob/living/proc/can_use(atom/movable/M, be_close = FALSE)
	if(HAS_TRAIT(src, TRAIT_HANDS_BLOCKED))
		to_chat(src, "<span class='warning'>You can't do that right now!</span>")
		return FALSE
	if(be_close && !in_range(M, src))
		to_chat(src, "<span class='warning'>You are too far away!</span>")
		return FALSE
	return TRUE

/mob/living/movement_delay(ignorewalk = 0)
	. = ..()
	if(isturf(loc))
		var/turf/T = loc
		. += T.slowdown
	var/datum/status_effect/incapacitating/slowed/S = IsSlowed()
	if(S)
		. += S.slowdown_value
	else
		// Only apply directional slow if we don't have a full slow.
		var/datum/status_effect/incapacitating/directional_slow/DS = has_status_effect(STATUS_EFFECT_DIRECTIONAL_SLOW)
		if(DS)
			if(DS.direction == last_move)
				// Moving directly in the direction we're slowed, full penalty
				. += DS.slowdown_value
			else if(REVERSE_DIR(DS.direction) == last_move)
				// Moving directly opposite to the slow, no penalty.
				// Lint doesn't like this block being empty so, uh, add zero, I guess.
				. += 0
			else if(IS_DIR_CARDINAL(DS.direction) || IS_DIR_CARDINAL(last_move))
				if(DS.direction & last_move)
					// Moving roughly in the direction we're slowed, full penalty.
					. += DS.slowdown_value
				else if(!(REVERSE_DIR(DS.direction) & last_move))
					// Moving perpendicular to the slow, partial penalty.
					. += DS.slowdown_value / 2
				// Moving roughly opposite to the slow, no penalty.
			else
				// Diagonal move perpendicular to the slow, partial penalty.
				. += DS.slowdown_value / 2

	if(forced_look)
		. += DIRECTION_LOCK_SLOWDOWN
	if(ignorewalk)
		. += GLOB.configuration.movement.base_run_speed
	else
		switch(m_intent)
			if(MOVE_INTENT_RUN)
				if(get_drowsiness() > 0)
					. += 6
				. += GLOB.configuration.movement.base_run_speed
			if(MOVE_INTENT_WALK)
				. += GLOB.configuration.movement.base_walk_speed


/mob/living/proc/can_use_guns(obj/item/gun/G)
	if(G.trigger_guard != TRIGGER_GUARD_ALLOW_ALL && !IsAdvancedToolUser() && !issmall(src))
		to_chat(src, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return FALSE
	if(G.trigger_guard == TRIGGER_GUARD_NONE)
		to_chat(src, "<span class='warning'>This gun is only built to be fired by machines!</span>")
		return FALSE
	return 1

/mob/living/start_pulling(atom/movable/AM, state, force = pull_force, show_message = FALSE)
	if(!AM || !src)
		return FALSE
	if(!(AM.can_be_pulled(src, state, force, show_message)))
		return FALSE
	if(incapacitated())
		return
	if(SEND_SIGNAL(src, COMSIG_LIVING_TRY_PULL, AM, force) & COMSIG_LIVING_CANCEL_PULL)
		return FALSE

	// If we're pulling something then drop what we're currently pulling and pull this instead.
	AM.add_fingerprint(src)
	if(pulling)
		if(AM == pulling)// Are we trying to pull something we are already pulling? Then just stop here, no need to continue.
			return
		stop_pulling()
		if(AM.pulledby)
			visible_message("<span class='danger'>[src] has pulled [AM] from [AM.pulledby]'s grip.</span>")
			AM.pulledby.stop_pulling() //an object can't be pulled by two mobs at once.
	pulling = AM
	AM.pulledby = src
	if(pullin)
		pullin.update_icon(UPDATE_ICON_STATE)
	SEND_SIGNAL(AM, COMSIG_ATOM_PULLED, src)

	for(var/log_pulltype in GLOB.log_pulltypes)
		if(istype(AM, log_pulltype))
			create_log(MISC_LOG, "Started pulling", AM)
			break

/mob/living/proc/check_pull()
	if(pulling && !pulling.Adjacent(src))
		stop_pulling()

/mob/living/proc/update_z(new_z) // 1+ to register, null to unregister
	if(registered_z != new_z)
		if(registered_z)
			SSmobs.clients_by_zlevel[registered_z] -= src

		if(isnull(client))
			registered_z = null
			return

		// Check the amount of clients exists on the Z level we're leaving from,
		// this excludes us because at this point we are not registered to any z level.
		var/old_level_new_clients = (registered_z ? length(SSmobs.clients_by_zlevel[registered_z]) : null)
		// No one is left after we're gone, shut off inactive ones
		if(registered_z && old_level_new_clients == 0)
			for(var/datum/ai_controller/controller as anything in SSai_controllers.ai_controllers_by_zlevel[registered_z])
				controller.set_ai_status(AI_STATUS_OFF)


		if(new_z)
			// Check the amount of clients exists on the Z level we're moving towards, excluding ourselves.
			var/new_level_old_clients = length(SSmobs.clients_by_zlevel[new_z])

			//We'll add ourselves to the list now so get_expected_ai_status() will know we're on the z level.
			SSmobs.clients_by_zlevel[new_z] += src

			if(new_level_old_clients == 0) // No one was here before, wake up all the AIs.
				// Basic mob AI
				for(var/datum/ai_controller/controller as anything in SSai_controllers.ai_controllers_by_zlevel[new_z])
					// We don't set them directly on, for instances like AIs acting while dead and other cases that may exist in the future.
					// This isn't a problem for AIs with a client since the client will prevent this from being called anyway.
					controller.set_ai_status(controller.get_expected_ai_status())

				// Simple mob AI
				for(var/I in length(SSidlenpcpool.idle_mobs_by_zlevel[new_z]) to 1 step -1) //Backwards loop because we're removing (guarantees optimal rather than worst-case performance)
					var/mob/living/simple_animal/SA = SSidlenpcpool.idle_mobs_by_zlevel[new_z][I]
					if(SA)
						SA.toggle_ai(AI_ON) // Guarantees responsiveness for when appearing right next to mobs
					else
						SSidlenpcpool.idle_mobs_by_zlevel[new_z] -= SA
		registered_z = new_z

/mob/living/on_changed_z_level(turf/old_turf, turf/new_turf)
	..()
	update_z(new_turf?.z)

/mob/living/rad_act(atom/source, amount, emission_type)
	// Mobs block very little Beta and Gamma radiation, but we still want the rads to affect them.
	if(emission_type > ALPHA_RAD)
		amount /=  (1 - RAD_MOB_INSULATION)
	// Alpha sources outside the body don't do much
	else if(!is_inside_mob(source))
		amount /= 100
	if(!amount || (amount < RAD_MOB_SKIN_PROTECTION) || HAS_TRAIT(src, TRAIT_RADIMMUNE))
		return

	amount -= RAD_BACKGROUND_RADIATION // This will always be at least 1 because of how skin protection is calculated

	var/blocked = getarmor(armor_type = RAD)
	if(blocked == INFINITY) // Full protection, go no further.
		return
	if(amount > RAD_BURN_THRESHOLD)
		apply_damage(RAD_BURN_CURVE(amount), BURN, null, blocked)

	apply_effect((amount * RAD_MOB_COEFFICIENT) / max(1, (radiation ** 2) * RAD_OVERDOSE_REDUCTION), IRRADIATE, ARMOUR_VALUE_TO_PERCENTAGE(blocked))

/mob/living/proc/is_inside_mob(atom/thing)
	if(!(thing in contents))
		return FALSE
	if(l_hand && l_hand.UID() == thing.UID())
		return FALSE
	if(r_hand && r_hand.UID() == thing.UID())
		return FALSE
	if(back && back.UID() == thing.UID())
		return FALSE
	if(wear_mask && wear_mask.UID() == thing.UID())
		return FALSE

	return TRUE

/mob/living/proc/fakefireextinguish()
	return

/mob/living/proc/fakefire()
	return

/mob/living/extinguish_light(force = FALSE)
	for(var/atom/A in src)
		if(A.light_range > 0)
			A.extinguish_light(force)

/mob/living/vv_get_header()
	. = ..()
	. += {"
		<br><font size='1'>
			BRUTE:<font size='1'><a href='byond://?_src_=vars;[VV_HK_TARGET]=[UID()];adjustDamage=brute'>[getBruteLoss()]</a>
			FIRE:<font size='1'><a href='byond://?_src_=vars;[VV_HK_TARGET]=[UID()];adjustDamage=fire'>[getFireLoss()]</a>
			TOXIN:<font size='1'><a href='byond://?_src_=vars;[VV_HK_TARGET]=[UID()];adjustDamage=toxin'>[getToxLoss()]</a>
			OXY:<font size='1'><a href='byond://?_src_=vars;[VV_HK_TARGET]=[UID()];adjustDamage=oxygen'>[getOxyLoss()]</a>
			CLONE:<font size='1'><a href='byond://?_src_=vars;[VV_HK_TARGET]=[UID()];adjustDamage=clone'>[getCloneLoss()]</a>
			BRAIN:<font size='1'><a href='byond://?_src_=vars;[VV_HK_TARGET]=[UID()];adjustDamage=brain'>[getBrainLoss()]</a>
			STAMINA:<font size='1'><a href='byond://?_src_=vars;[VV_HK_TARGET]=[UID()];adjustDamage=stamina'>[getStaminaLoss()]</a>
		</font>
	"}

/mob/living/vv_do_topic(list/href_list)
	. = ..()

	if(!.)
		return

	if(href_list["adjustDamage"])
		if(!check_rights(R_DEBUG|R_ADMIN|R_EVENT))	return

		var/Text = href_list["adjustDamage"]
		var/amount =	tgui_input_number(usr, "Deal how much damage to mob? (Negative values here heal)", "Adjust [Text]loss", min_value = -10000, max_value = 10000)

		if(QDELETED(src))
			to_chat(usr, "<span class='notice'>Mob doesn't exist anymore.</span>")
			return

		switch(Text)
			if("brute")
				if(ishuman(src))
					var/mob/living/carbon/human/H = src
					H.adjustBruteLoss(amount, robotic = TRUE)
				else
					adjustBruteLoss(amount)
			if("fire")
				if(ishuman(src))
					var/mob/living/carbon/human/H = src
					H.adjustFireLoss(amount, robotic = TRUE)
				else
					adjustFireLoss(amount)
			if("toxin")
				adjustToxLoss(amount)
			if("oxygen")
				adjustOxyLoss(amount)
			if("brain")
				adjustBrainLoss(amount)
			if("clone")
				adjustCloneLoss(amount)
			if("stamina")
				adjustStaminaLoss(amount)
			else
				to_chat(usr, "<span class='notice'>You caused an error. DEBUG: Text:[Text] Mob:[src]</span>")
				return

		if(amount != 0)
			log_admin("[key_name(usr)] dealt [amount] amount of [Text] damage to [src]")
			message_admins("[key_name_admin(usr)] dealt [amount] amount of [Text] damage to [src]")
			href_list["datumrefresh"] = UID()

/mob/living/vv_edit_var(var_name, var_value)
	switch(var_name)
		if("stat")
			if((stat == DEAD) && (var_value < DEAD))//Bringing the dead back to life
				GLOB.dead_mob_list -= src
				GLOB.alive_mob_list += src
			if((stat != DEAD) && (var_value == DEAD))//Kill he
				GLOB.alive_mob_list -= src
				GLOB.dead_mob_list += src
	. = ..()
	switch(var_name)
		if("resize")
			update_transform()
		if("lighting_alpha")
			sync_lighting_plane_alpha()
		if("advanced_bullet_dodge_chance")
			UnregisterSignal(src, COMSIG_ATOM_PREHIT)
			RegisterSignal(src, COMSIG_ATOM_PREHIT, PROC_REF(advanced_bullet_dodge))
		if("maxHealth")
			updatehealth("var edit")
		if("resize")
			update_transform()

/mob/living/throw_at(atom/target, range, speed, mob/thrower, spin, diagonals_first, datum/callback/callback, force, dodgeable, block_movement)
	stop_pulling()
	return ..()

/mob/living/hit_by_thrown_mob(mob/living/C, datum/thrownthing/throwingdatum, damage, mob_hurt, self_hurt)
	if(C == src || HAS_TRAIT(src, TRAIT_FLYING) || !density)
		return
	playsound(src, 'sound/weapons/punch1.ogg', 50, 1)
	if(mob_hurt)
		return
	if(!self_hurt)
		take_organ_damage(damage)
	if(issilicon(C))
		C.adjustBruteLoss(damage)
		C.Weaken(3 SECONDS)
	else
		var/obj/item/organ/external/affecting = C.get_organ(ran_zone(throwingdatum.target_zone))
		if(affecting)
			var/armor_block = C.run_armor_check(affecting, MELEE)
			C.apply_damage(damage, BRUTE, affecting, armor_block)
		else
			C.take_organ_damage(damage)

		C.KnockDown(3 SECONDS)

	C.visible_message("<span class='danger'>[C] crashes into [src], knocking them both over!</span>", "<span class='userdanger'>You violently crash into [src]!</span>")

/**
  * Sets the mob's direction lock towards a given atom.
  *
  * Arguments:
  * * a - The atom to face towards.
  * * track - If TRUE, updates our direction relative to the atom when moving.
  */
/mob/living/proc/set_forced_look(atom/A, track = FALSE)
	forced_look = track ? A.UID() : get_cardinal_dir(src, A)
	to_chat(src, "<span class='userdanger'>You are now facing [track ? A : dir2text(forced_look)]. To cancel this, shift-middleclick yourself.</span>")
	throw_alert("direction_lock", /atom/movable/screen/alert/direction_lock)

/**
  * Clears the mob's direction lock if enabled.
  *
  * Arguments:
  * * quiet - Whether to display a chat message.
  */
/mob/living/proc/clear_forced_look(quiet = FALSE)
	if(!forced_look)
		return
	forced_look = null
	if(!quiet)
		to_chat(src, "<span class='notice'>Cancelled direction lock.</span>")
	clear_alert("direction_lock")

/mob/living/setDir(new_dir)
	if(forced_look)
		if(isnum(forced_look))
			dir = forced_look
		else
			var/atom/A = locateUID(forced_look)
			if(istype(A))
				dir = get_cardinal_dir(src, A)
		return
	return ..()

/mob/living/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	for(var/obj/O in src)
		O.on_mob_move(movement_dir, src)

/// Can a mob interact with the apc remotely like a pulse demon, cyborg, or AI?
/mob/living/proc/can_remote_apc_interface(obj/machinery/power/apc/ourapc)
	return FALSE

/mob/living/proc/plushify(plushie_override, curse_time = 10 MINUTES)
	var/mob/living/simple_animal/shade/sword/generic_item/plushvictim = new(get_turf(src))
	var/obj/item/toy/plushie/plush_type = pick(subtypesof(/obj/item/toy/plushie) - typesof(/obj/item/toy/plushie/fluff) - typesof(/obj/item/toy/plushie/carpplushie)) //exclude the base type.
	if(plushie_override)
		plush_type = plushie_override
	var/obj/item/toy/plushie/plush_outcome = new plush_type(get_turf(src))
	plushvictim.forceMove(plush_outcome)
	plushvictim.key = key
	plushvictim.RegisterSignal(plush_outcome, COMSIG_PARENT_QDELETING, TYPE_PROC_REF(/mob/living/simple_animal/shade/sword/generic_item, handle_item_deletion))
	plushvictim.name = name
	plush_outcome.name = "[name] plushie"
	if(curse_time == -1)
		qdel(src)
	else
		plush_outcome.cursed_plushie_victim = src
		forceMove(plush_outcome)
		notransform = TRUE
		status_flags |= GODMODE
		addtimer(CALLBACK(plush_outcome, TYPE_PROC_REF(/obj/item/toy/plushie, un_plushify)), curse_time)
	to_chat(plushvictim, "<span class='warning'>You have been cursed into an enchanted plush doll! At least you can still move around a bit...</span>")

/mob/living/proc/sec_hud_set_ID()
	return

/// Proc called when TARGETED by a lazarus injector
/mob/living/proc/lazarus_revive(mob/living/reviver, malfunctioning)
	revive()
	befriend(reviver)
	AddElement(/datum/element/wears_collar)
	faction = (malfunctioning) ? list("lazarus", "\ref[reviver]") : list("neutral")
	if(malfunctioning)
		log_game("[reviver] has revived hostile mob [src] with a malfunctioning lazarus injector")

/// Proc for giving a mob a new 'friend', generally used for AI control and
/// targeting. Returns false if already friends or null if qdeleted.
/mob/living/proc/befriend(mob/living/new_friend)
	SHOULD_CALL_PARENT(TRUE)
	if(QDELETED(new_friend))
		return
	var/friend_ref = new_friend.UID()
	if(faction.Find(friend_ref))
		return FALSE
	faction |= friend_ref
	ai_controller?.insert_blackboard_key_lazylist(BB_FRIENDS_LIST, new_friend)

	SEND_SIGNAL(src, COMSIG_LIVING_BEFRIENDED, new_friend)
	return TRUE

/mob/living/proc/get_strippable_items(datum/source, list/items)
	SIGNAL_HANDLER // COMSIG_STRIPPABLE_REQUEST_ITEMS
	return
