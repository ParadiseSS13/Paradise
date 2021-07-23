/obj/item/slapper
	name = "slapper"
	desc = "This is how real men fight."
	icon_state = "latexballon"
	item_state = "nothing"
	force = 0
	throwforce = 0
	flags = DROPDEL | ABSTRACT
	attack_verb = list("slaps")
	hitsound = 'sound/weapons/slap.ogg'
	/// How many smaller table smacks we can do before we're out
	var/table_smacks_left = 3

/obj/item/slapper/attack(mob/M, mob/living/carbon/human/user)
	user.do_attack_animation(M)
	playsound(M, hitsound, 50, TRUE, -1)
	user.visible_message("<span class='danger'>[user] slaps [M]!</span>", "<span class='notice'>You slap [M]!</span>", "<span class='hear'>You hear a slap.</span>")

/obj/item/slapper/attack_obj(obj/O, mob/living/user, params)
	if(!istype(O, /obj/structure/table))
		return ..()

	var/obj/structure/table/the_table = O

	if(user.a_intent == INTENT_HARM && table_smacks_left == initial(table_smacks_left)) // so you can't do 2 weak slaps followed by a big slam
		transform = transform.Scale(1.5) // BIG slap
		if(HAS_TRAIT(user, TRAIT_HULK))
			transform = transform.Scale(2)
			color = COLOR_GREEN
		user.do_attack_animation(the_table)
		if(ishuman(user))
			var/mob/living/carbon/human/human_user = user
			if(istype(human_user.shoes, /obj/item/clothing/shoes/cowboy))
				human_user.say(pick("Hot damn!", "Hoo-wee!", "Got-dang!"))
		playsound(get_turf(the_table), 'sound/effects/tableslam.ogg', 110, TRUE)
		user.visible_message("<b><span class='danger'>[user] slams [user.p_their()] fist down on [the_table]!</span></b>", "<b><span class='danger'>You slam your fist down on [the_table]!</span></b>")
		qdel(src)
	else
		user.do_attack_animation(the_table)
		playsound(get_turf(the_table), 'sound/effects/tableslam.ogg', 40, TRUE)
		user.visible_message("<span class='notice'>[user] slaps [user.p_their()] hand on [the_table].</span>", "<span class='notice'>You slap your hand on [the_table].</span>")
		table_smacks_left--
		if(table_smacks_left <= 0)
			qdel(src)
