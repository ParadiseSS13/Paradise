/*
CONTAINS:
BEDSHEETS
LINEN BINS
*/

/obj/item/bedsheet
	name = "bedsheet"
	desc = "A surprisingly soft linen bedsheet."
	icon = 'icons/obj/items.dmi'
	icon_state = "sheet"
	item_state = "bedsheet"
	layer = 4.0
	throwforce = 1
	throw_speed = 1
	throw_range = 2
	w_class = WEIGHT_CLASS_TINY
	item_color = "white"
	burn_state = FLAMMABLE
	slot_flags = SLOT_BACK

	var/list/dream_messages = list("white")
	var/list/nightmare_messages = list("black")
	var/comfort = 0.5



/obj/item/bedsheet/attack_self(mob/user as mob)
	user.drop_item()
	if(layer == initial(layer))
		layer = 5
	else
		layer = initial(layer)
	add_fingerprint(user)
	return


/obj/item/bedsheet/blue
	icon_state = "sheetblue"
	item_color = "blue"
	dream_messages = list("blue")
	nightmare_messages = list("vox blood")

/obj/item/bedsheet/green
	icon_state = "sheetgreen"
	item_color = "green"
	dream_messages = list("green")
	nightmare_messages = list("unathi flesh")

/obj/item/bedsheet/orange
	icon_state = "sheetorange"
	item_color = "orange"
	dream_messages = list("orange")
	nightmare_messages = list("exploding fruit")

/obj/item/bedsheet/purple
	icon_state = "sheetpurple"
	item_color = "purple"
	dream_messages = list("purple")
	nightmare_messages = list("Grey blood")

/obj/item/bedsheet/patriot
	name = "patriotic bedsheet"
	desc = "You've never felt more free than when sleeping on this."
	icon_state = "sheetUSA"
	item_color = "sheetUSA"
	dream_messages = list("America", "freedom", "fireworks", "bald eagles")
	nightmare_messages = list("communism")

/obj/item/bedsheet/rainbow
	name = "rainbow bedsheet"
	desc = "A multi_colored blanket.  It's actually several different sheets cut up and sewn together."
	icon_state = "sheetrainbow"
	item_color = "rainbow"
	dream_messages = list("red", "orange", "yellow", "green", "blue", "purple", "a rainbow")
	nightmare_messages = list("green", "a cluwne", "fLoOr ClUwNe")

/obj/item/bedsheet/red
	icon_state = "sheetred"
	item_color = "red"
	dream_messages = list("red")
	nightmare_messages = list("gibs")

/obj/item/bedsheet/yellow
	icon_state = "sheetyellow"
	item_color = "yellow"
	dream_messages = list("yellow")
	nightmare_messages = list("locker full of banana peels")

/obj/item/bedsheet/mime
	name = "mime's blanket"
	desc = "A very soothing striped blanket.  All the noise just seems to fade out when you're under the covers in this."
	icon_state = "sheetmime"
	item_color = "mime"
	dream_messages = list("silence", "gestures", "a pale face", "a gaping mouth", "the mime")
	nightmare_messages = list("honk", "laughter", "a prank", "a joke", "a smiling face", "the clown")

/obj/item/bedsheet/clown
	name = "clown's blanket"
	desc = "A rainbow blanket with a clown mask woven in.  It smells faintly of bananas."
	icon_state = "sheetclown"
	item_color = "clown"
	dream_messages = list("honk", "laughter", "a prank", "a joke", "a smiling face", "the clown")
	nightmare_messages = list("silence", "gestures", "a pale face", "a gaping mouth", "the mime")

/obj/item/bedsheet/captain
	name = "captain's bedsheet."
	desc = "It has a Nanotrasen symbol on it, and was woven with a revolutionary new kind of thread guaranteed to have 0.01% permeability for most non-chemical substances, popular among most modern captains."
	icon_state = "sheetcaptain"
	item_color = "captain"
	dream_messages = list("authority", "a golden ID", "sunglasses", "a green disc", "an antique gun", "the captain")
	nightmare_messages = list("comdom", "clown with all access", "the syndicate")

/obj/item/bedsheet/rd
	name = "research director's bedsheet"
	desc = "It appears to have a beaker emblem, and is made out of fire-resistant material, although it probably won't protect you in the event of fires you're familiar with every day."
	icon_state = "sheetrd"
	item_color = "director"
	dream_messages = list("authority", "a silvery ID", "a bomb", "a mech", "a facehugger", "maniacal laughter", "the research director")
	nightmare_messages = list("toxins full of plasma", "UPGRADE THE SLEEPERS", "rogue ai")

/obj/item/bedsheet/rd/royal_cape
	name = "Royal Cape of the Liberator"
	desc = "Majestic."
	dream_messages = list("mining", "stone", "a golem", "freedom", "doing whatever")

/obj/item/bedsheet/medical
	name = "medical blanket"
	desc = "It's a sterilized* blanket commonly used in the Medbay.  *Sterilization is voided if a virologist is present onboard the station."
	icon_state = "sheetmedical"
	item_color = "medical"
	dream_messages = list("healing", "life", "surgery", "a doctor")
	nightmare_messages = list("death", "no cryox", "cryo is off")

/obj/item/bedsheet/cmo
	name = "chief medical officer's bedsheet"
	desc = "It's a sterilized blanket that has a cross emblem.  There's some cat fur on it, likely from Runtime."
	icon_state = "sheetcmo"
	item_color = "cmo"
	dream_messages = list("authority", "a silvery ID", "healing", "life", "surgery", "a cat", "the chief medical officer")
	nightmare_messages = list("chemists making meth", "cryo it off", "where is the defib", "no biomass")

/obj/item/bedsheet/hos
	name = "head of security's bedsheet"
	desc = "It is decorated with a shield emblem.  While crime doesn't sleep, you do, but you are still THE LAW!"
	icon_state = "sheethos"
	item_color = "hosred"
	dream_messages = list("authority", "a silvery ID", "handcuffs", "a baton", "a flashbang", "sunglasses", "the head of security")
	nightmare_messages = list("the clown", "a toolbox", "sHiTcUrItY", "why did you put them in for 50 minutes")


/obj/item/bedsheet/hop
	name = "head of personnel's bedsheet"
	desc = "It is decorated with a key emblem.  For those rare moments when you can rest and cuddle with Ian without someone screaming for you over the radio."
	icon_state = "sheethop"
	item_color = "hop"
	dream_messages = list("authority", "a silvery ID", "obligation", "a computer", "an ID", "a corgi", "the head of personnel")
	nightmare_messages = list("improper paperwork", "all access clown", "50 open clown slots", "dead ian")

/obj/item/bedsheet/ce
	name = "chief engineer's bedsheet"
	desc = "It is decorated with a wrench emblem.  It's highly reflective and stain resistant, so you don't need to worry about ruining it with oil."
	icon_state = "sheetce"
	item_color = "chief"
	dream_messages = list("authority", "a silvery ID", "the engine", "power tools", "an APC", "a parrot", "the chief engineer")
	nightmare_messages = list("forced airlock", "syndicate bomb", "explosion in research chem", "iT's LoOsE")

/obj/item/bedsheet/qm
	name = "quartermaster's bedsheet"
	desc = "It is decorated with a crate emblem in silver lining.  It's rather tough, and just the thing to lie on after a hard day of pushing paper."
	icon_state = "sheetqm"
	item_color = "qm"
	dream_messages = list("a grey ID", "a shuttle", "a crate", "a sloth", "the quartermaster")
	nightmare_messages = list("a bald person", "no points", "wheres the ore", "space carp")

/obj/item/bedsheet/brown
	icon_state = "sheetbrown"
	item_color = "cargo"
	dream_messages = list("brown")
	nightmare_messages = list("dead monkey")

/obj/item/bedsheet/centcom
	name = "centcom bedsheet"
	desc = "Woven with advanced nanothread for warmth as well as being very decorated, essential for all officials."
	icon_state = "sheetcentcom"
	item_color = "centcom"
	dream_messages = list("a unique ID", "authority", "artillery", "an ending")
	nightmare_messages = list("a butt fax")

/obj/item/bedsheet/syndie
	name = "syndicate bedsheet"
	desc = "It has a syndicate emblem and it has an aura of evil."
	icon_state = "sheetsyndie"
	item_color = "syndie"
	dream_messages = list("a green disc", "a red crystal", "a glowing blade", "a wire-covered ID")
	nightmare_messages = list("stunbaton", "taser", "lasers", "a toolbox")

/obj/item/bedsheet/cult
	name = "cultist's bedsheet"
	desc = "You might dream of Nar'Sie if you sleep with this.  It seems rather tattered and glows of an eldritch presence."
	icon_state = "sheetcult"
	item_color = "cult"
	dream_messages = list("a tome", "a floating red crystal", "a glowing sword", "a bloody symbol", "a massive humanoid figure")
	nightmare_messages = list("a tome", "a floating red crystal", "a glowing sword", "a bloody symbol", "a massive humanoid figure")


/obj/item/bedsheet/wiz
	name = "wizard's bedsheet"
	desc = "A special fabric enchanted with magic so you can have an enchanted night.  It even glows!"
	icon_state = "sheetwiz"
	item_color = "wiz"
	dream_messages = list("a book", "an explosion", "lightning", "a staff", "a skeleton", "a robe", "magic")
	nightmare_messages = list("a toolbox", "solars")



/obj/structure/bedsheetbin
	name = "linen bin"
	desc = "A linen bin. It looks rather cosy."
	icon = 'icons/obj/structures.dmi'
	icon_state = "linenbin-full"
	anchored = 1
	burn_state = FLAMMABLE
	burntime = 20
	var/amount = 20
	var/list/sheets = list()
	var/obj/item/hidden = null


/obj/structure/bedsheetbin/examine(mob/user)
	..(user)
	if(amount < 1)
		to_chat(user, "There are no bed sheets in the bin.")
		return
	if(amount == 1)
		to_chat(user, "There is one bed sheet in the bin.")
		return
	to_chat(user, "There are [amount] bed sheets in the bin.")


/obj/structure/bedsheetbin/update_icon()
	switch(amount)
		if(0)				icon_state = "linenbin-empty"
		if(1 to amount / 2)	icon_state = "linenbin-half"
		else				icon_state = "linenbin-full"


/obj/structure/bedsheetbin/fire_act()
	if(!amount)
		return
	..()

/obj/structure/bedsheetbin/burn()
	amount = 0
	extinguish()
	update_icon()

/obj/structure/bedsheetbin/attackby(obj/item/I as obj, mob/user as mob, params)
	if(istype(I, /obj/item/bedsheet))
		user.drop_item()
		I.loc = src
		sheets.Add(I)
		amount++
		to_chat(user, "<span class='notice'>You put [I] in [src].</span>")
	else if(amount && !hidden && I.w_class < WEIGHT_CLASS_BULKY)	//make sure there's sheets to hide it among, make sure nothing else is hidden in there.
		user.drop_item()
		I.loc = src
		hidden = I
		to_chat(user, "<span class='notice'>You hide [I] among the sheets.</span>")



/obj/structure/bedsheetbin/attack_hand(mob/user as mob)
	if(amount >= 1)
		amount--

		var/obj/item/bedsheet/B
		if(sheets.len > 0)
			B = sheets[sheets.len]
			sheets.Remove(B)

		else
			B = new /obj/item/bedsheet(loc)

		B.loc = user.loc
		user.put_in_hands(B)
		to_chat(user, "<span class='notice'>You take [B] out of [src].</span>")

		if(hidden)
			hidden.loc = user.loc
			to_chat(user, "<span class='notice'>[hidden] falls out of [B]!</span>")
			hidden = null


	add_fingerprint(user)


/obj/structure/bedsheetbin/attack_tk(mob/user as mob)
	if(amount >= 1)
		amount--

		var/obj/item/bedsheet/B
		if(sheets.len > 0)
			B = sheets[sheets.len]
			sheets.Remove(B)

		else
			B = new /obj/item/bedsheet(loc)

		B.loc = loc
		to_chat(user, "<span class='notice'>You telekinetically remove [B] from [src].</span>")
		update_icon()

		if(hidden)
			hidden.loc = loc
			hidden = null
