/obj/item/clothing/accessory
	name = "tie"
	desc = "A neosilk clip-on tie."
	icon = 'icons/obj/clothing/ties.dmi'
	icon_state = "bluetie"
	item_state = ""	//no inhands
	_color = "bluetie"
	slot_flags = SLOT_TIE
	w_class = 2.0
	var/slot = "decor"
	var/obj/item/clothing/under/has_suit = null		//the suit the tie may be attached to
	var/image/inv_overlay = null	//overlay used when attached to clothing.

/obj/item/clothing/accessory/New()
	..()
	inv_overlay = image("icon" = 'icons/obj/clothing/ties_overlay.dmi', "icon_state" = "[_color? "[_color]" : "[icon_state]"]")

//when user attached an accessory to S
/obj/item/clothing/accessory/proc/on_attached(obj/item/clothing/under/S, mob/user as mob)
	if(!istype(S))
		return
	has_suit = S
	loc = has_suit
	has_suit.overlays += inv_overlay

	user << "<span class='notice'>You attach [src] to [has_suit].</span>"
	src.add_fingerprint(user)

/obj/item/clothing/accessory/proc/on_removed(mob/user as mob)
	if(!has_suit)
		return
	has_suit.overlays -= inv_overlay
	has_suit = null
	usr.put_in_hands(src)
	src.add_fingerprint(user)

//default attackby behaviour
/obj/item/clothing/accessory/attackby(obj/item/I, mob/user, params)
	..()

//default attack_hand behaviour
/obj/item/clothing/accessory/attack_hand(mob/user as mob)
	if(has_suit)
		return	//we aren't an object on the ground so don't call parent
	..()

/obj/item/clothing/accessory/blue
	name = "blue tie"
	icon_state = "bluetie"
	_color = "bluetie"

/obj/item/clothing/accessory/red
	name = "red tie"
	icon_state = "redtie"
	_color = "redtie"

/obj/item/clothing/accessory/black
	name = "black tie"
	icon_state = "blacktie"
	_color = "blacktie"

/obj/item/clothing/accessory/horrible
	name = "horrible tie"
	desc = "A neosilk clip-on tie. This one is disgusting."
	icon_state = "horribletie"
	_color = "horribletie"

/obj/item/clothing/accessory/waistcoat // No overlay
	name = "waistcoat"
	desc = "For some classy, murderous fun."
	icon_state = "waistcoat"
	item_state = "waistcoat"
	_color = "waistcoat"

/obj/item/clothing/accessory/stethoscope
	name = "stethoscope"
	desc = "An outdated medical apparatus for listening to the sounds of the human body. It also makes you look like you know what you're doing."
	icon_state = "stethoscope"
	_color = "stethoscope"

/obj/item/clothing/accessory/stethoscope/attack(mob/living/carbon/human/M, mob/living/user)
	if(ishuman(M) && isliving(user))
		if(user.a_intent == "help")
			var/body_part = parse_zone(user.zone_sel.selecting)
			if(body_part)
				var/their = "their"
				switch(M.gender)
					if(MALE)	their = "his"
					if(FEMALE)	their = "her"

				var/sound = "pulse"
				var/sound_strength

				if(M.stat == DEAD || (M.status_flags&FAKEDEATH))
					sound_strength = "cannot hear"
					sound = "anything"
				else
					sound_strength = "hear a weak"
					switch(body_part)
						if("chest")
							if(M.oxyloss < 50)
								sound_strength = "hear a healthy"
							sound = "pulse and respiration"
						if("eyes","mouth")
							sound_strength = "cannot hear"
							sound = "anything"
						else
							sound_strength = "hear a weak"

				user.visible_message("[user] places [src] against [M]'s [body_part] and listens attentively.", "You place [src] against [their] [body_part]. You [sound_strength] [sound].")
				return
	return ..(M,user)


//Medals
/obj/item/clothing/accessory/medal
	name = "bronze medal"
	desc = "A bronze medal."
	icon_state = "bronze"
	_color = "bronze"

/obj/item/clothing/accessory/medal/conduct
	name = "distinguished conduct medal"
	desc = "A bronze medal awarded for distinguished conduct. Whilst a great honor, this is most basic award given by Nanotrasen. It is often awarded by a captain to a member of his crew."

/obj/item/clothing/accessory/medal/bronze_heart
	name = "bronze heart medal"
	desc = "A bronze heart-shaped medal awarded for sacrifice. It is often awarded posthumously or for severe injury in the line of duty."
	icon_state = "bronze_heart"

/obj/item/clothing/accessory/medal/nobel_science
	name = "nobel sciences award"
	desc = "A bronze medal which represents significant contributions to the field of science or engineering."

/obj/item/clothing/accessory/medal/silver
	name = "silver medal"
	desc = "A silver medal."
	icon_state = "silver"
	_color = "silver"

/obj/item/clothing/accessory/medal/silver/valor
	name = "medal of valor"
	desc = "A silver medal awarded for acts of exceptional valor."

/obj/item/clothing/accessory/medal/silver/security
	name = "robust security award"
	desc = "An award for distinguished combat and sacrifice in defence of Nanotrasen's commercial interests. Often awarded to security staff."

/obj/item/clothing/accessory/medal/gold
	name = "gold medal"
	desc = "A prestigious golden medal."
	icon_state = "gold"
	_color = "gold"

/obj/item/clothing/accessory/medal/gold/captain
	name = "medal of captaincy"
	desc = "A golden medal awarded exclusively to those promoted to the rank of captain. It signifies the codified responsibilities of a captain to Nanotrasen, and their undisputable authority over their crew."

/obj/item/clothing/accessory/medal/gold/heroism
	name = "medal of exceptional heroism"
	desc = "An extremely rare golden medal awarded only by CentComm. To recieve such a medal is the highest honor and as such, very few exist. This medal is almost never awarded to anybody but commanders."

/*
	Holobadges are worn on the belt or neck, and can be used to show that the holder is an authorized
	Security agent - the user details can be imprinted on the badge with a Security-access ID card,
	or they can be emagged to accept any ID for use in disguises.
*/

/obj/item/clothing/accessory/holobadge
	name = "holobadge"
	desc = "This glowing blue badge marks the holder as THE LAW."
	icon_state = "holobadge"
	_color = "holobadge"
	slot_flags = SLOT_BELT | SLOT_TIE

	var/emagged = 0 //Emagging removes Sec check.
	var/stored_name = null

/obj/item/clothing/accessory/holobadge/cord
	icon_state = "holobadge-cord"
	_color = "holobadge-cord"
	slot_flags = SLOT_MASK | SLOT_TIE

/obj/item/clothing/accessory/holobadge/attack_self(mob/user as mob)
	if(!stored_name)
		user << "Waving around a badge before swiping an ID would be pretty pointless."
		return
	if(isliving(user))
		user.visible_message("\red [user] displays their NanoTrasen Internal Security Legal Authorization Badge.\nIt reads: [stored_name], NT Security.","\red You display your NanoTrasen Internal Security Legal Authorization Badge.\nIt reads: [stored_name], NT Security.")

/obj/item/clothing/accessory/holobadge/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	if(istype(O, /obj/item/weapon/card/id) || istype(O, /obj/item/device/pda))

		var/obj/item/weapon/card/id/id_card = null

		if(istype(O, /obj/item/weapon/card/id))
			id_card = O
		else
			var/obj/item/device/pda/pda = O
			id_card = pda.id

		if(access_security in id_card.access || emagged)
			user << "You imprint your ID details onto the badge."
			stored_name = id_card.registered_name
			name = "holobadge ([stored_name])"
			desc = "This glowing blue badge marks [stored_name] as THE LAW."
		else
			user << "[src] rejects your insufficient access rights."
		return
	..()

/obj/item/clothing/accessory/holobadge/emag_act(user as mob)
	if (emagged)
		user << "\red [src] is already cracked."
		return
	else
		emagged = 1
		user << "\red You swipe the card and crack the holobadge security checks."
		return

/obj/item/clothing/accessory/holobadge/attack(mob/living/carbon/human/M, mob/living/user)
	if(isliving(user))
		user.visible_message("\red [user] invades [M]'s personal space, thrusting [src] into their face insistently.","\red You invade [M]'s personal space, thrusting [src] into their face insistently. You are the law.")

/obj/item/weapon/storage/box/holobadge
	name = "holobadge box"
	desc = "A box claiming to contain holobadges."
	New()
		new /obj/item/clothing/accessory/holobadge(src)
		new /obj/item/clothing/accessory/holobadge(src)
		new /obj/item/clothing/accessory/holobadge(src)
		new /obj/item/clothing/accessory/holobadge(src)
		new /obj/item/clothing/accessory/holobadge/cord(src)
		new /obj/item/clothing/accessory/holobadge/cord(src)
		..()
		return


///////////
//SCARVES//
///////////

/obj/item/clothing/accessory/scarf // No overlay
	name = "scarf"
	desc = "A stylish scarf. The perfect winter accessory for those with a keen fashion sense, and those who just can't handle a cold breeze on their necks."

/obj/item/clothing/accessory/scarf/red
	name = "red scarf"
	icon_state = "redscarf"
	_color = "redscarf"

/obj/item/clothing/accessory/scarf/green
	name = "green scarf"
	icon_state = "greenscarf"
	_color = "greenscarf"

/obj/item/clothing/accessory/scarf/darkblue
	name = "dark blue scarf"
	icon_state = "darkbluescarf"
	_color = "darkbluescarf"

/obj/item/clothing/accessory/scarf/purple
	name = "purple scarf"
	icon_state = "purplescarf"
	_color = "purplescarf"

/obj/item/clothing/accessory/scarf/yellow
	name = "yellow scarf"
	icon_state = "yellowscarf"
	_color = "yellowscarf"

/obj/item/clothing/accessory/scarf/orange
	name = "orange scarf"
	icon_state = "orangescarf"
	_color = "orangescarf"

/obj/item/clothing/accessory/scarf/lightblue
	name = "light blue scarf"
	icon_state = "lightbluescarf"
	_color = "lightbluescarf"

/obj/item/clothing/accessory/scarf/white
	name = "white scarf"
	icon_state = "whitescarf"
	_color = "whitescarf"

/obj/item/clothing/accessory/scarf/black
	name = "black scarf"
	icon_state = "blackscarf"
	_color = "blackscarf"

/obj/item/clothing/accessory/scarf/zebra
	name = "zebra scarf"
	icon_state = "zebrascarf"
	_color = "zebrascarf"

/obj/item/clothing/accessory/scarf/christmas
	name = "christmas scarf"
	icon_state = "christmasscarf"
	_color = "christmasscarf"

//The three following scarves don't have the scarf subtype
//This is because Ian can equip anything from that subtype
//However, these 3 don't have corgi versions of their sprites
/obj/item/clothing/accessory/stripedredscarf
	name = "striped red scarf"
	icon_state = "stripedredscarf"
	_color = "stripedredscarf"

/obj/item/clothing/accessory/stripedgreenscarf
	name = "striped green scarf"
	icon_state = "stripedgreenscarf"
	_color = "stripedgreenscarf"

/obj/item/clothing/accessory/stripedbluescarf
	name = "striped blue scarf"
	icon_state = "stripedbluescarf"
	_color = "stripedbluescarf"

/obj/item/clothing/accessory/petcollar
	name = "pet collar"
	icon_state = "petcollar"
	_color = "petcollar"
	var/tagname = null

/obj/item/clothing/accessory/petcollar/attack_self(mob/user as mob)
	tagname = copytext(sanitize(input(user, "Would you like to change the name on the tag?", "Name your new pet", "Spot") as null|text),1,MAX_NAME_LEN)
	name = "[initial(name)] - [tagname]"

/proc/english_accessory_list(obj/item/clothing/under/U)
	if(!istype(U) || !U.accessories.len)
		return
	var/list/A = U.accessories
	var/total = A.len
	if (total == 1)
		return "\a [A[1]]"
	else if (total == 2)
		return "\a [A[1]] and \a [A[2]]"
	else
		var/output = ""
		var/index = 1
		var/comma_text = ", "
		while (index < total)
			output += "\a [A[index]][comma_text]"
			index++

		return "[output]and \a [A[index]]"
