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
	slot_flags = ITEM_SLOT_ID

	new_attack_chain = TRUE
	var/associated_account_number = 0

	var/list/files = list()

/obj/item/card/proc/get_card_account()
	return GLOB.station_money_database.find_user_account(associated_account_number)

/*
 * ID CARDS
 */

/obj/item/card/emag_broken
	desc = "It's a card with a magnetic strip attached to some circuitry. It looks too busted to be used for anything but salvage."
	name = "broken cryptographic sequencer"
	icon_state = "emag"
	inhand_icon_state = "card-id"
	origin_tech = "magnets=2;syndicate=2"
	prefered_slot_flags = ITEM_SLOT_BOTH_POCKETS

/obj/item/card/emag
	desc = "It's a card with a magnetic strip attached to some circuitry."
	name = "cryptographic sequencer"
	icon_state = "emag"
	inhand_icon_state = "card-id"
	origin_tech = "magnets=2;syndicate=2"
	flags = NOBLUDGEON
	flags_2 = NO_MAT_REDEMPTION_2
	prefered_slot_flags = ITEM_SLOT_BOTH_POCKETS

/obj/item/card/emag/pre_attack(atom/target, mob/living/user, params)
	if(..() || ismob(target))
		return FINISH_ATTACK

/obj/item/card/emag/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(target.emag_act(user))
		return ITEM_INTERACT_COMPLETE

/obj/item/card/emag/magic_key
	name = "magic key"
	desc = "It's a magic key, that will open one door!"
	icon_state = "magic_key"
	origin_tech = "magnets=2"

/obj/item/card/emag/magic_key/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(!isairlock(target))
		return NONE
	var/obj/machinery/door/D = target
	D.locked = FALSE
	D.update_icon()
	D.emag_act(user)
	qdel(src)
	return ITEM_INTERACT_COMPLETE

/obj/item/card/cmag
	desc = "It's a card coated in a slurry of electromagnetic bananium."
	name = "jestographic sequencer"
	icon_state = "cmag"
	inhand_icon_state = "card-id"
	origin_tech = "magnets=2;syndicate=2"
	flags = NOBLUDGEON
	flags_2 = NO_MAT_REDEMPTION_2
	prefered_slot_flags = ITEM_SLOT_BOTH_POCKETS

/obj/item/card/cmag/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/slippery, src, 16 SECONDS, 100)

/obj/item/card/cmag/pre_attack(atom/target, mob/living/user, params)
	if(..() || ismob(target))
		return FINISH_ATTACK

/obj/item/card/cmag/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(target.cmag_act(user))
		return ITEM_INTERACT_COMPLETE

/obj/item/card/id
	name = "identification card"
	desc = "A card used to provide ID and determine access across the station."
	icon_state = "id"
	inhand_icon_state = "card-id"
	/// For redeeming at mining equipment lockers
	var/mining_points = 0
	/// Total mining points for the Shift.
	var/total_mining_points = 0
	var/list/access = list()
	var/registered_name = "Unknown" // The name registered_name on the card
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

	/// Can we flash the ID?
	var/can_id_flash = TRUE

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
	popup.open()

/obj/item/card/id/proc/regenerate_name()
	name = "[registered_name]'s ID Card ([assignment])"

/obj/item/card/id/activate_self(mob/user)
	if(..())
		return
	if(can_id_flash)
		flash_card(user)

/obj/item/card/id/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(!isliving(target))
		return NONE
	return shared_interact(target, user)

/obj/item/card/id/ranged_interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(isliving(target) && get_dist(target, user) <= 2)
		return shared_interact(target, user)
	return NONE

/obj/item/card/id/proc/shared_interact(mob/living/victim, mob/living/user)
	if(victim.has_status_effect(STATUS_EFFECT_OFFERING_EFTPOS))
		var/obj/item/eftpos/eftpos = victim.is_holding_item_of_type(/obj/item/eftpos)
		if(!eftpos || !eftpos.can_offer)
			to_chat(user, "<span class='warning'>They don't seem to have it in hand anymore.</span>")
			return ITEM_INTERACT_COMPLETE
		victim.remove_status_effect(STATUS_EFFECT_OFFERING_EFTPOS)
		eftpos.scan_card(src, user)
		return ITEM_INTERACT_COMPLETE
	return NONE

/obj/item/card/id/proc/UpdateName()
	name = "[registered_name]'s ID Card ([assignment])"

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

/obj/item/card/id/proc/attach_guest_pass(obj/item/card/id/guest/G, mob/user)
	if(world.time > G.expiration_time)
		to_chat(user, "There's no point, the guest pass has expired.")
		return
	if(guest_pass)
		to_chat(user, "There's already a guest pass attached to this ID.")
		return
	if(G.registered_name != registered_name && G.registered_name != "NOT SPECIFIED")
		to_chat(user, "The guest pass cannot be attached to this ID.")
		return
	if(!user.transfer_item_to(G, src))
		return
	guest_pass = G

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

/obj/item/card/id/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/id_decal/))
		var/obj/item/id_decal/decal = used
		to_chat(user, "You apply [decal] to [src].")
		if(decal.override_name)
			name = decal.decal_name
		desc = decal.decal_desc
		icon_state = decal.decal_icon_state
		inhand_icon_state = decal.decal_inhand_icon_state
		qdel(decal)
		qdel(used)
		return ITEM_INTERACT_COMPLETE

	else if(istype(used, /obj/item/barcodescanner))
		var/obj/item/barcodescanner/B = used
		B.scanID(src, user)
		return ITEM_INTERACT_COMPLETE

	else if(istype(used, /obj/item/stamp))
		if(!stamped)
			dat+="<img src=large_[used.icon_state].png>"
			stamped = 1
			to_chat(user, "You stamp the ID card!")
			playsound(user, 'sound/items/handling/standard_stamp.ogg', 50, vary = TRUE)
			return ITEM_INTERACT_COMPLETE
		to_chat(user, "This ID has already been stamped!")
		return ITEM_INTERACT_COMPLETE


	else if(istype(used, /obj/item/card/id/guest))
		attach_guest_pass(used, user)
		return ITEM_INTERACT_COMPLETE

	else if(istype(used, /obj/item/storage/wallet))
		used.attackby__legacy__attackchain(src, user)
		return ITEM_INTERACT_COMPLETE

/obj/item/card/id/AltClick(mob/user)
	if(user.stat || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED) || !Adjacent(user))
		return

	if(guest_pass)
		to_chat(user, "<span class='notice'>You remove the guest pass from this ID.</span>")
		guest_pass.forceMove(get_turf(src))
		guest_pass = null
	else
		to_chat(user, "<span class='warning'>There is no guest pass attached to this ID.</span>")

/obj/item/card/id/serialize()
	var/list/data = ..()

	data["sex"] = sex
	data["age"] = age
	data["btype"] = blood_type
	data["dna_hash"] = dna_hash
	data["fprint_hash"] = fingerprint_hash
	data["access"] = access
	data["assignment"] = assignment
	data["rank"] = rank
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
	assignment = data["job"] // backup for old jsons
	assignment = data["assignment"]
	rank = data["rank"]
	associated_account_number = data["account"]
	registered_name = data["owner"]
	mining_points = data["mining"]
	total_mining_points = data["total_mining"]
	// We'd need to use icon serialization(b64) to save the photo, and I don't feel like i
	UpdateName()
	RebuildHTML()
	..()

/obj/item/card/id/proc/to_tgui()
	. = list()
	.["name"] = name
	.["rank"] = rank
	.["registered_name"] = registered_name
	.["assignment"] = assignment
	.["current_skin"] = icon_state
	.["current_skin_name"] = get_skin_desc(icon_state)
	.["lastlog"] = lastlog
	.["access"] = access
	.["associated_account_number"] = associated_account_number

/obj/item/card/id/proc/flash_card(mob/user)
	user.visible_message("[user] shows you: [bicon(src)] [name]. The assignment on the card: [assignment]",\
		"You flash your ID card: [bicon(src)] [name]. The assignment on the card: [assignment]")
	if(mining_points)
		to_chat(user, "There's <b>[mining_points] Mining Points</b> loaded onto this card. This card has earned <b>[total_mining_points] Mining Points</b> this Shift!")
	add_fingerprint(user)

/obj/item/card/id/silver
	desc = "A silver card which shows honour and dedication."
	icon_state = "silver"
	inhand_icon_state = "silver_id"

/obj/item/card/id/gold
	desc = "A golden card which shows power and might."
	icon_state = "gold"
	inhand_icon_state = "gold_id"

/obj/item/card/id/captains_spare
	name = "captain's spare ID"
	desc = "The spare ID of the captain. Keep this secured."
	icon_state = "gold"
	inhand_icon_state = "gold_id"
	registered_name = "Captain"
	assignment = "Captain"

/obj/item/card/id/captains_spare/New()
	access = get_all_accesses()
	..()

/obj/item/card/id/admin
	name = "admin ID card"
	icon_state = "admin"
	inhand_icon_state = "gold_id"
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
	assignment = "Prisoner"
	registered_name = "Scum"
	access = list(ACCESS_LIBRARY)
	/// How many mining points you need to be released from the labour camp.
	var/goal = 0

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
	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_EVIDENCE, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_MORGUE, ACCESS_WEAPONS)

/obj/item/card/id/detective
	name = "Detective ID"
	registered_name = "Detective"
	icon_state = "detective"
	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_EVIDENCE, ACCESS_FORENSICS_LOCKERS, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS, ACCESS_COURT, ACCESS_WEAPONS)

/obj/item/card/id/warden
	name = "Warden ID"
	registered_name = "Warden"
	icon_state = "warden"
	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_EVIDENCE, ACCESS_ARMORY, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_MORGUE, ACCESS_WEAPONS)

/obj/item/card/id/internalaffairsagent
	name = "Internal Affairs Agent ID"
	registered_name = "Internal Affairs Agent"
	icon_state = "internalaffairsagent"
	access = list(ACCESS_INTERNAL_AFFAIRS, ACCESS_COURT, ACCESS_SEC_DOORS, ACCESS_MAINT_TUNNELS, ACCESS_RESEARCH, ACCESS_MEDICAL, ACCESS_CONSTRUCTION, ACCESS_MAILSORTING)

/obj/item/card/id/geneticist
	name = "Geneticist ID"
	registered_name = "Geneticist"
	icon_state = "geneticist"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_GENETICS, ACCESS_RESEARCH)

/obj/item/card/id/research
	name = "Research ID"
	registered_name = "Scientist"
	icon_state = "research"
	access = list(ACCESS_ROBOTICS, ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_RESEARCH, ACCESS_XENOBIOLOGY, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/xenobiology
	name = "Xenobiology ID"
	registered_name = "Xenobiologist"
	icon_state = "xenobiologist"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_MINERAL_STOREROOM, ACCESS_RESEARCH, ACCESS_XENOBIOLOGY, ACCESS_EVA, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_TELEPORTER)

/obj/item/card/id/roboticist
	name = "Roboticist ID"
	registered_name = "Roboticist"
	icon_state = "roboticist"
	access = list(ACCESS_ROBOTICS, ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_TECH_STORAGE, ACCESS_MORGUE, ACCESS_RESEARCH, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/supply
	name = "Supply ID"
	registered_name = "Cargonian"
	icon_state = "cargo"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_QM, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/smith
	name = "Smith ID"
	registered_name = "Smith"
	icon_state = "smith"
	access = list(ACCESS_CARGO_BAY, ACCESS_CARGO, ACCESS_MAINT_TUNNELS, ACCESS_MINERAL_STOREROOM, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_SMITH)

/obj/item/card/id/quartermaster
	name = "Quartermaster ID"
	registered_name = "Quartermaster"
	icon_state = "quartermaster"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_QM, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM, ACCESS_SMITH)

/obj/item/card/id/shaftminer
	name = "Shaftminer ID"
	registered_name = "Shaftminer"
	icon_state = "shaftminer"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_QM, ACCESS_MINING, ACCESS_MINING_STATION, ACCESS_MINERAL_STOREROOM)

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
	icon_state = "captain"

/obj/item/card/id/hop
	name = "Head of Personal ID"
	registered_name = "HoP"
	icon_state = "HoP"
	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_FORENSICS_LOCKERS,
						ACCESS_MEDICAL, ACCESS_ENGINE, ACCESS_CHANGE_IDS, ACCESS_AI_UPLOAD, ACCESS_EVA, ACCESS_HEADS,
						ACCESS_ALL_PERSONAL_LOCKERS, ACCESS_MAINT_TUNNELS, ACCESS_BAR, ACCESS_JANITOR, ACCESS_CONSTRUCTION, ACCESS_MORGUE,
						ACCESS_CREMATORIUM, ACCESS_KITCHEN, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_MAILSORTING, ACCESS_QM, ACCESS_HYDROPONICS, ACCESS_INTERNAL_AFFAIRS,
						ACCESS_THEATRE, ACCESS_CHAPEL_OFFICE, ACCESS_LIBRARY, ACCESS_RESEARCH, ACCESS_MINING, ACCESS_HEADS_VAULT, ACCESS_MINING_STATION,
						ACCESS_CLOWN, ACCESS_MIME, ACCESS_HOP, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_EXPEDITION, ACCESS_WEAPONS, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/hos
	name = "Head of Security ID"
	registered_name = "HoS"
	icon_state = "HoS"
	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_EVIDENCE, ACCESS_ARMORY, ACCESS_COURT,
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
						ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_TCOMSAT, ACCESS_EXPEDITION, ACCESS_MINISAT, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/ce
	name = "Chief Engineer ID"
	registered_name = "CE"
	icon_state = "CE"
	access = list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_TECH_STORAGE, ACCESS_MAINT_TUNNELS,
						ACCESS_TELEPORTER, ACCESS_EXTERNAL_AIRLOCKS, ACCESS_ATMOSPHERICS, ACCESS_EVA,
						ACCESS_HEADS, ACCESS_CONSTRUCTION, ACCESS_SEC_DOORS,
						ACCESS_CE, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_TCOMSAT, ACCESS_MINISAT, ACCESS_MINERAL_STOREROOM)

/obj/item/card/id/ntrep
	name = "Nanotrasen Representative ID"
	registered_name = "NTRep"
	icon_state = "ntrep"
	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_FORENSICS_LOCKERS,
						ACCESS_MEDICAL, ACCESS_ENGINE, ACCESS_CHANGE_IDS, ACCESS_EVA, ACCESS_HEADS,
						ACCESS_ALL_PERSONAL_LOCKERS, ACCESS_MAINT_TUNNELS, ACCESS_BAR, ACCESS_JANITOR, ACCESS_CONSTRUCTION, ACCESS_MORGUE,
						ACCESS_CREMATORIUM, ACCESS_KITCHEN, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_MAILSORTING, ACCESS_QM, ACCESS_HYDROPONICS, ACCESS_INTERNAL_AFFAIRS,
						ACCESS_THEATRE, ACCESS_CHAPEL_OFFICE, ACCESS_LIBRARY, ACCESS_RESEARCH, ACCESS_MINING, ACCESS_HEADS_VAULT, ACCESS_MINING_STATION,
						ACCESS_CLOWN, ACCESS_MIME, ACCESS_HOP, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_EXPEDITION, ACCESS_WEAPONS, ACCESS_NTREP)

/obj/item/card/id/nct
	name = "\improper Nanotrasen Career Trainer ID"
	registered_name = "Nanotrasen Career Trainer"
	icon_state = "nctrainer"
	access = list(ACCESS_ALL_PERSONAL_LOCKERS, ACCESS_CARGO, ACCESS_CONSTRUCTION, ACCESS_COURT, ACCESS_EVA, ACCESS_TRAINER, ACCESS_MAINT_TUNNELS,
						ACCESS_MEDICAL, ACCESS_RESEARCH, ACCESS_SEC_DOORS, ACCESS_THEATRE, ACCESS_INTERNAL_AFFAIRS)

/obj/item/card/id/blueshield
	name = "Blueshield ID"
	registered_name = "Blueshield"
	icon_state = "blueshield"
	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_FORENSICS_LOCKERS,
						ACCESS_MEDICAL, ACCESS_ENGINE, ACCESS_EVIDENCE, ACCESS_CHANGE_IDS, ACCESS_EVA, ACCESS_HEADS,
						ACCESS_ALL_PERSONAL_LOCKERS, ACCESS_MAINT_TUNNELS, ACCESS_BAR, ACCESS_JANITOR, ACCESS_CONSTRUCTION, ACCESS_MORGUE,
						ACCESS_CREMATORIUM, ACCESS_KITCHEN, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_MAILSORTING, ACCESS_QM, ACCESS_HYDROPONICS, ACCESS_INTERNAL_AFFAIRS,
						ACCESS_THEATRE, ACCESS_CHAPEL_OFFICE, ACCESS_LIBRARY, ACCESS_RESEARCH, ACCESS_MINING, ACCESS_HEADS_VAULT, ACCESS_MINING_STATION,
						ACCESS_CLOWN, ACCESS_MIME, ACCESS_HOP, ACCESS_RC_ANNOUNCE, ACCESS_KEYCARD_AUTH, ACCESS_EXPEDITION, ACCESS_WEAPONS, ACCESS_BLUESHIELD)

/obj/item/card/id/magistrate
	name = "Magistrate ID"
	registered_name = "Magistrate"
	icon_state = "magistrate"
	access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_FORENSICS_LOCKERS,
						ACCESS_MEDICAL, ACCESS_ENGINE, ACCESS_EVIDENCE, ACCESS_CHANGE_IDS, ACCESS_EVA, ACCESS_HEADS,
						ACCESS_ALL_PERSONAL_LOCKERS, ACCESS_MAINT_TUNNELS, ACCESS_BAR, ACCESS_JANITOR, ACCESS_CONSTRUCTION, ACCESS_MORGUE,
						ACCESS_CREMATORIUM, ACCESS_KITCHEN, ACCESS_CARGO, ACCESS_CARGO_BOT, ACCESS_MAILSORTING, ACCESS_QM, ACCESS_HYDROPONICS, ACCESS_INTERNAL_AFFAIRS,
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
	access = list(ACCESS_FREE_GOLEMS, ACCESS_ROBOTICS, ACCESS_CLOWN, ACCESS_MIME, ACCESS_XENOBIOLOGY, ACCESS_SMITH) //access to robots/mechs
	can_id_flash = FALSE //So you do not flash it the first time you use it.
	var/registered = FALSE

/obj/item/card/id/golem/activate_self(mob/user)
	if(..())
		return
	if(!registered && ishuman(user))
		registered_name = user.real_name
		SetOwnerInfo(user)
		assignment = "Free Golem"
		RebuildHTML()
		UpdateName()
		desc = "A card used to claim mining points and buy gear."
		registered = TRUE
		can_id_flash = TRUE
		to_chat(user, "<span class='notice'>The ID is now registered as yours.</span>")

/obj/item/card/id/data
	icon_state = "data"

/obj/item/card/id/nct_data_chip
	name = "\improper NCT Trainee Access Chip"
	desc = "A small electronic access token that allows its user to copy the access of their Trainee. Only accessible by NT Career Trainers!"
	icon_state = "nct_chip"
	assignment = "Nanotrasen Career Trainer"
	var/registered_user = null
	var/trainee = null

/obj/item/card/id/nct_data_chip/examine(mob/user)
	. = ..()
	. += "<br>The current registered Trainee is: <b>[trainee]</b>"
	. += "<span class='notice'>Use in hand to reset the assigned trainee and access.</span>"
	. += "<span class='purple'>The datachip is unable to copy any access that has been deemed high-risk by Nanotrasen Officials. That includes some, if not most, head related access permissions.</span>"

/obj/item/card/id/nct_data_chip/activate_self(mob/user)
	if(..())
		return
	if(!trainee)
		return

	var/response = tgui_alert(user, "Would you like to remove [trainee] as your current active Trainee?", "Choose", list("Yes", "No"))
	if(response == "Yes")
		trainee = null
		icon_state = "nct_chip"
		access = list()

/obj/item/card/id/nct_data_chip/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(!istype(target, /obj/item/card/id))
		return
	if(!(isliving(user) && user.mind))
		return

	if(user.mind.current != registered_user)
		to_chat(user, "<span class='notice'>You do not have access to use this NCT Trainee Access Chip!</span>")
		return

	if(istype(target, /obj/item/card/id/ert))
		to_chat(user, "<span class='warning'>The chip's screen blinks red as you attempt scanning this ID.</span>")
		return

	var/obj/item/card/id/I = target
	to_chat(user, "<span class='notice'>The chip's microscanners activate as you scan [I.registered_name]'s ID, copying its access.</span>")
	access = I.access.Copy()
	access.Remove(ACCESS_AI_UPLOAD, ACCESS_ARMORY, ACCESS_CAPTAIN, ACCESS_CE, ACCESS_RD, ACCESS_HOP, ACCESS_QM, ACCESS_CMO, ACCESS_HOS, ACCESS_NTREP,
						ACCESS_MAGISTRATE, ACCESS_BLUESHIELD, ACCESS_HEADS_VAULT, ACCESS_KEYCARD_AUTH, ACCESS_RC_ANNOUNCE,
						ACCESS_CHANGE_IDS, ACCESS_MINISAT)
	trainee = I.registered_name
	icon_state = "nct_chip_active"

/obj/item/card/id/syndicate_fake // Syndicate ID drip with none of the access theft or anti-tracking.
	name = "\improper Syndicate ID card"
	desc = "An evil-looking ID issued to members of the Syndicate."
	icon_state = "syndie"

/obj/item/card/id/vv_get_dropdown()
	. = ..()

	VV_DROPDOWN_OPTION(VV_HK_MODIFY_ID_CARD, "Modify ID Card")

/obj/item/card/id/vv_do_topic(list/href_list)
	. = ..()

	if(!.)
		return

	if(href_list[VV_HK_MODIFY_ID_CARD])
		if(!check_rights(R_ADMIN))
			return

		var/turf/T = get_turf(src)
		message_admins("[key_name_admin(usr)] is modifying the ID card [src] [ADMIN_COORDJMP(T)]")
		var/datum/ui_module/id_card_modifier/ui = new(target = src)
		ui.ui_interact(usr)

// Decals
/obj/item/id_decal
	name = "identification card decal"
	desc = "A nano-cellophane wrap that molds to an ID card to make it look snazzy."
	icon = 'icons/obj/toy.dmi'
	icon_state = "id_decal"
	var/decal_name = "identification card"
	var/decal_desc = "A card used to provide ID and determine access across the station."
	var/decal_icon_state = "id"
	var/decal_inhand_icon_state = "card-id"
	var/override_name = 0

/obj/item/id_decal/gold
	name = "gold ID card decal"
	icon_state = "id_decal_gold"
	desc = "Make your ID look like the Captain's or a self-centered HOP's. Applies to any ID."
	decal_desc = "A golden card which shows power and might."
	decal_icon_state = "gold"
	decal_inhand_icon_state = "gold_id"

/obj/item/id_decal/silver
	name = "silver ID card decal"
	icon_state = "id_decal_silver"
	desc = "Make your ID look like HOP's because they wouldn't change it officially. Applies to any ID."
	decal_desc = "A silver card which shows honour and dedication."
	decal_icon_state = "silver"
	decal_inhand_icon_state = "silver_id"

/obj/item/id_decal/prisoner
	name = "prisoner ID card decal"
	icon_state = "id_decal_prisoner"
	desc = "All the cool kids have an ID that's this color. Applies to any ID."
	decal_desc = "You are a number, you are not a free man."
	decal_icon_state = "prisoner"

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
	return list("data", "id", "gold", "silver", "security", "detective", "warden", "internalaffairsagent", "medical", "coroner", "chemist", "virologist", "paramedic", "psychiatrist", "geneticist", "research", "roboticist", "quartermaster", "cargo", "shaftminer", "engineering", "atmostech", "captain", "HoP", "HoS", "CMO", "RD", "CE", "assistant", "clown", "mime", "botanist", "librarian", "chaplain", "bartender", "chef", "janitor", "rainbow", "prisoner", "explorer", "nct")

/proc/get_centcom_card_skins()
	return list("centcom", "blueshield", "magistrate", "ntrep", "ERT_leader", "ERT_empty", "ERT_security", "ERT_engineering", "ERT_medical", "ERT_janitorial", "ERT_paranormal", "deathsquad", "commander", "syndie", "TDred", "TDgreen")

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
		if("nct")
			return "Nanotrasen Career Trainer"
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

/proc/GetNameAndAssignmentFromId(obj/item/card/id/I)
	// Format currently matches that of newscaster feeds: Registered Name (Assigned Rank)
	return I.assignment ? "[I.registered_name] ([I.assignment])" : I.registered_name
