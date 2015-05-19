/* Cards
 * Contains:
 *		DATA CARD
 *		ID CARD
 *		FINGERPRINT CARD HOLDER
 *		FINGERPRINT CARD
 */



/*
 * DATA CARDS - Used for the teleporter
 */
/obj/item/weapon/card
	name = "card"
	desc = "A card."
	icon = 'icons/obj/card.dmi'
	w_class = 1.0
	var/associated_account_number = 0

	var/list/files = list(  )

/obj/item/weapon/card/data
	name = "data card"
	desc = "A disk containing data."
	icon_state = "data"
	var/function = "storage"
	var/data = "null"
	var/special = null
	item_state = "card-id"

/obj/item/weapon/card/data/verb/label(t as text)
	set name = "Label Disk"
	set category = "Object"
	set src in usr

	if (t)
		src.name = text("Data Disk- '[]'", t)
	else
		src.name = "Data Disk"
	src.add_fingerprint(usr)
	return

/obj/item/weapon/card/data/clown
	name = "coordinates to clown planet"
	icon_state = "data"
	item_state = "card-id"
	layer = 3
	level = 2
	desc = "This card contains coordinates to the fabled Clown Planet. Handle with care."
	function = "teleporter"
	data = "Clown Land"

/*
 * ID CARDS
 */

/obj/item/weapon/card/emag_broken
	desc = "It's a card with a magnetic strip attached to some circuitry. It looks too busted to be used for anything but salvage."
	name = "broken cryptographic sequencer"
	icon_state = "emag"
	item_state = "card-id"
	origin_tech = "magnets=2;syndicate=2"

/obj/item/weapon/card/emag
	desc = "It's a card with a magnetic strip attached to some circuitry."
	name = "cryptographic sequencer"
	icon_state = "emag"
	item_state = "card-id"
	origin_tech = "magnets=2;syndicate=2"
	flags = NOBLUDGEON

/obj/item/weapon/card/emag/attack()
	return

/obj/item/weapon/card/emag/afterattack(atom/target, mob/user, proximity)
	var/atom/A = target
	if(!proximity)
		return
	A.emag_act(user)

/obj/item/weapon/card/id
	name = "identification card"
	desc = "A card used to provide ID and determine access across the station."
	icon_state = "id"
	item_state = "card-id"
	var/mining_points = 0 //For redeeming at mining equipment lockers
	var/access = list()
	var/registered_name = "Unknown" // The name registered_name on the card
	slot_flags = SLOT_ID

	var/blood_type = "\[UNSET\]"
	var/dna_hash = "\[UNSET\]"
	var/fingerprint_hash = "\[UNSET\]"

	//alt titles are handled a bit weirdly in order to unobtrusively integrate into existing ID system
	var/assignment = null	//can be alt title or the actual job
	var/rank = null			//actual job
	var/dorm = 0		// determines if this ID has claimed a dorm already

	var/datum/data/record/active1 = null
	var/sex
	var/age
	var/photo
	var/icon/front
	var/icon/side
	var/dat
	var/stamped=0

/obj/item/weapon/card/id/New()
	..()
	spawn(30)
	updatedat()

/obj/item/weapon/card/id/proc/updatedat()
	if(istype(loc, /mob/living/carbon/human))
		blood_type = loc:dna:b_type
		dna_hash = loc:dna:unique_enzymes
		fingerprint_hash = md5(loc:dna:uni_identity)
		dat = ("<table><tr><td>")
		dat +=text("Name: []</A><BR>", registered_name)
		dat +=text("Sex: []</A><BR>\n", sex)
		dat +=text("Age: []</A><BR>\n", age)
		dat +=text("Rank: []</A><BR>\n", assignment)
		dat +=text("Fingerprint: []</A><BR>\n", fingerprint_hash)
		dat +=text("Blood Type: []<BR>\n", blood_type)
		dat +=text("DNA Hash: []<BR><BR>\n", dna_hash)
		dat +="<td align = center valign = top>Photo:<br><img src=front.png height=80 width=80 border=4>	\
		<img src=side.png height=80 width=80 border=4></td></tr></table>"

/obj/item/weapon/card/id/examine()
	set src in oview(1)
	if(in_range(usr, src))
		show(usr)
		usr << desc
	else
		usr << "<span class='notice'>It is too far away.</span>"

/obj/item/weapon/card/id/proc/show(mob/user as mob)
	if(!front)
		front = new(photo, dir = SOUTH)
	if(!side)
		side = new(photo, dir = WEST)
	user << browse_rsc(front, "front.png")
	user << browse_rsc(side, "side.png")
	var/datum/browser/popup = new(user, "idcard", name, 600, 400)
	popup.set_content(dat)
	popup.set_title_image(usr.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

	return

/obj/item/weapon/card/id/attack_self(mob/user as mob)
	for(var/mob/O in viewers(user, null))
		O.show_message(text("[] shows you: \icon[] []. The assignment on the card: []", user, src, src.name, src.assignment), 1)
	if(mining_points)
		user << "There's [mining_points] mining equipment redemption points loaded onto this card."
	src.add_fingerprint(user)
	return

/obj/item/weapon/card/id/GetAccess()
	return access

/obj/item/weapon/card/id/GetID()
	return src

/obj/item/weapon/card/id/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	..()

	if(istype(W, /obj/item/weapon/id_decal/))
		var/obj/item/weapon/id_decal/decal = W
		user << "You apply [decal] to [src]."
		if(decal.override_name)
			name = decal.decal_name
		desc = decal.decal_desc
		icon_state = decal.decal_icon_state
		item_state = decal.decal_item_state
		qdel(decal)
		qdel(W)
		return

	else if(istype (W,/obj/item/weapon/stamp))
		if(!stamped)
			dat+="<img src=large_[W.icon_state].png>"
			stamped = 1
			usr << "You stamp the ID card!"
		else
			usr << "This ID has already been stamped!"


/obj/item/weapon/card/id/verb/read()
	set name = "Read ID Card"
	set category = "Object"
	set src in usr

	usr << text("\icon[] []: The current assignment on the card is [].", src, src.name, src.assignment)
	usr << "The blood type on the card is [blood_type]."
	usr << "The DNA hash on the card is [dna_hash]."
	usr << "The fingerprint hash on the card is [fingerprint_hash]."
	return


/obj/item/weapon/card/id/silver
	name = "identification card"
	desc = "A silver card which shows honour and dedication."
	icon_state = "silver"
	item_state = "silver_id"

/obj/item/weapon/card/id/gold
	name = "identification card"
	desc = "A golden card which shows power and might."
	icon_state = "gold"
	item_state = "gold_id"

/obj/item/weapon/card/id/syndicate
	name = "agent card"
	access = list(access_maint_tunnels, access_syndicate)
	origin_tech = "syndicate=3"
	var/registered_user=null

/obj/item/weapon/card/id/syndicate/New(mob/user as mob)
//	..() - Intentionally does not call parent, doesn't need to
	if(!isnull(user) && iscarbon(user)) // Runtime prevention on laggy starts or where users log out because of lag at round start. Also stops the ID from inheriting anything but a mob name
		registered_name = ishuman(user) ? user.real_name : user.name
	else
		registered_name = "Agent Card"
	assignment = "Agent"
	name = "[registered_name]'s ID Card ([assignment])"

/obj/item/weapon/card/id/syndicate/afterattack(var/obj/item/weapon/O as obj, mob/user as mob, proximity)
	if(!proximity) return
	if(istype(O, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/I = O
		src.access |= I.access
		if(istype(user, /mob/living) && user.mind)
			if(user.mind.special_role)
				usr << "\blue The card's microscanners activate as you pass it over the ID, copying its access."

/obj/item/weapon/card/id/syndicate/attack_self(mob/user as mob)
	if(!src.registered_name)
		//Stop giving the players unsanitized unputs! You are giving ways for players to intentionally crash clients! -Nodrak
		var t = reject_bad_name(input(user, "What name would you like to put on this card?", "Agent card name", ishuman(user) ? user.real_name : user.name))
		if(!t) //Same as mob/new_player/prefrences.dm
			alert("Invalid name.")
			return
		src.registered_name = t

		var u = sanitize(copytext(input(user, "What occupation would you like to put on this card?\nNote: This will not grant any access levels other than Maintenance.", "Agent card job assignment", "Civilian"),1,MAX_MESSAGE_LEN))
		if(!u)
			alert("Invalid assignment.")
			src.registered_name = ""
			return
		src.assignment = u
		src.name = "[src.registered_name]'s ID Card ([src.assignment])"
		registered_user = user
		var/s = input(user, "Would you like to update this card's details with your own?\nNote: This will take a picture of how you currently look, so put any items in your hand down first (other than this ID), and it will assume your age, and gender.", "Agent card update choice", "No") in list("Yes","No")
		if(s == "Yes")
			src.setupdat()
			spawn(0)
			src.updatedat()
		user << "\blue You successfully forge the ID card."

	else if(!registered_user || registered_user == user)

		if(!registered_user) registered_user = user  //

		switch(alert("Would you like to display the ID, or retitle it?","Choose.","Rename","Show"))
			if("Rename")
				var t = sanitize(copytext(input(user, "What name would you like to put on this card?", "Agent card name", ishuman(user) ? user.real_name : user.name),1,26))
				if(!t || t == "Unknown" || t == "floor" || t == "wall" || t == "r-wall") //Same as mob/new_player/prefrences.dm
					alert("Invalid name.")
					return
				src.registered_name = t

				var u = sanitize(copytext(input(user, "What occupation would you like to put on this card?\nNote: This will not grant any access levels other than Maintenance.", "Agent card job assignment", "Civilian"),1,MAX_MESSAGE_LEN))
				if(!u)
					alert("Invalid assignment.")
					src.registered_name = ""
					return
				src.assignment = u
				src.name = "[src.registered_name]'s ID Card ([src.assignment])"
				var/s = input(user, "Would you like to update this card's details with your own?\nNote: This will take a picture of how you currently look, so put any items in your hand down first (other than this ID), and it will assume your age, and gender.", "Agent card update choice", "No") in list("Yes","No")
				if(s == "Yes")
					src.setupdat()
					spawn(0)
					src.updatedat()
				user << "\blue You successfully forge the ID card."
				return
			if("Show")
				..()
	else
		..()

/obj/item/weapon/card/id/syndicate/proc/setupdat() //fake initilization, taken mostly from job_controller.dm
	if(istype(src.loc, /mob/living/carbon/human)) //just adopt the syndie stuff, it would be annoying to ask them to set all of this, and the use would be limited
		var/mob/living/carbon/human/H = loc
		src.sex = capitalize(H.gender)
		src.rank = src.assignment
		src.age = H.age
		src.photo = fake_id_photo(H)
		var/icon/photoside = fake_id_photo(H,1)
		front = new(photo)
		side = new(photoside)

/obj/item/weapon/card/id/syndicate/proc/fake_id_photo(var/mob/living/carbon/human/H, var/side=0)//get_id_photo wouldn't work correctly
	if(!istype(H))
		return
	var/storedDir = H.dir //don't want to lose track of this

	var/icon/faked
	if(!side)
		if(!H.equip_to_slot_if_possible(src, slot_l_store, 0, 1))
			H << "<span class='warning'>You need to empty your pockets before taking the ID picture.</span>"
			return

	if(side)
		H.dir = WEST //ensure the icon is actually the proper direction before copying it
		faked = getFlatIcon(H)
		H.dir = storedDir //reset the user back to their original direction, not even noticable they changed
		H.equip_to_slot_if_possible(src, slot_l_hand, 0, 1)

	else
		H.dir = SOUTH
		faked = getFlatIcon(H)
		H.dir = storedDir

	return faked

/obj/item/weapon/card/id/syndicate_command
	name = "syndicate ID card"
	desc = "An ID straight from the Syndicate."
	registered_name = "Syndicate"
	assignment = "Syndicate Overlord"
	access = list(access_syndicate, access_external_airlocks)

/obj/item/weapon/card/id/captains_spare
	name = "captain's spare ID"
	desc = "The spare ID of the captain."
	icon_state = "gold"
	item_state = "gold_id"
	registered_name = "Captain"
	assignment = "Captain"
	New()
		var/datum/job/captain/J = new/datum/job/captain
		access = J.get_access()
		..()

/obj/item/weapon/card/id/centcom
	name = "central command ID card"
	desc = "An ID straight from Central Command."
	icon_state = "centcom"
	registered_name = "Central Command"
	assignment = "General"
	New()
		access = get_all_centcom_access()
		..()

/obj/item/weapon/card/id/prisoner
	name = "prisoner ID card"
	desc = "You are a number, you are not a free man."
	icon_state = "orange"
	item_state = "orange-id"
	assignment = "Prisoner"
	registered_name = "Scum"
	var/goal = 0 //How far from freedom?
	var/points = 0

/obj/item/weapon/card/id/prisoner/attack_self(mob/user as mob)
	usr << "You have accumulated [points] out of the [goal] points you need for freedom."

/obj/item/weapon/card/id/prisoner/one
	name = "Prisoner #13-001"
	registered_name = "Prisoner #13-001"

/obj/item/weapon/card/id/prisoner/two
	name = "Prisoner #13-002"
	registered_name = "Prisoner #13-002"

/obj/item/weapon/card/id/prisoner/three
	name = "Prisoner #13-003"
	registered_name = "Prisoner #13-003"

/obj/item/weapon/card/id/prisoner/four
	name = "Prisoner #13-004"
	registered_name = "Prisoner #13-004"

/obj/item/weapon/card/id/prisoner/five
	name = "Prisoner #13-005"
	registered_name = "Prisoner #13-005"

/obj/item/weapon/card/id/prisoner/six
	name = "Prisoner #13-006"
	registered_name = "Prisoner #13-006"

/obj/item/weapon/card/id/prisoner/seven
	name = "Prisoner #13-007"
	registered_name = "Prisoner #13-007"

/obj/item/weapon/card/id/salvage_captain
	name = "Captain's ID"
	registered_name = "Captain"
	icon_state = "centcom"
	desc = "Finders, keepers."
	access = list(access_salvage_captain)

/obj/item/weapon/id_decal
	name = "identification card decal"
	desc = "A modification kit to make your ID cards look snazzy.."
	icon = 'icons/obj/device.dmi'
	icon_state = "batterer"
	var/decal_name = "identification card"
	var/decal_desc = "A card used to provide ID and determine access across the station."
	var/decal_icon_state = "id"
	var/decal_item_state = "card-id"
	var/override_name = 0

/obj/item/weapon/id_decal/gold
	name = "gold ID card card decal"
	decal_desc = "A golden card which shows power and might."
	decal_icon_state = "gold"
	decal_item_state = "gold_id"

/obj/item/weapon/id_decal/silver
	name = "silver ID card decal"
	decal_desc = "A silver card which shows honour and dedication."
	decal_icon_state = "silver"
	decal_item_state = "silver_id"

/obj/item/weapon/id_decal/prisoner
	name = "prisoner ID card decal"
	decal_desc = "You are a number, you are not a free man."
	decal_icon_state = "orange"
	decal_item_state = "orange-id"

/obj/item/weapon/id_decal/centcom
	name = "centcom ID card decal"
	decal_desc = "An ID straight from Cent. Com."
	decal_icon_state = "centcom"

/obj/item/weapon/id_decal/emag
	name = "cryptographic sequencer ID card decal"
	decal_name = "cryptographic sequencer"
	decal_desc = "It's a card with a magnetic strip attached to some circuitry."
	decal_icon_state = "emag"
	override_name = 1
