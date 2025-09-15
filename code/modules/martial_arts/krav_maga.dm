/* CONTENTS:
* .1 KRAV MAGA MARTIAL ART
* .2 KRAV MAGA GLOVES
*/
/datum/martial_art/krav_maga
	name = "Krav Maga"
	weight = 7 //Higher weight, since you can choose to put on or take off the gloves
	var/datum/action/neck_chop/neckchop = new/datum/action/neck_chop()
	var/datum/action/leg_sweep/legsweep = new/datum/action/leg_sweep()
	var/datum/action/lung_punch/lungpunch = new/datum/action/lung_punch()
	var/datum/action/neutral_stance/neutral = new/datum/action/neutral_stance()
	can_horizontally_grab = FALSE

/datum/action/neutral_stance
	name = "Neutral Stance - You relax, cancelling your last Krav Maga stance attack."
	button_icon_state = "neutralstance"

/datum/action/neutral_stance/Trigger(left_click)
	var/mob/living/carbon/human/H = owner
	if(!H.mind.martial_art.in_stance)
		to_chat(owner, "<b><i>You cannot cancel an attack you haven't prepared!</i></b>")
		return
	to_chat(owner, "<b><i>You cancel your prepared attack.</i></b>")
	owner.visible_message("<span class='danger'>[owner] relaxes [owner.p_their()] stance.</span>")
	H.mind.martial_art.combos.Cut()
	H.mind.martial_art.in_stance = FALSE

/datum/action/neck_chop
	name = "Neck Chop - Injures the neck, stopping the victim from speaking for a while."
	button_icon_state = "neckchop"

/datum/action/neck_chop/Trigger(left_click)
	var/mob/living/carbon/human/H = owner //This is a janky solution, but I want to refactor krav anyway and un-jank this (written in may 2023)
	if(!istype(H.mind.martial_art, /datum/martial_art/krav_maga))
		to_chat(owner, "<span class='warning'>You don't know how to do that right now.</span>")
		return
	if(owner.incapacitated())
		to_chat(owner, "<span class='warning'>You can't use Krav Maga while you're incapacitated.</span>")
		return
	to_chat(owner, "<b><i>Your next attack will be a Neck Chop.</i></b>")
	owner.visible_message("<span class='danger'>[owner] assumes the Neck Chop stance!</span>")
	H.mind.martial_art.combos.Cut()
	H.mind.martial_art.combos.Add(/datum/martial_combo/krav_maga/neck_chop)
	H.mind.martial_art.reset_combos()
	H.mind.martial_art.in_stance = TRUE
/datum/action/leg_sweep
	name = "Leg Sweep - Trips the victim, rendering them prone and unable to move for a short time."
	button_icon_state = "legsweep"

/datum/action/leg_sweep/Trigger(left_click)
	var/mob/living/carbon/human/H = owner
	if(!istype(H.mind.martial_art, /datum/martial_art/krav_maga))
		to_chat(owner, "<span class='warning'>You don't know how to do that right now.</span>")
		return
	if(owner.incapacitated())
		to_chat(owner, "<span class='warning'>You can't use Krav Maga while you're incapacitated.</span>")
		return
	if(!owner.get_num_legs())
		to_chat(owner, "<span class='warning'>You can't leg sweep someone if you have no legs.</span>")
		return
	if(HAS_TRAIT(owner, TRAIT_PARAPLEGIC))
		to_chat(owner, "<span class='warning'>You can't leg sweep someone without working legs.</span>")
		return
	to_chat(owner, "<b><i>Your next attack will be a Leg Sweep.</i></b>")
	owner.visible_message("<span class='danger'>[owner] assumes the Leg Sweep stance!</span>")
	H.mind.martial_art.combos.Cut()
	H.mind.martial_art.combos.Add(/datum/martial_combo/krav_maga/leg_sweep)
	H.mind.martial_art.reset_combos()
	H.mind.martial_art.in_stance = TRUE

/datum/action/lung_punch//referred to internally as 'quick choke'
	name = "Lung Punch - Delivers a strong punch just above the victim's abdomen, constraining the lungs. The victim will be unable to breathe for a short time."
	button_icon_state = "lungpunch"

/datum/action/lung_punch/Trigger(left_click)
	var/mob/living/carbon/human/H = owner
	if(!istype(H.mind.martial_art, /datum/martial_art/krav_maga))
		to_chat(owner, "<span class='warning'>You don't know how to do that right now.</span>")
		return
	if(owner.incapacitated())
		to_chat(owner, "<span class='warning'>You can't use Krav Maga while you're incapacitated.</span>")
		return
	to_chat(owner, "<b><i>Your next attack will be a Lung Punch.</i></b>")
	owner.visible_message("<span class='danger'>[owner] assumes the Lung Punch stance!</span>")
	H.mind.martial_art.combos.Cut()
	H.mind.martial_art.combos.Add(/datum/martial_combo/krav_maga/lung_punch)
	H.mind.martial_art.reset_combos()
	H.mind.martial_art.in_stance = TRUE

/datum/martial_art/krav_maga/teach(mob/living/carbon/human/H, make_temporary=0)
	..()
	if(HAS_TRAIT(H, TRAIT_PACIFISM))
		to_chat(H, "<span class='warning'>The arts of Krav Maga echo uselessly in your head, the thought of their violence repulsive to you!</span>")
		return
	to_chat(H, "<span class = 'userdanger'>You know the arts of Krav Maga!</span>")
	to_chat(H, "<span class = 'danger'>Place your cursor over a move at the top of the screen to see what it does.</span>")
	neutral.Grant(H)
	neckchop.Grant(H)
	legsweep.Grant(H)
	lungpunch.Grant(H)

/datum/martial_art/krav_maga/remove(mob/living/carbon/human/H)
	..()
	to_chat(H, "<span class = 'userdanger'>You suddenly forget the arts of Krav Maga...</span>")
	neutral.Remove(H)
	neckchop.Remove(H)
	legsweep.Remove(H)
	lungpunch.Remove(H)

/datum/martial_art/krav_maga/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	add_attack_logs(A, D, "Melee attacked with [src]")
	var/picked_hit_type = pick("punches", "kicks")
	var/bonus_damage = 10
	if(IS_HORIZONTAL(D))
		bonus_damage += 5
		picked_hit_type = "stomps on"
	if(picked_hit_type == "kicks" || IS_HORIZONTAL(D))
		A.do_attack_animation(D, ATTACK_EFFECT_KICK)
		playsound(get_turf(D), 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
	else
		A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
		playsound(get_turf(D), 'sound/effects/hit_punch.ogg', 50, TRUE, -1)
	D.visible_message("<span class='danger'>[A] [picked_hit_type] [D]!</span>", \
					"<span class='userdanger'>[A] [picked_hit_type] you!</span>")
	D.apply_damage(bonus_damage, BRUTE)
	return TRUE

/datum/martial_art/krav_maga/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	A.do_attack_animation(D, ATTACK_EFFECT_DISARM)
	var/obj/item/I = D.get_active_hand()
	if(prob(60) && D.drop_item_to_ground(I))
		if(!(QDELETED(I) || (I.flags & ABSTRACT)))
			A.put_in_hands(I)
		D.visible_message("<span class='danger'>[A] has disarmed [D]!</span>", \
							"<span class='userdanger'>[A] has disarmed [D]!</span>")
		playsound(D, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
	else
		D.visible_message("<span class='danger'>[A] attempted to disarm [D]!</span>", \
							"<span class='userdanger'>[A] attempted to disarm [D]!</span>")
		playsound(D, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)
	return TRUE

// Krav Maga gloves
/obj/item/clothing/gloves/color/black/krav_maga
	can_be_cut = FALSE
	var/datum/martial_art/krav_maga/style

/obj/item/clothing/gloves/color/black/krav_maga/Initialize(mapload)
	. = ..()
	style = new()

/obj/item/clothing/gloves/color/black/krav_maga/equipped(mob/user, slot)
	if(!ishuman(user))
		return
	if(slot == ITEM_SLOT_GLOVES)
		var/mob/living/carbon/human/H = user
		style.teach(H, TRUE)

/obj/item/clothing/gloves/color/black/krav_maga/dropped(mob/user)
	..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(ITEM_SLOT_GLOVES) == src)
		style.remove(H)

// Warden gloves
/obj/item/clothing/gloves/color/black/krav_maga/sec
	name = "Krav Maga gloves"
	desc = "These gloves can teach you to perform Krav Maga using nanochips for as long as you're wearing them."
	icon_state = "fightgloves"
	dyeable = FALSE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/clothing/gloves/color/black/krav_maga/sec/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/high_value_item)

/obj/item/clothing/gloves/color/black/krav_maga/sec/examine_more(mob/user)
	..()
	. = list()
	. += "These gloves are experimental combat gear developed by Nanotrasen R&D, capable of teaching the wearer the art of Krav Maga without prior training."
	. += ""
	. += "They function using embedded nanochips that host a non-sapient machine intelligence. Probes in the gloves allow the on-board intelligence limited control of the somatic nervous system, \
	allowing it to direct the wearer's body in the correct manner to execute the selected move when it detects the corresponding activation motion."
	. += ""
	. += "Most users are not aware of their body being puppeted in this manner - it feels like a reflexive movement. Particularly observant individuals or unarmed combat specialists trained in a different martial art \
	do report noticing their limbs being redirected, but they generally get used to it after sufficient exposure."
	. += ""
	. += "Because it is the gloves, and not the user that is handling the martial art, users return to previous proficiency when the gloves are removed."

// Syndicate Krav Maga gloves
/obj/item/clothing/gloves/color/black/krav_maga/combat
	name = "Combat gloves plus"
	desc = "These combat gloves have been upgraded with nanochips that teach the wearer Krav Maga."
	icon_state = "combat"
	inhand_icon_state = "swat_gl"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	strip_delay = 8 SECONDS
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 200, ACID = 50)

/obj/item/clothing/gloves/color/black/krav_maga/combat/examine_more(mob/user)
	..()
	. = list()
	. += "These gloves are made using similar gloves stolen from Nanotrasen. The Syndicate has extensively dissected several stolen sets of such gloves, but the method of manufacture cannot be gleaned directly from them."
	. += ""
	. += "In light of this, Syndicate researchers simply transplanted the working components from the stolen gloves into proper combat gloves and declared it a sufficient upgrade. Because of this method of manufacture, \
	these gloves are in very short supply - each set requiring one to be stolen from Nanotrasen to make."
