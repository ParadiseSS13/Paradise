/obj/item/clothing/accessory
	name = "tie"
	desc = "A neosilk clip-on tie."
	icon = 'icons/obj/clothing/ties.dmi'
	icon_state = "bluetie"
	item_state = ""	//no inhands
	item_color = "bluetie"
	slot_flags = SLOT_TIE
	w_class = 2
	var/slot = "decor"
	var/obj/item/clothing/under/has_suit = null		//the suit the tie may be attached to
	var/image/inv_overlay = null	//overlay used when attached to clothing.

/obj/item/clothing/accessory/New()
	..()
	inv_overlay = image("icon" = 'icons/obj/clothing/ties_overlay.dmi', "icon_state" = "[item_color? "[item_color]" : "[icon_state]"]")

//when user attached an accessory to S
/obj/item/clothing/accessory/proc/on_attached(obj/item/clothing/under/S, mob/user as mob)
	if(!istype(S))
		return
	has_suit = S
	loc = has_suit
	has_suit.overlays += inv_overlay
	has_suit.actions += actions

	for(var/X in actions)
		var/datum/action/A = X
		if(has_suit.is_equipped())
			var/mob/M = has_suit.loc
			A.Grant(M)

	for(var/armor_type in armor)
		has_suit.armor[armor_type] += armor[armor_type]

	if(user)
		to_chat(user, "<span class='notice'>You attach [src] to [has_suit].</span>")
	src.add_fingerprint(user)

/obj/item/clothing/accessory/proc/on_removed(mob/user as mob)
	if(!has_suit)
		return
	has_suit.overlays -= inv_overlay
	has_suit.actions -= actions

	for(var/X in actions)
		var/datum/action/A = X
		if(ismob(has_suit.loc))
			var/mob/M = has_suit.loc
			A.Remove(M)

	for(var/armor_type in armor)
		has_suit.armor[armor_type] -= armor[armor_type]

	has_suit = null
	usr.put_in_hands(src)
	src.add_fingerprint(user)

/obj/item/clothing/accessory/attack(mob/living/carbon/human/H, mob/living/user)
	// This code lets you put accessories on other people by attacking their sprite with the accessory
	if(istype(H))
		if(H.wear_suit && H.wear_suit.flags_inv & HIDEJUMPSUIT)
			to_chat(user, "[H]'s body is covered, and you cannot attach \the [src].")
			return 1
		var/obj/item/clothing/under/U = H.w_uniform
		if(istype(U))
			user.visible_message("<span class='notice'>[user] is putting a [src.name] on [H]'s [U.name]!</span>", "<span class='notice'>You begin to put a [src.name] on [H]'s [U.name]...</span>")
			if(do_after(user,40,target=H) && H.w_uniform == U)
				user.visible_message("<span class='notice'>[user] puts a [src.name] on [H]'s [U.name]!</span>", "<span class='notice'>You finish putting a [src.name] on [H]'s [U.name].</span>")
				U.attackby(src, user)
		else
			to_chat(user, "[H] is not wearing anything to attach \the [src] to.")
		return 1
	return ..()

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
	item_color = "bluetie"

/obj/item/clothing/accessory/red
	name = "red tie"
	icon_state = "redtie"
	item_color = "redtie"

/obj/item/clothing/accessory/black
	name = "black tie"
	icon_state = "blacktie"
	item_color = "blacktie"

/obj/item/clothing/accessory/horrible
	name = "horrible tie"
	desc = "A neosilk clip-on tie. This one is disgusting."
	icon_state = "horribletie"
	item_color = "horribletie"

/obj/item/clothing/accessory/waistcoat // No overlay
	name = "waistcoat"
	desc = "For some classy, murderous fun."
	icon_state = "waistcoat"
	item_state = "waistcoat"
	item_color = "waistcoat"
	species_fit = list("Vox")
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/suit.dmi'
		)

/obj/item/clothing/accessory/stethoscope
	name = "stethoscope"
	desc = "An outdated medical apparatus for listening to the sounds of the human body. It also makes you look like you know what you're doing."
	icon_state = "stethoscope"
	item_color = "stethoscope"

/obj/item/clothing/accessory/stethoscope/attack(mob/living/carbon/human/M, mob/living/user)
	if(ishuman(M) && isliving(user))
		if(user == M)
			user.visible_message("[user] places \the [src] against \his chest and listens attentively.", "You place \the [src] against your chest...")
		else
			user.visible_message("[user] places \the [src] against [M]'s chest and listens attentively.", "You place \the [src] against [M]'s chest...")
		var/obj/item/organ/internal/H = M.get_int_organ(/obj/item/organ/internal/heart)
		var/obj/item/organ/internal/L = M.get_int_organ(/obj/item/organ/internal/lungs)
		if((H && M.pulse) || (L && !(NO_BREATH in M.mutations) && !(M.species.flags & NO_BREATH)))
			var/color = "notice"
			if(H)
				var/heart_sound
				switch(H.damage)
					if(0 to 1)
						heart_sound = "healthy"
					if(1 to 25)
						heart_sound = "offbeat"
					if(25 to 50)
						heart_sound = "uneven"
						color = "warning"
					if(50 to INFINITY)
						heart_sound = "weak, unhealthy"
						color = "warning"
				to_chat(user, "<span class='[color]'>You hear \an [heart_sound] pulse.</span>")
			if(L)
				var/lung_sound
				switch(L.damage)
					if(0 to 1)
						lung_sound = "healthy respiration"
					if(1 to 25)
						lung_sound = "labored respiration"
					if(25 to 50)
						lung_sound = "pained respiration"
						color = "warning"
					if(50 to INFINITY)
						lung_sound = "gurgling"
						color = "warning"
				to_chat(user, "<span class='[color]'>You hear [lung_sound].</span>")
		else
			to_chat(user, "<span class='warning'>You don't hear anything.</span>")
		return
	return ..(M,user)


//Medals
/obj/item/clothing/accessory/medal
	name = "bronze medal"
	desc = "A bronze medal."
	icon_state = "bronze"
	item_color = "bronze"
	materials = list(MAT_METAL=1000)
	burn_state = FIRE_PROOF

/obj/item/clothing/accessory/medal/conduct
	name = "distinguished conduct medal"
	desc = "A bronze medal awarded for distinguished conduct. Whilst a great honor, this is the most basic award given by Nanotrasen. It is often awarded by a captain to a member of his crew."

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
	item_color = "silver"
	materials = list(MAT_SILVER=1000)

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
	item_color = "gold"
	materials = list(MAT_GOLD=1000)

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
	item_color = "holobadge"
	slot_flags = SLOT_BELT | SLOT_TIE

	var/emagged = 0 //Emagging removes Sec check.
	var/stored_name = null

/obj/item/clothing/accessory/holobadge/cord
	icon_state = "holobadge-cord"
	item_color = "holobadge-cord"
	slot_flags = SLOT_MASK | SLOT_TIE

/obj/item/clothing/accessory/holobadge/attack_self(mob/user as mob)
	if(!stored_name)
		to_chat(user, "Waving around a badge before swiping an ID would be pretty pointless.")
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
			to_chat(user, "You imprint your ID details onto the badge.")
			stored_name = id_card.registered_name
			name = "holobadge ([stored_name])"
			desc = "This glowing blue badge marks [stored_name] as THE LAW."
		else
			to_chat(user, "[src] rejects your insufficient access rights.")
		return
	..()

/obj/item/clothing/accessory/holobadge/emag_act(user as mob)
	if(emagged)
		to_chat(user, "\red [src] is already cracked.")
		return
	else
		emagged = 1
		to_chat(user, "\red You swipe the card and crack the holobadge security checks.")
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
	item_color = "redscarf"

/obj/item/clothing/accessory/scarf/green
	name = "green scarf"
	icon_state = "greenscarf"
	item_color = "greenscarf"

/obj/item/clothing/accessory/scarf/darkblue
	name = "dark blue scarf"
	icon_state = "darkbluescarf"
	item_color = "darkbluescarf"

/obj/item/clothing/accessory/scarf/purple
	name = "purple scarf"
	icon_state = "purplescarf"
	item_color = "purplescarf"

/obj/item/clothing/accessory/scarf/yellow
	name = "yellow scarf"
	icon_state = "yellowscarf"
	item_color = "yellowscarf"

/obj/item/clothing/accessory/scarf/orange
	name = "orange scarf"
	icon_state = "orangescarf"
	item_color = "orangescarf"

/obj/item/clothing/accessory/scarf/lightblue
	name = "light blue scarf"
	icon_state = "lightbluescarf"
	item_color = "lightbluescarf"

/obj/item/clothing/accessory/scarf/white
	name = "white scarf"
	icon_state = "whitescarf"
	item_color = "whitescarf"

/obj/item/clothing/accessory/scarf/black
	name = "black scarf"
	icon_state = "blackscarf"
	item_color = "blackscarf"

/obj/item/clothing/accessory/scarf/zebra
	name = "zebra scarf"
	icon_state = "zebrascarf"
	item_color = "zebrascarf"

/obj/item/clothing/accessory/scarf/christmas
	name = "christmas scarf"
	icon_state = "christmasscarf"
	item_color = "christmasscarf"

//The three following scarves don't have the scarf subtype
//This is because Ian can equip anything from that subtype
//However, these 3 don't have corgi versions of their sprites
/obj/item/clothing/accessory/stripedredscarf
	name = "striped red scarf"
	icon_state = "stripedredscarf"
	item_color = "stripedredscarf"

/obj/item/clothing/accessory/stripedgreenscarf
	name = "striped green scarf"
	icon_state = "stripedgreenscarf"
	item_color = "stripedgreenscarf"

/obj/item/clothing/accessory/stripedbluescarf
	name = "striped blue scarf"
	icon_state = "stripedbluescarf"
	item_color = "stripedbluescarf"

/obj/item/clothing/accessory/petcollar
	name = "pet collar"
	desc = "The latest fashion accessory for your favorite pets!"
	icon_state = "petcollar"
	item_color = "petcollar"
	var/tagname = null
	var/obj/item/weapon/card/id/access_id

/obj/item/clothing/accessory/petcollar/Destroy()
	if(access_id)
		qdel(access_id)
		access_id = null
	processing_objects -= src
	return ..()

/obj/item/clothing/accessory/petcollar/attack_self(mob/user as mob)
	var/option = "Change Name"
	if(access_id)
		option = input(user, "What do you want to do?", "[src]", option) as null|anything in list("Change Name", "Remove ID")

	switch(option)
		if("Change Name")
			var/t = input(user, "Would you like to change the name on the tag?", "Name your new pet", tagname ? tagname : "Spot") as null|text
			if(t)
				tagname = copytext(sanitize(t), 1, MAX_NAME_LEN)
				name = "[initial(name)] - [tagname]"
		if("Remove ID")
			if(access_id)
				user.visible_message("<span class='warning'>[user] starts unclipping \the [access_id] from \the [src].</span>")
				if(do_after(user, 50, target = user) && access_id)
					user.visible_message("<span class='warning'>[user] unclips \the [access_id] from \the [src].</span>")
					access_id.forceMove(get_turf(user))
					user.put_in_hands(access_id)
					access_id = null

/obj/item/clothing/accessory/petcollar/attackby(obj/item/weapon/card/id/W, mob/user, params)
	if(!istype(W))
		return ..()
	if(access_id)
		to_chat(user, "<span class='warning'>There is already \a [access_id] clipped onto \the [src]</span>")
	user.drop_item()
	W.forceMove(src)
	access_id = W
	to_chat(user, "<span class='notice'>\The [W] clips onto \the [src] snugly.</span>")

/obj/item/clothing/accessory/petcollar/GetAccess()
	return access_id ? access_id.GetAccess() : ..()

/obj/item/clothing/accessory/petcollar/examine(mob/user)
	..()
	if(access_id)
		to_chat(user, "There is [bicon(access_id)] \a [access_id] clipped onto it.")

/obj/item/clothing/accessory/petcollar/equipped(mob/living/simple_animal/user)
	if(istype(user))
		processing_objects |= src

/obj/item/clothing/accessory/petcollar/dropped(mob/living/simple_animal/user)
	processing_objects -= src

/obj/item/clothing/accessory/petcollar/process()
	var/mob/living/simple_animal/M = loc
	// if it wasn't intentionally unequipped but isn't being worn, possibly gibbed
	if(istype(M) && src == M.collar && M.stat != DEAD)
		return

	var/area/t = get_area(M)
	var/obj/item/device/radio/headset/a = new /obj/item/device/radio/headset(null)
	if(istype(t, /area/syndicate_station) || istype(t, /area/syndicate_mothership) || istype(t, /area/shuttle/syndicate_elite) )
		//give the syndicats a bit of stealth
		a.autosay("[M] has been vandalized in Space!", "[M]'s Death Alarm")
	else
		a.autosay("[M] has been vandalized in [t.name]!", "[M]'s Death Alarm")
	qdel(a)
	processing_objects -= src

/proc/english_accessory_list(obj/item/clothing/under/U)
	if(!istype(U) || !U.accessories.len)
		return
	var/list/A = U.accessories
	var/total = A.len
	if(total == 1)
		return "\a [A[1]]"
	else if(total == 2)
		return "\a [A[1]] and \a [A[2]]"
	else
		var/output = ""
		var/index = 1
		var/comma_text = ", "
		while(index < total)
			output += "\a [A[index]][comma_text]"
			index++

		return "[output]and \a [A[index]]"
