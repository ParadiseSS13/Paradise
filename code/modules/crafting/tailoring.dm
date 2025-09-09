#define ALLOWED_INGREDIENT_SUNGLASSES list( \
	/obj/item/clothing/glasses/sunglasses, \
	/obj/item/clothing/glasses/sunglasses/noir, \
	/obj/item/clothing/glasses/sunglasses/yeah, \
	/obj/item/clothing/glasses/sunglasses/big \
)

/datum/crafting_recipe/durathread_vest
	name = "Durathread Vest"
	result = list(/obj/item/clothing/suit/armor/vest/durathread)
	reqs = list(/obj/item/stack/sheet/durathread = 5,
				/obj/item/stack/sheet/leather = 4)
	time = 5 SECONDS
	category = CAT_CLOTHING

/datum/crafting_recipe/durathread_helmet
	name = "Durathread Helmet"
	result = list(/obj/item/clothing/head/helmet/durathread)
	reqs = list(/obj/item/stack/sheet/durathread = 4,
				/obj/item/stack/sheet/leather = 5)
	time = 4 SECONDS
	category = CAT_CLOTHING

/datum/crafting_recipe/durathread_hardhat
	name = "Durathread Hard Hat"
	result = list(/obj/item/clothing/head/hardhat/durathread)
	reqs = list(/obj/item/clothing/head/helmet/durathread = 1,
				/obj/item/mounted/frame/light_fixture/small = 1,
				/obj/item/stack/cable_coil = 5,
				/obj/item/light/bulb = 1)
	time = 4 SECONDS
	category = CAT_CLOTHING

/datum/crafting_recipe/durathread_jumpsuit
	name = "Durathread Jumpsuit"
	result = list(/obj/item/clothing/under/misc/durathread)
	reqs = list(/obj/item/stack/sheet/durathread = 4)
	time = 4 SECONDS
	category = CAT_CLOTHING

/datum/crafting_recipe/durathread_beret
	name = "Durathread Beret"
	result = list(/obj/item/clothing/head/beret/durathread)
	reqs = list(/obj/item/stack/sheet/durathread = 2)
	time = 4 SECONDS
	category = CAT_CLOTHING

/datum/crafting_recipe/durathread_beanie
	name = "Durathread Beanie"
	result = list(/obj/item/clothing/head/beanie/durathread)
	reqs = list(/obj/item/stack/sheet/durathread = 2)
	time = 4 SECONDS
	category = CAT_CLOTHING

/datum/crafting_recipe/durathread_bandana
	name = "Durathread Bandana"
	result = list(/obj/item/clothing/mask/bandana/durathread)
	reqs = list(/obj/item/stack/sheet/durathread = 1)
	time = 2.5 SECONDS
	category = CAT_CLOTHING

/datum/crafting_recipe/fannypack
	name = "Fannypack"
	result = list(/obj/item/storage/belt/fannypack)
	reqs = list(/obj/item/stack/sheet/cloth = 2,
				/obj/item/stack/sheet/leather = 1)
	time = 2 SECONDS
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

/datum/crafting_recipe/hudgogsec/New()
	..()
	blacklist = subtypesof(/obj/item/clothing/glasses/hud/security)

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

/datum/crafting_recipe/hudgoghealth/New()
	..()
	blacklist = subtypesof(/obj/item/clothing/glasses/hud/health)

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

/datum/crafting_recipe/hudgogdiagnostic/New()
	..()
	blacklist = subtypesof(/obj/item/clothing/glasses/hud/diagnostic)

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

/datum/crafting_recipe/hudgoghydroponic/New()
	..()
	blacklist = subtypesof(/obj/item/clothing/glasses/hud/hydroponic)

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

/datum/crafting_recipe/hudgogskills/New()
	..()
	blacklist = subtypesof(/obj/item/clothing/glasses/hud/skills)

/datum/crafting_recipe/hudgogskillsremoval
	name = "Skills HUD removal (goggles)"
	result = list(/obj/item/clothing/glasses/goggles, /obj/item/clothing/glasses/hud/skills)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/skills/goggles = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/hudsunskills
	name = "Skills HUD sunglasses"
	result = list(/obj/item/clothing/glasses/hud/skills/sunglasses)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/skills = 1,
				/obj/item/clothing/glasses/sunglasses = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_CLOTHING

/datum/crafting_recipe/hudsunskills/New()
	..()
	blacklist = subtypesof(/obj/item/clothing/glasses/hud/skills) \
		| typesof(/obj/item/clothing/glasses/sunglasses) - ALLOWED_INGREDIENT_SUNGLASSES

/datum/crafting_recipe/hudsunskillsremoval
	name = "Skills HUD removal"
	result = list(/obj/item/clothing/glasses/sunglasses, /obj/item/clothing/glasses/hud/skills)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/skills/sunglasses = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/hudsunsec
	name = "Security HUDsunglasses"
	result = list(/obj/item/clothing/glasses/hud/security/sunglasses)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/security = 1,
				/obj/item/clothing/glasses/sunglasses = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_CLOTHING

/datum/crafting_recipe/hudsunsec/New()
	..()
	blacklist = subtypesof(/obj/item/clothing/glasses/hud/security) \
		| typesof(/obj/item/clothing/glasses/sunglasses) - ALLOWED_INGREDIENT_SUNGLASSES

/datum/crafting_recipe/hudsunsecremoval
	name = "Security HUD removal"
	result = list(/obj/item/clothing/glasses/sunglasses, /obj/item/clothing/glasses/hud/security)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/security/sunglasses = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/hudsunmed
	name = "Medical HUDsunglasses"
	result = list(/obj/item/clothing/glasses/hud/health/sunglasses)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/health = 1,
				/obj/item/clothing/glasses/sunglasses = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_CLOTHING

/datum/crafting_recipe/hudsunmed/New()
	..()
	blacklist = subtypesof(/obj/item/clothing/glasses/hud/health) \
		| typesof(/obj/item/clothing/glasses/sunglasses) - ALLOWED_INGREDIENT_SUNGLASSES

/datum/crafting_recipe/hudsunmedremoval
	name = "Medical HUD removal"
	result = list(/obj/item/clothing/glasses/sunglasses, /obj/item/clothing/glasses/hud/health)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/health/sunglasses = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/hudsundiag
	name = "Diagnostic HUDsunglasses"
	result = list(/obj/item/clothing/glasses/hud/diagnostic/sunglasses)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/diagnostic = 1,
				/obj/item/clothing/glasses/sunglasses = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_CLOTHING

/datum/crafting_recipe/hudsundiag/New()
	..()
	blacklist = subtypesof(/obj/item/clothing/glasses/hud/diagnostic) \
		| typesof(/obj/item/clothing/glasses/sunglasses) - ALLOWED_INGREDIENT_SUNGLASSES

/datum/crafting_recipe/hudsundiagremoval
	name = "Diagnostic HUD removal"
	result = list(/obj/item/clothing/glasses/sunglasses, /obj/item/clothing/glasses/hud/diagnostic)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/diagnostic/sunglasses = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/hudsunjani
	name = "Janitor HUD sunglasses"
	result = list(/obj/item/clothing/glasses/hud/janitor/sunglasses)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/janitor = 1,
				/obj/item/clothing/glasses/sunglasses = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_CLOTHING

/datum/crafting_recipe/hudsunjani/New()
	..()
	blacklist = subtypesof(/obj/item/clothing/glasses/hud/janitor) \
		| typesof(/obj/item/clothing/glasses/sunglasses) - ALLOWED_INGREDIENT_SUNGLASSES

/datum/crafting_recipe/hudsunjaniremoval
	name = "Janitor HUD sunglasses removal"
	result = list(/obj/item/clothing/glasses/sunglasses, /obj/item/clothing/glasses/hud/janitor)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/janitor/sunglasses = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/hudsunmeson
	name = "Meson HUD sunglasses"
	result = list(/obj/item/clothing/glasses/meson/sunglasses)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/meson = 1,
				/obj/item/clothing/glasses/sunglasses = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_CLOTHING

/datum/crafting_recipe/hudsunmeson/New()
	..()
	blacklist = subtypesof(/obj/item/clothing/glasses/meson) \
		| typesof(/obj/item/clothing/glasses/sunglasses) - ALLOWED_INGREDIENT_SUNGLASSES

/datum/crafting_recipe/hudsunmesonremoval
	name = "Meson HUD sunglasses removal"
	result = list(/obj/item/clothing/glasses/sunglasses, /obj/item/clothing/glasses/meson)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/meson/sunglasses = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/hudsyndiesun
	name = "Suspicious sunglasses"
	result = list(/obj/item/clothing/glasses/syndie_sun)
	time = 1 SECONDS
	tools = list(TOOL_SCREWDRIVER)
	reqs = list(/obj/item/clothing/glasses/sunglasses = 1,
				/obj/item/clothing/glasses/syndie = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/hudsyndiesunremoval
	name = "Suspicious glasses flash protection removal"
	result = list(/obj/item/clothing/glasses/sunglasses = 1,
				/obj/item/clothing/glasses/syndie = 1,)
	time = 1 SECONDS
	tools = list(TOOL_SCREWDRIVER)
	reqs = list(/obj/item/clothing/glasses/syndie_sun = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/beergoggles
	name = "Sunscanners"
	result = list(/obj/item/clothing/glasses/sunglasses/reagent)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/science = 1,
				/obj/item/clothing/glasses/sunglasses = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_CLOTHING

/datum/crafting_recipe/beergoggles/New()
	..()
	blacklist = subtypesof(/obj/item/clothing/glasses/science) \
		| typesof(/obj/item/clothing/glasses/sunglasses) - ALLOWED_INGREDIENT_SUNGLASSES

/datum/crafting_recipe/beergogglesremoval
	name = "Sunscanners removal"
	result = list(/obj/item/clothing/glasses/sunglasses, /obj/item/clothing/glasses/science)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/sunglasses/reagent = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/shaded_tajblind
	name = "Shaded Tajaran veil"
	result = list(/obj/item/clothing/glasses/hud/tajblind/shaded)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/sunglasses = 1,
				/obj/item/clothing/glasses/hud/tajblind = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/shaded_tajblind/New()
	..()
	blacklist += subtypesof(/obj/item/clothing/glasses/sunglasses)
	blacklist += subtypesof(/obj/item/clothing/glasses/hud/tajblind)

/datum/crafting_recipe/shaded_tajblind_removal
	name = "Shaded Tajaran veil removal"
	result = list(/obj/item/clothing/glasses/sunglasses, /obj/item/clothing/glasses/hud/tajblind)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/tajblind/shaded = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/shaded_tajblind_removal/New()
	..()
	blacklist += subtypesof(/obj/item/clothing/glasses/hud/tajblind/shaded)

/datum/crafting_recipe/engi_tajblind
	name = "Tajaran engineering meson veil"
	result = list(/obj/item/clothing/glasses/hud/tajblind/meson)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/meson = 1,
				/obj/item/clothing/glasses/hud/tajblind = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/engi_tajblind/New()
	..()
	blacklist += subtypesof(/obj/item/clothing/glasses/hud/tajblind)
	blacklist += subtypesof(/obj/item/clothing/glasses/meson)

/datum/crafting_recipe/engi_tajblind_removal
	name = "Tajaran engineering meson removal"
	result = list(/obj/item/clothing/glasses/meson, /obj/item/clothing/glasses/hud/tajblind)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/tajblind/meson = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/engi_tajblind_removal/New()
	..()
	blacklist += subtypesof(/obj/item/clothing/glasses/hud/tajblind/meson)

/datum/crafting_recipe/shaded_engi_tajblind
	name = "Shaded Tajaran engineering meson veil"
	result = list(/obj/item/clothing/glasses/hud/tajblind/shaded/meson)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/meson/sunglasses = 1,
				/obj/item/clothing/glasses/hud/tajblind = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/shaded_engi_tajblind/New()
	..()
	blacklist += subtypesof(/obj/item/clothing/glasses/hud/tajblind)

/datum/crafting_recipe/shaded_engi_tajblind_removal
	name = "Shaded Tajaran engineering meson veil removal"
	result = list(/obj/item/clothing/glasses/meson/sunglasses, /obj/item/clothing/glasses/hud/tajblind)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/tajblind/shaded/meson = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/shaded_engi_tajblind_removal/New()
	..()
	blacklist += subtypesof(/obj/item/clothing/glasses/hud/tajblind/shaded/meson)

/datum/crafting_recipe/cargo_tajblind
	name = "Tajaran mining meson veil"
	result = list(/obj/item/clothing/glasses/hud/tajblind/meson/cargo)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/meson = 1,
				/obj/item/clothing/glasses/hud/tajblind = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/cargo_tajblind/New()
	..()
	blacklist += subtypesof(/obj/item/clothing/glasses/hud/tajblind)
	blacklist += subtypesof(/obj/item/clothing/glasses/meson)

/datum/crafting_recipe/cargo_tajblind_removal
	name = "Tajaran mining meson veil removal"
	result = list(/obj/item/clothing/glasses/meson, /obj/item/clothing/glasses/hud/tajblind)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/tajblind/meson/cargo = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/shaded_cargo_tajblind
	name = "Shaded Tajaran mining meson veil"
	result = list(/obj/item/clothing/glasses/hud/tajblind/shaded/meson/cargo)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/meson/sunglasses = 1,
				/obj/item/clothing/glasses/hud/tajblind = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/shaded_cargo_tajblind/New()
	..()
	blacklist += subtypesof(/obj/item/clothing/glasses/hud/tajblind)

/datum/crafting_recipe/shaded_cargo_tajblind_removal
	name = "Shaded Tajaran mining meson veil removal"
	result = list(/obj/item/clothing/glasses/meson/sunglasses, /obj/item/clothing/glasses/hud/tajblind)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/tajblind/shaded/meson/cargo = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/sci_tajblind
	name = "Tajaran scientific veil"
	result = list(/obj/item/clothing/glasses/hud/tajblind/sci)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/science = 1,
				/obj/item/clothing/glasses/hud/tajblind = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/sci_tajblind/New()
	..()
	blacklist += subtypesof(/obj/item/clothing/glasses/hud/tajblind)

/datum/crafting_recipe/sci_tajblind_removal
	name = "Tajaran scientific veil removal"
	result = list(/obj/item/clothing/glasses/science, /obj/item/clothing/glasses/hud/tajblind)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/tajblind/sci = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/shaded_sci_tajblind
	name = "Shaded Tajaran scientific veil"
	result = list(/obj/item/clothing/glasses/hud/tajblind/shaded/sci)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/sunglasses/reagent = 1,
				/obj/item/clothing/glasses/hud/tajblind = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/shaded_sci_tajblind/New()
	..()
	blacklist += subtypesof(/obj/item/clothing/glasses/hud/tajblind)

/datum/crafting_recipe/shaded_sci_tajblind_removal
	name = "Shaded Tajaran scientific veil removal"
	result = list(/obj/item/clothing/glasses/sunglasses/reagent, /obj/item/clothing/glasses/hud/tajblind)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/tajblind/shaded/sci = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/med_tajblind
	name = "Tajaran medical veil"
	result = list(/obj/item/clothing/glasses/hud/tajblind/med)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/health = 1,
				/obj/item/clothing/glasses/hud/tajblind = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/med_tajblind/New()
	..()
	blacklist += subtypesof(/obj/item/clothing/glasses/hud/tajblind)
	blacklist += subtypesof(/obj/item/clothing/glasses/hud/health)

/datum/crafting_recipe/med_tajblind_removal
	name = "Tajaran medical veil removal"
	result = list(/obj/item/clothing/glasses/hud/health, /obj/item/clothing/glasses/hud/tajblind)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/tajblind/med = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/shaded_med_tajblind
	name = "Shaded Tajaran medical veil"
	result = list(/obj/item/clothing/glasses/hud/tajblind/shaded/med)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/health/sunglasses = 1,
				/obj/item/clothing/glasses/hud/tajblind = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/shaded_med_tajblind/New()
	..()
	blacklist += subtypesof(/obj/item/clothing/glasses/hud/tajblind)

/datum/crafting_recipe/shaded_med_tajblind_removal
	name = "Shaded Tajaran medical veil removal"
	result = list(/obj/item/clothing/glasses/hud/health/sunglasses, /obj/item/clothing/glasses/hud/tajblind)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/tajblind/shaded/med = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/sec_tajblind
	name = "Tajaran security veil"
	result = list(/obj/item/clothing/glasses/hud/tajblind/sec)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/security = 1,
				/obj/item/clothing/glasses/hud/tajblind = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/sec_tajblind/New()
	..()
	blacklist += subtypesof(/obj/item/clothing/glasses/hud/tajblind)
	blacklist += subtypesof(/obj/item/clothing/glasses/hud/security)

/datum/crafting_recipe/sec_tajblind_removal
	name = "Tajaran security veil removal"
	result = list(/obj/item/clothing/glasses/hud/security, /obj/item/clothing/glasses/hud/tajblind)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/tajblind/sec = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/shaded_sec_tajblind
	name = "Shaded Tajaran security veil"
	result = list(/obj/item/clothing/glasses/hud/tajblind/shaded/sec)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/security/sunglasses = 1,
				/obj/item/clothing/glasses/hud/tajblind = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/shaded_sec_tajblind/New()
	..()
	blacklist += subtypesof(/obj/item/clothing/glasses/hud/tajblind)

/datum/crafting_recipe/shaded_sec_tajblind_removal
	name = "Shaded Tajaran security veil removal"
	result = list(/obj/item/clothing/glasses/hud/security/sunglasses, /obj/item/clothing/glasses/hud/tajblind)
	time = 2 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_WIRECUTTER)
	reqs = list(/obj/item/clothing/glasses/hud/tajblind/shaded/sec = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/ghostsheet
	name = "Ghost Sheet"
	result = list(/obj/item/clothing/suit/ghost_sheet)
	time = 0.5 SECONDS
	tools = list(TOOL_WIRECUTTER)
	reqs = list(/obj/item/bedsheet = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/cowboyboots
	name = "Cowboy Boots"
	result = list(/obj/item/clothing/shoes/cowboy)
	time = 4.5 SECONDS
	reqs = list(/obj/item/stack/sheet/leather = 2)
	category = CAT_CLOTHING

/datum/crafting_recipe/lizardboots
	name = "Lizard Skin Boots"
	result = list(/obj/effect/spawner/random/lizardboots)
	time = 6 SECONDS
	reqs = list(/obj/item/stack/sheet/animalhide/lizard = 1, /obj/item/stack/sheet/leather = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/rubberduckyshoes
	name = "Rubber Ducky Shoes"
	result = list(/obj/item/clothing/shoes/ducky)
	time = 4.5 SECONDS
	tools = list(TOOL_WIRECUTTER)
	reqs = list(/obj/item/bikehorn/rubberducky = 2,
				/obj/item/clothing/shoes/sandal = 1)
	category = CAT_CLOTHING

/datum/crafting_recipe/salmonsuit
	name = "Salmon Suit"
	result = list(/obj/item/clothing/suit/hooded/salmon_costume)
	time = 6 SECONDS
	tools = list(TOOL_WIRECUTTER)
	reqs = list(/obj/item/fish/salmon = 20,
				/obj/item/stack/tape_roll = 5)
	pathtools = list(/obj/item/kitchen/knife)
	category = CAT_CLOTHING

/datum/crafting_recipe/voice_modulator
	name = "Voice Modulator Mask"
	result = list(/obj/item/clothing/mask/gas/voice_modulator)
	time = 4.5 SECONDS
	tools = list(TOOL_SCREWDRIVER, TOOL_MULTITOOL)
	reqs = list(/obj/item/clothing/mask/gas = 1,
				/obj/item/assembly/voice = 1,
				/obj/item/stack/cable_coil = 5)
	category = CAT_CLOTHING

/datum/crafting_recipe/flower_crown
	name = "Flower Crown"
	result = list(/obj/item/clothing/head/flower_crown)
	time = 2 SECONDS
	reqs = list(/obj/item/food/grown/poppy = 3,
				/obj/item/food/grown/lily = 3,
				/obj/item/grown/sunflower = 3)
	category = CAT_CLOTHING

/datum/crafting_recipe/sunflower_crown
	name = "Sunflower Crown"
	result = list(/obj/item/clothing/head/sunflower_crown)
	time = 2 SECONDS
	reqs = list(/obj/item/grown/sunflower = 5)
	category = CAT_CLOTHING

/datum/crafting_recipe/poppy_crown
	name = "Poppy Crown"
	result = list(/obj/item/clothing/head/poppy_crown)
	time = 2 SECONDS
	reqs = list(/obj/item/food/grown/poppy = 5)
	category = CAT_CLOTHING

/datum/crafting_recipe/lily_crown
	name = "Lily Crown"
	result = list(/obj/item/clothing/head/lily_crown)
	time = 2 SECONDS
	reqs = list(/obj/item/food/grown/lily = 5)
	category = CAT_CLOTHING

/datum/crafting_recipe/geranium_crown
	name = "Geranium Crown"
	result = list(/obj/item/clothing/head/geranium_crown)
	time = 2 SECONDS
	reqs = list(/obj/item/food/grown/geranium = 5)
	category = CAT_CLOTHING

#undef ALLOWED_INGREDIENT_SUNGLASSES
