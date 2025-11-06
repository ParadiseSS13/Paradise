/obj/structure/closet/secure_closet/captains
	name = "captain's locker"
	req_access = list(ACCESS_CAPTAIN)
	icon_state = "cap"

/obj/structure/closet/secure_closet/captains/populate_contents()
	if(prob(50))
		new /obj/item/storage/backpack/captain(src)
	else
		new /obj/item/storage/backpack/satchel_cap(src)
	new /obj/item/book/manual/wiki/faxes(src)
	new /obj/item/storage/backpack/duffel/captain(src)
	new /obj/item/storage/bag/garment/captain(src)
	new /obj/item/cartridge/captain(src)
	new /obj/item/radio/headset/heads/captain/alt(src)
	new /obj/item/storage/belt/sheath/saber(src)
	new /obj/item/gun/energy/gun(src)
	new /obj/item/flash(src)
	new /obj/item/door_remote/captain(src)
	new /obj/item/reagent_containers/drinks/mug/cap(src)
	new /obj/item/tank/internals/emergency_oxygen/double(src)
	new /obj/item/autosurgeon/organ/one_use/skill_hud(src)

/obj/structure/closet/secure_closet/hop
	name = "head of personnel's locker"
	req_access = list(ACCESS_HOP)
	icon_state = "hop"

/obj/structure/closet/secure_closet/hop/populate_contents()
	new /obj/item/cartridge/hop(src)
	new /obj/item/radio/headset/heads/hop(src)
	new /obj/item/storage/box/ids(src)
	new /obj/item/storage/box/pdas(src)
	new /obj/item/gun/energy/gun/mini(src)
	new /obj/item/flash(src)
	new /obj/item/door_remote/civillian(src)
	new /obj/item/reagent_containers/drinks/mug/hop(src)
	new /obj/item/clothing/accessory/medal/service(src)
	new /obj/item/storage/bag/garment/head_of_personnel(src)
	new /obj/item/autosurgeon/organ/one_use/skill_hud(src)
	new /obj/item/storage/box/fingerprints(src) // used for fingerprinting new arrivals

/obj/structure/closet/secure_closet/hos
	name = "head of security's locker"
	req_access = list(ACCESS_HOS)
	icon_state = "hos"

/obj/structure/closet/secure_closet/hos/populate_contents()
	if(prob(50))
		new /obj/item/storage/backpack/security(src)
	else
		new /obj/item/storage/backpack/satchel_sec(src)

	new /obj/item/storage/bag/garment/head_of_security(src)
	new /obj/item/cartridge/hos(src)
	new /obj/item/radio/headset/heads/hos/alt(src)
	new /obj/item/storage/lockbox/mindshield(src)
	new /obj/item/storage/box/flashbangs(src)
	new /obj/item/holosign_creator/security(src)
	new /obj/item/shield/riot/tele(src)
	new /obj/item/flashlight/seclite(src)
	new /obj/item/storage/belt/security/full(src)
	new /obj/item/gun/energy/gun/hos(src)
	new /obj/item/door_remote/head_of_security(src)
	new /obj/item/reagent_containers/drinks/mug/hos(src)
	new /obj/item/clothing/accessory/medal/security(src)
	new /obj/item/reagent_containers/drinks/flask/barflask(src)
	new /obj/item/clothing/mask/gas/sechailer(src)
	new /obj/item/autosurgeon/organ/one_use/sec_hud(src)

/obj/structure/closet/secure_closet/warden
	name = "warden's locker"
	req_access = list(ACCESS_ARMORY)
	icon_state = "warden"
	opened_door_sprite = "sec"

/obj/structure/closet/secure_closet/warden/populate_contents()
	if(prob(50))
		new /obj/item/storage/backpack/security(src)
	else
		new /obj/item/storage/backpack/satchel_sec(src)
	new /obj/item/storage/bag/garment/warden(src)
	new /obj/item/radio/headset/headset_sec/alt(src)
	new /obj/item/holosign_creator/security(src)
	new /obj/item/storage/box/zipties(src)
	new /obj/item/storage/box/flashbangs(src)
	new /obj/item/storage/belt/security/full(src)
	new /obj/item/flashlight/seclite(src)
	new /obj/item/storage/box/holobadge(src)
	new /obj/item/clothing/gloves/color/black/krav_maga/sec(src)
	new /obj/item/clothing/mask/gas/sechailer(src)

/obj/structure/closet/secure_closet/security
	name = "security officer's locker"
	req_access = list(ACCESS_SECURITY)
	icon_state = "sec"

/obj/structure/closet/secure_closet/security/populate_contents()
	if(prob(50))
		new /obj/item/storage/backpack/security(src)
	else
		new /obj/item/storage/backpack/satchel_sec(src)
	new /obj/item/clothing/suit/armor/vest/security(src)
	new /obj/item/radio/headset/headset_sec/alt(src)
	new /obj/item/clothing/head/soft/sec(src)
	new /obj/item/storage/belt/security/full(src)
	new /obj/item/holosign_creator/security(src)
	new /obj/item/clothing/mask/gas/sechailer(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses(src)
	new /obj/item/flashlight/seclite(src)
	new /obj/item/clothing/head/helmet(src)
	new /obj/item/clothing/suit/armor/secjacket(src)

/obj/structure/closet/secure_closet/evidence
	name = "evidence locker"
	req_access = list(ACCESS_SEC_DOORS)
	anchored = TRUE

/obj/structure/closet/secure_closet/evidence/detective
	req_access = list(ACCESS_FORENSICS_LOCKERS)

/obj/structure/closet/secure_closet/blueshield
	name = "blueshield's locker"
	req_access = list(ACCESS_BLUESHIELD)
	icon_state = "hop"
	closed_door_sprite = "bs"

/obj/structure/closet/secure_closet/blueshield/populate_contents()
	new /obj/item/storage/backpack/blueshield(src)
	new /obj/item/storage/backpack/satchel_blueshield(src)
	new /obj/item/storage/briefcase(src)
	new /obj/item/storage/backpack/duffel/blueshield(src)
	new /obj/item/radio/headset/heads/blueshield/alt(src)
	new /obj/item/cartridge/hos(src)
	new	/obj/item/storage/firstaid/adv(src)
	new /obj/item/pinpointer/crew(src)
	new /obj/item/flashlight/seclite(src)
	new /obj/item/storage/belt/security/full(src)
	new /obj/item/clothing/accessory/holster(src)
	new /obj/item/storage/bag/garment/blueshield(src)
	new /obj/item/sensor_device(src)

/obj/structure/closet/secure_closet/ntrep
	name = "\improper Nanotrasen Representative's locker"
	req_access = list(ACCESS_NTREP)
	icon_state = "hop"
	closed_door_sprite = "ntr"

/obj/structure/closet/secure_closet/ntrep/populate_contents()
	new /obj/item/book/manual/wiki/faxes(src)
	new /obj/item/storage/briefcase(src)
	new /obj/item/radio/headset/heads/ntrep (src)
	new /obj/item/cartridge/supervisor(src)
	new /obj/item/paicard(src)
	new /obj/item/flash(src)
	new /obj/item/storage/box/tapes(src)
	new /obj/item/taperecorder(src)
	new /obj/item/storage/bag/garment/nanotrasen_representative(src)
	new /obj/item/clipboard/station_report(src)

/obj/structure/closet/secure_closet/security/cargo

/obj/structure/closet/secure_closet/security/cargo/populate_contents()
	new /obj/item/clothing/accessory/armband/cargo(src)
	new /obj/item/encryptionkey/headset_cargo(src)

/obj/structure/closet/secure_closet/security/engine

/obj/structure/closet/secure_closet/security/engine/populate_contents()
	new /obj/item/clothing/accessory/armband/engine(src)
	new /obj/item/encryptionkey/headset_eng(src)

/obj/structure/closet/secure_closet/security/science

/obj/structure/closet/secure_closet/security/science/populate_contents()
	new /obj/item/clothing/accessory/armband/science(src)
	new /obj/item/encryptionkey/headset_sci(src)

/obj/structure/closet/secure_closet/security/med

/obj/structure/closet/secure_closet/security/med/populate_contents()
	new /obj/item/clothing/accessory/armband/medgreen(src)
	new /obj/item/encryptionkey/headset_med(src)

/obj/structure/closet/secure_closet/detective
	name = "detective's cabinet"
	req_access = list(ACCESS_FORENSICS_LOCKERS)
	icon_state = "cabinet"
	door_anim_time = 0
	resistance_flags = FLAMMABLE
	max_integrity = 70
	open_sound = 'sound/machines/wooden_closet_open.ogg'
	close_sound = 'sound/machines/wooden_closet_close.ogg'

/obj/structure/closet/secure_closet/detective/populate_contents()
	new /obj/effect/spawner/detgun(src)
	new /obj/item/ammo_box/magazine/detective/speedcharger(src)
	new /obj/item/ammo_box/magazine/detective/speedcharger(src)
	new /obj/item/clipboard(src)
	new /obj/item/clothing/gloves/color/latex(src)
	new /obj/item/flash(src)
	new /obj/item/flashlight/seclite(src)
	new /obj/item/holosign_creator/detective(src)
	new /obj/item/radio/headset/headset_sec/alt(src)
	new /obj/item/reagent_containers/drinks/flask/detflask(src)
	new /obj/item/restraints/handcuffs(src)
	new /obj/item/storage/bag/garment/detective(src)
	new /obj/item/storage/belt/security(src)
	new /obj/item/storage/box/evidence(src)
	new /obj/item/taperecorder(src)
	new /obj/item/storage/box/tapes(src)
	new /obj/item/taperecorder(src)
	new /obj/item/storage/briefcase/crimekit(src)

/obj/structure/closet/secure_closet/injection
	name = "lethal injections locker"
	req_access = list(ACCESS_SECURITY)

/obj/structure/closet/secure_closet/injection/populate_contents()
	new /obj/item/reagent_containers/syringe/lethal(src)
	new /obj/item/reagent_containers/syringe/lethal(src)

/obj/structure/closet/secure_closet/brig
	name = "brig locker"
	req_access = list(ACCESS_BRIG)
	anchored = TRUE
	var/id = null

/obj/structure/closet/secure_closet/brig/populate_contents()
	new /obj/item/clothing/under/color/orange/prison(src)
	new /obj/item/clothing/under/color/jumpskirt/orange/prison(src)
	new /obj/item/clothing/shoes/orange(src)
	new /obj/item/card/id/prisoner/random(src)
	new /obj/item/radio/headset(src)

/obj/structure/closet/secure_closet/brig/temp
	desc = "A locker connected to the cell's timer system, used to store prisoner belongings. It unlocks automatically once the sentence has been served."

/obj/structure/closet/secure_closet/brig/temp/populate_contents()
	return

/obj/structure/closet/secure_closet/brig/temp/cell_1
	name = "Cell 1 Locker"
	id = "Cell 1"

/obj/structure/closet/secure_closet/brig/temp/cell_2
	name = "Cell 2 Locker"
	id = "Cell 2"

/obj/structure/closet/secure_closet/brig/temp/cell_3
	name = "Cell 3 Locker"
	id = "Cell 3"

/obj/structure/closet/secure_closet/brig/temp/cell_4
	name = "Cell 4 Locker"
	id = "Cell 4"

/obj/structure/closet/secure_closet/brig/temp/cell_5
	name = "Cell 5 Locker"
	id = "Cell 5"

/obj/structure/closet/secure_closet/brig/temp/cell_6
	name = "Cell 6 Locker"
	id = "Cell 6"

/obj/structure/closet/secure_closet/brig/temp/cell_7
	name = "Cell 7 Locker"
	id = "Cell 7"

/obj/structure/closet/secure_closet/brig/temp/cell_8
	name = "Cell 8 Locker"
	id = "Cell 8"

/obj/structure/closet/secure_closet/brig/gulag
	name = "labor camp locker"
	desc = "A special locker designed to store prisoner belongings, allows access when prisoners meet their point quota."
	locked = FALSE
	var/registered_ID_UID

/obj/structure/closet/secure_closet/brig/gulag/allowed(mob/M)
	. = ..()
	if(.) //we were gonna let them do it anyway
		return TRUE

	for(var/obj/item/card/id/prisoner/prisoner_id in M) //they might have a stash of them
		if(!prisoner_id.goal)
			continue //no goal? no interaction

		if(locked && registered_ID_UID && !(prisoner_id.UID() == registered_ID_UID))
			continue //you don't own this!

		if(!locked)
			registered_ID_UID = prisoner_id.UID()
			return TRUE //they are trying to lock it, so let them

		if(prisoner_id.mining_points >= prisoner_id.goal)
			registered_ID_UID = null
			return TRUE //completed goal? do the interaction

	return FALSE //if we didn't match above, no interaction for you

/obj/structure/closet/secure_closet/brig/gulag/examine(mob/user)
	. = ..()
	if(registered_ID_UID)
		var/obj/item/card/id/prisoner/prisoner_id = locateUID(registered_ID_UID)
		. += "\nOwned by [prisoner_id.registered_name]."

/obj/structure/closet/secure_closet/magistrate
	name = "\improper Magistrate's locker"
	req_access = list(ACCESS_MAGISTRATE)
	icon_state = "magi"
	opened_door_sprite = "chaplain"

/obj/structure/closet/secure_closet/magistrate/populate_contents()
	new /obj/item/book/manual/wiki/faxes(src)
	new /obj/item/storage/secure/briefcase(src)
	new /obj/item/flash(src)
	new /obj/item/radio/headset/heads/magistrate(src)
	new /obj/item/cartridge/supervisor(src)
	new /obj/item/gavelblock(src)
	new /obj/item/gavelhammer(src)
	new /obj/item/clothing/accessory/medal/legal(src)
	new /obj/item/clothing/accessory/legal_badge(src)
	new /obj/item/storage/bag/garment/magistrate(src)

/obj/structure/closet/secure_closet/iaa
	name = "internal affairs locker"
	req_access = list(ACCESS_INTERNAL_AFFAIRS)
	icon_state = "magi"
	opened_door_sprite = "chaplain"
	closed_door_sprite = "iaa"

/obj/structure/closet/secure_closet/iaa/populate_contents()
	new /obj/item/book/manual/wiki/faxes(src)
	new /obj/item/storage/box/tapes(src)
	new /obj/item/storage/secure/briefcase(src)
	new /obj/item/storage/secure/briefcase(src)
	new /obj/item/storage/briefcase(src)
	new /obj/item/storage/briefcase(src)
	new /obj/item/radio/headset/headset_iaa(src)
	new /obj/item/radio/headset/headset_iaa(src)
	new /obj/item/clothing/accessory/legal_badge/iaa(src)
