/obj/item/scissors
	name = "Scissors"
	desc = "Those are scissors. Don't run with them!"
	icon_state = "scissor"
	item_state = "scissor"
	force = 5
	sharp = 1
	w_class = WEIGHT_CLASS_SMALL
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("slices", "cuts", "stabs", "jabs")
	toolspeed = 1

/obj/item/scissors/barber
	name = "Barber's Scissors"
	desc = "A pair of scissors used by the barber."
	icon_state = "bscissor"
	item_state = "scissor"
	attack_verb = list("beautifully sliced", "artistically cut", "smoothly stabbed", "quickly jabbed")
	toolspeed = 0.75

/obj/item/scissors/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(user.a_intent != INTENT_HELP)
		..()
		return
	if(!(M in view(1))) //Adjacency test
		..()
		return
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/head/C = H.get_organ("head")
		//facial hair
		var/f_new_style = input(user, "Select a facial hair style", "Grooming")  as null|anything in H.generate_valid_facial_hairstyles()
		//handle normal hair
		var/h_new_style = input(user, "Select a hair style", "Grooming")  as null|anything in H.generate_valid_hairstyles()
		user.visible_message("<span class='notice'>[user] starts cutting [M]'s hair!</span>", "<span class='notice'>You start cutting [M]'s hair!</span>") //arguments for this are: 1. what others see 2. what the user sees. --Fixed grammar, (TGameCo)
		playsound(loc, 'sound/goonstation/misc/scissor.ogg', 100, 1)
		if(do_after(user, 50 * toolspeed, target = H)) //this is the part that adds a delay. delay is in deciseconds. --Made it 5 seconds, because hair isn't cut in one second in real life, and I want at least a little bit longer time, (TGameCo)
			if(!(M in view(1))) //Adjacency test
				user.visible_message("<span class='notice'>[user] stops cutting [M]'s hair.</span>", "<span class='notice'>You stop cutting [M]'s hair.</span>")
				return
			if(f_new_style)
				C.f_style = f_new_style
			if(h_new_style)
				C.h_style = h_new_style

		H.update_hair()
		H.update_fhair()
		user.visible_message("<span class='notice'>[user] finishes cutting [M]'s hair!</span>")

/obj/item/scissors/safety //Totally safe, I assure you.
	desc = "The blades of the scissors appear to be made of some sort of ultra-strong metal alloy."
	force = 18 //same as e-daggers
	var/is_cutting = 0 //to prevent spam clicking this for huge accumulation of losebreath.

/obj/item/scissors/safety/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(user.a_intent != INTENT_HELP)
		..()
		return
	if(!(M in view(1)))
		..()
		return
	if(ishuman(M))
		var/mob/living/carbon/human/H = M

		if(!is_cutting)
			is_cutting = 1
			user.visible_message("<span class='notice'>[user] starts cutting [M]'s hair!</span>", "<span class='notice'>You start cutting [M]'s hair!</span>")
			playsound(loc, 'sound/goonstation/misc/scissor.ogg', 100, 1)
			if(do_after(user, 50 * toolspeed, target = H))
				playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
				user.visible_message("<span class='danger'>[user] abruptly stops cutting [M]'s hair and slices [M.p_their()] throat!</span>", "<span class='danger'>You stop cutting [M]'s hair and slice [M.p_their()] throat!</span>") //Just a little off the top.
				H.AdjustLoseBreath(10) //30 Oxy damage over time
				H.apply_damage(18, BRUTE, "head", sharp =1, used_weapon = "scissors")
				var/turf/location = get_turf(src)
				H.add_splatter_floor(location)
				H.bloody_hands(H)
				H.bloody_body(H)
				var/mob/living/carbon/human/U = user
				U.bloody_hands(H)
				U.bloody_body(H)
				is_cutting = 0
				return
			is_cutting = 0
