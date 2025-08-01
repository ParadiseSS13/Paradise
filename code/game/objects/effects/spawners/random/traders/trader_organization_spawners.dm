/obj/effect/spawner/random/traders/federation_minor
	name = "11. trans-solar federation small gear"
	loot = list(
		/obj/item/storage/box/enforcer_rubber = 5,
		/obj/item/lighter/zippo/gonzofist = 5,
		/obj/item/clothing/glasses/welding/superior = 5,
		/obj/item/clothing/suit/armor/bulletproof = 5,
		/obj/item/clothing/mask/gas/explorer/marines = 5,
		/obj/item/clothing/gloves/combat = 5,
		/obj/item/storage/belt/federation_webbing = 5,
		/obj/item/clothing/under/solgov = 5,
		/obj/item/mod/module/dispenser = 5,
		/obj/item/flag/solgov = 3,
		/obj/item/clothing/mask/holo_cigar = 5
	)

/obj/effect/spawner/random/traders/federation_major
	name = "12. trans-solar federation large gear"
	spawn_loot_count = 3
	loot = list(
		/obj/item/storage/box/deagle = 2, //One mag
		/obj/item/gun/projectile/automatic/pistol/m1911 = 3, //Again, one mag. Don't lose it.
		/obj/item/melee/baseball_bat/homerun = 5,
		/obj/item/rcd/combat = 5,
		/obj/item/weaponcrafting/gunkit/universal_gun_kit/sol_gov = 5,
		/obj/item/storage/fancy/shell/buck = 3, //Only seven shots, make them count
		/obj/item/mod/module/noslip = 4,
		/obj/item/storage/box/marine_armor_export = 3 //Export-grade armor, it's a bit worse than the normal version.
	)

/obj/effect/spawner/random/traders/cybersun_minor
	name = "11. cybersun industries small gear"
	loot = list(
		/obj/item/storage/box/syndidonkpockets = 5,
		/obj/item/clothing/suit/jacket/bomber/syndicate = 5,
		/obj/item/storage/box/syndie_kit/space = 5,
		/obj/item/clothing/glasses/meson/sunglasses = 5,
		/obj/item/storage/pill_bottle/zoom = 5,
		/obj/item/clothing/mask/gas/voice_modulator/chameleon = 5,
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/xray = 3,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine = 3,
		/obj/item/flag/syndi = 3
	)

// Damn near all of this is illegal. Gives officers something to do on a shift quiet enough to spawn traders.
/obj/effect/spawner/random/traders/cybersun_major
	name = "12. cybersun industries large gear"
	spawn_loot_count = 3
	loot = list(
		/obj/item/shield/energy = 20,
		/obj/item/gun/projectile/automatic/pistol = 50,
		/obj/item/bio_chip_implanter/storage = 50,
		/obj/item/melee/knuckleduster/syndie = 50,
		/obj/item/clothing/glasses/thermal/eyepatch = 50,
		/obj/item/toy/syndicateballoon = 60,
		/obj/item/organ/internal/cyberimp/arm/razorwire = 30,
		/obj/item/organ/internal/cyberimp/arm/shell_launcher = 30,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg/dual = 30,
		/obj/item/clothing/mask/holo_cigar = 50,
		/obj/mecha/combat/marauder/mauler/trader = 3 //Extremely rare, unloaded so crew need to arm it for it to have any use. Also most definitely needs one helluva permit.
	)
	spawn_loot_double = FALSE // No double mechs.

/obj/effect/spawner/random/traders/ussp_minor
	name = "11. USSP small gear"
	spawn_loot_count = 8 //Mostly flavor items
	loot = list(
		/obj/item/clothing/under/new_soviet = 50,
		/obj/item/clothing/suit/sovietcoat = 50,
		/obj/item/clothing/head/ushanka = 50,
		/obj/item/food/grown/potato = 50,
		/obj/item/reagent_containers/drinks/bottle/vodka/badminka = 50,
		/obj/item/clothing/head/sovietsidecap = 50,
		/obj/item/flag/ussp = 30,
		/obj/item/ammo_box/magazine/apsm10mm = 15, //Spare mags for APS pistol. Sometimes you don't get the APS, in which case, soviet logistics.
		/obj/item/ammo_box/a762 = 15
	)

// Lots of things to write permits for. Gives officers something to do on a shift quiet enough to spawn traders.
/obj/effect/spawner/random/traders/ussp_major
	name = "12. USSP large gear"
	spawn_loot_count = 2 //Lots of dangerous stuff here - reduced amount
	loot = list(
		/obj/item/gun/projectile/revolver/nagant = 5,
		/obj/item/gun/projectile/automatic/pistol/type_230 = 3,
		/obj/item/gun/projectile/shotgun/boltaction = 5,
		/obj/item/clothing/suit/space/hardsuit/soviet = 4,
		/obj/item/clothing/glasses/thermal/eyepatch = 5,
		/obj/item/clothing/mask/holo_cigar = 1
	)

/obj/effect/spawner/random/traders/glintscale_minor
	name = "11. glint-scale small gear"
	loot = list(
				/obj/item/clothing/suit/armor/vest/combat = 50,
				/obj/item/clothing/under/syndicate/combat = 50,
				/obj/item/claymore/ceremonial = 50,
				/obj/item/harpoon = 50,
				/obj/item/nullrod/claymore/chainsaw_sword = 50,
				/obj/item/whetstone = 50,
				/obj/item/flag/species/unathi = 20,
				/obj/item/clothing/suit/armor/riot/knight/templar = 40,
				/obj/item/clothing/head/helmet/riot/knight/templar = 40,
				/obj/item/clothing/suit/unathi/robe = 20
				)

/obj/effect/spawner/random/traders/glintscale_major
	name = "12. glint-scale large gear"
	spawn_loot_count = 3
	loot = list(
				/obj/item/melee/energy/sword/pirate = 30,
				/obj/item/storage/box/breacher = 30,
				/obj/item/fireaxe = 50,
				/obj/item/fireaxe/boneaxe = 50,
				/obj/item/gun/energy/kinetic_accelerator/crossbow/large = 10 //Big ebow.
				)

/obj/effect/spawner/random/traders/steadfast_minor
	name = "11. steadfast trading co. small gear"
	spawn_loot_count = 8 //Since it's a lot of seeds, boosted amount
	loot = list(
		/obj/item/storage/box/botany_labelled_seeds = 50,
		/obj/item/seeds/chili/ice = 20,
		/obj/item/seeds/chili/ghost = 20,
		/obj/item/seeds/cannabis/ultimate = 10,
		/obj/item/seeds/cannabis/white = 20,
		/obj/item/seeds/wheat/meat = 20,
		/obj/item/seeds/glowshroom = 20,
		/obj/item/seeds/glowshroom/glowcap = 20,
		/obj/item/seeds/tobacco/space = 20,
		/obj/item/storage/box/hydroponics_starter = 40,
		/obj/item/mod/module/thermal_regulator = 20,
		/obj/item/flag/species/vulp = 20
	)

/obj/effect/spawner/random/traders/steadfast_major
	name = "12. steadfast trading co. large gear"
	spawn_loot_count = 3
	loot = list(
		/obj/item/mod/construction/plating/research = 3,
		/obj/item/assembly/signaler/anomaly/random = 2,
		/obj/item/gun/energy/gun = 5,
		/obj/item/storage/fancy/shell/dragonsbreath = 3,
		/obj/item/storage/box/turbine_kit = 2,
		/obj/item/mod/module/firefighting_tank = 4,
		/obj/item/mod/module/jetpack/advanced = 4
	)

/obj/effect/spawner/random/traders/syntheticunion_minor
	name = "11. synthetic union small gear"
	spawn_loot_count = 8 //A lot of these are available on station, so the amount of items spawned here is increased
	loot = list(
		/obj/item/clothing/glasses/meson/sunglasses = 5,
		/obj/item/clothing/glasses/thermal/monocle = 5,
		/obj/item/organ/internal/cyberimp/arm/toolset = 5,
		/obj/item/organ/internal/cyberimp/arm/surgery = 5,
		/obj/item/organ/internal/cyberimp/arm/janitorial = 5,
		/obj/item/organ/internal/cyberimp/brain/anti_stam = 5,
		/obj/item/organ/internal/cyberimp/brain/anti_sleep = 5,
		/obj/item/organ/internal/cyberimp/brain/clown_voice = 4,
		/obj/item/organ/internal/cyberimp/mouth/breathing_tube = 5,
		/obj/item/organ/internal/cyberimp/chest/ipc_repair = 5,
		/obj/item/organ/internal/cyberimp/chest/ipc_joints/magnetic_joints = 5,
		/obj/item/organ/internal/cyberimp/chest/ipc_joints/sealed = 5,
		/obj/item/autosurgeon/organ = 1,
		/obj/item/flag/species/machine = 2
	)

/obj/effect/spawner/random/traders/syntheticunion_major
	name = "12. synthetic union large gear"
	spawn_loot_count = 4
	loot = list(
		/obj/item/organ/internal/cyberimp/arm/toolset_abductor = 20,
		/obj/item/organ/internal/cyberimp/arm/esword = 10,
		/obj/item/organ/internal/cyberimp/arm/flash = 50,
		/obj/item/organ/internal/cyberimp/chest/nutriment/plus/hardened = 50,
		/obj/item/organ/internal/cyberimp/arm/telebaton = 25, //Security'll love this one
		/obj/item/organ/internal/cyberimp/arm/razorwire = 30,
		/obj/item/organ/internal/cyberimp/arm/shell_launcher = 30,
		/obj/item/organ/internal/cyberimp/brain/anti_drop/hardened = 20,
		/obj/item/organ/internal/cyberimp/brain/anti_stam/hardened = 30,
		/obj/item/ai_upgrade/surveillance_upgrade = 35
	)

/obj/effect/spawner/random/traders/skipjack_minor
	name = "11. skipjack small gear"
	loot = list(
		/obj/item/clothing/glasses/meson/gar = 50,
		/obj/item/clothing/glasses/thermal/eyepatch = 50,
		/obj/item/melee/energy/sword/pirate = 50,
		/obj/item/clothing/suit/hooded/vox_robes = 30,
		/obj/item/clothing/under/vox/vox_casual = 30,
		/obj/item/clothing/gloves/color/yellow/vox = 10, //Species limited - rare item
		/obj/item/clothing/shoes/magboots/vox = 10, //Species limited - rare item
		/obj/item/organ/internal/cyberimp/mouth/breathing_tube = 50,
		/obj/item/mod/module/jetpack/advanced = 50,
		/obj/item/gun/energy/plasma_pistol = 50,
		/obj/item/mod/control/pre_equipped/standard = 40,
		/obj/item/flag/species/vox = 20
	)

/obj/effect/spawner/random/traders/skipjack_major //contains a variety of things - raider loot
	name = "12. skipjack large gear"
	spawn_loot_count = 3
	loot = list(
		/obj/item/storage/box/vox_spacesuit = 2,
		/obj/item/storage/box/syndie_kit/chameleon = 5,
		/obj/item/organ/internal/cyberimp/arm/esword = 1,
		/obj/item/gun/energy/spikethrower = 2,
		/obj/item/organ/internal/cyberimp/arm/medibeam = 5,
		/obj/item/organ/internal/cyberimp/arm/toolset_abductor = 5,
		/obj/item/organ/internal/cyberimp/brain/anti_stam/hardened = 1,
		/obj/item/organ/internal/cyberimp/arm/gun/laser = 1,
		/obj/item/fireaxe = 1,
		/obj/item/gun/projectile/revolver/nagant = 1,
		/obj/item/bio_chip_implanter/storage = 1,
		/obj/item/rcd/combat = 1
	)

/obj/effect/spawner/random/traders/solarcentral_minor
	name = "11. skrellian central authority small gear" //Medical and protection theme - shields, mods, meds, and love
	loot = list(
		/obj/item/mod/control/pre_equipped/rescue = 6,
		/obj/item/pen/sleepy/love = 5,
		/obj/item/reagent_containers/glass/bottle/reagent/omnizine = 5,
		/obj/item/reagent_containers/glass/bottle/love = 5,
		/obj/item/reagent_containers/glass/bottle/reagent/lazarus_reagent = 5,
		/obj/item/reagent_containers/applicator/dual = 5,
		/obj/item/reagent_containers/hypospray/autoinjector/nanocalcium = 3,
		/obj/item/storage/firstaid/surgery = 4,
		/obj/item/dnainjector/nobreath = 5,
		/obj/item/dnainjector/regenerate = 5,
		/obj/item/dnainjector/insulation = 5,
		/obj/item/flag/species/skrell = 2
	)

/obj/effect/spawner/random/traders/solarcentral_major
	name = "12. skrellian central authority large gear"
	spawn_loot_count = 3
	loot = list(
		/obj/item/mod/module/energy_shield = 4,
		/obj/item/shield/energy = 4,
		/obj/item/reagent_containers/applicator/dual/syndi = 5, //Same as the above but comes emagged
		/obj/item/gun/medbeam = 3,
		/obj/item/gun/syringe/syndicate = 5,
		/obj/item/storage/box/skrell_suit/black = 3,
		/obj/item/storage/box/skrell_suit/white = 3,
		/obj/item/rod_of_asclepius = 2
	)

/obj/effect/spawner/random/traders/technocracy_minor
	name = "11. technocracy small gear"
	loot = list(
		/obj/item/paper/researchnotes = 15, //More research from the smart ones
		/obj/item/storage/box/beakers/bluespace = 5,
		/obj/item/storage/box/stockparts/deluxe = 5,
		/obj/item/clothing/glasses/thermal/monocle = 5,
		/obj/item/organ/internal/cyberimp/arm/toolset_abductor = 3,
		/obj/item/organ/internal/cyberimp/arm/surgery = 4,
		/obj/item/organ/internal/cyberimp/arm/advmop = 3,
		/obj/item/organ/internal/cyberimp/brain/anti_stam = 5,
		/obj/item/organ/internal/cyberimp/brain/anti_sleep = 5,
		/obj/item/organ/internal/cyberimp/brain/anti_drop = 5,
		/obj/item/autosurgeon/organ = 1,
		/obj/item/flag/species/greys = 2
	)

/obj/effect/spawner/random/traders/technocracy_major
	name = "12. technocracy large gear"
	spawn_loot_count = 3
	loot = list(
		/obj/item/storage/box/syndie_kit/prescan = 30,
		/obj/item/gun/energy/decloner = 50,
		/obj/item/organ/internal/cyberimp/brain/anti_drop/hardened = 20,
		/obj/item/organ/internal/cyberimp/brain/anti_stam/hardened = 30,
		/obj/item/assembly/signaler/anomaly/random = 50,
		/obj/item/ai_upgrade/surveillance_upgrade = 35,
		/obj/item/mod/module/storage/bluespace = 40
	)

/obj/effect/spawner/random/traders/merchantguild_minor
	name = "11. merchant guild small gear"
	spawn_loot_count = 12 //Much larger selection due to it being almost all clothes.
	loot = list(
		/obj/item/flag/species/nian = 2,
		/obj/item/clothing/under/suit/really_black = 5,
		/obj/item/clothing/under/syndicate/combat = 5,
		/obj/item/clothing/under/syndicate/sniper = 5,
		/obj/item/clothing/under/new_soviet/sovietofficer = 5,
		/obj/item/clothing/under/solgov/elite = 5,
		/obj/item/clothing/under/solgov/command = 5,
		/obj/item/clothing/under/retro/security = 5,
		/obj/item/clothing/under/misc/gimmick_captain_suit = 5,
		/obj/item/clothing/under/misc/durathread = 5,
		/obj/item/clothing/under/psysuit = 5,
		/obj/item/clothing/under/costume/cuban_suit = 5,
		/obj/item/clothing/suit/armor/vest/jacket = 5,
		/obj/item/clothing/head/collectable/petehat = 2,
		/obj/item/clothing/head/collectable/tophat = 5,
		/obj/item/clothing/head/collectable/police = 5,
		/obj/item/clothing/head/collectable/kitty = 5,
		/obj/item/clothing/under/costume/janimaid = 5,
		/obj/item/clothing/under/costume/maid = 5,
		/obj/item/storage/box/syndie_kit/chameleon = 6
	)

/obj/effect/spawner/random/traders/merchantguild_major
	name = "12. merchant guild large gear"
	loot = list(
		/obj/item/clothing/suit/pimpcoat = 5,
		/obj/item/dualsaber/toy = 5,
		/obj/item/toy/sword = 5,
		/obj/item/toy/plushie/carpplushie/dragon = 5,
		/obj/item/toy/plushie/carpplushie/void = 5,
		/obj/item/toy/plushie/ipcplushie = 3,
		/obj/item/toy/plushie/nukeplushie = 3,
		/obj/item/toy/plushie/nianplushie = 5, //*buzz
		/obj/item/toy/windup_toolbox = 5,
		/obj/item/toy/ai = 5,
		/obj/item/clothing/mask/gas/voice_modulator/chameleon = 5,
		/obj/item/storage/box/syndie_kit/chameleon = 5
	)
