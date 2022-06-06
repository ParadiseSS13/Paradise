/datum/martial_art/adminfu
	name = "Путь танцующего админа"
	has_explaination_verb = TRUE
	combos = list(/datum/martial_combo/adminfu/healing_palm)

/datum/martial_art/adminfu/harm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	if(!D.stat)//do not kill what is dead...
		A.do_attack_animation(D)
		D.visible_message("<span class='warning'>[A] проявля[pluralize_ru(A.gender,"ет","ют")] большой светящийся тулбокс и запихива[pluralize_ru(A.gender,"ет","ют")] его прямо в грудь [D]!</span>", \
							"<spac class='userdanger'>[A] запихивает мистический тулбокс в вашу грудь!</span>")
		D.death()

		return TRUE


/datum/martial_art/adminfu/disarm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	A.do_attack_animation(D)
	D.Weaken(25)
	D.Stun(25)
	return TRUE

/datum/martial_art/adminfu/grab_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	var/obj/item/grab/G = D.grabbedby(A,1)
	if(G)
		G.state = GRAB_NECK
	return TRUE

/datum/martial_art/adminfu/explaination_header(user)
	to_chat(user, "<span class='notice'>Grab</span>: Automatic Neck Grab.")
	to_chat(user, "<span class='notice'>Disarm</span>: Stun/weaken")
	to_chat(user, "<span class='notice'>Harm</span>: Death.")

/obj/item/adminfu_scroll
	name = "потёртый свиток"
	desc = "Старый потёртый клочок бумаги, исписанный меняющимися рунами. Есть рисованные иллюстрации кулачного боя."
	icon = 'icons/obj/wizard.dmi'
	icon_state ="scroll2"
	var/used = 0

/obj/item/adminfu_scroll/attack_self(mob/user as mob)
	if(!ishuman(user))
		return
	if(!used)
		var/mob/living/carbon/human/H = user
		var/datum/martial_art/adminfu/F = new/datum/martial_art/adminfu(null)
		F.teach(H)
		to_chat(H, "<span class='boldannounce'>Вы изучили древнее боевое искусство Админов.</span>")
		used = 1
		desc = "Он совершенно пуст."
		name = "пустой свиток"
		icon_state = "blankscroll"
