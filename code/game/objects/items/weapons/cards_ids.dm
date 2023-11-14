/* Cards
 * Contains:
 *		DATA CARD
 *		ID CARD
 *		FINGERPRINT CARD HOLDER
 *		FINGERPRINT CARD
 */

/obj/item/card
	name = "card"
	desc = "A card."
	icon = 'icons/obj/card.dmi'
	w_class = WEIGHT_CLASS_TINY
	var/associated_account_number = 0

	var/list/files = list(  )

/obj/item/card/proc/get_card_account()
	return GLOB.station_money_database.find_user_account(associated_account_number)

/*
 * ID CARDS
 */

/obj/item/card/emag_broken
	desc = "It's a card with a magnetic strip attached to some circuitry. It looks too busted to be used for anything but salvage."
	name = "broken cryptographic sequencer"
	icon_state = "emag"
	item_state = "card-id"
	origin_tech = "magnets=2;syndicate=2"

/obj/item/card/emag
	desc = "It's a card with a magnetic strip attached to some circuitry."
	name = "cryptographic sequencer"
	icon_state = "emag"
	item_state = "card-id"
	origin_tech = "magnets=2;syndicate=2"
	flags = NOBLUDGEON
	flags_2 = NO_MAT_REDEMPTION_2

/obj/item/card/emag/attack()
	return

/obj/item/card/emag/afterattack(atom/target, mob/user, proximity)
	var/atom/A = target
	if(!proximity)
		return
	A.emag_act(user)

/obj/item/card/cmag
	desc = "It's a card coated in a slurry of electromagnetic bananium."
	name = "jestographic sequencer"
	icon_state = "cmag"
	item_state = "card-id"
	origin_tech = "magnets=2;syndicate=2"
	flags = NOBLUDGEON
	flags_2 = NO_MAT_REDEMPTION_2

/obj/item/card/cmag/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/slippery, src, 16 SECONDS, 100)

/obj/item/card/cmag/attack()
	return

/obj/item/card/cmag/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return
	target.cmag_act(user)

/obj/item/card/id
	name = "identification card"
	desc = "A card used to provide ID and determine access across the station."
	icon_state = "id"
	item_state = "card-id"
	/// For redeeming at mining equipment lockers
	var/mining_points = 0
	/// Total mining points for the Shift.
	var/total_mining_points = 0
	var/list/access = list()
	var/registered_name = "Unknown" // The name registered_name on the card
	slot_flags = SLOT_FLAG_ID
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 100, ACID = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/untrackable // Can not be tracked by AI's

	var/blood_type = "\[UNSET\]"
	var/dna_hash = "\[UNSET\]"
	var/fingerprint_hash = "\[UNSET\]"

	//alt titles are handled a bit weirdly in order to unobtrusively integrate into existing ID system
	var/assignment = null	//can be alt title or the actual job
	var/rank = null			//actual job
	var/owner_uid
	var/owner_ckey
	var/lastlog
	var/dorm = 0			// determines if this ID has claimed a dorm already

	var/sex
	var/age
	var/photo
	var/dat
	var/stamped = 0

	var/obj/item/card/id/guest/guest_pass = null // Guest pass attached to the ID

/obj/item/card/id/New()
	..()
	spawn(30)
		if(ishuman(loc) && blood_type == "\[UNSET\]")
			var/mob/living/carbon/human/H = loc
			SetOwnerInfo(H)

/obj/item/card/id/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		show(usr)
	else
		. += "<span class='warning'>It is too far away.</span>"
	if(guest_pass)
		. += "<span class='notice'>There is a guest pass attached to this ID card, <b>Alt-Click</b> to remove it.</span>"
		if(world.time < guest_pass.expiration_time)
			. += "<span class='notice'>It expires at [station_time_timestamp("hh:mm:ss", guest_pass.expiration_time)].</span>"
		else
			. += "<span class='warning'>It expired at [station_time_timestamp("hh:mm:ss", guest_pass.expiration_time)].</span>"
		. += "<span class='notice'>It grants access to following areas:</span>"
		for(var/A in guest_pass.temp_access)
			. += "<span class='notice'>[get_access_desc(A)].</span>"
		. += "<span class='notice'>Issuing reason: [guest_pass.reason].</span>"

/obj/item/card/id/proc/show(mob/user as mob)
	var/datum/asset/assets = get_asset_datum(/datum/asset/simple/paper)
	assets.send(user)

	var/datum/browser/popup = new(user, "idcard", name, 600, 400)
	popup.set_content(dat)
	popup.set_title_image(usr.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/item/card/id/attack_self(mob/user as mob)
	user.visible_message("[user] shows you: [bicon(src)] [src.name]. The assignment on the card: [src.assignment]",\
		"You flash your ID card: [bicon(src)] [src.name]. The assignment on the card: [src.assignment]")
	if(mining_points)
		to_chat(user, "There's <b>[mining_points] Mining Points</b> loaded onto this card. This card has earned <b>[total_mining_points] Mining Points</b> this Shift!")
	src.add_fingerprint(user)
	return

/obj/item/card/id/proc/UpdateName()
	name = "[src.registered_name]'s ID Card ([src.assignment])"

/obj/item/card/id/proc/SetOwnerInfo(mob/living/carbon/human/H)
	if(!H || !H.dna)
		return

	sex = capitalize(H.gender)
	age = H.age
	blood_type = H.dna.blood_type
	dna_hash = H.dna.unique_enzymes
	fingerprint_hash = md5(H.dna.uni_identity)

	RebuildHTML()

/obj/item/card/id/proc/RebuildHTML()
	var/photo_front = "'data:image/png;base64,[icon2base64(icon(photo, dir = SOUTH))]'"
	var/photo_side = "'data:image/png;base64,[icon2base64(icon(photo, dir = WEST))]'"

	dat = {"<table><tr><td>
	Name: [registered_name]</A><BR>
	Sex: [sex]</A><BR>
	Age: [age]</A><BR>
	Rank: [assignment]</A><BR>
	Fingerprint: [fingerprint_hash]</A><BR>
	Blood Type: [blood_type]<BR>
	DNA Hash: [dna_hash]<BR><BR>
	<td align = center valign = top>Photo:<br><img src=[photo_front] height=80 width=80 border=4>
	<img src=[photo_side] height=80 width=80 border=4></td></tr></table>"}

/obj/item/card/id/GetAccess()
	if(!guest_pass)
		return access
	return access | guest_pass.GetAccess()

/obj/item/card/id/GetID()
	return src

/obj/item/card/id/proc/getRankAndAssignment()
	var/jobnamedata = ""
	if(rank)
		jobnamedata += rank
	if(rank != assignment)
		jobnamedata += " (" + assignment + ")"
	return jobnamedata

/obj/item/card/id/proc/getPlayer()
	if(owner_uid)
		var/mob/living/carbon/human/H = locateUID(owner_uid)
		if(istype(H) && H.ckey == owner_ckey)
			return H
		owner_uid = null
	if(owner_ckey)
		for(var/mob/M in GLOB.player_list)
			if(M.ckey && M.ckey == owner_ckey)
				owner_uid = M.UID()
				return M
		owner_ckey = null

/obj/item/card/id/proc/getPlayerCkey()
	var/mob/living/carbon/human/H = getPlayer()
	if(istype(H))
		return H.ckey

/obj/item/card/id/proc/is_untrackable()
	return untrackable

/obj/item/card/id/proc/update_label(newname, newjob)
	if(newname || newjob)
		name = "[(!newname)	? "identification card"	: "[newname]'s ID Card"][(!newjob) ? "" : " ([newjob])"]"
		return

	name = "[(!registered_name)	? "identification card"	: "[registered_name]'s ID Card"][(!assignment) ? "" : " ([assignment])"]"

/obj/item/card/id/proc/get_departments()
	return get_departments_from_job(rank)

/obj/item/card/id/attackby(obj/item/W as obj, mob/user as mob, params)
	..()

	if(istype(W, /obj/item/id_decal/))
		var/obj/item/id_decal/decal = W
		to_chat(user, "You apply [decal] to [src].")
		if(decal.override_name)
			name = decal.decal_name
		desc = decal.decal_desc
		icon_state = decal.decal_icon_state
		item_state = decal.decal_item_state
		qdel(decal)
		qdel(W)
		return

	else if(istype(W, /obj/item/barcodescanner))
		var/obj/item/barcodescanner/B = W
		B.scanID(src, user)
		return

	else if(istype (W,/obj/item/stamp))
		if(!stamped)
			dat+="<img src=large_[W.icon_state].png>"
			stamped = 1
			to_chat(user, "You stamp the ID card!")
			playsound(user, 'sound/items/handling/standard_stamp.ogg', 50, vary = TRUE)
		else
			to_chat(user, "This ID has already been stamped!")

	else if(istype(W, /obj/item/card/id/guest))
		if(istype(src, /obj/item/card/id/guest))
			return
		var/obj/item/card/id/guest/G = W
		if(world.time > G.expiration_time)
			to_chat(user, "There's no point, the guest pass has expired.")
			return
		if(guest_pass)
			to_chat(user, "There's already a guest pass attached to this ID.")
			return
		if(G.registered_name != registered_name && G.registered_name != "NOT SPECIFIED")
			to_chat(user, "The guest pass cannot be attached to this ID")
			return
		if(!user.unEquip(G))
			return
		G.loc = src
		guest_pass = G

/obj/item/card/id/AltClick(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return

	if(guest_pass)
		to_chat(user, "<span class='notice'>You remove the guest pass from this ID.</span>")
		guest_pass.forceMove(get_turf(src))
		guest_pass = null
	else
		to_chat(user, "<span class='warning'>There is no guest pass attached to this ID</span>")

/obj/item/card/id/serialize()
	var/list/data = ..()

	data["sex"] = sex
	data["age"] = age
	data["btype"] = blood_type
	data["dna_hash"] = dna_hash
	data["fprint_hash"] = fingerprint_hash
	data["access"] = access
	data["job"] = assignment
	data["account"] = associated_account_number
	data["owner"] = registered_name
	data["mining"] = mining_points
	data["total_mining"] = total_mining_points
	return data

/obj/item/card/id/deserialize(list/data)
	sex = data["sex"]
	age = data["age"]
	blood_type = data["btype"]
	dna_hash = data["dna_hash"]
	fingerprint_hash = data["fprint_hash"]
	access = data["access"] // No need for a copy, the list isn't getting touched
	assignment = data["job"]
	associated_account_number = data["account"]
	registered_name = data["owner"]
	mining_points = data["mining"]
	total_mining_points = data["total_mining"]
	// We'd need to use icon serialization(b64) to save the photo, and I don't feel like i
	UpdateName()
	RebuildHTML()
	..()

/obj/item/card/id/silver
	name = "identification card"
	desc = "A silver card which shows honour and dedication."
	icon_state = "silver"
	item_state = "silver_id"

/obj/item/card/id/gold
	name = "identification card"
	desc = "A golden card which shows power and might."
	icon_state = "gold"
	item_state = "gold_id"

/obj/item/card/id/syndicate
	name = "agent card"
	var/list/initial_access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE, ACCESS_EXTERNAL_AIRLOCKS)
	origin_tech = "syndicate=1"
	var/registered_user = null
	untrackable = TRUE

/obj/item/card/id/syndicate/researcher
	initial_access = list(ACCESS_SYNDICATE)
	assignment = "Syndicate Researcher"
	icon_state = "syndie"

/obj/item/card/id/syndicate/New()
	access = initial_access.Copy()
	..()

/obj/item/card/id/syndicate/vox
	name = "agent card"
	initial_access = list(ACCESS_MAINT_TUNNELS, ACCESS_VOX, ACCESS_EXTERNAL_AIRLOCKS)

/obj/item/card/id/syndicate/ghost_bar
	name = "ghost bar identification card"
	assignment = "Ghost Bar Occupant"
	initial_access = list() // This is for show, they don't need actual accesses
	icon_state = "assistant"

/obj/item/card/id/syndicate/command
	initial_access = list(ACCESS_MAINT_TUNNELS, ACCESS_SYNDICATE, ACCESS_SYNDICATE_LEADER, ACCESS_SYNDICATE_COMMAND, ACCESS_EXTERNAL_AIRLOCKS)
	icon_state = "commander"

/obj/item/card/id/syndicate/afterattack(obj/item/O as obj, mob/user as mob, proximity)
	if(!proximity)
		return
	if(istype(O, /obj/item/card/id))
		var/obj/item/card/id/I = O
		if(isliving(user) && user.mind)
			if(user.mind.special_role)
				to_chat(usr, "<span class='notice'>The card's microscanners activate as you pass it over \the [I], copying its access.</span>")
				src.access |= I.access //Don't copy access if user isn't an antag -- to prevent metagaming

/obj/item/card/id/syndicate/attack_self(mob/user as mob)
	if(!src.registered_name)
		var/t = reject_bad_name(input(user, "What name would you like to use on this card?", "Agent Card name", ishuman(user) ? user.real_name : user.name), TRUE)
		if(!t)
			to_chat(user, "<span class='warning'>Invalid name.</span>")
			return
		src.registered_name = t

		var/u = sanitize(stripped_input(user, "What occupation would you like to put on this card?\nNote: This will not grant any access levels other than maintenance.", "Agent Card Job Assignment", "Agent", MAX_MESSAGE_LEN))
		if(!u)
			to_chat(user, "<span class='warning'>Invalid assignment.</span>")
			src.registered_name = ""
			return
		src.assignment = u
		src.name = "[src.registered_name]'s ID Card ([src.assignment])"
		to_chat(user, "<span class='notice'>You successfully forge the ID card.</span>")
		registered_user = user.mind.current
	else if(!registered_user || registered_user == user.mind.current)
		if(!registered_user)
			registered_user = user.mind.current

		switch(alert(user,"Would you like to display \the [src] or edit it?","Choose","Show","Edit"))
			if("Show")
				return ..()
			if("Edit")
				switch(input(user,"What would you like to edit on \the [src]?") in list("Name", "Photo", "Appearance", "Sex", "Age", "Occupation", "Money Account", "Blood Type", "DNA Hash", "Fingerprint Hash", "Reset Access", "Delete Card Information"))
					if("Name")
						var/new_name = reject_bad_name(input(user,"What name would you like to put on this card?","Agent Card Name", ishuman(user) ? user.real_name : user.name), TRUE)
						if(!Adjacent(user))
							return
						src.registered_name = new_name
						UpdateName()
						to_chat(user, "<span class='notice'>Name changed to [new_name].</span>")
						RebuildHTML()

					if("Photo")
						if(!Adjacent(user))
							return
						var/job_clothes = null
						if(assignment)
							job_clothes = assignment
						var/icon/newphoto = get_id_photo(user, job_clothes)
						if(!newphoto)
							return
						photo = newphoto
						to_chat(user, "<span class='notice'>Photo changed. Select another occupation and take a new photo if you wish to appear with different clothes.</span>")
						RebuildHTML()

					if("Appearance")
						var/list/appearances = list(
							"data",
							"id",
							"gold",
							"silver",
							"centcom",
							"security",
							"detective",
							"warden",
							"internalaffairsagent",
							"medical",
							"coroner",
							"virologist",
							"chemist",
							"paramedic",
							"psychiatrist",
							"research",
							"roboticist",
							"quartermaster",
							"cargo",
							"shaftminer",
							"engineering",
							"atmostech",
							"captain",
							"HoP",
							"HoS",
							"CMO",
							"RD",
							"CE",
							"assistant",
							"clown",
							"mime",
							"barber",
							"botanist",
							"librarian",
							"chaplain",
							"bartender",
							"chef",
							"janitor",
							"explorer",
							"rainbow",
							"prisoner",
							"syndie",
							"deathsquad",
							"commander",
							"ERT_leader",
							"ERT_security",
							"ERT_engineering",
							"ERT_medical",
							"ERT_janitorial",
							"ERT_paranormal",
						)
						var/choice = input(user, "Select the appearance for this card.", "Agent Card Appearance") in appearances
						if(!Adjacent(user))
							return
						if(!choice)
							return
						icon_state = choice
						switch(choice)
							if("silver")
								desc = "A silver card which shows honour and dedication."
							if("gold")
								desc = "A golden card which shows power and might."
							if("clown")
								desc = "Even looking at the card strikes you with deep fear."
							if("mime")
								desc = "..."
							if("prisoner")
								desc = "You are a number, you are not a free man."
							if("centcom")
								desc = "An ID straight from Central Command."
							else
								desc = "A card used to provide ID and determine access across the station."
						to_chat(usr, "<span class='notice'>Appearance changed to [choice].</span>")

					if("Sex")
						var/new_sex = sanitize(stripped_input(user,"What sex would you like to put on this card?","Agent Card Sex", ishuman(user) ? capitalize(user.gender) : "Male", MAX_MESSAGE_LEN))
						if(!Adjacent(user))
							return
						sex = new_sex
						to_chat(user, "<span class='notice'>Sex changed to [new_sex].</span>")
						RebuildHTML()

					if("Age")
						var/default = "21"
						if(ishuman(user))
							var/mob/living/carbon/human/H = user
							default = H.age
						var/new_age = sanitize(input(user,"What age would you like to be written on this card?","Agent Card Age", default) as text)
						if(!Adjacent(user))
							return
						age = new_age
						to_chat(user, "<span class='notice'>Age changed to [new_age].</span>")
						RebuildHTML()

					if("Occupation")
						var/list/departments = list(
							"Assistant" = null,
							"Engineering" = GLOB.engineering_positions,
							"Medical" = GLOB.medical_positions,
							"Science" = GLOB.science_positions,
							"Security" = GLOB.security_positions,
							"Support" = GLOB.support_positions,
							"Supply" = GLOB.supply_positions,
							"Command" = GLOB.command_positions,
							"Custom" = null,
						)

						var/department = input(user, "What job would you like to put on this card?\nChoose a department or a custom job title.\nChanging occupation will not grant or remove any access levels.","Agent Card Occupation") in departments
						var/new_job = "Assistant"

						if(department == "Custom")
							new_job = sanitize(stripped_input(user,"Choose a custom job title:","Agent Card Occupation", "Assistant", MAX_MESSAGE_LEN))
						else if(department != "Assistant" && !isnull(departments[department]))
							new_job = input(user, "What job would you like to put on this card?\nChanging occupation will not grant or remove any access levels.","Agent Card Occupation") in departments[department]

						if(!Adjacent(user))
							return
						assignment = new_job
						to_chat(user, "<span class='notice'>Occupation changed to [new_job].</span>")
						UpdateName()
						RebuildHTML()

					if("Money Account")
						var/new_account = input(user,"What money account would you like to link to this card?","Agent Card Account",12345) as num
						if(!Adjacent(user))
							return
						associated_account_number = new_account
						to_chat(user, "<span class='notice'>Linked money account changed to [new_account].</span>")

					if("Blood Type")
						var/default = "\[UNSET\]"
						if(ishuman(user))
							var/mob/living/carbon/human/H = user
							if(H.dna)
								default = H.dna.blood_type

						var/new_blood_type = sanitize(input(user,"What blood type would you like to be written on this card?","Agent Card Blood Type",default) as text)
						if(!Adjacent(user))
							return
						blood_type = new_blood_type
						to_chat(user, "<span class='notice'>Blood type changed to [new_blood_type].</span>")
						RebuildHTML()

					if("DNA Hash")
						var/default = "\[UNSET\]"
						if(ishuman(user))
							var/mob/living/carbon/human/H = user
							if(H.dna)
								default = H.dna.unique_enzymes

						var/new_dna_hash = sanitize(input(user,"What DNA hash would you like to be written on this card?","Agent Card DNA Hash",default) as text)
						if(!Adjacent(user))
							return
						dna_hash = new_dna_hash
						to_chat(user, "<span class='notice'>DNA hash changed to [new_dna_hash].</span>")
						RebuildHTML()

					if("Fingerprint Hash")
						var/default = "\[UNSET\]"
						if(ishuman(user))
							var/mob/living/carbon/human/H = user
							if(H.dna)
								default = md5(H.dna.uni_identity)

						var/new_fingerprint_hash = sanitize(input(user,"What fingerprint hash would you like to be written on this card?","Agent Card Fingerprint Hash",default) as text)
						if(!Adjacent(user))
							return
						fingerprint_hash = new_fingerprint_hash
						to_chat(user, "<span class='notice'>Fingerprint hash changed to [new_fingerprint_hash].</span>")
						RebuildHTML()

					if("Reset Access")
						var/response = alert(user, "Are you sure you want to reset access saved on the card?","Reset Access", "No", "Yes")
						if(response == "Yes")
							access = initial_access.Copy() // Initial() doesn't work on lists
							to_chat(user, "<span class='notice'>Card access reset.</span>")

					if("Delete Card Information")
						var/response = alert(user, "Are you sure you want to delete all information saved on the card?","Delete Card Information", "No", "Yes")
						if(response == "Yes")
							name = initial(name)
							registered_name = initial(registered_name)
							icon_state = initial(icon_state)
							sex = initial(sex)
							age = initial(age)
							assignment = initial(assignment)
							associated_account_number = initial(associated_account_number)
							blood_type = initial(blood_type)
							dna_hash = initial(dna_hash)
							fingerprint_hash = initial(fingerprint_hash)
							photo = null
							registered_user = null
							to_chat(user, "<span class='notice'>All information has been deleted from \the [src].</span>")
							RebuildHTML()
	else
		..()

/obj/item/card/id/syndicate/Destroy()
	registered_user = null
	return ..()

/obj/item/card/id/syndicate_command
	name = "syndicate ID card"
	desc = "An ID straight from the Syndicate."
	registered_name = "Syndicate"
	icon_state = "syndie"
	assignment = "Syndicate Overlord"
	untrackable = TRUE
	access = list(ACCESS_SYNDICATE, ACCESS_SYNDICATE_LEADER, ACCESS_SYNDICATE_COMMAND, ACCESS_EXTERNAL_AIRLOCKS)

/obj/item/card/id/captains_spare
	name = "captain's spare ID"
	desc = "The spare ID of the captain."
	icon_state = "gold"
	item_state = "gold_id"
	registered_name = "Captain"
	assignment = "Captain"

/obj/item/card/id/captains_spare/New()
	var/datum/job/captain/J = new/datum/job/captain
	access = J.get_access()
	..()

/obj/item/card/id/admin
	name = "admin ID card"
	icon_state = "admin"
	item_state = "gold_id"
	registered_name = "Admin"
	assignment = "Testing Shit"
	untrackable = TRUE

/obj/item/card/id/admin/New()
	access = get_absolutely_all_accesses()
	..()

/obj/item/card/id/centcom
	name = "central command ID card"
	desc = "An ID straight from Central Command."
	icon_state = "centcom"
	registered_name = "Central Command"
	assignment = "General"

/obj/item/card/id/centcom/New()
	access = get_all_centcom_access()
	..()


/obj/item/card/id/prisoner
	name = "prisoner ID card"
	desc = "You are a number, you are not a free man."
	icon_state = "prisoner"
	item_state = "orange-id"
	assignment = "Prisoner"
	registered_name = "Scum"
	access = list(ACCESS_LIBRARY)
	var/goal = 0 //How far from freedom?

/obj/item/card/id/prisoner/examine(mob/user)
	. = ..()
	if(goal)
		. += "\nYou have accumulated [mining_points] out of the [goal] points assigned to gain freedom."

/obj/item/card/id/prisoner/one
	name = "Prisoner #13-001"
	icon_state = "prisonerone"
	registered_name = "Prisoner #13-001"

/obj/item/card/id/prisoner/two
	name = "Prisoner #13-002"
	icon_state = "prisonertwo"
	registered_name = "Prisoner #13-002"

/obj/item/card/id/prisoner/three
	name = "Prisoner #13-003"
	icon_state = "prisonerthree"
	registered_name = "Prisoner #13-003"

/obj/item/card/id/prisoner/four
	name = "Prisoner #13-004"
	icon_state = "prisonerfour"
	registered_name = "Prisoner #13-004"

/obj/item/card/id/prisoner/five
	name = "Prisoner #13-005"
	icon_state = "prisonerfive"
	registered_name = "Prisoner #13-005"

/obj/item/card/id/prisoner/six
	name = "Prisoner #13-006"
	icon_state = "prisonersix"
	registered_name = "Prisoner #13-006"

/obj/item/card/id/prisoner/seven
	name = "Prisoner #13-007"
	icon_state = "prisonerseven"
	registered_name = "Prisoner #13-007"

/obj/item/card/id/prisoner/random
/obj/item/card/id/prisoner/random/New()
	..()
	var/random_number = "#[rand(0, 99)]-[rand(0, 999)]"
	name = "Prisoner [random_number]"
	registered_name = name

/obj/item/card/id/salvage_captain
	name = "Captain's ID"
	registered_name = "Captain"
	icon_state = "centcom"
	desc = "Finders, keepers."
	access = list(ACCESS_SALVAGE_CAPTAIN)

/obj/item/card/id/medical
	name = "Medical ID"
	registered_name = "Medic"
	icon_state = "medical"
	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_GENETICS, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/coroner
	name = "Coroner ID"
	registered_name = "Coroner"
	icon_state = "coroner"
	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_GENETICS, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/virologist
	name = "Virologist ID"
	registered_name = "Virologist"
	icon_state = "virologist"
	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_GENETICS)

/obj/item/card/id/chemist
	name = "Chemist ID"
	registered_name = "Chemist"
	icon_state = "chemist"
	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_GENETICS, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/paramedic
	name = "Paramedic ID"
	registered_name = "Paramedic"
	icon_state = "paramedic"
	access = list(ACCESS_PARAMEDIC, ACCESS_MEDICAL, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_MORGUE)

/obj/item/card/id/psychiatrist
	name = "Psychiatrist ID"
	registered_name = "Psychiatrist"
	icon_state = "psychiatrist"
	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_GENETICS, ACCESS_PSYCHIATRIST)

/obj/item/card/id/security
	name = "Security ID"
	registered_name = "Officer"
	icon_state = "security"
	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_MORGUE, ACCESS_WEAPONS)

/obj/item/card/id/detective
	name = "Detective ID"
	registered_name = "Detective"
	icon_state = "detective"
	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_FORENSICS_LOCKERS, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS, ACCESS_COURT, ACCESS_WEAPONS)

/obj/item/card/id/warden
	name = "Warden ID"
	registered_name = "Warden"
	icon_state = "warden"
	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_MORGUE, ACCESS_WEAPONS)

/obj/item/card/id/internalaffairsagent
	name = "Internal Affairs Agent ID"
	registered_name = "Internal Affairs Agent"
	icon_state = "internalaffairsagent"
	access = list(ACCESS_LAWYER, ACCESS_COURT, ACCESS_SEC_DOORS, ACCESS_MAINT_TUNNELS, ACCESS_RESEARCH, ACCESS_MEDICAL, ACCESS_CONSTRUCTION, ACCESS_MAILSORTING)

/obj/item/card/id/geneticist
	name = "Geneticist ID"
	registered_name = "Geneticist"
	icon_state = "geneticist"
	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_GENETICS, ACCESS_RESEARCH, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/research
	name = "Research ID"
	registered_name = "Scientist"
	icon_state = "research"
	access = list(ACCESS_ROBOTICS, ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_RESEARCH, ACCESS_XENOBIOLOGY, ACCESS_XENOARCH, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/roboticist
	name = "Roboticist ID"
	registered_name = "Roboticist"
	icon_state = "roboticist"
	access = list(ACCESS_ROBOTICS, ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_TECH_STORAGE, ACCESS_MORGUE, ACCESS_RESEARCH, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/supply
	name = "Supply ID"
	registered_name = "Cargonian"
	icon_state = "cargo"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_QM, ACCESS_MINT, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/quartermaster
	name = "Quartermaster ID"
	registered_name = "Quartermaster"
	icon_state = "quartermaster"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_QM, ACCESS_MINT, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/shaftminer
	name = "Shaftminer ID"
	registered_name = "Shaftminer"
	icon_state = "shaftminer"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_QM, ACCESS_MINT, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/engineering
	name = "Engineering ID"
	registered_name = "Engineer"
	icon_state = "engineering"
	access = list(ACCESS_EVA, ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_CONSTRUCTION, ACCESS_ATMOSPHERICS)

/obj/item/card/id/atmostech
	name = "Life Support Specialist ID"
	registered_name = "Life Support Specialist"
	icon_state = "atmostech"
	access = list(ACCESS_EVA, ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_CONSTRUCTION, ACCESS_ATMOSPHERICS)

/obj/item/card/id/captains_spare/assigned
	name = "Captain ID"
	registered_name = "Captain"
	icon_state = "captain"

/obj/item/card/id/hop
	name = "Head of Personal ID"
	registered_name = "HoP"
	icon_state = "HoP"
	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_FORENSICS_LOCKERS,
						ACCESS_MEDICAL, ACCESS_ENGINE, ACCESS_CHANGE_IDS, ACCESS_AI_UPLOAD, ACCESS_EVA, ACCESS_HEADS,
						ACCESS_ALL_PERSONAL_LOCKERS, ACCESS_MAINT_TUNNELS, ACCESS_BAR, ACCESS_JANITOR, ACCESS_CONSTRUCTION, ACCESS_MORGUE,
						ACCESS_CREMATORIUM, ACCESS_KITCHEN, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_MAILSORTING, ACCESS_QM, ACCESS_HYDROPONICS, ACCESS_LAWYER,
						ACCESS_THEATRE, ACCESS_CHAPEL_OFFICE, ACCESS_LIBRARY, ACCESS_RESEARCH, ACCESS_MINING, ACCESS_HEADS_VAULT, ACCESS_MINING_STATION,
						ACCESS_CLOWN, ACCESS_MIME, ACCESS_HOP, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_EXPEDITION, ACCESS_WEAPONS, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/hos
	name = "Head of Security ID"
	registered_name = "HoS"
	icon_state = "HoS"
	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_ARMORY, ACCESS_COURT,
						ACCESS_FORENSICS_LOCKERS, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS, ACCESS_ALL_PERSONAL_LOCKERS,
						ACCESS_RESEARCH, ACCESS_ENGINE, ACCESS_MINING, ACCESS_MEDICAL, ACCESS_CONSTRUCTION, ACCESS_MAILSORTING,
						ACCESS_HEADS, ACCESS_HOS, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_EXPEDITION, ACCESS_WEAPONS)

/obj/item/card/id/cmo
	name = "Chief Medical Officer ID"
	registered_name = "CMO"
	icon_state = "CMO"
	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_GENETICS, ACCESS_HEADS,
			ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_CMO, ACCESS_SURGERY, ACCESS_RC_ANNOUNCE,
			ACCESS_KEYCARD_AUTH, ACCESS_SEC_DOORS, ACCESS_PSYCHIATRIST, ACCESS_PARAMEDIC, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/rd
	name = "Research Director ID"
	registered_name = "RD"
	icon_state = "RD"
	access = list(ACCESS_RD, ACCESS_HEADS, ACCESS_TOX, ACCESS_GENETICS, ACCESS_MORGUE,
						ACCESS_TOX_STORAGE, ACCESS_TECH_STORAGE, ACCESS_TELEPORTER, ACCESS_SEC_DOORS,
						ACCESS_RESEARCH, ACCESS_ROBOTICS, ACCESS_XENOBIOLOGY, ACCESS_AI_UPLOAD,
						ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_TCOMSAT, ACCESS_EXPEDITION, ACCESS_XENOARCH, ACCESS_MINISAT, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/ce
	name = "Chief Engineer ID"
	registered_name = "CE"
	icon_state = "CE"
	access = list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS,
						ACCESS_TELEPORTER, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_ATMOSPHERICS, ACCESS_EMERGENCY_STORAGE, ACCESS_EVA,
						ACCESS_HEADS, ACCESS_CONSTRUCTION, ACCESS_SEC_DOORS,
						ACCESS_CE, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_TCOMSAT, ACCESS_MINISAT, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/ntrep
	name = "Nanotrasen Representative ID"
	registered_name = "NTRep"
	icon_state = "ntrep"
	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_FORENSICS_LOCKERS,
						ACCESS_MEDICAL, ACCESS_ENGINE, ACCESS_CHANGE_IDS, ACCESS_EVA, ACCESS_HEADS,
						ACCESS_ALL_PERSONAL_LOCKERS, ACCESS_MAINT_TUNNELS, ACCESS_BAR, ACCESS_JANITOR, ACCESS_CONSTRUCTION, ACCESS_MORGUE,
						ACCESS_CREMATORIUM, ACCESS_KITCHEN, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_MAILSORTING, ACCESS_QM, ACCESS_HYDROPONICS, ACCESS_LAWYER,
						ACCESS_THEATRE, ACCESS_CHAPEL_OFFICE, ACCESS_LIBRARY, ACCESS_RESEARCH, ACCESS_MINING, ACCESS_HEADS_VAULT, ACCESS_MINING_STATION,
						ACCESS_CLOWN, ACCESS_MIME, ACCESS_HOP, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_EXPEDITION, ACCESS_WEAPONS, ACCESS_NTREP)

/obj/item/card/id/blueshield
	name = "Blueshield ID"
	registered_name = "Blueshield"
	icon_state = "blueshield"
	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_FORENSICS_LOCKERS,
						ACCESS_MEDICAL, ACCESS_ENGINE, ACCESS_CHANGE_IDS, ACCESS_EVA, ACCESS_HEADS,
						ACCESS_ALL_PERSONAL_LOCKERS, ACCESS_MAINT_TUNNELS, ACCESS_BAR, ACCESS_JANITOR, ACCESS_CONSTRUCTION, ACCESS_MORGUE,
						ACCESS_CREMATORIUM, ACCESS_KITCHEN, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_MAILSORTING, ACCESS_QM, ACCESS_HYDROPONICS, ACCESS_LAWYER,
						ACCESS_THEATRE, ACCESS_CHAPEL_OFFICE, ACCESS_LIBRARY, ACCESS_RESEARCH, ACCESS_MINING, ACCESS_HEADS_VAULT, ACCESS_MINING_STATION,
						ACCESS_CLOWN, ACCESS_MIME, ACCESS_HOP, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_EXPEDITION, ACCESS_WEAPONS, ACCESS_BLUESHIELD)

/obj/item/card/id/magistrate
	name = "Magistrate ID"
	registered_name = "Magistrate"
	icon_state = "magistrate"
	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_FORENSICS_LOCKERS,
						ACCESS_MEDICAL, ACCESS_ENGINE, ACCESS_CHANGE_IDS, ACCESS_EVA, ACCESS_HEADS,
						ACCESS_ALL_PERSONAL_LOCKERS, ACCESS_MAINT_TUNNELS, ACCESS_BAR, ACCESS_JANITOR, ACCESS_CONSTRUCTION, ACCESS_MORGUE,
						ACCESS_CREMATORIUM, ACCESS_KITCHEN, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_MAILSORTING, ACCESS_QM, ACCESS_HYDROPONICS, ACCESS_LAWYER,
						ACCESS_THEATRE, ACCESS_CHAPEL_OFFICE, ACCESS_LIBRARY, ACCESS_RESEARCH, ACCESS_MINING, ACCESS_HEADS_VAULT, ACCESS_MINING_STATION,
						ACCESS_CLOWN, ACCESS_MIME, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_EXPEDITION, ACCESS_MAGISTRATE)

/obj/item/card/id/assistant
	name = "Assistant ID"
	registered_name = "Assistant"
	icon_state = "assistant"
	access = list(ACCESS_MAINT_TUNNELS)

/obj/item/card/id/clown
	name = "Pink ID"
	registered_name = "HONK!"
	icon_state = "clown"
	desc = "Even looking at the card strikes you with deep fear."
	access = list(ACCESS_CLOWN, ACCESS_THEATRE, ACCESS_MAINT_TUNNELS)

/obj/item/card/id/mime
	name = "Black and White ID"
	registered_name = "..."
	icon_state = "mime"
	desc = "..."
	access = list(ACCESS_MIME, ACCESS_THEATRE, ACCESS_MAINT_TUNNELS)

/obj/item/card/id/barber
	name = "Barber ID"
	registered_name = "Barber"
	icon_state = "barber"
	access = list(ACCESS_MAINT_TUNNELS)

/obj/item/card/id/botanist
	name = "Botanist ID"
	registered_name = "Botanist"
	icon_state = "botanist"
	access = list(ACCESS_HYDROPONICS, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_MORGUE)

/obj/item/card/id/librarian
	name = "Librarian ID"
	registered_name = "Librarian"
	icon_state = "librarian"
	access = list(ACCESS_LIBRARY, ACCESS_MAINT_TUNNELS)

/obj/item/card/id/chaplain
	name = "Chaplain ID"
	registered_name = "Chaplain"
	icon_state = "chaplain"
	access = list(ACCESS_MORGUE, ACCESS_CHAPEL_OFFICE, ACCESS_CREMATORIUM, ACCESS_MAINT_TUNNELS)

/obj/item/card/id/bartender
	name = "Bartender ID"
	registered_name = "Bartender"
	icon_state = "bartender"
	access = list(ACCESS_HYDROPONICS, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_MORGUE, ACCESS_WEAPONS, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/chef
	name = "Chef ID"
	registered_name = "Chef"
	icon_state = "chef"
	access = list(ACCESS_HYDROPONICS, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_MORGUE)

/obj/item/card/id/janitor
	name = "Janitor ID"
	registered_name = "Janitor"
	icon_state = "janitor"
	access = list(ACCESS_HYDROPONICS, ACCESS_BAR, ACCESS_KITCHEN, ACCESS_MORGUE)

/obj/item/card/id/explorer
	name = "Explorer ID"
	registered_name = "Explorer"
	icon_state = "explorer"

/obj/item/card/id/rainbow
	name = "Rainbow ID"
	icon_state = "rainbow"

/obj/item/card/id/thunderdome/red
	name = "Thunderdome Red ID"
	registered_name = "Red Team Fighter"
	assignment = "Red Team Fighter"
	icon_state = "TDred"
	desc = "This ID card is given to those who fought inside the thunderdome for the Red Team. Not many have lived to see one of those, even fewer lived to keep it."

/obj/item/card/id/thunderdome/green
	name = "Thunderdome Green ID"
	registered_name = "Green Team Fighter"
	assignment = "Green Team Fighter"
	icon_state = "TDgreen"
	desc = "This ID card is given to those who fought inside the thunderdome for the Green Team. Not many have lived to see one of those, even fewer lived to keep it."

/obj/item/card/id/lifetime
	name = "Lifetime ID Card"
	desc = "A modified ID card given only to those people who have devoted their lives to the better interests of Nanotrasen. It sparkles blue."
	icon_state = "lifetimeid"

/obj/item/card/id/ert
	name = "ERT ID"
	icon_state = "ERT_empty"

/obj/item/card/id/ert/commander
	icon_state = "ERT_leader"

/obj/item/card/id/ert/security
	icon_state = "ERT_security"

/obj/item/card/id/ert/engineering
	icon_state = "ERT_engineering"

/obj/item/card/id/ert/medic
	icon_state = "ERT_medical"

/obj/item/card/id/ert/paranormal
	icon_state = "ERT_paranormal"

/obj/item/card/id/ert/janitorial
	icon_state = "ERT_janitorial"

/obj/item/card/id/ert/deathsquad
	icon_state = "deathsquad"

/obj/item/card/id/golem
	name = "Free Golem ID"
	desc = "A card used to claim mining points and buy gear. Use it to mark it as yours."
	icon_state = "research"
	access = list(ACCESS_FREE_GOLEMS, ACCESS_ROBOTICS, ACCESS_CLOWN, ACCESS_MIME) //access to robots/mechs
	var/registered = FALSE

/obj/item/card/id/golem/attack_self(mob/user as mob)
	if(!registered && ishuman(user))
		registered_name = user.real_name
		SetOwnerInfo(user)
		assignment = "Free Golem"
		RebuildHTML()
		UpdateName()
		desc = "A card used to claim mining points and buy gear."
		registered = TRUE
		to_chat(user, "<span class='notice'>The ID is now registered as yours.</span>")
	else
		..()

/obj/item/card/id/data
	icon_state = "data"

// Decals
/obj/item/id_decal
	name = "identification card decal"
	desc = "A nano-cellophane wrap that molds to an ID card to make it look snazzy."
	icon = 'icons/obj/toy.dmi'
	icon_state = "id_decal"
	var/decal_name = "identification card"
	var/decal_desc = "A card used to provide ID and determine access across the station."
	var/decal_icon_state = "id"
	var/decal_item_state = "card-id"
	var/override_name = 0

/obj/item/id_decal/gold
	name = "gold ID card decal"
	icon_state = "id_decal_gold"
	desc = "Make your ID look like the Captain's or a self-centered HOP's. Applies to any ID."
	decal_desc = "A golden card which shows power and might."
	decal_icon_state = "gold"
	decal_item_state = "gold_id"

/obj/item/id_decal/silver
	name = "silver ID card decal"
	icon_state = "id_decal_silver"
	desc = "Make your ID look like HOP's because they wouldn't change it officially. Applies to any ID."
	decal_desc = "A silver card which shows honour and dedication."
	decal_icon_state = "silver"
	decal_item_state = "silver_id"

/obj/item/id_decal/prisoner
	name = "prisoner ID card decal"
	icon_state = "id_decal_prisoner"
	desc = "All the cool kids have an ID that's this color. Applies to any ID."
	decal_desc = "You are a number, you are not a free man."
	decal_icon_state = "prisoner"
	decal_item_state = "orange-id"

/obj/item/id_decal/centcom
	name = "centcom ID card decal"
	icon_state = "id_decal_centcom"
	desc = "All the prestige without the responsibility or the access. Applies to any ID."
	decal_desc = "An ID straight from Cent. Com."
	decal_icon_state = "centcom"

/obj/item/id_decal/emag
	name = "cryptographic sequencer ID card decal"
	icon_state = "id_decal_emag"
	desc = "A bundle of wires that you can tape to your ID to look very suspect. Applies to any ID."
	decal_name = "cryptographic sequencer"
	decal_desc = "It's a card with a magnetic strip attached to some circuitry."
	decal_icon_state = "emag"
	override_name = 1

/proc/get_station_card_skins()
	return list("data","id","gold","silver","security","detective","warden","internalaffairsagent","medical","coroner","chemist","virologist","paramedic","psychiatrist","geneticist","research","roboticist","quartermaster","cargo","shaftminer","engineering","atmostech","captain","HoP","HoS","CMO","RD","CE","assistant","clown","mime","barber","botanist","librarian","chaplain","bartender","chef","janitor","rainbow","prisoner","explorer")

/proc/get_centcom_card_skins()
	return list("centcom","blueshield","magistrate","ntrep","ERT_leader","ERT_empty","ERT_security","ERT_engineering","ERT_medical","ERT_janitorial","ERT_paranormal","deathsquad","commander","syndie","TDred","TDgreen")

/proc/get_all_card_skins()
	return get_station_card_skins() + get_centcom_card_skins()

/proc/get_skin_desc(skin)
	switch(skin)
		if("id")
			return "Blank"
		if("cargo")
			return "Cargo Technician"
		if("shaftminer")
			return "Shaft Miner"
		if("medical")
			return "Medical Doctor"
		if("engineering")
			return "Station Engineer"
		if("security")
			return "Security Officer"
		if("internalaffairsagent")
			return "Internal Affairs Agent"
		if("atmostech")
			return "Life Support Specialist"
		if("HoP")
			return "Head of Personal"
		if("HoS")
			return "Head of Security"
		if("CMO")
			return "Chief Medical Officer"
		if("RD")
			return "Research Director"
		if("CE")
			return "Chief Engineer"
		if("ERT_leader")
			return "ERT Leader"
		if("ERT_empty")
			return "ERT Default"
		if("ERT_security")
			return "ERT Security"
		if("ERT_engineering")
			return "ERT Engineering"
		if("ERT_medical")
			return "ERT Medical"
		if("ERT_janitorial")
			return "ERT Janitorial"
		if("ERT_paranormal")
			return "ERT Paranormal"
		if("deathsquad")
			return "Deathsquad"
		if("syndie")
			return "Syndicate"
		if("TDred")
			return "Thunderdome Red"
		if("TDgreen")
			return "Thunderdome Green"
		else
			return capitalize(skin)
