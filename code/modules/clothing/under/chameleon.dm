/obj/item/clothing/under/chameleon
//starts off as black
	name = "black jumpsuit"
	icon_state = "black"
	item_state = "bl_suit"
	item_color = "black"
	desc = "It's a plain jumpsuit. It seems to have a small dial on the wrist."
	origin_tech = "syndicate=3"
	var/list/clothing_choices = list()
	burn_state = FIRE_PROOF
	armor = list(melee = 10, bullet = 10, laser = 10, energy = 0, bomb = 0, bio = 0, rad = 0)

	New()
		..()
		for(var/U in subtypesof(/obj/item/clothing/under/color))
			var/obj/item/clothing/under/V = new U
			src.clothing_choices += V

		for(var/U in subtypesof(/obj/item/clothing/under/rank))
			var/obj/item/clothing/under/V = new U
			src.clothing_choices += V
		return


	attackby(obj/item/clothing/under/U as obj, mob/user as mob, params)
		..()
		if(istype(U, /obj/item/clothing/under/chameleon))
			to_chat(user, "\red Nothing happens.")
			return
		if(istype(U, /obj/item/clothing/under))
			if(src.clothing_choices.Find(U))
				to_chat(user, "\red Pattern is already recognised by the suit.")
				return
			src.clothing_choices += U
			to_chat(user, "\red Pattern absorbed by the suit.")


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
			to_chat(usr, "\red Your suit is malfunctioning")
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
