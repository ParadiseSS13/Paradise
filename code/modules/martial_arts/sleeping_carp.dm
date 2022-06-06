//Used by the gang of the same name. Uses combos. Basic attacks bypass armor and never miss
/datum/martial_art/the_sleeping_carp
	name = "Спящий карп"
	deflection_chance = 100
	no_guns = TRUE
	no_guns_message = "Использование оружия дальнего боя опозорит твой клан."
	has_explaination_verb = TRUE
	combos = list(/datum/martial_combo/sleeping_carp/wrist_wrench, /datum/martial_combo/sleeping_carp/back_kick, /datum/martial_combo/sleeping_carp/stomach_knee, /datum/martial_combo/sleeping_carp/head_kick, /datum/martial_combo/sleeping_carp/elbow_drop)

/datum/martial_art/the_sleeping_carp/can_use(mob/living/carbon/human/H)
	if(length(H.reagents.addiction_list))
		return FALSE
	return ..()

/datum/martial_art/the_sleeping_carp/grab_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	var/obj/item/grab/G = D.grabbedby(A,1)
	if(G)
		G.state = GRAB_AGGRESSIVE //Instant aggressive grab
	add_attack_logs(A, D, "Melee attacked with martial-art [src] : Grabbed", ATKLOG_ALL)
	return TRUE

/datum/martial_art/the_sleeping_carp/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	var/atk_verb = pick("ударил[genderize_ru(A.gender,"","а","о","и")] кулаком", "ударил[genderize_ru(A.gender,"","а","о","и")] локтем", "бь[pluralize_ru(A.gender,"ет","ют")] ногой", "пнул[genderize_ru(A.gender,"","а","о","и")]", "пина[pluralize_ru(A.gender,"ет","ют")]", "разнос[pluralize_ru(A.gender,"ит","ят")] ударами")
	D.visible_message("<span class='danger'>[A] [atk_verb] [D]!</span>", \
					  "<span class='userdanger'>[A] [atk_verb] тебя!</span>")
	D.apply_damage(rand(10,15), BRUTE)
	playsound(get_turf(D), 'sound/weapons/punch1.ogg', 25, 1, -1)
	if(prob(50))
		A.say(pick("ХА!", "ХЬЯ!", "КУА!", "ВУА!", "НЫА!", "НА!", "ЧУОО!", "ЧУУ!", "ВУО!", "КЙА!", "ХУУ!", "ХУОХ!", "ХИЙООХ!", "УДАР КАРПА!", "УКУС КАРПА!", "ВЫПАД КАРПА!"))
	if(prob(D.getBruteLoss()) && !D.lying)
		D.visible_message("<span class='warning'>[D] оступа[pluralize_ru(D.gender,"ет","ют")]ся и пада[pluralize_ru(D.gender,"ет","ют")]!</span>", "<span class='userdanger'>Удар [A] опрокидывает тебя на землю!</span>")
		D.Weaken(3)
	add_attack_logs(A, D, "Melee attacked with martial-art [src] : Punched", ATKLOG_ALL)
	return TRUE

/datum/martial_art/the_sleeping_carp/explaination_header(user)
	to_chat(usr, "<b><i>Вы погружаетесь в глубины своей памяти и вспоминаете учение Спящего карпа…</i></b>")
