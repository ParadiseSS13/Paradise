var/list/sacrificed = list()
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
	anchored = 1
	icon = 'icons/obj/rune.dmi'
	icon_state = "1"
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/visibility = 0
	var/view_range = 7
	layer = TURF_LAYER

	var/invocation = "Aiy ele-mayo!" //This is said by cultists when the rune is invoked.
	var/req_cultists = 1 //The amount of cultists required around the rune to invoke it. If only 1, any cultist can invoke it.
	var/rune_in_use = 0 // Used for some runes, this is for when you want a rune to not be usable when in use.

	var/scribe_delay = 50 //how long the rune takes to create
	var/scribe_damage = 0.1 //how much damage you take doing it

	var/allow_excess_invokers = 0 //if we allow excess invokers when being invoked
	var/construct_invoke = 1 //if constructs can invoke it

	var/req_keyword = 0 //If the rune requires a keyword - go figure amirite
	var/keyword //The actual keyword for the rune

	var/invoke_damage = 0 //how much damage invokers take when invoking it


/obj/effect/rune/New(loc, set_keyword)
	..()
	if(set_keyword)
		keyword = set_keyword
	check_icon()
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
	if(istype(I, /obj/item/tome) && iscultist(user))
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

/obj/effect/rune/proc/talismanhide() //for talisman of revealing/hiding
	visible_message("<span class='danger'>[src] fades away.</span>")
	invisibility = INVISIBILITY_OBSERVER
	alpha = 100 //To help ghosts distinguish hidden runes

/obj/effect/rune/proc/talismanreveal() //for talisman of revealing/hiding
	invisibility = 0
	visible_message("<span class='danger'>[src] suddenly appears!</span>")
	alpha = initial(alpha)

/obj/effect/rune/proc/talismanfake() //for rune disguising
	var/runenum = pick(1,2,3,4,5,6)
	visible_message("<span class='danger'>[src] takes on a waxy apperance!</span>")
	icon = 'icons/effects/crayondecal.dmi'
	icon_state = "rune[runenum]"
	color = rgb(255, 0, 0)

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
		if(invocation)
			if(!L.IsVocal())
				L.emote("gestures ominously.")
			else
				L.say(invocation)
			L.changeNext_move(CLICK_CD_MELEE)//THIS IS WHY WE CAN'T HAVE NICE THINGS
		if(invoke_damage)
			L.apply_damage(invoke_damage, BRUTE)
			to_chat(L, "<span class='cultitalic'>[src] saps your strength!</span>")
	do_invoke_glow()

/obj/effect/rune/proc/burn_invokers(var/list/mobstoburn)
	for(var/M in mobstoburn)
		var/mob/living/L = M
		to_chat(L, "<span class='cultlarge'><i>\"YOUR SOUL BURNS WITH YOUR ARROGANCE!!!\"</i></span>")
		if(L.reagents)
			L.reagents.add_reagent("hell_water", 10)
		L.Weaken(7)
		L.Stun(7)
	fail_invoke()

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

//Rite of Binding: A paper on top of the rune to a talisman.
/obj/effect/rune/imbue
	cultist_name = "Rite of Binding"
	cultist_desc = "transforms paper into powerful magic talismans."
	invocation = "H'drak v'loso, mir'kanas verbot!"
	icon_state = "3"

/obj/effect/rune/imbue/invoke(var/list/invokers)
	var/mob/living/user = invokers[1] //the first invoker is always the user
	var/turf/T = get_turf(src)
	var/list/papers_on_rune = list()
	var/entered_talisman_name
	var/obj/item/paper/talisman/talisman_type
	var/list/possible_talismans = list()
	for(var/obj/item/paper/P in T)
		if(!P.info)
			papers_on_rune.Add(P)
	if(!papers_on_rune.len)
		to_chat(user, "<span class='cultitalic'>There must be a blank paper on top of [src]!</span>")
		fail_invoke()
		log_game("Talisman Creation rune failed - no blank papers on rune")
		return
	if(rune_in_use)
		to_chat(user, "<span class='cultitalic'>[src] can only support one ritual at a time!</span>")
		fail_invoke()
		log_game("Talisman Creation rune failed - already in use")
		return
	var/obj/item/paper/paper_to_imbue = pick(papers_on_rune)
	for(var/I in subtypesof(/obj/item/paper/talisman) - /obj/item/paper/talisman/malformed - /obj/item/paper/talisman/supply - /obj/item/paper/talisman/supply/weak)
		var/obj/item/paper/talisman/J = I
		var/talisman_cult_name = initial(J.cultist_name)
		if(talisman_cult_name)
			possible_talismans[talisman_cult_name] = J //This is to allow the menu to let cultists select talismans by name
	entered_talisman_name = input(user, "Choose a talisman to imbue.", "Talisman Choices") as null|anything in possible_talismans
	talisman_type = possible_talismans[entered_talisman_name]
	if(!Adjacent(user) || !src || QDELETED(src) || user.incapacitated() || rune_in_use || !talisman_type)
		return
	..()
	visible_message("<span class='warning'>Dark power begins to channel into the paper!.</span>")
	rune_in_use = 1
	if(!do_after(user, 100, target = get_turf(user)))
		rune_in_use = 0
		return
	new talisman_type(get_turf(src))
	visible_message("<span class='warning'>[src] glows with power, and bloody images form themselves on [paper_to_imbue].</span>")
	qdel(paper_to_imbue)
	rune_in_use = 0

var/list/teleport_runes = list()
/obj/effect/rune/teleport
	cultist_name = "Teleport"
	cultist_desc = "warps everything above it to another chosen teleport rune."
	invocation = "Sas'so c'arta forbici!"
	icon_state = "2"
	req_keyword = 1
	var/listkey
	invoke_damage = 6 //but theres some checks for z-level

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
	var/movedsomething = 0
	var/moveuserlater = 0
	for(var/atom/movable/A in T)
		if(A.move_resist == INFINITY)
			continue  //object cant move, shouldnt teleport
		if(A == user)
			moveuserlater = 1
			movedsomething = 1
			continue
		if(!A.anchored)
			movedsomething = 1
			A.forceMove(get_turf(actual_selected_rune))
	if(movedsomething)
		..()
		visible_message("<span class='warning'>There is a sharp crack of inrushing air, and everything above the rune disappears!</span>")
		to_chat(user, "<span class='cult'>You[moveuserlater ? "r vision blurs, and you suddenly appear somewhere else":" send everything above the rune away"].</span>")
		if(moveuserlater)
			user.forceMove(get_turf(actual_selected_rune))
		var/mob/living/carbon/human/H = user
		if(user.z != T.z)
			H.bleed(5)
			user.apply_damage(5, BRUTE)
		else
			H.bleed(rand(5,10))
	else
		fail_invoke()


//Rite of Offering: Converts a normal crewmember to the cult or sacrifices mindshielded and sacrifice targets.
/obj/effect/rune/convert
	cultist_name = "Rite of Offering"
	cultist_desc = "Offers a non-cultists on top of it to your deity, either converting or sacrificing them."
	invocation = "Mah'weyh pleggh at e'ntrath!"
	icon_state = "3"
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
		if(!iscultist(M))
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
	if(invokers.len < 2)
		fail_invoke()
		for(var/I in invokers)
			to_chat(I, "<span class='warning'>You need at least two invokers to convert!</span>")
		return
	else
		convertee.visible_message("<span class='warning'>[convertee] writhes in pain as the markings below them glow a bloody red!</span>", \
									"<span class='cultlarge'><i>AAAAAAAAAAAAAA-</i></span>")
		SSticker.mode.add_cultist(convertee.mind, 1)
		new /obj/item/tome(get_turf(src))
		convertee.mind.special_role = "Cultist"
		to_chat(convertee, "<span class='cultitalic'><b>Your blood pulses. Your head throbs. The world goes red. All at once you are aware of a horrible, horrible, truth. The veil of reality has been ripped away \
		and something evil takes root.</b></span>")
		to_chat(convertee, "<span class='cultitalic'><b>Assist your new compatriots in their dark dealings. Your goal is theirs, and theirs is yours. You serve [SSticker.cultdat.entity_title3] above all else. Bring it back.\
		</b></span>")
		return

/obj/effect/rune/convert/proc/do_sacrifice(mob/living/offering, list/invokers)
	var/mob/living/user = invokers[1] //the first invoker is always the user
	if(((ishuman(offering) || isrobot(offering)) && offering.stat != DEAD) || is_sacrifice_target(offering.mind)) //Requires three people to sacrifice living targets
		if(invokers.len < 3)
			for(var/M in invokers)
				to_chat(M, "<span class='cultitalic'>[offering] is too greatly linked to the world! You need three acolytes!</span>")
			fail_invoke()
			log_game("Sacrifice rune failed - not enough acolytes and target is living")
			return

	var/sacrifice_fulfilled
	var/datum/game_mode/cult/cult_mode = SSticker.mode
	if(offering.mind)
		sacrificed.Add(offering.mind)
		if(is_sacrifice_target(offering.mind))
			sacrifice_fulfilled = TRUE
	new /obj/effect/temp_visual/cult/sac(loc)
	if(SSticker && SSticker.mode && SSticker.mode.name == "cult")
		cult_mode.harvested++
	for(var/M in invokers)
		if(sacrifice_fulfilled)
			to_chat(M, "<span class='cultlarge'>\"Yes! This is the one I desire! You have done well.\"</span>")
			cult_mode.additional_phase()
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
		offering.dust()

//Ritual of Dimensional Rending: Calls forth the avatar of Nar-Sie upon the station.
/obj/effect/rune/narsie
	cultist_name = "Tear Reality (God)"
	cultist_desc = "tears apart dimensional barriers, calling forth your god. Requires 9 invokers."
	invocation = "TOK-LYR RQA-NAP G'OLT-ULOFT!!"
	req_cultists = 9
	icon = 'icons/effects/96x96.dmi'
	color = rgb(125,23,23)
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

/obj/effect/rune/narsie/talismanhide() //can't hide this, and you wouldn't want to
	return

/obj/effect/rune/narsie/invoke(var/list/invokers)
	if(used)
		return
	var/mob/living/user = invokers[1]
	var/datum/game_mode/cult/cult_mode = SSticker.mode
	if(!(CULT_ELDERGOD in cult_mode.objectives))
		message_admins("[key_name_admin(user)] tried to summonn an eldritch horror when the objective was wrong")
		burn_invokers(invokers)
		log_game("Summon Nar-Sie rune failed - improper objective")
		return
	if(!is_station_level(user.z))
		message_admins("[key_name_admin(user)] tried to summon an eldritch horror off station")
		burn_invokers(invokers)
		log_game("Summon Nar-Sie rune failed - off station Z level")
		return
	if(!cult_mode.eldergod)
		for(var/M in invokers)
			to_chat(M, "<span class='warning'>[SSticker.cultdat.entity_name] is already on this plane!</span>")
		log_game("Summon god rune failed - already summoned")
		return
	//BEGIN THE SUMMONING
	used = 1
	color = rgb(255, 0, 0)
	..()
	world << 'sound/effects/dimensional_rend.ogg'
	to_chat(world, "<span class='cultitalic'><b>The veil... <span class='big'>is...</span> <span class='reallybig'>TORN!!!--</span></b></span>")
	icon_state = "rune_large_distorted"
	var/turf/T = get_turf(src)
	sleep(40)
	new /obj/singularity/narsie/large(T) //Causes Nar-Sie to spawn even if the rune has been removed
	cult_mode.eldergod = 0

/obj/effect/rune/narsie/attackby(obj/I, mob/user, params)	//Since the narsie rune takes a long time to make, add logging to removal.
	if((istype(I, /obj/item/tome) && iscultist(user)))
		user.visible_message("<span class='warning'>[user] begins erasing the [src]...</span>", "<span class='notice'>You begin erasing the [src]...</span>")
		if(do_after(user, 50, target = src))	//Prevents accidental erasures.
			log_game("Summon Narsie rune erased by [key_name(user)] with a tome")
			message_admins("[key_name_admin(user)] erased a Narsie rune with a tome")
		return
	if(istype(I, /obj/item/nullrod))	//Begone foul magiks. You cannot hinder me.
		log_game("Summon Narsie rune erased by [key_name(user)] using a null rod")
		message_admins("[key_name_admin(user)] erased a Narsie rune with a null rod")
		return
	return ..()



/obj/effect/rune/slaughter
	cultist_name = "Call Forth The Slaughter (Demons)"
	cultist_desc = "Calls forth the doom of an eldritch being. Three slaughter demons will appear to wreak havoc on the station."
	invocation = null
	req_cultists = 9
	color = rgb(125,23,23)
	scribe_delay = 450
	scribe_damage = 40.1 //how much damage you take doing it
	icon = 'icons/effects/96x96.dmi'
	icon_state = "rune_large"
	pixel_x = -32
	pixel_y = -32

	var/used = 0

/obj/effect/rune/slaughter/check_icon()
	return

/obj/effect/rune/slaughter/talismanhide() //can't hide this, and you wouldn't want to
	return

/obj/effect/rune/slaughter/attackby(obj/I, mob/user, params)	//Since the narsie rune takes a long time to make, add logging to removal.
	if((istype(I, /obj/item/tome) && iscultist(user)))
		user.visible_message("<span class='warning'>[user.name] begins erasing the [src]...</span>", "<span class='notice'>You begin erasing the [src]...</span>")
		if(do_after(user, 50, target = src))	//Prevents accidental erasures.
			log_game("Summon demon rune erased by [key_name(user)] with a tome")
			message_admins("[key_name_admin(user)] erased a demon rune with a tome")
		return
	if(istype(I, /obj/item/nullrod))	//Begone foul magiks. You cannot hinder me.
		log_game("Summon demon rune erased by [key_name(user)] using a null rod")
		message_admins("[key_name_admin(user)] erased a demon rune with a null rod")
		return
	return ..()


/obj/effect/rune/slaughter/invoke(var/list/invokers)
	if(used)
		return
	var/mob/living/user = invokers[1]
	var/datum/game_mode/cult/cult_mode = SSticker.mode
	if(!(CULT_SLAUGHTER in cult_mode.objectives))
		message_admins("[key_name_admin(user)] tried to summon demons when the objective was wrong")
		burn_invokers(invokers)
		log_game("Summon Demons rune failed - improper objective")
		return
	if(!is_station_level(user.z))
		message_admins("[key_name_admin(user)] tried to summon demons off station")
		burn_invokers(invokers)
		log_game("Summon demons rune failed - off station Z level")
		return
	if(cult_mode.demons_summoned)
		for(var/M in invokers)
			to_chat(M, "<span class='warning'>Demons are already on this plane!</span>")
			log_game("Summon Demons rune failed - already summoned")
			return
	//BEGIN THE SLAUGHTER
	used = 1
	for(var/mob/living/M in range(1,src))
		if(iscultist(M))
			M.say("TOK-LYR RQA-NAP SHA-NEX!!")
	world << 'sound/effects/dimensional_rend.ogg'
	to_chat(world, "<span class='userdanger'>A hellish cacaphony bombards from all around as something awful tears through the world...</span>")
	icon_state = "rune_large_distorted"
	sleep(55)
	to_chat(world, "<span class='cultlarge'><i>\"LIBREATE TE EX INFERIS!\"</i></span>")//Fethas note:I COULDN'T HELP IT OKAY?!
	visible_message("<span class='warning'>[src] melts away into blood, and three horrific figures emerge from within!</span>")
	var/turf/T = get_turf(src)
	new /mob/living/simple_animal/slaughter/cult(T)
	new /mob/living/simple_animal/slaughter/cult(T, pick(NORTH, EAST, SOUTH, WEST))
	new /mob/living/simple_animal/slaughter/cult(T, pick(NORTHEAST, SOUTHEAST, NORTHWEST, SOUTHWEST))
	cult_mode.demons_summoned = 1
	SSshuttle.emergency.request(null, 0.5,null)
	SSshuttle.emergency.canRecall = FALSE
	cult_mode.third_phase()
	qdel(src)


//Rite of Resurrection: Requires two corpses. Revives one and gibs the other.
/obj/effect/rune/raise_dead
	cultist_name = "Rite of Resurrection"
	cultist_desc = "requires two corpses, one on the rune and one adjacent to the rune. The one on the rune is brought to life, the other is turned to ash."
	invocation = null //Depends on the name of the user - see below
	icon_state = "1"

/obj/effect/rune/raise_dead/invoke(var/list/invokers)
	var/turf/T = get_turf(src)
	var/mob/living/mob_to_sacrifice
	var/mob/living/mob_to_revive
	var/list/potential_sacrifice_mobs = list()
	var/list/potential_revive_mobs = list()
	var/mob/living/user = invokers[1]
	if(rune_in_use)
		return
	for(var/mob/living/M in orange(1,src))
		if(M.stat == DEAD  && !iscultist(M))
			potential_sacrifice_mobs.Add(M)
	if(!potential_sacrifice_mobs.len)
		to_chat(user, "<span class='cultitalic'>There are no eligible sacrifices nearby!</span>")
		log_game("Raise Dead rune failed - no catalyst corpse")
		return
	mob_to_sacrifice = input(user, "Choose a corpse to sacrifice.", "Corpse to Sacrifice") as null|anything in potential_sacrifice_mobs
	if(!Adjacent(user) || !src || QDELETED(src) || user.incapacitated() || !mob_to_sacrifice || rune_in_use)
		return
	for(var/mob/living/M in T.contents)
		if(M.stat == DEAD)
			potential_revive_mobs.Add(M)
	if(!potential_revive_mobs.len)
		to_chat(user, "<span class='cultitalic'>There is no eligible revival target on the rune!</span>")
		log_game("Raise Dead rune failed - no corpse to revive")
		return
	mob_to_revive = input(user, "Choose a corpse to revive.", "Corpse to Revive") as null|anything in potential_revive_mobs
	if(!Adjacent(user) || !src || QDELETED(src) || user.incapacitated() || rune_in_use || !mob_to_revive)
		return
	if(!in_range(mob_to_sacrifice,src))
		to_chat(user, "<span class='cultitalic'>The sacrificial target has been moved!</span>")
		fail_invoke()
		log_game("Raise Dead rune failed - catalyst corpse moved")
		return
	if(!(mob_to_revive in T.contents))
		to_chat(user, "<span class='cultitalic'>The corpse to revive has been moved!</span>")
		fail_invoke()
		log_game("Raise Dead rune failed - revival target moved")
		return
	if(mob_to_sacrifice.stat != DEAD)
		to_chat(user, "<span class='cultitalic'>The sacrificial target must be dead!</span>")
		fail_invoke()
		log_game("Raise Dead rune failed - catalyst corpse is not dead")
		return
	rune_in_use = 1
	if(user.name == "Herbert West")
		user.say("To life, to life, I bring them!")
	else
		user.say("Pasnar val'keriam usinar. Savrae ines amutan. Yam'toth remium il'tarat!")
	..()
	mob_to_sacrifice.visible_message("<span class='warning'><b>[mob_to_sacrifice]'s body rises into the air, connected to [mob_to_revive] by a glowing tendril!</span>")
	mob_to_revive.Beam(mob_to_sacrifice,icon_state="sendbeam",time=20)
	sleep(20)
	if(!mob_to_sacrifice || !in_range(mob_to_sacrifice, src))
		mob_to_sacrifice.visible_message("<span class='warning'><b>[mob_to_sacrifice] disintegrates into a pile of bones</span>")
		return
	mob_to_sacrifice.dust()
	if(!mob_to_revive || mob_to_revive.stat != DEAD)
		visible_message("<span class='warning'>The glowing tendril snaps against the rune with a shocking crack.</span>")
		rune_in_use = 0
		return
	mob_to_revive.revive() //This does remove disabilities and such, but the rune might actually see some use because of it!
	to_chat(mob_to_revive, "<span class='cultlarge'>\"PASNAR SAVRAE YAM'TOTH. Arise.\"</span>")
	mob_to_revive.visible_message("<span class='warning'>[mob_to_revive] draws in a huge breath, red light shining from [mob_to_revive.p_their()] eyes.</span>", \
								  "<span class='cultlarge'>You awaken suddenly from the void. You're alive!</span>")
	rune_in_use = 0


/obj/effect/rune/raise_dead/fail_invoke()
	..()
	rune_in_use = FALSE
	for(var/mob/living/M in range(1,src))
		if(M.stat == DEAD)
			M.visible_message("<span class='warning'>[M] twitches.</span>")


//Rite of Disruption: Emits an EMP blast.
/obj/effect/rune/emp
	cultist_name = "Rite of Disruption"
	cultist_desc = "emits a large electromagnetic pulse, increasing in size for each cultist invoking it, hindering electronics and disabling silicons."
	invocation = "Ta'gh fara'qha fel d'amar det!"
	icon_state = "5"
	allow_excess_invokers = 1

/obj/effect/rune/emp/invoke(var/list/invokers)
	var/turf/E = get_turf(src)
	..()
	visible_message("<span class='warning'>[src] glows blue for a moment before vanishing.</span>")
	switch(invokers.len)
		if(1 to 2)
			playsound(E, 'sound/items/welder2.ogg', 25, 1)
			for(var/M in invokers)
				to_chat(M, "<span class='warning'>You feel a minute vibration pass through you...</span>")
		if(3 to 6)
			playsound(E, 'sound/effects/EMPulse.ogg', 50, 1)
			for(var/M in invokers)
				to_chat(M, "<span class='danger'>Your hair stands on end as a shockwave eminates from the rune!</span>")
		if(7 to INFINITY)
			playsound(E, 'sound/effects/EMPulse.ogg', 100, 1)
			for(var/M in invokers)
				var/mob/living/L = M
				to_chat(L, "<span class='userdanger'>You chant in unison and a colossal burst of energy knocks you backward!</span>")
				L.Weaken(2)
	qdel(src) //delete before pulsing because it's a delay reee
	empulse(E, 9*invokers.len, 12*invokers.len, 1) // Scales now, from a single room to most of the station depending on # of chanters

//Rite of Astral Communion: Separates one's spirit from their body. They will take damage while it is active.
/obj/effect/rune/astral
	cultist_name = "Astral Communion"
	cultist_desc = "severs the link between one's spirit and body. This effect is taxing and one's physical body will take damage while this is active."
	invocation = "Fwe'sh mah erl nyag r'ya!"
	icon_state = "6"
	rune_in_use = 0 //One at a time, please!
	construct_invoke = 0
	var/mob/living/affecting = null

/obj/effect/rune/astral/examine(mob/user)
	. = ..()
	if(affecting)
		. += "<span class='cultitalic'>A translucent field encases [user] above the rune!</span>"

/obj/effect/rune/astral/can_invoke(mob/living/user)
	if(rune_in_use)
		to_chat(user, "<span class='cultitalic'>[src] cannot support more than one body!</span>")
		log_game("Astral Communion rune failed - more than one user")
		return list()
	var/turf/T = get_turf(src)
	if(!user in T.contents)
		to_chat(user, "<span class='cultitalic'>You must be standing on top of [src]!</span>")
		log_game("Astral Communion rune failed - user not standing on rune")
		return list()
	return ..()

/obj/effect/rune/astral/invoke(var/list/invokers)
	var/mob/living/user = invokers[1]
	..()
	var/turf/T = get_turf(src)
	rune_in_use = 1
	affecting = user
	user.color = "#7e1717"
	user.visible_message("<span class='warning'>[user] freezes statue-still, glowing an unearthly red.</span>", \
						 "<span class='cult'>You see what lies beyond. All is revealed. While this is a wondrous experience, your physical form will waste away in this state. Hurry...</span>")
	user.ghostize(1)
	while(user)
		if(!affecting)
			visible_message("<span class='warning'>[src] pulses gently before falling dark.</span>")
			affecting = null //In case it's assigned to a number or something
			rune_in_use = 0
			return
		affecting.apply_damage(1, BRUTE)
		if(!(user in T.contents))
			user.visible_message("<span class='warning'>A spectral tendril wraps around [user] and pulls [user.p_them()] back to the rune!</span>")
			Beam(user,icon_state="drainbeam",time=2)
			user.forceMove(get_turf(src)) //NO ESCAPE :^)
		if(user.key)
			user.visible_message("<span class='warning'>[user] slowly relaxes, the glow around [user.p_them()] dimming.</span>", \
								 "<span class='danger'>You are re-united with your physical form. [src] releases its hold over you.</span>")
			user.color = initial(user.color)
			user.Weaken(3)
			rune_in_use = 0
			affecting = null
			user.update_sight()
			return
		if(user.stat == UNCONSCIOUS)
			if(prob(10))
				var/mob/dead/observer/G = user.get_ghost()
				if(G)
					to_chat(G, "<span class='cultitalic'>You feel the link between you and your body weakening... you must hurry!</span>")
		if(user.stat == DEAD)
			user.color = initial(user.color)
			rune_in_use = 0
			affecting = null
			var/mob/dead/observer/G = user.get_ghost()
			if(G)
				to_chat(G, "<span class='cultitalic'><b>You suddenly feel your physical form pass on. [src]'s exertion has killed you!</b></span>")
			return
		sleep(10)
	rune_in_use = 0


//Rite of the Corporeal Shield: When invoked, becomes solid and cannot be passed. Invoke again to undo.
/obj/effect/rune/wall
	cultist_name = "Rite of the Corporeal Shield"
	cultist_desc = "when invoked, makes an invisible wall to block passage. Can be invoked again to reverse this."
	invocation = "Khari'd! Eske'te tannin!"
	icon_state = "1"
	invoke_damage = 2

/obj/effect/rune/wall/examine(mob/user)
	. = ..()
	if(density)
		. += "<span class='cultitalic'>There is a barely perceptible shimmering of the air above [src].</span>"

/obj/effect/rune/wall/invoke(var/list/invokers)
	var/mob/living/user = invokers[1]
	..()
	density = !density
	user.visible_message("<span class='warning'>[user] places [user.p_their()] hands on [src], and [density ? "the air above it begins to shimmer" : "the shimmer above it fades"].</span>", \
						 "<span class='cultitalic'>You channel your life energy into [src], [density ? "preventing" : "allowing"] passage above it.</span>")
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.apply_damage(2, BRUTE, pick("l_arm", "r_arm"))


//Rite of Joined Souls: Summons a single cultist.
/obj/effect/rune/summon
	cultist_name = "Rite of Joined Souls"
	cultist_desc = "summons a single cultist to the rune. Requires 2 invokers."
	invocation = "N'ath reth sh'yro eth d'rekkathnor!"
	req_cultists = 2
	allow_excess_invokers = 1
	icon_state = "5"
	invoke_damage = 5
	var/summontime = 0

/obj/effect/rune/summon/invoke(var/list/invokers)
	var/mob/living/user = invokers[1]
	var/list/cultists = list()
	for(var/datum/mind/M in SSticker.mode.cult)
		if(!(M.current in invokers) && M.current && M.current.stat != DEAD)
			cultists |= M.current
	var/mob/living/cultist_to_summon = input(user, "Who do you wish to call to [src]?", "Followers of [SSticker.cultdat.entity_title3]") as null|anything in cultists
	if(!Adjacent(user) || !src || QDELETED(src) || user.incapacitated())
		return
	if(!cultist_to_summon)
		to_chat(user, "<span class='cultitalic'>You require a summoning target!</span>")
		fail_invoke()
		log_game("Summon Cultist rune failed - no target")
		return
	if(!iscultist(cultist_to_summon))
		to_chat(user, "<span class='cultitalic'>[cultist_to_summon] is not a follower of [SSticker.cultdat.entity_title3]!</span>")
		fail_invoke()
		log_game("Summon Cultist rune failed - no target")
		return
	if(!is_level_reachable(cultist_to_summon.z))
		to_chat(user, "<span class='cultitalic'>[cultist_to_summon] is not in our dimension!</span>")
		fail_invoke()
		log_game("Summon Cultist rune failed - target in away mission")
		return
	if((cultist_to_summon.reagents.has_reagent("holywater") || cultist_to_summon.restrained()) && invokers.len < 3)
		to_chat(user, "<span class='cultitalic'>The summoning of [cultist_to_summon] is being blocked somehow! You need 3 chanters to counter it!</span>")
		fail_invoke()
		new /obj/effect/temp_visual/cult/sparks(get_turf(cultist_to_summon)) //observer warning
		log_game("Summon Cultist rune failed - holywater in target")
		return

	..()
	if(cultist_to_summon.reagents.has_reagent("holywater") || cultist_to_summon.restrained())
		summontime = 20

	if(do_after(user, summontime, target = loc))
		cultist_to_summon.visible_message("<span class='warning'>[cultist_to_summon] suddenly disappears in a flash of red light!</span>", \
										  "<span class='cultitalic'><b>Overwhelming vertigo consumes you as you are hurled through the air!</b></span>")
		visible_message("<span class='warning'>A foggy shape materializes atop [src] and solidifies into [cultist_to_summon]!</span>")

		cultist_to_summon.forceMove(get_turf(src))
		qdel(src)

//Rite of Boiling Blood: Deals extremely high amounts of damage to non-cultists nearby
/obj/effect/rune/blood_boil
	cultist_name = "Boil Blood"
	cultist_desc = "boils the blood of non-believers who can see the rune, dealing extreme amounts of damage. Requires 3 invokers."
	invocation = "Dedo ol'btoh!"
	icon_state = "4"
	construct_invoke = 0
	req_cultists = 3
	invoke_damage = 15

/obj/effect/rune/blood_boil/do_invoke_glow()
	return

/obj/effect/rune/blood_boil/invoke(var/list/invokers)
	..()
	var/turf/T = get_turf(src)
	visible_message("<span class='warning'>[src] briefly bubbles before exploding!</span>")
	for(var/mob/living/carbon/C in viewers(T))
		if(!iscultist(C))
			var/obj/item/nullrod/N = C.null_rod_check()
			if(N)
				to_chat(C, "<span class='userdanger'>\The [N] suddenly burns hotly before returning to normal!</span>")
				continue
			to_chat(C, "<span class='cultlarge'>Your blood boils in your veins!</span>")
			C.take_overall_damage(45,45)
			C.Stun(7)
	qdel(src)
	explosion(T, -1, 0, 1, 5)

//Deals brute damage to all targets on the rune and heals the invoker for each target drained.
/obj/effect/rune/leeching
	cultist_name = "Drain Life"
	cultist_desc = "drains the life of all targets on the rune, restoring life to the user."
	invocation = "Yu'gular faras desdae. Umathar uf'kal thenar!"
	icon_state = "3"

/obj/effect/rune/leeching/can_invoke(mob/living/user)
	if(world.time <= user.next_move)
		return list()
	var/turf/T = get_turf(src)
	var/list/potential_targets = list()
	for(var/mob/living/carbon/M in T.contents - user)
		if(M.stat != DEAD)
			potential_targets += M
	if(!potential_targets.len)
		to_chat(user, "<span class='cultitalic'>There must be at least one valid target on the rune!</span>")
		log_game("Leeching rune failed - no valid targets")
		return list()
	return ..()

/obj/effect/rune/leeching/invoke(var/list/invokers)
	var/mob/living/user = invokers[1]
	user.changeNext_move(CLICK_CD_MELEE)
	..()
	var/turf/T = get_turf(src)
	for(var/mob/living/carbon/M in T.contents - user)
		if(M.stat != DEAD)
			var/drained_amount = rand(10,20)
			M.apply_damage(drained_amount, BRUTE, "chest")
			user.adjustBruteLoss(-drained_amount)
			to_chat(M, "<span class='cultitalic'>You feel extremely weak.</span>")
	user.Beam(T,icon_state="drainbeam",time=5)
	user.visible_message("<span class='warning'>Blood flows from the rune into [user]!</span>", \
	"<span class='cult'>Blood flows into you, healing your wounds and revitalizing your spirit.</span>")


//Rite of Spectral Manifestation: Summons a ghost on top of the rune as a cultist human with no items. User must stand on the rune at all times, and takes damage for each summoned ghost.
/obj/effect/rune/manifest
	cultist_name = "Rite of Spectral Manifestation"
	cultist_desc = "manifests a spirit as a servant of your god. The invoker must not move from atop the rune, and will take damage for each summoned spirit."
	invocation = "Gal'h'rfikk harfrandid mud'gib!" //how the fuck do you pronounce this
	icon_state = "6"
	construct_invoke = 0
	color = rgb(200, 0, 0)
	var/list/summoned_guys = list()
	var/ghost_limit = 5
	var/ghosts = 0
	invoke_damage = 10

/obj/effect/rune/manifest/New(loc)
	..()
	cultist_desc = "manifests a spirit as a servant of [SSticker.cultdat.entity_title3]. The invoker must not move from atop the rune, and will take damage for each summoned spirit."

	notify_ghosts("Manifest rune created in [get_area(src)].", ghost_sound='sound/effects/ghost2.ogg', source = src)

/obj/effect/rune/manifest/can_invoke(mob/living/user)
	if(ghosts >= ghost_limit)
		to_chat(user, "<span class='cultitalic'>You are sustaining too many ghosts to summon more!</span>")
		fail_invoke()
		log_game("Manifest rune failed - too many summoned ghosts")
		return list()
	if(!(user in get_turf(src)))
		to_chat(user,"<span class='cultitalic'>You must be standing on [src]!</span>")
		fail_invoke()
		log_game("Manifest rune failed - user not standing on rune")
		return list()
	if(user.has_status_effect(STATUS_EFFECT_SUMMONEDGHOST))
		to_chat(user, "<span class='cult italic'>Ghosts can't summon more ghosts!</span>")
		fail_invoke()
		log_game("Manifest rune failed - user is a ghost")
		return list()
	var/list/ghosts_on_rune = list()
	for(var/mob/dead/observer/O in get_turf(src))
		if(O.client && !jobban_isbanned(O, ROLE_CULTIST) && !jobban_isbanned(O, ROLE_SYNDICATE))
			ghosts_on_rune |= O
	if(!ghosts_on_rune.len)
		to_chat(user, "<span class='cultitalic'>There are no spirits near [src]!</span>")
		fail_invoke()
		log_game("Manifest rune failed - no nearby ghosts")
		return list()
	return ..()

/obj/effect/rune/manifest/invoke(var/list/invokers)
	var/mob/living/user = invokers[1]
	var/list/ghosts_on_rune = list()
	for(var/mob/dead/observer/O in get_turf(src))
		if(O.client && !jobban_isbanned(O, ROLE_CULTIST) && !jobban_isbanned(O, ROLE_SYNDICATE))
			ghosts_on_rune |= O
	var/mob/dead/observer/ghost_to_spawn = pick(ghosts_on_rune)
	var/mob/living/carbon/human/new_human = new(get_turf(src))
	new_human.real_name = ghost_to_spawn.real_name
	new_human.alpha = 150 //Makes them translucent
	new_human.equipOutfit(/datum/outfit/ghost_cultist) //give them armor
	new_human.apply_status_effect(STATUS_EFFECT_SUMMONEDGHOST) //ghosts can't summon more ghosts
	new_human.color = "grey" //heh..cult greytide...litterly...
	..()

	playsound(src, 'sound/misc/exit_blood.ogg', 50, 1)
	visible_message("<span class='warning'>A cloud of red mist forms above [src], and from within steps... a man.</span>")
	to_chat(user, "<span class='cultitalic'>Your blood begins flowing into [src]. You must remain in place and conscious to maintain the forms of those summoned. This will hurt you slowly but surely...</span>")
	var/obj/machinery/shield/N = new(get_turf(src))
	N.name = "Invoker's Shield"
	N.desc = "A weak shield summoned by cultists to protect them while they carry out delicate rituals"
	N.color = "red"
	N.health = 20
	N.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	new_human.key = ghost_to_spawn.key
	SSticker.mode.add_cultist(new_human.mind, FALSE)
	new_human.mind.special_role = SPECIAL_ROLE_CULTIST
	summoned_guys |= new_human
	ghosts++
	to_chat(new_human, "<span class='cultitalic'><b>You are a servant of [SSticker.cultdat.entity_title3]. You have been made semi-corporeal by the cult of [SSticker.cultdat.entity_name], and you are to serve them at all costs.</b></span>")

	while(user in get_turf(src))
		if(user.stat)
			break
		if(!atoms_share_level(get_turf(new_human), get_turf(user)))
			break
		user.apply_damage(0.1, BRUTE)
		sleep(3)

	qdel(N)
	if(new_human)
		new_human.visible_message("<span class='warning'>[new_human] suddenly dissolves into bones and ashes.</span>", \
								  "<span class='cultlarge'>Your link to the world fades. Your form breaks apart.</span>")
		for(var/obj/I in new_human)
			new_human.unEquip(I)
		summoned_guys -= new_human
		ghosts--
		SSticker.mode.remove_cultist(new_human.mind, FALSE)
		new_human.dust()

/obj/effect/rune/manifest/Destroy()
	for(var/mob/living/carbon/human/guy in summoned_guys)
		for(var/obj/I in guy)
			guy.unEquip(I)
		guy.dust()
	summoned_guys.Cut()
	return ..()
