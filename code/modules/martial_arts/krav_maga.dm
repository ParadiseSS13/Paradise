/datum/martial_art/krav_maga
	name = "Krav Maga"
	var/datum/action/neck_chop/neckchop = new/datum/action/neck_chop()
	var/datum/action/leg_sweep/legsweep = new/datum/action/leg_sweep()
	var/datum/action/lung_punch/lungpunch = new/datum/action/lung_punch()

/datum/action/neck_chop
	name = "Neck Chop - Injures the neck, stopping the victim from speaking for a while."
	button_icon_state = "neckchop"

/datum/action/neck_chop/Trigger()
	if(owner.incapacitated())
		to_chat(owner, "<span class='warning'>You can't use Krav Maga while you're incapacitated.</span>")
		return
	to_chat(owner, "<b><i>Your next attack will be a Neck Chop.</i></b>")
	owner.visible_message("<span class='danger'>[owner] assumes the Neck Chop stance!</span>")
	var/mob/living/carbon/human/H = owner
	H.martial_art.streak = "neck_chop"

/datum/action/leg_sweep
	name = "Leg Sweep - Trips the victim, rendering them prone and unable to move for a short time."
	button_icon_state = "legsweep"

/datum/action/leg_sweep/Trigger()
	if(owner.incapacitated())
		to_chat(owner, "<span class='warning'>You can't use Krav Maga while you're incapacitated.</span>")
		return
	to_chat(owner, "<b><i>Your next attack will be a Leg Sweep.</i></b>")
	owner.visible_message("<span class='danger'>[owner] assumes the Leg Sweep stance!</span>")
	var/mob/living/carbon/human/H = owner
	H.martial_art.streak = "leg_sweep"

/datum/action/lung_punch//referred to internally as 'quick choke'
	name = "Lung Punch - Delivers a strong punch just above the victim's abdomen, constraining the lungs. The victim will be unable to breathe for a short time."
	button_icon_state = "lungpunch"

/datum/action/lung_punch/Trigger()
	if(owner.incapacitated())
		to_chat(owner, "<span class='warning'>You can't use Krav Maga while you're incapacitated.</span>")
		return
	to_chat(owner, "<b><i>Your next attack will be a Lung Punch.</i></b>")
	owner.visible_message("<span class='danger'>[owner] assumes the Lung Punch stance!</span>")
	var/mob/living/carbon/human/H = owner
	H.martial_art.streak = "quick_choke"//internal name for lung punch

/datum/martial_art/krav_maga/teach(var/mob/living/carbon/human/H,var/make_temporary=0)
	..()
	to_chat(H, "<span class = 'userdanger'>You know the arts of Krav Maga!</span>")
	to_chat(H, "<span class = 'danger'>Place your cursor over a move at the top of the screen to see what it does.</span>")
	neckchop.Grant(H)
	legsweep.Grant(H)
	lungpunch.Grant(H)

/datum/martial_art/krav_maga/remove(var/mob/living/carbon/human/H)
	..()
	to_chat(H, "<span class = 'userdanger'>You suddenly forget the arts of Krav Maga...</span>")
	neckchop.Remove(H)
	legsweep.Remove(H)
	lungpunch.Remove(H)

/datum/martial_art/krav_maga/proc/check_streak(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	switch(streak)
		if("neck_chop")
			streak = ""
			neck_chop(A,D)
			return 1
		if("leg_sweep")
			streak = ""
			leg_sweep(A,D)
			return 1
		if("quick_choke")//is actually lung punch
			streak = ""
			quick_choke(A,D)
			return 1
	return 0

/datum/martial_art/krav_maga/proc/leg_sweep(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	if(D.stat || D.IsWeakened())
		return 0
	D.visible_message("<span class='warning'>[A] leg sweeps [D]!</span>", \
					  	"<span class='userdanger'>[A] leg sweeps you!</span>")
	playsound(get_turf(A), 'sound/effects/hit_kick.ogg', 50, 1, -1)
	D.apply_damage(5, BRUTE)
	D.Weaken(2)
	return 1

/datum/martial_art/krav_maga/proc/quick_choke(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)//is actually lung punch
	D.visible_message("<span class='warning'>[A] pounds [D] on the chest!</span>", \
				  	"<span class='userdanger'>[A] slams your chest! You can't breathe!</span>")
	playsound(get_turf(A), 'sound/effects/hit_punch.ogg', 50, 1, -1)
	D.AdjustLoseBreath(5)
	D.adjustOxyLoss(10)
	return 1

/datum/martial_art/krav_maga/proc/neck_chop(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	D.visible_message("<span class='warning'>[A] karate chops [D]'s neck!</span>", \
				  	"<span class='userdanger'>[A] karate chops your neck, rendering you unable to speak for a short time!</span>")
	playsound(get_turf(A), 'sound/effects/hit_punch.ogg', 50, 1, -1)
	D.apply_damage(5, BRUTE)
	D.AdjustSilence(10)
	return 1

datum/martial_art/krav_maga/grab_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	if(check_streak(A,D))
		return 1
	..()

/datum/martial_art/krav_maga/harm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	if(check_streak(A,D))
		return 1
	add_attack_logs(A, D, "Melee attacked with [src]")
	var/picked_hit_type = pick("punches", "kicks")
	var/bonus_damage = 10
	if(D.IsWeakened() || D.resting || D.lying)
		bonus_damage += 5
		picked_hit_type = "stomps on"
	D.apply_damage(bonus_damage, BRUTE)
	if(picked_hit_type == "kicks" || picked_hit_type == "stomps")
		A.do_attack_animation(D, ATTACK_EFFECT_KICK)
		playsound(get_turf(D), 'sound/effects/hit_kick.ogg', 50, 1, -1)
	else
		A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
		playsound(get_turf(D), 'sound/effects/hit_punch.ogg', 50, 1, -1)
	D.visible_message("<span class='danger'>[A] [picked_hit_type] [D]!</span>", \
					  "<span class='userdanger'>[A] [picked_hit_type] you!</span>")
	return 1

/datum/martial_art/krav_maga/disarm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	if(check_streak(A,D))
		return 1
	if(prob(60))
		if(D.hand)
			if(istype(D.l_hand, /obj/item))
				var/obj/item/I = D.l_hand
				if(D.drop_item())
					A.put_in_hands(I)
		else
			if(istype(D.r_hand, /obj/item))
				var/obj/item/I = D.r_hand
				if(D.drop_item())
					A.put_in_hands(I)
		D.visible_message("<span class='danger'>[A] has disarmed [D]!</span>", \
							"<span class='userdanger'>[A] has disarmed [D]!</span>")
		playsound(D, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
	else
		D.visible_message("<span class='danger'>[A] attempted to disarm [D]!</span>", \
							"<span class='userdanger'>[A] attempted to disarm [D]!</span>")
		playsound(D, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
	return 1

//Krav Maga Gloves

/obj/item/clothing/gloves/color/black/krav_maga
	var/datum/martial_art/krav_maga/style = new
	can_be_cut = FALSE
	resistance_flags = NONE

/obj/item/clothing/gloves/color/black/krav_maga/equipped(mob/user, slot)
	if(!ishuman(user))
		return
	if(slot == slot_gloves)
		var/mob/living/carbon/human/H = user
		style.teach(H,1)

/obj/item/clothing/gloves/color/black/krav_maga/dropped(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(slot_gloves) == src)
		style.remove(H)

/obj/item/clothing/gloves/color/black/krav_maga/sec//more obviously named, given to sec
	name = "krav maga gloves"
	desc = "These gloves can teach you to perform Krav Maga using nanochips."
	icon_state = "fightgloves"
	item_state = "fightgloves"
