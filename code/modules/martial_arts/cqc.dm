#define SLAM_COMBO "HG"
#define KICK_COMBO "HH"
#define RESTRAIN_COMBO "GG"
#define PRESSURE_COMBO "DG"
#define CONSECUTIVE_COMBO "DDH"

/datum/martial_art/cqc
	name = "CQC"
	help_verb = /mob/living/carbon/human/proc/CQC_help
	block_chance = 75

/datum/martial_art/cqc/can_use(mob/living/carbon/human/H)
	if(istype(H.gloves, /obj/item/clothing/gloves/fingerless/rapid))
		return FALSE
	return ..()

/datum/martial_art/cqc/proc/drop_restraining()
	restraining = FALSE

/datum/martial_art/cqc/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	if(findtext(streak, SLAM_COMBO))
		streak = ""
		Slam(A, D)
		return TRUE
	if(findtext(streak, KICK_COMBO))
		streak = ""
		Kick(A, D)
		return TRUE
	if(findtext(streak, RESTRAIN_COMBO))
		streak = ""
		Restrain(A, D)
		return TRUE
	if(findtext(streak, PRESSURE_COMBO))
		streak = ""
		Pressure(A, D)
		return TRUE
	if(findtext(streak, CONSECUTIVE_COMBO))
		streak = ""
		Consecutive(A, D)
	return FALSE

/datum/martial_art/cqc/proc/Slam(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	if(!D.stat || !D.weakened)
		D.visible_message("<span class='warning'>[A] slams [D] into the ground!</span>", \
						  	"<span class='userdanger'>[A] slams you into the ground!</span>")
		playsound(get_turf(A), 'sound/weapons/slam.ogg', 50, 1, -1)
		D.apply_damage(10, BRUTE)
		D.Weaken(6)
		add_attack_logs(A, D, "Melee attacked with martial-art [src] :  Slam", ATKLOG_ALL)
	else //if target can't be slammed, do a regular grab attack then clear the streak
		streak = ""
		grab_act(A, D)
		streak = ""
	return TRUE

/datum/martial_art/cqc/proc/Kick(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	if(!D.stat || !D.weakened)
		D.visible_message("<span class='warning'>[A] kicks [D] back!</span>", \
							"<span class='userdanger'>[A] kicks you back!</span>")
		playsound(get_turf(A), 'sound/weapons/cqchit1.ogg', 50, 1, -1)
		var/atom/throw_target = get_edge_target_turf(D, A.dir)
		D.throw_at(throw_target, 1, 14, A)
		D.apply_damage(10, BRUTE)
		add_attack_logs(A, D, "Melee attacked with martial-art [src] : Kick", ATKLOG_ALL)
		if(D.weakened && !D.stat)
			D.visible_message("<span class='warning'>[A] kicks [D]'s head, knocking [D.p_them()] out!</span>", \
						  		"<span class='userdanger'>[A] kicks your head, knocking you out!</span>")
			playsound(get_turf(A), 'sound/weapons/genhit1.ogg', 50, 1, -1)
			D.SetSleeping(15)
			D.adjustBrainLoss(15, 150)
			add_attack_logs(A, D, "Knocked out with martial-art [src] : Kick", ATKLOG_ALL)
	else //if target can't be kicked, do a regular harm attack then clear the streak
		streak = ""
		harm_act(A, D)
		streak = ""
	return TRUE

/datum/martial_art/cqc/proc/Pressure(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	D.visible_message("<span class='warning'>[A] forces their arm on [D]'s neck!</span>")
	D.adjustStaminaLoss(60)
	playsound(get_turf(A), 'sound/weapons/cqchit1.ogg', 50, 1, -1)
	add_attack_logs(A, D, "Melee attacked with martial-art [src] : Pressure", ATKLOG_ALL)
	return TRUE

/datum/martial_art/cqc/proc/Restrain(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(restraining)
		return
	if(!can_use(A))
		return FALSE
	if(!D.stat)
		D.visible_message("<span class='warning'>[A] locks [D] into a restraining position!</span>", \
							"<span class='userdanger'>[A] locks you into a restraining position!</span>")
		D.adjustStaminaLoss(20)
		D.Stun(5)
		restraining = TRUE
		addtimer(CALLBACK(src, .proc/drop_restraining), 50, TIMER_UNIQUE)
		add_attack_logs(A, D, "Melee attacked with martial-art [src] : Restrain", ATKLOG_ALL)
	return TRUE

/datum/martial_art/cqc/proc/Consecutive(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	if(!D.stat)
		D.visible_message("<span class='warning'>[A] strikes [D]'s abdomen, neck and back consecutively</span>", \
							"<span class='userdanger'>[A] strikes your abdomen, neck and back consecutively!</span>")
		playsound(get_turf(D), 'sound/weapons/cqchit2.ogg', 50, 1, -1)
		var/obj/item/I = D.get_active_hand()
		if(I && D.drop_item())
			A.put_in_hands(I)
		D.adjustStaminaLoss(50)
		D.apply_damage(25, BRUTE)
		add_attack_logs(A, D, "Melee attacked with martial-art [src] : Consecutive", ATKLOG_ALL)
	else //if target can't be hit, do a regular harm attack then clear the streak
		streak = ""
		harm_act(A, D)
		streak = ""
	return TRUE

/datum/martial_art/cqc/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	add_to_streak("G", D)
	if(check_streak(A, D))
		return TRUE
	var/obj/item/grab/G = D.grabbedby(A, 1)
	if(G)
		G.state = GRAB_AGGRESSIVE //Instant aggressive grab
	return TRUE

/datum/martial_art/cqc/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	add_to_streak("H", D)
	if(check_streak(A, D))
		return TRUE
	A.do_attack_animation(D)
	var/picked_hit_type = pick("CQC'd", "neck chopped", "gut punched")
	var/bonus_damage = 13
	if(D.weakened || D.resting || D.lying)
		bonus_damage += 5
		picked_hit_type = "stomps on"
	D.apply_damage(bonus_damage, BRUTE)
	if(picked_hit_type == "kicks" || picked_hit_type == "stomps on")
		playsound(get_turf(D), 'sound/weapons/cqchit2.ogg', 50, 1, -1)
	else
		playsound(get_turf(D), 'sound/weapons/cqchit1.ogg', 50, 1, -1)
	D.visible_message("<span class='danger'>[A] [picked_hit_type] [D]!</span>", \
					  "<span class='userdanger'>[A] [picked_hit_type] you!</span>")
	add_attack_logs(A, D, "Melee attacked with martial-art [src]", ATKLOG_ALL)
	if(A.resting && !D.stat && !D.weakened)
		D.visible_message("<span class='warning'>[A] leg sweeps [D]!", \
							"<span class='userdanger'>[A] leg sweeps you!</span>")
		playsound(get_turf(A), 'sound/effects/hit_kick.ogg', 50, 1, -1)
		D.apply_damage(10, BRUTE)
		D.Weaken(3)
		add_attack_logs(A, D, "Melee attacked with martial-art [src] : Leg sweep", ATKLOG_ALL)
	return TRUE

/datum/martial_art/cqc/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	add_to_streak("D", D)
	if(check_streak(A, D))
		return TRUE
	if(!restraining)
		D.visible_message("<span class='warning'>[A] strikes [D]'s jaw with their hand!</span>", \
							"<span class='userdanger'>[A] strikes your jaw, disorienting you!</span>")
		playsound(get_turf(D), 'sound/weapons/cqchit1.ogg', 50, 1, -1)
		D.Jitter(2)
		D.apply_damage(5, BRUTE)
		add_attack_logs(A, D, "Melee attacked with martial-art [src] : Disarm", ATKLOG_ALL)
	if(restraining)
		D.visible_message("<span class='danger'>[A] puts [D] into a chokehold!</span>", \
							"<span class='userdanger'>[A] puts you into a chokehold!</span>")
		D.SetSleeping(20)
		restraining = FALSE
		add_attack_logs(A, D, "Knocked out with martial-art [src] : Choke hold", ATKLOG_ALL)
	else
		restraining = FALSE
		return FALSE
	return TRUE

/mob/living/carbon/human/proc/CQC_help()
	set name = "Remember The Basics"
	set desc = "You try to remember some of the basics of CQC."
	set category = "CQC"
	to_chat(usr, "<b><i>You try to remember some of the basics of CQC.</i></b>")

	to_chat(usr, "<span class='notice'>Slam</span>: Harm Grab. Slam opponent into the ground, knocking them down.")
	to_chat(usr, "<span class='notice'>CQC Kick</span>: Harm Harm. Knocks opponent away. Knocks out stunned or knocked down opponents.")
	to_chat(usr, "<span class='notice'>Restrain</span>: Grab Switch Hand Grab. Locks opponent into a restraining position, stunning them.")
	to_chat(usr, "<span class='notice'>Choke Hold</span>: Restrain Disarm. Knocks out an opponent you have restrained.")
	to_chat(usr, "<span class='notice'>Pressure</span>: Disarm Grab. Decent stamina damage.")
	to_chat(usr, "<span class='notice'>Consecutive CQC</span>: Disarm Disarm Harm. Mainly offensive move, huge damage and decent stamina damage.")

	to_chat(usr, "<b><i>In addition, by having your throw mode on when being attacked, you enter an active defense mode where you have a chance to block and sometimes even counter melee attacks done to you.</i></b>")