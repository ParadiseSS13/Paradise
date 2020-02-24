GLOBAL_LIST_EMPTY(sacrificed) //a mixed list of minds and mobs
GLOBAL_LIST_EMPTY(wall_runes)
var/list/non_revealed_runes = (subtypesof(/obj/effect/rune) - /obj/effect/rune/malformed)

/*
This file contains runes.
Runes are used by the cult to cause many different effects and are paramount to their success.
They are drawn with an arcane tome in blood, and are distinguishable to cultists and normal crew by examining.
Fake runes can be drawn in crayon to fool people.
Runes can either be invoked by one's self or with many different cultists. Each rune has a specific incantation that the cultists will say when invoking it.
To draw a rune, use an arcane tome.
*/

/obj/effect/rune
	name = "rune"
	var/cultist_name = "basic rune"
	desc = "An odd collection of symbols drawn in what seems to be blood."
	var/cultist_desc = "a basic rune with no function." //This is shown to cultists who examine the rune in order to determine its true purpose.
	anchored = TRUE
	icon = 'icons/obj/rune.dmi'
	icon_state = "1"
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/visibility = 0
	var/view_range = 7
	layer = SIGIL_LAYER
	color = RUNE_COLOR_RED

	var/invocation = "Aiy ele-mayo!" //This is said by cultists when the rune is invoked.
	var/req_cultists = 1 //The amount of cultists required around the rune to invoke it. If only 1, any cultist can invoke it.
	var/rune_in_use = 0 // Used for some runes, this is for when you want a rune to not be usable when in use.

	var/scribe_delay = 50 //how long the rune takes to create
	var/scribe_damage = 0.1 //how much damage you take doing it

	var/allow_excess_invokers = 0 //if we allow excess invokers when being invoked
	var/construct_invoke = TRUE //if constructs can invoke it

	var/req_keyword = 0 //If the rune requires a keyword - go figure amirite
	var/keyword //The actual keyword for the rune

	var/invoke_damage = 0 //how much damage invokers take when invoking it

/obj/effect/rune/New(loc, set_keyword)
	..()
	if(set_keyword)
		keyword = set_keyword
	//check_icon()
	var/image/blood = image(loc = src)
	blood.override = 1
	for(var/mob/living/silicon/ai/AI in GLOB.player_list)
		AI.client.images += blood

/obj/effect/rune/examine(mob/user)
	. = ..()
	if(iscultist(user) || user.stat == DEAD) //If they're a cultist or a ghost, tell them the effects
		. += "<b>Name:</b> [cultist_name]"
		. += "<b>Effects:</b> [capitalize(cultist_desc)]"
		. += "<b>Required Acolytes:</b> [req_cultists]"
		if(req_keyword && keyword)
			. += "<b>Keyword:</b> [keyword]"

/obj/effect/rune/attackby(obj/I, mob/user, params)
	if(istype(I, /obj/item/melee/cultblade/dagger) && iscultist(user))
		user.visible_message("<span class='warning'>[user] begins to erase [src] with [I].</span>")
		if(do_after(user, 50, target = src))
			to_chat(user, "<span class='notice'>You carefully erase the [lowertext(cultist_name)] rune.</span>")
			qdel(src)
		return
	if(istype(I, /obj/item/nullrod))
		if(iscultist(user))//cultist..what are doing..cultist..staph...
			user.drop_item()
			user.visible_message("<span class='warning'>[I] suddenly glows with white light, forcing [user] to drop it in pain!</span>", \
			"<span class='warning'><b>[I] suddenly glows with a white light that sears your hand, forcing you to drop it!</b></span>")
			return
		to_chat(user,"<span class='danger'>You disrupt the magic of [src] with [I].</span>")
		qdel(src)
		return
	return ..()

/obj/effect/rune/attack_hand(mob/living/user)
	if(!iscultist(user))
		to_chat(user, "<span class='warning'>You aren't able to understand the words of [src].</span>")
		return
	var/list/invokers = can_invoke(user)
	if(invokers.len >= req_cultists)
		invoke(invokers)
	else
		fail_invoke(user)


/obj/effect/rune/attack_animal(mob/living/simple_animal/M)
	if(istype(M, /mob/living/simple_animal/shade) || istype(M, /mob/living/simple_animal/hostile/construct))
		if(construct_invoke || !iscultist(M)) //if you're not a cult construct we want the normal fail message
			attack_hand(M)
		else
			to_chat(M, "<span class='warning'>You are unable to invoke the rune!</span>")

/obj/effect/rune/cult_conceal() //for concealing spell
	visible_message("<span class='danger'>[src] fades away.</span>")
	invisibility = INVISIBILITY_OBSERVER
	alpha = 100 //To help ghosts distinguish hidden runes

/obj/effect/rune/cult_reveal() //for revealing spell
	invisibility = 0
	visible_message("<span class='danger'>[src] suddenly appears!</span>")
	alpha = initial(alpha)

/*
There are a few different procs each rune runs through when a cultist activates it.
can_invoke() is called when a cultist activates the rune with an empty hand. If there are multiple cultists, this rune determines if the required amount is nearby.
invoke() is the rune's actual effects.
fail_invoke() is called when the rune fails, via not enough people around or otherwise. Typically this just has a generic 'fizzle' effect.
structure_check() searches for nearby cultist structures required for the invocation. Proper structures are pylons, forges, archives, and altars.
*/

/obj/effect/rune/proc/can_invoke(var/mob/living/user)
	//This proc determines if the rune can be invoked at the time. If there are multiple required cultists, it will find all nearby cultists.
	var/list/invokers = list() //people eligible to invoke the rune
	var/list/chanters = list() //people who will actually chant the rune when passed to invoke()
	if(invisibility == INVISIBILITY_OBSERVER)//hidden rune
		return
	if(user)
		chanters |= user
		invokers |= user
	if(req_cultists > 1 || allow_excess_invokers)
		for(var/mob/living/L in range(1, src))
			if(iscultist(L))
				if(L == user)
					continue
				if(ishuman(L))
					var/mob/living/carbon/human/H = L
					if(!H.can_speak())
						continue
				if(L.stat)
					continue
				invokers |= L
		if(invokers.len >= req_cultists)
			if(allow_excess_invokers)
				chanters |= invokers
			else
				invokers -= user
				shuffle(invokers)
				for(var/i in 0 to req_cultists)
					var/L = pick_n_take(invokers)
					chanters |= L
	return chanters

/obj/effect/rune/proc/invoke(var/list/invokers)
	//This proc contains the effects of the rune as well as things that happen afterwards. If you want it to spawn an object and then delete itself, have both here.
	for(var/M in invokers)
		var/mob/living/L = M
		if(invocation && L)
			if(!L.IsVocal())
				L.emote("gestures ominously.")
			else
				L.say(invocation)
			L.changeNext_move(CLICK_CD_MELEE)//THIS IS WHY WE CAN'T HAVE NICE THINGS
		if(invoke_damage)
			L.apply_damage(invoke_damage, BRUTE)
			to_chat(L, "<span class='cultitalic'>[src] saps your strength!</span>")
	do_invoke_glow()

/obj/effect/rune/proc/do_invoke_glow()
    var/oldtransform = transform
    spawn(0) //animate is a delay, we want to avoid being delayed
        animate(src, transform = matrix()*2, alpha = 0, time = 5) //fade out
        animate(transform = oldtransform, alpha = 255, time = 0)

/obj/effect/rune/proc/fail_invoke(var/mob/living/user)
	//This proc contains the effects of a rune if it is not invoked correctly, through either invalid wording or not enough cultists. By default, it's just a basic fizzle.
	visible_message("<span class='warning'>The markings pulse with a small flash of red light, then fall dark.</span>")
	spawn(0) //animate is a delay, we want to avoid being delayed
		animate(src, color = rgb(255, 0, 0), time = 0)
		animate(src, color = initial(color), time = 5)

/obj/effect/rune/proc/fizzle()
	if(istype(src, /obj/effect/rune))
		usr.say(pick("Hakkrutju gopoenjim.", "Nherasai pivroiashan.", "Firjji prhiv mazenhor.", "Tanah eh wakantahe.", "Obliyae na oraie.", "Miyf hon vnor'c.", "Wakabai hij fen juswix."))
	else
		usr.whisper(pick("Hakkrutju gopoenjim.", "Nherasai pivroiashan.", "Firjji prhiv mazenhor.", "Tanah eh wakantahe.", "Obliyae na oraie.", "Miyf hon vnor'c.", "Wakabai hij fen juswix."))
	for (var/mob/V in viewers(src))
		V.show_message("<span class='warning'>The markings pulse with a small burst of light, then fall dark.</span>", 3, "<span class='warning'>You hear a faint fizzle.</span>", 2)
	return

/obj/effect/rune/proc/check_icon()
	if(!SSticker.mode)//work around for maps with runes and cultdat is not loaded all the way
		var/bits = make_bit_triplet()
		icon = get_rune(bits)
	else
		icon = get_rune_cult(invocation)


//Malformed Rune: This forms if a rune is not drawn correctly. Invoking it does nothing but hurt the user.
/obj/effect/rune/malformed
	cultist_name = "malformed rune"
	cultist_desc = "a senseless rune written in gibberish. No good can come from invoking this."
	invocation = "Ra'sha yoka!"
	invoke_damage = 30

/obj/effect/rune/malformed/invoke(var/list/invokers)
	..()
	for(var/M in invokers)
		var/mob/living/L = M
		to_chat(L, "<span class='cultitalic'><b>You feel your life force draining. [SSticker.cultdat.entity_title3] is displeased.</b></span>")
	qdel(src)

/mob/proc/null_rod_check() //The null rod, if equipped, will protect the holder from the effects of most runes
	var/obj/item/nullrod/N = locate() in src
	if(N)
		return N
	return 0

//Rite of Enlightenment: Converts a normal crewmember to the cult. Faster for every cultist nearby.
/obj/effect/rune/convert
	cultist_name = "Offer"
	cultist_desc = "Offers non-cultists on top of it to [SSticker.cultdat.entity_name], either converting or sacrificing them."
	invocation = "Mah'weyh pleggh at e'ntrath!"
	icon_state = "3"
	color = RUNE_COLOR_OFFER
	req_cultists = 1
	allow_excess_invokers = TRUE
	rune_in_use = FALSE

/obj/effect/rune/convert/do_invoke_glow()
	return

/obj/effect/rune/convert/invoke(var/list/invokers)
	if(rune_in_use)
		return
	var/list/myriad_targets = list()
	var/turf/T = get_turf(src)
	for(var/mob/living/M in T)
		if(!iscultist(M) || (M.mind && is_sacrifice_target(M.mind)))
			myriad_targets |= M
	if(!myriad_targets.len)
		fail_invoke()
		log_game("Offer rune failed - no eligible targets")
		rune_in_use = FALSE
		return

	rune_in_use = TRUE
	var/mob/living/new_cultist = pick(myriad_targets)
	if(is_convertable_to_cult(new_cultist.mind) && !new_cultist.null_rod_check() && !is_sacrifice_target(new_cultist.mind) && new_cultist.stat != DEAD && new_cultist.client != null)
		invocation = "Mah'weyh pleggh at e'ntrath!"
		..()
		do_convert(new_cultist, invokers)
	else
		invocation = "Barhah hra zar'garis!"
		..()
		do_sacrifice(new_cultist, invokers)
	rune_in_use = FALSE

/obj/effect/rune/convert/proc/do_convert(mob/living/convertee, list/invokers)
	if(invokers.len < 1)
		fail_invoke()
		for(var/I in invokers)
			to_chat(I, "<span class='warning'>You need at least two invokers to convert!</span>")
		return
	else
		convertee.visible_message("<span class='warning'>[convertee] writhes in pain as the markings below them glow a bloody red!</span>", \
									"<span class='cultlarge'><i>AAAAAAAAAAAAAA-</i></span>")
		SSticker.mode.add_cultist(convertee.mind)
		convertee.mind.special_role = "Cultist"
		to_chat(convertee, "<span class='cultitalic'><b>Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible, truth. The veil of reality has been ripped away \
		and something evil takes root.</b></span>")
		to_chat(convertee, "<span class='cultitalic'><b>Assist your new compatriots in their dark dealings. Your goal is theirs, and theirs is yours. You serve [SSticker.cultdat.entity_title3] above all else. Bring it back.\
		</b></span>")
		if(ishuman(convertee))
			var/brutedamage = convertee.getBruteLoss()
			var/burndamage = convertee.getFireLoss()
			if(brutedamage || burndamage)
				if(ismachine(convertee))
					convertee.visible_message("<span class='warning'>A dark force repairs [convertee]!</span>", \
												"<span class='cultitalic'>Your damage has been repaired. Now spread the blood to others.</span>")
				else
					convertee.visible_message("<span class='warning'>[convertee]'s wounds heal and close!</span>", \
												"<span class='cultitalic'>Your wounds have been healed. Now spread the blood to others.</span>")
				convertee.adjustBruteLoss(-(brutedamage * 0.90))
				convertee.adjustFireLoss(-(burndamage * 0.90))
			var/mob/living/carbon/human/H = convertee
			for(var/obj/item/organ/external/E in H.bodyparts)
				E.mend_fracture()
				E.internal_bleeding = FALSE
			for(var/datum/disease/critical/crit in H.viruses) // cure all crit conditions
				crit.cure()
			H.uncuff()
			var/obj/item/melee/cultblade/dagger/D = new(get_turf(src))
			if(H.equip_to_slot_if_possible(D, slot_in_backpack, FALSE, TRUE))
				to_chat(H, "<span class='cultlarge'>You have a dagger in your backpack. Use it to do [SSticker.cultdat.entity_title1]'s bidding. </span>")
			else
				to_chat(H, "<span class='cultlarge'>There is a dagger on the floor. Use it to do [SSticker.cultdat.entity_title1]'s bidding.</span>")
	return

/obj/effect/rune/convert/proc/do_sacrifice(mob/living/offering, list/invokers)
	var/mob/living/user = invokers[1] //the first invoker is always the user
	if(offering.stat != DEAD || is_sacrifice_target(offering.mind)) //Requires three people to sacrifice living targets/sacrifice objective
		if(invokers.len < 3)
			for(var/M in invokers)
				to_chat(M, "<span class='cultitalic'>[offering] is too greatly linked to the world! You need three acolytes!</span>")
			fail_invoke()
			log_game("Sacrifice rune failed - not enough acolytes and target is living")
			return

	var/sacrifice_fulfilled
	var/datum/game_mode/gamemode = SSticker.mode
	if(offering.mind)
		GLOB.sacrificed += offering.mind
		if(is_sacrifice_target(offering.mind))
			sacrifice_fulfilled = TRUE
			gamemode.cult_objs.succesful_sacrifice()
	else
		GLOB.sacrificed += offering

	new /obj/effect/temp_visual/cult/sac(loc)
	for(var/M in invokers)
		if(sacrifice_fulfilled)
			to_chat(M, "<span class='cultlarge'>\"Yes! This is the one I desire! You have done well.\"</span>")
		else
			if(ishuman(offering) || isrobot(offering))
				to_chat(M, "<span class='cultlarge'>\"I accept this sacrifice.\"</span>")
			else
				to_chat(M, "<span class='cultlarge'>\"I accept this meager sacrifice.\"</span>")

	playsound(offering, 'sound/misc/demon_consume.ogg', 100, 1)
	if((ishuman(offering) || isrobot(offering)) && offering.client_mobs_in_contents?.len)
		var/obj/item/soulstone/stone = new /obj/item/soulstone(get_turf(src))
		stone.invisibility = INVISIBILITY_MAXIMUM //so it's not picked up during transfer_soul()
		stone.transfer_soul("FORCE", offering, user) //If it cannot be added
		stone.invisibility = 0
	else
		if(isrobot(offering))
			playsound(offering, 'sound/magic/disable_tech.ogg', 100, TRUE)
			offering.dust() //To prevent the MMI from remaining
		else
			playsound(offering, 'sound/magic/disintegrate.ogg', 100, TRUE)
			offering.gib()
	return TRUE

var/list/teleport_runes = list()

/obj/effect/rune/teleport
	cultist_name = "Teleport"
	cultist_desc = "warps everything above it to another chosen teleport rune."
	invocation = "Sas'so c'arta forbici!"
	icon_state = "2"
	color = RUNE_COLOR_TELEPORT
	req_keyword = TRUE
	light_power = 4
	var/obj/effect/temp_visual/cult/portal/inner_portal //The portal "hint" for off-station teleportations
	var/obj/effect/temp_visual/cult/rune_spawn/rune2/outer_portal
	var/listkey

/obj/effect/rune/teleport/New(loc, set_keyword)
	..()
	var/area/A = get_area(src)
	var/locname = initial(A.name)
	listkey = set_keyword ? "[set_keyword] [locname]":"[locname]"
	teleport_runes += src

/obj/effect/rune/teleport/Destroy()
	teleport_runes -= src
	return ..()

/obj/effect/rune/teleport/invoke(var/list/invokers)
	var/mob/living/user = invokers[1] //the first invoker is always the user
	var/list/potential_runes = list()
	var/list/teleportnames = list()
	var/list/duplicaterunecount = list()
	for(var/R in teleport_runes)
		var/obj/effect/rune/teleport/T = R
		var/resultkey = T.listkey
		if(resultkey in teleportnames)
			duplicaterunecount[resultkey]++
			resultkey = "[resultkey] ([duplicaterunecount[resultkey]])"
		else
			teleportnames.Add(resultkey)
			duplicaterunecount[resultkey] = 1
		if(T != src && is_level_reachable(T.z))
			potential_runes[resultkey] = T

	if(!potential_runes.len)
		to_chat(user, "<span class='warning'>There are no valid runes to teleport to!</span>")
		log_game("Teleport rune failed - no other teleport runes")
		fail_invoke()
		return

	if(!is_level_reachable(user.z))
		to_chat(user, "<span class='cultitalic'>You are not in the right dimension!</span>")
		log_game("Teleport rune failed - user in away mission")
		fail_invoke()
		return

	var/input_rune_key = input(user, "Choose a rune to teleport to.", "Rune to Teleport to") as null|anything in potential_runes //we know what key they picked
	var/obj/effect/rune/teleport/actual_selected_rune = potential_runes[input_rune_key] //what rune does that key correspond to?
	if(!Adjacent(user) || !src || QDELETED(src) || user.incapacitated() || !actual_selected_rune)
		fail_invoke()
		return

	var/turf/T = get_turf(src)
	var/turf/target = get_turf(actual_selected_rune)
	var/movedsomething = FALSE
	var/moveuserlater = FALSE
	for(var/atom/movable/A in T)
		if(ishuman(A))
			new /obj/effect/temp_visual/dir_setting/cult/phase/out(T, A.dir)
			new /obj/effect/temp_visual/dir_setting/cult/phase(target, A.dir)
		if(A.move_resist == INFINITY)
			continue  //object cant move, shouldnt teleport
		if(A == user)
			moveuserlater = TRUE
			movedsomething = TRUE
			continue
		if(!A.anchored)
			movedsomething = TRUE
			A.forceMove(target)
	if(movedsomething)
		..()
		if(is_mining_level(z) && !is_mining_level(target.z)) //No effect if you stay on lavaland
			actual_selected_rune.handle_portal("lava")
		else if(!is_station_level(z) || istype(get_area(src), /area/space))
			actual_selected_rune.handle_portal("space", T)
		visible_message("<span class='warning'>There is a sharp crack of inrushing air, and everything above the rune disappears!</span>")
		to_chat(user, "<span class='cult'>You[moveuserlater ? "r vision blurs, and you suddenly appear somewhere else":" send everything above the rune away"].</span>")
		if(moveuserlater)
			user.forceMove(target)
	else
		fail_invoke()

/obj/effect/rune/teleport/proc/handle_portal(portal_type, turf/origin)
	var/turf/T = get_turf(src)
	close_portal() // To avoid stacking descriptions/animations
	playsound(T, pick('sound/effects/sparks1.ogg', 'sound/effects/sparks2.ogg', 'sound/effects/sparks3.ogg', 'sound/effects/sparks4.ogg'), 100, TRUE, 14)
	inner_portal = new /obj/effect/temp_visual/cult/portal(T)
	if(portal_type == "space")
		light_color = color
		var/area/A = get_area(origin)
		var/locname = initial(A.name)
		desc += "<br><b>A tear in reality reveals a black void interspersed with dots of light... something recently teleported here from space.<br>"
		if(is_station_level(origin.z))
			desc += "<u>The void feels like it's trying to pull you to the [dir2text(get_dir(T, origin))], near the station!</u></b>"
		else if(locname == "Space")
			desc += "<u>The void feels like it's trying to pull you to the [dir2text(get_dir(T, origin))], in the direction of space sector [origin.z]!</u></b>"
		else
			desc += "<u>The void feels like it's trying to pull you to the [dir2text(get_dir(T, origin))], in the direction of [locname]!</u></b>"
	else
		inner_portal.icon_state = "lava"
		light_color = LIGHT_COLOR_FIRE
		desc += "<br><b>A tear in reality reveals a coursing river of lava... something recently teleported here from the Lavaland Mines!</b>"
	outer_portal = new(T, 600, color)
	light_range = 4
	update_light()
	addtimer(CALLBACK(src, .proc/close_portal), 600, TIMER_UNIQUE)

/obj/effect/rune/teleport/proc/close_portal()
	qdel(inner_portal)
	qdel(outer_portal)
	desc = initial(desc)
	light_range = 0
	update_light()


//Rite of Offering: Converts a normal crewmember to the cult or sacrifices mindshielded and sacrifice targets.
/obj/effect/rune/empower
	cultist_name = "Empower"
	cultist_desc = "allows cultists to prepare greater amounts of blood magic at far less of a cost."
	invocation = "H'drak v'loso, mir'kanas verbot!"
	icon_state = "3"
	color = RUNE_COLOR_TALISMAN
	construct_invoke = FALSE

/obj/effect/rune/empower/invoke(var/list/invokers)
	. = ..()
	var/mob/living/user = invokers[1] //the first invoker is always the user
	for(var/datum/action/innate/cult/blood_magic/BM in user.actions)
		BM.Activate()

//Rite of Resurrection: Requires a dead or inactive cultist. When reviving the dead, you can only perform one revival for every three sacrifices your cult has carried out.
/obj/effect/rune/raise_dead
	cultist_name = "Revive"
	cultist_desc = "requires a dead, mindless, or inactive cultist placed upon the rune. For each three bodies sacrificed to the dark patron, one body will be mended and their mind awoken"
	invocation = "Pasnar val'keriam usinar. Savrae ines amutan. Yam'toth remium il'tarat!" //Depends on the name of the user - see below
	icon_state = "1"
	color = RUNE_COLOR_MEDIUMRED
	var/static/sacrifices_used = -SOULS_TO_REVIVE // Cultists get one "free" revive

/obj/effect/rune/raise_dead/examine(mob/user)
	. = ..()
	if(iscultist(user) || user.stat == DEAD)
		. += "<b>Sacrifices unrewarded:</b> [LAZYLEN(GLOB.sacrificed) - sacrifices_used]"

/obj/effect/rune/raise_dead/invoke(var/list/invokers)
	var/turf/T = get_turf(src)
	var/mob/living/mob_to_revive
	var/list/potential_revive_mobs = list()
	var/mob/living/user = invokers[1]
	if(rune_in_use)
		return
	rune_in_use = TRUE
	for(var/mob/living/M in T.contents)
		if(iscultist(M) && (M.stat == DEAD || !M.client || M.client.is_afk()))
			potential_revive_mobs |= M
	if(!potential_revive_mobs.len)
		to_chat(user, "<span class='cultitalic'>There are no dead cultists on the rune!</span>")
		log_game("Raise Dead rune failed - no cultists to revive")
		fail_invoke()
		return
	if(potential_revive_mobs.len > 1)
		mob_to_revive = input(user, "Choose a cultist to revive.", "Cultist to Revive") as null|anything in potential_revive_mobs
	else
		mob_to_revive = potential_revive_mobs[1]
	if(QDELETED(src) || !validness_checks(mob_to_revive, user))
		fail_invoke()
		return
	..()
	if(mob_to_revive.stat == DEAD)
		var/diff = LAZYLEN(GLOB.sacrificed) - SOULS_TO_REVIVE - sacrifices_used
		if(diff < 0)
			to_chat(user, "<span class='warning'>Your cult must carry out [abs(diff)] more sacrifice\s before it can revive another cultist!</span>")
			fail_invoke()
			return
		sacrifices_used += SOULS_TO_REVIVE
		mob_to_revive.revive()
		mob_to_revive.grab_ghost()
	if(!mob_to_revive.client || mob_to_revive.client.is_afk())
		set waitfor = FALSE
		var/list/mob/dead/observer/candidates = pollCandidates("Do you want to play as [mob_to_revive.name], an inactive blood cultist?", ROLE_CULTIST, TRUE)
		if(LAZYLEN(candidates))
			var/mob/dead/observer/C = pick(candidates)
			to_chat(mob_to_revive.mind, "Your physical form has been taken over by another soul due to your inactivity! Ahelp if you wish to regain your form.")
			message_admins("[key_name_admin(C)] has taken control of ([key_name_admin(mob_to_revive)]) to replace an AFK player.")
			mob_to_revive.ghostize(0)
			mob_to_revive.key = C.key
		else
			fail_invoke()
			return
	SEND_SOUND(mob_to_revive, 'sound/ambience/antag/bloodcult.ogg')
	to_chat(mob_to_revive, "<span class='cultlarge'>\"PASNAR SAVRAE YAM'TOTH. Arise.\"</span>")
	mob_to_revive.visible_message("<span class='warning'>[mob_to_revive] draws in a huge breath, red light shining from [mob_to_revive.p_their()] eyes.</span>", \
								  "<span class='cultlarge'>You awaken suddenly from the void. You're alive!</span>")
	rune_in_use = FALSE

/obj/effect/rune/raise_dead/proc/validness_checks(mob/living/target_mob, mob/living/user)
	var/turf/T = get_turf(src)
	if(QDELETED(user))
		return FALSE
	if(!Adjacent(user) || user.incapacitated())
		return FALSE
	if(QDELETED(target_mob))
		return FALSE
	if(target_mob.loc != T)
		to_chat(user, "<span class='cultitalic'>The cultist to revive has been moved!</span>")
		log_game("Raise Dead rune failed - revival target moved")
		return FALSE
	return TRUE

/obj/effect/rune/raise_dead/fail_invoke()
	..()
	rune_in_use = FALSE
	for(var/mob/living/M in range(1,src))
		if(iscultist(M) && M.stat == DEAD)
			M.visible_message("<span class='warning'>[M] twitches.</span>")

//Rite of the Corporeal Shield: When invoked, becomes solid and cannot be passed. Invoke again to undo.
/obj/effect/rune/wall
	cultist_name = "Barrier"
	cultist_desc = "when invoked, makes a temporary invisible wall to block passage. Will chain-invoke nearby unactive barrier runes. Can be invoked again to reverse this."
	invocation = "Khari'd! Eske'te tannin!"
	icon_state = "4"
	color = RUNE_COLOR_DARKRED
	var/datum/timedevent/density_timer
	var/recharging = FALSE

/obj/effect/rune/wall/Initialize(mapload)
	. = ..()
	GLOB.wall_runes += src

/obj/effect/forcefield/CanAtmosPass(turf/T)
	return !density

/obj/effect/rune/wall/examine(mob/user)
	. = ..()
	if(density && iscultist(user))
		if(density_timer)
			. += "<span class='cultitalic'>The air above this rune has hardened into a barrier that will last [DisplayTimeText(density_timer.timeToRun - world.time)].</span>"

/obj/effect/rune/wall/Destroy()
	GLOB.wall_runes -= src
	return ..()

/obj/effect/rune/wall/invoke(var/list/invokers)
	if(recharging)
		return
	var/mob/living/user = invokers[1]
	..()
	density = !density
	update_state()
	if(density)
		spread_density()
	var/carbon_user = iscarbon(user)
	user.visible_message("<span class='warning'>[user] [carbon_user ? "places [user.p_their()] hands on":"stares intently at"] [src], and [density ? "the air above it begins to shimmer" : "the shimmer above it fades"].</span>", \
						 "<span class='cultitalic'>You channel [carbon_user ? "your life ":""]energy into [src], [density ? "temporarily preventing" : "allowing"] passage above it.</span>")
	if(carbon_user)
		var/mob/living/carbon/C = user
		C.apply_damage(2, BRUTE, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))

/obj/effect/rune/wall/proc/spread_density()
	for(var/R in GLOB.wall_runes)
		var/obj/effect/rune/wall/W = R
		if(W.z == z && get_dist(src, W) <= 2 && !W.density && !W.recharging)
			W.density = TRUE
			W.update_state()
			W.spread_density()
	density_timer = addtimer(CALLBACK(src, .proc/lose_density), 3000, TIMER_STOPPABLE)

/obj/effect/rune/wall/proc/lose_density()
	if(density)
		recharging = TRUE
		density = FALSE
		update_state()
		var/oldcolor = color
		add_atom_colour("#696969", FIXED_COLOUR_PRIORITY)
		animate(src, color = oldcolor, time = 50, easing = EASE_IN)
		addtimer(CALLBACK(src, .proc/recharge), 50)

/obj/effect/rune/wall/proc/recharge()
	recharging = FALSE
	add_atom_colour(RUNE_COLOR_MEDIUMRED, FIXED_COLOUR_PRIORITY)

/obj/effect/rune/wall/proc/update_state()
	deltimer(density_timer)
	air_update_turf(1)
	if(density)
		var/mutable_appearance/shimmer = mutable_appearance('icons/effects/effects.dmi', "barriershimmer", ABOVE_MOB_LAYER)
		shimmer.appearance_flags |= RESET_COLOR
		shimmer.alpha = 60
		shimmer.color = "#701414"
		add_overlay(shimmer)
		add_atom_colour(RUNE_COLOR_RED, FIXED_COLOUR_PRIORITY)
	else
		cut_overlays()
		add_atom_colour(RUNE_COLOR_MEDIUMRED, FIXED_COLOUR_PRIORITY)

//Rite of Joined Souls: Summons a single cultist.
/obj/effect/rune/summon
	cultist_name = "Summon Cultist"
	cultist_desc = "summons a single cultist to the rune. Requires 2 invokers."
	invocation = "N'ath reth sh'yro eth d'rekkathnor!"
	req_cultists = 2
	invoke_damage = 10
	icon_state = "3"
	color = RUNE_COLOR_SUMMON

/obj/effect/rune/summon/invoke(var/list/invokers)
	var/mob/living/user = invokers[1]
	var/list/cultists = list()

	for(var/datum/mind/M in SSticker.mode.cult)
		if(!(M.current in invokers) && M.current && M.current.stat != DEAD)
			cultists[M.current.real_name] = M.current
	var/input = input(user, "Who do you wish to call to [src]?", "Acolytes") as null|anything in cultists
	var/mob/living/cultist_to_summon = cultists[input]
	if(!Adjacent(user) || !src || QDELETED(src) || user.incapacitated())
		return
	if(!cultist_to_summon)
		to_chat(user, "<span class='cultitalic'>You require a summoning target!</span>")
		fail_invoke()
		log_game("Summon Cultist rune failed - no target")
		return
	if(cultist_to_summon.stat == DEAD)
		to_chat(user, "<span class='cultitalic'>[cultist_to_summon] has died!</span>")
		fail_invoke()
		log_game("Summon Cultist rune failed - target died")
		return
	if(cultist_to_summon.pulledby || cultist_to_summon.buckled)
		to_chat(user, "<span class='cultitalic'>[cultist_to_summon] is being held in place!</span>")
		fail_invoke()
		log_game("Summon Cultist rune failed - target restrained")
		return
	if(!iscultist(cultist_to_summon))
		to_chat(user, "<span class='cultitalic'>[cultist_to_summon] is not a follower of the [SSticker.cultdat.entity_title3]!</span>")
		fail_invoke()
		log_game("Summon Cultist rune failed - target was deconverted")
		return
	if(is_away_level(cultist_to_summon.z))
		to_chat(user, "<span class='cultitalic'>[cultist_to_summon] is not in our dimension!</span>")
		fail_invoke()
		log_game("Summon Cultist rune failed - target in away mission")
		return
	cultist_to_summon.visible_message("<span class='warning'>[cultist_to_summon] suddenly disappears in a flash of red light!</span>", \
									  "<span class='cultitalic'><b>Overwhelming vertigo consumes you as you are hurled through the air!</b></span>")
	..()
	visible_message("<span class='warning'>A foggy shape materializes atop [src] and solidifes into [cultist_to_summon]!</span>")
	cultist_to_summon.forceMove(get_turf(src))
	qdel(src)

//Rite of Boiling Blood: Deals extremely high amounts of damage to non-cultists nearby
/obj/effect/rune/blood_boil
	cultist_name = "Boil Blood"
	cultist_desc = "boils the blood of non-believers who can see the rune, rapidly dealing extreme amounts of damage. Requires 3 invokers."
	invocation = "Dedo ol'btoh!"
	icon_state = "4"
	color = RUNE_COLOR_BURNTORANGE
	light_color = LIGHT_COLOR_LAVA
	req_cultists = 3
	invoke_damage = 10
	construct_invoke = FALSE
	var/tick_damage = 30 //90 burn damage total + damage taken by being on fire/overheating
	rune_in_use = FALSE

/obj/effect/rune/blood_boil/do_invoke_glow()
	return

/obj/effect/rune/blood_boil/invoke(var/list/invokers)
	if(rune_in_use)
		return
	..()
	rune_in_use = TRUE
	var/turf/T = get_turf(src)
	visible_message("<span class='warning'>[src] turns a bright, glowing orange!</span>")
	color = "#FC9B54"
	set_light(6, 1, color)
	for(var/mob/living/L in viewers(T))
		if(!iscultist(L) && L.blood_volume && !ismachine(L))
			var/atom/I = L.null_rod_check()
			if(I)
				if(isitem(I))
					to_chat(L, "<span class='userdanger'>[I] suddenly burns hotly before returning to normal!</span>")
				continue
			to_chat(L, "<span class='cultlarge'>Your blood boils in your veins!</span>")
	animate(src, color = "#FCB56D", time = 4)
	sleep(4)
	if(QDELETED(src))
		return
	do_area_burn(T, 0.5)
	animate(src, color = "#FFDF80", time = 5)
	sleep(5)
	if(QDELETED(src))
		return
	do_area_burn(T, 1)
	animate(src, color = "#FFFDF4", time = 6)
	sleep(6)
	if(QDELETED(src))
		return
	do_area_burn(T, 1.5)
	qdel(src)

/obj/effect/rune/blood_boil/proc/do_area_burn(turf/T, multiplier)
	set_light(6, 1, color)
	for(var/mob/living/L in viewers(T))
		if(!iscultist(L) && L.blood_volume && !ismachine(L))
			if(L.null_rod_check())
				continue
			L.take_overall_damage(0, tick_damage * multiplier)
			L.adjust_fire_stacks(1)
			L.IgniteMob()

/obj/effect/rune/manifest
	cultist_name = "Spirit Realm"
	cultist_desc = "manifests a spirit servant of the [SSticker.cultdat.entity_title3] and allows you to ascend as a spirit yourself. The invoker must not move from atop the rune, and will take damage for each summoned spirit."
	invocation = "Gal'h'rfikk harfrandid mud'gib!" //how the fuck do you pronounce this
	icon_state = "7"
	construct_invoke = FALSE
	color = RUNE_COLOR_DARKRED
	var/mob/living/affecting = null //The living mob of the user
	var/mob/dead/observer/G = null //The cult ghost of the user
	var/ghost_limit = 3
	var/ghosts = 0

/obj/effect/rune/manifest/can_invoke(mob/living/user)
	if(!(user in get_turf(src)))
		to_chat(user, "<span class='cultitalic'>You must be standing on [src]!</span>")
		fail_invoke()
		log_game("Manifest rune failed - user not standing on rune")
		return list()
	if(user.has_status_effect(STATUS_EFFECT_SUMMONEDGHOST))
		to_chat(user, "<span class='cultitalic'>Ghosts can't summon more ghosts!</span>")
		fail_invoke()
		log_game("Manifest rune failed - user is a ghost")
		return list()
	return ..()

/obj/effect/rune/manifest/invoke(var/list/invokers)
	. = ..()
	var/mob/living/user = invokers[1]
	var/turf/T = get_turf(src)
	var/choice = alert(user,"You tear open a connection to the spirit realm...",,"Summon a Cult Ghost","Ascend as a Dark Spirit","Cancel")
	if(choice == "Summon a Cult Ghost")
		if(!is_station_level(src.z) || istype(get_area(src), /area/space))
			to_chat(user, "<span class='cultitalic'><b>The veil is not weak enough here to manifest spirits, you must be on station!</b></span>")
			fail_invoke()
			log_game("Manifest rune failed - not on station")
			return
		if(user.health <= 40)
			to_chat(user, "<span class='cultitalic'>Your body is too weak to manifest spirits, heal yourself first.</span>")
			fail_invoke()
			log_game("Manifest rune failed - not enough health")
			return list()
		notify_ghosts("Manifest rune created in [get_area(src)].", ghost_sound='sound/effects/ghost2.ogg', source = src)
		if(ghosts >= ghost_limit)
			to_chat(user, "<span class='cultitalic'>You are sustaining too many ghosts to summon more!</span>")
			fail_invoke()
			log_game("Manifest rune failed - too many summoned ghosts")
			return list()
		notify_ghosts("Manifest rune created in [get_area(src)].", ghost_sound='sound/effects/ghost2.ogg', source = src)
		var/list/ghosts_on_rune = list()
		for(var/mob/dead/observer/O in T)
			if(O.client && !(jobban_isbanned(O, ROLE_CULTIST) || jobban_isbanned(O, ROLE_SYNDICATE)) && !QDELETED(src) && !QDELETED(O))
				ghosts_on_rune += O
		if(!ghosts_on_rune.len)
			to_chat(user, "<span class='cultitalic'>There are no spirits near [src]!</span>")
			fail_invoke()
			log_game("Manifest rune failed - no nearby ghosts")
			return list()
		var/mob/dead/observer/ghost_to_spawn = pick(ghosts_on_rune)
		var/mob/living/carbon/human/new_human = new(T)
		new_human.real_name = ghost_to_spawn.real_name
		new_human.alpha = 150 //Makes them translucent
		new_human.equipOutfit(/datum/outfit/ghost_cultist) //give them armor
		new_human.apply_status_effect(STATUS_EFFECT_SUMMONEDGHOST) //ghosts can't summon more ghosts
		new_human.see_invisible = SEE_INVISIBLE_OBSERVER
		ghosts++
		playsound(src, 'sound/misc/exit_blood.ogg', 50, TRUE)
		visible_message("<span class='warning'>A cloud of red mist forms above [src], and from within steps... a [new_human.gender == FEMALE ? "wo":""]man.</span>")
		to_chat(user, "<span class='cultitalic'>Your blood begins flowing into [src]. You must remain in place and conscious to maintain the forms of those summoned. This will hurt you slowly but surely...</span>")
		var/obj/machinery/shield/N = new(get_turf(src))
		N.name = "Invoker's Shield"
		N.desc = "A weak shield summoned by cultists to protect them while they carry out delicate rituals"
		N.color = "red"
		N.health = 20
		N.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		new_human.key = ghost_to_spawn.key
		SSticker.mode.add_cultist(new_human.mind, 0)
		to_chat(new_human, "<span class='cultitalic'><b>You are a servant of the [SSticker.cultdat.entity_title3]. You have been made semi-corporeal by the cult of [SSticker.cultdat.entity_name], and you are to serve them at all costs.</b></span>")
		while(!QDELETED(src) && !QDELETED(user) && !QDELETED(new_human) && (user in T))
			if(new_human.InCritical())
				to_chat(user, "<span class='cultitalic'>You feel your connection to [new_human] severs as they are destroyed.</span>")
				if(G)
					to_chat(G, "<span class='cultitalic'>You feel your connection to [new_human] severs as they are destroyed.</span>")
				break
			if(user.stat || affecting.health <= 40)
				to_chat(user, "<span class='cultitalic'>Your body can no longer sustain the connection, and your link to the spirit realm fades.</span>")
				if(G)
					to_chat(G, "<span class='cultitalic'>Your body is damaged and your connection to the spirit realm weakens, any ghost you may have manifested are destroyed.</span>")
				break
			user.apply_damage(0.1, BRUTE)
			sleep(1)
		qdel(N)
		ghosts--
		if(new_human)
			new_human.visible_message("<span class='warning'>[new_human] suddenly dissolves into bones and ashes.</span>", \
									  "<span class='cultlarge'>Your link to the world fades. Your form breaks apart.</span>")
			for(var/obj/I in new_human)
				if(I.flags & NODROP)
					qdel(I)
				else
					I.forceMove(new_human.drop_location())
			new_human.dust()
	else if(choice == "Ascend as a Dark Spirit")
		affecting = user
		affecting.add_atom_colour(RUNE_COLOR_DARKRED, ADMIN_COLOUR_PRIORITY)
		affecting.visible_message("<span class='warning'>[affecting] freezes statue-still, glowing an unearthly red.</span>", \
						 "<span class='cult'>You see what lies beyond. All is revealed. In this form you find that your voice booms louder and you can mark targets for the entire cult</span>")
		G = affecting.ghostize(TRUE)
		var/datum/action/innate/cult/comm/spirit/CM = new
		//var/datum/action/innate/cult/ghostmark/GM = new
		G.name = "Dark Spirit of [G.name]"
		G.color = "red"
		CM.Grant(G)
		//GM.Grant(G)
		while(!QDELETED(affecting))
			if(!(affecting in T))
				user.visible_message("<span class='warning'>A spectral tendril wraps around [affecting] and pulls [affecting.p_them()] back to the rune!</span>")
				Beam(affecting, icon_state="drainbeam", time=2)
				affecting.forceMove(get_turf(src)) //NO ESCAPE :^)
			if(affecting.key)
				affecting.visible_message("<span class='warning'>[affecting] slowly relaxes, the glow around [affecting.p_them()] dimming.</span>", \
									 "<span class='danger'>You are re-united with your physical form. [src] releases its hold over you.</span>")
				affecting.Weaken(3)
				break
			if(affecting.health <= 10)
				to_chat(G, "<span class='cultitalic'>Your body can no longer sustain the connection!</span>")
				break
			sleep(5)
		CM.Remove(G)
		//GM.Remove(G)
		affecting.remove_atom_colour(ADMIN_COLOUR_PRIORITY, RUNE_COLOR_DARKRED)
		affecting.grab_ghost()
		affecting = null
		rune_in_use = FALSE

//Ritual of Dimensional Rending: Calls forth the avatar of Nar-Sie upon the station.
/obj/effect/rune/narsie
	cultist_name = "Tear Veil"
	cultist_desc = "tears apart dimensional barriers, calling forth your god. Requires 9 invokers."
	invocation = "TOK-LYR RQA-NAP G'OLT-ULOFT!!"
	req_cultists = 9
	icon = 'icons/effects/96x96.dmi'
	color = RUNE_COLOR_DARKRED
	icon_state = "rune_large"
	pixel_x = -32 //So the big ol' 96x96 sprite shows up right
	pixel_y = -32
	mouse_opacity = MOUSE_OPACITY_ICON //we're huge and easy to click
	scribe_delay = 450 //how long the rune takes to create
	scribe_damage = 40.1 //how much damage you take doing it
	var/used

/obj/effect/rune/narsie/New()
	..()
	cultist_name = "Summon [SSticker.cultdat ? SSticker.cultdat.entity_name : "your god"]"
	cultist_desc = "tears apart dimensional barriers, calling forth [SSticker.cultdat ? SSticker.cultdat.entity_title3 : "your god"]. Requires 9 invokers."

/obj/effect/rune/narsie/check_icon()
	return

/obj/effect/rune/narsie/cult_conceal() //can't hide this, and you wouldn't want to
	return

/obj/effect/rune/narsie/invoke(var/list/invokers)
	if(used)
		return
	var/mob/living/user = invokers[1]
	var/datum/game_mode/gamemode = SSticker.mode
	if(!is_station_level(user.z))
		message_admins("[key_name_admin(user)] tried to summon an eldritch horror off station")
		log_game("Summon Nar-Sie rune failed - off station Z level")
		return
	if(gamemode.cult_objs.status == NARSIE_HAS_RISEN)
		for(var/M in invokers)
			to_chat(M, "<span class='warning'>[SSticker.cultdat.entity_name] is already on this plane!</span>")
		log_game("Summon god rune failed - already summoned")
		return
	//BEGIN THE SUMMONING
	gamemode.cult_objs.succesful_summon()
	used = 1
	color = rgb(255, 0, 0)
	..()
	world << 'sound/effects/dimensional_rend.ogg'
	to_chat(world, "<span class='cultitalic'><b>The veil... <span class='big'>is...</span> <span class='reallybig'>TORN!!!--</span></b></span>")
	icon_state = "rune_large_distorted"
	var/turf/T = get_turf(src)
	sleep(40)
	new /obj/singularity/narsie/large(T) //Causes Nar-Sie to spawn even if the rune has been removed

/obj/effect/rune/narsie/attackby(obj/I, mob/user, params)	//Since the narsie rune takes a long time to make, add logging to removal.
	if((istype(I, /obj/item/melee/cultblade/dagger) && iscultist(user)))
		log_game("Summon Narsie rune erased by [key_name(user)] with a cult dagger")
		message_admins("[key_name_admin(user)] erased a Narsie rune with a cult dagger")
	if(istype(I, /obj/item/nullrod))	//Begone foul magiks. You cannot hinder me.
		log_game("Summon Narsie rune erased by [key_name(user)] using a null rod")
		message_admins("[key_name_admin(user)] erased a Narsie rune with a null rod")
	return ..()