/*
CONTAINS:
BEDSHEETS
LINEN BINS
*/

/obj/item/weapon/bedsheet
	name = "bedsheet"
	desc = "A surprisingly soft linen bedsheet."
	icon = 'icons/obj/items.dmi'
	icon_state = "sheet"
	item_state = "bedsheet"
	layer = 4.0
	throwforce = 1
	throw_speed = 1
	throw_range = 2
	w_class = 1.0
	_color = "white"
	slot_flags = SLOT_BACK


/obj/item/weapon/bedsheet/attack_self(mob/user as mob)
	user.drop_item()
	if(layer == initial(layer))
		layer = 5
	else
		layer = initial(layer)
	add_fingerprint(user)
	return


/obj/item/weapon/bedsheet/blue
	icon_state = "sheetblue"
	_color = "blue"

/obj/item/weapon/bedsheet/green
	icon_state = "sheetgreen"
	_color = "green"

/obj/item/weapon/bedsheet/orange
	icon_state = "sheetorange"
	_color = "orange"

/obj/item/weapon/bedsheet/purple
	icon_state = "sheetpurple"
	_color = "purple"

/obj/item/weapon/bedsheet/rainbow
	name = "rainbow bedsheet"
	desc = "A multi_colored blanket.  It's actually several different sheets cut up and sewn together."
	icon_state = "sheetrainbow"
	_color = "rainbow"

/obj/item/weapon/bedsheet/red
	icon_state = "sheetred"
	_color = "red"

/obj/item/weapon/bedsheet/yellow
	icon_state = "sheetyellow"
	_color = "yellow"

/obj/item/weapon/bedsheet/mime
	name = "mime's blanket"
	desc = "A very soothing striped blanket.  All the noise just seems to fade out when you're under the covers in this."
	icon_state = "sheetmime"
	_color = "mime"

/obj/item/weapon/bedsheet/clown
	name = "clown's blanket"
	desc = "A rainbow blanket with a clown mask woven in.  It smells faintly of bananas."
	icon_state = "sheetclown"
	_color = "clown"

/obj/item/weapon/bedsheet/captain
	name = "captain's bedsheet."
	desc = "It has a Nanotrasen symbol on it, and was woven with a revolutionary new kind of thread guaranteed to have 0.01% permeability for most non-chemical substances, popular among most modern captains."
	icon_state = "sheetcaptain"
	_color = "captain"

/obj/item/weapon/bedsheet/rd
	name = "research director's bedsheet"
	desc = "It appears to have a beaker emblem, and is made out of fire-resistant material, although it probably won't protect you in the event of fires you're familiar with every day."
	icon_state = "sheetrd"
	_color = "director"

/obj/item/weapon/bedsheet/medical
	name = "medical blanket"
	desc = "It's a sterilized* blanket commonly used in the Medbay.  *Sterilization is voided if a virologist is present onboard the station."
	icon_state = "sheetmedical"
	_color = "medical"

/obj/item/weapon/bedsheet/cmo
	name = "chief medical officer's bedsheet"
	desc = "It's a sterilized blanket that has a cross emblem.  There's some cat fur on it, likely from Runtime."
	icon_state = "sheetcmo"
	_color = "cmo"

/obj/item/weapon/bedsheet/hos
	name = "head of security's bedsheet"
	desc = "It is decorated with a shield emblem.  While crime doesn't sleep, you do, but you are still THE LAW!"
	icon_state = "sheethos"
	_color = "hosred"

/obj/item/weapon/bedsheet/hop
	name = "head of personnel's bedsheet"
	desc = "It is decorated with a key emblem.  For those rare moments when you can rest and cuddle with Ian without someone screaming for you over the radio."
	icon_state = "sheethop"
	_color = "hop"

/obj/item/weapon/bedsheet/ce
	name = "chief engineer's bedsheet"
	desc = "It is decorated with a wrench emblem.  It's highly reflective and stain resistant, so you don't need to worry about ruining it with oil."
	icon_state = "sheetce"
	_color = "chief"

/obj/item/weapon/bedsheet/qm
	name = "quartermaster's bedsheet"
	desc = "It is decorated with a crate emblem in silver lining.  It's rather tough, and just the thing to lie on after a hard day of pushing paper."
	icon_state = "sheetqm"
	_color = "qm"

/obj/item/weapon/bedsheet/brown
	icon_state = "sheetbrown"
	_color = "cargo"

/obj/item/weapon/bedsheet/centcom
	name = "centcom bedsheet"
	desc = "Woven with advanced nanothread for warmth as well as being very decorated, essential for all officials."
	icon_state = "sheetcentcom"
	_color = "centcom"

/obj/item/weapon/bedsheet/syndie
	name = "syndicate bedsheet"
	desc = "It has a syndicate emblem and it has an aura of evil."
	icon_state = "sheetsyndie"
	_color = "syndie"

/obj/item/weapon/bedsheet/cult
	name = "cultist's bedsheet"
	desc = "You might dream of Nar'Sie if you sleep with this.  It seems rather tattered and glows of an eldritch presence."
	icon_state = "sheetcult"
	_color = "cult"

/obj/item/weapon/bedsheet/wiz
	name = "wizard's bedsheet"
	desc = "A special fabric enchanted with magic so you can have an enchanted night.  It even glows!"
	icon_state = "sheetwiz"
	_color = "wiz"



/obj/structure/bedsheetbin
	name = "linen bin"
	desc = "A linen bin. It looks rather cosy."
	icon = 'icons/obj/structures.dmi'
	icon_state = "linenbin-full"
	anchored = 1
	var/amount = 20
	var/list/sheets = list()
	var/obj/item/hidden = null


/obj/structure/bedsheetbin/examine()
	usr << desc
	if(amount < 1)
		usr << "There are no bed sheets in the bin."
		return
	if(amount == 1)
		usr << "There is one bed sheet in the bin."
		return
	usr << "There are [amount] bed sheets in the bin."


/obj/structure/bedsheetbin/update_icon()
	switch(amount)
		if(0)				icon_state = "linenbin-empty"
		if(1 to amount / 2)	icon_state = "linenbin-half"
		else				icon_state = "linenbin-full"


/obj/structure/bedsheetbin/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/weapon/bedsheet))
		user.drop_item()
		I.loc = src
		sheets.Add(I)
		amount++
		user << "<span class='notice'>You put [I] in [src].</span>"
	else if(amount && !hidden && I.w_class < 4)	//make sure there's sheets to hide it among, make sure nothing else is hidden in there.
		user.drop_item()
		I.loc = src
		hidden = I
		user << "<span class='notice'>You hide [I] among the sheets.</span>"



/obj/structure/bedsheetbin/attack_paw(mob/user as mob)
	return attack_hand(user)


/obj/structure/bedsheetbin/attack_hand(mob/user as mob)
	if(amount >= 1)
		amount--

		var/obj/item/weapon/bedsheet/B
		if(sheets.len > 0)
			B = sheets[sheets.len]
			sheets.Remove(B)

		else
			B = new /obj/item/weapon/bedsheet(loc)

		B.loc = user.loc
		user.put_in_hands(B)
		user << "<span class='notice'>You take [B] out of [src].</span>"

		if(hidden)
			hidden.loc = user.loc
			user << "<span class='notice'>[hidden] falls out of [B]!</span>"
			hidden = null


	add_fingerprint(user)


/obj/structure/bedsheetbin/attack_tk(mob/user as mob)
	if(amount >= 1)
		amount--

		var/obj/item/weapon/bedsheet/B
		if(sheets.len > 0)
			B = sheets[sheets.len]
			sheets.Remove(B)

		else
			B = new /obj/item/weapon/bedsheet(loc)

		B.loc = loc
		user << "<span class='notice'>You telekinetically remove [B] from [src].</span>"
		update_icon()

		if(hidden)
			hidden.loc = loc
			hidden = null