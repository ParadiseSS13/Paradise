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

/obj/item/magic_tarot_card/attack_self(mob/user)
	if(our_tarot)
		our_tarot.activate(user)
	poof()

/obj/item/magic_tarot_card/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(isliving(hit_atom) && our_tarot)
		our_tarot.activate(hit_atom)
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

//Chariot blood drunk, and vampire bonus.
// Hierophant for hierphant, make shield purple.
