// CONTAINS: All chameleon clothing items

// Chameleon Jumpsuit

/obj/item/clothing/under/chameleon
//starts off as black
	name = "black jumpsuit"
	icon_state = "black"
	item_state = "bl_suit"
	item_color = "black"
	desc = "It's a plain jumpsuit. It seems to have a small dial on the wrist."
	origin_tech = "syndicate=2"
	var/list/clothing_choices = list()
	burn_state = FIRE_PROOF
	armor = list(melee = 10, bullet = 10, laser = 10, energy = 0, bomb = 0, bio = 0, rad = 0)

	New()
		..()
		var/blocked = list(/obj/item/clothing/under/color/random, /obj/item/clothing/under/rank/centcom) // Stops random coloured jumpsuit and undefined centcomm suit appearing in the list.
		for(var/U in subtypesof(/obj/item/clothing/under/color) - blocked)
			var/obj/item/clothing/under/V = new U
			src.clothing_choices += V

		for(var/U in subtypesof(/obj/item/clothing/under/rank) - blocked)
			var/obj/item/clothing/under/V = new U
			src.clothing_choices += V
		return

	attackby(obj/item/clothing/under/U as obj, mob/user as mob, params)
		..()
		if(istype(U, /obj/item/clothing/under/chameleon))
			to_chat(user, "<span class='warning'>Nothing happens.</span>")
			return
		if(istype(U, /obj/item/clothing/under))
			if(src.clothing_choices.Find(U))
				to_chat(user, "<span class='warning'>Pattern is already recognised by the suit.</span>")
				return
			src.clothing_choices += U
			to_chat(user, "<span class='warning'>Pattern absorbed by the suit.</span>")

	emp_act(severity)
		name = "psychedelic"
		desc = "Groovy!"
		icon_state = "psyche"
		item_color = "psyche"
		usr.update_inv_w_uniform()
		spawn(200)
			name = initial(name)
			icon_state = initial(icon_state)
			item_color = initial(item_color)
			desc = initial(desc)
			usr.update_inv_w_uniform()
		..()

	verb/change()
		set name = "Change Color"
		set category = "Object"
		set src in usr

		if(icon_state == "psyche")
			to_chat(usr, "<span class='warning'>Your suit is malfunctioning</span>")
			return

		var/obj/item/clothing/under/A
		A = input("Select Colour to change it to", "BOOYEA", A) in clothing_choices
		if(!A)
			return

		desc = null
		permeability_coefficient = 0.90

		desc = A.desc
		name = A.name
		icon_state = A.icon_state
		item_state = A.item_state
		item_color = A.item_color
		usr.update_inv_w_uniform()	//so our overlays update.

/obj/item/clothing/under/chameleon/all/New()
	..()
	var/blocked = list(/obj/item/clothing/under/chameleon, /obj/item/clothing/under/chameleon/all)
	//to prevent an infinite loop
	for(var/U in typesof(/obj/item/clothing/under)-blocked)
		var/obj/item/clothing/under/V = new U
		src.clothing_choices += V

// Chameleon Eyewear

/obj/item/clothing/glasses/proc/chameleon(var/mob/user)
	var/input_glasses = input(user, "Choose a piece of eyewear to disguise as.", "Choose glasses style.") as null|anything in list("Sunglasses", "Medical HUD", "Mesons", "Science Goggles", "Glasses", "Security Sunglasses", "Eyepatch", "Welding", "Gar", "Diagnostics")
	var/obj/item/clothing/glasses/E

	if(user && src in user.contents)
		switch(input_glasses)
			if("Sunglasses")
				E = new /obj/item/clothing/glasses/sunglasses
			if("Medical HUD")
				E = new /obj/item/clothing/glasses/hud/health
			if("Mesons")
				E = new /obj/item/clothing/glasses/meson
			if("Science Goggles")
				E = new /obj/item/clothing/glasses/science
			if("Glasses")
				E = new /obj/item/clothing/glasses/regular
			if("Security Sunglasses")
				E = new /obj/item/clothing/glasses/hud/security/sunglasses
			if("Eyepatch")
				E = new /obj/item/clothing/glasses/eyepatch
			if("Welding")
				E = new /obj/item/clothing/glasses/welding
			if("Gar")
				E = new /obj/item/clothing/glasses/fluff/kamina
			if("Diagnostics")
				E = new /obj/item/clothing/glasses/hud/diagnostic
		if(E)
			name = E.name
			desc = E.desc
			icon_state = E.icon_state
			item_state = E.item_state

/obj/item/clothing/glasses/hud/security/chameleon
	name = "Chameleon Security HUD"
	desc = "A stolen security HUD integrated with Syndicate chameleon technology. Toggle to disguise the HUD. Provides flash protection."
	flash_protect = 1

/obj/item/clothing/glasses/hud/security/chameleon/attack_self(mob/user)
	chameleon(user)

/obj/item/clothing/glasses/thermal/syndi
	name = "Optical Meson Scanner"
	desc = "Used for seeing walls, floors, and stuff through anything."
	icon_state = "meson"
	origin_tech = "magnets=3;syndicate=4"
	prescription_upgradable = 1

/obj/item/clothing/glasses/thermal/syndi/attack_self(mob/user)
	chameleon(user)
