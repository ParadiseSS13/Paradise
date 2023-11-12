/mob/living/Initialize()
	. = ..()
	var/datum/atom_hud/data/human/medical/advanced/medhud = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	medhud.add_to_hud(src)
	register_init_signals()
	faction += "\ref[src]"
	determine_move_and_pull_forces()
	GLOB.mob_living_list += src

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
		mind.current = null
	return ..()

/mob/living/ghostize(can_reenter_corpse = 1)
	var/prev_client = client
	. = ..()
	if(.)
		if(ranged_ability && prev_client)
			ranged_ability.remove_mousepointer(prev_client)
	SEND_SIGNAL(src, COMSIG_LIVING_GHOSTIZED)

/mob/living/proc/OpenCraftingMenu()
	return

//Generic Bump(). Override MobBump() and ObjBump() instead of this.
/mob/living/Bump(atom/A, yes)
	if(..()) //we are thrown onto something
		return
	if(buckled || !yes || now_pushing)
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

		if(pulledby == L && a_intent != INTENT_HELP) //prevents boosting the person pulling you, but you can still move through them on help intent
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

	if(a_intent == INTENT_HELP) // Help intent doesn't mob swap a mob pulling a structure
		if(isstructure(M.pulling) || isstructure(pulling))
			return TRUE

	if(!M.buckled && !M.has_buckled_mobs())
		var/mob_swap
		//the puller can always swap with it's victim if on grab intent
		if(M.pulledby == src && a_intent == INTENT_GRAB)
			mob_swap = TRUE
		//restrained people act if they were on 'help' intent to prevent a person being pulled from being seperated from their puller
		else if((M.restrained() || M.a_intent == INTENT_HELP) && (restrained() || a_intent == INTENT_HELP))
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
	if(M.r_hand?.GetComponent(/datum/component/parry) || M.l_hand?.GetComponent(/datum/component/parry))
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
		current_dir = AM.dir
	if(step(AM, t))
		step(src, t)
	if(current_dir)
		AM.setDir(current_dir)
	now_pushing = FALSE

/mob/living/CanPathfindPass(obj/item/card/id/ID, to_dir, atom/movable/caller, no_id = FALSE)
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
	..()
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
	var/pointed_object = "\the [A]"
	if(A.loc in src)
		pointed_object += " inside [A.loc]"
	if(istype(hand_item, /obj/item/gun) && A != hand_item)
		if(a_intent == INTENT_HELP || !ismob(A))
			visible_message("<b>[src]</b> points to [pointed_object] with [hand_item]")
			return TRUE
		A.visible_message("<span class='danger'>[src] points [hand_item] at [pointed_object]!</span>",
											"<span class='userdanger'>[src] points [hand_item] at you!</span>")
		SEND_SOUND(A, sound('sound/weapons/targeton.ogg'))
		return TRUE
	if(istype(hand_item, /obj/item/toy/russian_revolver/trick_revolver) && A != hand_item)
		var/obj/item/toy/russian_revolver/trick_revolver/trick = hand_item
		visible_message("<span class='danger'>[src] points [trick] at- and [trick] goes off in their hand!</span>")
		trick.shoot_gun(src)

	visible_message("<b>[src]</b> points to [pointed_object]")
	return TRUE

/mob/living/verb/succumb()
	set hidden = 1
	if(InCritical())
		create_attack_log("[src] has ["succumbed to death"] with [round(health, 0.1)] points of health!")
		create_log(MISC_LOG, "has succumbed to death with [round(health, 0.1)] points of health")
		adjustOxyLoss(health - HEALTH_THRESHOLD_DEAD)
		// super check for weird mobs, including ones that adjust hp
		// we don't want to go overboard and gib them, though
		for(var/i = 1 to 5)
			if(health < HEALTH_THRESHOLD_DEAD)
				break
			take_overall_damage(max(5, health - HEALTH_THRESHOLD_DEAD), 0)
		death()
		to_chat(src, "<span class='notice'>You have given up life and succumbed to death.</span>")


/mob/living/proc/InCritical()
	return (health < HEALTH_THRESHOLD_CRIT && health > HEALTH_THRESHOLD_DEAD && stat == UNCONSCIOUS)


/mob/living/ex_act(severity)
	..()
	flash_eyes()

/mob/living/acid_act(acidpwr, acid_volume)
	take_organ_damage(acidpwr * min(1, acid_volume * 0.1))
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

	update_stat("updatehealth([reason])")
	med_hud_set_health()
	med_hud_set_status()
	update_health_hud()


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
//	if(istype(src, /mob/living/carbon/human))
//		to_chat(world, "[src] ~ [bodytemperature] ~ [temperature]")
	return temperature


/mob/proc/get_contents()


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

		for(var/obj/item/smallDelivery/D in Storage.return_inv()) //Check for package wrapped items
			L += D.wrapped
			if(isstorage(D.wrapped)) //this should never happen
				L += get_contents(D.wrapped)
		return L

	else

		L += contents
		for(var/obj/item/storage/S in contents)	//Check for storage items
			L += get_contents(S)
		for(var/obj/item/clothing/suit/storage/S in contents)//Check for labcoats and jackets
			L += get_contents(S)
		for(var/obj/item/clothing/accessory/storage/S in contents)//Check for holsters
			L += get_contents(S)
		for(var/obj/item/implant/storage/I in contents) //Check for storage implants.
			L += I.get_contents()
		for(var/obj/item/gift/G in contents) //Check for gift-wrapped items
			L += G.gift
			if(isstorage(G.gift))
				L += get_contents(G.gift)

		for(var/obj/item/smallDelivery/D in contents) //Check for package wrapped items
			L += D.wrapped
			if(isstorage(D.wrapped)) //this should never happen
				L += get_contents(D.wrapped)
		for(var/obj/item/folder/F in contents)
			L += F.contents //Folders can't store any storage items.

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
			C.unEquip(C.handcuffed)
		C.handcuffed = initial(C.handcuffed)
		C.update_handcuffed()

		if(C.legcuffed && !initial(C.legcuffed))
			C.unEquip(C.legcuffed)
		C.legcuffed = initial(C.legcuffed)
		C.update_inv_legcuffed()

		if(C.reagents)
			C.reagents.clear_reagents()
			QDEL_LIST_CONTENTS(C.reagents.addiction_list)
			C.reagents.addiction_threshold_accumulated.Cut()
		if(iscultist(src))
			if(SSticker.mode.cult_risen)
				SSticker.mode.rise(src)
			if(SSticker.mode.cult_ascendant)
				SSticker.mode.ascend(src)

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
	CureTourettes()
	CureEpilepsy()
	CureCoughing()
	CureNervous()
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
		buckled.unbuckle_mob(src, force = TRUE)

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

/mob/living/Move(atom/newloc, direct, movetime)
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

	var/turf/old_loc = loc
	. = ..()
	if(.)
		step_count++
		pull_pulled(old_loc, pullee, movetime)
		pull_grabbed(old_loc, direct, movetime)

	if(pulledby && moving_diagonally != FIRST_DIAG_STEP && get_dist(src, pulledby) > 1) //seperated from our puller and not in the middle of a diagonal move
		pulledby.stop_pulling()

	if(s_active && !(s_active in contents) && get_turf(s_active) != get_turf(src))	//check !( s_active in contents) first so we hopefully don't have to call get_turf() so much.
		s_active.close(src)

/mob/living/proc/pull_pulled(turf/dest, atom/movable/pullee, movetime)
	if(pulling && pulling == pullee) // we were pulling a thing and didn't lose it during our move.
		if(pulling.anchored)
			stop_pulling()
			return

		var/pull_dir = get_dir(src, pulling)
		if(get_dist(src, pulling) > 1 || (moving_diagonally != SECOND_DIAG_STEP && ((pull_dir - 1) & pull_dir))) // puller and pullee more than one tile away or in diagonal position
			if(isliving(pulling))
				var/mob/living/M = pulling
				if(IS_HORIZONTAL(M) && !M.buckled && (prob(M.getBruteLoss() * 200 / M.maxHealth))) // So once you reach 50 brute damage you hit 100% chance to leave a blood trail for every tile you're pulled
					M.makeTrail(dest)
			pulling.Move(dest, get_dir(pulling, dest), movetime) // the pullee tries to reach our previous position
			if(pulling && get_dist(src, pulling) > 1) // the pullee couldn't keep up
				stop_pulling()

/mob/living/proc/pull_grabbed(turf/old_turf, direct, movetime)
	if(!Adjacent(old_turf))
		return
	// We might not actually be grab pulled, but we are pretending that we are, so as to
	// hackily work around issues arising from mutual grabs.
	var/old_being_pulled = currently_grab_pulled
	currently_grab_pulled = TRUE
	// yes, this is four distinct `for` loops. No, they can't be merged.
	var/list/grabbing = list()
	for(var/mob/M in ret_grab())
		if(src == M)
			continue
		if(M.currently_grab_pulled)
			// Being already pulled by something else up the call stack.
			continue
		grabbing |= M
	for(var/mob/M in grabbing)
		M.currently_grab_pulled = TRUE
		M.animate_movement = SYNC_STEPS
	for(var/i in 1 to length(grabbing))
		var/mob/M = grabbing[i]
		if(QDELETED(M))  // old code warned me that M could go missing during a move, so I'm cargo-culting it here
			continue
		// compile a list of turfs we can maybe move them towards
		// importantly, this should happen before actually trying to move them to either of those
		// otherwise they can be moved twice (since `Move` returns TRUE only if it managed to
		// *fully* move where you wanted it to; it can still move partially and return FALSE)
		var/possible_dest = list()
		for(var/turf/dest in orange(src, 1))
			if(dest.Adjacent(M))
				possible_dest |= dest
		if(i == 1) // at least one of them should try to trail behind us, for aesthetics purposes
			if(M.Move(old_turf, get_dir(M, old_turf), movetime))
				continue
		// By this time the `old_turf` is definitely occupied by something immovable.
		// So try to move them into some other adjacent turf, in a believable way
		if(Adjacent(M))
			continue // they are already adjacent
		for(var/turf/dest in possible_dest)
			if(M.Move(dest, get_dir(M, dest), movetime))
				break
	for(var/mob/M in grabbing)
		M.currently_grab_pulled = null
		M.animate_movement = SLIDE_STEPS

	for(var/obj/item/grab/G in src)
		if(G.state == GRAB_NECK)
			setDir(angle2dir((dir2angle(direct) + 202.5) % 365))
		G.adjust_position()
	for(var/obj/item/grab/G in grabbed_by)
		G.adjust_position()

	currently_grab_pulled = old_being_pulled


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

/mob/living/experience_pressure_difference(pressure_difference, direction, pressure_resistance_prob_delta = 0)
	if(buckled)
		return
	if(client && client.move_delay >= world.time + world.tick_lag * 2)
		pressure_resistance_prob_delta -= 30

	var/list/turfs_to_check = list()

	if(has_limbs)
		var/turf/T = get_step(src, angle2dir(dir2angle(direction) + 90))
		if(T)
			turfs_to_check += T

		T = get_step(src, angle2dir(dir2angle(direction) - 90))
		if(T)
			turfs_to_check += T

		for(var/t in turfs_to_check)
			T = t
			if(T.density)
				pressure_resistance_prob_delta -= 20
				continue
			for(var/atom/movable/AM in T)
				if(AM.density && AM.anchored)
					pressure_resistance_prob_delta -= 20
					break

	..(pressure_difference, direction, pressure_resistance_prob_delta)

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

/mob/living/proc/Exhaust()
	to_chat(src, "<span class='notice'>You're too exhausted to keep going...</span>")
	Weaken(10 SECONDS)

/mob/living/proc/get_visible_name()
	return name

/mob/living/proc/is_facehugged()
	return FALSE

/mob/living/update_gravity(has_gravity)
	if(!SSticker)
		return
	if(has_gravity)
		clear_alert("weightless")
	else
		throw_alert("weightless", /obj/screen/alert/weightless)
	if(!flying)
		float(!has_gravity)

/mob/living/proc/float(on)
	if(throwing)
		return
	var/fixed = FALSE
	if(anchored || (buckled && buckled.anchored))
		fixed = TRUE
	if(on && !floating && !fixed)
		animate(src, pixel_y = pixel_y + 2, time = 10, loop = -1)
		sleep(10)
		animate(src, pixel_y = pixel_y - 2, time = 10, loop = -1)
		floating = TRUE
	else if(((!on || fixed) && floating))
		animate(src, pixel_y = get_standard_pixel_y_offset(), time = 10)
		floating = FALSE

/mob/living/proc/can_use_vents()
	return "You can't fit into that vent."

//Checks for anything other than eye protection that would stop flashing. Overridden in carbon.dm and human.dm
/mob/living/proc/can_be_flashed(intensity = 1, override_blindness_check = 0)
	if(check_eye_prot() >= intensity || (!override_blindness_check && (HAS_TRAIT(src, TRAIT_BLIND) || HAS_TRAIT(src, TRAIT_FLASH_PROTECTION))))
		return FALSE

	return TRUE

//called when the mob receives a bright flash
/mob/living/proc/flash_eyes(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0, laser_pointer = FALSE, type = /obj/screen/fullscreen/flash)
	if(can_be_flashed(intensity, override_blindness_check))
		overlay_fullscreen("flash", type)
		addtimer(CALLBACK(src, PROC_REF(clear_fullscreen), "flash", 25), 25)
		return 1

/mob/living/proc/check_eye_prot()
	return 0

/mob/living/proc/check_ear_prot()

/**
 * Returns the name override, if any, for the slot somebody is trying to strip
 */
/mob/living/proc/get_strip_slot_name_override(slot)
	switch(slot)
		if(SLOT_HUD_WEAR_PDA)
			return "PDA"

// The src mob is trying to strip an item from someone
// Override if a certain type of mob should be behave differently when stripping items (can't, for example)
/mob/living/stripPanelUnequip(obj/item/what, mob/who, where, silent = 0)
	var/item_name = get_strip_slot_name_override(where) || what.name
	if(what.flags & NODROP)
		to_chat(src, "<span class='warning'>You can't remove \the [item_name], it appears to be stuck!</span>")
		return
	if(!silent)
		who.visible_message("<span class='danger'>[src] tries to remove [who]'s [item_name].</span>", \
						"<span class='userdanger'>[src] tries to remove [who]'s [item_name].</span>")
	what.add_fingerprint(src)
	if(do_mob(src, who, what.strip_delay))
		if(what && what == who.get_item_by_slot(where) && Adjacent(who))
			who.unEquip(what)
			if(silent)
				put_in_hands(what)
			add_attack_logs(src, who, "Stripped of [what]")

// The src mob is trying to place an item on someone
// Override if a certain mob should be behave differently when placing items (can't, for example)
/mob/living/stripPanelEquip(obj/item/what, mob/who, where, silent = 0)
	what = get_active_hand()
	if(what && (what.flags & NODROP))
		to_chat(src, "<span class='warning'>You can't put \the [what.name] on [who], it's stuck to your hand!</span>")
		return
	if(what)
		if(!what.mob_can_equip(who, where, 1))
			to_chat(src, "<span class='warning'>\The [what.name] doesn't fit in that place!</span>")
			return
		if(!silent)
			visible_message("<span class='notice'>[src] tries to put [what] on [who].</span>")
		if(do_mob(src, who, what.put_on_delay))
			if(what && Adjacent(who) && !(what.flags & NODROP))
				unEquip(what)
				who.equip_to_slot_if_possible(what, where, FALSE, TRUE)
				add_attack_logs(src, who, "Equipped [what]")

/mob/living/singularity_act()
	investigate_log("([key_name(src)]) has been consumed by the singularity.","singulo") //Oh that's where the clown ended up!
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
		loc_temp =  M.return_temperature()

	else if(istype(loc, /obj/structure/transit_tube_pod))
		loc_temp = environment.temperature

	else if(isspaceturf(get_turf(src)))
		var/turf/heat_turf = get_turf(src)
		loc_temp = heat_turf.temperature

	else if(istype(loc, /obj/machinery/atmospherics/unary/cryo_cell))
		var/obj/machinery/atmospherics/unary/cryo_cell/C = loc

		if(C.air_contents.total_moles() < 10)
			loc_temp = environment.temperature
		else
			loc_temp = C.air_contents.temperature

	else
		loc_temp = environment.temperature

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
	if(user.a_intent == INTENT_HARM && stat == DEAD && butcher_results) //can we butcher it?
		var/sharpness = is_sharp(I)
		if(sharpness)
			to_chat(user, "<span class='notice'>You begin to butcher [src]...</span>")
			playsound(loc, 'sound/weapons/slice.ogg', 50, 1, -1)
			if(do_mob(user, src, 80 / sharpness) && Adjacent(I))
				harvest(user)
			return 1

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
	if(forced_look)
		. += 3
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
	if(ismob(AM))
		var/mob/M = AM
		if(!iscarbon(src))
			M.LAssailant = null
		else
			M.LAssailant = usr

/mob/living/proc/check_pull()
	if(pulling && !pulling.Adjacent(src))
		stop_pulling()

/mob/living/proc/update_z(new_z) // 1+ to register, null to unregister
	if(registered_z != new_z)
		if(registered_z)
			SSmobs.clients_by_zlevel[registered_z] -= src
		if(client)
			if(new_z)
				SSmobs.clients_by_zlevel[new_z] += src
				for(var/I in length(SSidlenpcpool.idle_mobs_by_zlevel[new_z]) to 1 step -1) //Backwards loop because we're removing (guarantees optimal rather than worst-case performance), it's fine to use .len here but doesn't compile on 511
					var/mob/living/simple_animal/SA = SSidlenpcpool.idle_mobs_by_zlevel[new_z][I]
					if(SA)
						SA.toggle_ai(AI_ON) // Guarantees responsiveness for when appearing right next to mobs
					else
						SSidlenpcpool.idle_mobs_by_zlevel[new_z] -= SA
			registered_z = new_z
		else
			registered_z = null

/mob/living/onTransitZ(old_z,new_z)
	..()
	update_z(new_z)

/mob/living/rad_act(amount)
	. = ..()

	if(!amount || (amount < RAD_MOB_SKIN_PROTECTION) || HAS_TRAIT(src, TRAIT_RADIMMUNE))
		return

	amount -= RAD_BACKGROUND_RADIATION // This will always be at least 1 because of how skin protection is calculated

	var/blocked = getarmor(null, RAD)

	if(amount > RAD_BURN_THRESHOLD)
		apply_damage(RAD_BURN_CURVE(amount), BURN, null, blocked)

	apply_effect((amount * RAD_MOB_COEFFICIENT) / max(1, (radiation ** 2) * RAD_OVERDOSE_REDUCTION), IRRADIATE, blocked)

/mob/living/proc/fakefireextinguish()
	return

/mob/living/proc/fakefire()
	return

/mob/living/extinguish_light(force = FALSE)
	for(var/atom/A in src)
		if(A.light_range > 0)
			A.extinguish_light(force)

/mob/living/vv_edit_var(var_name, var_value)
	switch(var_name)
		if("stat")
			if((stat == DEAD) && (var_value < DEAD))//Bringing the dead back to life
				GLOB.dead_mob_list -= src
				GLOB.alive_mob_list += src
			if((stat < DEAD) && (var_value == DEAD))//Kill he
				GLOB.alive_mob_list -= src
				GLOB.dead_mob_list += src
	. = ..()
	switch(var_name)
		if("maxHealth")
			updatehealth()
		if("resize")
			update_transform()
		if("lighting_alpha")
			sync_lighting_plane_alpha()

/mob/living/throw_at(atom/target, range, speed, mob/thrower, spin, diagonals_first, datum/callback/callback, force, dodgeable)
	stop_pulling()
	return ..()

/mob/living/hit_by_thrown_carbon(mob/living/carbon/human/C, datum/thrownthing/throwingdatum, damage, mob_hurt, self_hurt)
	if(C == src || flying || !density)
		return
	playsound(src, 'sound/weapons/punch1.ogg', 50, 1)
	if(mob_hurt)
		return
	if(!self_hurt)
		take_organ_damage(damage)
	C.take_organ_damage(damage)
	C.KnockDown(3 SECONDS)
	C.visible_message("<span class='danger'>[C] crashes into [src], knocking them both over!</span>", "<span class='userdanger'>You violently crash into [src]!</span>")
