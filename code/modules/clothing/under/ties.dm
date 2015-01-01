/obj/item/clothing/tie
	name = "tie"
	desc = "A neosilk clip-on tie."
	icon = 'icons/obj/clothing/ties.dmi'
	icon_state = "bluetie"
	item_state = ""	//no inhands
	_color = "bluetie"
	flags = FPRINT | TABLEPASS
	slot_flags = 0
	w_class = 2.0

/obj/item/clothing/tie/blue
	name = "blue tie"
	icon_state = "bluetie"
	_color = "bluetie"

/obj/item/clothing/tie/red
	name = "red tie"
	icon_state = "redtie"
	_color = "redtie"

/obj/item/clothing/tie/black
	name = "black tie"
	icon_state = "blacktie"
	_color = "blacktie"

/obj/item/clothing/tie/horrible
	name = "horrible tie"
	desc = "A neosilk clip-on tie. This one is disgusting."
	icon_state = "horribletie"
	_color = "horribletie"

/obj/item/clothing/tie/waistcoat
	name = "waistcoat"
	desc = "For some classy, murderous fun."
	icon_state = "waistcoat"
	item_state = "waistcoat"
	_color = "waistcoat"

/obj/item/clothing/tie/stethoscope
	name = "stethoscope"
	desc = "An outdated medical apparatus for listening to the sounds of the human body. It also makes you look like you know what you're doing."
	icon_state = "stethoscope"
	_color = "stethoscope"

/obj/item/clothing/tie/stethoscope/attack(mob/living/carbon/human/M, mob/living/user)
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
/obj/item/clothing/tie/medal
	name = "bronze medal"
	desc = "A bronze medal."
	icon_state = "bronze"
	_color = "bronze"

/obj/item/clothing/tie/medal/conduct
	name = "distinguished conduct medal"
	desc = "A bronze medal awarded for distinguished conduct. Whilst a great honor, this is most basic award given by Nanotrasen. It is often awarded by a captain to a member of his crew."

/obj/item/clothing/tie/medal/bronze_heart
	name = "bronze heart medal"
	desc = "A bronze heart-shaped medal awarded for sacrifice. It is often awarded posthumously or for severe injury in the line of duty."
	icon_state = "bronze_heart"

/obj/item/clothing/tie/medal/nobel_science
	name = "nobel sciences award"
	desc = "A bronze medal which represents significant contributions to the field of science or engineering."

/obj/item/clothing/tie/medal/silver
	name = "silver medal"
	desc = "A silver medal."
	icon_state = "silver"
	_color = "silver"

/obj/item/clothing/tie/medal/silver/valor
	name = "medal of valor"
	desc = "A silver medal awarded for acts of exceptional valor."

/obj/item/clothing/tie/medal/silver/security
	name = "robust security award"
	desc = "An award for distinguished combat and sacrifice in defence of Nanotrasen's commercial interests. Often awarded to security staff."

/obj/item/clothing/tie/medal/gold
	name = "gold medal"
	desc = "A prestigious golden medal."
	icon_state = "gold"
	_color = "gold"

/obj/item/clothing/tie/medal/gold/captain
	name = "medal of captaincy"
	desc = "A golden medal awarded exclusively to those promoted to the rank of captain. It signifies the codified responsibilities of a captain to Nanotrasen, and their undisputable authority over their crew."

/obj/item/clothing/tie/medal/gold/heroism
	name = "medal of exceptional heroism"
	desc = "An extremely rare golden medal awarded only by CentComm. To recieve such a medal is the highest honor and as such, very few exist. This medal is almost never awarded to anybody but commanders."

/obj/item/clothing/tie/medal/gold/ion
	name = "Ion Chef Medal"
	desc = "A medal awarded to the winner of the Ion Chef contest"
	icon_state = "ion"
	_color = "ion"


//Armbands
/obj/item/clothing/tie/armband
	name = "red armband"
	desc = "An fancy red armband!"
	icon_state = "red"
	_color = "red"

/obj/item/clothing/tie/armband/cargo
	name = "cargo bay guard armband"
	desc = "An armband, worn by the station's security forces to display which department they're assigned to. This one is brown."
	icon_state = "cargo"
	_color = "cargo"

/obj/item/clothing/tie/armband/engine
	name = "engineering guard armband"
	desc = "An armband, worn by the station's security forces to display which department they're assigned to. This one is orange with a reflective strip!"
	icon_state = "engie"
	_color = "engie"

/obj/item/clothing/tie/armband/science
	name = "science guard armband"
	desc = "An armband, worn by the station's security forces to display which department they're assigned to. This one is purple."
	icon_state = "rnd"
	_color = "rnd"

/obj/item/clothing/tie/armband/hydro
	name = "hydroponics guard armband"
	desc = "An armband, worn by the station's security forces to display which department they're assigned to. This one is green and blue."
	icon_state = "hydro"
	_color = "hydro"

/obj/item/clothing/tie/armband/med
	name = "medical guard armband"
	desc = "An armband, worn by the station's security forces to display which department they're assigned to. This one is white."
	icon_state = "med"
	_color = "med"

/obj/item/clothing/tie/armband/medgreen
	name = "medical guard armband"
	desc = "An armband, worn by the station's security forces to display which department they're assigned to. This one is white and green."
	icon_state = "medgreen"
	_color = "medgreen"

/obj/item/clothing/tie/holster
	name = "shoulder holster"
	desc = "A handgun holster."
	icon_state = "holster"
	_color = "holster"
	var/obj/item/weapon/gun/holstered = null
	icon_action_button = "action_holster"

/obj/item/clothing/tie/holster/attack_self()
	holster()

/obj/item/clothing/tie/holster/proc/holster()
	if(!istype(usr, /mob/living)) return
	if(usr.stat) return

	if(!holstered)
		if(!istype(usr.get_active_hand(), /obj/item/weapon/gun))
			usr << "\blue You need your gun equiped to holster it."
			return
		var/obj/item/weapon/gun/W = usr.get_active_hand()
		if (!W.isHandgun())
			usr << "\red This gun won't fit in \the [src]!"
			return
		holstered = usr.get_active_hand()
		usr.drop_item()
		holstered.loc = src
		usr.visible_message("\blue \The [usr] holsters \the [holstered].", "You holster \the [holstered].")
	else
		if(istype(usr.get_active_hand(),/obj) && istype(usr.get_inactive_hand(),/obj))
			usr << "\red You need an empty hand to draw the gun!"
		else
			if(usr.a_intent == "harm")
				usr.visible_message("\red \The [usr] draws \the [holstered], ready to shoot!", \
				"\red You draw \the [holstered], ready to shoot!")
			else
				usr.visible_message("\blue \The [usr] draws \the [holstered], pointing it at the ground.", \
				"\blue You draw \the [holstered], pointing it at the ground.")
			usr.put_in_hands(holstered)
			holstered = null

/obj/item/clothing/tie/holster/armpit
	name = "shoulder holster"
	desc = "A worn-out handgun holster. Perfect for concealed carry"
	icon_state = "holster"
	_color = "holster"

/obj/item/clothing/tie/storage
	name = "load bearing equipment"
	desc = "Used to hold things when you don't have enough hands for that."
	icon_state = "webbing"
	_color = "webbing"
	var/slots = 3
	var/obj/item/weapon/storage/pockets/hold
	icon_action_button = "action_storage"

/obj/item/clothing/tie/storage/New()
	hold = new /obj/item/weapon/storage/pockets(src)
	hold.master_item = src
	hold.storage_slots = slots


/obj/item/clothing/tie/storage/attack_self(mob/user as mob)
	if (!istype(hold))
		return

	hold.loc = user
	hold.attack_hand(user)

/obj/item/clothing/tie/storage/attackby(obj/item/weapon/W as obj, mob/user as mob)
	hold.attackby(W,user)
	src.add_fingerprint(user)

/obj/item/weapon/storage/pockets
	name = "storage"
	var/master_item		//item it belongs to

/obj/item/weapon/storage/pockets/close(mob/user as mob)
	..()
	loc = master_item

/obj/item/clothing/tie/storage/webbing
	name = "webbing"
	desc = "Strudy mess of synthcotton belts and buckles, ready to share your burden."
	icon_state = "webbing"
	_color = "webbing"

/obj/item/clothing/tie/storage/black_vest
	name = "black webbing vest"
	desc = "Robust black synthcotton vest with lots of pockets to hold whatever you need, but cannot hold in hands."
	icon_state = "vest_black"
	_color = "vest_black"
	slots = 5

/obj/item/clothing/tie/storage/brown_vest
	name = "brown webbing vest"
	desc = "Worn brownish synthcotton vest with lots of pockets to unload your hands."
	icon_state = "vest_brown"
	_color = "vest_brown"
	slots = 5
/*
	Holobadges are worn on the belt or neck, and can be used to show that the holder is an authorized
	Security agent - the user details can be imprinted on the badge with a Security-access ID card,
	or they can be emagged to accept any ID for use in disguises.
*/

/obj/item/clothing/tie/holobadge

	name = "holobadge"
	desc = "This glowing blue badge marks the holder as THE LAW."
	icon_state = "holobadge"
	_color = "holobadge"
	slot_flags = SLOT_BELT

	var/emagged = 0 //Emagging removes Sec check.
	var/stored_name = null

/obj/item/clothing/tie/holobadge/cord
	icon_state = "holobadge-cord"
	_color = "holobadge-cord"
	slot_flags = SLOT_MASK

/obj/item/clothing/tie/holobadge/attack_self(mob/user as mob)
	if(!stored_name)
		user << "Waving around a badge before swiping an ID would be pretty pointless."
		return
	if(isliving(user))
		user.visible_message("\red [user] displays their Nanotrasen Internal Security Legal Authorization Badge.\nIt reads: [stored_name], NT Security.","\red You display your Nanotrasen Internal Security Legal Authorization Badge.\nIt reads: [stored_name], NT Security.")

/obj/item/clothing/tie/holobadge/attackby(var/obj/item/O as obj, var/mob/user as mob)

	if (istype(O, /obj/item/weapon/card/emag))
		if (emagged)
			user << "\red [src] is already cracked."
			return
		else
			emagged = 1
			user << "\red You swipe [O] and crack the holobadge security checks."
			return

	else if(istype(O, /obj/item/weapon/card/id) || istype(O, /obj/item/device/pda))

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

/obj/item/clothing/tie/holobadge/attack(mob/living/carbon/human/M, mob/living/user)
	if(isliving(user))
		user.visible_message("\red [user] invades [M]'s personal space, thrusting [src] into their face insistently.","\red You invade [M]'s personal space, thrusting [src] into their face insistently. You are the law.")

/obj/item/weapon/storage/box/holobadge
	name = "holobadge box"
	desc = "A box claiming to contain holobadges."
	New()
		new /obj/item/clothing/tie/holobadge(src)
		new /obj/item/clothing/tie/holobadge(src)
		new /obj/item/clothing/tie/holobadge(src)
		new /obj/item/clothing/tie/holobadge(src)
		new /obj/item/clothing/tie/holobadge/cord(src)
		new /obj/item/clothing/tie/holobadge/cord(src)
		..()
		return

/obj/item/clothing/tie/storage/knifeharness
	name = "decorated harness"
	desc = "A heavily decorated harness of sinew and leather with two knife-loops."
	icon_state = "unathiharness2"
	_color = "unathiharness2"
	slots = 2

/obj/item/clothing/tie/storage/knifeharness/attackby(var/obj/item/O as obj, mob/user as mob)
	..()
	update()

/obj/item/clothing/tie/storage/knifeharness/proc/update()
	var/count = 0
	for(var/obj/item/I in hold)
		if(istype(I,/obj/item/weapon/hatchet/unathiknife))
			count++
	if(count>2) count = 2
	item_state = "unathiharness[count]"
	icon_state = item_state
	_color = item_state

	if(istype(loc, /obj/item/clothing))
		var/obj/item/clothing/U = loc
		if(istype(U.loc, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = U.loc
			H.update_inv_w_uniform()

/obj/item/clothing/tie/storage/knifeharness/New()
	..()
	new /obj/item/weapon/hatchet/unathiknife(hold)
	new /obj/item/weapon/hatchet/unathiknife(hold)

///////////
//SCARVES//
///////////

/obj/item/clothing/tie/scarf
	name = "scarf"
	desc = "A stylish scarf. The perfect winter accessory for those with a keen fashion sense, and those who just can't handle a cold breeze on their necks."

/obj/item/clothing/tie/scarf/red
	name = "red scarf"
	icon_state = "redscarf"
	_color = "redscarf"

/obj/item/clothing/tie/scarf/green
	name = "green scarf"
	icon_state = "greenscarf"
	_color = "greenscarf"

/obj/item/clothing/tie/scarf/darkblue
	name = "dark blue scarf"
	icon_state = "darkbluescarf"
	_color = "darkbluescarf"

/obj/item/clothing/tie/scarf/purple
	name = "purple scarf"
	icon_state = "purplescarf"
	_color = "purplescarf"

/obj/item/clothing/tie/scarf/yellow
	name = "yellow scarf"
	icon_state = "yellowscarf"
	_color = "yellowscarf"

/obj/item/clothing/tie/scarf/orange
	name = "orange scarf"
	icon_state = "orangescarf"
	_color = "orangescarf"

/obj/item/clothing/tie/scarf/lightblue
	name = "light blue scarf"
	icon_state = "lightbluescarf"
	_color = "lightbluescarf"

/obj/item/clothing/tie/scarf/white
	name = "white scarf"
	icon_state = "whitescarf"
	_color = "whitescarf"

/obj/item/clothing/tie/scarf/black
	name = "black scarf"
	icon_state = "blackscarf"
	_color = "blackscarf"

/obj/item/clothing/tie/scarf/zebra
	name = "zebra scarf"
	icon_state = "zebrascarf"
	_color = "zebrascarf"

/obj/item/clothing/tie/scarf/christmas
	name = "christmas scarf"
	icon_state = "christmasscarf"
	_color = "christmasscarf"

//The three following scarves don't have the scarf subtype
//This is because Ian can equip anything from that subtype
//However, these 3 don't have corgi versions of their sprites
/obj/item/clothing/tie/stripedredscarf
	name = "striped red scarf"
	icon_state = "stripedredscarf"
	_color = "stripedredscarf"

/obj/item/clothing/tie/stripedgreenscarf
	name = "striped green scarf"
	icon_state = "stripedgreenscarf"
	_color = "stripedgreenscarf"

/obj/item/clothing/tie/stripedbluescarf
	name = "striped blue scarf"
	icon_state = "stripedbluescarf"
	_color = "stripedbluescarf"