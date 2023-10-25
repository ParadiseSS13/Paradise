/datum/crafting_recipe/durathread_vest
	name = "Durathread Vest"
	result = list(/obj/item/clothing/suit/armor/vest/durathread)
	reqs = list(/obj/item/stack/sheet/durathread = 5,
				/obj/item/stack/sheet/leather = 4)
	time = 50
	category = CAT_CLOTHING

/datum/crafting_recipe/durathread_helmet
	name = "Durathread Helmet"
	result = list(/obj/item/clothing/head/helmet/durathread)
	reqs = list(/obj/item/stack/sheet/durathread = 4,
				/obj/item/stack/sheet/leather = 5)
	time = 40
	category = CAT_CLOTHING

/datum/crafting_recipe/durathread_jumpsuit
	name = "Durathread Jumpsuit"
	result = list(/obj/item/clothing/under/misc/durathread)
	reqs = list(/obj/item/stack/sheet/durathread = 4)
	time = 40
	category = CAT_CLOTHING

/datum/crafting_recipe/durathread_beret
	name = "Durathread Beret"
	result = list(/obj/item/clothing/head/beret/durathread)
	reqs = list(/obj/item/stack/sheet/durathread = 2)
	time = 40
	category = CAT_CLOTHING

/datum/crafting_recipe/durathread_beanie
	name = "Durathread Beanie"
	result = list(/obj/item/clothing/head/beanie/durathread)
	reqs = list(/obj/item/stack/sheet/durathread = 2)
	time = 40
	category = CAT_CLOTHING

/datum/crafting_recipe/durathread_bandana
	name = "Durathread Bandana"
	result = list(/obj/item/clothing/mask/bandana/durathread)
	reqs = list(/obj/item/stack/sheet/durathread = 1)
	time = 25
	category = CAT_CLOTHING

/datum/crafting_recipe/fannypack
	name = "Fannypack"
	result = list(/obj/item/storage/belt/fannypack)
	reqs = list(/obj/item/stack/sheet/cloth = 2,
				/obj/item/stack/sheet/leather = 1)
	time = 20
	category = CAT_CLOTHING

/datum/crafting_recipe/hudgogsec
	name = "Security HUD goggles"
	result = list(/obj/item/clothing/glasses/hud/security/goggles)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/security = 1,
				/obj/item/clothing/glasses/goggles = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_CLOTHING

/datum/crafting_recipe/hudgogsecremoval
	name = "Security HUD removal (goggles)"
	result = list(/obj/item/clothing/glasses/goggles, /obj/item/clothing/glasses/hud/security)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/security/goggles = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/hudgoghealth
	name = "Health HUD goggles"
	result = list(/obj/item/clothing/glasses/hud/health/goggles)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/health = 1,
				/obj/item/clothing/glasses/goggles = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_CLOTHING

/datum/crafting_recipe/hudgoghealthremoval
	name = "Health HUD removal (goggles)"
	result = list(/obj/item/clothing/glasses/goggles, /obj/item/clothing/glasses/hud/health)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/health/goggles = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/hudgogdiagnostic
	name = "Diagnostic HUD goggles"
	result = list(/obj/item/clothing/glasses/hud/diagnostic/goggles)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/diagnostic = 1,
				/obj/item/clothing/glasses/goggles = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_CLOTHING

/datum/crafting_recipe/hudgogdiagnosticremoval
	name = "Diagnostic HUD removal (goggles)"
	result = list(/obj/item/clothing/glasses/goggles, /obj/item/clothing/glasses/hud/diagnostic)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/diagnostic/goggles = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/hudgoghydroponic
	name = "Hydroponic HUD goggles"
	result = list(/obj/item/clothing/glasses/hud/hydroponic/goggles)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/hydroponic = 1,
				/obj/item/clothing/glasses/goggles = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_CLOTHING

/datum/crafting_recipe/hudgoghydroponicremoval
	name = "Hydroponic HUD removal (goggles)"
	result = list(/obj/item/clothing/glasses/goggles, /obj/item/clothing/glasses/hud/hydroponic)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/hydroponic/goggles = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/hudgogskills
	name = "Skills HUD goggles"
	result = list(/obj/item/clothing/glasses/hud/skills/goggles)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/skills = 1,
				/obj/item/clothing/glasses/goggles = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_CLOTHING

/datum/crafting_recipe/hudgogskillsremoval
	name = "Skills HUD removal (goggles)"
	result = list(/obj/item/clothing/glasses/goggles, /obj/item/clothing/glasses/hud/skills)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/skills/goggles = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/hudsunsec
	name = "Security HUDsunglasses"
	result = list(/obj/item/clothing/glasses/hud/security/sunglasses)
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/security = 1,
				/obj/item/clothing/glasses/sunglasses = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_CLOTHING

/datum/crafting_recipe/hudsunsecremoval
	name = "Security HUD removal"
	result = list(/obj/item/clothing/glasses/sunglasses, /obj/item/clothing/glasses/hud/security)
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/security/sunglasses = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/hudsunmed
	name = "Medical HUDsunglasses"
	result = list(/obj/item/clothing/glasses/hud/health/sunglasses)
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/health = 1,
				/obj/item/clothing/glasses/sunglasses = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_CLOTHING

/datum/crafting_recipe/hudsunmedremoval
	name = "Medical HUD removal"
	result = list(/obj/item/clothing/glasses/sunglasses, /obj/item/clothing/glasses/hud/health)
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/health/sunglasses = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/hudsundiag
	name = "Diagnostic HUDsunglasses"
	result = list(/obj/item/clothing/glasses/hud/diagnostic/sunglasses)
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/diagnostic = 1,
				/obj/item/clothing/glasses/sunglasses = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_CLOTHING

/datum/crafting_recipe/hudsundiagremoval
	name = "Diagnostic HUD removal"
	result = list(/obj/item/clothing/glasses/sunglasses, /obj/item/clothing/glasses/hud/diagnostic)
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/diagnostic/sunglasses = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/beergoggles
	name = "Sunscanners"
	result = list(/obj/item/clothing/glasses/sunglasses/reagent)
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/science = 1,
				/obj/item/clothing/glasses/sunglasses = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_CLOTHING

/datum/crafting_recipe/beergogglesremoval
	name = "Sunscanners removal"
	result = list(/obj/item/clothing/glasses/sunglasses, /obj/item/clothing/glasses/science)
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/sunglasses/reagent = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/ghostsheet
	name = "Ghost Sheet"
	result = list(/obj/item/clothing/suit/ghost_sheet)
	time = 5
	tools = list(TOOL_WIRECUTTER)
	reqs = list(/obj/item/bedsheet = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/cowboyboots
	name = "Cowboy Boots"
	result = list(/obj/item/clothing/shoes/cowboy)
	reqs = list(/obj/item/stack/sheet/leather = 2)
	time = 45
	category = CAT_CLOTHING

/datum/crafting_recipe/lizardboots
	name = "Lizard Skin Boots"
	result = list(/obj/effect/spawner/lootdrop/lizardboots)
	reqs = list(/obj/item/stack/sheet/animalhide/lizard = 1, /obj/item/stack/sheet/leather = 1)
	time = 60
	category = CAT_CLOTHING

/datum/crafting_recipe/rubberduckyshoes
	name = "Rubber Ducky Shoes"
	result = list(/obj/item/clothing/shoes/ducky)
	time = 45
	reqs = list(/obj/item/bikehorn/rubberducky = 2,
				/obj/item/clothing/shoes/sandal = 1)
	tools = list(TOOL_WIRECUTTER)
	category = CAT_CLOTHING

/datum/crafting_recipe/salmonsuit
	name = "Salmon Suit"
	result = list(/obj/item/clothing/suit/hooded/salmon_costume)
	time = 60
	reqs = list(/obj/item/fish/salmon = 20,
				/obj/item/stack/tape_roll = 5)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/kitchen/knife)
	category = CAT_CLOTHING

/datum/crafting_recipe/voice_modulator
	name = "Voice Modulator Mask"
	result = list(/obj/item/clothing/mask/gas/voice_modulator)
	time = 45
	tools = list(TOOL_SCREWDRIVER, TOOL_MULTITOOL)
	reqs = list(/obj/item/clothing/mask/gas = 1,
				/obj/item/assembly/voice = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_CLOTHING
