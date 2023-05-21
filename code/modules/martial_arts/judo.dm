/datum/martial_art/judo
	name = "Corporate Judo"
	has_explaination_verb = TRUE
	no_baton = TRUE
	combos = list(/datum/martial_combo/judo/discombobulate)//, /datum/martial_combo/judo/eyepoke, /datum/martial_combo/judo/gunfight, /datum/martial_combo/judo/gunfightfinisher, /datum/martial_combo/judo/judothrow, /datum/martial_combo/judo/armbar, /datum/martial_combo/judo/meelefinisher)
	var/armbar_active = FALSE //used to check if the victim is in an armbar, useful for finishing moves

//Corporate Judo Belt

/obj/item/storage/belt/champion/judo
	name = "Corporate Judo Belt"
	var/datum/martial_art/judo/style = new

/obj/item/storage/belt/champion/judo/equipped(mob/user, slot)
	if(!ishuman(user))
		return
	if(slot == slot_belt)
		var/mob/living/carbon/human/H = user
		if(HAS_TRAIT(user, TRAIT_PACIFISM))
			to_chat(H, "<span class='warning'>The arts of Corporate Judo echo uselessly in your head, the thought of their violence repulsive to you!</span>")
			return
		style.teach(H,1)
		to_chat(H, "<span class = 'userdanger'>The belt's nanites infuse you with the prowess of a black belt in Corporate Judo!</span>")
		to_chat(H, "<span class = 'danger'>See the martial arts tab for an explantion of combos!.</span>")
		return

/obj/item/storage/belt/champion/judo/dropped(mob/user)
	..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(slot_belt) == src)
		style.remove(H)
		to_chat(user, "<span class='sciradio'>You suddenly forget the arts of Corporate Judo...</span>")

//Increased harm damage
/datum/martial_art/judo/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	var/picked_hit_type = pick("punches", "slugs", "strikes", "jabs", "hooks", "uppercuts")
	var/bonus_damage = 10
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	D.apply_damage(bonus_damage, BRUTE)
	playsound(get_turf(D), 'sound/effects/hit_punch.ogg', 50, 1, -1)
	D.visible_message("<span class='danger'>[A] [picked_hit_type] [D]!</span>", \
					"<span class='userdanger'>[A] [picked_hit_type] you!</span>")
	add_attack_logs(A, D, "Melee attacked with [src]")
	return TRUE

/datum/martial_art/judo/explaination_header(user)
	to_chat(user, "<b><i>You recall the teachings of Corperate Judo.</i></b>")

/datum/martial_art/cqc/explaination_footer(user)
	to_chat(user, "<b>Your unarmed strikes hit about twice as hard as your peers, on average.</b>")
