/obj/item/weapon/scissors
	name = "Scissors"
	desc = "Those are scissors. Don't run with them!"
	icon_state = "scissor"
	item_state = "scissor"
	force = 5
	sharp = 1
	edge = 1
	w_class = 2
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("slices", "cuts", "stabs", "jabs")

/obj/item/weapon/scissors/barber
	name = "Barber's Scissors"
	desc = "A pair of scissors used by the barber."
	icon_state = "bscissor"
	item_state = "scissor"
	attack_verb = list("beautifully slices", "artistically cuts", "smoothly stabs", "quickly jabs")

/obj/item/weapon/scissors/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(user.a_intent != "help")
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
		if(H.gender == MALE || H.get_species() == "Vulpkanin")
			if(H.species)
				for(var/i in facial_hair_styles_list)
					var/datum/sprite_accessory/facial_hair/tmp_facial = facial_hair_styles_list[i]
					if(H.species.name in tmp_facial.species_allowed)
						species_facial_hair += i
			else
				species_facial_hair = facial_hair_styles_list
		var/f_new_style = input(user, "Select a facial hair style", "Grooming")  as null|anything in species_facial_hair
		//handle normal hair
		var/list/species_hair = list()
		if(H.species)
			for(var/i in hair_styles_list)
				var/datum/sprite_accessory/hair/tmp_hair = hair_styles_list[i]
				if(H.species.name in tmp_hair.species_allowed)
					species_hair += i
		else
			species_hair = hair_styles_list
		var/h_new_style = input(user, "Select a hair style", "Grooming")  as null|anything in species_hair
		user.visible_message("<span class='notice'>[user] starts cutting [M]'s hair!</span>", "<span class='notice'>You start cutting [M]'s hair!</span>") //arguments for this are: 1. what others see 2. what the user sees. --Fixed grammar, (TGameCo)
		playsound(loc, "sound/items/Wirecutter.ogg", 50, 1, -1)
		spawn(5)
			playsound(loc, "sound/items/Wirecutter.ogg", 50, 1, -1)
		spawn(10)
			playsound(loc, "sound/items/Wirecutter.ogg", 50, 1, -1)
		if(do_after(user, 50, target = H)) //this is the part that adds a delay. delay is in deciseconds. --Made it 5 seconds, because hair isn't cut in one second in real life, and I want at least a little bit longer time, (TGameCo)
			if(!(M in view(1))) //Adjacency test
				user.visible_message("<span class='notice'>[user] stops cutting [M]'s hair.</span>", "<span class='notice'>You stop cutting [M]'s hair.</span>")
				return
			if(f_new_style)
				H.f_style = f_new_style
			if(h_new_style)
				H.h_style = h_new_style

		H.update_hair()
		user.visible_message("<span class='notice'>[user] finishes cutting [M]'s hair!</span>")

/obj/item/weapon/scissors/safety //Totally safe, I assure you.
	name = "safety scissors"
	desc = "The blades of the scissors appear to be made of some sort of ultra-strong metal alloy."
	force = 18 //same as e-daggers
	var/is_cutting = 0 //to prevent spam clicking this for huge accumulation of losebreath.

/obj/item/weapon/scissors/safety/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(user.a_intent != "help")
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
			playsound(loc, "sound/items/Wirecutter.ogg", 50, 1, -1)
			spawn(5)
				playsound(loc, "sound/items/Wirecutter.ogg", 50, 1, -1)
			spawn(10)
				playsound(loc, "sound/items/Wirecutter.ogg", 50, 1, -1)
			if(do_after(user, 50, target = H))
				playsound(loc, "sound/weapons/bladeslice.ogg", 50, 1, -1)
				user.visible_message("<span class='danger'>[user] abruptly stops cutting [M]'s hair and slices their throat!</span>", "<span class='danger'>You stop cutting [M]'s hair and slice their throat!</span>")
				H.losebreath += 10 //30 Oxy damage over time
				H.apply_damage(18, BRUTE, "head", sharp =1, edge =1, used_weapon = "scissors")
				var/turf/location = get_turf(H)
				if (istype(location, /turf/simulated))
					location.add_blood(H)
				H.bloody_hands(H)
				H.bloody_body(H)
				var/mob/living/carbon/human/U = user
				U.bloody_hands(H)
				U.bloody_body(H)
				is_cutting = 0
				return
			is_cutting = 0
