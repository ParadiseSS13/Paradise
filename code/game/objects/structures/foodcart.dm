/obj/structure/foodcart
	name = "food cart"
	desc = "A cart for transporting food and drinks."
	icon = 'icons/obj/foodcart.dmi'
	icon_state = "cart"
	anchored = 0
	density = 1
	//Food slots
	var/obj/item/weapon/reagent_containers/food/snacks/food1 = null
	var/obj/item/weapon/reagent_containers/food/snacks/food2 = null
	var/obj/item/weapon/reagent_containers/food/snacks/food3 = null
	var/obj/item/weapon/reagent_containers/food/snacks/food4 = null
	var/obj/item/weapon/reagent_containers/food/snacks/food5 = null
	var/obj/item/weapon/reagent_containers/food/snacks/food6 = null
	//Drink slots
	var/obj/item/weapon/reagent_containers/food/drinks/drink1 = null
	var/obj/item/weapon/reagent_containers/food/drinks/drink2 = null
	var/obj/item/weapon/reagent_containers/food/drinks/drink3 = null
	var/obj/item/weapon/reagent_containers/food/drinks/drink4 = null
	var/obj/item/weapon/reagent_containers/food/drinks/drink5 = null
	var/obj/item/weapon/reagent_containers/food/drinks/drink6 = null

/obj/structure/foodcart/proc/put_in_cart(obj/item/I, mob/user)
	user.drop_item()
	I.loc = src
	updateUsrDialog()
	user << "<span class='notice'>You put [I] into [src].</span>"
	return

/obj/structure/foodcart/attackby(obj/item/I, mob/user)
	var/fail_msg = "<span class='notice'>There are no open spaces for this in [src].</span>"
	if(!I.is_robot_module())
		if(istype(I, /obj/item/weapon/reagent_containers/food/snacks))
			if(!food1)
				put_in_cart(I, user)
				food1=I
				update_icon()
			else if(!food2)
				put_in_cart(I, user)
				food2=I
				update_icon()
			else if(!food3)
				put_in_cart(I, user)
				food3=I
				update_icon()
			else if(!food4)
				put_in_cart(I, user)
				food4=I
				update_icon()
			else if(!food5)
				put_in_cart(I, user)
				food5=I
				update_icon()
			else if(!food6)
				put_in_cart(I, user)
				food6=I
				update_icon()
			else
				user << fail_msg
		else if(istype(I, /obj/item/weapon/reagent_containers/food/drinks))
			if(!drink1)
				put_in_cart(I, user)
				drink1=I
				update_icon()
			else if(!drink2)
				put_in_cart(I, user)
				drink2=I
				update_icon()
			else if(!drink3)
				put_in_cart(I, user)
				drink3=I
				update_icon()
			else if(!drink4)
				put_in_cart(I, user)
				drink4=I
				update_icon()
			else if(!drink5)
				put_in_cart(I, user)
				drink5=I
				update_icon()
			else if(!drink6)
				put_in_cart(I, user)
				drink6=I
				update_icon()
			else
				user << fail_msg
	else
		usr << "<span class='warning'>You cannot interface your modules [src]!</span>"

/obj/structure/foodcart/attack_hand(mob/user)
	user.set_machine(src)
	var/dat
	if(food1)
		dat += "<a href='?src=\ref[src];f1=1'>[food1.name]</a><br>"
	if(food2)
		dat += "<a href='?src=\ref[src];f2=1'>[food2.name]</a><br>"
	if(food3)
		dat += "<a href='?src=\ref[src];f3=1'>[food3.name]</a><br>"
	if(food4)
		dat += "<a href='?src=\ref[src];f4=1'>[food4.name]</a><br>"
	if(food5)
		dat += "<a href='?src=\ref[src];f5=1'>[food5.name]</a><br>"
	if(food6)
		dat += "<a href='?src=\ref[src];f6=1'>[food6.name]</a><br>"
	if(drink1)
		dat += "<a href='?src=\ref[src];d1=1'>[drink1.name]</a><br>"
	if(drink2)
		dat += "<a href='?src=\ref[src];d2=1'>[drink2.name]</a><br>"
	if(drink3)
		dat += "<a href='?src=\ref[src];d3=1'>[drink3.name]</a><br>"
	if(drink4)
		dat += "<a href='?src=\ref[src];d4=1'>[drink4.name]</a><br>"
	if(drink5)
		dat += "<a href='?src=\ref[src];d5=1'>[drink5.name]</a><br>"
	if(drink6)
		dat += "<a href='?src=\ref[src];d6=1'>[drink6.name]</a><br>"
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
		if(food1)
			user.put_in_hands(food1)
			user << "<span class='notice'>You take [food1] from [src].</span>"
			food1 = null
	if(href_list["f2"])
		if(food2)
			user.put_in_hands(food2)
			user << "<span class='notice'>You take [food2] from [src].</span>"
			food2 = null
	if(href_list["f3"])
		if(food3)
			user.put_in_hands(food3)
			user << "<span class='notice'>You take [food3] from [src].</span>"
			food3 = null
	if(href_list["f4"])
		if(food4)
			user.put_in_hands(food4)
			user << "<span class='notice'>You take [food4] from [src].</span>"
			food4 = null
	if(href_list["f5"])
		if(food5)
			user.put_in_hands(food5)
			user << "<span class='notice'>You take [food5] from [src].</span>"
			food5 = null
	if(href_list["f6"])
		if(food6)
			user.put_in_hands(food6)
			user << "<span class='notice'>You take [food6] from [src].</span>"
			food6 = null
	if(href_list["d1"])
		if(drink1)
			user.put_in_hands(drink1)
			user << "<span class='notice'>You take [drink1] from [src].</span>"
			drink1 = null
	if(href_list["d2"])
		if(drink2)
			user.put_in_hands(drink2)
			user << "<span class='notice'>You take [drink2] from [src].</span>"
			drink2 = null
	if(href_list["d3"])
		if(drink3)
			user.put_in_hands(drink3)
			user << "<span class='notice'>You take [drink3] from [src].</span>"
			drink3 = null
	if(href_list["d4"])
		if(drink4)
			user.put_in_hands(drink4)
			user << "<span class='notice'>You take [drink4] from [src].</span>"
			drink4 = null
	if(href_list["d5"])
		if(drink5)
			user.put_in_hands(drink5)
			user << "<span class='notice'>You take [drink5] from [src].</span>"
			drink5 = null
	if(href_list["d6"])
		if(drink6)
			user.put_in_hands(drink6)
			user << "<span class='notice'>You take [drink6] from [src].</span>"
			drink6 = null

	update_icon()
	updateUsrDialog()

/obj/structure/foodcart/update_icon()
	overlays = null
	if(food1)
		overlays += "cart_food1"
	if(food2)
		overlays += "cart_food2"
	if(food3)
		overlays += "cart_food3"
	if(food4)
		overlays += "cart_food4"
	if(food5)
		overlays += "cart_food5"
	if(food6)
		overlays += "cart_food6"
	if(drink1)
		overlays += "cart_drink1"
	if(drink2)
		overlays += "cart_drink2"
	if(drink3)
		overlays += "cart_drink3"
	if(drink4)
		overlays += "cart_drink4"
	if(drink5)
		overlays += "cart_drink5"
	if(drink6)
		overlays += "cart_drink6"