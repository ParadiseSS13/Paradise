//ENGINEERING TOOLS

/obj/item/crowbar/abductor
	name = "alien crowbar"
	desc = "A hard-light crowbar. It appears to pry by itself, without any effort required."
	icon = 'icons/obj/abductor.dmi'
	usesound = 'sound/weapons/sonic_jackhammer.ogg'
	icon_state = "crowbar"
	toolspeed = 0.1
	origin_tech = "combat=4;engineering=4;abductor=3"

/obj/item/multitool/abductor
	name = "alien multitool"
	desc = "An omni-technological interface."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "multitool"
	toolspeed = 0.1
	origin_tech = "magnets=5;engineering=5;abductor=3"

/obj/item/multitool/abductor/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SHOW_WIRE_INFO, ROUNDSTART_TRAIT)

/obj/item/screwdriver/abductor
	name = "alien screwdriver"
	desc = "An ultrasonic screwdriver."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "screwdriver"
	usesound = 'sound/items/pshoom.ogg'
	toolspeed = 0.1
	random_color = FALSE

/obj/item/weldingtool/abductor
	name = "alien welding tool"
	desc = "An alien welding tool. Whatever fuel it uses, it never runs out."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "welder"
	toolspeed = 0.1
	light_intensity = 0
	origin_tech = "plasmatech=5;engineering=5;abductor=3"
	requires_fuel = FALSE
	refills_over_time = TRUE
	low_fuel_changes_icon = FALSE

/obj/item/wirecutters/abductor
	name = "alien wirecutters"
	desc = "Extremely sharp wirecutters, made out of a silvery-green metal."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "cutters"
	toolspeed = 0.1
	origin_tech = "materials=5;engineering=4;abductor=3"
	random_color = FALSE

/obj/item/wirecutters/abductor/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SHOW_WIRE_INFO, ROUNDSTART_TRAIT)

/obj/item/wrench/abductor
	name = "alien wrench"
	desc = "A polarized wrench. It causes anything placed between the jaws to turn."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "wrench"
	usesound = 'sound/effects/empulse.ogg'
	toolspeed = 0.1
	origin_tech = "materials=5;engineering=5;abductor=3"

//SURGERY TOOLS

/obj/item/scalpel/alien
	name = "alien scalpel"
	desc = "It's a gleaming sharp knife made out of silvery-green metal."
	icon = 'icons/obj/abductor.dmi'
	origin_tech = "materials=2;biotech=2;abductor=2"
	toolspeed = 0.25

/obj/item/hemostat/alien
	name = "alien hemostat"
	desc = "You've never seen this before."
	icon = 'icons/obj/abductor.dmi'
	origin_tech = "materials=2;biotech=2;abductor=2"
	toolspeed = 0.25

/obj/item/retractor/alien
	name = "alien retractor"
	desc = "You're not sure if you want the veil pulled back."
	icon = 'icons/obj/abductor.dmi'
	origin_tech = "materials=2;biotech=2;abductor=2"
	toolspeed = 0.25

/obj/item/circular_saw/alien
	name = "alien saw"
	desc = "Do the aliens also lose this, and need to find an alien hatchet?"
	icon = 'icons/obj/abductor.dmi'
	origin_tech = "materials=2;biotech=2;abductor=2"
	toolspeed = 0.25

/obj/item/surgicaldrill/alien
	name = "alien drill"
	desc = "Maybe alien surgeons have finally found a use for the drill."
	icon = 'icons/obj/abductor.dmi'
	origin_tech = "materials=2;biotech=2;abductor=2"
	toolspeed = 0.25

/obj/item/cautery/alien
	name = "alien cautery"
	desc = "Why would bloodless aliens have a tool to stop bleeding? Unless..."
	icon = 'icons/obj/abductor.dmi'
	origin_tech = "materials=2;biotech=2;abductor=2"
	toolspeed = 0.25

/obj/item/bonegel/alien
	name = "alien bone gel"
	desc = "It smells like duct tape."
	icon = 'icons/obj/abductor.dmi'
	origin_tech = "materials=2;biotech=2;abductor=2"
	toolspeed = 0.25

/obj/item/FixOVein/alien
	name = "alien FixOVein"
	desc = "Bloodless aliens would totally know how to stop internal bleeding...right?"
	icon = 'icons/obj/abductor.dmi'
	origin_tech = "materials=2;biotech=2;abductor=2"
	toolspeed = 0.25

/obj/item/bonesetter/alien
	name = "alien bone setter"
	desc = "You're not sure you want to know whether or not aliens have bones."
	icon = 'icons/obj/abductor.dmi'
	origin_tech = "materials=2;biotech=2;abductor=2"
	toolspeed = 0.25
