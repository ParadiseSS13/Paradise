
//////////////////////
//		Pizzas		//
//////////////////////

/obj/item/food/snacks/sliceable/pizza
	icon = 'icons/obj/food/pizza.dmi'
	slices_num = 6
	filling_color = "#BAA14C"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1)

// Margherita
/obj/item/food/snacks/sliceable/pizza/margheritapizza
	name = "margherita pizza"
	desc = "The golden standard of pizzas."
	icon_state = "margheritapizza"
	slice_path = /obj/item/food/snacks/margheritapizzaslice
	list_reagents = list("nutriment" = 30, "tomatojuice" = 6, "vitamin" = 5)

/obj/item/food/snacks/margheritapizzaslice
	name = "margherita slice"
	desc = "A slice of the classic pizza."
	icon = 'icons/obj/food/pizza.dmi'
	icon_state = "margheritapizzaslice"
	filling_color = "#BAA14C"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 1)
	goal_difficulty = FOOD_GOAL_EASY

// Meat Pizza
/obj/item/food/snacks/sliceable/pizza/meatpizza
	name = "meat pizza"
	desc = "A pizza with meat topping."
	icon_state = "meatpizza"
	slice_path = /obj/item/food/snacks/meatpizzaslice
	list_reagents = list("protein" = 30, "tomatojuice" = 6, "vitamin" = 8)
	tastes = list("crust" = 1, "cheese" = 1, "meat" = 1)

/obj/item/food/snacks/meatpizzaslice
	name = "meat pizza slice"
	desc = "A slice of a meaty pizza."
	icon = 'icons/obj/food/pizza.dmi'
	icon_state = "meatpizzaslice"
	filling_color = "#BAA14C"
	tastes = list("crust" = 1, "cheese" = 1, "meat" = 1)
	goal_difficulty = FOOD_GOAL_EASY

// Mushroom Pizza
/obj/item/food/snacks/sliceable/pizza/mushroompizza
	name = "mushroom pizza"
	desc = "Very special pizza."
	icon_state = "mushroompizza"
	slice_path = /obj/item/food/snacks/mushroompizzaslice
	list_reagents = list("plantmatter" = 30, "vitamin" = 5)
	tastes = list("crust" = 1, "cheese" = 1, "mushroom" = 1)

/obj/item/food/snacks/mushroompizzaslice
	name = "mushroom pizza slice"
	desc = "Maybe it is the last slice of pizza in your life."
	icon = 'icons/obj/food/pizza.dmi'
	icon_state = "mushroompizzaslice"
	filling_color = "#BAA14C"
	tastes = list("crust" = 1, "cheese" = 1, "mushroom" = 1)
	goal_difficulty = FOOD_GOAL_EASY

// Vegetable Pizza
/obj/item/food/snacks/sliceable/pizza/vegetablepizza
	name = "vegetable pizza"
	desc = "No Tomato Sapiens were harmed during the making of this pizza."
	icon_state = "vegetablepizza"
	slice_path = /obj/item/food/snacks/vegetablepizzaslice
	list_reagents = list("plantmatter" = 25, "tomatojuice" = 6, "oculine" = 12, "vitamin" = 5)
	tastes = list("crust" = 1, "tomato" = 1, "carrot" = 1, "vegetables" = 1)

/obj/item/food/snacks/vegetablepizzaslice
	name = "vegetable pizza slice"
	desc = "A slice of the most green pizza of all pizzas not containing green ingredients."
	icon = 'icons/obj/food/pizza.dmi'
	icon_state = "vegetablepizzaslice"
	filling_color = "#BAA14C"
	tastes = list("crust" = 1, "tomato" = 1, "carrot" = 1, "vegetables" = 1)
	goal_difficulty = FOOD_GOAL_EASY

// Hawaiian Pizza
/obj/item/food/snacks/sliceable/pizza/hawaiianpizza
	name = "hawaiian pizza"
	desc = "Love it or hate it, this pizza divides opinions. Complete with juicy pineapple."
	icon_state = "hawaiianpizza"
	slice_path = /obj/item/food/snacks/hawaiianpizzaslice
	list_reagents = list("protein" = 15, "tomatojuice" = 6, "plantmatter" = 20, "pineapplejuice" = 6, "vitamin" = 5)
	tastes = list("crust" = 1, "cheese" = 1, "pineapple" = 1)

/obj/item/food/snacks/hawaiianpizzaslice
	name = "hawaiian pizza slice"
	desc = "A slice of polarising pizza."
	icon = 'icons/obj/food/pizza.dmi'
	icon_state = "hawaiianpizzaslice"
	filling_color = "#e5b437"
	tastes = list("crust" = 1, "cheese" = 1, "pineapple" = 1)
	goal_difficulty = FOOD_GOAL_EASY

// Mac 'n' Cheese Pizza
/obj/item/food/snacks/sliceable/pizza/macpizza
	name = "mac 'n' cheese pizza"
	desc = "Gastronomists have yet to classify this dish as 'pizza'."
	icon_state = "macpizza"
	slice_path = /obj/item/food/snacks/macpizzaslice
	list_reagents = list("nutriment" = 40, "vitamin" = 5) //More nutriment because carbs, but it's not any more vitaminicious
	filling_color = "#ffe45d"
	tastes = list("crust" = 1, "cheese" = 2, "pasta" = 1)

/obj/item/food/snacks/macpizzaslice
	name = "mac 'n' cheese pizza slice"
	desc = "A delicious slice of pizza topped with macaroni & cheese... wait, what the hell? Who would do this?!"
	icon = 'icons/obj/food/pizza.dmi'
	icon_state = "macpizzaslice"
	filling_color = "#ffe45d"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 2, "pasta" = 1)
	goal_difficulty = FOOD_GOAL_EASY

// Pepperoni Pizza
/obj/item/food/snacks/sliceable/pizza/pepperonipizza
	name = "pepperoni pizza"
	desc = "What did the pepperoni say to the pizza?"
	icon_state = "pepperonipizza"
	slice_path = /obj/item/food/snacks/pepperonipizzaslice
	list_reagents = list("protein" = 30, "tomatojuice" = 6, "vitamin" = 8)
	filling_color = "#ffe45d"
	tastes = list("cheese" = 3, "pepperoni" = 3, "grease" = 1)

/obj/item/food/snacks/pepperonipizzaslice
	name = "pepperoni pizza slice"
	desc = "Nice to meat you!"
	icon = 'icons/obj/food/pizza.dmi'
	icon_state = "pepperonipizzaslice"
	filling_color = "#ffe45d"
	tastes = list("cheese" = 3, "pepperoni" = 3, "grease" = 1)
	goal_difficulty = FOOD_GOAL_EASY

// Cheese Pizza
/obj/item/food/snacks/sliceable/pizza/cheesepizza
	name = "cheese pizza"
	desc = "Cheese, bread, cheese, tomato, and cheese."
	icon_state = "cheesepizza"
	slice_path = /obj/item/food/snacks/cheesepizzaslice
	list_reagents = list("nutriment" = 40, "tomatojuice" = 6, "vitamin" = 5)

/obj/item/food/snacks/cheesepizzaslice
	name = "cheese pizza slice"
	desc = "Dangerously cheesy?"
	icon = 'icons/obj/food/pizza.dmi'
	icon_state = "cheesepizzaslice"
	filling_color = "#BAA14C"
	tastes = list("crust" = 1, "tomato" = 1, "cheese" = 3)
	goal_difficulty = FOOD_GOAL_EASY

// Donk-pocket Pizza
/obj/item/food/snacks/sliceable/pizza/donkpocketpizza
	name = "donk-pocket pizza"
	desc = "Who thought this would be a good idea?"
	icon_state = "donkpocketpizza"
	slice_path = /obj/item/food/snacks/donkpocketpizzaslice
	list_reagents = list("nutriment" = 35, "tomatojuice" = 6, "vitamin" = 2, "weak_omnizine" = 6)
	tastes = list("crust" = 1, "meat" = 1, "laziness" = 1)

/obj/item/food/snacks/donkpocketpizzaslice
	name = "donk-pocket pizza slice"
	desc = "Smells like lukewarm donk-pocket."
	icon = 'icons/obj/food/pizza.dmi'
	icon_state = "donkpocketpizzaslice"
	filling_color = "#BAA14C"
	tastes = list("crust" = 1, "meat" = 1, "laziness" = 1)
	goal_difficulty = FOOD_GOAL_EASY

// Dank Pizza
/obj/item/food/snacks/sliceable/pizza/dankpizza
	name = "dank pizza"
	desc = "The hippie's pizza of choice."
	icon_state = "dankpizza"
	slice_path = /obj/item/food/snacks/dankpizzaslice
	list_reagents = list("nutriment" = 30, "tomatojuice" = 6, "vitamin" = 5, "cbd" = 6, "thc" = 6)
	tastes = list("crust" = 1, "cheese" = 1, "special herbs" = 2)

/obj/item/food/snacks/dankpizzaslice
	name = "dank pizza slice"
	desc = "So good, man..."
	icon = 'icons/obj/food/pizza.dmi'
	icon_state = "dankpizzaslice"
	filling_color = "#BAA14C"
	tastes = list("crust" = 1, "cheese" = 1, "special herbs" = 2)
	goal_difficulty = FOOD_GOAL_EASY

// Firecracker Pizza
/obj/item/food/snacks/sliceable/pizza/firecrackerpizza
	name = "firecracker pizza"
	desc = "Tastes HOT HOT HOT!"
	icon_state = "firecrackerpizza"
	slice_path = /obj/item/food/snacks/firecrackerpizzaslice
	list_reagents = list("nutriment" = 30, "vitamin" = 5, "capsaicin" = 12)
	tastes = list("crust" = 1, "cheese" = 1, "HOTNESS" = 1)

/obj/item/food/snacks/firecrackerpizzaslice
	name = "firecracker pizza slice"
	desc = "A spicy slice of something quite nice"
	icon = 'icons/obj/food/pizza.dmi'
	icon_state = "firecrackerpizzaslice"
	filling_color = "#BAA14C"
	tastes = list("crust" = 1, "cheese" = 1, "HOTNESS" = 1)
	goal_difficulty = FOOD_GOAL_EASY

// "Pesto" Pizza
/obj/item/food/snacks/sliceable/pizza/pestopizza
	name = "\"pesto\" pizza"
	desc = "Wait a second...this doesn't taste like pesto!"
	icon_state = "pestopizza"
	slice_path = /obj/item/food/snacks/pestopizzaslice
	list_reagents = list("nutriment" = 30, "tomatojuice" = 12, "vitamin" = 5, "wasabi" = 12)
	tastes = list("tomato" = 1, "cheese" = 1, "wasabi" = 1)

/obj/item/food/snacks/pestopizzaslice
	name = "\"pesto\" pizza slice"
	desc = "Delicious and suspicious(ly green)."
	icon = 'icons/obj/food/pizza.dmi'
	icon_state = "pestopizzaslice"
	filling_color = "#BAA14C"
	tastes = list("tomato" = 1, "cheese" = 1, "wasabi" = 1)
	goal_difficulty = FOOD_GOAL_EASY

// Garlic Pizza
/obj/item/food/snacks/sliceable/pizza/garlicpizza
	name = "garlic pizza"
	desc = "Ahh, garlic. A universally loved ingredient, except possibly by vampires."
	icon_state = "garlicpizza"
	slice_path = /obj/item/food/snacks/garlicpizzaslice
	list_reagents = list("plantmatter" = 30, "vitamin" = 5, "garlic" = 12)
	tastes = list("crust" = 1, "cheese" = 1, "garlic" = 1)

/obj/item/food/snacks/garlicpizzaslice
	name = "garlic pizza slice"
	desc = "What's not to love?"
	icon = 'icons/obj/food/pizza.dmi'
	icon_state = "garlicpizzaslice"
	filling_color = "#BAA14C"
	tastes = list("crust" = 1, "cheese" = 1, "garlic" = 1)
	goal_difficulty = FOOD_GOAL_EASY


//////////////////////
//		Boxes		//
//////////////////////

/obj/item/pizzabox
	name = "pizza box"
	desc = "A box suited for pizzas."
	icon = 'icons/obj/food/pizza.dmi'
	icon_state = "pizzabox1"

	var/open = FALSE // Is the box open?
	var/is_messy = FALSE // Fancy mess on the lid
	var/obj/item/food/snacks/sliceable/pizza/pizza // Content pizza
	var/list/boxes = list() // If the boxes are stacked, they come here
	var/box_tag = ""

/obj/item/pizzabox/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_DESC|UPDATE_ICON)

/obj/item/pizzabox/update_desc()
	. = ..()
	if(open && pizza)
		desc = "A box suited for pizzas. It appears to have a [pizza.name] inside."
	else if(length(boxes) > 0)
		desc = "A pile of boxes suited for pizzas. There appears to be [length(boxes) + 1] boxes in the pile."
		var/obj/item/pizzabox/top_box = boxes[length(boxes)]
		var/top_tag = top_box.box_tag
		if(top_tag != "")
			desc = "[desc] The box on top has a tag, it reads: '[top_tag]'."
	else
		desc = "A box suited for pizzas."
		if(box_tag != "")
			desc = "[desc] The box has a tag, it reads: '[box_tag]'."

/obj/item/pizzabox/update_icon_state()
	if(open)
		if(is_messy)
			icon_state = "pizzabox_messy"
		else
			icon_state = "pizzabox_open"
		return
	icon_state = "pizzabox[boxes.len+1]"

/obj/item/pizzabox/update_overlays()
	. = ..()
	if(open && pizza)
		var/image/pizzaimg = image("food/pizza.dmi", icon_state = pizza.icon_state)
		pizzaimg.pixel_y = -3
		. += pizzaimg
		return
	else
		// Stupid code because byondcode sucks
		var/set_tag = TRUE
		if(length(boxes) > 0)
			var/obj/item/pizzabox/top_box = boxes[length(boxes)]
			if(top_box.box_tag != "")
				set_tag = TRUE
		else
			if(box_tag != "")
				set_tag = TRUE
		if(!open && set_tag)
			var/image/tag = image("food/pizza.dmi", icon_state = "pizzabox_tag")
			tag.pixel_y = length(boxes) * 3
			. += tag

/obj/item/pizzabox/attack_hand(mob/user)
	if(open && pizza)
		user.put_in_hands(pizza)
		to_chat(user, "<span class='warning'>You take [pizza] out of [src].</span>")
		pizza = null
		update_appearance(UPDATE_DESC|UPDATE_ICON)
		return

	if(length(boxes) > 0)
		if(user.is_in_inactive_hand(src))
			..()
			return
		var/obj/item/pizzabox/box = boxes[length(boxes)]
		boxes -= box
		user.put_in_hands(box)
		to_chat(user, "<span class='warning'>You remove the topmost [src] from your hand.</span>")
		box.update_appearance(UPDATE_DESC|UPDATE_ICON)
		update_appearance(UPDATE_DESC|UPDATE_ICON)
		return
	..()

/obj/item/pizzabox/AltClick(mob/user)
	..()
	if(length(boxes) || !Adjacent(user))
		return
	open = !open
	update_appearance(UPDATE_DESC|UPDATE_ICON)

/obj/item/pizzabox/attack_self(mob/user)
	if(length(boxes) > 0)
		return
	open = !open
	if(open && pizza)
		is_messy = TRUE
	update_appearance(UPDATE_DESC|UPDATE_ICON)

/obj/item/pizzabox/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/pizzabox/))
		var/obj/item/pizzabox/box = I
		if(!box.open && !open)
			// Make a list of all boxes to be added
			var/list/boxestoadd = list()
			boxestoadd += box
			for(var/obj/item/pizzabox/i in box.boxes)
				boxestoadd += i
			if((boxes.len+1) + length(boxestoadd) <= 5)
				user.drop_item()
				box.loc = src
				box.boxes = list() // Clear the box boxes so we don't have boxes inside boxes. - Xzibit
				boxes.Add(boxestoadd)
				box.update_appearance(UPDATE_DESC|UPDATE_ICON)
				update_appearance(UPDATE_DESC|UPDATE_ICON)
				to_chat(user, "<span class='warning'>You put [box] on top of [src]!</span>")
			else
				to_chat(user, "<span class='warning'>The stack is too high!</span>")
		else
			to_chat(user, "<span class='warning'>Close [box] first!</span>")
		return

	if(istype(I, /obj/item/food/snacks/sliceable/pizza)) // Long ass fucking object name
		if(open)
			user.drop_item()
			I.loc = src
			pizza = I

			update_appearance(UPDATE_DESC|UPDATE_ICON)

			to_chat(user, "<span class='warning'>You put [I] in [src]!</span>")
		else
			to_chat(user, "<span class='warning'>You try to push [I] through the lid but it doesn't work!</span>")
		return

	if(is_pen(I))
		if(open)
			return
		var/t = tgui_input_text(usr, "Enter what you want to set the tag to:", "Write")
		if(!t)
			return
		var/obj/item/pizzabox/boxtotagto = src
		if(length(boxes) > 0)
			boxtotagto = boxes[length(boxes)]
		boxtotagto.box_tag = copytext("[t]", 1, 30)
		update_appearance(UPDATE_DESC|UPDATE_ICON)
		return
	..()


/obj/item/pizzabox/margherita/Initialize(mapload)
	pizza = new /obj/item/food/snacks/sliceable/pizza/margheritapizza(src)
	box_tag = "margherita deluxe"
	. = ..()

/obj/item/pizzabox/vegetable/Initialize(mapload)
	pizza = new /obj/item/food/snacks/sliceable/pizza/vegetablepizza(src)
	box_tag = "gourmet vegetable"
	. = ..()

/obj/item/pizzabox/mushroom/Initialize(mapload)
	pizza = new /obj/item/food/snacks/sliceable/pizza/mushroompizza(src)
	box_tag = "mushroom special"
	. = ..()

/obj/item/pizzabox/meat/Initialize(mapload)
	pizza = new /obj/item/food/snacks/sliceable/pizza/meatpizza(src)
	box_tag = "meatlover's supreme"
	. = ..()

/obj/item/pizzabox/hawaiian/Initialize(mapload)
	pizza = new /obj/item/food/snacks/sliceable/pizza/hawaiianpizza(src)
	box_tag = "Hawaiian feast"
	. = ..()

/obj/item/pizzabox/pepperoni/Initialize(mapload)
	pizza = new /obj/item/food/snacks/sliceable/pizza/pepperonipizza(src)
	box_tag = "classic pepperoni"
	. = ..()

/obj/item/pizzabox/garlic/Initialize(mapload)
	pizza = new /obj/item/food/snacks/sliceable/pizza/garlicpizza(src)
	box_tag = "triple garlic"
	. = ..()

/obj/item/pizzabox/firecracker/Initialize(mapload)
	pizza = new /obj/item/food/snacks/sliceable/pizza/firecrackerpizza(src)
	box_tag = "extra spicy pie"
	. = ..()

//////////////////////////
//		Pizza bombs		//
//////////////////////////
/obj/item/pizzabox/pizza_bomb
	/// Adjustable timer
	var/timer = 1 SECONDS
	var/timer_set = FALSE
	var/primed = FALSE
	var/disarmed = FALSE
	var/wires = list("orange", "green", "blue", "yellow", "aqua", "purple")
	var/correct_wire
	var/armer //Used for admin purposes
	var/opener //Ditto

/obj/item/pizzabox/pizza_bomb/update_desc()
	if(primed)
		return
	return ..()

/obj/item/pizzabox/pizza_bomb/update_icon_state()
	if(primed)
		return
	return ..()

/obj/item/pizzabox/pizza_bomb/AltClick(mob/user)
	attack_self(user)

/obj/item/pizzabox/pizza_bomb/attack_self(mob/user)
	if(disarmed)
		to_chat(user, "<span class='notice'>[src] is disarmed.</span>")
		return
	if(!timer_set)
		name = "pizza bomb"
		desc = "It seems inactive."
		icon_state = "pizzabox_bomb"
		timer_set = TRUE
		var/new_timer = tgui_input_number(user, "Set a timer, from one second to ten seconds.", "Timer", timer / 10, 10, 1)
		if(isnull(new_timer))
			return
		if(!in_range(src, user) || issilicon(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || user.restrained())
			timer_set = FALSE
			name = "pizza box"
			desc = "A box suited for pizzas."
			icon_state = "pizzabox1"
			return
		timer = new_timer SECONDS
		icon_state = "pizzabox1"
		to_chat(user, "<span class='notice'>You set the timer to [timer / 10] before activating the payload and closing [src].")
		message_admins("[key_name_admin(usr)] has set a timer on a pizza bomb to [timer/10] seconds at <A href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[loc.x];Y=[loc.y];Z=[loc.z]'>(JMP)</a>.")
		log_game("[key_name(usr)] has set the timer on a pizza bomb to [timer / 10] seconds ([loc.x],[loc.y],[loc.z]).")
		investigate_log("[key_name(usr)] has armed a [name] for detonation at ([loc.x],[loc.y],[loc.z])", INVESTIGATE_BOMB)
		add_attack_logs(user, src, "has armed for detonation", ATKLOG_FEW)
		armer = user
		name = "pizza box"
		desc = "A box suited for pizzas."
		return
	if(!primed)
		name = "pizza bomb"
		desc = "OH GOD THAT'S NOT A PIZZA"
		icon_state = "pizzabox_bomb_active"
		audible_message("<span class='warning'>[bicon(src)] *beep* *beep*</span>")
		to_chat(user, "<span class='danger'>That's no pizza! That's a bomb!</span>")
		if(HAS_TRAIT(src, TRAIT_CMAGGED))
			atom_say("Pizza time!")
			playsound(src, 'sound/voice/pizza_time.ogg', 50, FALSE) ///Sound effect made by BlackDog
		message_admins("[key_name_admin(usr)] has triggered a pizza bomb armed by [key_name_admin(armer)] at <A href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[loc.x];Y=[loc.y];Z=[loc.z]'>(JMP)</a>.")
		log_game("[key_name(usr)] has triggered a pizza bomb armed by [key_name(armer)] ([loc.x],[loc.y],[loc.z]).")
		investigate_log("[key_name(usr)] has opened a [name] for detonation at ([loc.x],[loc.y],[loc.z])", INVESTIGATE_BOMB)
		add_attack_logs(user, src, "has opened for detonation", ATKLOG_FEW)
		opener = user
		primed = TRUE
		sleep(timer)
		return go_boom()

/obj/item/pizzabox/pizza_bomb/proc/go_boom()
	if(disarmed)
		visible_message("<span class='danger'>[bicon(src)] Sparks briefly jump out of the [correct_wire] wire on [src], but it's disarmed!</span>")
		return
	atom_say("Enjoy the pizza!")
	visible_message("<span class='userdanger'>[src] violently explodes!</span>")
	message_admins("A pizza bomb set by [key_name_admin(armer)] and opened by [key_name_admin(opener)] has detonated at <A href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[loc.x];Y=[loc.y];Z=[loc.z]'>(JMP)</a>.")
	log_game("Pizza bomb set by [key_name(armer)] and opened by [key_name(opener)]) detonated at ([loc.x],[loc.y],[loc.z]).")
	explosion(loc, 1, 2, 4, flame_range = 2) //Identical to a minibomb
	armer = null
	opener = null
	qdel(src)

/obj/item/pizzabox/pizza_bomb/cmag_act(mob/user)
	if(!HAS_TRAIT(src, TRAIT_CMAGGED))
		to_chat(user, "<span class='notice'>You smear the bananium ooze all over the pizza bomb's internals! You think you smell a bit of tomato sauce.</span>")
		ADD_TRAIT(src, TRAIT_CMAGGED, CLOWN_EMAG)

/obj/item/pizzabox/pizza_bomb/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/wirecutters) && primed)
		to_chat(user, "<span class='danger'>Oh God, what wire do you cut?!</span>")
		var/chosen_wire = tgui_input_list(user, "OH GOD OH GOD", "WHAT WIRE?!", wires)
		if(!in_range(src, user) || issilicon(usr) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || user.restrained() || !chosen_wire)
			return
		playsound(src, I.usesound, 50, 1, 1)
		user.visible_message("<span class='warning'>[user] cuts the [chosen_wire] wire!</span>", "<span class='danger'>You cut the [chosen_wire] wire!</span>")
		sleep(5)
		if(chosen_wire == correct_wire)
			audible_message("<span class='warning'>[bicon(src)] [src] suddenly stops beeping and seems lifeless.</span>")
			to_chat(user, "<span class='notice'>You did it!</span>")
			icon_state = "pizzabox_bomb_[correct_wire]"
			name = "pizza bomb"
			desc = "A devious contraption, made of a small explosive payload hooked up to pressure-sensitive wires. It's disarmed."
			disarmed = TRUE
			primed = FALSE
			return
		else
			to_chat(user, "<span class='userdanger'>WRONG WIRE!</span>")
			go_boom()
			return
	if(istype(I, /obj/item/wirecutters) && disarmed)
		if(!in_range(user, src))
			to_chat(user, "<span class='warning'>You can't see the box well enough to cut the wires out.</span>")
			return
		user.visible_message("<span class='notice'>[user] starts removing the payload and wires from [src].</span>")
		if(do_after(user, 40 * I.toolspeed, target = src))
			playsound(src, I.usesound, 50, 1, 1)
			user.unEquip(src)
			user.visible_message("<span class='notice'>[user] removes the insides of [src]!</span>")
			var/obj/item/stack/cable_coil/C = new /obj/item/stack/cable_coil(src.loc)
			C.amount = 3
			new /obj/item/bombcore/miniature(loc)
			new /obj/item/pizzabox(loc)
			qdel(src)
		return
	..()

/obj/item/pizzabox/pizza_bomb/Initialize(mapload)
	correct_wire = pick(wires)
	box_tag = "classic pepperoni"
	. = ..()

/obj/item/pizzabox/pizza_bomb/autoarm
	timer_set = TRUE
	timer = 3 SECONDS
