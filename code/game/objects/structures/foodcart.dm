/obj/structure/foodcart
	name = "food and drink cart"
	desc = "A cart for transporting food and drinks."
	icon = 'icons/obj/foodcart.dmi'
	icon_state = "cart"
	anchored = 0
	density = 1
	//Food slots
	var/list/food_slots[15]
	//var/obj/item/reagent_containers/food/snacks/food1 = null
	//var/obj/item/reagent_containers/food/snacks/food2 = null
	//var/obj/item/reagent_containers/food/snacks/food3 = null
	//var/obj/item/reagent_containers/food/snacks/food4 = null
	//var/obj/item/reagent_containers/food/snacks/food5 = null
	//var/obj/item/reagent_containers/food/snacks/food6 = null
	//Drink slots
	var/list/drink_slots[15]
	//var/obj/item/reagent_containers/food/drinks/drink1 = null
	//var/obj/item/reagent_containers/food/drinks/drink2 = null
	//var/obj/item/reagent_containers/food/drinks/drink3 = null
	//var/obj/item/reagent_containers/food/drinks/drink4 = null
	//var/obj/item/reagent_containers/food/drinks/drink5 = null
	//var/obj/item/reagent_containers/food/drinks/drink6 = null

/obj/structure/foodcart/proc/put_in_cart(obj/item/I, mob/user)
	user.drop_item()
	I.loc = src
	updateUsrDialog()
	to_chat(user, "<span class='notice'>You put [I] into [src].</span>")
	return

/obj/structure/foodcart/attackby(obj/item/I, mob/user, params)
	var/fail_msg = "<span class='notice'>There are no open spaces for this in [src].</span>"
	if(!I.is_robot_module())
		if(istype(I, /obj/item/reagent_containers/food/snacks))
			var/success = 0
			for(var/s=1,s<=15,s++)
				if(!food_slots[s])
					put_in_cart(I, user)
					food_slots[s]=I
					update_icon()
					success = 1
					break
			if(!success)
				to_chat(user, fail_msg)
		else if(istype(I, /obj/item/reagent_containers/food/drinks))
			var/success = 0
			for(var/s=1,s<=15,s++)
				if(!drink_slots[s])
					put_in_cart(I, user)
					drink_slots[s]=I
					update_icon()
					success = 1
					break
			if(!success)
				to_chat(user, fail_msg)
		else if(istype(I, /obj/item/wrench))
			if(!anchored && !isinspace())
				playsound(src.loc, I.usesound, 50, 1)
				user.visible_message( \
					"[user] tightens \the [src]'s casters.", \
					"<span class='notice'> You have tightened \the [src]'s casters.</span>", \
					"You hear ratchet.")
				anchored = 1
			else if(anchored)
				playsound(src.loc, I.usesound, 50, 1)
				user.visible_message( \
					"[user] loosens \the [src]'s casters.", \
					"<span class='notice'> You have loosened \the [src]'s casters.</span>", \
					"You hear ratchet.")
				anchored = 0
	else
		to_chat(usr, "<span class='warning'>You cannot interface your modules [src]!</span>")

/obj/structure/foodcart/attack_hand(mob/user)
	user.set_machine(src)
	var/dat
	if(food_slots[1])
		dat += "<a href='?src=[UID()];f1=1'>[food_slots[1]]</a><br>"
	if(food_slots[2])
		dat += "<a href='?src=[UID()];f2=1'>[food_slots[2]]</a><br>"
	if(food_slots[3])
		dat += "<a href='?src=[UID()];f3=1'>[food_slots[3]]</a><br>"
	if(food_slots[4])
		dat += "<a href='?src=[UID()];f4=1'>[food_slots[4]]</a><br>"
	if(food_slots[5])
		dat += "<a href='?src=[UID()];f5=1'>[food_slots[5]]</a><br>"
	if(food_slots[6])
		dat += "<a href='?src=[UID()];f6=1'>[food_slots[6]]</a><br>"
	if(food_slots[7])
		dat += "<a href='?src=[UID()];f7=1'>[food_slots[7]]</a><br>"
	if(food_slots[8])
		dat += "<a href='?src=[UID()];f8=1'>[food_slots[8]]</a><br>"
	if(food_slots[9])
		dat += "<a href='?src=[UID()];f9=1'>[food_slots[9]]</a><br>"
	if(food_slots[10])
		dat += "<a href='?src=[UID()];f10=1'>[food_slots[10]]</a><br>"
	if(food_slots[11])
		dat += "<a href='?src=[UID()];f11=1'>[food_slots[11]]</a><br>"
	if(food_slots[12])
		dat += "<a href='?src=[UID()];f12=1'>[food_slots[12]]</a><br>"
	if(food_slots[13])
		dat += "<a href='?src=[UID()];f13=1'>[food_slots[13]]</a><br>"
	if(food_slots[14])
		dat += "<a href='?src=[UID()];f14=1'>[food_slots[14]]</a><br>"
	if(food_slots[15])
		dat += "<a href='?src=[UID()];f15=1'>[food_slots[15]]</a><br>"
	if(drink_slots[1])
		dat += "<a href='?src=[UID()];d1=1'>[drink_slots[1]]</a><br>"
	if(drink_slots[2])
		dat += "<a href='?src=[UID()];d2=1'>[drink_slots[2]]</a><br>"
	if(drink_slots[3])
		dat += "<a href='?src=[UID()];d3=1'>[drink_slots[3]]</a><br>"
	if(drink_slots[4])
		dat += "<a href='?src=[UID()];d4=1'>[drink_slots[4]]</a><br>"
	if(drink_slots[5])
		dat += "<a href='?src=[UID()];d5=1'>[drink_slots[5]]</a><br>"
	if(drink_slots[6])
		dat += "<a href='?src=[UID()];d6=1'>[drink_slots[6]]</a><br>"
	if(drink_slots[7])
		dat += "<a href='?src=[UID()];d7=1'>[drink_slots[7]]</a><br>"
	if(drink_slots[8])
		dat += "<a href='?src=[UID()];d8=1'>[drink_slots[8]]</a><br>"
	if(drink_slots[9])
		dat += "<a href='?src=[UID()];d9=1'>[drink_slots[9]]</a><br>"
	if(drink_slots[10])
		dat += "<a href='?src=[UID()];d10=1'>[drink_slots[10]]</a><br>"
	if(drink_slots[11])
		dat += "<a href='?src=[UID()];d11=1'>[drink_slots[11]]</a><br>"
	if(drink_slots[12])
		dat += "<a href='?src=[UID()];d12=1'>[drink_slots[12]]</a><br>"
	if(drink_slots[13])
		dat += "<a href='?src=[UID()];d13=1'>[drink_slots[13]]</a><br>"
	if(drink_slots[14])
		dat += "<a href='?src=[UID()];d14=1'>[drink_slots[14]]</a><br>"
	if(drink_slots[15])
		dat += "<a href='?src=[UID()];d15=1'>[drink_slots[15]]</a><br>"
	var/datum/browser/popup = new(user, "foodcart", name, 240, 160)
	popup.set_content(dat)
	popup.open()

/obj/structure/foodcart/Topic(href, href_list)
	if(!in_range(src, usr))
		return
	if(!isliving(usr))
		return
	var/mob/living/user = usr
	if(href_list["f1"])
		if(food_slots[1])
			user.put_in_hands(food_slots[1])
			to_chat(user, "<span class='notice'>You take [food_slots[1]] from [src].</span>")
			food_slots[1] = null
	if(href_list["f2"])
		if(food_slots[2])
			user.put_in_hands(food_slots[2])
			to_chat(user, "<span class='notice'>You take [food_slots[2]] from [src].</span>")
			food_slots[2] = null
	if(href_list["f3"])
		if(food_slots[3])
			user.put_in_hands(food_slots[3])
			to_chat(user, "<span class='notice'>You take [food_slots[3]] from [src].</span>")
			food_slots[3] = null
	if(href_list["f4"])
		if(food_slots[4])
			user.put_in_hands(food_slots[4])
			to_chat(user, "<span class='notice'>You take [food_slots[4]] from [src].</span>")
			food_slots[4] = null
	if(href_list["f5"])
		if(food_slots[5])
			user.put_in_hands(food_slots[5])
			to_chat(user, "<span class='notice'>You take [food_slots[5]] from [src].</span>")
			food_slots[5] = null
	if(href_list["f6"])
		if(food_slots[6])
			user.put_in_hands(food_slots[6])
			to_chat(user, "<span class='notice'>You take [food_slots[6]] from [src].</span>")
			food_slots[6] = null
	if(href_list["f7"])
		if(food_slots[7])
			user.put_in_hands(food_slots[7])
			to_chat(user, "<span class='notice'>You take [food_slots[7]] from [src].</span>")
			food_slots[7] = null
	if(href_list["f8"])
		if(food_slots[8])
			user.put_in_hands(food_slots[8])
			to_chat(user, "<span class='notice'>You take [food_slots[8]] from [src].</span>")
			food_slots[8] = null
	if(href_list["f9"])
		if(food_slots[9])
			user.put_in_hands(food_slots[9])
			to_chat(user, "<span class='notice'>You take [food_slots[9]] from [src].</span>")
			food_slots[9] = null
	if(href_list["f10"])
		if(food_slots[10])
			user.put_in_hands(food_slots[10])
			to_chat(user, "<span class='notice'>You take [food_slots[10]] from [src].</span>")
			food_slots[10] = null
	if(href_list["f11"])
		if(food_slots[11])
			user.put_in_hands(food_slots[11])
			to_chat(user, "<span class='notice'>You take [food_slots[11]] from [src].</span>")
			food_slots[11] = null
	if(href_list["f12"])
		if(food_slots[12])
			user.put_in_hands(food_slots[12])
			to_chat(user, "<span class='notice'>You take [food_slots[12]] from [src].</span>")
			food_slots[12] = null
	if(href_list["f13"])
		if(food_slots[13])
			user.put_in_hands(food_slots[13])
			to_chat(user, "<span class='notice'>You take [food_slots[13]] from [src].</span>")
			food_slots[13] = null
	if(href_list["f14"])
		if(food_slots[14])
			user.put_in_hands(food_slots[14])
			to_chat(user, "<span class='notice'>You take [food_slots[14]] from [src].</span>")
			food_slots[14] = null
	if(href_list["f15"])
		if(food_slots[15])
			user.put_in_hands(food_slots[15])
			to_chat(user, "<span class='notice'>You take [food_slots[15]] from [src].</span>")
			food_slots[15] = null
	if(href_list["d1"])
		if(drink_slots[1])
			user.put_in_hands(drink_slots[1])
			to_chat(user, "<span class='notice'>You take [drink_slots[1]] from [src].</span>")
			drink_slots[1] = null
	if(href_list["d2"])
		if(drink_slots[2])
			user.put_in_hands(drink_slots[2])
			to_chat(user, "<span class='notice'>You take [drink_slots[2]] from [src].</span>")
			drink_slots[2] = null
	if(href_list["d3"])
		if(drink_slots[3])
			user.put_in_hands(drink_slots[3])
			to_chat(user, "<span class='notice'>You take [drink_slots[3]] from [src].</span>")
			drink_slots[3] = null
	if(href_list["d4"])
		if(drink_slots[4])
			user.put_in_hands(drink_slots[4])
			to_chat(user, "<span class='notice'>You take [drink_slots[4]] from [src].</span>")
			drink_slots[4] = null
	if(href_list["d5"])
		if(drink_slots[5])
			user.put_in_hands(drink_slots[5])
			to_chat(user, "<span class='notice'>You take [drink_slots[5]] from [src].</span>")
			drink_slots[5] = null
	if(href_list["d6"])
		if(drink_slots[6])
			user.put_in_hands(drink_slots[6])
			to_chat(user, "<span class='notice'>You take [drink_slots[6]] from [src].</span>")
			drink_slots[6] = null
	if(href_list["d7"])
		if(drink_slots[7])
			user.put_in_hands(drink_slots[7])
			to_chat(user, "<span class='notice'>You take [drink_slots[7]] from [src].</span>")
			drink_slots[7] = null
	if(href_list["d8"])
		if(drink_slots[8])
			user.put_in_hands(drink_slots[8])
			to_chat(user, "<span class='notice'>You take [drink_slots[8]] from [src].</span>")
			drink_slots[8] = null
	if(href_list["d9"])
		if(drink_slots[9])
			user.put_in_hands(drink_slots[9])
			to_chat(user, "<span class='notice'>You take [drink_slots[9]] from [src].</span>")
			drink_slots[9] = null
	if(href_list["d10"])
		if(drink_slots[10])
			user.put_in_hands(drink_slots[10])
			to_chat(user, "<span class='notice'>You take [drink_slots[10]] from [src].</span>")
			drink_slots[10] = null
	if(href_list["d11"])
		if(drink_slots[11])
			user.put_in_hands(drink_slots[11])
			to_chat(user, "<span class='notice'>You take [drink_slots[11]] from [src].</span>")
			drink_slots[11] = null
	if(href_list["d12"])
		if(drink_slots[12])
			user.put_in_hands(drink_slots[12])
			to_chat(user, "<span class='notice'>You take [drink_slots[12]] from [src].</span>")
			drink_slots[12] = null
	if(href_list["d13"])
		if(drink_slots[13])
			user.put_in_hands(drink_slots[13])
			to_chat(user, "<span class='notice'>You take [drink_slots[13]] from [src].</span>")
			drink_slots[13] = null
	if(href_list["d14"])
		if(drink_slots[14])
			user.put_in_hands(drink_slots[14])
			to_chat(user, "<span class='notice'>You take [drink_slots[14]] from [src].</span>")
			drink_slots[14] = null
	if(href_list["d15"])
		if(drink_slots[15])
			user.put_in_hands(drink_slots[15])
			to_chat(user, "<span class='notice'>You take [drink_slots[15]] from [src].</span>")
			drink_slots[15] = null

	update_icon()		//Not really needed without overlays, but keeping just in case
	updateUsrDialog()

/obj/structure/foodcart/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/metal(loc, 4)
	qdel(src)
