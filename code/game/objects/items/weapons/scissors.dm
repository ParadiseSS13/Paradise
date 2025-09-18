/obj/item/scissors
	name = "Scissors"
	desc = "Those are scissors. Don't run with them!"
	icon_state = "scissor"
	inhand_icon_state = "scissor"
	force = 5
	sharp = TRUE
	w_class = WEIGHT_CLASS_SMALL
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("slices", "cuts", "stabs", "jabs")

/obj/item/scissors/barber
	name = "Barber's Scissors"
	desc = "A pair of scissors used by a barber."
	icon_state = "bscissor"
	attack_verb = list("beautifully sliced", "artistically cut", "smoothly stabbed", "quickly jabbed")
	toolspeed = 0.75

/obj/item/scissors/attack__legacy__attackchain(mob/living/carbon/M as mob, mob/user as mob)
	if(user.a_intent != INTENT_HELP)
		..()
		return
	if(!(M in view(1))) //Adjacency test
		..()
		return
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/head/C = H.get_organ("head")
		if(!C)
			to_chat(user, "<span class='warning'>[M] doesn't have a head!</span>")
			return
		//facial hair
		var/f_new_style = tgui_input_list(user, "Select a facial hair style", "Grooming", H.generate_valid_facial_hairstyles())
		//handle normal hair
		var/h_new_style = tgui_input_list(user, "Select a hair style", "Grooming", H.generate_valid_hairstyles())
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
