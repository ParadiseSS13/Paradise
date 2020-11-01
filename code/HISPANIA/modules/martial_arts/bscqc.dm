#define PRESSURE_COMBO_BS "DG"

/datum/martial_art/bscqc
	name = "Blue Flame"
	help_verb = /mob/living/carbon/human/proc/BSCQC_help
	block_chance = 50
	var/restraining = 0
	var/current_target

/datum/martial_art/bscqc/proc/add_to_streak(var/element,var/mob/living/carbon/human/D)
	if(D != current_target)
		current_target = D
		streak = ""
	streak = streak+element
	if(length(streak) > max_streak_length)
		streak = copytext(streak,2)
	return

/datum/martial_art/bscqc/under_siege
	name = "The Ancient Blue Flame"

/datum/martial_art/bscqc/proc/drop_restraining()
	restraining = FALSE

/datum/martial_art/bscqc/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	if(findtext(streak, PRESSURE_COMBO_BS))
		streak = ""
		Pressure(A, D)
		return TRUE

/datum/martial_art/bscqc/proc/Pressure(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	D.visible_message("<span class='warning'>[A] forces their arm on [D]'s neck!</span>")
	D.adjustStaminaLoss(34)
	playsound(get_turf(A), 'sound/weapons/cqchit1.ogg', 50, 1, -1)
	add_attack_logs(A, D, "Melee attacked with blue-art [src] : Pressure", ATKLOG_ALL)
	return TRUE

/datum/martial_art/bscqc/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	add_to_streak("G", D)
	if(check_streak(A, D))
		return TRUE
	var/obj/item/grab/G = D.grabbedby(A, 1)
	if(G)
		add_attack_logs(A, D, "Melee attacked with blue-art [src] : grabbed", ATKLOG_ALL)
	return TRUE

/datum/martial_art/bscqc/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	add_to_streak("H", D)
	if(check_streak(A, D))
		return TRUE
	add_attack_logs(A, D, "Melee attacked with blue-art [src]", ATKLOG_ALL)
	A.do_attack_animation(D)
	var/picked_hit_type = pick("kicks","neck chopped", "gut punched", "Big Bossed")
	var/bonus_damage = 5
	if(D.weakened || D.resting || D.lying)
		bonus_damage += 2
		picked_hit_type = "stomps on"
	D.apply_damage(bonus_damage, BRUTE)
	if(picked_hit_type == "kicks" || picked_hit_type == "stomps on")
		playsound(get_turf(D), 'sound/weapons/cqchit2.ogg', 50, 1, -1)
	else
		playsound(get_turf(D), 'sound/weapons/cqchit1.ogg', 50, 1, -1)
	D.visible_message("<span class='danger'>[A] [picked_hit_type] [D]!</span>", \
					  "<span class='userdanger'>[A] [picked_hit_type] you!</span>")
	add_attack_logs(A, D, "Melee attacked with blue-art [src] : [picked_hit_type]", ATKLOG_ALL)
	return TRUE

/datum/martial_art/bscqc/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	add_to_streak("D", D)
	var/obj/item/I
	if(check_streak(A, D))
		return TRUE
	if(prob(25))
		if(!D.stat || !D.weakened || !restraining)
			I = D.get_active_hand()
			D.visible_message("<span class='warning'>[A] strikes [D]'s jaw with their hand!</span>", \
								"<span class='userdanger'>[A] strikes your jaw, disorienting you!</span>")
			playsound(get_turf(D), 'sound/weapons/cqchit1.ogg', 50, 1, -1)
			D.drop_item()
			if(I && D.drop_item())
				A.put_in_hands(I)
			D.Jitter(2)
			D.apply_damage(3, BRUTE)
	else
		D.visible_message("<span class='danger'>[A] attempted to disarm [D]!</span>", "<span class='userdanger'>[A] attempted to disarm [D]!</span>")
		playsound(D, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
	add_attack_logs(A, D, "Melee attacked with blue-art [src] : Disarmed [I ? " grabbing \the [I]" : ""]", ATKLOG_ALL)
	return TRUE

/mob/living/carbon/human/proc/BSCQC_help()
	set name = "Remember The Lessons"
	set desc = "You try to remember some of the basics of the blue flame."
	set category = "Blue Flame"
	to_chat(usr, "<b><i>You try to remember some of the ancient blue flame movements.</i></b>")
	to_chat(usr, "<span class='notice'>Pressure</span>: Disarm Grab. Moderate stamina damage.")
	to_chat(usr, "<span class='notice'>Disarm</span>: Disarming people you have a chance to take the active hand item.")
	to_chat(usr, "<b><i>In addition, by having your throw mode on when being attacked, you enter an active defense mode where you have a chance to block and sometimes even counter attacks done to you.</i></b>")
