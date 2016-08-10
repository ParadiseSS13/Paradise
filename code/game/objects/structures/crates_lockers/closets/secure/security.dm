/obj/structure/closet/secure_closet/captains
	name = "captain's locker"
	req_access = list(access_captain)
	icon_state = "capsecure1"
	icon_closed = "capsecure"
	icon_locked = "capsecure1"
	icon_opened = "capsecureopen"
	icon_broken = "capsecurebroken"
	icon_off = "capsecureoff"

	New()
		..()
		if(prob(50))
			new /obj/item/weapon/storage/backpack/captain(src)
		else
			new /obj/item/weapon/storage/backpack/satchel_cap(src)
		new /obj/item/weapon/book/manual/faxes(src)
		new /obj/item/clothing/head/crown/fancy(src)
		new /obj/item/weapon/storage/backpack/duffel/captain(src)
		new /obj/item/clothing/suit/captunic(src)
		new /obj/item/clothing/suit/captunic/capjacket(src)
		new /obj/item/clothing/under/captainparade(src)
		new /obj/item/clothing/head/caphat/parade(src)
		new /obj/item/clothing/under/rank/captain(src)
		new /obj/item/clothing/under/dress/dress_cap(src)
		new /obj/item/clothing/suit/armor/vest/capcarapace/alt(src)
		new /obj/item/weapon/cartridge/captain(src)
		new /obj/item/clothing/shoes/brown(src)
		new /obj/item/clothing/shoes/laceup(src)
		new /obj/item/device/radio/headset/heads/captain/alt(src)
		new /obj/item/clothing/gloves/color/captain(src)
		new /obj/item/weapon/storage/belt/rapier(src)
		new /obj/item/weapon/gun/energy/gun(src)
		new /obj/item/weapon/door_remote/captain(src)



/obj/structure/closet/secure_closet/hop
	name = "head of personnel's locker"
	req_access = list(access_hop)
	icon_state = "hopsecure1"
	icon_closed = "hopsecure"
	icon_locked = "hopsecure1"
	icon_opened = "hopsecureopen"
	icon_broken = "hopsecurebroken"
	icon_off = "hopsecureoff"

	New()
		..()
		new /obj/item/weapon/book/manual/faxes(src)
		new /obj/item/clothing/glasses/sunglasses(src)
		new /obj/item/clothing/head/hopcap(src)
		new /obj/item/weapon/cartridge/hop(src)
		new /obj/item/device/radio/headset/heads/hop(src)
		new /obj/item/weapon/storage/box/ids(src)
		new /obj/item/weapon/storage/box/PDAs(src)
		new /obj/item/clothing/suit/armor/vest(src)
		new /obj/item/weapon/gun/energy/gun(src)
		new /obj/item/device/flash(src)
		new /obj/item/clothing/accessory/petcollar(src)
		new /obj/item/weapon/door_remote/civillian(src)

/obj/structure/closet/secure_closet/hop2
	name = "head of personnel's attire"
	req_access = list(access_hop)
	icon_state = "hopsecure1"
	icon_closed = "hopsecure"
	icon_locked = "hopsecure1"
	icon_opened = "hopsecureopen"
	icon_broken = "hopsecurebroken"
	icon_off = "hopsecureoff"

	New()
		..()
		new /obj/item/clothing/under/rank/head_of_personnel(src)
		new /obj/item/clothing/under/dress/dress_hop(src)
		new /obj/item/clothing/under/dress/dress_hr(src)
		new /obj/item/clothing/under/lawyer/female(src)
		new /obj/item/clothing/under/lawyer/black(src)
		new /obj/item/clothing/under/lawyer/red(src)
		new /obj/item/clothing/under/lawyer/oldman(src)
		new /obj/item/clothing/shoes/brown(src)
		new /obj/item/clothing/shoes/black(src)
		new /obj/item/clothing/shoes/leather(src)
		new /obj/item/clothing/shoes/white(src)
		new /obj/item/clothing/under/rank/head_of_personnel_whimsy(src)



/obj/structure/closet/secure_closet/hos
	name = "head of security's locker"
	req_access = list(access_hos)
	icon_state = "hossecure1"
	icon_closed = "hossecure"
	icon_locked = "hossecure1"
	icon_opened = "hossecureopen"
	icon_broken = "hossecurebroken"
	icon_off = "hossecureoff"

	New()
		..()
		if(prob(50))
			new /obj/item/weapon/storage/backpack/security(src)
		else
			new /obj/item/weapon/storage/backpack/satchel_sec(src)
		new /obj/item/weapon/book/manual/faxes(src)
		new /obj/item/weapon/cartridge/hos(src)
		new /obj/item/device/radio/headset/heads/hos/alt(src)
		new /obj/item/clothing/under/rank/head_of_security(src)
		new /obj/item/clothing/under/rank/head_of_security/formal(src)
		new /obj/item/clothing/under/rank/head_of_security/corp(src)
		new /obj/item/clothing/under/rank/head_of_security/skirt(src)
		new /obj/item/clothing/suit/armor/hos(src)
		new /obj/item/clothing/suit/armor/hos/alt(src)
		new /obj/item/clothing/head/HoS(src)
		new /obj/item/clothing/head/HoS/beret(src)
		new /obj/item/clothing/glasses/hud/security/sunglasses(src)
		new /obj/item/weapon/storage/lockbox/loyalty(src)
		new /obj/item/weapon/storage/box/flashbangs(src)
		new /obj/item/clothing/mask/gas/sechailer/hos(src)
		new /obj/item/weapon/shield/riot/tele(src)
		new /obj/item/weapon/melee/baton/loaded(src)
		new /obj/item/weapon/storage/belt/security/sec(src)
		new /obj/item/taperoll/police(src)
		new /obj/item/weapon/gun/energy/gun/hos(src)
		new /obj/item/weapon/door_remote/head_of_security(src)



/obj/structure/closet/secure_closet/warden
	name = "warden's locker"
	req_access = list(access_armory)
	icon_state = "wardensecure1"
	icon_closed = "wardensecure"
	icon_locked = "wardensecure1"
	icon_opened = "wardensecureopen"
	icon_broken = "wardensecurebroken"
	icon_off = "wardensecureoff"


	New()
		..()
		if(prob(50))
			new /obj/item/weapon/storage/backpack/security(src)
		else
			new /obj/item/weapon/storage/backpack/satchel_sec(src)
		new /obj/item/device/radio/headset/headset_sec/alt(src)
		new /obj/item/clothing/suit/armor/vest/warden(src)
		new /obj/item/clothing/head/warden(src)
		new /obj/item/clothing/suit/armor/vest/warden/alt(src)
		new /obj/item/clothing/head/beret/sec/warden(src)
		new /obj/item/clothing/under/rank/warden(src)
		new /obj/item/clothing/under/rank/warden/formal(src)
		new /obj/item/clothing/under/rank/warden/corp(src)
		new /obj/item/clothing/under/rank/warden/skirt(src)
		new /obj/item/clothing/glasses/hud/security/sunglasses(src)
		new /obj/item/clothing/mask/gas/sechailer/warden(src)
		new /obj/item/taperoll/police(src)
		new /obj/item/weapon/storage/box/zipties(src)
		new /obj/item/weapon/storage/box/flashbangs(src)
		new /obj/item/weapon/reagent_containers/spray/pepper(src)
		new /obj/item/weapon/melee/baton/loaded(src)
		new /obj/item/weapon/gun/energy/gun/advtaser(src)
		new /obj/item/weapon/storage/belt/security/sec(src)
		new /obj/item/weapon/storage/box/holobadge(src)
		new /obj/item/clothing/gloves/color/black/krav_maga/sec(src)



/obj/structure/closet/secure_closet/security
	name = "security officer's locker"
	req_access = list(access_security)
	icon_state = "sec1"
	icon_closed = "sec"
	icon_locked = "sec1"
	icon_opened = "secopen"
	icon_broken = "secbroken"
	icon_off = "secoff"

	New()
		..()
		if(prob(50))
			new /obj/item/weapon/storage/backpack/security(src)
		else
			new /obj/item/weapon/storage/backpack/satchel_sec(src)
		new /obj/item/clothing/suit/armor/vest/security(src)
		new /obj/item/device/radio/headset/headset_sec/alt(src)
		new /obj/item/clothing/head/soft/sec(src)
		new /obj/item/weapon/reagent_containers/spray/pepper(src)
		new /obj/item/device/flash(src)
		new /obj/item/weapon/grenade/flashbang(src)
		new /obj/item/weapon/storage/belt/security/sec(src)
		new /obj/item/clothing/mask/gas/sechailer(src)
		new /obj/item/clothing/glasses/hud/security/sunglasses(src)
		new /obj/item/clothing/head/helmet(src)
		new /obj/item/weapon/melee/baton/loaded(src)
		new /obj/item/taperoll/police(src)

/obj/structure/closet/secure_closet/brigdoc
	name = "brig physician's locker"
	req_access = list(access_security)
	icon_state = "securemed1"
	icon_closed = "securemed"
	icon_locked = "securemed1"
	icon_opened = "securemedopen"
	icon_broken = "securemedbroken"
	icon_off = "securemedoff"

	New()
		..()
		if(prob(50))
			new /obj/item/weapon/storage/backpack/medic(src)
		else
			new /obj/item/weapon/storage/backpack/satchel_med(src)
		new /obj/item/weapon/reagent_containers/spray/pepper(src)
		new /obj/item/device/flash(src)
		new /obj/item/weapon/storage/firstaid/regular(src)
		new /obj/item/weapon/storage/firstaid/fire(src)
		new /obj/item/weapon/storage/firstaid/adv(src)
		new /obj/item/weapon/storage/firstaid/o2(src)
		new /obj/item/weapon/storage/firstaid/toxin(src)
		new /obj/item/clothing/suit/storage/brigdoc(src)
		new /obj/item/clothing/under/rank/security/brigphys(src)
		new /obj/item/clothing/shoes/white(src)
		new /obj/item/device/radio/headset/headset_sec/alt(src)
		new /obj/item/clothing/shoes/sandal/white(src)

/obj/structure/closet/secure_closet/blueshield
	name = "blueshield's locker"
	req_access = list(access_blueshield)
	icon_state = "bssecure1"
	icon_closed = "bssecure"
	icon_locked = "bssecure1"
	icon_opened = "bssecureopen"
	icon_broken = "bssecurebroken"
	icon_off = "bssecureoff"

	New()
		..()
		new /obj/item/weapon/storage/briefcase(src)
		new	/obj/item/weapon/storage/firstaid/adv(src)
		new /obj/item/weapon/storage/belt/security/sec(src)
		new /obj/item/weapon/grenade/flashbang(src)
		new /obj/item/device/flash(src)
		new /obj/item/weapon/restraints/handcuffs(src)
		new /obj/item/weapon/melee/baton/loaded(src)
		new /obj/item/clothing/glasses/sunglasses(src)
		new /obj/item/clothing/glasses/hud/health/health_advanced
		new /obj/item/clothing/head/beret/centcom/officer(src)
		new /obj/item/clothing/head/beret/centcom/officer/navy(src)
		new /obj/item/clothing/suit/armor/vest/blueshield(src)
		new /obj/item/clothing/suit/storage/blueshield(src)
		new /obj/item/clothing/shoes/centcom(src)
		new /obj/item/clothing/accessory/holster(src)
		new /obj/item/clothing/accessory/blue(src)
		new /obj/item/clothing/shoes/jackboots/jacksandals(src)

/obj/structure/closet/secure_closet/ntrep
	name = "\improper Nanotrasen Representative's locker"
	req_access = list(access_ntrep)
	icon_state = "ntsecure1"
	icon_closed = "ntsecure"
	icon_locked = "ntsecure1"
	icon_opened = "ntsecureopen"
	icon_broken = "ntsecurebroken"
	icon_off = "ntsecureoff"

	New()
		..()
		new /obj/item/weapon/book/manual/faxes(src)
		new /obj/item/weapon/storage/briefcase(src)
		new /obj/item/device/paicard(src)
		new /obj/item/device/flash(src)
		new /obj/item/clothing/glasses/sunglasses(src)
		new /obj/item/clothing/gloves/color/white(src)
		new /obj/item/clothing/shoes/centcom(src)
		new /obj/item/clothing/under/lawyer/oldman(src)
		new /obj/item/clothing/under/lawyer/black(src)
		new /obj/item/clothing/under/lawyer/female(src)
		new /obj/item/clothing/head/ntrep(src)
		new /obj/item/clothing/shoes/sandal/fancy(src)
		new /obj/item/weapon/storage/box/tapes(src)
		new /obj/item/device/taperecorder(src)


/obj/structure/closet/secure_closet/security/cargo

	New()
		..()
		new /obj/item/clothing/accessory/armband/cargo(src)
		new /obj/item/device/encryptionkey/headset_cargo(src)

/obj/structure/closet/secure_closet/security/engine

	New()
		..()
		new /obj/item/clothing/accessory/armband/engine(src)
		new /obj/item/device/encryptionkey/headset_eng(src)

/obj/structure/closet/secure_closet/security/science

	New()
		..()
		new /obj/item/clothing/accessory/armband/science(src)
		new /obj/item/device/encryptionkey/headset_sci(src)

/obj/structure/closet/secure_closet/security/med

	New()
		..()
		new /obj/item/clothing/accessory/armband/medgreen(src)
		new /obj/item/device/encryptionkey/headset_med(src)


/obj/structure/closet/secure_closet/detective
	name = "detective's cabinet"
	req_access = list(access_forensics_lockers)
	icon_state = "cabinetdetective_locked"
	icon_closed = "cabinetdetective"
	icon_locked = "cabinetdetective_locked"
	icon_opened = "cabinetdetective_open"
	icon_broken = "cabinetdetective_broken"
	icon_off = "cabinetdetective_broken"
	burn_state = FLAMMABLE
	burntime = 20

	New()
		..()
		new /obj/item/clothing/under/det(src)
		new /obj/item/clothing/suit/storage/det_suit(src)
		new /obj/item/clothing/suit/storage/det_suit/forensics/blue(src)
		new /obj/item/clothing/suit/storage/det_suit/forensics/red(src)
		new /obj/item/clothing/gloves/color/black(src)
		new /obj/item/clothing/head/det_hat(src)
		new /obj/item/clothing/shoes/brown(src)
		new /obj/item/weapon/storage/box/evidence(src)
		new /obj/item/weapon/clipboard(src)
		new /obj/item/device/radio/headset/headset_sec/alt(src)
		new /obj/item/device/detective_scanner(src)
		new /obj/item/clothing/suit/armor/vest/det_suit(src)
		new /obj/item/ammo_box/c38(src)
		new /obj/item/ammo_box/c38(src)
		new /obj/item/weapon/gun/projectile/revolver/detective(src)
		new /obj/item/taperoll/police(src)
		new /obj/item/clothing/accessory/holster/armpit(src)
		new /obj/item/clothing/glasses/sunglasses/yeah(src)
		new /obj/item/device/flashlight/seclite(src)
		new /obj/item/clothing/accessory/black(src)

/obj/structure/closet/secure_closet/detective/update_icon()
	if(broken)
		icon_state = icon_broken
	else
		if(!opened)
			if(locked)
				icon_state = icon_locked
			else
				icon_state = icon_closed
		else
			icon_state = icon_opened

/obj/structure/closet/secure_closet/injection
	name = "lethal injections locker"
	req_access = list(access_security)


	New()
		..()
		new /obj/item/weapon/reagent_containers/ld50_syringe/lethal(src)
		new /obj/item/weapon/reagent_containers/ld50_syringe/lethal(src)



/obj/structure/closet/secure_closet/brig
	name = "brig locker"
	req_access = list(access_brig)
	anchored = 1
	var/id = null

	New()
		..()
		new /obj/item/clothing/under/color/orange/prison( src )
		new /obj/item/clothing/shoes/orange( src )



/obj/structure/closet/secure_closet/courtroom
	name = "courtroom locker"
	req_access = list(access_court)

	New()
		..()
		new /obj/item/clothing/shoes/brown(src)
		new /obj/item/weapon/paper/Court (src)
		new /obj/item/weapon/paper/Court (src)
		new /obj/item/weapon/paper/Court (src)
		new /obj/item/weapon/pen (src)
		new /obj/item/clothing/suit/judgerobe (src)
		new /obj/item/clothing/head/powdered_wig (src)
		new /obj/item/weapon/storage/briefcase(src)

/obj/structure/closet/secure_closet/wall
	name = "wall locker"
	req_access = list(access_security)
	icon_state = "wall-locker1"
	density = 1
	icon_closed = "wall-locker"
	icon_locked = "wall-locker1"
	icon_opened = "wall-lockeropen"
	icon_broken = "wall-lockerbroken"
	icon_off = "wall-lockeroff"

	//too small to put a man in
	large = 0

/obj/structure/closet/secure_closet/wall/update_icon()
	if(broken)
		icon_state = icon_broken
	else
		if(!opened)
			if(locked)
				icon_state = icon_locked
			else
				icon_state = icon_closed
		else
			icon_state = icon_opened
