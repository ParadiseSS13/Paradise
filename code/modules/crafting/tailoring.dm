/datum/crafting_recipe/durathread_vest
	name = "Durathread Vest"
	result = /obj/item/clothing/suit/armor/vest/durathread
	reqs = list(/obj/item/stack/sheet/durathread = 5,
				/obj/item/stack/sheet/leather = 4)
	time = 50
	category = CAT_CLOTHING

/datum/crafting_recipe/durathread_helmet
	name = "Durathread Helmet"
	result = /obj/item/clothing/head/helmet/durathread
	reqs = list(/obj/item/stack/sheet/durathread = 4,
				/obj/item/stack/sheet/leather = 5)
	time = 40
	category = CAT_CLOTHING

/datum/crafting_recipe/durathread_jumpsuit
	name = "Durathread Jumpsuit"
	result = /obj/item/clothing/under/misc/durathread
	reqs = list(/obj/item/stack/sheet/durathread = 4)
	time = 40
	category = CAT_CLOTHING

/datum/crafting_recipe/durathread_beret
	name = "Durathread Beret"
	result = /obj/item/clothing/head/beret/durathread
	reqs = list(/obj/item/stack/sheet/durathread = 2)
	time = 40
	category = CAT_CLOTHING

/datum/crafting_recipe/durathread_beanie
	name = "Durathread Beanie"
	result = /obj/item/clothing/head/beanie/durathread
	reqs = list(/obj/item/stack/sheet/durathread = 2)
	time = 40
	category = CAT_CLOTHING

/datum/crafting_recipe/durathread_duffel
	name = "Durathread Duffelbag"
	result = /obj/item/storage/backpack/duffel/durathread
	reqs = list(/obj/item/stack/sheet/durathread = 6)
	time = 40
	category = CAT_CLOTHING

/datum/crafting_recipe/durathread_bandana
	name = "Durathread Bandana"
	result = /obj/item/clothing/mask/bandana/durathread
	reqs = list(/obj/item/stack/sheet/durathread = 1)
	time = 25
	category = CAT_CLOTHING

/datum/crafting_recipe/fannypack
	name = "Fannypack"
	result = /obj/item/storage/belt/fannypack
	reqs = list(/obj/item/stack/sheet/cloth = 2,
				/obj/item/stack/sheet/leather = 1)
	time = 20
	category = CAT_CLOTHING

/datum/crafting_recipe/hudsunsec
	name = "Security HUDsunglasses"
	result = /obj/item/clothing/glasses/hud/security/sunglasses
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/security = 1,
				  /obj/item/clothing/glasses/sunglasses = 1,
				  /obj/item/stack/cable_coil = 5)
	category = CAT_CLOTHING

/datum/crafting_recipe/hudsunsecremoval
	name = "Security HUD removal"
	result = /obj/item/clothing/glasses/sunglasses
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/security/sunglasses = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/hudsunmed
	name = "Medical HUDsunglasses"
	result = /obj/item/clothing/glasses/hud/health/sunglasses
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/health = 1,
				  /obj/item/clothing/glasses/sunglasses = 1,
				  /obj/item/stack/cable_coil = 5)
	category = CAT_CLOTHING

/datum/crafting_recipe/hudsunmedremoval
	name = "Medical HUD removal"
	result = /obj/item/clothing/glasses/sunglasses
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/health/sunglasses = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/hudsundiag
	name = "Diagnostic HUDsunglasses"
	result = /obj/item/clothing/glasses/hud/diagnostic/sunglasses
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/diagnostic = 1,
				  /obj/item/clothing/glasses/sunglasses = 1,
				  /obj/item/stack/cable_coil = 5)
	category = CAT_CLOTHING

/datum/crafting_recipe/hudsundiagremoval
	name = "Diagnostic HUD removal"
	result = /obj/item/clothing/glasses/sunglasses
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/diagnostic/sunglasses = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/hudsunskills
	name = "Skills HUDsunglasses"
	result = /obj/item/clothing/glasses/hud/skills/sunglasses
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/skills = 1,
				  /obj/item/clothing/glasses/sunglasses = 1,
				  /obj/item/stack/cable_coil = 5)
	category = CAT_CLOTHING

/datum/crafting_recipe/hudsunskillsremoval
	name = "Skills HUD removal"
	result = /obj/item/clothing/glasses/sunglasses
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/skills/sunglasses = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/hudsunmeson
	name = "Meson HUDsunglasses"
	result = /obj/item/clothing/glasses/meson/sunglasses
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/meson = 1,
				  /obj/item/clothing/glasses/sunglasses = 1,
				  /obj/item/stack/cable_coil = 5)
	category = CAT_CLOTHING

/datum/crafting_recipe/hudsunmesonremoval
	name = "Meson HUD removal"
	result = /obj/item/clothing/glasses/sunglasses
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/meson/sunglasses = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/hudsunhydroponic
	name = "Hydroponic HUDsunglasses"
	result = /obj/item/clothing/glasses/hud/hydroponic/sunglasses
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/hydroponic = 1,
				  /obj/item/clothing/glasses/sunglasses = 1,
				  /obj/item/stack/cable_coil = 5)
	category = CAT_CLOTHING

/datum/crafting_recipe/hudsunhydroponicremoval
	name = "Hydroponic HUD removal"
	result = /obj/item/clothing/glasses/sunglasses
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/hydroponic/sunglasses = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/hudsunthermal
	name = "Thermal HUDsunglasses"
	result = /obj/item/clothing/glasses/thermal/sunglasses
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/thermal = 1,
				  /obj/item/clothing/glasses/sunglasses = 1,
				  /obj/item/stack/cable_coil = 5)
	category = CAT_CLOTHING

/datum/crafting_recipe/hudsunthermalremoval
	name = "Thermal HUD removal"
	result = /obj/item/clothing/glasses/sunglasses
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/thermal/sunglasses = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/beergoggles
	name = "Beer Goggles"
	result = /obj/item/clothing/glasses/sunglasses/reagent
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/science = 1,
				  /obj/item/clothing/glasses/sunglasses = 1,
				  /obj/item/stack/cable_coil = 5)
	category = CAT_CLOTHING

/datum/crafting_recipe/beergogglesremoval
	name = "Beer Goggles removal"
	result = /obj/item/clothing/glasses/sunglasses
	time = 20
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/sunglasses/reagent = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/ghostsheet
	name = "Ghost Sheet"
	result = /obj/item/clothing/suit/ghost_sheet
	time = 5
	tools = list(TOOL_WIRECUTTER)
	reqs = list(/obj/item/bedsheet = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/cowboyboots
	name = "Cowboy Boots"
	result = /obj/item/clothing/shoes/cowboy
	reqs = list(/obj/item/stack/sheet/leather = 2)
	time = 45
	category = CAT_CLOTHING

/datum/crafting_recipe/lizardboots
	name = "Lizard Skin Boots"
	result = /obj/effect/spawner/lootdrop/lizardboots
	reqs = list(/obj/item/stack/sheet/animalhide/lizard = 1, /obj/item/stack/sheet/leather = 1)
	time = 60
	category = CAT_CLOTHING

/datum/crafting_recipe/rubberduckyshoes
	name = "Rubber Ducky Shoes"
	result = /obj/item/clothing/shoes/ducky
	time = 45
	reqs = list(/obj/item/bikehorn/rubberducky = 2,
				/obj/item/clothing/shoes/sandal = 1)
	tools = list(TOOL_WIRECUTTER)
	category = CAT_CLOTHING

/datum/crafting_recipe/salmonsuit
	name = "Salmon Suit"
	result = /obj/item/clothing/suit/hooded/salmon_costume
	time = 60
	reqs = list(/obj/item/fish/salmon = 20,
				/obj/item/stack/tape_roll = 5)
	tools = list(TOOL_WIRECUTTER)
	pathtools = list(/obj/item/kitchen/knife)
	category = CAT_CLOTHING

/datum/crafting_recipe/makeshift_armor
	name = "Makeshift armor"
	result = /obj/item/clothing/suit/armor/makeshift_armor
	time = 6 SECONDS
	reqs = list(/obj/item/caution = 1,
				/obj/item/stack/tape_roll = 10)
	tools = list(TOOL_WIRECUTTER)
	category = CAT_CLOTHING

/datum/crafting_recipe/buckhelm
	name = "BuckHelm"
	result = /obj/item/clothing/head/helmet/buckhelm
	time = 6 SECONDS
	reqs = list(/obj/item/reagent_containers/glass/bucket = 3)
	tools = list(TOOL_WIRECUTTER)
	category = CAT_CLOTHING

/datum/crafting_recipe/guitarbag
	name = "Guitar Bag"
	result = /obj/item/storage/backpack/guitarbag
	time = 6 SECONDS
	reqs = list(/obj/item/bodybag = 1,
				/obj/item/stack/tape_roll = 10,
				/obj/item/stack/sheet/cardboard = 2)
	tools = list(TOOL_WIRECUTTER)
	category = CAT_CLOTHING

/datum/crafting_recipe/footwrapsgoliath
	name = "Goliath Hide Footwraps"
	result = /obj/item/clothing/shoes/footwraps/goliath
	reqs = list(/obj/item/stack/sheet/animalhide/goliath_hide = 1,
				/obj/item/stack/sheet/leather = 1)
	time = 6 SECONDS
	category = CAT_CLOTHING

/datum/crafting_recipe/footwrapsdragon
	name = "Ash Drake Hide Footwraps"
	result = /obj/item/clothing/shoes/footwraps/dragon
	reqs = list(/obj/item/stack/sheet/animalhide/ashdrake = 1,
				/obj/item/stack/sheet/leather = 1)
	time = 6 SECONDS
	category = CAT_CLOTHING

/datum/crafting_recipe/goliathgloves
	name = "Goliath Gloves"
	result = /obj/item/clothing/gloves/color/black/goliath
	time = 2 SECONDS
	reqs = list(/obj/item/stack/sheet/leather = 2,
				/obj/item/stack/sheet/animalhide/goliath_hide = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/chitingloves
	name = "Weaver Chitin Gloves"
	result = /obj/item/clothing/gloves/fingerless/weaver
	time = 2 SECONDS
	reqs = list(/obj/item/stack/sheet/leather = 1,
				/obj/item/stack/sheet/animalhide/weaver_chitin = 3)
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
