GLOBAL_LIST_EMPTY(sacrificed) // A mixed list of minds and mobs
GLOBAL_LIST_EMPTY(teleport_runes) // I'll give you two guesses

/*
This file contains runes.
Runes are used by the cult to cause many different effects and are paramount to their success.
They are drawn with a ritual dagger in blood, and are distinguishable to cultists and normal crew by examining.
Fake runes can be drawn in crayon to fool people.
Runes can either be invoked by one's self or with many different cultists. Each rune has a specific incantation that the cultists will say when invoking it.
To draw a rune, use a ritual dagger.
*/

/obj/effect/rune
	/// Name non-cultists see
	name = "rune"
	/// Name that cultists see
	var/cultist_name = "basic rune"
	/// Description that non-cultists see
	desc = "An odd collection of symbols drawn in what seems to be blood."
	/// Description that cultists see
	var/cultist_desc = "a basic rune with no function." //This is shown to cultists who examine the rune in order to determine its true purpose.
	icon = 'icons/obj/rune.dmi'
	icon_state = "1"
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	mouse_opacity = MOUSE_OPACITY_OPAQUE // So that runes aren't so hard to click
	var/visibility = 0
	var/view_range = 7
	invisibility = INVISIBILITY_RUNES
	layer = SIGIL_LAYER
	color = COLOR_BLOOD_BASE

	/// What is said by cultists when the rune is invoked
	var/invocation = "Aiy ele-mayo!"
	///The amount of cultists required around the rune to invoke it. If only 1, any cultist can invoke it.
	var/req_cultists = 1
	/// Used for some runes, this is for when you want a rune to not be usable when in use.
	var/rune_in_use = FALSE

	/// How long the rune takes to create (Currently only different for the Nar'Sie rune)
	var/scribe_delay = 5 SECONDS
	/// How much damage you take from drawing the rune
	var/scribe_damage = 1

	/// If nearby cultists will also chant when invoked
	var/allow_excess_invokers = FALSE
	/// If constructs can invoke it
	var/construct_invoke = TRUE

	/// If the rune requires a keyword (e.g. Teleport runes)
	var/req_keyword = FALSE
	/// The actual keyword for the rune
	var/keyword

	/// How much damage cultists take when invoking it (This includes constructs)
	var/invoke_damage = 0
	/// The color of the rune. (Based on species blood color)
	var/rune_blood_color = COLOR_BLOOD_BASE

/obj/effect/rune/Initialize(mapload, set_keyword)
	. = ..()
	if(set_keyword)
		keyword = set_keyword
	var/image/blood = image(loc = src)
	blood.override = 1
	for(var/mob/living/silicon/ai/AI in GLOB.ai_list)
		AI.client.images += blood

/obj/effect/rune/examine(mob/user)
	. = ..()
	if(IS_CULTIST(user) || isobserver(user)) //If they're a cultist or a ghost, tell them the effects
		. += "<b>Name:</b> [cultist_name]"
		. += "<b>Effects:</b> [capitalize(cultist_desc)]"
		. += "<b>Required Acolytes:</b> [req_cultists]"
		if(req_keyword && keyword)
			. += "<b>Keyword:</b> <span class='cultitalic'>[keyword]</span>"

/obj/effect/rune/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/melee/cultblade/dagger) && IS_CULTIST(user))
		if(!can_dagger_erase_rune(user))
			return ITEM_INTERACT_COMPLETE

		var/obj/item/melee/cultblade/dagger/dagger = used
		user.visible_message("<span class='warning'>[user] begins to erase [src] with [dagger].</span>")
		if(do_after(user, initial(scribe_delay) * dagger.scribe_multiplier, target = src))
			to_chat(user, "<span class='notice'>You carefully erase the [lowertext(cultist_name)] rune.</span>")
			qdel(src)
		return ITEM_INTERACT_COMPLETE

	if(istype(used, /obj/item/nullrod))
		var/obj/item/nullrod/nullrod = used
		if(IS_CULTIST(user)) // cultist..what are doing..cultist..staph...
			user.drop_item()
			user.visible_message("<span class='warning'>[nullrod] suddenly glows with a white light, forcing [user] to drop it in pain!</span>", \
			"<span class='danger'>[nullrod] suddenly glows with a white light that sears your hand, forcing you to drop it!</span>") // TODO: Make this actually burn your hand
			return ITEM_INTERACT_COMPLETE
		to_chat(user,"<span class='danger'>You disrupt the magic of [src] with [nullrod].</span>")
		qdel(src)
		return ITEM_INTERACT_COMPLETE

/obj/effect/rune/proc/can_dagger_erase_rune(mob/user)
	return TRUE

/obj/effect/rune/attack_hand(mob/living/user)
	user.Move_Pulled(src) // So that you can still drag things onto runes
	if(!IS_CULTIST(user))
		to_chat(user, "<span class='warning'>You aren't able to understand the words of [src].</span>")
		return
	var/list/invokers = can_invoke(user)
	if(length(invokers) >= req_cultists)
		invoke(invokers)
	else
		fail_invoke()

/obj/effect/rune/attack_animal(mob/living/simple_animal/M)
	if(isshade(M) || isconstruct(M))
		if(construct_invoke || !IS_CULTIST(M)) //if you're not a cult construct we want the normal fail message
			attack_hand(M)
		else
			to_chat(M, "<span class='warning'>You are unable to invoke the rune!</span>")

/obj/effect/rune/cult_conceal() //for concealing spell
	visible_message("<span class='danger'>[src] fades away.</span>")
	invisibility = INVISIBILITY_HIDDEN_RUNES
	alpha = 100 //To help ghosts distinguish hidden runes

/obj/effect/rune/cult_reveal() //for revealing spell
	invisibility = initial(invisibility)
	visible_message("<span class='danger'>[src] suddenly appears!</span>")
	alpha = initial(alpha)

/obj/effect/rune/is_cleanable()
	return TRUE

/obj/effect/rune/cleaning_act(mob/user, atom/cleaner, cleanspeed = 5 SECONDS, text_verb = "scrub out", text_description = " with [cleaner].")
	if(issimulatedturf(loc))
		var/turf/simulated/T = get_turf(src)
		T.cleaning_act(user, cleaner, cleanspeed = cleanspeed, text_verb = text_verb, text_description = text_description, text_targetname = name) //Strings are deliberately "A = A" to avoid overrides
		return
	else
		..()


/*
There are a few different procs each rune runs through when a cultist activates it.
can_invoke() is called when a cultist activates the rune with an empty hand. If there are multiple cultists, this rune determines if the required amount is nearby.
invoke() is the rune's actual effects.
fail_invoke() is called when the rune fails, via not enough people around or otherwise. Typically this just has a generic 'fizzle' effect.
structure_check() searches for nearby cultist structures required for the invocation. Proper structures are pylons, forges, archives, and altars.
*/
/obj/effect/rune/proc/can_invoke(mob/living/user)
	if(user.holy_check())
		return
	//This proc determines if the rune can be invoked at the time. If there are multiple required cultists, it will find all nearby cultists.
	var/list/invokers = list() //people eligible to invoke the rune
	var/list/chanters = list() //people who will actually chant the rune when passed to invoke()
	if(invisibility == INVISIBILITY_HIDDEN_RUNES)//hidden rune
		return
	// Get the user
	if(user)
		chanters |= user
		invokers |= user
	// Get anyone nearby
	if(req_cultists > 1 || allow_excess_invokers)
		for(var/mob/living/L in range(1, src))
			if(IS_CULTIST(L))
				if(L == user)
					continue
				if(L.stat)
					continue
				invokers |= L

		if(length(invokers) >= req_cultists) // If there's enough invokers
			if(allow_excess_invokers)
				chanters |= invokers // Let the others join in too
			else
				invokers -= user
				shuffle(invokers)
				for(var/i in 0 to req_cultists)
					var/L = pick_n_take(invokers)
					chanters |= L
	return chanters

/obj/effect/rune/proc/invoke(list/invokers)
	//This proc contains the effects of the rune as well as things that happen afterwards. If you want it to spawn an object and then delete itself, have both here.
	SHOULD_CALL_PARENT(TRUE)
	var/ghost_invokers = 0
	for(var/M in invokers)
		var/mob/living/L = M
		if(!L)
			return
		if(L.has_status_effect(STATUS_EFFECT_SUMMONEDGHOST))
			ghost_invokers++
		if(invocation)
			if(!L.IsVocal() || L.cannot_speak_loudly())
				L.custom_emote(EMOTE_VISIBLE, message = pick("draws arcane sigils in the air.","gestures ominously.","silently mouths out an invocation.","places their hands on the rune, activating it."))
			else
				L.say(invocation)
			L.changeNext_move(CLICK_CD_MELEE)//THIS IS WHY WE CAN'T HAVE NICE THINGS
		if(invoke_damage)
			L.apply_damage(invoke_damage, BRUTE)
			to_chat(L, "<span class='cultitalic'>[src] saps your strength!</span>")
	do_invoke_glow()
	SSblackbox.record_feedback("nested tally", "runes_invoked", 1, list("[initial(cultist_name)]", "[length(SSticker.mode.cult_team.members)]")) // the name of the rune, and the number of cultists in the cult when it was invoked
	if(ghost_invokers)
		SSblackbox.record_feedback("nested tally", "runes_invoked_with_ghost", 1, list("[initial(cultist_name)]", "[ghost_invokers]")) //the name of the rune and the number of ghosts used to invoke it.

/**
  * Spawns the phase in/out effects for a cult teleport.
  *
  * Arguments:
  * * user - Mob to teleport
  * * location - Location to teleport from
  * * target - Location to teleport to
  */
/obj/effect/rune/proc/teleport_effect(mob/living/user, turf/location, turf/target)
	new /obj/effect/temp_visual/dir_setting/cult/phase/out(location, user.dir)
	new /obj/effect/temp_visual/dir_setting/cult/phase(target, user.dir)
	// So that the mob only appears after the effect is finished
	user.notransform = TRUE
	user.invisibility = INVISIBILITY_MAXIMUM
	sleep(12)
	user.notransform = FALSE
	user.invisibility = 0

/obj/effect/rune/proc/do_invoke_glow()
	var/oldtransform = transform
	animate(src, transform = matrix() * 2, alpha = 0, time = 5) // Fade out
	animate(transform = oldtransform, alpha = 255, time = 0)

/obj/effect/rune/proc/fail_invoke(show_message = TRUE)
	//This proc contains the effects of a rune if it is not invoked correctly, through either invalid wording or not enough cultists. By default, it's just a basic fizzle.
	if(!invisibility && show_message) // No visible messages if not visible
		visible_message("<span class='warning'>The markings pulse with a small flash of red light, then fall dark.</span>")
	animate(src, color = rgb(255, 0, 0), time = 0)
	animate(src, color = rune_blood_color, time = 5)

//Malformed Rune: This forms if a rune is not drawn correctly. Invoking it does nothing but hurt the user.
/obj/effect/rune/malformed
	cultist_name = "Malformed"
	cultist_desc = "a senseless rune written in gibberish. No good can come from invoking this."
	invocation = "Ra'sha yoka!"
	invoke_damage = 30

/obj/effect/rune/malformed/invoke(list/invokers)
	..()
	for(var/M in invokers)
		var/mob/living/L = M
		to_chat(L, "<span class='cultitalic'><b>You feel your life force draining. [GET_CULT_DATA(entity_title3, "Your god")] is displeased.</b></span>")
	qdel(src)

/mob/proc/null_rod_check() //The null rod, if equipped, will protect the holder from the effects of most runes
	if(can_block_magic(MAGIC_RESISTANCE_HOLY))
		return TRUE
	return FALSE

//Rite of Enlightenment: Converts a normal crewmember to the cult, or offer them as sacrifice if cant be converted.
/obj/effect/rune/convert
	cultist_name = "Offer"
	cultist_desc = "offers non-cultists on top of it to the Dark One, either converting or sacrificing them. Sacrifices with a soul will result in a captured soulshard. This can be done with brains as well."
	invocation = "Mah'weyh pleggh at e'ntrath!"
	icon_state = "offering"
	allow_excess_invokers = TRUE

/obj/effect/rune/convert/invoke(list/invokers)
	if(rune_in_use)
		return

	var/list/offer_targets = list()
	var/turf/T = get_turf(src)
	for(var/mob/living/M in T)
		if(!IS_CULTIST(M) || (M.mind && IS_SACRIFICE_TARGET(M.mind)))
			if(isconstruct(M)) // No offering constructs please
				continue
			offer_targets += M

	// Offering a head/brain
	for(var/obj/item/organ/O in T)
		var/mob/living/brain/b_mob
		if(istype(O, /obj/item/organ/external/head)) // Offering a head
			var/obj/item/organ/external/head/H = O
			for(var/obj/item/organ/internal/brain/brain in H.contents)
				b_mob = brain.brainmob
				brain.forceMove(T)

		else if(istype(O, /obj/item/organ/internal/brain)) // Offering a brain
			var/obj/item/organ/internal/brain/brain = O
			b_mob = brain.brainmob

		if(b_mob && b_mob.mind && (!IS_CULTIST(b_mob) || IS_SACRIFICE_TARGET(b_mob.mind)))
			offer_targets += b_mob

	if(!length(offer_targets))
		fail_invoke()
		log_game("Offer rune failed - no eligible targets")
		rune_in_use = FALSE
		return

	rune_in_use = TRUE
	var/mob/living/L = pick(offer_targets)
	if(HAS_TRAIT(L, TRAIT_CULT_IMMUNITY))
		fail_invoke(FALSE)
		for(var/I in invokers)
			to_chat(I, "<span class='warning'>This sacrifice was already converted recently. Wait a minute before trying again!</span>")
		rune_in_use = FALSE
		return

	if(L.stat != DEAD && SSticker.mode.cult_team.is_convertable_to_cult(L.mind))
		..()
		do_convert(L, invokers)
	else
		invocation = "Barhah hra zar'garis!"
		..()
		do_sacrifice(L, invokers)
	rune_in_use = FALSE

/obj/effect/rune/convert/proc/do_convert(mob/living/convertee, list/invokers)
	if(length(invokers) < 2)
		fail_invoke()
		for(var/I in invokers)
			to_chat(I, "<span class='warning'>You need at least two invokers to convert!</span>")
		return

	convertee.visible_message("<span class='warning'>[convertee] writhes in pain as the markings below them glow a bloody red!</span>", \
							"<span class='cultlarge'><i>AAAAAAAAAAAAAA-</i></span>")
	convertee.mind.add_antag_datum(/datum/antagonist/cultist)
	to_chat(convertee, "<span class='cultitalic'><b>Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible, truth. The veil of reality has been ripped away \
		and something evil takes root.</b></span>")
	to_chat(convertee, "<span class='cultitalic'><b>Assist your new compatriots in their dark dealings. Your goal is theirs, and theirs is yours. You serve [GET_CULT_DATA(entity_title3, "your god")] above all else. Bring it back.\
		</b></span>")

	if(ishuman(convertee))
		var/mob/living/carbon/human/H = convertee
		var/brutedamage = convertee.getBruteLoss()
		var/burndamage = convertee.getFireLoss()
		if(brutedamage || burndamage) // If the convertee is injured
			// Heal 90% of all damage, including robotic limbs
			H.adjustBruteLoss(-(brutedamage * 0.9), robotic = TRUE)
			H.adjustFireLoss(-(burndamage * 0.9), robotic = TRUE)
			if(ismachineperson(H))
				H.visible_message("<span class='warning'>A dark force repairs [convertee]!</span>",
				"<span class='cultitalic'>Your damage has been repaired. Now spread the blood to others.</span>")
			else
				H.visible_message("<span class='warning'>[convertee]'s wounds heal and close!</span>",
				"<span class='cultitalic'>Your wounds have been healed. Now spread the blood to others.</span>")
				for(var/obj/item/organ/external/E in H.bodyparts)
					E.mend_fracture()
					E.fix_internal_bleeding()
					E.fix_burn_wound()
				for(var/datum/disease/critical/crit in H.viruses) // cure all crit conditions
					crit.cure()

		H.clear_restraints()
		H.Silence(6 SECONDS) //Prevent "HALP MAINT CULT" before you realise you're converted
		if(H.reagents?.has_reagent("holywater"))
			H.reagents.del_reagent("holywater") // Also prevent fill stomach with holy water and "forgot" about it after converting

		var/obj/item/melee/cultblade/dagger/D = new(get_turf(src))
		if(H.equip_to_slot_if_possible(D, ITEM_SLOT_IN_BACKPACK, FALSE, TRUE))
			to_chat(H, "<span class='cultlarge'>You have a dagger in your backpack. Use it to do [GET_CULT_DATA(entity_title1, "your god")]'s bidding.</span>")
		else
			to_chat(H, "<span class='cultlarge'>There is a dagger on the floor. Use it to do [GET_CULT_DATA(entity_title1, "your god")]'s bidding.</span>")

/obj/effect/rune/convert/proc/do_sacrifice(mob/living/offering, list/invokers)
	var/mob/living/user = invokers[1] //the first invoker is always the user

	if(offering.stat != DEAD || (offering.mind && IS_SACRIFICE_TARGET(offering.mind))) //Requires three people to sacrifice living targets/sacrifice objective
		if(length(invokers) < 3)
			for(var/M in invokers)
				to_chat(M, "<span class='cultitalic'>[offering] is too greatly linked to the world! You need three acolytes!</span>")
			fail_invoke()
			log_game("Sacrifice rune failed - not enough acolytes and target is living")
			return

	var/sacrifice_fulfilled
	var/worthless = FALSE

	if(isliving(offering) && !isbrain(offering))
		var/mob/living/L = offering
		if(isrobot(L) || ismachineperson(L))
			L.adjustBruteLoss(250)
		else
			L.adjustCloneLoss(120)
		L.death(FALSE)

	if(offering.mind)
		GLOB.sacrificed += offering.mind
		if(IS_SACRIFICE_TARGET(offering.mind))
			sacrifice_fulfilled = TRUE
	else
		GLOB.sacrificed += offering

	new /obj/effect/temp_visual/cult/sac(loc)
	for(var/M in invokers)
		if(sacrifice_fulfilled)
			to_chat(M, "<span class='cultlarge'>\"Yes! This is the one I desire! You have done well.\"</span>")
			if(!SSticker.mode.cult_team.mirror_shields_active) // Only show once
				to_chat(M, "<span class='cultitalic'>You are now able to construct mirror shields inside the daemon forge.</span>")
				SSticker.mode.cult_team.mirror_shields_active = TRUE
		else
			if((ishuman(offering) && offering.mind?.offstation_role && offering.mind.special_role != SPECIAL_ROLE_ERT) || HAS_MIND_TRAIT(offering, TRAIT_XENOBIO_SPAWNED_HUMAN)) //If you try it on a ghost role, or an envolved caterpillar/nymph, you get nothing
				to_chat(M, "<span class='cultlarge'>\"This soul is of no use to either of us.\"</span>")
				worthless = TRUE
			else if(ishuman(offering) || isrobot(offering))
				to_chat(M, "<span class='cultlarge'>\"I accept this sacrifice.\"</span>")
			else
				to_chat(M, "<span class='cultlarge'>\"I accept this meager sacrifice.\"</span>")
	playsound(offering, 'sound/misc/demon_consume.ogg', 100, TRUE, SOUND_RANGE_SET(10))

	if(((ishuman(offering) || isrobot(offering) || isbrain(offering)) && offering.mind) && !worthless)
		var/obj/item/soulstone/stone = new /obj/item/soulstone(get_turf(src))
		stone.invisibility = INVISIBILITY_MAXIMUM // So it's not picked up during transfer_soul()
		stone.transfer_soul("FORCE", offering, user) // If it cannot be added
		stone.invisibility = 0
		var/put_in_hands = user.put_in_any_hand_if_possible(stone)
		if(put_in_hands)
			to_chat(user, "<span class='cultitalic'>A glowing crimson shard appears in your hand - your new ally contained within.</span>")
	else
		if(isrobot(offering))
			offering.dust() //To prevent the MMI from remaining
		else
			offering.gib()
		playsound(offering, 'sound/magic/disintegrate.ogg', 100, TRUE, SOUND_RANGE_SET(10))
	if(sacrifice_fulfilled)
		SSticker.mode.cult_team.successful_sacrifice()
	return TRUE

/obj/effect/rune/teleport
	cultist_name = "Teleport"
	cultist_desc = "warps everything above it to another chosen teleport rune."
	invocation = "Sas'so c'arta forbici!"
	icon_state = "teleport"
	req_keyword = TRUE
	light_power = 4
	var/obj/effect/temp_visual/cult/portal/inner_portal //The portal "hint" for off-station teleportations
	var/obj/effect/temp_visual/cult/rune_spawn/rune2/outer_portal
	var/listkey

/obj/effect/rune/teleport/Initialize(mapload, set_keyword)
	. = ..()
	var/area/A = get_area(src)
	var/locname = initial(A.name)
	listkey = set_keyword ? "[set_keyword] [locname]":"[locname]"
	GLOB.teleport_runes += src

/obj/effect/rune/teleport/Destroy()
	GLOB.teleport_runes -= src
	QDEL_NULL(inner_portal)
	QDEL_NULL(outer_portal)
	return ..()

/obj/effect/rune/teleport/can_dagger_erase_rune(mob/user)
	// Can't erase telerunes if they have a portal open
	if(inner_portal || outer_portal)
		to_chat(user, "<span class='warning'>The portal needs to close first!</span>")
		return FALSE
	return TRUE

/obj/effect/rune/teleport/invoke(list/invokers)
	var/mob/living/user = invokers[1] //the first invoker is always the user
	var/list/potential_runes = list()
	var/list/teleportnames = list()
	var/list/duplicaterunecount = list()

	for(var/I in GLOB.teleport_runes)
		var/obj/effect/rune/teleport/R = I
		var/resultkey = R.listkey
		if(resultkey in teleportnames)
			duplicaterunecount[resultkey]++
			resultkey = "[resultkey] ([duplicaterunecount[resultkey]])"
		else
			teleportnames += resultkey
			duplicaterunecount[resultkey] = 1
		if(R != src && is_level_reachable(R.z))
			potential_runes[resultkey] = R

	if(!length(potential_runes))
		to_chat(user, "<span class='warning'>There are no valid runes to teleport to!</span>")
		log_game("Teleport rune failed - no other teleport runes")
		fail_invoke()
		return

	if(!is_level_reachable(user.z))
		to_chat(user, "<span class='cultitalic'>You are too far away from the station to teleport!</span>")
		log_game("Teleport rune failed - user in away mission")
		fail_invoke()
		return

	var/input_rune_key = tgui_input_list(user, "Choose a rune to teleport to.", "Rune to Teleport to", potential_runes) //we know what key they picked
	var/obj/effect/rune/teleport/actual_selected_rune = potential_runes[input_rune_key] //what rune does that key correspond to?
	if(QDELETED(src) || QDELETED(actual_selected_rune) ||!Adjacent(user) || user.incapacitated())
		fail_invoke()
		return

	var/turf/T = get_turf(src)
	var/turf/target = get_turf(actual_selected_rune)
	var/movedsomething = FALSE
	var/moveuser = FALSE
	for(var/atom/movable/A in T)
		if(SEND_SIGNAL(A, COMSIG_MOVABLE_TELEPORTING, target) & COMPONENT_BLOCK_TELEPORT)
			continue
		if(ishuman(A))
			if(A != user) // Teleporting someone else
				INVOKE_ASYNC(src, PROC_REF(teleport_effect), A, T, target)
			else // Teleporting yourself
				INVOKE_ASYNC(src, PROC_REF(teleport_effect), user, T, target)
		if(A.move_resist == INFINITY)
			continue  //object cant move, shouldnt teleport
		if(A == user)
			moveuser = TRUE
			movedsomething = TRUE
			continue
		if(!A.anchored)
			movedsomething = TRUE
			A.forceMove(target)

	if(movedsomething)
		..()
		if(is_mining_level(z) && !is_mining_level(target.z)) //No effect if you stay on lavaland
			actual_selected_rune.handle_portal("lava")
		else if(!is_station_level(z) || isspacearea(get_area(src)))
			actual_selected_rune.handle_portal("space", T)
		user.visible_message("<span class='warning'>There is a sharp crack of inrushing air, and everything above the rune disappears!</span>",
							"<span class='cult'>You[moveuser ? "r vision blurs, and you suddenly appear somewhere else":" send everything above the rune away"].</span>")
		if(moveuser)
			user.forceMove(target)
	else
		fail_invoke()

/obj/effect/rune/teleport/proc/handle_portal(portal_type, turf/origin)
	var/turf/T = get_turf(src)
	if(inner_portal || outer_portal)
		close_portal() // To avoid stacking descriptions/animations
	playsound(T, pick('sound/effects/sparks1.ogg', 'sound/effects/sparks2.ogg', 'sound/effects/sparks3.ogg', 'sound/effects/sparks4.ogg'), 100, TRUE, 14)
	inner_portal = new /obj/effect/temp_visual/cult/portal(T)

	if(portal_type == "space")
		light_color = color
		desc += "<br><span class='boldwarning'>A tear in reality reveals a black void interspersed with dots of light... something recently teleported here from space.</span><br>"

		// Space base near the station
		if(is_station_level(origin.z))
			desc += "<u><span class='warning'>The void feels like it's trying to pull you to the [dir2text(get_dir(T, origin))], near the station!</span></u>"
		// Space base on another Z-level
		else
			desc += "<u><span class='warning'>The void feels like it's trying to pull you to the [dir2text(get_dir(T, origin))], in the direction of space sector [origin.z]!</span></u>"

	else
		inner_portal.icon_state = "lava"
		light_color = LIGHT_COLOR_FIRE
		desc += "<br><span class='boldwarning'>A tear in reality reveals a coursing river of lava... something recently teleported here from the Lavaland Mines!</span>"

	outer_portal = new(T, 60 SECONDS, color)
	light_range = 4
	update_light()
	addtimer(CALLBACK(src, PROC_REF(close_portal)), 60 SECONDS, TIMER_UNIQUE)

/obj/effect/rune/teleport/proc/close_portal()
	qdel(inner_portal)
	qdel(outer_portal)
	desc = initial(desc)
	light_range = 0
	update_light()


//Rune of Empowering : Enables carrying 4 blood spells, greatly reduce blood cost
/obj/effect/rune/empower
	cultist_name = "Empower"
	cultist_desc = "allows cultists to prepare greater amounts of blood magic at far less of a cost."
	invocation = "H'drak v'loso, mir'kanas verbot!"
	icon_state = "empower"
	construct_invoke = FALSE

/obj/effect/rune/empower/invoke(list/invokers)
	. = ..()
	var/mob/living/user = invokers[1] //the first invoker is always the user
	for(var/datum/action/innate/cult/blood_magic/BM in user.actions)
		BM.Activate()

//Rite of Resurrection: Requires a dead or inactive cultist. When reviving the dead, you can only perform one revival for every three sacrifices your cult has carried out.
/obj/effect/rune/raise_dead
	cultist_name = "Revive"
	cultist_desc = "requires a dead, alive, mindless, or inactive cultist placed upon the rune. For each three bodies sacrificed to the dark patron, one body will be mended and their mind awoken. Mending living cultist requires two cultists at the rune"
	invocation = "Pasnar val'keriam usinar. Savrae ines amutan. Yam'toth remium il'tarat!" //Depends on the name of the user - see below
	icon_state = "revive"
	var/static/sacrifices_used = -SOULS_TO_REVIVE // Cultists get one "free" revive
	allow_excess_invokers = TRUE

/obj/effect/rune/raise_dead/examine(mob/user)
	. = ..()
	if(IS_CULTIST(user) || user.stat == DEAD)
		. += "<b>Sacrifices unrewarded:</b><span class='cultitalic'> [length(GLOB.sacrificed) - sacrifices_used]</span>"
		. += "<b>Sacrifice cost per ressurection:</b><span class='cultitalic'> [SOULS_TO_REVIVE]</span>"

/obj/effect/rune/raise_dead/proc/revive_alive(mob/living/target)
	target.visible_message("<span class='warning'>Dark magic begins to surround [target], regenerating their body.</span>")
	if(!do_after(target, 10 SECONDS, FALSE, target, allow_moving = FALSE, progress = TRUE))
		target.visible_message("<span class='warning'>Dark magic silently disappears.</span>")
		return FALSE
	target.revive()
	return TRUE

/obj/effect/rune/raise_dead/proc/revive_dead(mob/living/target)
	target.revive()
	if(target.ghost_can_reenter())
		target.grab_ghost()
	return TRUE

/obj/effect/rune/raise_dead/invoke(list/invokers)
	var/turf/T = get_turf(src)
	var/mob/living/mob_to_revive
	var/list/potential_revive_mobs = list()
	var/mob/living/user = invokers[1]
	if(rune_in_use)
		return
	rune_in_use = TRUE
	var/diff = length(GLOB.sacrificed) - SOULS_TO_REVIVE - sacrifices_used
	var/revived_from_dead = FALSE
	if(diff < 0)
		to_chat(user, "<span class='cult'>Your cult must carry out [abs(diff)] more sacrifice\s before it can revive another cultist!</span>")
		fail_invoke()
		return
	for(var/mob/living/M in T.contents)
		if(!IS_CULTIST(M))
			continue
		potential_revive_mobs |= M
	if(!length(potential_revive_mobs))
		to_chat(user, "<span class='cultitalic'>There are no cultists on the rune!</span>")
		log_game("Raise Dead rune failed - no cultists to revive")
		fail_invoke()
		return
	if(length(potential_revive_mobs) > 1)
		mob_to_revive = tgui_input_list(user, "Choose a cultist to revive.", "Cultist to Revive", potential_revive_mobs)
	else // If there's only one, no need for a menu
		mob_to_revive = potential_revive_mobs[1]
	if(!validness_checks(mob_to_revive, user))
		fail_invoke()
		return

	if(mob_to_revive.stat != DEAD && length(invokers) < 2)
		to_chat(user, "<span class='cultitalic'>You need at least two cultists to heal cultist!</span>")
		log_game("Raise Dead rune failed - not enough cultists to heal alive")
		fail_invoke()
		return

	if(mob_to_revive.stat != DEAD)
		if(!revive_alive(mob_to_revive))
			fail_invoke()
			return
	else
		if(!revive_dead(mob_to_revive))
			fail_invoke()
			return
		revived_from_dead = TRUE
	..()
	sacrifices_used += SOULS_TO_REVIVE

	if(!mob_to_revive.get_ghost() && (!mob_to_revive.client || mob_to_revive.client.is_afk()))
		set waitfor = FALSE
		to_chat(user, "<span class='cult'>[mob_to_revive] was revived, but their mind is lost! Seeking a lost soul to replace it.</span>")
		var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Would you like to play as a revived Cultist?", ROLE_CULTIST, TRUE, poll_time = 20 SECONDS, source = /obj/item/melee/cultblade/dagger)
		if(length(candidates) && !QDELETED(mob_to_revive))
			var/mob/dead/observer/C = pick(candidates)
			to_chat(mob_to_revive, "<span class='biggerdanger'>Your physical form has been taken over by another soul due to your inactivity! Ahelp if you wish to regain your form.</span>")
			message_admins("[key_name_admin(C)] has taken control of ([key_name_admin(mob_to_revive)]) to replace an AFK player.")
			mob_to_revive.ghostize(GHOST_FLAGS_NO_REENTER)
			mob_to_revive.key = C.key
			dust_if_respawnable(C)
		else
			fail_invoke()
			return
	if(!revived_from_dead)
		mob_to_revive.visible_message("<span class='warning'>[mob_to_revive] draws in a huge breath, red light shining from [mob_to_revive.p_their()] eyes.</span>", \
								"<span class='cultlarge'>All your injuries are now gone!</span>")
		rune_in_use = FALSE
		return
	SEND_SOUND(mob_to_revive, sound('sound/ambience/antag/bloodcult.ogg'))
	to_chat(mob_to_revive, "<span class='cultlarge'>\"PASNAR SAVRAE YAM'TOTH. Arise.\"</span>")
	mob_to_revive.visible_message("<span class='warning'>[mob_to_revive] draws in a huge breath, red light shining from [mob_to_revive.p_their()] eyes.</span>", \
								"<span class='cultlarge'>You awaken suddenly from the void. You're alive!</span>")
	rune_in_use = FALSE

/obj/effect/rune/raise_dead/proc/validness_checks(mob/living/target_mob, mob/living/user)
	if(QDELETED(src))
		return FALSE
	if(QDELETED(user))
		return FALSE
	if(!Adjacent(user) || user.incapacitated())
		return FALSE
	if(QDELETED(target_mob))
		return FALSE
	var/turf/T = get_turf(src)
	if(target_mob.loc != T)
		to_chat(user, "<span class='cultitalic'>The cultist to revive has been moved!</span>")
		log_game("Raise Dead rune failed - revival target moved")
		return FALSE
	return TRUE

/obj/effect/rune/raise_dead/fail_invoke()
	..()
	rune_in_use = FALSE
	for(var/mob/living/M in range(0, src))
		if(IS_CULTIST(M) && M.stat == DEAD)
			M.visible_message("<span class='warning'>[M] twitches.</span>")

//Rite of the Corporeal Shield: When invoked, becomes solid and cannot be passed. Invoke again to undo.
/obj/effect/rune/wall
	cultist_name = "Barrier"
	cultist_desc = "when invoked makes a temporary wall to block passage. Can be destroyed by brute force. Can be invoked again to reverse this."
	invocation = "Khari'd! Eske'te tannin!"
	icon_state = "barrier"
	///The barrier summoned by the rune when invoked. Tracked as a variable to prevent refreshing the barrier's integrity. shieldgen.dm
	var/obj/machinery/shield/cult/barrier/B

/obj/effect/rune/wall/Initialize(mapload)
	. = ..()
	B = new /obj/machinery/shield/cult/barrier(loc)
	B.parent_rune = src

/obj/effect/rune/wall/Destroy()
	if(B && !QDELETED(B))
		QDEL_NULL(B)
	return ..()

/obj/effect/rune/wall/invoke(list/invokers)
	var/mob/living/user = invokers[1]
	..()
	var/amount = 1
	if(B.Toggle()) // Toggling on
		for(var/obj/effect/rune/wall/rune in orange(1, src)) // Chaining barriers
			if(!rune.B.density) // Barrier is currently invisible
				amount++ // Count the invoke damage for each rune
				rune.do_invoke_glow()
				rune.B.Toggle()
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.cult_self_harm(2 * amount)

//Rite of Joined Souls: Summons a single cultist.
/obj/effect/rune/summon
	cultist_name = "Summon Cultist"
	cultist_desc = "summons a single cultist to the rune. <b><i>(Cannot summon restrained cultists!)</b></i>"
	invocation = "N'ath reth sh'yro eth d'rekkathnor!"
	req_cultists = 2
	invoke_damage = 10
	icon_state = "summon"

/obj/effect/rune/summon/invoke(list/invokers)
	var/mob/living/user = invokers[1]
	var/list/cultists = list()

	for(var/datum/mind/M in SSticker.mode.cult_team.members)
		if(!(M.current in invokers) && M.current && M.current.stat != DEAD)
			cultists[M.current.real_name] = M.current
	var/input = tgui_input_list(user, "Who do you wish to call to [src]?", "Acolytes", cultists)
	var/mob/living/cultist_to_summon = cultists[input]
	if(QDELETED(src) || !Adjacent(user) || user.incapacitated())
		return
	if(!cultist_to_summon)
		log_game("Summon Cultist rune failed - no target")
		return
	if(cultist_to_summon.stat == DEAD)
		to_chat(user, "<span class='cultitalic'>[cultist_to_summon] has died!</span>")
		fail_invoke()
		log_game("Summon Cultist rune failed - target died")
		return
	if(cultist_to_summon.pulledby || cultist_to_summon.buckled)
		to_chat(user, "<span class='cultitalic'>[cultist_to_summon] is being held in place!</span>")
		to_chat(cultist_to_summon, "<span class='cult'>You feel a tugging sensation, but you are being held in place!")
		fail_invoke()
		log_game("Summon Cultist rune failed - target restrained")
		return
	if(!IS_CULTIST(cultist_to_summon))
		to_chat(user, "<span class='cultitalic'>[cultist_to_summon] is not a follower of [GET_CULT_DATA(entity_title3, "our god")]!</span>")
		fail_invoke()
		log_game("Summon Cultist rune failed - target was deconverted")
		return
	if(is_away_level(cultist_to_summon.z))
		to_chat(user, "<span class='cultitalic'>[cultist_to_summon] is not in our dimension!</span>")
		fail_invoke()
		log_game("Summon Cultist rune failed - target in away mission")
		return
	if(SEND_SIGNAL(cultist_to_summon, COMSIG_MOVABLE_TELEPORTING, get_turf(src)) & COMPONENT_BLOCK_TELEPORT)
		to_chat(user, "<span class='cultitalic'>[cultist_to_summon] is anchored in bluespace!</span>")
		fail_invoke()
		log_game("Summon Cultist rune failed - anchored in bluespace")
		return

	cultist_to_summon.visible_message("<span class='warning'>[cultist_to_summon] suddenly disappears in a flash of red light!</span>", \
									"<span class='cultitalic'><b>Overwhelming vertigo consumes you as you are hurled through the air!</b></span>")
	..()
	INVOKE_ASYNC(src, PROC_REF(teleport_effect), cultist_to_summon, get_turf(cultist_to_summon), get_turf(src))
	visible_message("<span class='warning'>[src] begins to bubble and rises into the form of [cultist_to_summon]!</span>")
	cultist_to_summon.forceMove(get_turf(src))
	qdel(src)

/**
  * # Blood Boil Rune
  *
  * When invoked deals up to 30 burn damage to nearby non-cultists and sets them on fire.
  *
  * On activation the rune charges for six seconds, changing colour, glowing, and giving out a warning to all nearby mobs.
  * After the charging period the rune burns any non-cultists in view and sets them on fire. After another short wait it does the same again with slightly higher damage.
  * If the cultists channeling the rune move away or are stunned at any point, the rune is deleted. So it can be countered pretty easily with flashbangs.
  */
/obj/effect/rune/blood_boil
	cultist_name = "Boil Blood"
	cultist_desc = "boils the blood of non-believers who can see the rune, rapidly dealing extreme amounts of damage. Requires 2 invokers channeling the rune."
	invocation = "Dedo ol'btoh!"
	icon_state = "blood_boil"
	light_color = LIGHT_COLOR_LAVA
	req_cultists = 2
	invoke_damage = 15
	construct_invoke = FALSE
	var/tick_damage = 10 // 30 burn damage total + damage taken by being on fire/overheating

/obj/effect/rune/blood_boil/invoke(list/invokers)
	if(rune_in_use)
		return
	..()
	rune_in_use = TRUE
	var/turf/T = get_turf(src)
	var/list/targets = list()
	for(var/mob/living/L in viewers(T))
		if(!IS_CULTIST(L) && L.blood_volume && !ismachineperson(L))
			var/atom/I = L.null_rod_check()
			if(I)
				if(isitem(I))
					to_chat(L, "<span class='userdanger'>[I] suddenly burns hotly before returning to normal!</span>")
				continue
			targets += L

	// Six seconds buildup
	visible_message("<span class='warning'>A haze begins to form above [src]!</span>")
	animate(src, color = "#FC9A6D", time = 6 SECONDS)
	set_light(6, 1, color)
	sleep(6 SECONDS)
	visible_message("<span class='boldwarning'>[src] turns a bright, burning orange!</span>")
	if(!burn_check())
		return

	for(var/I in targets)
		to_chat(I, "<span class='userdanger'>Your blood boils in your veins!</span>")
	do_area_burn(T, 1)
	animate(src, color = "#FFDF80", time = 5 SECONDS)
	sleep(5 SECONDS)
	if(!burn_check())
		return

	do_area_burn(T, 2)
	animate(src, color = "#FFFFFF", time = 5 SECONDS)
	sleep(5 SECONDS)
	if(!burn_check())
		return

	do_area_burn(T, 3)
	qdel(src)

/obj/effect/rune/blood_boil/proc/do_area_burn(turf/T, iteration)
	var/multiplier = iteration / 2 // Iteration 1 = 0.5, Iteration 2 = 1, etc.
	set_light(6, 1 * iteration, color)
	for(var/mob/living/L in viewers(T))
		if(!IS_CULTIST(L) && L.blood_volume && !ismachineperson(L))
			if(L.null_rod_check())
				continue
			L.take_overall_damage(0, tick_damage * multiplier)
			L.adjust_fire_stacks(2)
			L.IgniteMob()
	playsound(src, 'sound/effects/bamf.ogg', 100, TRUE)
	do_invoke_glow()
	sleep(0.6 SECONDS) // Only one 'animate()' can play at once, so this waits for the pulse to finish

/obj/effect/rune/blood_boil/proc/burn_check()
	. = TRUE
	if(QDELETED(src))
		return FALSE
	var/list/cultists = list()
	for(var/mob/living/M in range(1, src)) // Get all cultists currently in range
		if(IS_CULTIST(M) && !M.incapacitated())
			cultists += M

	if(length(cultists) < req_cultists) // Stop the rune there's not enough invokers
		visible_message("<span class='warning'>[src] loses its glow and dissipates!</span>")
		qdel(src)

/obj/effect/rune/manifest
	cultist_name = "Spirit Realm"
	cultist_desc = "manifests a spirit servant of the Dark One and allows you to ascend as a spirit yourself. The invoker must not move from atop the rune, and will take damage for each summoned spirit."
	invocation = "Gal'h'rfikk harfrandid mud'gib!" //how the fuck do you pronounce this
	icon_state = "spirit_realm"
	construct_invoke = FALSE
	var/mob/dead/observer/ghost = null //The cult ghost of the user
	var/default_ghost_limit = 4 //Lowered by the amount of cult objectives done
	var/minimum_ghost_limit = 2 //But cant go lower than this
	var/ghosts = 0

/obj/effect/rune/manifest/examine(mob/user)
	. = ..()
	if(IS_CULTIST(user) || user.stat == DEAD)
		. += "<b>Amount of ghosts summoned:</b><span class='cultitalic'> [ghosts]</span>"
		. += "<b>Maximum amount of ghosts:</b><span class='cultitalic'> [clamp(default_ghost_limit - SSticker.mode.cult_team.sacrifices_done, minimum_ghost_limit, default_ghost_limit)]</span>"
		. += "Lowers to a minimum of [minimum_ghost_limit] for each objective accomplished."

/obj/effect/rune/manifest/invoke(list/invokers)
	. = ..()
	var/mob/living/user = invokers[1]
	var/turf/T = get_turf(src)
	if(!(user in get_turf(src)))
		to_chat(user, "<span class='cultitalic'>You must be standing on [src]!</span>")
		fail_invoke()
		log_game("Manifest rune failed - user not standing on rune")
		return
	if(user.has_status_effect(STATUS_EFFECT_SUMMONEDGHOST))
		to_chat(user, "<span class='cultitalic'>Ghosts can't summon more ghosts!</span>")
		fail_invoke()
		log_game("Manifest rune failed - user is a ghost")
		return

	var/choice = tgui_alert(user, "You tear open a connection to the spirit realm...", "Invoke", list("Summon a Cult Ghost", "Ascend as a Dark Spirit", "Cancel"))
	if(choice == "Summon a Cult Ghost")
		if(!is_station_level(z) || isspacearea(get_area(src)))
			to_chat(user, "<span class='cultitalic'>The veil is not weak enough here to manifest spirits, you must be on station!</span>")
			fail_invoke()
			log_game("Manifest rune failed - not on station")
			return
		if(user.health <= 40)
			to_chat(user, "<span class='cultitalic'>Your body is too weak to manifest spirits, heal yourself first.</span>")
			fail_invoke()
			log_game("Manifest rune failed - not enough health")
			return list()
		if(ghosts >= clamp(default_ghost_limit - SSticker.mode.cult_team.sacrifices_done, minimum_ghost_limit, default_ghost_limit))
			to_chat(user, "<span class='cultitalic'>You are sustaining too many ghosts to summon more!</span>")
			fail_invoke()
			log_game("Manifest rune failed - too many summoned ghosts")
			return list()
		summon_ghosts(user, T)

	else if(choice == "Ascend as a Dark Spirit")
		ghostify(user, T)


/obj/effect/rune/manifest/proc/summon_ghosts(mob/living/user, turf/T)
	notify_ghosts("Manifest rune created in [get_area(src)].", ghost_sound = 'sound/effects/ghost2.ogg', source = src)
	var/list/ghosts_on_rune = list()
	for(var/mob/dead/observer/O in T)
		if(!O.client)
			continue
		if(IS_CULTIST(O) || jobban_isbanned(O, ROLE_CULTIST))
			continue
		if(!HAS_TRAIT(O, TRAIT_RESPAWNABLE) || QDELETED(src) || QDELETED(O))
			continue
		if(!O.mind)
			continue
		if(O.mind.current && HAS_TRAIT(O.mind.current, SCRYING))
			continue
		ghosts_on_rune += O
	if(!length(ghosts_on_rune))
		to_chat(user, "<span class='cultitalic'>There are no spirits near [src]!</span>")
		fail_invoke()
		log_game("Manifest rune failed - no nearby ghosts")
		return list()

	var/mob/dead/observer/ghost_to_spawn = pick(ghosts_on_rune)
	var/mob/living/carbon/human/new_human = new(T)
	new_human.real_name = ghost_to_spawn.real_name
	new_human.key = ghost_to_spawn.key
	new_human.gender = ghost_to_spawn.gender
	new_human.alpha = 150 //Makes them translucent
	new_human.equipOutfit(/datum/outfit/ghost_cultist) //give them armor
	new_human.apply_status_effect(STATUS_EFFECT_SUMMONEDGHOST, user) //ghosts can't summon more ghosts, also lets you see actual ghosts
	for(var/obj/item/organ/external/current_organ in new_human.bodyparts)
		current_organ.limb_flags |= CANNOT_DISMEMBER //you can't chop of the limbs of a ghost, silly
	ghosts++
	playsound(src, 'sound/misc/exit_blood.ogg', 50, TRUE, SOUND_RANGE_SET(10))
	user.visible_message("<span class='warning'>A cloud of red mist forms above [src], and from within steps... a [new_human.gender == FEMALE ? "wo" : ""]man.</span>",
						"<span class='cultitalic'>Your blood begins flowing into [src]. You must remain in place and conscious to maintain the forms of those summoned. This will hurt you slowly but surely...</span>")

	var/obj/machinery/shield/cult/weak/shield = new(T)
	new_human.mind.add_antag_datum(/datum/antagonist/cultist)
	to_chat(new_human, "<span class='cultlarge'>You are a servant of [GET_CULT_DATA(entity_title3, "the cult")]. You have been made semi-corporeal by the cult of [GET_CULT_DATA(entity_name, "your god")], and you are to serve them at all costs.</span>")

	while(!QDELETED(src) && !QDELETED(user) && !QDELETED(new_human) && (user in T))
		if(new_human.InCritical())
			to_chat(user, "<span class='cultitalic'>You feel your connection to [new_human.real_name] severs as they are destroyed.</span>")
			if(ghost)
				to_chat(ghost, "<span class='cultitalic'>You feel your connection to [new_human.real_name] severs as they are destroyed.</span>")
			break
		if(user.stat || user.health <= 40)
			to_chat(user, "<span class='cultitalic'>Your body can no longer sustain the connection, and your link to the spirit realm fades.</span>")
			if(ghost)
				to_chat(ghost, "<span class='cultitalic'>Your body is damaged and your connection to the spirit realm weakens, any ghost you may have manifested are destroyed.</span>")
			break
		user.apply_damage(0.1, BRUTE)
		user.apply_damage(0.1, BURN)
		sleep(2) //Takes two pylons to sustain the damage taken by summoning one ghost

	qdel(shield)
	ghosts--
	if(new_human)
		new_human.visible_message("<span class='warning'>[new_human] suddenly dissolves into bones and ashes.</span>",
								"<span class='cultlarge'>Your link to the world fades. Your form breaks apart.</span>")
		for(var/obj/item/I in new_human.get_all_slots())
			new_human.drop_item_to_ground(I)
		new_human.mind.remove_antag_datum(/datum/antagonist/cultist, silent_removal = TRUE)
		new_human.dust()

/obj/effect/rune/manifest/proc/ghostify(mob/living/user, turf/T)
	ADD_TRAIT(user, SCRYING, CULT_TRAIT)
	user.visible_message("<span class='warning'>[user] freezes statue-still, glowing an unearthly red.</span>",
					"<span class='cult'>You see what lies beyond. All is revealed. In this form you find that your voice booms above all others.</span>")
	ghost = user.ghostize(ghost_name = "Dark Spirit of [user.name]", ghost_color = RUNE_COLOR_DARKRED)
	var/datum/action/innate/cult/comm/spirit/CM = new
	var/datum/action/innate/cult/check_progress/V = new
	//var/datum/action/innate/cult/ghostmark/GM = new
	CM.Grant(ghost)
	V.Grant(ghost)
	//GM.Grant(ghost)
	while(!QDELETED(user))
		if(user.key || QDELETED(src))
			user.visible_message("<span class='warning'>[user] slowly relaxes, the glow around [user.p_them()] dimming.</span>",
								"<span class='danger'>You are re-united with your physical form. [src] releases its hold over you.</span>")
			user.Weaken(6 SECONDS)
			break
		if(user.health <= 10)
			to_chat(ghost, "<span class='cultitalic'>Your body can no longer sustain the connection!</span>")
			break
		if(!(user in T))
			user.visible_message("<span class='warning'>A spectral tendril wraps around [user] and pulls [user.p_them()] back to the rune!</span>")
			Beam(user, icon_state = "drainbeam", time = 2)
			user.forceMove(get_turf(src)) //NO ESCAPE :^)
		sleep(5)
	if(user.grab_ghost())
		CM.Remove(ghost)
		V.Remove(ghost)
		//GM.Remove(ghost)
	REMOVE_TRAIT(user, SCRYING, CULT_TRAIT)
	user.remove_atom_colour(ADMIN_COLOUR_PRIORITY, RUNE_COLOR_DARKRED)
	user = null
	rune_in_use = FALSE


//Ritual of Dimensional Rending: Calls forth the avatar of Nar'Sie upon the station.
/obj/effect/rune/narsie
	cultist_name = "Tear Veil"
	cultist_desc = "tears apart dimensional barriers, calling forth your god."
	invocation = "TOK-LYR RQA-NAP G'OLT-ULOFT!!"
	req_cultists = 9
	icon = 'icons/effects/96x96.dmi'
	icon_state = "rune_large"
	pixel_x = -32 //So the big ol' 96x96 sprite shows up right
	pixel_y = -32
	mouse_opacity = MOUSE_OPACITY_ICON //we're huge and easy to click
	scribe_delay = 45 SECONDS //how long the rune takes to create
	scribe_damage = 10 //how much damage you take doing it
	var/used = FALSE

/obj/effect/rune/narsie/Initialize(mapload)
	. = ..()
	cultist_name = "Summon [GET_CULT_DATA(entity_name, "your god")]"
	cultist_desc = "tears apart dimensional barriers, calling forth [GET_CULT_DATA(entity_title3, "your god")]."

/obj/effect/rune/narsie/cult_conceal() //can't hide this, and you wouldn't want to
	return

/obj/effect/rune/narsie/is_cleanable() //No, you can't just yeet a cleaning grenade to remove it.
	return FALSE

/obj/effect/rune/narsie/invoke(list/invokers)
	if(used)
		return
	var/mob/living/user = invokers[1]
	if(!is_station_level(user.z))
		message_admins("[key_name_admin(user)] tried to summon an eldritch horror off station")
		log_game("Summon Nar'Sie rune failed - off station Z level")
		return
	if(SSticker.mode.cult_team.cult_status == NARSIE_HAS_RISEN)
		for(var/M in invokers)
			to_chat(M, "<span class='cultlarge'>\"I am already here. There is no need to try to summon me now.\"</span>")
		log_game("Summon god rune failed - already summoned")
		return

	//BEGIN THE SUMMONING
	SSticker.mode.cult_team.successful_summon()
	used = TRUE
	color = COLOR_RED
	..()

	for(var/mob/M in GLOB.player_list)
		if(!isnewplayer(M)) // exclude people in the lobby
			SEND_SOUND(M, sound('sound/effects/dimensional_rend.ogg'))
			to_chat(M, "<span class='cultitalic'><b>The veil... <span class='big'>is...</span> <span class='reallybig'>TORN!!!--</span></b></span>")

	icon_state = "rune_large_distorted"
	var/turf/T = get_turf(src)
	sleep(40)
	new /obj/singularity/narsie/large(T) //Causes Nar'Sie to spawn even if the rune has been removed

/obj/effect/rune/narsie/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	. = ..()
	if((istype(used, /obj/item/melee/cultblade/dagger) && IS_CULTIST(user)))
		log_game("Summon Narsie rune erased by [key_name(user)] with a cult dagger")
		message_admins("[key_name_admin(user)] erased a Narsie rune with a cult dagger")
	if(istype(used, /obj/item/nullrod))	//Begone foul magiks. You cannot hinder me.
		log_game("Summon Narsie rune erased by [key_name(user)] using a null rod")
		message_admins("[key_name_admin(user)] erased a Narsie rune with a null rod")
