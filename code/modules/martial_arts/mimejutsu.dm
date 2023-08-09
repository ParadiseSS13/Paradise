/datum/martial_art/mimejutsu
	name = "Mimejutsu"
	block_chance = 50
	has_explaination_verb = TRUE
	combos = list(/datum/martial_combo/mimejutsu/mimechucks, /datum/martial_combo/mimejutsu/silent_palm, /datum/martial_combo/mimejutsu/silencer, /datum/martial_combo/mimejutsu/execution)

/datum/martial_art/mimejutsu/grab_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	var/obj/item/grab/G = D.grabbedby(A, 1)
	if(G)
		G.state = GRAB_AGGRESSIVE //Instant aggressive grab
		add_attack_logs(A, D, "Melee attacked with martial-art [src] : aggressively grabbed", ATKLOG_ALL)
	return TRUE

/datum/martial_art/mimejutsu/harm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	A.do_attack_animation(D, ATTACK_EFFECT_KICK)
	var/bonus_damage = 15
	D.apply_damage(bonus_damage, BRUTE)
	if(prob(30))
		D.Weaken(2 SECONDS)
	playsound(get_turf(A), 'sound/weapons/blunthit_mimejutsu.ogg', 10, 1, -1)
	objective_damage(A, D, bonus_damage, BRUTE)
	add_attack_logs(A, D, "Melee attacked with [src]", ATKLOG_ALL)
	return TRUE

/datum/martial_art/mimejutsu/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	A.do_attack_animation(D, ATTACK_EFFECT_DISARM)
	var/obj/item/I = null
	if(prob(50))
		if(!D.stat || !D.IsWeakened())
			I = D.get_active_hand()
			if(I && D.drop_from_active_hand())
				A.put_in_hands(I, ignore_anim = FALSE)
			D.Jitter(4 SECONDS)
			D.apply_damage(5, BRUTE)
			objective_damage(A, D, 5, BRUTE)
	playsound(D, 'sound/weapons/punchmiss.ogg', 10, 1, -1)
	add_attack_logs(A, D, "Melee attacked with martial-art [src]", ATKLOG_ALL)
	return TRUE

/obj/item/mimejutsu_scroll
	name = "Mimejutsu manual"
	desc =	"An old manual of the martial art of mimes."
	icon = 'icons/obj/library.dmi'
	icon_state = "mimemanual"
	var/used = FALSE

/obj/item/mimejutsu_scroll/attack_self(mob/user as mob)
	if(!ishuman(user))
		return
	if(!used)
		var/mob/living/carbon/human/H = user
		var/datum/martial_art/mimejutsu/F = new/datum/martial_art/mimejutsu(null)
		F.teach(H)
		to_chat(H, "<span class='boldannounce'>...</span>")
		used = TRUE
		desc = "An old manual of the martial art of mimes. The pages are blank."
	else
		to_chat(usr, "<span class='notice'>You must dedicate yourself to silence first.</span>")

/datum/martial_art/mimejutsu/explaination_header(user)
	to_chat(user, "<b><i>...</i></b>")
