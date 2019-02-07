
//////////////////////
//		Pizzas		//
//////////////////////

/obj/item/reagent_containers/food/snacks/sliceable/pizza
	icon = 'icons/obj/food/pizza.dmi'
	slices_num = 6
	filling_color = "#BAA14C"

/obj/item/reagent_containers/food/snacks/sliceable/pizza/margherita
	name = "margherita pizza"
	desc = "The golden standard of pizzas."
	icon_state = "pizzamargherita"
	slice_path = /obj/item/reagent_containers/food/snacks/margheritaslice
	list_reagents = list("nutriment" = 30, "tomatojuice" = 6, "vitamin" = 5)

/obj/item/reagent_containers/food/snacks/margheritaslice
	name = "margherita slice"
	desc = "A slice of the classic pizza."
	icon = 'icons/obj/food/pizza.dmi'
	icon_state = "pizzamargheritaslice"
	filling_color = "#BAA14C"
	list_reagents = list("nutriment" = 5)

/obj/item/reagent_containers/food/snacks/sliceable/pizza/meatpizza
	name = "meat pizza"
	desc = "A pizza with meat topping."
	icon_state = "meatpizza"
	slice_path = /obj/item/reagent_containers/food/snacks/meatpizzaslice
	list_reagents = list("protein" = 30, "tomatojuice" = 6, "vitamin" = 8)

/obj/item/reagent_containers/food/snacks/meatpizzaslice
	name = "meat pizza slice"
	desc = "A slice of a meaty pizza."
	icon = 'icons/obj/food/pizza.dmi'
	icon_state = "meatpizzaslice"
	filling_color = "#BAA14C"

/obj/item/reagent_containers/food/snacks/sliceable/pizza/mushroompizza
	name = "mushroom pizza"
	desc = "Very special pizza."
	icon_state = "mushroompizza"
	slice_path = /obj/item/reagent_containers/food/snacks/mushroompizzaslice
	list_reagents = list("plantmatter" = 30, "vitamin" = 5)

/obj/item/reagent_containers/food/snacks/mushroompizzaslice
	name = "mushroom pizza slice"
	desc = "Maybe it is the last slice of pizza in your life."
	icon = 'icons/obj/food/pizza.dmi'
	icon_state = "mushroompizzaslice"
	filling_color = "#BAA14C"

/obj/item/reagent_containers/food/snacks/sliceable/pizza/vegetablepizza
	name = "vegetable pizza"
	desc = "No Tomato Sapiens were harmed during the making of this pizza."
	icon_state = "vegetablepizza"
	slice_path = /obj/item/reagent_containers/food/snacks/vegetablepizzaslice
	list_reagents = list("plantmatter" = 25, "tomatojuice" = 6, "oculine" = 12, "vitamin" = 5)

/obj/item/reagent_containers/food/snacks/vegetablepizzaslice
	name = "vegetable pizza slice"
	desc = "A slice of the most green pizza of all pizzas not containing green ingredients."
	icon = 'icons/obj/food/pizza.dmi'
	icon_state = "vegetablepizzaslice"
	filling_color = "#BAA14C"

/obj/item/reagent_containers/food/snacks/sliceable/pizza/hawaiianpizza
	name = "Hawaiian pizza"
	desc = "Love it or hate it, this pizza divides opinions. Complete with juicy pineapple."
	icon_state = "hawaiianpizza" //NEEDED
	slice_path = /obj/item/reagent_containers/food/snacks/hawaiianpizzaslice
	list_reagents = list("protein" = 15, "tomatojuice" = 6, "plantmatter" = 20, "pineapplejuice" = 6, "vitamin" = 5)

/obj/item/reagent_containers/food/snacks/hawaiianpizzaslice
	name = "Hawaiian pizza slice"
	desc = "A slice of polarising pizza."
	icon = 'icons/obj/food/pizza.dmi'
	icon_state = "hawaiianpizzaslice"
	filling_color = "#e5b437"

/obj/item/reagent_containers/food/snacks/sliceable/pizza/macpizza
	name = "mac n cheese pizza"
	desc = "Gastronomists have yet to classify this dish as 'pizza'."
	icon_state = "macpizza"
	slice_path = /obj/item/reagent_containers/food/snacks/macpizzaslice
	list_reagents = list("nutriment" = 40, "vitamin" = 5) //More nutriment because carbs, but it's not any more vitaminicious
	filling_color = "#ffe45d"

/obj/item/reagent_containers/food/snacks/macpizzaslice
	name = "mac n cheese pizza slice"
	desc = "A delicious slice of pizza topped with macaroni cheese... wait, what the hell? Who would do this?!"
	icon = 'icons/obj/food/pizza.dmi'
	icon_state = "macpizzaslice"
	filling_color = "#ffe45d"


//////////////////////
//		Boxes		//
//////////////////////

/obj/item/pizzabox
	name = "pizza box"
	desc = "A box suited for pizzas."
	icon = 'icons/obj/food/pizza.dmi'
	icon_state = "pizzabox1"

	var/open = 0 // Is the box open?
	var/ismessy = 0 // Fancy mess on the lid
	var/obj/item/reagent_containers/food/snacks/sliceable/pizza/pizza // Content pizza
	var/list/boxes = list() // If the boxes are stacked, they come here
	var/boxtag = ""

/obj/item/pizzabox/update_icon()
	overlays = list()

	// Set appropriate description
	if(open && pizza)
		desc = "A box suited for pizzas. It appears to have a [pizza.name] inside."
	else if(boxes.len > 0)
		desc = "A pile of boxes suited for pizzas. There appears to be [boxes.len + 1] boxes in the pile."
		var/obj/item/pizzabox/topbox = boxes[boxes.len]
		var/toptag = topbox.boxtag
		if(toptag != "")
			desc = "[desc] The box on top has a tag, it reads: '[toptag]'."
	else
		desc = "A box suited for pizzas."
		if(boxtag != "")
			desc = "[desc] The box has a tag, it reads: '[boxtag]'."

	// Icon states and overlays
	if(open)
		if(ismessy)
			icon_state = "pizzabox_messy"
		else
			icon_state = "pizzabox_open"
		if(pizza)
			var/image/pizzaimg = image("food/pizza.dmi", icon_state = pizza.icon_state)
			pizzaimg.pixel_y = -3
			overlays += pizzaimg

		return
	else
		// Stupid code because byondcode sucks
		var/doimgtag = 0
		if(boxes.len > 0)
			var/obj/item/pizzabox/topbox = boxes[boxes.len]
			if(topbox.boxtag != "")
				doimgtag = 1
		else
			if(boxtag != "")
				doimgtag = 1
		if(doimgtag)
			var/image/tagimg = image("food/pizza.dmi", icon_state = "pizzabox_tag")
			tagimg.pixel_y = boxes.len * 3
			overlays += tagimg
	icon_state = "pizzabox[boxes.len+1]"

/obj/item/pizzabox/attack_hand(mob/user)
	if(open && pizza)
		user.put_in_hands(pizza)
		to_chat(user, "<span class='warning'>You take the [pizza] out of the [src].</span>")
		pizza = null
		update_icon()
		return

	if(boxes.len > 0)
		if(user.is_in_inactive_hand(src))
			..()
			return
		var/obj/item/pizzabox/box = boxes[boxes.len]
		boxes -= box
		user.put_in_hands(box)
		to_chat(user, "<span class='warning'>You remove the topmost [src] from your hand.</span>")
		box.update_icon()
		update_icon()
		return
	..()

/obj/item/pizzabox/attack_self(mob/user)
	if(boxes.len > 0)
		return
	open = !open
	if(open && pizza)
		ismessy = 1
	update_icon()

/obj/item/pizzabox/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/pizzabox/))
		var/obj/item/pizzabox/box = I
		if(!box.open && !open)
			// Make a list of all boxes to be added
			var/list/boxestoadd = list()
			boxestoadd += box
			for(var/obj/item/pizzabox/i in box.boxes)
				boxestoadd += i
			if((boxes.len+1) + boxestoadd.len <= 5)
				user.drop_item()
				box.loc = src
				box.boxes = list() // Clear the box boxes so we don't have boxes inside boxes. - Xzibit
				boxes.Add(boxestoadd)
				box.update_icon()
				update_icon()
				to_chat(user, "<span class='warning'>You put the [box] ontop of the [src]!</span>")
			else
				to_chat(user, "<span class='warning'>The stack is too high!</span>")
		else
			to_chat(user, "<span class='warning'>Close the [box] first!</span>")
		return

	if(istype(I, /obj/item/reagent_containers/food/snacks/sliceable/pizza/)) // Long ass fucking object name
		if(open)
			user.drop_item()
			I.loc = src
			pizza = I

			update_icon()

			to_chat(user, "<span class='warning'>You put the [I] in the [src]!</span>")
		else
			to_chat(user, "<span class='warning'>You try to push the [I] through the lid but it doesn't work!</span>")
		return

	if(istype(I, /obj/item/pen/))
		if(open)
			return
		var/t = input("Enter what you want to add to the tag:", "Write", null, null) as text
		var/obj/item/pizzabox/boxtotagto = src
		if(boxes.len > 0)
			boxtotagto = boxes[boxes.len]
		boxtotagto.boxtag = copytext("[boxtotagto.boxtag][t]", 1, 30)
		update_icon()
		return
	..()

/obj/item/pizzabox/margherita/New()
	pizza = new /obj/item/reagent_containers/food/snacks/sliceable/pizza/margherita(src)
	boxtag = "margherita deluxe"

/obj/item/pizzabox/vegetable/New()
	pizza = new /obj/item/reagent_containers/food/snacks/sliceable/pizza/vegetablepizza(src)
	boxtag = "gourmet vegatable"

/obj/item/pizzabox/mushroom/New()
	pizza = new /obj/item/reagent_containers/food/snacks/sliceable/pizza/mushroompizza(src)
	boxtag = "mushroom special"

/obj/item/pizzabox/meat/New()
	pizza = new /obj/item/reagent_containers/food/snacks/sliceable/pizza/meatpizza(src)
	boxtag = "meatlover's supreme"

/obj/item/pizzabox/hawaiian/New()
	pizza = new /obj/item/reagent_containers/food/snacks/sliceable/pizza/hawaiianpizza(src)
	boxtag = "Hawaiian feast"