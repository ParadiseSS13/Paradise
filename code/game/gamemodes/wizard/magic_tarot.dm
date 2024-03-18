/obj/item/tarot_generator
	name = "Enchanted tarot card pack" //Qwertodo: A better name
	desc = "Reusable card generator"
	icon = 'icons/obj/playing_cards.dmi'
	icon_state = "card_holder"
	w_class = WEIGHT_CLASS_SMALL
	/// What is the maximum number of cards the tarot generator can have in the world at a time?
	var/maximum_cards = 3
	/// List of cards we have created, to check against maximum, and so we can purge them from the pack.
	var/list/our_card_list = list()

/obj/item/tarot_generator/attack_self(mob/user)
	if(length(our_card_list) >= 3)
		to_chat(user, "<span class='warning'>[src]'s magic can only support up to [maximum_cards] in the world at once, use or destroy some!</span>")
		return
	var/obj/item/magic_tarot_card/MTC = new /obj/item/magic_tarot_card(get_turf(src), src)
	our_card_list += MTC
	user.put_in_hands(MTC)
	to_chat(user, "<span class='hierophant'>You draw [MTC.name]... [MTC.card_desc]</span>") //No period on purpose.

/obj/item/tarot_generator/examine(mob/user)
	. = ..()
	. += "<span class='hierophant'>Alt-Shift-Click to destroy all cards it has produced.</span>"

/obj/item/tarot_generator/AltShiftClick(mob/user)
	for(var/obj/item/magic_tarot_card/MTC in our_card_list)
		MTC.dust()
	to_chat(user, "<span class='hierophant'>You dispell the cards [src] had created.</span>")

/obj/item/magic_tarot_card
	name = "XXII - The Unknown"
	desc = "A tarot card. However, it feels like it has a meaning behind it?"
	icon = 'icons/obj/playing_cards.dmi'
	icon_state = "tarot_the_unknown"
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 10
	throwforce = 0
	force = 0
	/// The deck that created us. Notifies it we have been deleted on use.
	var/obj/item/tarot_generator/creator_deck
	/// Our magic tarot card datum that lets the tarot card do stuff on use, or hitting someone
	var/datum/tarot/our_tarot
	/// Our fancy description given to use by the tarot datum.
	var/card_desc = "Untold answers... wait what? This is a bug, report this as an issue on github!"

/obj/item/magic_tarot_card/Initialize(mapload, obj/item/tarot_generator/source)
	. = ..()
	if(source)
		creator_deck = source
	var/tarotpath = pick(subtypesof(/datum/tarot))
	our_tarot = new tarotpath
	name = our_tarot.name
	card_desc = our_tarot.desc
	icon_state = "tarot_the_unknown" //Qwertodo: Change this to use the datums icon, once we sprite it

/obj/item/magic_tarot_card/Destroy()
	if(creator_deck)
		creator_deck.our_card_list -= src
	return ..()

/obj/item/magic_tarot_card/examine(mob/user)
	. = ..()
	. += "<span class='hierophant'>[card_desc]</span>"

/obj/item/magic_tarot_card/attack_self(mob/user) //QWERTODO: Invoke asynk on the hit effect
	if(our_tarot)
		INVOKE_ASYNC(our_tarot, TYPE_PROC_REF(/datum/tarot, activate), user)
	poof()

/obj/item/magic_tarot_card/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(isliving(hit_atom) && our_tarot)
		INVOKE_ASYNC(our_tarot, TYPE_PROC_REF(/datum/tarot, activate), hit_atom)
	poof()

/obj/item/magic_tarot_card/proc/poof()
	new /obj/effect/particle_effect/sparks(get_turf(src)) //Something more magical
	qdel(src)

/obj/item/magic_tarot_card/proc/dust()
	visible_message("<span class='danger'>[src] disintigrates into dust!</span>")
	qdel(src)

/datum/tarot
	/// Name used for the card
	var/name = "XXII - The Unknown."
	/// Desc used for the card description of the card
	var/desc = "Untold answers... wait what? This is a bug, report this as an issue on github!"
	/// What icon is used for the card?
	var/card_icon = "the_unknown"

/datum/tarot/proc/activate(mob/living/target)
	message_admins("Uh oh! A bugged tarot card was spawned and used. Please make an issue report! Type was [src.type]")

/datum/tarot/the_fool //Assistant
	name = "0 - The Fool"
	desc = "Where journey begins."

/datum/tarot/the_fool/activate(mob/living/target)
	target.forceMove(pick(GLOB.latejoin))
	to_chat(target, "<span class='userdanger'>You are abruptly pulled through space!</span>")

/datum/tarot/the_magician //Wizard
	name = "I - The Magician"
	desc = "May you never miss your goal"

/datum/tarot/the_magician/activate(mob/living/target)
	. = ..()

/datum/tarot/the_high_priestess //BUBBLEGUM
	name = "II - The High Priestess"
	desc = "Mother is watching you"

/datum/tarot/the_high_priestess/activate(mob/living/target)
	new /obj/effect/abstract/bubblegum_rend_helper(get_turf(target), target, 20)

/obj/effect/abstract/bubblegum_rend_helper
	name = "bubblegum_rend_helper"

/obj/effect/abstract/bubblegum_rend_helper/Initialize(mapload, mob/living/owner, damage)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(rend), owner, damage)

/obj/effect/abstract/bubblegum_rend_helper/proc/rend(mob/living/owner, damage)
	var/turf/TA = get_turf(owner)
	owner.Immobilize(3 SECONDS)
	new /obj/effect/decal/cleanable/blood/bubblegum(TA)
	new /obj/effect/temp_visual/bubblegum_hands/rightsmack(TA)
	sleep(6)
	var/turf/TB = get_turf(owner)
	to_chat(owner, "<span class='userdanger'>Something huge rends you!</span>")
	playsound(TB, 'sound/misc/demon_attack1.ogg', 100, TRUE, -1)
	owner.adjustBruteLoss(damage)
	new /obj/effect/decal/cleanable/blood/bubblegum(TB)
	new /obj/effect/temp_visual/bubblegum_hands/leftsmack(TB)
	sleep(6)
	var/turf/TC = get_turf(owner)
	to_chat(owner, "<span class='userdanger'>Something huge rends you!</span>")
	playsound(TC, 'sound/misc/demon_attack1.ogg', 100, TRUE, -1)
	owner.adjustBruteLoss(damage)
	new /obj/effect/decal/cleanable/blood/bubblegum(TC)
	new /obj/effect/temp_visual/bubblegum_hands/rightsmack(TC)
	sleep(6)
	var/turf/TD = get_turf(owner)
	to_chat(owner, "<span class='userdanger'>Something huge rends you!</span>")
	playsound(TD, 'sound/misc/demon_attack1.ogg', 100, TRUE, -1)
	owner.adjustBruteLoss(damage)
	qdel(src)

/datum/tarot/the_empress //Unsure!
	name = "III - The Empress"
	desc = "May your rage bring power"

/datum/tarot/the_empress/activate(mob/living/target)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.reagents.add_reagent("mephedrone", 4.5)
		H.reagents.add_reagent("mitocholide", 12)

/datum/tarot/the_emperor //Captain
	name = "IV - The Emperor"
	desc = "Challenge me!"

/datum/tarot/the_emperor/activate(mob/living/target)
	var/list/L = list()
	for(var/turf/T in get_area_turfs(/area/station/command/bridge))
		if(is_blocked_turf(T))
			continue
		L.Add(T)

	if(!length(L))
		to_chat(target, "<span class='warning'>Huh. No bridge? Well, that sucks.</span>")
		return

	target.forceMove(pick(L))

/datum/tarot/the_hierophant
	name = "V - The Hierophant"
	desc = "Two prayers for the lost"

/datum/tarot/the_hierophant/activate(mob/living/target)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.wear_suit)
			H.wear_suit.setup_hierophant_shielding()
			H.update_appearance(UPDATE_ICON)

//Chariot blood drunk, and vampire bonus.

/datum/tarot/the_lovers
	name = "VI - The Lovers"
	desc = "May you prosper and be in good health"

/datum/tarot/the_lovers/activate(mob/living/target)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.adjustBruteLoss(-40, robotic = TRUE)
		H.adjustFireLoss(-40, robotic = TRUE)
	else
		target.adjustBruteLoss(-40)
		target.adjustFireLoss(-40)
	target.adjustOxyLoss(-40)
	target.adjustToxLoss(-40)

/datum/tarot/the_chariot
	name = "VII - The Chariot"
	desc = "May nothing stand before you"

/datum/tarot/the_chariot/activate(mob/living/target)
	target.apply_status_effect(STATUS_EFFECT_BLOOD_RUSH)
	target.apply_status_effect(STATUS_EFFECT_FORCESHIELD)

/datum/tarot/justice
	name = "VIII - Justice"
	desc = "May your future become balanced"

/datum/tarot/justice/activate(mob/living/target)
	var/turf/target_turf = get_turf(target)
	new /obj/item/storage/firstaid/regular(target_turf)
	new /obj/item/grenade/frag(target_turf)
	new /obj/item/card/emag/one_use(target_turf)
	new /obj/item/stack/spacecash/c200(target_turf)

/datum/tarot/the_hermit
	name = "IX - The Hermit"
	desc = "May you see what life has to offer"

/datum/tarot/the_hermit/activate(mob/living/target)
	var/list/viable_vendors = list()
	for(var/obj/machinery/economy/vending/candidate in GLOB.machines)
		if(!is_station_level(candidate.z))
			continue
		viable_vendors += candidate

	if(!length(viable_vendors))
		to_chat(target, "<span class='warning'>No vending machines? Well, with luck cargo will have something to offer. If you go there yourself.</span>")
		return

	target.forceMove(get_turf(pick(viable_vendors)))


/datum/tarot/wheel_of_fortune
	name = "X - Wheel of Fortune"
	desc = "Spin the wheel of destiny"

/datum/tarot/wheel_of_fortune/activate(mob/living/target)
	var/list/static/bad_vendors = list(/obj/machinery/economy/vending/liberationstation,
	/obj/machinery/economy/vending/toyliberationstation,
	/obj/machinery/economy/vending/wallmed)
	var/turf/target_turf = get_turf(target)
	var/vendorpath = pick(subtypesof(/obj/machinery/economy/vending) - bad_vendors)
	new vendorpath(target_turf)

/datum/tarot/strength
	name = "XI - Strength"
	desc = "May your power bring rage"

/datum/tarot/strength/activate(mob/living/target)
	target.apply_status_effect(STATUS_EFFECT_VAMPIRE_GLADIATOR)
	target.apply_status_effect(STATUS_EFFECT_BLOOD_SWELL)

/datum/tarot/the_hanged_man
	name = "XII - The Hanged Man"
	desc = "May you find enlightenment"

/datum/tarot/the_hanged_man/activate(mob/living/target)
	if(target.flying)
		return
	target.flying = TRUE
	addtimer(VARSET_CALLBACK(target, flying, FALSE), 60 SECONDS)

/datum/tarot/death
	name = "XIII - Death"
	desc = "Lay waste to all that oppose you"

/datum/tarot/death/activate(mob/living/target) //qwertodo: to_chat? visable effect? unsure
	for(var/mob/living/L in oview(9, target))
		L.adjustBruteLoss(20)
		L.adjustFireLoss(20)

/datum/tarot/temperance
	name = "XIV - Temperance"
	desc = "May you be pure in heart"

/datum/tarot/temperance/activate(mob/living/target)
	. = ..()

/datum/tarot/the_devil
	name = "XV - The Devil"
	desc = "Revel in the power of darkness"

/datum/tarot/the_devil/activate(mob/living/target)
	. = ..()

/datum/tarot/the_tower
	name = "XVI - The Tower"
	desc = "Destruction brings creation"

/datum/tarot/the_tower/activate(mob/living/target)
	var/obj/item/grenade/clusterbuster/ied/bakoom = new(get_turf(target))
	bakoom.prime()

/datum/tarot/the_stars //I'm sorry matt, this is very funny.
	name = "XVII - The Stars"
	desc = "May you find what you desire"

/datum/tarot/the_stars/activate(mob/living/target)
	var/list/L = list()
	for(var/turf/T in get_area_turfs(/area/station/security/evidence))
		if(is_blocked_turf(T))
			continue
		L.Add(T)

	if(!length(L))
		to_chat(target, "<span class='warning'>Huh. No evidence? Well, that means they can't charge you with a crime, right?</span>")
		return

	target.forceMove(pick(L))
	for(var/obj/structure/closet/C in shuffle(view(9, target)))
		if(istype(C, /obj/structure/closet/secure_closet))
			var/obj/structure/closet/secure_closet/SC = C
			SC.locked = FALSE
		C.open()
		break //Only open one locker

/datum/tarot/the_moon
	name = "XVIII - The Moon"
	desc = "May you find all you have lost"

/datum/tarot/the_moon/activate(mob/living/target)
	var/list/funny_ruin_list = list()
	var/turf/target_turf = get_turf(target)
	for(var/i in GLOB.ruin_landmarks)
		var/obj/effect/landmark/ruin/ruin_landmark = i
		if(ruin_landmark.z == target_turf.z)
			funny_ruin_list += ruin_landmark

	if(length(funny_ruin_list))
		target.forceMove(get_turf(pick(funny_ruin_list)))
		target.update_parallax_contents()
		return
	//We did not find a ruin on the same level. Well. I hope you have a space suit, but we'll go space ruins as they are mostly sorta kinda safer.
	for(var/i in GLOB.ruin_landmarks)
		var/obj/effect/landmark/ruin/ruin_landmark = i
		if(!is_mining_level(ruin_landmark.z))
			funny_ruin_list += ruin_landmark

	if(length(funny_ruin_list))
		target.forceMove(get_turf(pick(funny_ruin_list)))
		target.update_parallax_contents()
		return
	to_chat(target, "<span class='warning'>Huh. No space ruins? Well, this card is RUINED!</span>")

/datum/tarot/the_sun
	name = "XIX - The Sun"
	desc = "May the light heal and enlighten you"

/datum/tarot/the_sun/activate(mob/living/target)
	target.revive()

/datum/tarot/judgement
	name = "XX - Judgement"
	desc = "Judge lest ye be judged"

/datum/tarot/judgement/activate(mob/living/target)
	notify_ghosts("[target] has used a judgment card. Judge them. Or not, up to you.", enter_link="<a href=?src=[UID()];follow=1>(Click to judge)</a>", source = target, action = NOTIFY_FOLLOW)

/datum/tarot/the_world //qwertodo: temporary xray vision
	name = "XXI - The World"
	desc = "Open your eyes and see"

/datum/tarot/the_world/activate(mob/living/target)
	. = ..()
