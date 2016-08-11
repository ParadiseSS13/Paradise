#define DEVIL_HANDS_LAYER 1
#define DEVIL_HEAD_LAYER 2
#define DEVIL_TOTAL_LAYERS 2


/mob/living/carbon/true_devil
	name = "True Devil"
	desc = "A pile of infernal energy, taking a vaguely humanoid form."
	icon = 'icons/mob/32x64.dmi'
	icon_state = "true_devil"
	gender = NEUTER
	health = 350
	maxHealth = 350
	ventcrawler = 0
	density = 1
	pass_flags =  0
	var/ascended = 0
	sight = (SEE_TURFS | SEE_OBJS)
	status_flags = CANPUSH
	languages_spoken = ALL //The devil speaks all languages meme
	languages_understood = ALL //The devil speaks all languages meme
	mob_size = MOB_SIZE_LARGE
	var/mob/living/oldform
	var/list/devil_overlays[DEVIL_TOTAL_LAYERS]

/mob/living/carbon/true_devil/New()
	internal_organs += new /obj/item/organ/brain/
	for(var/X in internal_organs)
		var/obj/item/organ/I = X
		I.Insert(src)
	..()


/mob/living/carbon/true_devil/proc/convert_to_archdevil()
	maxHealth = 5000 // not an IMPOSSIBLE amount, but still near impossible.
	ascended = 1
	health = maxHealth
	icon_state = "arch_devil"

/mob/living/carbon/true_devil/proc/set_name()
	name = mind.devilinfo.truename
	real_name = name

/mob/living/carbon/true_devil/Login()
	..()
	mind.announceDevilLaws()
	var/obj_count = 1
		to_chat(current, "\blue Your current objectives:")
		for(var/datum/objective/objective in objectives)
			to_chat(current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
			obj_count++


/mob/living/carbon/true_devil/death(gibbed)
	stat = DEAD
	..(gibbed)
	drop_l_hand()
	drop_r_hand()
	spawn (0)
		mind.devilinfo.beginResurrectionCheck(src)


/mob/living/carbon/true_devil/examine(mob/user)
	var/msg = "<span class='info'>*---------*\nThis is \icon[src] <b>[src]</b>!\n"

	//Left hand items
	if(l_hand && !(l_hand.flags&ABSTRACT))
		if(l_hand.blood_DNA)
			msg += "<span class='warning'>It is holding \icon[l_hand] [l_hand.gender==PLURAL?"some":"a"] blood-stained [l_hand.name] in its left hand!</span>\n"
		else
			msg += "It is holding \icon[l_hand] \a [l_hand] in its left hand.\n"

	//Right hand items
	if(r_hand && !(r_hand.flags&ABSTRACT))
		if(r_hand.blood_DNA)
			msg += "<span class='warning'>It is holding \icon[r_hand] [r_hand.gender==PLURAL?"some":"a"] blood-stained [r_hand.name] in its right hand!</span>\n"
		else
			msg += "It is holding \icon[r_hand] \a [r_hand] in its right hand.\n"

	//Braindead
	if(!client && stat != DEAD)
		msg += "The devil seems to be in deep contemplation.\n"

	//Damaged
	if(stat == DEAD)
		msg += "<span class='deadsay'>The hellfire seems to have been extinguished, for now at least.</span>\n"
	else if(health < (maxHealth/10))
		msg += "<span class='warning'>You can see hellfire inside of it's gaping wounds.</span>\n"
	else if(health < (maxHealth/2))
		msg += "<span class='warning'>You can see hellfire inside of it's wounds.</span>\n"
	msg += "*---------*</span>"
	user << msg


/mob/living/carbon/true_devil/IsAdvancedToolUser()
	return 1

/mob/living/carbon/true_devil/canUseTopic(atom/movable/M, be_close = 0)
	if(incapacitated())
		return 0
	if(be_close && !in_range(M, src))
		return 0
	return 1

/mob/living/carbon/true_devil/assess_threat()
	return 666

/mob/living/carbon/true_devil/flash_eyes(intensity = 1, override_blindness_check = 0, affect_silicon = 0)
	if(mind && has_bane(BANE_LIGHT))
		mind.disrupt_spells(-500)
		return ..() //flashes don't stop devils UNLESS it's their bane.


/mob/living/carbon/true_devil/attacked_by(obj/item/I, mob/living/user, def_zone)
	var/weakness = check_weakness(I, user)
	apply_damage(I.force * weakness, I.damtype, def_zone)
	var/message_verb = ""
	if(I.attack_verb && I.attack_verb.len)
		message_verb = "[pick(I.attack_verb)]"
	else if(I.force)
		message_verb = "attacked"

	var/attack_message = "[src] has been [message_verb] with [I]."
	if(user)
		user.do_attack_animation(src)
		if(user in viewers(src, null))
			attack_message = "[user] has [message_verb] [src] with [I]!"
	if(message_verb)
		visible_message("<span class='danger'>[attack_message]</span>",
		"<span class='userdanger'>[attack_message]</span>")
	return TRUE

/mob/living/carbon/true_devil/UnarmedAttack(atom/A, proximity)
	A.attack_hand(src)

/mob/living/carbon/true_devil/Process_Spacemove(movement_dir = 0)
	return 1

/mob/living/carbon/true_devil/singularity_act()
	if(ascended)
		return 0
	return ..()

/mob/living/carbon/true_devil/attack_ghost(mob/dead/observer/user as mob)
	if(ascended || user.mind.soulOwner == src.mind)
		var/mob/living/simple_animal/imp/S = new(get_turf(loc))
		S.key = user.key
		S.mind.assigned_role = "Imp"
		S.mind.special_role = "Imp"
		var/datum/objective/newobjective = new
		newobjective.explanation_text = "Try to get a promotion to a higher devilic rank."
		S.mind.objectives += newobjective
		S << S.playstyle_string
		S << "<B>Objective #[1]</B>: [newobjective.explanation_text]"
		return
	else
		return ..()

/mob/living/carbon/true_devil/can_be_revived()
	return 1

/mob/living/carbon/true_devil/resist_fire()
	//They're immune to fire.

/mob/living/carbon/true_devil/attack_hand(mob/living/carbon/human/M)
	if(..())
		switch(M.a_intent)
			if ("harm")
				var/damage = rand(1, 5)
				playsound(loc, "punch", 25, 1, -1)
				visible_message("<span class='danger'>[M] has punched [src]!</span>", \
						"<span class='userdanger'>[M] has punched [src]!</span>")
				adjustBruteLoss(damage)
				add_logs(M, src, "attacked")
				updatehealth()
			if ("disarm")
				if (!lying && !ascended) //No stealing the arch devil's pitchfork.
					if (prob(5))
						Paralyse(2)
						playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
						add_logs(M, src, "pushed")
						visible_message("<span class='danger'>[M] has pushed down [src]!</span>", \
							"<span class='userdanger'>[M] has pushed down [src]!</span>")
					else
						if (prob(25))
							drop_item()
							playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
							visible_message("<span class='danger'>[M] has disarmed [src]!</span>", \
							"<span class='userdanger'>[M] has disarmed [src]!</span>")
						else
							playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
							visible_message("<span class='danger'>[M] has attempted to disarm [src]!</span>")

/mob/living/carbon/true_devil/handle_breathing()
	// devils do not need to breathe

/mob/living/carbon/true_devil/is_literate()
	return 1

/mob/living/carbon/true_devil/ex_act(severity, ex_target)
	if(!ascended)
		var/b_loss
		switch (severity)
			if (1)
				b_loss = 500
			if (2)
				b_loss = 150
			if(3)
				b_loss = 30
		if(has_bane(BANE_LIGHT))
			b_loss *=2
		adjustBruteLoss(b_loss)
	return ..()