/obj/item/clothing/gloves/ring
	name = "iron ring"
	desc = "A band that goes around your finger.  It's considered gauche to wear more than one."
	gender = "neuter" // not plural anymore
	transfer_prints = TRUE
	icon_state = "ironring"
	item_state = ""
	icon = 'icons/obj/clothing/rings.dmi'
	var/fluff_material = FALSE	//If true, will ignore the material when examining
	var/material = "iron"
	var/stud = 0
	var/ring_color = "iron"

/obj/item/clothing/gloves/ring/New()
	..()
	update_icon()

/obj/item/clothing/gloves/ring/update_icon()
	icon_state = "[stud ? "d_" : ""][ring_color]ring"

/obj/item/clothing/gloves/ring/examine(mob/user)
	. = ..()
	if(!fluff_material)
		. += "This one is made of [material]."
	if(stud)
		. += "It is adorned with a single gem."

/obj/item/clothing/gloves/ring/attackby(obj/item/I as obj, mob/user as mob, params)
	if(istype(I, /obj/item/stack/sheet/mineral/diamond))
		var/obj/item/stack/sheet/mineral/diamond/D = I
		if(stud)
			to_chat(usr, "<span class='notice'>The [src] already has a gem.</span>")
		else
			if(D.amount >= 1)
				D.use(1)
				stud = 1
				update_icon()
				to_chat(usr, "<span class='notice'>You socket the diamond into the [src].</span>")

// s'pensive
/obj/item/clothing/gloves/ring/silver
	name =  "silver ring"
	icon_state = "silverring"
	material = "silver"
	ring_color = "silver"

/obj/item/clothing/gloves/ring/silver/blessed // todo
	name = "blessed silver ring"

/obj/item/clothing/gloves/ring/gold
	name =  "gold ring"
	icon_state = "goldring"
	material = "gold"
	ring_color = "gold"

/obj/item/clothing/gloves/ring/gold/blessed
	name = "wedding band"

// cheap
/obj/item/clothing/gloves/ring/plastic
	name =  "white plastic ring"
	icon_state = "whitering"
	material = "plastic"
	ring_color = "white"

/obj/item/clothing/gloves/ring/plastic/blue
	name =  "blue plastic ring"
	icon_state = "bluering"
	ring_color = "blue"

/obj/item/clothing/gloves/ring/plastic/red
	name =  "red plastic ring"
	icon_state = "redring"
	ring_color = "red"

/obj/item/clothing/gloves/ring/plastic/random/New()
	ring_color = pick("white","blue","red")
	name = "[ring_color] plastic ring"
	..()

// weird
/obj/item/clothing/gloves/ring/glass
	name = "glass ring"
	icon_state = "whitering"
	material = "glass"
	ring_color = "white"

/obj/item/clothing/gloves/ring/plasma
	name = "plasma ring"
	icon_state = "plasmaring"
	material = "plasma"
	ring_color = "plasma"

/obj/item/clothing/gloves/ring/uranium
	name = "uranium ring"
	icon_state = "uraniumring"
	material = "uranium"
	ring_color = "uranium"

// cultish
/obj/item/clothing/gloves/ring/shadow
	name = "shadow ring"
	icon_state = "shadowring"
	material = "shadows"
	ring_color = "shadow"
