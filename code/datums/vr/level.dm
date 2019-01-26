//death types VR_DROP_NONE, VR_DROP_ALL, VR_DROP_BLACKLIST, VR_DROP_WHITELIST


/datum/map_template/vr/level
	prefix = "_maps/map_files/vr/"
	suffix = null
	name = "Error Error"
	description = "You should not see this."

/datum/map_template/vr/level/lobby
	id = "lobby"
	suffix = "lobby.dmm"
	name = "Virtual Hub Facility"
	description = "This is the lobby. The hub for all things VR."
	death_type = VR_DROP_WHITELIST
	drop_whitelist = list(/obj/item/reagent_containers/food/drinks/drinkingglass, /obj/item/reagent_containers/spray/cleaner)
	outfit = /datum/outfit/vr/vr_basic
	system = 1

/datum/map_template/vr/level/roman1
	id = "roman1"
	suffix = "blood_and_sand1.dmm"
	name = "Blood and Sand Arena"
	description = "To the Death!"
	death_type = VR_DROP_BLACKLIST
	drop_blacklist = list(/obj/item/clothing/under/roman, /obj/item/clothing/shoes/roman, /obj/item/shield/riot/roman, /obj/item/clothing/head/helmet/roman)
	loot_common = list(/obj/item/twohanded/spear, /obj/item/kitchen/knife/ritual, /obj/item/restraints/legcuffs/bola, /obj/item/twohanded/bostaff,
						/obj/item/storage/backpack/quiver/full, /obj/item/gun/projectile/bow)
	loot_rare = list(/obj/item/claymore, /obj/item/twohanded/energizedfireaxe, /obj/item/grenade/syndieminibomb,
						/obj/item/gun/projectile/revolver/doublebarrel/improvised, /obj/item/twohanded/mjollnir, /obj/item/twohanded/singularityhammer,
						/obj/item/twohanded/knighthammer, /obj/item/gun/energy/e_gun/old, /obj/item/gun/projectile/automatic/pistol/m1911)
	outfit = /datum/outfit/vr/roman

/datum/map_template/vr/level/roman2
	id = "roman2"
	suffix = "blood_and_sand2.dmm"
	name = "Ring of Fire Arena"
	description = "Mind the fire!"
	death_type = VR_DROP_BLACKLIST
	drop_blacklist = list(/obj/item/clothing/under/roman, /obj/item/clothing/shoes/roman, /obj/item/shield/riot/roman, /obj/item/clothing/head/helmet/roman)
	loot_common = list(/obj/item/twohanded/spear, /obj/item/kitchen/knife/ritual, /obj/item/restraints/legcuffs/bola, /obj/item/twohanded/bostaff,
						/obj/item/storage/backpack/quiver/full, /obj/item/gun/projectile/bow)
	loot_rare = list(/obj/item/claymore, /obj/item/twohanded/energizedfireaxe, /obj/item/grenade/syndieminibomb,
						/obj/item/gun/projectile/revolver/doublebarrel/improvised, /obj/item/twohanded/mjollnir, /obj/item/twohanded/singularityhammer,
						/obj/item/twohanded/knighthammer, /obj/item/gun/energy/e_gun/old, /obj/item/gun/projectile/automatic/pistol/m1911)
	outfit = /datum/outfit/vr/roman

/datum/map_template/vr/level/roman3
	id = "roman3"
	suffix = "blood_and_sand3.dmm"
	name = "Monster Pit Arena"
	description = "Be careful not to get eaten!"
	death_type = VR_DROP_BLACKLIST
	drop_blacklist = list(/obj/item/clothing/under/roman, /obj/item/clothing/shoes/roman, /obj/item/shield/riot/roman, /obj/item/clothing/head/helmet/roman)
	loot_common = list(/obj/item/twohanded/spear, /obj/item/kitchen/knife/ritual, /obj/item/restraints/legcuffs/bola, /obj/item/twohanded/bostaff,
						/obj/item/storage/backpack/quiver/full, /obj/item/gun/projectile/bow)
	loot_rare = list(/obj/item/claymore, /obj/item/twohanded/energizedfireaxe, /obj/item/grenade/syndieminibomb,
						/obj/item/gun/projectile/revolver/doublebarrel/improvised, /obj/item/twohanded/mjollnir, /obj/item/twohanded/singularityhammer,
						/obj/item/twohanded/knighthammer, /obj/item/gun/energy/e_gun/old, /obj/item/gun/projectile/automatic/pistol/m1911)
	outfit = /datum/outfit/vr/roman

/datum/map_template/vr/level/ship1
	id = "ship1"
	suffix = "ship1.dmm"
	name = "Sol Raiders"
	description = "GUNS! GUNS! GUNS!"
	death_type = VR_DROP_BLACKLIST
	drop_blacklist = list(/obj/item/clothing/under/solgov, /obj/item/clothing/suit/armor/vest/combat, /obj/item/clothing/shoes/combat, /obj/item/clothing/gloves/combat,
							/obj/item/clothing/head/helmet, /obj/item/storage/belt/military/assault)
	outfit = /datum/outfit/vr/ship
	system = 1

/datum/map_template/vr/level/medical
	id = "medical"
	suffix = "medical.dmm"
	name = "Medical Simulator"
	description = "Its not malpractice if its virtual."
	death_type = VR_DROP_BLACKLIST
	drop_blacklist = list(/obj/item/clothing/under/rank/medical, /obj/item/clothing/suit/storage/labcoat, /obj/item/clothing/shoes/white, /obj/item/card/id/medical,
							/obj/item/clothing/glasses/science, /obj/item/clothing/gloves/color/latex)
	outfit = /datum/outfit/vr/medical

/datum/map_template/vr/level/bombs
	id = "bombs"
	suffix = "bombs.dmm"
	name = "Explosives Testing"
	description = "This is such a waste of CPU cycles to render."
	death_type = VR_DROP_BLACKLIST
	drop_blacklist = list(/obj/item/clothing/under/rank/medical, /obj/item/clothing/suit/storage/labcoat, /obj/item/clothing/shoes/white, /obj/item/card/id/research,
							/obj/item/clothing/glasses/science, /obj/item/clothing/gloves/color/latex, /obj/item/storage/belt/utility/chief/full)
	outfit = /datum/outfit/vr/research

/datum/map_template/vr/level/bomb_range
	id = "bomb_range"
	suffix = "bomb_range.dmm"
	name = "Explosives Testing"
	system = 1

/datum/map_template/vr/level/engineering
	id = "engineering"
	suffix = "engineering.dmm"
	name = "Engineering Simulator"
	description = "A true open world sandbox."
	death_type = VR_DROP_BLACKLIST
	drop_blacklist = list(/obj/item/clothing/under/rank/engineer, /obj/item/clothing/suit/storage/hazardvest, /obj/item/clothing/shoes/workboots, /obj/item/card/id/engineering,
							/obj/item/clothing/gloves/color/yellow, /obj/item/storage/belt/utility/chief/full, /obj/item/storage/backpack/industrial)
	outfit = /datum/outfit/vr/engineering

/datum/map_template/vr/level/engine
	id = "engine"
	suffix = "engine.dmm"
	name = "Engineering Simulator"
	system = 1