/obj/structure/closet/syndicate
	name = "armoury closet"
	desc = "Why is this here?"
	icon_state = "syndicate"
	icon_closed = "syndicate"
	icon_opened = "syndicateopen"


/obj/structure/closet/syndicate/personal
	desc = "It's a storage unit for operative gear."

/obj/structure/closet/syndicate/personal/populate_contents()
	new /obj/item/clothing/under/syndicate(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/storage/belt/military(src)
	new /obj/item/crowbar/red(src)
	new /obj/item/clothing/glasses/night(src)

/obj/structure/closet/syndicate/suits
	desc = "It's a storage unit for operative space gear."

/obj/structure/closet/syndicate/suits/populate_contents()
	new /obj/item/clothing/mask/gas/syndicate(src)
	new /obj/item/clothing/suit/space/hardsuit/syndi(src)
	new /obj/item/tank/jetpack/oxygen/harness(src)

/obj/structure/closet/syndicate/nuclear
	desc = "It's a storage unit for a Syndicate boarding party."

/obj/structure/closet/syndicate/nuclear/populate_contents()
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/storage/box/teargas(src)
	new /obj/item/storage/box/flashbangs(src)
	new /obj/item/storage/backpack/duffel/syndie/med(src)
	new /obj/item/gun/projectile/automatic/shotgun/bulldog(src)
	new /obj/item/gun/projectile/automatic/shotgun/bulldog(src)
	new /obj/item/gun/projectile/automatic/shotgun/bulldog(src)
	new /obj/item/gun/projectile/automatic/shotgun/bulldog(src)
	new /obj/item/gun/projectile/automatic/shotgun/bulldog(src)
	new /obj/item/pda/syndicate(src)

/obj/structure/closet/syndicate/sst
	desc = "It's a storage unit for an elite syndicate strike team's gear."

/obj/structure/closet/syndicate/sst/populate_contents()
	new /obj/item/ammo_box/magazine/mm556x45(src)
	new /obj/item/gun/projectile/automatic/l6_saw(src)
	new /obj/item/tank/jetpack/oxygen/harness(src)
	new /obj/item/storage/belt/military/sst(src)
	new /obj/item/clothing/glasses/thermal(src)
	new /obj/item/clothing/shoes/magboots/syndie/advance(src)
	new /obj/item/clothing/mask/gas/syndicate(src)
	new /obj/item/clothing/suit/space/hardsuit/syndi/elite/sst(src)

/obj/structure/closet/syndicate/resources
	desc = "An old, dusty locker."

/obj/structure/closet/syndicate/resources/populate_contents()
	var/common_min = 30 //Minimum amount of minerals in the stack for common minerals
	var/common_max = 50 //Maximum amount of HONK in the stack for HONK common minerals
	var/rare_min = 5  //Minimum HONK of HONK in the stack HONK HONK rare minerals
	var/rare_max = 20 //Maximum HONK HONK HONK in the HONK for HONK rare HONK

	var/pickednum = rand(1, 50)

	//Sad trombone
	if(pickednum == 1)
		var/obj/item/paper/P = new /obj/item/paper(src)
		P.name = "IOU"
		P.info = "Sorry man, we needed the money so we sold your stash. It's ok, we'll double our money for sure this time!"

	//Metal (common ore)
	if(pickednum >= 2)
		new /obj/item/stack/sheet/metal(src, rand(common_min, common_max))

	//Glass (common ore)
	if(pickednum >= 5)
		new /obj/item/stack/sheet/glass(src, rand(common_min, common_max))

	//Plasteel (common ore) Because it has a million more uses then plasma
	if(pickednum >= 10)
		new /obj/item/stack/sheet/plasteel(src, rand(common_min, common_max))

	//Plasma (rare ore)
	if(pickednum >= 15)
		new /obj/item/stack/sheet/mineral/plasma(src, rand(rare_min, rare_max))

	//Silver (rare ore)
	if(pickednum >= 20)
		new /obj/item/stack/sheet/mineral/silver(src, rand(rare_min, rare_max))

	//Gold (rare ore)
	if(pickednum >= 30)
		new /obj/item/stack/sheet/mineral/gold(src, rand(rare_min, rare_max))

	//Uranium (rare ore)
	if(pickednum >= 40)
		new /obj/item/stack/sheet/mineral/uranium(src, rand(rare_min, rare_max))

	//Titanium (rare ore)
	if(pickednum >= 40)
		new /obj/item/stack/sheet/mineral/titanium(src, rand(rare_min, rare_max))

	//Plastitanium (rare ore)
	if(pickednum >= 40)
		new /obj/item/stack/sheet/mineral/plastitanium(src, rand(rare_min, rare_max))

	//Diamond (rare HONK)
	if(pickednum >= 45)
		new /obj/item/stack/sheet/mineral/diamond(src, rand(rare_min, rare_max))

	//Jetpack (You hit the jackpot!)
	if(pickednum == 50)
		new /obj/item/tank/jetpack/carbondioxide(src)

/obj/structure/closet/syndicate/resources/everything
	desc = "It's an emergency storage closet for repairs."

/obj/structure/closet/syndicate/resources/everything/populate_contents()
	var/list/resources = list(
	/obj/item/stack/sheet/metal,
	/obj/item/stack/sheet/glass,
	/obj/item/stack/sheet/mineral/gold,
	/obj/item/stack/sheet/mineral/silver,
	/obj/item/stack/sheet/mineral/plasma,
	/obj/item/stack/sheet/mineral/uranium,
	/obj/item/stack/sheet/mineral/diamond,
	/obj/item/stack/sheet/mineral/bananium,
	/obj/item/stack/sheet/mineral/titanium,
	/obj/item/stack/sheet/mineral/plastitanium,
	/obj/item/stack/sheet/plasteel,
	/obj/item/stack/rods
	)

	for(var/i in 1 to 2)
		for(var/res in resources)
			var/obj/item/stack/R = new res(src)
			R.amount = R.max_amount

//Adding syndicate closets for "Taipan". Sprites by Элл Гууд
/obj/structure/closet/secure_closet/syndicate
	name = "Syndicate Locker"
	desc = "It's an immobile card-locked storage unit. A big 'S' letter on it indicates that it belongs to the syndicate."
	req_access = list(150)
	layer = 2.9 // ensures the loot they drop always appears on top of them.
	max_integrity = 300
	icon_state = "syndicate_secure1"
	icon_closed = "syndicate_secure"
	icon_locked = "syndicate_secure1"
	icon_opened = "syndicate_secure_open"
	icon_broken = "syndicate_secure_broken"
	icon_off = "syndicate_secure_off"

/obj/structure/closet/secure_closet/syndicate/comms_officer
	req_access = list(ACCESS_SYNDICATE_COMMS_OFFICER)
	name = "Syndicate Comms Officer's Locker"

/obj/structure/closet/secure_closet/syndicate/comms_officer/populate_contents()
	new /obj/item/clothing/glasses/night(src)
	new /obj/item/pda/syndicate/no_cartridge/comms(src)
	new /obj/item/ammo_box/magazine/m50(src)
	new /obj/item/ammo_box/magazine/m50(src)
	new /obj/item/ammo_box/magazine/m50(src)
	new /obj/item/storage/box/flashbangs(src)
	new /obj/item/clothing/accessory/holster(src)
	new /obj/item/clothing/accessory/stripedredscarf(src)
	new /obj/item/storage/box/syndie_kit/chameleon(src)
	new /obj/item/storage/secure/briefcase/syndie(src)
	new /obj/item/megaphone(src)
	new /obj/item/card/emag(src)
	new /obj/item/dnainjector/xraymut(src)
	new /obj/item/storage/belt/military(src)
	new /obj/item/crowbar/red(src)
	new /obj/item/encryptionkey/syndicate/taipan/tcomms_agent(src)
	new /obj/item/storage/backpack/syndicate/command(src)
	new /obj/item/storage/backpack/fluff/syndiesatchel(src)
	new /obj/item/storage/backpack/duffel/syndie(src)
	new /obj/item/storage/box/syndicate_permits(src)
	new /obj/item/door_remote/taipan(src)
	new /obj/item/clothing/neck/cloak/syndiecap/comms(src)

/obj/structure/closet/secure_closet/syndicate/research_director
	name = "Syndicate Research Director's Locker"
	req_access = list(ACCESS_SYNDICATE_RESEARCH_DIRECTOR)
	icon_state = "syndicate_rd_secure1"
	icon_closed = "syndicate_rd_secure"
	icon_locked = "syndicate_rd_secure1"
	icon_opened = "syndicate_rd_secure_open"
	icon_broken = "syndicate_rd_secure_broken"
	icon_off = "syndicate_rd_secure_off"

/obj/structure/closet/secure_closet/syndicate/research_director/populate_contents()
	new /obj/item/clothing/glasses/night(src)
	new /obj/item/pda/syndicate/no_cartridge/rd(src)
	new /obj/item/dart_cartridge(src)
	new /obj/item/dart_cartridge(src)
	new /obj/item/dart_cartridge(src)
	new /obj/item/clothing/accessory/rbscarf(src)
	new /obj/item/storage/box/syndie_kit/chameleon(src)
	new /obj/item/storage/secure/briefcase/syndie(src)
	new /obj/item/megaphone(src)
	new /obj/item/card/emag(src)
	new /obj/item/clothing/suit/cardborg(src)
	new /obj/item/clothing/head/cardborg(src)
	new /obj/item/clothing/head/welding(src)
	new /obj/item/storage/belt/chameleon(src)
	new /obj/item/organ/internal/cyberimp/arm/gun/laser(src)
	new /obj/item/encryptionkey/syndicate/taipan(src)
	new /obj/item/batterer(src)
	new /obj/item/storage/backpack/syndicate/command(src)
	new /obj/item/storage/backpack/fluff/syndiesatchel(src)
	new /obj/item/storage/backpack/duffel/syndie(src)
	new /obj/item/storage/box/syndicate_permits(src)

/obj/structure/closet/secure_closet/syndicate/cargo
	name = "Syndicate Cargo Technician's Locker"
	req_access = list(ACCESS_SYNDICATE_CARGO)
	icon_state = "syndicate_cargo_secure1"
	icon_closed = "syndicate_cargo_secure"
	icon_locked = "syndicate_cargo_secure1"
	icon_opened = "syndicate_cargo_secure_open"
	icon_broken = "syndicate_cargo_secure_broken"
	icon_off = "syndicate_cargo_secure_off"

/obj/structure/closet/secure_closet/syndicate/cargo/populate_contents()
	new /obj/item/clothing/glasses/meson(src)
	new /obj/item/clothing/head/soft(src)
	new /obj/item/clothing/head/soft/black(src)
	new /obj/item/stamp/denied(src)
	new /obj/item/stamp/granted(src)
	new /obj/item/clothing/gloves/fingerless(src)
	new /obj/item/clothing/under/rank/cargotech(src)
	new /obj/item/clothing/under/rank/cargotech/skirt(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/encryptionkey/syndicate/taipan(src)
	new /obj/item/storage/backpack/syndicate/cargo(src)
	new /obj/item/storage/backpack/duffel/syndie(src)

/obj/structure/closet/secure_closet/syndicate/medbay
	name = "Syndicate Medical Doctor's Locker"
	req_access = list(ACCESS_SYNDICATE_MEDICAL)
	icon_state = "syndicate_med_secure1"
	icon_closed = "syndicate_med_secure"
	icon_locked = "syndicate_med_secure1"
	icon_opened = "syndicate_med_secure_open"
	icon_broken = "syndicate_med_secure_broken"
	icon_off = "syndicate_med_secure_off"

/obj/structure/closet/secure_closet/syndicate/medbay/populate_contents()
	new /obj/item/storage/backpack/duffel/syndie/surgery(src)
	new /obj/item/storage/backpack/duffel/syndie/surgery(src)
	new /obj/item/clothing/under/rank/medical(src)
	new /obj/item/clothing/suit/storage/labcoat(src)
	new /obj/item/clothing/shoes/white(src)
	new /obj/item/encryptionkey/syndicate/taipan(src)
	new /obj/item/clothing/gloves/color/latex/nitrile(src)
	new /obj/item/defibrillator/loaded(src)
	new /obj/item/handheld_defibrillator(src)
	new /obj/item/storage/belt/medical(src)
	new /obj/item/storage/belt/medical(src)
	new /obj/item/clothing/glasses/hud/health(src)
	new /obj/item/clothing/glasses/hud/health(src)
	new /obj/item/clothing/head/headmirror(src)
	new /obj/item/clothing/shoes/sandal/white(src)
	new /obj/item/storage/backpack/syndicate/med(src)
	new /obj/item/storage/backpack/duffel/syndie(src)

/obj/structure/closet/secure_closet/syndicate/hydro
	name = "Syndicate Botanist's Locker"
	req_access = list(ACCESS_SYNDICATE_BOTANY)
	icon_state = "syndicate_hydro_secure1"
	icon_closed = "syndicate_hydro_secure"
	icon_locked = "syndicate_hydro_secure1"
	icon_opened = "syndicate_hydro_secure_open"
	icon_broken = "syndicate_hydro_secure_broken"
	icon_off = "syndicate_hydro_secure_off"

/obj/structure/closet/secure_closet/syndicate/hydro/populate_contents()
	new /obj/item/clothing/suit/apron(src)
	new /obj/item/clothing/suit/apron/overalls(src)
	new /obj/item/storage/bag/plants/portaseeder(src)
	new /obj/item/clothing/under/rank/hydroponics(src)
	new /obj/item/clothing/glasses/hud/hydroponic(src)
	new /obj/item/plant_analyzer(src)
	new /obj/item/encryptionkey/syndicate/taipan(src)
	new /obj/item/clothing/mask/bandana/botany(src)
	new /obj/item/cultivator(src)
	new /obj/item/hatchet(src)
	new /obj/item/storage/box/disks_plantgene(src)
	new /obj/item/storage/backpack/syndicate(src)
	new /obj/item/storage/backpack/duffel/syndie(src)

/obj/structure/closet/secure_closet/syndicate/chef
	name = "Syndicate Chef's Locker"
	req_access = list(ACCESS_SYNDICATE_KITCHEN)
	icon_state = "syndicate_fridge_secure1"
	icon_closed = "syndicate_fridge_secure"
	icon_locked = "syndicate_fridge_secure1"
	icon_opened = "syndicate_fridge_secure_open"
	icon_broken = "syndicate_fridge_secure_broken"
	icon_off = "syndicate_fridge_secure_off"

/obj/structure/closet/secure_closet/syndicate/chef/populate_contents()
	new /obj/item/clothing/under/waiter(src)
	new /obj/item/clothing/under/waiter(src)
	new /obj/item/encryptionkey/syndicate/taipan(src)
	new /obj/item/encryptionkey/syndicate/taipan(src)
	new /obj/item/clothing/accessory/waistcoat(src)
	new /obj/item/clothing/accessory/waistcoat(src)
	new /obj/item/clothing/suit/chef/classic(src)
	new /obj/item/clothing/suit/chef/classic(src)
	new /obj/item/clothing/suit/chef/classic(src)
	new /obj/item/clothing/head/soft/mime(src)
	new /obj/item/clothing/head/soft/mime(src)
	new /obj/item/storage/box/mousetraps(src)
	new /obj/item/storage/box/mousetraps(src)
	new /obj/item/clothing/under/rank/chef(src)
	new /obj/item/clothing/head/chefhat(src)
	new /obj/item/reagent_containers/glass/rag(src)
	new /obj/item/storage/backpack/syndicate(src)
	new /obj/item/storage/backpack/duffel/syndie(src)
