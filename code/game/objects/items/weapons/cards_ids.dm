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
	w_class = 1
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

	if(t)
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
	var/untrackable // Can not be tracked by AI's

	var/blood_type = "\[UNSET\]"
	var/dna_hash = "\[UNSET\]"
	var/fingerprint_hash = "\[UNSET\]"

	//alt titles are handled a bit weirdly in order to unobtrusively integrate into existing ID system
	var/assignment = null	//can be alt title or the actual job
	var/rank = null			//actual job
	var/dorm = 0			// determines if this ID has claimed a dorm already

	var/datum/data/record/active1 = null
	var/sex
	var/age
	var/photo
	var/dat
	var/stamped = 0

	var/obj/item/weapon/card/id/guest/guest_pass = null // Guest pass attached to the ID

/obj/item/weapon/card/id/New()
	..()
	spawn(30)
		if(ishuman(loc) && blood_type == "\[UNSET\]")
			var/mob/living/carbon/human/H = loc
			SetOwnerInfo(H)

/obj/item/weapon/card/id/examine(mob/user)
	if(..(user, 1))
		show(usr)
	else
		to_chat(user, "<span class='warning'>It is too far away.</span>")
	if(guest_pass)
		to_chat(user, "<span class='notice'>There is a guest pass attached to this ID card</span>")
		if(world.time < guest_pass.expiration_time)
			to_chat(user, "<span class='notice'>It expires at [worldtime2text(guest_pass.expiration_time)].</span>")
		else
			to_chat(user, "<span class='warning'>It expired at [worldtime2text(guest_pass.expiration_time)].</span>")
		to_chat(user, "<span class='notice'>It grants access to following areas:</span>")
		for(var/A in guest_pass.temp_access)
			to_chat(user, "<span class='notice'>[get_access_desc(A)].</span>")
		to_chat(user, "<span class='notice'>Issuing reason: [guest_pass.reason].</span>")

/obj/item/weapon/card/id/proc/show(mob/user as mob)
	var/datum/asset/assets = get_asset_datum(/datum/asset/simple/paper)
	assets.send(user)

	var/datum/browser/popup = new(user, "idcard", name, 600, 400)
	popup.set_content(dat)
	popup.set_title_image(usr.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	return

/obj/item/weapon/card/id/attack_self(mob/user as mob)
	user.visible_message("[user] shows you: [bicon(src)] [src.name]. The assignment on the card: [src.assignment]",\
		"You flash your ID card: [bicon(src)] [src.name]. The assignment on the card: [src.assignment]")
	if(mining_points)
		to_chat(user, "There's [mining_points] mining equipment redemption points loaded onto this card.")
	src.add_fingerprint(user)
	return

/obj/item/weapon/card/id/proc/UpdateName()
	name = "[src.registered_name]'s ID Card ([src.assignment])"

/obj/item/weapon/card/id/proc/SetOwnerInfo(var/mob/living/carbon/human/H)
	if(!H || !H.dna)
		return

	sex = capitalize(H.gender)
	age = H.age
	blood_type = H.dna.b_type
	dna_hash = H.dna.unique_enzymes
	fingerprint_hash = md5(H.dna.uni_identity)

	RebuildHTML()

/obj/item/weapon/card/id/proc/RebuildHTML()
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

/obj/item/weapon/card/id/GetAccess()
	if(!guest_pass)
		return access
	return access | guest_pass.GetAccess()

/obj/item/weapon/card/id/GetID()
	return src

/obj/item/weapon/card/id/proc/is_untrackable()
	return untrackable

/obj/item/weapon/card/id/proc/update_label(newname, newjob)
	if(newname || newjob)
		name = "[(!newname)	? "identification card"	: "[newname]'s ID Card"][(!newjob) ? "" : " ([newjob])"]"
		return

	name = "[(!registered_name)	? "identification card"	: "[registered_name]'s ID Card"][(!assignment) ? "" : " ([assignment])"]"

/obj/item/weapon/card/id/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	..()

	if(istype(W, /obj/item/weapon/id_decal/))
		var/obj/item/weapon/id_decal/decal = W
		to_chat(user, "You apply [decal] to [src].")
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
			to_chat(user, "You stamp the ID card!")
		else
			to_chat(user, "This ID has already been stamped!")

	else if(istype(W, /obj/item/weapon/card/id/guest))
		if(istype(src, /obj/item/weapon/card/id/guest))
			return
		var/obj/item/weapon/card/id/guest/G = W
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

/obj/item/weapon/card/id/verb/remove_guest_pass()
	set name = "Remove Guest Pass"
	set category = "Object"
	set src in range(0)

	if(usr.stat || !usr.canmove || usr.restrained())
		return

	if(guest_pass)
		to_chat(usr, "<span class='notice'>You remove the guest pass from this ID.</span>")
		guest_pass.forceMove(get_turf(src))
		guest_pass = null
	else
		to_chat(usr, "<span class='warning'>There is no guest pass attached to this ID</span>")

/obj/item/weapon/card/id/serialize()
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
	return data

/obj/item/weapon/card/id/deserialize(list/data)
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
	// We'd need to use icon serialization(b64) to save the photo, and I don't feel like i
	UpdateName()
	RebuildHTML()
	..()

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
	var/list/initial_access = list(access_maint_tunnels, access_syndicate, access_external_airlocks)
	origin_tech = "syndicate=3"
	var/registered_user = null
	untrackable = 1

/obj/item/weapon/card/id/syndicate/New()
	access = initial_access.Copy()
	..()

/obj/item/weapon/card/id/syndicate/vox
	name = "agent card"
	initial_access = list(access_maint_tunnels, access_vox, access_external_airlocks)

/obj/item/weapon/card/id/syndicate/afterattack(var/obj/item/weapon/O as obj, mob/user as mob, proximity)
	if(!proximity)
		return
	if(istype(O, /obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/I = O
		if(istype(user, /mob/living) && user.mind)
			if(user.mind.special_role)
				to_chat(usr, "<span class='notice'>The card's microscanners activate as you pass it over \the [I], copying its access.</span>")
				src.access |= I.access //Don't copy access if user isn't an antag -- to prevent metagaming

/obj/item/weapon/card/id/syndicate/proc/fake_id_photo(var/mob/living/carbon/human/H)//get_id_photo wouldn't work correctly
	if(!istype(H))
		return
	var/storedDir = H.dir //don't want to lose track of this

	var/icon/faked = new()
	if(!H.equip_to_slot_if_possible(src, slot_l_store, 0, 1))
		to_chat(H, "<span class='warning'>You need to empty your pockets before taking the ID picture.</span>")
		return

	H.dir = WEST //ensure the icon is actually the proper direction before copying it
	faked.Insert(getFlatIcon(H), dir = WEST)
	H.dir = SOUTH
	faked.Insert(getFlatIcon(H), dir = SOUTH)
	H.dir = storedDir
	H.equip_to_slot_if_possible(src, slot_l_hand, 0, 1)

	return faked

/obj/item/weapon/card/id/syndicate/attack_self(mob/user as mob)
	if(!src.registered_name)
		var t = reject_bad_name(input(user, "What name would you like to use on this card?", "Agent Card name", ishuman(user) ? user.real_name : user.name))
		if(!t)
			to_chat(user, "<span class='warning'>Invalid name.</span>")
			return
		src.registered_name = t

		var u = sanitize(stripped_input(user, "What occupation would you like to put on this card?\nNote: This will not grant any access levels other than maintenance.", "Agent Card Job Assignment", "Agent", MAX_MESSAGE_LEN))
		if(!u)
			to_chat(user, "<span class='warning'>Invalid assignment.</span>")
			src.registered_name = ""
			return
		src.assignment = u
		src.name = "[src.registered_name]'s ID Card ([src.assignment])"
		to_chat(user, "<span class='notice'>You successfully forge the ID card.</span>")
		registered_user = user
	else if(!registered_user || registered_user == user)
		if(!registered_user)
			registered_user = user

		switch(alert(user,"Would you like to display \the [src] or edit it?","Choose","Show","Edit"))
			if("Show")
				return ..()
			if("Edit")
				switch(input(user,"What would you like to edit on \the [src]?") in list("Name","Photo","Appearance","Sex","Age","Occupation","Money Account","Blood Type","DNA Hash","Fingerprint Hash","Reset Card"))
					if("Name")
						var/new_name = reject_bad_name(input(user,"What name would you like to put on this card?","Agent Card Name", ishuman(user) ? user.real_name : user.name))
						if(!Adjacent(user))
							return
						src.registered_name = new_name
						UpdateName()
						to_chat(user, "<span class='notice'>Name changed to [new_name].</span>")
						RebuildHTML()

					if("Photo")
						if(!Adjacent(user))
							return
						var/icon/newphoto = fake_id_photo(user)
						if(!newphoto)
							return
						photo = newphoto
						to_chat(user, "<span class='notice'>Photo changed.</span>")
						RebuildHTML()

					if("Appearance")
						var/list/appearances = list(
							"data",
							"id",
							"gold",
							"silver",
							"centcom",
							"centcom_old",
							"security",
							"medical",
							"HoS",
							"research",
							"engineering",
							"CMO",
							"RD",
							"CE",
							"clown",
							"mime",
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
						)
						var/choice = input(user, "Select the appearance for this card.", "Agent Card Appearance") in appearances
						if(!Adjacent(user))
							return
						if(!choice)
							return
						src.icon_state = choice
						to_chat(usr, "<span class='notice'>Appearance changed to [choice].</span>")

					if("Sex")
						var/new_sex = sanitize(stripped_input(user,"What sex would you like to put on this card?","Agent Card Sex", ishuman(user) ? capitalize(user.gender) : "Male", MAX_MESSAGE_LEN))
						if(!Adjacent(user))
							return
						src.sex = new_sex
						to_chat(user, "<span class='notice'>Sex changed to [new_sex].</span>")
						RebuildHTML()

					if("Age")
						var/new_age = sanitize(stripped_input(user,"What age would you like to put on this card?","Agent Card Age","21", MAX_MESSAGE_LEN))
						if(!Adjacent(user))
							return
						src.age = new_age
						to_chat(user, "<span class='notice'>Age changed to [new_age].</span>")
						RebuildHTML()

					if("Occupation")
						var/new_job = sanitize(stripped_input(user,"What job would you like to put on this card?\nChanging occupation will not grant or remove any access levels.","Agent Card Occupation", "Civilian", MAX_MESSAGE_LEN))
						if(!Adjacent(user))
							return
						src.assignment = new_job
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
								default = H.dna.b_type

						var/new_blood_type = sanitize(input(user,"What blood type would you like to be written on this card?","Agent Card Blood Type",default) as text)
						if(!Adjacent(user))
							return
						src.blood_type = new_blood_type
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
						src.dna_hash = new_dna_hash
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
						src.fingerprint_hash = new_fingerprint_hash
						to_chat(user, "<span class='notice'>Fingerprint hash changed to [new_fingerprint_hash].</span>")
						RebuildHTML()

					if("Reset Card")
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
						access = initial_access.Copy() // Initial() doesn't work on lists
						registered_user = null

						to_chat(user, "<span class='notice'>All information has been deleted from \the [src].</span>")
						RebuildHTML()
	else
		..()

/obj/item/weapon/card/id/syndicate_command
	name = "syndicate ID card"
	desc = "An ID straight from the Syndicate."
	registered_name = "Syndicate"
	icon_state = "syndie"
	assignment = "Syndicate Overlord"
	untrackable = 1
	access = list(access_syndicate, access_external_airlocks)

/obj/item/weapon/card/id/captains_spare
	name = "captain's spare ID"
	desc = "The spare ID of the captain."
	icon_state = "gold"
	item_state = "gold_id"
	registered_name = "Captain"
	assignment = "Captain"

/obj/item/weapon/card/id/captains_spare/New()
	var/datum/job/captain/J = new/datum/job/captain
	access = J.get_access()
	..()

/obj/item/weapon/card/id/admin
	name = "admin ID card"
	icon_state = "admin"
	item_state = "gold_id"
	registered_name = "Admin"
	assignment = "Testing Shit"
	untrackable = 1

/obj/item/weapon/card/id/admin/New()
	access = get_absolutely_all_accesses()
	..()

/obj/item/weapon/card/id/centcom
	name = "central command ID card"
	desc = "An ID straight from Central Command."
	icon_state = "centcom"
	registered_name = "Central Command"
	assignment = "General"

/obj/item/weapon/card/id/centcom/New()
	access = get_all_centcom_access()
	..()

/obj/item/weapon/card/id/nanotrasen
	name = "nanotrasen ID card"
	icon_state = "nanotrasen"

/obj/item/weapon/card/id/prisoner
	name = "prisoner ID card"
	desc = "You are a number, you are not a free man."
	icon_state = "prisoner"
	item_state = "orange-id"
	assignment = "Prisoner"
	registered_name = "Scum"
	var/goal = 0 //How far from freedom?
	var/points = 0

/obj/item/weapon/card/id/prisoner/attack_self(mob/user as mob)
	to_chat(usr, "You have accumulated [points] out of the [goal] points you need for freedom.")

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

/obj/item/weapon/card/id/medical
	name = "Medical ID"
	registered_name = "Medic"
	icon_state = "medical"
	access = list(access_medical, access_morgue, access_surgery, access_chemistry, access_virology, access_genetics, access_mineral_storeroom)

/obj/item/weapon/card/id/security
	name = "Security ID"
	registered_name = "Officer"
	icon_state = "security"
	access = list(access_security, access_sec_doors, access_brig, access_court, access_maint_tunnels, access_morgue, access_weapons)

/obj/item/weapon/card/id/research
	name = "Research ID"
	registered_name = "Scientist"
	icon_state = "research"
	access = list(access_robotics, access_tox, access_tox_storage, access_research, access_xenobiology, access_xenoarch, access_mineral_storeroom)

/obj/item/weapon/card/id/supply
	name = "Supply ID"
	registered_name = "Cargonian"
	icon_state = "cargo"
	access = list(access_maint_tunnels, access_mailsorting, access_cargo, access_cargo_bot, access_qm, access_mint, access_mining, access_mining_station, access_mineral_storeroom)

/obj/item/weapon/card/id/engineering
	name = "Engineering ID"
	registered_name = "Engineer"
	icon_state = "engineering"
	access = list(access_eva, access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels, access_external_airlocks, access_construction, access_atmospherics)

/obj/item/weapon/card/id/hos
	name = "Head of Security ID"
	registered_name = "HoS"
	icon_state = "HoS"
	access = list(access_security, access_sec_doors, access_brig, access_armory, access_court,
			            access_forensics_lockers, access_pilot, access_morgue, access_maint_tunnels, access_all_personal_lockers,
			            access_research, access_engine, access_mining, access_medical, access_construction, access_mailsorting,
			            access_heads, access_hos, access_RC_announce, access_keycard_auth, access_gateway, access_weapons)

/obj/item/weapon/card/id/cmo
	name = "Chief Medical Officer ID"
	registered_name = "CMO"
	icon_state = "CMO"
	access = list(access_medical, access_morgue, access_genetics, access_heads,
			access_chemistry, access_virology, access_cmo, access_surgery, access_RC_announce,
			access_keycard_auth, access_sec_doors, access_psychiatrist, access_paramedic, access_mineral_storeroom)

/obj/item/weapon/card/id/rd
	name = "Research Director ID"
	registered_name = "RD"
	icon_state = "RD"
	access = list(access_rd, access_heads, access_tox, access_genetics, access_morgue,
			            access_tox_storage, access_tech_storage, access_teleporter, access_sec_doors,
			            access_research, access_robotics, access_xenobiology, access_ai_upload,
			            access_RC_announce, access_keycard_auth, access_tcomsat, access_gateway, access_xenoarch, access_minisat, access_mineral_storeroom)

/obj/item/weapon/card/id/ce
	name = "Chief Engineer ID"
	registered_name = "CE"
	icon_state = "CE"
	access = list(access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels,
			            access_teleporter, access_external_airlocks, access_atmospherics, access_emergency_storage, access_eva,
			            access_heads, access_construction, access_sec_doors,
			            access_ce, access_RC_announce, access_keycard_auth, access_tcomsat, access_minisat, access_mechanic, access_mineral_storeroom)

/obj/item/weapon/card/id/clown
	name = "Pink ID"
	registered_name = "HONK!"
	icon_state = "clown"
	desc = "Even looking at the card strikes you with deep fear."
	access = list(access_clown, access_theatre, access_maint_tunnels)

/obj/item/weapon/card/id/mime
	name = "Black and White ID"
	registered_name = "..."
	icon_state = "mime"
	desc = "..."
	access = list(access_mime, access_theatre, access_maint_tunnels)

/obj/item/weapon/card/id/rainbow
	name = "Rainbow ID"
	icon_state = "rainbow"

/obj/item/weapon/card/id/thunderdome/red
	name = "Thunderdome Red ID"
	registered_name = "Red Team Fighter"
	assignment = "Red Team Fighter"
	icon_state = "TDred"
	desc = "This ID card is given to those who fought inside the thunderdome for the Red Team. Not many have lived to see one of those, even fewer lived to keep it."

/obj/item/weapon/card/id/thunderdome/green
	name = "Thunderdome Green ID"
	registered_name = "Green Team Fighter"
	assignment = "Green Team Fighter"
	icon_state = "TDgreen"
	desc = "This ID card is given to those who fought inside the thunderdome for the Green Team. Not many have lived to see one of those, even fewer lived to keep it."

/obj/item/weapon/card/id/lifetime
	name = "Lifetime ID Card"
	desc = "A modified ID card given only to those people who have devoted their lives to the better interests of Nanotrasen. It sparkles blue."
	icon_state = "lifetimeid"

// Decals
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
	decal_icon_state = "prisoner"
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

/proc/get_station_card_skins()
	return list("data","id","gold","silver","security","medical","research","engineering","HoS","CMO","RD","CE","clown","mime","rainbow","prisoner")

/proc/get_centcom_card_skins()
	return list("centcom","centcom_old","nanotrasen","ERT_leader","ERT_empty","ERT_security","ERT_engineering","ERT_medical","ERT_janitorial","deathsquad","commander","syndie","TDred","TDgreen")

/proc/get_all_card_skins()
	return get_station_card_skins() + get_centcom_card_skins()

/proc/get_skin_desc(skin)
	switch(skin)
		if("id")
			return "Standard"
		if("HoS")
			return "Head of Security"
		if("CMO")
			return "Chief Medical Officer"
		if("RD")
			return "Research Director"
		if("CE")
			return "Chief Engineer"
		if("centcom_old")
			return "Centcom Old"
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
		if("syndie")
			return "Syndicate"
		if("TDred")
			return "Thunderdome Red"
		if("TDgreen")
			return "Thunderdome Green"
		else
			return capitalize(skin)
