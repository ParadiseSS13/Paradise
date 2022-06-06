#define HAS_COMBOS LAZYLEN(combos)
#define COMBO_ALIVE_TIME 5 SECONDS // How long the combo stays alive when no new attack is done

//Перевод боевых искусств - Пупс PhantomRU#1289

/datum/martial_art
	var/name = "Боевые искусства"
	var/streak = ""
	var/max_streak_length = 6
	var/temporary = FALSE
	var/datum/martial_art/base = null // The permanent style
	var/deflection_chance = 0 //Chance to deflect projectiles
	var/block_chance = 0 //Chance to block melee attacks using items while on throw mode.
	var/help_verb = null
	var/no_guns = FALSE	//set to TRUE to prevent users of this style from using guns (sleeping carp, highlander). They can still pick them up, but not fire them.
	var/no_guns_message = ""	//message to tell the style user if they try and use a gun while no_guns = TRUE (DISHONORABRU!)

	var/has_explaination_verb = FALSE	// If the martial art has it's own explaination verb

	var/list/combos = list()							// What combos can the user do? List of combo types
	var/list/datum/martial_art/current_combos = list()	// What combos are currently (possibly) being performed
	var/last_hit = 0									// When the last hit happened

/datum/martial_art/New()
	. = ..()
	reset_combos()

/datum/martial_art/proc/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return act(MARTIAL_COMBO_STEP_DISARM, A, D)

/datum/martial_art/proc/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return act(MARTIAL_COMBO_STEP_HARM, A, D)

/datum/martial_art/proc/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return act(MARTIAL_COMBO_STEP_GRAB, A, D)

/datum/martial_art/proc/help_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	return act(MARTIAL_COMBO_STEP_HELP, A, D)

/datum/martial_art/proc/can_use(mob/living/carbon/human/H)
	return TRUE

/datum/martial_art/proc/act(step, mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(!can_use(user))
		return MARTIAL_ARTS_CANNOT_USE
	if(last_hit + COMBO_ALIVE_TIME < world.time)
		reset_combos()
	last_hit = world.time

	if(HAS_COMBOS)
		return check_combos(step, user, target)
	return FALSE

/datum/martial_art/proc/reset_combos()
	current_combos.Cut()
	for(var/combo_type in combos)
		current_combos.Add(new combo_type())

/datum/martial_art/proc/check_combos(step, mob/living/carbon/human/user, mob/living/carbon/human/target)
	. = FALSE
	for(var/thing in current_combos)
		var/datum/martial_combo/MC = thing
		if(!MC.check_combo(step, target))
			current_combos -= MC	// It failed so remove it
		else
			switch(MC.progress_combo(user, target, src))
				if(MARTIAL_COMBO_FAIL)
					current_combos -= MC
				if(MARTIAL_COMBO_DONE_NO_CLEAR)
					. = TRUE
					current_combos -= MC
				if(MARTIAL_COMBO_DONE)
					reset_combos()
					return TRUE
				if(MARTIAL_COMBO_DONE_BASIC_HIT)
					basic_hit(user, target)
					reset_combos()
					return TRUE
				if(MARTIAL_COMBO_DONE_CLEAR_COMBOS)
					combos.Cut()
					reset_combos()
					return TRUE
	if(!LAZYLEN(current_combos))
		reset_combos()

/datum/martial_art/proc/basic_hit(mob/living/carbon/human/A, mob/living/carbon/human/D)

	var/damage = rand(A.dna.species.punchdamagelow, A.dna.species.punchdamagehigh)
	var/datum/unarmed_attack/attack = A.dna.species.unarmed

	var/atk_verb = "[pick(attack.attack_verb)]"
	if(D.lying)
		atk_verb = "пнуть"

	switch(atk_verb)
		if("пнуть")
			A.do_attack_animation(D, ATTACK_EFFECT_KICK)
			if(damage)
				atk_verb = "пнул"
		else
			A.do_attack_animation(D, attack.animation_type)

	if(!damage)
		playsound(D.loc, attack.miss_sound, 25, 1, -1)
		D.visible_message("<span class='warning'>[A] попытал[genderize_ru(A.gender,"ся","ась","ось","ись")] [atk_verb] [D]!</span>")
		return FALSE

	var/obj/item/organ/external/affecting = D.get_organ(ran_zone(A.zone_selected))
	var/armor_block = D.run_armor_check(affecting, "melee")

	playsound(D.loc, attack.attack_sound, 25, 1, -1)
	D.visible_message("<span class='danger'>[A] [atk_verb] по [D]!</span>", \
								"<span class='userdanger'>[A] [atk_verb] по [D]!</span>")

	D.apply_damage(damage, BRUTE, affecting, armor_block)

	add_attack_logs(A, D, "Melee attacked with martial-art [src]", (damage > 0) ? null : ATKLOG_ALL)

	if((D.stat != DEAD) && damage >= A.dna.species.punchstunthreshold)
		D.visible_message("<span class='danger'>[A] ослабил[genderize_ru(A.gender,"","а","о","и")] [D]!</span>", \
								"<span class='userdanger'>[A] ослабил[genderize_ru(A.gender,"","а","о","и")] [D]!</span>")
		D.apply_effect(2, WEAKEN, armor_block)
		D.forcesay(GLOB.hit_appends)
	else if(D.lying)
		D.forcesay(GLOB.hit_appends)
	return TRUE

/datum/martial_art/proc/teach(mob/living/carbon/human/H, make_temporary = FALSE)
	if(!H.mind)
		return
	if(has_explaination_verb)
		H.verbs |= /mob/living/carbon/human/proc/martial_arts_help
	if(make_temporary)
		temporary = TRUE
	if(temporary)
		if(H.mind.martial_art)
			base = H.mind.martial_art.base
	else
		base = src
	H.mind.martial_art = src

/datum/martial_art/proc/remove(var/mob/living/carbon/human/H)
	if(!H.mind)
		return
	if(H.mind.martial_art != src)
		return
	H.mind.martial_art = null // Remove reference
	H.verbs -= /mob/living/carbon/human/proc/martial_arts_help
	if(base)
		base.teach(H)
		base = null

/mob/living/carbon/human/proc/martial_arts_help()
	set name = "Показать информацию"
	set desc = "Получить информацию о изученных тобой боевых искусствах"
	set category = "Боевые искусства"
	var/mob/living/carbon/human/H = usr
	if(!istype(H))
		to_chat(usr, "<span class='warning'>You shouldn't have access to this verb. Report this as a bug to the github please.</span>")
		return
	H.mind.martial_art.give_explaination(H)

/datum/martial_art/proc/give_explaination(user = usr)
	explaination_header(user)
	explaination_combos(user)
	explaination_footer(user)

// Put after the header and before the footer in the explaination text
/datum/martial_art/proc/explaination_combos(user)
	if(HAS_COMBOS)
		for(var/combo_type in combos)
			var/datum/martial_combo/MC = new combo_type()
			MC.give_explaination(user)

// Put on top of the explaination text
/datum/martial_art/proc/explaination_header(user)
	return

// Put below the combos in the explaination text
/datum/martial_art/proc/explaination_footer(user)
	return

//ITEMS

/obj/item/clothing/gloves/boxing
	var/datum/martial_art/boxing/style = new

/obj/item/clothing/gloves/boxing/equipped(mob/user, slot)
	if(!ishuman(user))
		return
	if(slot == slot_gloves)
		var/mob/living/carbon/human/H = user
		style.teach(H,1)
	return

/obj/item/clothing/gloves/boxing/dropped(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(slot_gloves) == src)
		style.remove(H)
	return

/obj/item/storage/belt/champion/wrestling
	name = "Борцовский пояс"
	var/datum/martial_art/wrestling/style = new

/obj/item/storage/belt/champion/wrestling/equipped(mob/user, slot)
	if(!ishuman(user))
		return
	if(slot == slot_belt)
		var/mob/living/carbon/human/H = user
		style.teach(H,1)
		to_chat(user, "<span class='sciradio'>Вы поигрываете мускулами! Они напряжены и желают драки. Вам известны знания тысяч предшествующих вам бойцов. Подробности можно вспомнить, используя <kbd>Recall</kbd> во вкладке <kbd>Wrestling</kbd>.</span>")
	return

/obj/item/storage/belt/champion/wrestling/dropped(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(slot_belt) == src)
		style.remove(H)
		to_chat(user, "<span class='sciradio'>Вы потеряли желание заигрывать мускулами.</span>")
	return

/obj/item/plasma_fist_scroll
	name = "Потертый свиток"
	desc = "Старый потёртый клочок бумаги, исписанный меняющимися рунами. На нём изображены рисованные иллюстрации кулачного боя."
	icon = 'icons/obj/wizard.dmi'
	icon_state ="scroll2"
	var/used = 0

/obj/item/plasma_fist_scroll/attack_self(mob/user as mob)
	if(!ishuman(user))
		return

	if(!used)
		var/mob/living/carbon/human/H = user
		var/datum/martial_art/plasma_fist/F = new/datum/martial_art/plasma_fist(null)
		F.teach(H)
		to_chat(H, "<span class='boldannounce'>Вы изучили древнее искусство Плазменного кулака</span>")
		used = 1
		desc = "Совершенно пустой бланк."
		name = "пустой свиток"
		icon_state = "blankscroll"

/obj/item/sleeping_carp_scroll
	name = "загадочный свиток"
	desc = "Свиток с загадочными маркировками. Похоже это рисунки забытого боевого искусства."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll2"

/obj/item/sleeping_carp_scroll/attack_self(mob/living/carbon/human/user as mob)
	if(!istype(user) || !user)
		return
	if(user.mind && (user.mind.changeling || user.mind.vampire)) //Prevents changelings and vampires from being able to learn it
		if(user.mind && user.mind.changeling) //Changelings
			to_chat(user, "<span class ='warning'>Вы неоднократно пытались, но так и не смогли понять содержимое свитка!</span>")
			return
		else //Vampires
			to_chat(user, "<span class ='warning'>Ваша жажда крови слишком отвлекает ваши мысли от сосредоточенного чтения свитка!</span>")
			return

	to_chat(user, "<span class='sciradio'>Вы изучили древнее искусство Спящего карпа! \
					Ваши рукопашные навыки стали эффективнее, вы теперь способны отражать любые пущенные в вас снаряды. \
					Однако, вы больше не можете использовать оружие дальнего боя. \
					Вы можете узнать больше об этом древнем искусстве, нажав <kbd>Recall</kbd> во вкладке <kbd>Sleeping Carp</kbd>.</span>")


	var/datum/martial_art/the_sleeping_carp/theSleepingCarp = new(null)
	theSleepingCarp.teach(user)
	user.drop_item()
	visible_message("<span class='warning'>[src.name] вспыхивает пламенем и сгорает дотла.</span>")
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	qdel(src)

/obj/item/CQC_manual
	name = "старый мануал"
	desc = "Небольшой чёрный мануал. Он полон рисованных инструкций по тактике рукопашного боя."
	icon = 'icons/obj/library.dmi'
	icon_state = "cqcmanual"

/obj/item/CQC_manual/attack_self(mob/living/carbon/human/user)
	if(!istype(user) || !user)
		return
	to_chat(user, "<span class='boldannounce'>Вы выучили основы CQC.</span>")

	var/datum/martial_art/cqc/CQC = new(null)
	CQC.teach(user)
	user.drop_item()
	visible_message("<span class='warning'>[src.name] зловеще пищит и через мгновение вспыхивает пламенем.</span>")
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	qdel(src)

/obj/item/twohanded/bostaff
	name = "бо"
	desc = "Длинный высокий посох из полированного дерева. Традиционно используется в боевых искусствах старой Земли. Используется как для вывода из строя, так и убийств."
	force = 10
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = SLOT_BACK
	force_unwielded = 10
	force_wielded = 24
	throwforce = 20
	throw_speed = 2
	attack_verb = list("разбил", "хлопнул", "поколотил", "наколотил", "прихлопнул", "захлопнул", "ударил", "избил")
	icon_state = "bostaff0"
	block_chance = 50

/obj/item/twohanded/bostaff/update_icon()
	icon_state = "bostaff[wielded]"
	return

/obj/item/twohanded/bostaff/attack(mob/target, mob/living/user)
	add_fingerprint(user)
	if((CLUMSY in user.mutations) && prob(50))
		to_chat(user, "<span class ='warning'>Вы бьёте себя по голове [src.name].</span>")
		user.Weaken(3)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			H.apply_damage(2*force, BRUTE, "head")
		else
			user.take_organ_damage(2*force)
		return
	if(isrobot(target))
		return ..()
	if(!isliving(target))
		return ..()
	var/mob/living/carbon/C = target
	if(C.stat)
		to_chat(user, "<span class='warning'>Бесчестно нападать на врага, пока он[genderize_ru(C.gender,"","а","о","и")] не мо[pluralize_ru(C.gender,"жет","гут")] ответить.</span>")
		return
	switch(user.a_intent)
		if(INTENT_DISARM)
			if(!wielded)
				return ..()
			if(!ishuman(target))
				return ..()
			var/mob/living/carbon/human/H = target
			var/list/fluffmessages = list("[user] бь[pluralize_ru(user.gender,"ет","ют")] [H] используя [src.name]!", \
										  "[user] хлещ[pluralize_ru(user.gender,"ет","ут")] [H] прикладом [src.name]!", \
										  "[user] широко хлещ[pluralize_ru(user.gender,"ет","ут")] [H] используя [src.name]!", \
										  "[user] разбива[pluralize_ru(user.gender,"ет","ют")] [H] голову об [src.name]!", \
										  "[user] бь[pluralize_ru(user.gender,"ет","ют")] [H] передом [src.name]!", \
										  "[user] верт[pluralize_ru(user.gender,"ит","ят")] и хлещ[pluralize_ru(user.gender,"ет","ут")] по [H] используя [src.name]!")
			H.visible_message("<span class='warning'>[pick(fluffmessages)]</span>", \
								   "<span class='userdanger'>[pick(fluffmessages)]</span>")
			playsound(get_turf(user), 'sound/effects/woodhit.ogg', 75, 1, -1)
			H.adjustStaminaLoss(rand(13,20))
			if(prob(10))
				H.visible_message("<span class='warning'>[H] рухнул[genderize_ru(H.gender,"","а","о","и")]!</span>", \
									   "<span class='userdanger'>У вас отказывают ноги!</span>")
				H.Weaken(4)
			if(H.staminaloss && !H.sleeping)
				var/total_health = (H.health - H.staminaloss)
				if(total_health <= HEALTH_THRESHOLD_CRIT && !H.stat)
					H.visible_message("<span class='warning'>[user] нанос[pluralize_ru(user.gender,"ит","ят")] сильный удар по голове [H], выбивая [H.p_them()] из строя!</span>", \
										   "<span class='userdanger'>[user] сбива[pluralize_ru(user.gender,"ет","ют")] тебя с ног!</span>")
					H.SetSleeping(30)
					H.adjustBrainLoss(25)
			return
		else
			return ..()

/obj/item/twohanded/bostaff/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(wielded)
		return ..()
	return 0

#undef HAS_COMBOS
#undef COMBO_ALIVE_TIME
