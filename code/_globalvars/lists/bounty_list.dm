// ADDING A NEW BOUNTY
// new /datum/supply_bounty(TYPE, IS_EXACT, QUANTITY, REWARD, EXTRA REWARD)
#define SUPPLY_BOUNTY_QUANTITY_ONE 1
#define SUPPLY_BOUNTY_QUANTITY_LOW 3
#define SUPPLY_BOUNTY_QUANTITY_MEDIUM 5
#define SUPPLY_BOUNTY_QUANTITY_HIGH 10
#define SUPPLY_BOUNTY_QUANTITY_BULK 25

#define SUPPLY_BOUNTY_REWARD_CHEAP 25
#define SUPPLY_BOUNTY_REWARD_LOW 50
#define SUPPLY_BOUNTY_REWARD_MEDIUM 75
#define SUPPLY_BOUNTY_REWARD_HIGH 100
#define SUPPLY_BOUNTY_REWARD_GRAND 200
/// List of all bounty datums.
GLOBAL_LIST_INIT(supply_bounties, list(
	/// GENERAL
	new /datum/supply_bounty(/obj/item/folder, 				FALSE, 			SUPPLY_BOUNTY_QUANTITY_MEDIUM, 		SUPPLY_BOUNTY_REWARD_LOW),
	new /datum/supply_bounty(/obj/item/pen, 				FALSE, 			SUPPLY_BOUNTY_QUANTITY_MEDIUM, 		SUPPLY_BOUNTY_REWARD_LOW),
	new /datum/supply_bounty(/obj/item/paper_bin, 			FALSE, 			SUPPLY_BOUNTY_QUANTITY_LOW, 		SUPPLY_BOUNTY_REWARD_MEDIUM),
	new /datum/supply_bounty(/obj/item/stamp/granted, 		FALSE, 			SUPPLY_BOUNTY_QUANTITY_ONE, 		SUPPLY_BOUNTY_REWARD_MEDIUM),
	new /datum/supply_bounty(/obj/item/stamp/denied, 		FALSE, 			SUPPLY_BOUNTY_QUANTITY_ONE, 		SUPPLY_BOUNTY_REWARD_MEDIUM),
	new /datum/supply_bounty(/obj/item/toner, 				FALSE, 			SUPPLY_BOUNTY_QUANTITY_LOW, 		SUPPLY_BOUNTY_REWARD_MEDIUM),

	// SUPPLY
	new /datum/supply_bounty(/obj/item/wrench, 				TRUE, 			SUPPLY_BOUNTY_QUANTITY_HIGH, 		SUPPLY_BOUNTY_REWARD_CHEAP),
	new /datum/supply_bounty(/obj/item/crowbar, 			TRUE, 			SUPPLY_BOUNTY_QUANTITY_HIGH, 		SUPPLY_BOUNTY_REWARD_CHEAP),
	new /datum/supply_bounty(/obj/item/screwdriver, 		TRUE, 			SUPPLY_BOUNTY_QUANTITY_HIGH, 		SUPPLY_BOUNTY_REWARD_CHEAP),
	new /datum/supply_bounty(/obj/item/wirecutters, 		TRUE, 			SUPPLY_BOUNTY_QUANTITY_HIGH, 		SUPPLY_BOUNTY_REWARD_CHEAP),
	new /datum/supply_bounty(/obj/item/multitool, 			TRUE, 			SUPPLY_BOUNTY_QUANTITY_HIGH, 		SUPPLY_BOUNTY_REWARD_LOW),
	new /datum/supply_bounty(/obj/item/wrench,				TRUE,			SUPPLY_BOUNTY_QUANTITY_HIGH,		SUPPLY_BOUNTY_REWARD_CHEAP),

	// SERVICE


	// SCIENCE


	// MEDICAL
	new /datum/medical_bounty(obj/item/scalpel, 			FALSE,			SUPPLY_BOUNTY_QUANTITY_LOW,			SUPPLY_BOUNTY_REWARD_CHEAP),
	new /datum/medical_bounty(obj/item/cautery,				TRUE, 			SUPPLY_BOUNTY_QUANTITY_LOW, 		SUPPLY_BOUNTY_REWARD_LOW),
	new /datum/medical_bounty(obj/item/hemostat,			TRUE,			SUPPLY_BOUNTY_QUANTITY_LOW,			SUPPLY_BOUNTY_REWARD_LOW),
	new /datum/medical_bounty(obj/item/retractor,			TRUE,			SUPPLY_BOUNTY_QUANTITY_LOW,			SUPPLY_BOUNTY_REWARD_LOW),
	new /datum/medical_bounty(obj/item/fix_o_vein,			TRUE,			SUPPLY_BOUNTY_QUANTITY_LOW,			SUPPLY_BOUNTY_REWARD_LOW),
	new /datum/medical_bounty(obj/item/surgicaldrill,		TRUE,			SUPPLY_BOUNTY_QUANTITY_LOW,			SUPPLY_BOUNTY_REWARD_LOW),
	new /datum/medical_bounty(obj/item/circular_saw,		TRUE,			SUPPLY_BOUNTY_QUANTITY_LOW, 		SUPPLY_BOUNTY_REWARD_LOW),
	new /datum/medical_bounty(obj/item/bonegel,				TRUE,			SUPPLY_BOUNTY_QUANTITY_LOW,			SUPPLY_BOUNTY_REWARD_LOW),
	new /datum/medical_bounty(obj/item/bonesetter,			TRUE,			SUPPLY_BOUNTY_QUANTITY_LOW,			SUPPLY_BOUNTY_REWARD_LOW),
	new /datum/medical_bounty(obj/item/dissector,			TRUE,			SUPPLY_BOUNTY_QUANTITY_LOW,			SUPPLY_BOUNTY_REWARD_LOW),
	new /datum/medical_bounty(obj/item/surgical_drapes,		TRUE,			SUPPLY_BOUNTY_QUANTITY_LOW,			SUPPLY_BOUNTY_REWARD_LOW),
	new /datum/medical_bounty(obj/item/stack/medical/burn_pack	TRUE		SUPPLY_BOUNTY_QUANTITY_MEDIUM,		SUPPLY_BOUNTY_REWARD_MEDIUM),
	new /datum/medical_bounty(obj/item/stack/medical/bruise_pack	TRUE	SUPPLY_BOUNTY_QUANTITY_MEDIUM,
	new /datum/medical_bounty(obj/item/stack/medical/ointment		TRUE	SUPPLY_BOUNTY_QUANTITY_MEDIUM,
	new /datum/medical_bounty(obj/item/reagent_containers/syringe/charcoal		TRUE
	new /datum/medical_bounty(obj/item/reagent_containers/hypospray/autoinjector/epinephrine
	new /datum/medical_bounty(obj/item/stack/medical/splint		TRUE		SUPPLY_BOUNTY_QUANTITY_HIGH,		SUPPLY_BOUNTY_REWARD_CHEAP),
	new /datum/medical_bounty(obj/item/reagent_containers/hypospray/autoinjector/epinephrine
	new /datum/medical_bounty(obj/item/stack/medical/bruise_pack/advanced
	new /datum/medical_bounty(obj/item/stack/medical/ointment/advanced
	new /datum/medical_bounty(obj/item/reagent_containers/patch/styptic
	new /datum/medical_bounty(obj/item/reagent_containers/patch/silver_sulf
	new /datum/medical_bounty(obj/item/stack/medical/suture
	new /datum/medical_bounty(obj/item/stack/medical/suture/emergency
	new /datum/medical_bounty(obj/item/stack/medical/suture/medicated
	new /datum/medical_bounty(obj/item/stack/medical/suture/regen_mesh/advanced
	new /datum/medical_bounty(obj/item/stack/medical/suture/regen_mesh
	new /datum/medical_bounty(obj/item/reagent_containers/syringe
	new /datum/medical_bounty(obj/item/reagent_containers/glass/beaker
	new /datum/medical_bounty(obj/item/reagent_containers/dropper
	new /datum/medical_bounty(obj/item/reagent_containers/hypospray/safety
	new /datum/medical_bounty(obj/item/healthanalyzer/advanced
	new /datum/medical_bounty(obj/item/healthanalyzer
	new /datum/medical_bounty(obj/item/sensor_device
	new /datum/medical_bounty(obj/item/pinpointer/crew



	// SECURITY
	new /datum/security_bounty(obj/item/melee/baton,		TRUE,			SUPPLY_BOUNTY_QUANTITY_LOW,			SUPPLY_BOUNTY_REWARD_MEDIUM),
	new /datum/security_bounty(obj/item/restraint/handcuffs,	TRUE,		SUPPLY_BOUNTY_QUANTITY_HIGH,		SUPPLY_BOUNTY_REWARD_CHEAP),

))

#undef SUPPLY_BOUNTY_QUANTITY_ONE
#undef SUPPLY_BOUNTY_QUANTITY_LOW
#undef SUPPLY_BOUNTY_QUANTITY_MEDIUM
#undef SUPPLY_BOUNTY_QUANTITY_HIGH
#undef SUPPLY_BOUNTY_QUANTITY_BULK

#undef SUPPLY_BOUNTY_REWARD_CHEAP
#undef SUPPLY_BOUNTY_REWARD_LOW
#undef SUPPLY_BOUNTY_REWARD_MEDIUM
#undef SUPPLY_BOUNTY_REWARD_HIGH
#undef SUPPLY_BOUNTY_REWARD_GRAND
