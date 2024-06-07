/obj/item/tarot_generator
	name = "Enchanted tarot card deck"
	desc = "This tarot card box has quite the array of runes and artwork on it."
	icon = 'icons/obj/playing_cards.dmi'
	icon_state = "tarot_box"
	w_class = WEIGHT_CLASS_SMALL
	/// What is the maximum number of cards the tarot generator can have in the world at a time?
	var/maximum_cards = 3
	/// List of cards we have created, to check against maximum, and so we can purge them from the pack.
	var/list/our_card_list = list()
	///How long the cooldown is each time we draw a card before we can draw another?
	var/our_card_cooldown_time = 25 SECONDS
	COOLDOWN_DECLARE(card_cooldown)

/obj/item/tarot_generator/wizard
	maximum_cards = 5
	our_card_cooldown_time = 12 SECONDS  // A minute for a full hand of 5 cards

/obj/item/tarot_generator/attack_self(mob/user)
	if(!COOLDOWN_FINISHED(src, card_cooldown))
		to_chat(user, "<span class='warning'>[src]'s magic is still recovering from the last card, wait [round(COOLDOWN_TIMELEFT(src, card_cooldown) / 10)] more second\s!</span>")
		return
	if(length(our_card_list) >= maximum_cards)
		to_chat(user, "<span class='warning'>[src]'s magic can only support up to [maximum_cards] in the world at once, use or destroy some!</span>")
		return
	var/obj/item/magic_tarot_card/MTC = new /obj/item/magic_tarot_card(get_turf(src), src)
	our_card_list += MTC
	user.put_in_hands(MTC)
	to_chat(user, "<span class='hierophant'>You draw [MTC.name]... [MTC.card_desc]</span>") //No period on purpose.
	COOLDOWN_START(src, card_cooldown, our_card_cooldown_time)

/obj/item/tarot_generator/examine(mob/user)
	. = ..()
	. += "<span class='hierophant'>Alt-Shift-Click to destroy all cards it has produced.</span>"
	. += "<span class='hierophant'>It has [length(our_card_list)] card\s in the world right now.</span>"
	if(!COOLDOWN_FINISHED(src, card_cooldown))
		. += "<span class='hierophant'>You may draw another card again in [round(COOLDOWN_TIMELEFT(src, card_cooldown) / 10)] second\s.</span>"

/obj/item/tarot_generator/AltShiftClick(mob/user)
	for(var/obj/item/magic_tarot_card/MTC in our_card_list)
		MTC.dust()
	to_chat(user, "<span class='hierophant'>You dispell the cards [src] had created.</span>")

// Booster packs filled with 3, 5, or 7 playing cards! Used by the wizard space ruin, or rarely in lavaland tendril chests.
/obj/item/tarot_card_pack
	name = "\improper Enchanted Arcana Pack"
	desc = "A pack of 3 Enchanted tarot cards. Collect them all!"
	icon = 'icons/obj/playing_cards.dmi'
	icon_state = "pack"
	///How many cards in a pack. 3 in base, 5 in jumbo, 7 in mega
	var/cards = 3

/obj/item/tarot_card_pack/attack_self(mob/user)
	user.visible_message("<span class='notice'>[user] tears open [src].</span>", \
						"<span class='hierophant'>You tear open [src]!</span>")
	playsound(loc, 'sound/items/poster_ripped.ogg', 50, TRUE)
	for(var/i in 1 to cards)
		new /obj/item/magic_tarot_card(get_turf(src))
	qdel(src)

/obj/item/tarot_card_pack/jumbo
	name = "\improper Jumbo Arcana Pack"
	desc = "A Jumbo card pack from your friend Jimbo!"
	icon_state = "jumbopack"
	cards = 5

/obj/item/tarot_card_pack/mega
	name = "\improper MEGA Arcana Pack"
	desc = "Sadly, you won't find a Joker for an angel room, or a Soul card in here either."
	icon_state = "megapack"
	cards = 7

// Blank tarot cards. Made by the cult, however also good for space ruins potentially, where one feels a card pack would be too much?
/obj/item/blank_tarot_card
	name = "blank tarot card"
	desc = "A blank tarot card."
	icon = 'icons/obj/playing_cards.dmi'
	icon_state = "tarot_blank"
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 10
	throwforce = 0
	force = 0
	resistance_flags = FLAMMABLE
	/// If a person can choose what the card produces. No cost if they can choose.
	var/let_people_choose = FALSE

/obj/item/blank_tarot_card/examine(mob/user)
	. = ..()
	if(!let_people_choose)
		. += "<span class='hierophant'>With a bit of Ink, a work of art could be created. Will you provide your Ink?</span>"
	else
		. += "<span class='hierophant'>We have the Ink... Could you provide your Vision instead?</span>"

/obj/item/blank_tarot_card/attack_self(mob/user)
	if(!ishuman(user))
		return
	if(!let_people_choose)
		var/mob/living/carbon/human/H = user
		if(H.dna && (NO_BLOOD in H.dna.species.species_traits))
			to_chat(user, "<span class='cult'>No blood to provide?...</span><span class='hierophant'> Then no Ink for the art...</span>")
			return
		if(H.blood_volume <= 100) //Shouldn't happen, they should be dead, but failsafe. Not bleeding as then they could recover the blood with blood rites
			return
		H.blood_volume -= 100
		H.drop_item()
		var/obj/item/magic_tarot_card/MTC = new /obj/item/magic_tarot_card(get_turf(src))
		user.put_in_hands(MTC)
		to_chat(user, "<span class='cult'>Your blood flows into [src]...</span><span class='hierophant'> And your Ink makes a work of art! [MTC.name]... [MTC.card_desc]</span>") //No period on purpose.
		qdel(src)
		return
	var/tarot_type
	var/tarot_name
	var/list/card_by_name = list()
	for(var/T in subtypesof(/datum/tarot) - /datum/tarot/reversed)
		var/datum/tarot/temp = T
		card_by_name[temp.name] = T

	tarot_name = tgui_input_list(user, "Choose the Work of Art to create.", "Art Creation", card_by_name)
	tarot_type = card_by_name[tarot_name]
	if(tarot_type)
		user.drop_item()
		var/obj/item/magic_tarot_card/MTC = new /obj/item/magic_tarot_card(get_turf(src), null, tarot_type)
		user.put_in_hands(MTC)
		to_chat(user, "</span><span class='hierophant'>You put your Vision into [src], and your Vision makes a work of Art! [MTC.name]... [MTC.card_desc]</span>") //No period on purpose.
		qdel(src)

/obj/item/blank_tarot_card/choose //For admins mainly, to spawn a specific tarot card. Not recommended for ruins.
	let_people_choose = TRUE

/obj/item/magic_tarot_card
	name = "XXII - The Unknown"
	desc = "A beautiful tarot card. However, it feels like... more?"
	icon = 'icons/obj/playing_cards.dmi'
	icon_state = "tarot_the_unknown"
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 10
	throwforce = 0
	force = 0
	resistance_flags = FLAMMABLE
	/// The deck that created us. Notifies it we have been deleted on use.
	var/obj/item/tarot_generator/creator_deck
	/// Our magic tarot card datum that lets the tarot card do stuff on use, or hitting someone
	var/datum/tarot/our_tarot
	/// Our fancy description given to use by the tarot datum.
	var/card_desc = "Untold answers... wait what? This is a bug, report this as an issue on github!"
	///Is the card face down? Shows the card back, hides the examine / name.
	var/face_down = FALSE

/obj/item/magic_tarot_card/Initialize(mapload, obj/item/tarot_generator/source, datum/tarot/chosen_tarot)
	. = ..()
	if(source)
		creator_deck = source
	if(chosen_tarot)
		our_tarot = new chosen_tarot
	if(!istype(our_tarot))
		var/tarotpath = pick(subtypesof(/datum/tarot) - /datum/tarot/reversed)
		our_tarot = new tarotpath
	name = our_tarot.name
	card_desc = our_tarot.desc
	icon_state = "tarot_[our_tarot.card_icon]"

/obj/item/magic_tarot_card/Destroy()
	if(creator_deck)
		creator_deck.our_card_list -= src
	return ..()

/obj/item/magic_tarot_card/examine(mob/user)
	. = ..()
	if(!face_down)
		. += "<span class='hierophant'>[card_desc]</span>"
	. += "<span class='hierophant'>Alt-Shift-Click to flip the card over.</span>"

/obj/item/magic_tarot_card/attack_self(mob/user)
	poof()
	if(face_down)
		flip()
	if(our_tarot)
		pre_activate(user)
		return
	qdel(src)

/obj/item/magic_tarot_card/throw_at(atom/target, range, speed, mob/thrower, spin, diagonals_first, datum/callback/callback, force, dodgeable)
	if(face_down)
		flip()
	. = ..()

/obj/item/magic_tarot_card/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	poof()
	if(isliving(hit_atom) && our_tarot)
		pre_activate(hit_atom)
		return
	qdel(src)

/obj/item/magic_tarot_card/AltShiftClick(mob/user)
	flip()

/obj/item/magic_tarot_card/proc/flip()
	if(!face_down)
		icon_state = "cardback[our_tarot.reversed ? "?" : ""]"
		name = "Enchanted tarot card"
		face_down = TRUE
	else
		name = our_tarot.name
		icon_state = "tarot_[our_tarot.card_icon]"
		face_down = FALSE

/obj/item/magic_tarot_card/proc/poof()
	new /obj/effect/temp_visual/revenant(get_turf(src))

/obj/item/magic_tarot_card/proc/dust()
	visible_message("<span class='danger'>[src] disintegrates into dust!</span>")
	new /obj/effect/temp_visual/revenant(get_turf(src))
	qdel(src)

/obj/item/magic_tarot_card/proc/pre_activate(mob/user)
	forceMove(user)
	var/obj/effect/temp_visual/tarot_preview/draft = new /obj/effect/temp_visual/tarot_preview(user, our_tarot.card_icon)
	user.vis_contents += draft
	user.visible_message("<span class='hierophant'>[user] holds up [src]!</span>")
	addtimer(CALLBACK(our_tarot, TYPE_PROC_REF(/datum/tarot, activate), user), 0.5 SECONDS)
	QDEL_IN(src, 0.6 SECONDS)

/obj/effect/temp_visual/tarot_preview
	name = "a tarot card"
	icon = 'icons/obj/playing_cards.dmi'
	icon_state = "tarot_the_unknown"
	pixel_y = 20
	duration = 1.5 SECONDS

/obj/effect/temp_visual/tarot_preview/Initialize(atom/mapload, new_icon_state)
	. = ..()
	if(new_icon_state)
		icon_state = "tarot_[new_icon_state]"
	var/new_filter = isnull(get_filter("ray"))
	ray_filter_helper(1, 40,"#fcf3dc", 6, 20)
	if(new_filter)
		animate(get_filter("ray"), alpha = 0, offset = 10, time = duration, loop = -1)
		animate(offset = 0, time = duration)

/datum/tarot
	/// Name used for the card
	var/name = "XXII - The Unknown."
	/// Desc used for the card description of the card
	var/desc = "Untold answers... wait what? This is a bug, report this as an issue on github!"
	/// What icon is used for the card?
	var/card_icon = "the_unknown"
	/// Are we reversed? Used for the card back.
	var/reversed = FALSE

/datum/tarot/proc/activate(mob/living/target)
	stack_trace("A bugged tarot card was spawned and used. Please make an issue report! Type was [src.type]")

/datum/tarot/reversed
	name = "XXII - The Unknown?"
	desc = "Untold answers... wait what? This is a bug, report this as an issue on github! This one was a reversed arcana!"
	card_icon = "the_unknown?"
	reversed = TRUE

/datum/tarot/the_fool
	name = "0 - The Fool"
	desc = "Where journey begins."
	card_icon = "the_fool"

/datum/tarot/the_fool/activate(mob/living/target)
	target.forceMove(pick(GLOB.latejoin))
	to_chat(target, "<span class='userdanger'>You are abruptly pulled through space!</span>")

/datum/tarot/the_magician
	name = "I - The Magician"
	desc = "May you never miss your goal."
	card_icon = "the_magician"

/datum/tarot/the_magician/activate(mob/living/target)
	target.apply_status_effect(STATUS_EFFECT_BADASS)
	to_chat(target, "<span class='notice'>You feel badass.</span>")

/datum/tarot/the_high_priestess
	name = "II - The High Priestess"
	desc = "Mother is watching you."
	card_icon = "the_high_priestess"

/datum/tarot/the_high_priestess/activate(mob/living/target)
	new /obj/effect/abstract/bubblegum_rend_helper(get_turf(target), target, 20)

/obj/effect/abstract/bubblegum_rend_helper
	name = "bubblegum_rend_helper"

/obj/effect/abstract/bubblegum_rend_helper/Initialize(mapload, mob/living/owner, damage)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(rend), owner, damage)

/obj/effect/abstract/bubblegum_rend_helper/proc/rend(mob/living/owner, damage)
	if(!owner)
		for(var/mob/living/L in shuffle(view(9, src)))
			owner = L
			break
	owner.Immobilize(3 SECONDS)
	for(var/i in 1 to 3)
		var/turf/first_turf = get_turf(owner)
		new /obj/effect/decal/cleanable/blood/bubblegum(first_turf)
		if(prob(50))
			new /obj/effect/temp_visual/bubblegum_hands/rightsmack(first_turf)
		else
			new /obj/effect/temp_visual/bubblegum_hands/leftsmack(first_turf)
		sleep(6)
		var/turf/second_turf = get_turf(owner)
		to_chat(owner, "<span class='userdanger'>Something huge rends you!</span>")
		playsound(second_turf, 'sound/misc/demon_attack1.ogg', 100, TRUE, -1)
		owner.adjustBruteLoss(damage)
	qdel(src)

/datum/tarot/the_empress
	name = "III - The Empress"
	desc = "May your rage bring power."
	card_icon = "the_empress"

/datum/tarot/the_empress/activate(mob/living/target)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.reagents.add_reagent("mephedrone", 4.5)
		H.reagents.add_reagent("mitocholide", 12)

/datum/tarot/the_emperor
	name = "IV - The Emperor"
	desc = "Challenge me!"
	card_icon = "the_emperor"

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
	to_chat(target, "<span class='userdanger'>You are abruptly pulled through space!</span>")

/datum/tarot/the_hierophant
	name = "V - The Hierophant"
	desc = "Two prayers for the lost."
	card_icon = "the_hierophant"

/datum/tarot/the_hierophant/activate(mob/living/target)
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/H = target
	if(!H.wear_suit)
		return
	H.wear_suit.setup_hierophant_shielding()
	H.update_appearance(UPDATE_ICON)

/datum/tarot/the_lovers
	name = "VI - The Lovers"
	desc = "May you prosper and be in good health."
	card_icon = "the_lovers"

/datum/tarot/the_lovers/activate(mob/living/target)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.adjustBruteLoss(-40, robotic = TRUE)
		H.adjustFireLoss(-40, robotic = TRUE)
		H.blood_volume = min(H.blood_volume + 100, BLOOD_VOLUME_NORMAL)
	else
		target.adjustBruteLoss(-40)
		target.adjustFireLoss(-40)
	target.adjustOxyLoss(-40)
	target.adjustToxLoss(-40)

/datum/tarot/the_chariot
	name = "VII - The Chariot"
	desc = "May nothing stand before you."
	card_icon = "the_chariot"

/datum/tarot/the_chariot/activate(mob/living/target)
	target.apply_status_effect(STATUS_EFFECT_BLOOD_RUSH)
	target.apply_status_effect(STATUS_EFFECT_BLOODDRUNK_CHARIOT)

/datum/tarot/justice
	name = "VIII - Justice"
	desc = "May your future become balanced."
	card_icon = "justice"

/datum/tarot/justice/activate(mob/living/target)
	var/turf/target_turf = get_turf(target)
	new /obj/item/storage/firstaid/regular(target_turf)
	new /obj/item/grenade/chem_grenade/waterpotassium(target_turf)
	new /obj/item/card/emag/magic_key(target_turf)
	new /obj/item/stack/spacecash/c100(target_turf)

/datum/tarot/the_hermit
	name = "IX - The Hermit"
	desc = "May you see what life has to offer."
	card_icon = "the_hermit"

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
	to_chat(target, "<span class='userdanger'>You are abruptly pulled through space!</span>")

/datum/tarot/wheel_of_fortune
	name = "X - Wheel of Fortune"
	desc = "Spin the wheel of destiny."
	card_icon = "wheel_of_fortune"

/datum/tarot/wheel_of_fortune/activate(mob/living/target)
	var/list/static/bad_vendors = typesof(/obj/machinery/economy/vending/liberationstation)\
								+ typesof(/obj/machinery/economy/vending/toyliberationstation)\
								+ typesof(/obj/machinery/economy/vending/wallmed) // Future proofing in case we add more subtypes of disallowed vendors
	var/turf/target_turf = get_turf(target)
	var/vendorpath = pick(subtypesof(/obj/machinery/economy/vending) - bad_vendors)
	new vendorpath(target_turf)

/datum/tarot/strength
	name = "XI - Strength"
	desc = "May your power bring rage."
	card_icon = "strength"

/datum/tarot/strength/activate(mob/living/target)
	target.apply_status_effect(STATUS_EFFECT_VAMPIRE_GLADIATOR)
	target.apply_status_effect(STATUS_EFFECT_BLOOD_SWELL)

/datum/tarot/the_hanged_man
	name = "XII - The Hanged Man"
	desc = "May you find enlightenment."
	card_icon = "the_hanged_man"

/datum/tarot/the_hanged_man/activate(mob/living/target)
	if(target.flying)
		return
	target.flying = TRUE
	addtimer(VARSET_CALLBACK(target, flying, FALSE), 60 SECONDS)

/datum/tarot/death
	name = "XIII - Death"
	desc = "Lay waste to all that oppose you."
	card_icon = "death"

/datum/tarot/death/activate(mob/living/target)
	for(var/mob/living/L in oview(9, target))
		L.adjustBruteLoss(20)
		L.adjustFireLoss(20)

/datum/tarot/temperance
	name = "XIV - Temperance"
	desc = "May you be pure in heart."
	card_icon = "temperance"

/datum/tarot/temperance/activate(mob/living/target)
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/H = target
	var/obj/item/organ/internal/body_egg/egg = H.get_int_organ(/obj/item/organ/internal/body_egg)
	if(egg)
		egg.remove(H)
		H.vomit()
		egg.forceMove(get_turf(H))
	H.reagents.add_reagent("mutadone", 1)
	for(var/obj/item/organ/internal/I in H.internal_organs)
		I.heal_internal_damage(60)
	H.apply_status_effect(STATUS_EFFECT_PANACEA)
	for(var/thing in H.viruses)
		var/datum/disease/D = thing
		if(D.severity == NONTHREAT)
			continue
		D.cure()

/datum/tarot/the_devil
	name = "XV - The Devil"
	desc = "Revel in the power of darkness."
	card_icon = "the_devil"

/datum/tarot/the_devil/activate(mob/living/target)
	target.apply_status_effect(STATUS_EFFECT_SHADOW_MEND_DEVIL)

/datum/tarot/the_tower
	name = "XVI - The Tower"
	desc = "Destruction brings creation."
	card_icon = "the_tower"

/datum/tarot/the_tower/activate(mob/living/target)
	var/obj/item/grenade/clusterbuster/ied/bakoom = new(get_turf(target))
	bakoom.prime()

/// I'm sorry matt, this is very funny.
/datum/tarot/the_stars
	name = "XVII - The Stars"
	desc = "May you find what you desire."
	card_icon = "the_stars"

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
	to_chat(target, "<span class='userdanger'>You are abruptly pulled through space!</span>")
	for(var/obj/structure/closet/C in shuffle(view(9, target)))
		if(istype(C, /obj/structure/closet/secure_closet))
			var/obj/structure/closet/secure_closet/SC = C
			SC.locked = FALSE
		C.open()
		break //Only open one locker

/datum/tarot/the_moon
	name = "XVIII - The Moon"
	desc = "May you find all you have lost."
	card_icon = "the_moon"

/datum/tarot/the_moon/activate(mob/living/target)
	var/list/funny_ruin_list = list()
	var/turf/target_turf = get_turf(target)
	for(var/I in GLOB.ruin_landmarks)
		var/obj/effect/landmark/ruin/ruin_landmark = I
		if(ruin_landmark.z == target_turf.z)
			funny_ruin_list += ruin_landmark

	if(length(funny_ruin_list))
		var/turf/T = get_turf(pick(funny_ruin_list))
		target.forceMove(T)
		to_chat(target, "<span class='userdanger'>You are abruptly pulled through space!</span>")
		T.ChangeTurf(/turf/simulated/floor/plating) //we give them plating so they are not trapped in a wall, and a pickaxe to avoid being trapped in a wall
		new /obj/item/pickaxe/emergency(T)
		target.update_parallax_contents()
		return
	//We did not find a ruin on the same level. Well. I hope you have a space suit, but we'll go space ruins as they are mostly sorta kinda safer.
	for(var/I in GLOB.ruin_landmarks)
		var/obj/effect/landmark/ruin/ruin_landmark = I
		if(!is_mining_level(ruin_landmark.z))
			funny_ruin_list += ruin_landmark

	if(!length(funny_ruin_list))
		to_chat(target, "<span class='warning'>Huh. No space ruins? Well, this card is RUINED!</span>")

	var/turf/T = get_turf(pick(funny_ruin_list))
	target.forceMove(T)
	to_chat(target, "<span class='userdanger'>You are abruptly pulled through space!</span>")
	T.ChangeTurf(/turf/simulated/floor/plating) //we give them plating so they are not trapped in a wall, and a pickaxe to avoid being trapped in a wall
	new /obj/item/pickaxe/emergency(T)
	target.update_parallax_contents()
	return

/datum/tarot/the_sun
	name = "XIX - The Sun"
	desc = "May the light heal and enlighten you."
	card_icon = "the_sun"

/datum/tarot/the_sun/activate(mob/living/target)
	target.revive()

/datum/tarot/judgement
	name = "XX - Judgement"
	desc = "Judge lest ye be judged."
	card_icon = "judgement"

/datum/tarot/judgement/activate(mob/living/target)
	notify_ghosts("[target] has used a judgment card. Judge them. Or not, up to you.", enter_link = "<a href=byond://?src=[UID()];follow=1>(Click to judge)</a>", source = target, action = NOTIFY_FOLLOW)

/datum/tarot/the_world
	name = "XXI - The World"
	desc = "Open your eyes and see."
	card_icon = "the_world"

/datum/tarot/the_world/activate(mob/living/target)
	var/datum/effect_system/smoke_spread/bad/smoke = new()
	smoke.set_up(10, FALSE, target)
	smoke.start()
	target.apply_status_effect(STATUS_EFFECT_XRAY)

////////////////////////////////
////////REVERSED ARCANA/////////
////////////////////////////////

/datum/tarot/reversed/the_fool
	name = "0 - The Fool?"
	desc = "Let go and move on."
	card_icon = "the_fool?"

/datum/tarot/reversed/the_fool/activate(mob/living/target)
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/H = target
	for(var/obj/item/I in H)
		if(istype(I, /obj/item/bio_chip))
			continue
		H.unEquip(I)

/datum/tarot/reversed/the_magician
	name = "I - The Magician?"
	desc = "May no harm come to you."
	card_icon = "the_magician?"

/datum/tarot/reversed/the_magician/activate(mob/living/target)
	var/list/thrown_atoms = list()
	var/sparkle_path = /obj/effect/temp_visual/gravpush
	for(var/turf/T in range(5, target)) //Done this way so things don't get thrown all around hilariously.
		for(var/atom/movable/AM in T)
			thrown_atoms += AM

	for(var/atom/movable/AM as anything in thrown_atoms)
		if(AM == target || AM.anchored || (ismob(AM) && !isliving(AM)))
			continue

		var/throw_target = get_edge_target_turf(target, get_dir(target, get_step_away(AM, target)))
		var/dist_from_user = get_dist(target, AM)
		if(dist_from_user == 0)
			if(isliving(AM))
				var/mob/living/M = AM
				M.Weaken(6 SECONDS)
				M.adjustBruteLoss(10)
				to_chat(M, "<span class='userdanger'>You're slammed into the floor by [name]!</span>")
				add_attack_logs(target, M, "[M] was thrown by [target]'s [name]", ATKLOG_ALMOSTALL)
		else
			new sparkle_path(get_turf(AM), get_dir(target, AM))
			if(isliving(AM))
				var/mob/living/M = AM
				to_chat(M, "<span class='userdanger'>You're thrown back by [name]!</span>")
				add_attack_logs(target, M, "[M] was thrown by [target]'s [name]", ATKLOG_ALMOSTALL)
			INVOKE_ASYNC(AM, TYPE_PROC_REF(/atom/movable, throw_at), throw_target, ((clamp((3 - (clamp(dist_from_user - 2, 0, dist_from_user))), 3, 3))), 1) //So stuff gets tossed around at the same time.

/datum/tarot/reversed/the_high_priestess
	name = "II - The High Priestess?"
	desc = "Run."
	card_icon = "the_high_priestess?"

/datum/tarot/reversed/the_high_priestess/activate(mob/living/target)
	target.visible_message("<span class='colossus'><b>WHO DARES TO TRY TO USE MY POWER IN A CARD?</b></span>")
	target.apply_status_effect(STATUS_EFFECT_REVERSED_HIGH_PRIESTESS)

/datum/tarot/reversed/the_empress
	name = "III - The Empress?"
	desc = "May your love bring protection."
	card_icon = "the_empress?"

/datum/tarot/reversed/the_empress/activate(mob/living/target)
	for(var/mob/living/L in oview(9, target))
		L.apply_status_effect(STATUS_EFFECT_PACIFIED)

/datum/tarot/reversed/the_emperor
	name = "IV - The Emperor?"
	desc = "May you find a worthy opponent."
	card_icon = "the_emperor?"

/datum/tarot/reversed/the_emperor/activate(mob/living/target)
	var/list/L = list()
	var/list/heads = SSticker.mode.get_all_heads()
	for(var/datum/mind/head in heads)
		if(ishuman(head.current))
			L.Add(head.current)

	if(!length(L))
		to_chat(target, "<span class='warning'>Huh. No command members? I hope you didn't kill them all already...</span>")
		return

	target.forceMove(get_turf(pick(L)))
	to_chat(target, "<span class='userdanger'>You are abruptly pulled through space!</span>")

/datum/tarot/reversed/the_hierophant
	name = "V - The Hierophant?"
	desc = "Two prayers for the forgotten."
	card_icon = "the_hierophant?"

/datum/tarot/reversed/the_hierophant/activate(mob/living/target)
	var/active_chasers = 0
	for(var/mob/living/M in shuffle(orange(7, target)))
		if(M.stat == DEAD) //Let us not have dead mobs be used to make a disco inferno.
			continue
		if(active_chasers >= 2)
			return
		var/obj/effect/temp_visual/hierophant/chaser/C = new(get_turf(target), target, M, 1, FALSE)
		C.moving = 2
		C.standard_moving_before_recalc = 2
		C.moving_dir = text2dir(pick("NORTH", "SOUTH", "EAST", "WEST"))
		active_chasers++

/datum/tarot/reversed/the_lovers
	name = "VI - The Lovers?"
	desc = "May your heart shatter to pieces."
	card_icon = "the_lovers?"

/datum/tarot/reversed/the_lovers/activate(mob/living/target)
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/H = target
	H.apply_damage(20, BRUTE, BODY_ZONE_CHEST)
	H.bleed(120)
	var/obj/item/organ/external/chest = H.get_organ(BODY_ZONE_CHEST)
	chest.fracture()
	var/datum/organ/heart/datum_heart = H.get_int_organ_datum(ORGAN_DATUM_HEART)
	var/obj/item/organ/internal/our_heart = datum_heart.linked_organ
	our_heart.receive_damage(20, TRUE)

/datum/tarot/reversed/the_chariot
	name = "VII - The Chariot?"
	desc = "May nothing walk past you."
	card_icon = "the_chariot?"

/datum/tarot/reversed/the_chariot/activate(mob/living/target)
	target.Stun(4 SECONDS)
	new /obj/structure/closet/statue/indestructible(get_turf(target), target)

/datum/tarot/reversed/justice
	name = "VIII - Justice?"
	desc = "May your sins come back to torment you."
	card_icon = "justice?"

/datum/tarot/reversed/justice/activate(mob/living/target)
	var/list/static/ignored_supply_pack_types = list(
		/datum/supply_packs/abstract,
		/datum/supply_packs/abstract/shuttle
	)
	var/chosen = pick(SSeconomy.supply_packs - ignored_supply_pack_types)
	var/datum/supply_packs/the_pack = new chosen()
	var/spawn_location = get_turf(target)
	var/obj/structure/closet/crate/crate = the_pack.create_package(spawn_location)
	crate.name = "magic [crate.name]"
	qdel(the_pack)

/datum/tarot/reversed/the_hermit
	name = "IX - The Hermit?"
	desc = "May you see the value of all things in life."
	card_icon = "the_hermit?"

/datum/tarot/reversed/the_hermit/activate(mob/living/target) //Someone can improve this in the future (hopefully comment will not be here in 10 years.)
	for(var/obj/item/I in view(7, target))
		if(istype(I, /obj/item/gun))
			new /obj/item/stack/spacecash/c200(get_turf(I))
			qdel(I)
			continue
		if(istype(I, /obj/item/grenade))
			new /obj/item/stack/spacecash/c50(get_turf(I))
			qdel(I)
		if(istype(I, /obj/item/clothing/suit/armor))
			new /obj/item/stack/spacecash/c100(get_turf(I))
			qdel(I)
		if(istype(I, /obj/item/melee/baton))
			new /obj/item/stack/spacecash/c100(get_turf(I))
			qdel(I)

/datum/tarot/reversed/wheel_of_fortune
	name = "X - Wheel of Fortune?"
	desc = "Throw the dice of fate."
	card_icon = "wheel_of_fortune?"

/datum/tarot/reversed/wheel_of_fortune/activate(mob/living/target)
	var/obj/item/dice/d20/fate/one_use/gonna_roll_a_one = new /obj/item/dice/d20/fate/one_use(get_turf(target))
	gonna_roll_a_one.diceroll(target)

/datum/tarot/reversed/strength
	name = "XI - Strength?"
	desc = "May you break their resolve."
	card_icon = "strength?"

/datum/tarot/reversed/strength/activate(mob/living/target)
	for(var/mob/living/M in oview(9, target))
		M.Hallucinate(2 MINUTES)
		new /obj/effect/hallucination/delusion(get_turf(M), M)
		M.adjustBrainLoss(30)

/datum/tarot/reversed/the_hanged_man
	name = "XII - The Hanged Man?"
	desc = "May your greed know no bounds."
	card_icon = "the_hanged_man?"

/datum/tarot/reversed/the_hanged_man/activate(mob/living/target)
	var/obj/structure/cursed_slot_machine/pull_the_lever_kronk = new /obj/structure/cursed_slot_machine(get_turf(target))
	if(ishuman(target))
		var/mob/living/carbon/human/WRONG_LEVER = target
		pull_the_lever_kronk.attack_hand(WRONG_LEVER)

/datum/tarot/reversed/death
	name = "XIII - Death?"
	desc = "May life spring forth from the fallen."
	card_icon = "death?"

/datum/tarot/reversed/death/activate(mob/living/target)
	new /obj/structure/constructshell(get_turf(target))
	new /obj/item/soulstone/anybody(get_turf(target))

/datum/tarot/reversed/temperance
	name = "XIV - Temperance?"
	desc = "May your hunger be satiated."
	card_icon = "temperance?"

/datum/tarot/reversed/temperance/activate(mob/living/target)
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/H = target
	for(var/i in 1 to 5)
		var/datum/reagents/R = new /datum/reagents(10)
		R.add_reagent(get_unrestricted_random_reagent_id(), 10)
		R.reaction(H, REAGENT_INGEST)
		R.trans_to(H, 10)
	target.visible_message("<span class='warning'>[target] consumes 5 pills rapidly!</span>")

/datum/tarot/reversed/the_devil
	name = "XV - The Devil?"
	desc = "Bask in the light of your mercy."
	card_icon = "the_devil?"

/datum/tarot/reversed/the_devil/activate(mob/living/target)
	var/obj/item/grenade/clusterbuster/i_hate_nians = new(get_turf(target))
	i_hate_nians.prime()

/datum/tarot/reversed/the_tower
	name = "XVI - The Tower?"
	desc = "Creation brings destruction."
	card_icon = "the_tower?"

/datum/tarot/reversed/the_tower/activate(mob/living/target)
	for(var/turf/T in RANGE_TURFS(9, target))
		if(locate(/mob/living) in T)
			continue
		if(istype(T, /turf/simulated/wall/indestructible))
			continue
		if(prob(66))
			continue
		T.ChangeTurf(/turf/simulated/mineral/random/labormineral)

/datum/tarot/reversed/the_stars
	name = "XVII - The Stars?"
	desc = "May your loss bring fortune."
	card_icon = "the_stars?"

/datum/tarot/reversed/the_stars/activate(mob/living/target) //Heavy clone damage hit, but gain 2 cards. Not teathered to the card producer. Could lead to card stacking, but would require the sun to fix easily
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/H = target
	H.adjustCloneLoss(50)
	for(var/obj/item/organ/external/E in shuffle(H.bodyparts))
		switch(rand(1,3))
			if(1)
				E.fracture()
			if(2)
				E.cause_internal_bleeding()
			if(3)
				E.cause_burn_wound()
		break // I forgot the break the first time. Very funny.

	H.drop_l_hand()
	H.drop_r_hand()
	var/obj/item/magic_tarot_card/MTC = new /obj/item/magic_tarot_card(get_turf(src))
	var/obj/item/magic_tarot_card/MPC = new /obj/item/magic_tarot_card(get_turf(src))
	H.put_in_hands(MTC)
	H.put_in_hands(MPC)

/datum/tarot/reversed/the_moon
	name = "XVIII - The Moon?"
	desc = "May you remember lost memories."
	card_icon = "the_moon?"

/datum/tarot/reversed/the_moon/activate(mob/living/target)
	for(var/mob/living/L in view(5, target)) //Shorter range as this kinda can give away antagonists, though that is also funny.
		target.mind.show_memory(L, 0) //Safe code? Bank accounts? PDA codes? It's yours my friend, as long as you have enough tarots

/datum/tarot/reversed/the_sun
	name = "XIX - The Sun?"
	desc = "May the darkness swallow all around you."
	card_icon = "the_sun?"

/datum/tarot/reversed/the_sun/activate(mob/living/target)
	target.apply_status_effect(STATUS_EFFECT_REVERSED_SUN)

/datum/tarot/reversed/judgement
	name = "XX - Judgement?"
	desc = "May you redeem those found wanting" //Who wants more, but ghosts for something interesting
	card_icon = "judgement?"

/datum/tarot/reversed/judgement/activate(mob/living/target)
	var/datum/event_container/EC = SSevents.event_containers[EVENT_LEVEL_MODERATE]
	var/decrease = 5 MINUTES
	EC.next_event_time -= decrease
	log_and_message_admins("decreased timer for [GLOB.severity_to_string[EC.severity]] events by 5 minutes by use of a [src].")

/datum/tarot/reversed/the_world
	name = "XXI - The World?"
	desc = "Step into the abyss."
	card_icon = "the_world?"

/datum/tarot/reversed/the_world/activate(mob/living/target)
	var/list/L = list()
	for(var/turf/T in get_area_turfs(/area/mine/outpost)) //Lavaland is the abyss, but also too hot to send people too. Mining base should be fair!
		if(is_blocked_turf(T))
			continue
		L.Add(T)

	if(!length(L))
		to_chat(target, "<span class='warning'>Hmm. No base? A miner issue.</span>")
		return

	target.forceMove(pick(L))
	to_chat(target, "<span class='userdanger'>You are abruptly pulled through space!</span>")
