//The purpose of this file is to ensure uniqueness of the loot Space Pirates get
//rather than allowing for doubles.


/obj/effect/spawner/unique/space_pirate_common
	name = "unique spawner"
	color = "#222222"
	icon_state = "x2"

/obj/effect/spawner/unique/space_pirate_common/New()
	var/looty_loot
	for(var/i = 1 to 2)//2 items.
		if(pirateloot_common && pirateloot_common.len)
			looty_loot = pick(pirateloot_common)
			pirateloot_common -= looty_loot
			new looty_loot(get_turf(src))
	qdel(src)


var/global/list/pirateloot_common = list(
						/obj/item/weapon/tank/anesthetic,
						/obj/item/weapon/weldingtool/hugetank,
						/obj/item/weapon/pickaxe/diamond,
						/obj/item/device/spacepod_equipment/weaponry/mining_laser,
						/obj/item/device/paicard,
						/obj/item/device/megaphone,
						/obj/item/pizzabox,
						/obj/item/weapon/spacecash/c1000{amount = 3},
						/obj/item/weapon/spacecash/c200{amount = 4},
						/obj/item/clothing/glasses/sunglasses,
						/obj/item/weapon/tank/emergency_oxygen/engi,
						/obj/item/weapon/grenade/clown_grenade,
						/obj/item/weapon/storage/backpack/satchel_flat,
						/obj/item/weapon/storage/backpack/duffel/syndie/surgery_fake,
						/obj/item/weapon/storage/toolbox/syndicate,
						/obj/item/weapon/soap/syndie,
						/obj/item/weapon/coin/twoheaded,
						/obj/item/weapon/contraband/poster,
						/obj/item/clothing/gloves/color/yellow,
						/obj/item/clothing/gloves/color/black,
						/obj/item/weapon/storage/firstaid/brute,
						/obj/item/weapon/storage/firstaid/fire,
						/obj/item/weapon/storage/toolbox/electrical,
						/obj/item/weapon/storage/toolbox/mechanical,
						/obj/item/clothing/head/that,
						/obj/item/weapon/storage/belt/utility/full/multitool,
						/obj/item/weapon/wrench,
						/obj/item/weapon/screwdriver,
						/obj/item/weapon/wirecutters,
						/obj/item/weapon/crowbar/large,
						/obj/item/weapon/grown/bananapeel,
						/obj/item/weapon/bikehorn,
						)

/obj/effect/spawner/unique/space_pirate_uncommon
	name = "space pirate uncommon loot"
	color = "#FF0000"

/obj/effect/spawner/unique/New()//unlike the previous one, this spawns just one item
	var/looty_loot
	if(pirateloot_uncommon && pirateloot_uncommon.len)
		looty_loot = pick(pirateloot_uncommon)
		pirateloot_uncommon -= looty_loot
		new looty_loot(get_turf(src))
	qdel(src)

var/global/list/pirateloot_uncommon = list(
						/obj/item/weapon/rcd/combat,
						/obj/item/weapon/kitchen/knife/combat,
						/obj/item/weapon/storage/box/syndidonkpockets{name = "combat donk pocket box"},
						/obj/item/weapon/gun/energy/kinetic_accelerator/crossbow,
						/obj/item/weapon/grenade/syndieminibomb,
						/obj/item/clothing/glasses/hud/security/chameleon,
						/obj/item/weapon/storage/box/syndie_kit/hardsuit,
						/obj/item/weapon/pinpointer/advpinpointer,
						/obj/item/weapon/shield/energy,
						/obj/item/weapon/implanter/adrenalin,
						/obj/item/weapon/storage/belt/military,
						/obj/item/weapon/implanter/storage,
						/obj/item/weapon/storage/firstaid/tactical,
						/obj/item/weapon/bikehorn/golden,
						/obj/item/weapon/restraints/handcuffs/pinkcuffs,
						)
