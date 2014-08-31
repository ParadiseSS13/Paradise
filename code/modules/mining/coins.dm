/*****************************Coin********************************/

/obj/item/weapon/coin
	icon = 'icons/obj/items.dmi'
	name = "Coin"
	icon_state = "coin"
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 0.0
	throwforce = 0.0
	w_class = 1.0
	var/string_attached
	var/material="iron" // Ore ID, used with coinbags.
	var/credits = 0 // How many credits is this coin worth?

/obj/item/weapon/coin/New()
	pixel_x = rand(0,16)-8
	pixel_y = rand(0,8)-8

/obj/item/weapon/coin/gold
	name = "Gold coin"
	icon_state = "coin_gold"
	credits = 10

/obj/item/weapon/coin/silver
	name = "Silver coin"
	icon_state = "coin_silver"
	credits = 5

/obj/item/weapon/coin/diamond
	name = "Diamond coin"
	icon_state = "coin_diamond"
	credits = 25

/obj/item/weapon/coin/iron
	name = "Iron coin"
	icon_state = "coin_iron"
	credits = 1

/obj/item/weapon/coin/plasma
	name = "Solid plasma coin"
	icon_state = "coin_plasma"
	credits = 5

/obj/item/weapon/coin/uranium
	name = "Uranium coin"
	icon_state = "coin_uranium"
	credits = 25

/obj/item/weapon/coin/clown
	name = "Bananaium coin"
	icon_state = "coin_clown"
	credits = 1000


/obj/item/weapon/coin/platinum
	name = "platinum coin"
	icon_state = "coin_adamantine"

/obj/item/weapon/coin/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/stack/cable_coil) )
		var/obj/item/stack/cable_coil/CC = W
		if(string_attached)
			user << "\blue There already is a string attached to this coin."
			return

		if(CC.amount <= 0)
			user << "\blue This cable coil appears to be empty."
			del(CC)
			return

		overlays += image('icons/obj/items.dmi',"coin_string_overlay")
		string_attached = 1
		user << "\blue You attach a string to the coin."
		CC.use(1)
	else if(istype(W,/obj/item/weapon/wirecutters) )
		if(!string_attached)
			..()
			return

		var/obj/item/stack/cable_coil/CC = new/obj/item/stack/cable_coil(user.loc)
		CC.amount = 1
//		CC.updateicon()
		overlays = list()
		string_attached = null
		user << "\blue You detach the string from the coin."
	else ..()
