/*****************************Coin********************************/

/obj/item/weapon/coin
	icon = 'icons/obj/items.dmi'
	name = "coin"
	icon_state = "coin__heads"
	flags = CONDUCT
	force = 1
	throwforce = 2
	w_class = 1
	var/string_attached
	var/list/sideslist = list("heads","tails")
	var/cmineral = null
	var/cooldown = 0
	var/credits = 10

/obj/item/weapon/coin/New()
	pixel_x = rand(0,16)-8
	pixel_y = rand(0,8)-8

	icon_state = "coin_[cmineral]_heads"
	if(cmineral)
		name = "[cmineral] coin"

/obj/item/weapon/coin/gold
	cmineral = "gold"
	icon_state = "coin_gold_heads"
	materials = list(MAT_GOLD = 400)
	credits = 160

/obj/item/weapon/coin/silver
	cmineral = "silver"
	icon_state = "coin_silver_heads"
	materials = list(MAT_SILVER = 400)
	credits = 40

/obj/item/weapon/coin/diamond
	cmineral = "diamond"
	icon_state = "coin_diamond_heads"
	materials = list(MAT_DIAMOND = 400)
	credits = 120

/obj/item/weapon/coin/iron
	cmineral = "iron"
	icon_state = "coin_iron_heads"
	materials = list(MAT_METAL = 400)
	credits = 20

/obj/item/weapon/coin/plasma
	cmineral = "plasma"
	icon_state = "coin_plasma_heads"
	materials = list(MAT_PLASMA = 400)
	credits = 80

/obj/item/weapon/coin/uranium
	cmineral = "uranium"
	icon_state = "coin_uranium_heads"
	materials = list(MAT_URANIUM = 400)
	credits = 160

/obj/item/weapon/coin/clown
	cmineral = "bananium"
	icon_state = "coin_bananium_heads"
	materials = list(MAT_BANANIUM = 400)
	credits = 600 //makes the clown cri

/obj/item/weapon/coin/mime
	cmineral = "tranquillite"
	icon_state = "coin_tranquillite_heads"
	materials = list(MAT_TRANQUILLITE = 400)
	credits = 600 //makes the mime cri

/obj/item/weapon/coin/adamantine
	cmineral = "adamantine"
	icon_state = "coin_adamantine_heads"
	credits = 400

/obj/item/weapon/coin/mythril
	cmineral = "mythril"
	icon_state = "coin_mythril_heads"
	credits = 400

/obj/item/weapon/coin/twoheaded
	cmineral = "iron"
	icon_state = "coin_iron_heads"
	desc = "Hey, this coin's the same on both sides!"
	sideslist = list("heads")
	credits = 20

/obj/item/weapon/coin/antagtoken
	name = "antag token"
	icon_state = "coin_valid_valid"
	cmineral = "valid"
	desc = "A novelty coin that helps the heart know what hard evidence cannot prove."
	sideslist = list("valid", "salad")
	credits = 20

/obj/item/weapon/coin/antagtoken/New()
	return

/obj/item/weapon/coin/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/CC = W
		if(string_attached)
			to_chat(user, "<span class='notice'>There already is a string attached to this coin.</span>")
			return

		if(CC.use(1))
			overlays += image('icons/obj/items.dmi',"coin_string_overlay")
			string_attached = 1
			to_chat(user, "<span class='notice'>You attach a string to the coin.</span>")
		else
			to_chat(user, "<span class='warning'>You need one length of cable to attach a string to the coin.</span>")
			return

	else if(istype(W,/obj/item/weapon/wirecutters))
		if(!string_attached)
			..()
			return

		var/obj/item/stack/cable_coil/CC = new/obj/item/stack/cable_coil(user.loc)
		CC.amount = 1
		CC.update_icon()
		overlays = list()
		string_attached = null
		to_chat(user, "<span class='notice'>You detach the string from the coin.</span>")
	else if(istype(W,/obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(WT.welding && WT.remove_fuel(0, user))
			var/typelist = list("iron" = /obj/item/clothing/gloves/ring,
								"silver" = /obj/item/clothing/gloves/ring/silver,
								"gold" = /obj/item/clothing/gloves/ring/gold,
								"plasma" = /obj/item/clothing/gloves/ring/plasma,
								"uranium" = /obj/item/clothing/gloves/ring/uranium)
			var/typekey = typelist[cmineral]
			if(ispath(typekey))
				to_chat(user, "\blue You make [src] into a ring.")
				new typekey(get_turf(loc))
				qdel(src)
	else ..()

/obj/item/weapon/coin/attack_self(mob/user as mob)
	if(cooldown < world.time - 15)
		var/coinflip = pick(sideslist)
		cooldown = world.time
		flick("coin_[cmineral]_flip", src)
		icon_state = "coin_[cmineral]_[coinflip]"
		playsound(user.loc, 'sound/items/coinflip.ogg', 50, 1)
		if(do_after(user, 15, target = src))
			user.visible_message("<span class='notice'>[user] has flipped [src]. It lands on [coinflip].</span>", \
								 "<span class='notice'>You flip [src]. It lands on [coinflip].</span>", \
								 "<span class='notice'>You hear the clattering of loose change.</span>")