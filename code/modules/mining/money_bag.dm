/*****************************Money bag********************************/

/obj/item/moneybag
	icon = 'icons/obj/storage.dmi'
	name = "Money bag"
	icon_state = "moneybag"
	flags = CONDUCT
	force = 10.0
	throwforce = 0
	burn_state = FLAMMABLE
	burntime = 20
	w_class = WEIGHT_CLASS_BULKY

/obj/item/moneybag/attack_hand(user as mob)
	var/amt_gold = 0
	var/amt_silver = 0
	var/amt_diamond = 0
	var/amt_iron = 0
	var/amt_plasma = 0
	var/amt_uranium = 0
	var/amt_clown = 0
	var/amt_mime = 0
	var/amt_adamantine = 0

	for(var/obj/item/coin/C in contents)
		if(istype(C,/obj/item/coin/diamond))
			amt_diamond++
		if(istype(C,/obj/item/coin/plasma))
			amt_plasma++
		if(istype(C,/obj/item/coin/iron))
			amt_iron++
		if(istype(C,/obj/item/coin/silver))
			amt_silver++
		if(istype(C,/obj/item/coin/gold))
			amt_gold++
		if(istype(C,/obj/item/coin/uranium))
			amt_uranium++
		if(istype(C,/obj/item/coin/clown))
			amt_clown++
		if(istype(C,/obj/item/coin/mime))
			amt_mime++
		if(istype(C,/obj/item/coin/adamantine))
			amt_adamantine++

	var/dat = text("<b>The contents of the moneybag reveal...</b><br>")
	if(amt_gold)
		dat += text("Gold coins: [amt_gold] <A href='?src=[UID()];remove=gold'>Remove one</A><br>")
	if(amt_silver)
		dat += text("Silver coins: [amt_silver] <A href='?src=[UID()];remove=silver'>Remove one</A><br>")
	if(amt_iron)
		dat += text("Metal coins: [amt_iron] <A href='?src=[UID()];remove=iron'>Remove one</A><br>")
	if(amt_diamond)
		dat += text("Diamond coins: [amt_diamond] <A href='?src=[UID()];remove=diamond'>Remove one</A><br>")
	if(amt_plasma)
		dat += text("Plasma coins: [amt_plasma] <A href='?src=[UID()];remove=plasma'>Remove one</A><br>")
	if(amt_uranium)
		dat += text("Uranium coins: [amt_uranium] <A href='?src=[UID()];remove=uranium'>Remove one</A><br>")
	if(amt_clown)
		dat += text("Bananium coins: [amt_clown] <A href='?src=[UID()];remove=clown'>Remove one</A><br>")
	if(amt_mime)
		dat += text("Tranquillite coins: [amt_mime] <A href='?src=[UID()];remove=mime'>Remove one</A><br>")
	if(amt_adamantine)
		dat += text("Adamantine coins: [amt_adamantine] <A href='?src=[UID()];remove=adamantine'>Remove one</A><br>")
	user << browse("[dat]", "window=moneybag")

/obj/item/moneybag/attackby(obj/item/W as obj, mob/user as mob, params)
	..()
	if(istype(W, /obj/item/coin))
		var/obj/item/coin/C = W
		if(!user.drop_item())
			return
		to_chat(user, "<span class='notice'>You add the [C.name] into the bag.</span>")
		contents += C
	if(istype(W, /obj/item/moneybag))
		var/obj/item/moneybag/C = W
		for(var/obj/O in C.contents)
			contents += O;
		to_chat(user, "<span class='notice'>You empty the [C.name] into the bag.</span>")
	return

/obj/item/moneybag/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(href_list["remove"])
		var/obj/item/coin/COIN
		switch(href_list["remove"])
			if("gold")
				COIN = locate(/obj/item/coin/gold,src.contents)
			if("silver")
				COIN = locate(/obj/item/coin/silver,src.contents)
			if("iron")
				COIN = locate(/obj/item/coin/iron,src.contents)
			if("diamond")
				COIN = locate(/obj/item/coin/diamond,src.contents)
			if("plasma")
				COIN = locate(/obj/item/coin/plasma,src.contents)
			if("uranium")
				COIN = locate(/obj/item/coin/uranium,src.contents)
			if("clown")
				COIN = locate(/obj/item/coin/clown,src.contents)
			if("mime")
				COIN = locate(/obj/item/coin/mime,src.contents)
			if("adamantine")
				COIN = locate(/obj/item/coin/adamantine,src.contents)
		if(!COIN)
			return
		COIN.loc = src.loc
	return

/obj/item/moneybag/vault

/obj/item/moneybag/vault/New()
	..()
	new /obj/item/coin/silver(src)
	new /obj/item/coin/silver(src)
	new /obj/item/coin/silver(src)
	new /obj/item/coin/silver(src)
	new /obj/item/coin/gold(src)
	new /obj/item/coin/gold(src)
	new /obj/item/coin/adamantine(src)
