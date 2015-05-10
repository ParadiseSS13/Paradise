/obj/item/clothing/gloves/ring
	name = "iron ring"
	desc = "A band that goes around your finger.  It's considered gauche to wear more than one."
	gender = "neuter" // not plural anymore
	transfer_prints = TRUE
	icon_state = "ironring"
	item_state = ""
	icon = 'icons/obj/clothing/rings.dmi'
	var/material = "iron"
	var/stud = 0
	species_restricted = null

	New()
		..()
		update_icon()

	update_icon()
		if(stud)
			icon_state = "d_[initial(icon_state)]"
		else
			icon_state = initial(icon_state)
	examine()
		..()
		usr << "This one is made of [material]."
		if(stud)
			usr << "It is adorned with a single gem."

/obj/item/clothing/gloves/ring/attackby(obj/item/I as obj, mob/user as mob, params)
	if(istype(I, /obj/item/stack/sheet/mineral/diamond))
		var/obj/item/stack/sheet/mineral/diamond/D = I
		if(stud)
			usr << "<span class='notice'>The [src] already has a gem.</span>"
		else
			if(D.amount >= 1)
				D.use(1)
				stud = 1
				update_icon()
				usr << "<span class='notice'>You socket the diamond into the [src].</span>"

// s'pensive
/obj/item/clothing/gloves/ring/silver
	name =  "silver ring"
	icon_state = "silverring"
	material = "silver"

/obj/item/clothing/gloves/ring/silver/blessed // todo
	name = "blessed silver ring"

/obj/item/clothing/gloves/ring/gold
	name =  "gold ring"
	icon_state = "goldring"
	material = "gold"

/obj/item/clothing/gloves/ring/gold/blessed
	name = "wedding band"

// cheap
/obj/item/clothing/gloves/ring/plastic
	name =  "white plastic ring"
	icon_state = "whitering"
	material = "plastic"

/obj/item/clothing/gloves/ring/plastic/blue
	name =  "blue plastic ring"
	icon_state = "bluering"

/obj/item/clothing/gloves/ring/plastic/red
	name =  "red plastic ring"
	icon_state = "redring"

/obj/item/clothing/gloves/ring/plastic/random
	New()
		var/c = pick("white","blue","red")
		name = "[c] plastic ring"
		icon_state = "[c]ring"

// weird
/obj/item/clothing/gloves/ring/glass
	name = "glass ring"
	icon_state = "whitering"
	material = "glass"

/obj/item/clothing/gloves/ring/plasma
	name = "plasma ring"
	icon_state = "plasmaring"
	material = "plasma"

/obj/item/clothing/gloves/ring/uranium
	name = "uranium ring"
	icon_state = "uraniumring"
	material = "uranium"

// cultish
/obj/item/clothing/gloves/ring/shadow
	name = "shadow ring"
	icon_state = "shadowring"
	material = "shadows"
