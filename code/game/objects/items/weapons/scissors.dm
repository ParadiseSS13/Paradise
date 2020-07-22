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
		//see code/modules/mob/new_player/preferences.dm at approx line 545 for comments!
		//this is largely copypasted from there.
		//handle facial hair (if necessary)
		var/list/species_facial_hair = list()
		var/obj/item/organ/external/head/C = H.get_organ("head")
		var/datum/robolimb/robohead = all_robolimbs[C.model]
		if(H.gender == MALE || isvulpkanin(H))
			if(C.dna.species)
				for(var/i in GLOB.facial_hair_styles_list)
					var/datum/sprite_accessory/facial_hair/tmp_facial = GLOB.facial_hair_styles_list[i]
					if(C.dna.species.name in tmp_facial.species_allowed)  //If the species is allowed to have the style, add the style to the list. Or, if the character has a prosthetic head, give them the human hair styles.
						if(C.dna.species.bodyflags & ALL_RPARTS) //If the character is of a species that can have full body prosthetics and their head doesn't suport human hair 'wigs', don't add the style to the list.
							if(robohead.is_monitor)
								to_chat(user, "<span class='warning'>You are unable to find anything on [H]'s face worth cutting. How disappointing.</span>")
								return
							continue //If the head DOES support human hair wigs, make sure they don't get monitor-oriented styles.
						species_facial_hair += i
					else
						if(C.dna.species.bodyflags & ALL_RPARTS) //If the target is of a species that can have prosthetic heads, and the head supports human hair 'wigs' AND the hair-style is human-suitable, add it to the list.
							if(!robohead.is_monitor)
								if("Human" in tmp_facial.species_allowed)
									species_facial_hair += i
							else //Otherwise, they won't be getting any hairstyles.
								to_chat(user, "<span class='warning'>You are unable to find anything on [H]'s face worth cutting. How disappointing.</span>")
								return
			else
				species_facial_hair = GLOB.facial_hair_styles_list
		var/f_new_style = input(user, "Select a facial hair style", "Grooming")  as null|anything in species_facial_hair
		//handle normal hair
		var/list/species_hair = list()
		if(C.dna.species)
			for(var/i in GLOB.hair_styles_public_list)
				var/datum/sprite_accessory/hair/tmp_hair = GLOB.hair_styles_public_list[i]
				if(C.dna.species.name in tmp_hair.species_allowed) //If the species is allowed to have the style, add the style to the list. Or, if the character has a prosthetic head, give them the human facial hair styles.
					if(C.dna.species.bodyflags & ALL_RPARTS) //If the character is of a species that can have full body prosthetics and their head doesn't suport human hair 'wigs', don't add the style to the list.
						if(robohead.is_monitor)
							to_chat(user, "<span class='warning'>You are unable to find anything on [H]'s head worth cutting. How disappointing.</span>")
							return
						continue //If the head DOES support human hair wigs, make sure they don't get monitor-oriented styles.
					species_hair += i
				else
					if(C.dna.species.bodyflags & ALL_RPARTS) //If the target is of a species that can have prosthetic heads, and the head supports human hair 'wigs' AND the hair-style is human-suitable, add it to the list.
						if(!robohead.is_monitor)
							if("Human" in tmp_hair.species_allowed)
								species_hair += i
						else //Otherwise, they won't be getting any hairstyles.
							to_chat(user, "<span class='warning'>You are unable to find anything on [H]'s head worth cutting. How disappointing.</span>")
							return
		else
			species_hair = GLOB.hair_styles_public_list
		var/h_new_style = input(user, "Select a hair style", "Grooming")  as null|anything in species_hair
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
