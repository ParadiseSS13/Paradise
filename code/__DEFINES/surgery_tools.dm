// Order of the tools matters. The most specific path should go first. 
// /obj/item/stack/medical/bruise_pack/advanced should go before /obj/item/stack/medical/bruise_pack

#define SURGERY_TOOLS_INCISION list(/obj/item/scalpel = 100,		\
									/obj/item/kitchen/knife = 90,	\
									/obj/item/shard = 60, 		\
									/obj/item/scissors = 12,		\
									/obj/item/twohanded/chainsaw = 1, \
									/obj/item/claymore = 6, \
									/obj/item/melee/energy/ = 6, \
									/obj/item/pen/edagger = 6)

#define SURGERY_TOOLS_CLAMP 	list(/obj/item/scalpel/laser = 100, \
									/obj/item/hemostat = 100,	\
									/obj/item/stack/cable_coil = 90, 	\
									/obj/item/assembly/mousetrap = 25)

#define SURGERY_TOOLS_RETRACT_SKIN 	list(/obj/item/scalpel/laser/manager = 100, \
										/obj/item/retractor = 100, 	\
										/obj/item/crowbar = 90,	\
										/obj/item/kitchen/utensil/fork = 60)

#define SURGERY_TOOLS_CAUTERIZE		list(/obj/item/scalpel/laser = 100, \
										/obj/item/cautery = 100,			\
										/obj/item/clothing/mask/cigarette = 90,	\
										/obj/item/lighter = 60,			\
										/obj/item/weldingtool = 30)

#define SURGERY_TOOLS_RETRACT_BONE	list(/obj/item/scalpel/laser/manager = 100, \
										/obj/item/retractor = 100, 	\
										/obj/item/crowbar = 90)

#define SURGERY_TOOLS_SAW_BONE		list(/obj/item/circular_saw = 100, \
										/obj/item/melee/energy/sword/cyborg/saw = 100, \
										/obj/item/hatchet = 90)

#define SURGERY_TOOLS_DRILL			list(/obj/item/surgicaldrill = 100, \
										/obj/item/pickaxe/drill = 60, \
										/obj/item/mecha_parts/mecha_equipment/drill = 60, \
										 /obj/item/screwdriver = 20)

#define SURGERY_TOOLS_AMPUTATE		list(/obj/item/circular_saw = 100, \
										/obj/item/melee/energy/sword/cyborg/saw = 100, \
										/obj/item/hatchet = 90, \
										/obj/item/melee/arm_blade = 75)

#define SURGERY_TOOLS_MEND_BONES	list(/obj/item/bonegel = 100,	\
										/obj/item/screwdriver = 90)

#define SURGERY_TOOLS_SET_BONES		list(/obj/item/bonesetter = 100,	\
										/obj/item/wrench = 90)

#define SURGERY_TOOLS_MAKE_CAVITY	list(/obj/item/surgicaldrill = 100,	\
										/obj/item/pen = 90,	\
										/obj/item/stack/rods = 60)

#define SURGERY_TOOLS_EXTRACT_IMPLANT	list(/obj/item/hemostat = 100, /obj/item/crowbar = 65)

#define SURGERY_TOOLS_CONNECT_LIMB 	list(/obj/item/hemostat = 100,	\
										/obj/item/stack/cable_coil = 90, \
										/obj/item/assembly/mousetrap = 25)

#define SURGERY_TOOLS_EXTRACT_ORGAN	list(/obj/item/hemostat = 100, /obj/item/kitchen/utensil/fork = 70)

#define SURGERY_TOOLS_HEAL_ORGAN	list(/obj/item/stack/medical/bruise_pack/advanced = 100, /obj/item/stack/medical/bruise_pack = 20, /obj/item/stack/nanopaste = 100)

#define SURGERY_TOOLS_CLEAN_ORGAN	list(/obj/item/reagent_containers/dropper = 100, \
										/obj/item/reagent_containers/syringe = 100, \
										/obj/item/reagent_containers/glass/bottle = 90, \
										/obj/item/reagent_containers/food/drinks/drinkingglass = 85, \
										/obj/item/reagent_containers/food/drinks/bottle = 80, \
										/obj/item/reagent_containers/glass/beaker = 75, \
										/obj/item/reagent_containers/spray = 60, \
										/obj/item/reagent_containers/glass/bucket = 50)

#define SURGERY_TOOLS_MEND_INTERNAL_BLEEDING 	list(/obj/item/FixOVein = 100, \
													/obj/item/stack/cable_coil = 90)

#define SURGERY_TOOLS_DETHRALL		list(/obj/item/flash = 100, /obj/item/flashlight/pen = 80, /obj/item/flashlight = 40)

#define SURGERY_TOOLS_RESHAPE_FACE	list(/obj/item/scalpel = 100, /obj/item/kitchen/knife = 50, /obj/item/wirecutters = 35)

#define SURGERY_TOOLS_RIGSUIT_CUT	list(/obj/item/weldingtool = 80, \
										/obj/item/circular_saw = 60, \
										/obj/item/gun/energy/plasmacutter = 100)

#define SURGERY_TOOLS_UNSCREW_HATCH	list(/obj/item/screwdriver = 100, \
										/obj/item/coin = 50, \
										/obj/item/kitchen/knife = 50)

#define SURGERY_TOOLS_OPEN_CLOSE_HATCH	list(/obj/item/retractor = 100, \
										/obj/item/crowbar = 100, \
										/obj/item/kitchen/utensil/ = 50)

#define SURGERY_TOOLS_ROBOTIC_REPAIR	list(/obj/item/stack/cable_coil = 100, \
											/obj/item/weldingtool = 100, \
											/obj/item/gun/energy/plasmacutter = 50)

#define SURGERY_TOOLS_ROBOTIC_REMOVE_ORGAN	list(/obj/item/multitool = 100)

#define SURGERY_TOOLS_ROBOTIC_MEND_ORGAN	list(/obj/item/stack/nanopaste = 100,/obj/item/bonegel = 30, /obj/item/screwdriver = 70)

#define SURGERY_TOOLS_ROBOTIC_REPORGRAM		list(/obj/item/multitool = 100)
