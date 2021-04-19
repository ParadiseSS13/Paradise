GLOBAL_LIST_EMPTY(all_robolimbs)
GLOBAL_LIST_EMPTY(chargen_robolimbs)
GLOBAL_LIST_EMPTY(selectable_robolimbs)
GLOBAL_DATUM(basic_robolimb, /datum/robolimb)


///Model = This iconset contains ONLY a monitor and is a subtypeof a Brand
#define model        0
///Brand = This iconset contains all body parts (including a monitor) and there are other monitor Models for this type/Brand
#define brand        1
//Childless = This iconset contains all body parts (including a monitor). There are no other monitor Models for this type
#define childless    2

/datum/robolimb
	///The name shown when selecting the limb(s) from a menu.
	var/company = "Unbranded"
	///The description of the limb(s) that appears when you examine one.
	var/desc = "A generic unbranded robotic prosthesis."
	///The .dmi file path of the icon base.
	var/icon = 'icons/mob/human_races/robotic.dmi'
	///Whether the robolimb is unavailable when setting up a character. Defaults to FALSE.
	var/unavailable_at_chargen = FALSE
	///Which Species can choose these Robolimbs at CharGen
	var/list/species_allowed = list("Machine", "Human", "Skrell", "Unathi", "Drask", "Wryn", "Tajaran", "Vox", "Vulpkanin", "Tajaran", "Nucleation", "Diona", "Slime People", "Plasmamen", "Grey")
	///Whether the limb type is available for selection via attack_self with a robolimb - see robo_parts Defaults to TRUE.
	var/selectable = TRUE
	///Does this iconset contain a head sprite with a screen? If TRUE, head sprite cannot use hair and instead uses ipc_face.
	var/is_monitor
	///Which of the following types is this robolimb: model, brand, or childless?
	var/has_subtypes = childless
	///The list of body parts that are contained in the iconset
	var/parts = list("chest", "groin", "head", "r_arm", "r_hand", "r_leg", "r_foot", "l_leg", "l_foot", "l_arm", "l_hand")


/* Bishop */
//Main
/datum/robolimb/bishop
	company = "Bishop Cybernetics"
	desc = "This limb has a white polymer casing with blue holo-displays."
	icon = 'icons/mob/human_races/cyberlimbs/bishop/bishop_main.dmi'
	has_subtypes = brand

/datum/robolimb/bishop/monitor
	company = "Bishop Knight"
	icon = 'icons/mob/human_races/cyberlimbs/bishop/bishop_alt1.dmi'
	parts = list("head")
	has_subtypes = model
	is_monitor = TRUE
	selectable = FALSE

//Rook
/datum/robolimb/rook
	company = "Bishop Rook"
	desc = "This limb has a polished metallic casing."
	icon = 'icons/mob/human_races/cyberlimbs/bishop/bishop_rook.dmi'
	has_subtypes = brand

/datum/robolimb/rook/monitor
	company = "Bishop Castle"
	icon = 'icons/mob/human_races/cyberlimbs/bishop/bishop_monitor.dmi'
	parts = list("head")
	has_subtypes = model
	is_monitor = TRUE
	selectable = FALSE

/* Hesphiastos */
//Main
/datum/robolimb/hesphiastos
	company = "Hesphiastos Industries"
	desc = "This limb has a militaristic black-and-green casing with gold stripes."
	icon = 'icons/mob/human_races/cyberlimbs/hesphiastos/hesphiastos_main.dmi'
	has_subtypes = brand

/datum/robolimb/hesphiastos/monitor
	company ="Industrial Revolution"
	icon = 'icons/mob/human_races/cyberlimbs/hesphiastos/hesphiastos_monitor.dmi'
	parts = list("head")
	has_subtypes = model
	is_monitor = TRUE
	selectable = FALSE

//Titan
/datum/robolimb/titan
	company = "Hesphiastos Titan"
	desc = "This limb has an olive drab casing, providing a reinforced housing look."
	icon = 'icons/mob/human_races/cyberlimbs/hesphiastos/hesphiastos_titan.dmi'
	has_subtypes = brand
	species_allowed = list("Machine")

/datum/robolimb/titan/monitor
	company = "Titan Enforcer"
	icon = 'icons/mob/human_races/cyberlimbs/hesphiastos/hesphiastos_alt1.dmi'
	parts = list("head")
	has_subtypes = model
	is_monitor = TRUE
	selectable = FALSE

/* Morpheus */
//Main
/datum/robolimb/morpheus
	// This is the Default IPC loadout
	company = "Morpheus Cyberkinetics"
	desc = "This limb is simple and functional; no effort has been made to make it look human."
	icon = 'icons/mob/human_races/cyberlimbs/morpheus/morpheus_main.dmi'
	has_subtypes = brand
	is_monitor = TRUE	// Because this one has a SCREEN - it needs to use ipc_face.dm instead of using HAIR.

/datum/robolimb/morpheus/monitor
	company = "Cyberkinetics Sport"
	icon = 'icons/mob/human_races/cyberlimbs/morpheus/morpheus_alt1.dmi'
	parts = list("head")
	has_subtypes = model
	is_monitor = TRUE
	selectable = TRUE	// Both the parent (brand) and the child (model) have monitors with screens, therefore this "head" should be selectable.

//Mantis
/datum/robolimb/mantis
	company = "Morpheus Mantis"
	desc = "This limb has a sleek black metal casing with an innovative insectile design."
	icon = 'icons/mob/human_races/cyberlimbs/morpheus/morpheus_mantis.dmi'
	has_subtypes = brand

/datum/robolimb/mantis/monitor
	company = "Morpheus Blitz"
	icon = 'icons/mob/human_races/cyberlimbs/morpheus/morpheus_blitz.dmi'
	parts = list("head")
	has_subtypes = model
	is_monitor = TRUE
	selectable = FALSE

/* Nanotrasen */
/datum/robolimb/nanotrasen
	company = "Nanotrasen Modular Mechanics"
	desc = "This limb is made from a cheap polymer."
	icon = 'icons/mob/human_races/cyberlimbs/nanotrasen/nanotrasen_main.dmi'
	has_subtypes = childless
	is_monitor = TRUE

/*Robo Vox */
//Main
/datum/robolimb/robovox
	company = "Vox"
	desc = "This limb is cybernetic and looks like like it would only fit a Vox Primalis."
	icon = 'icons/mob/human_races/cyberlimbs/robovox/main.dmi'
	has_subtypes = childless
	selectable = FALSE
	// The only robolimbs for Vox at Chargen
	species_allowed = list("Vox")

/* Shellguard */
//Main
/datum/robolimb/shellguard
	company = "Shellguard Munitions"
	desc = "This limb features exposed robust steel, painted to match Shellguard's motifs."
	icon = 'icons/mob/human_races/cyberlimbs/shellguard/shellguard_main.dmi'
	has_subtypes = brand

/datum/robolimb/shellguard/monitor
	company = "Shellguard Munitions Standard Series"
	icon = 'icons/mob/human_races/cyberlimbs/shellguard/shellguard_monitor.dmi'
	parts = list("head")
	has_subtypes = model
	is_monitor = TRUE
	selectable = FALSE

//Elite
/datum/robolimb/shellguard/alt1
	company = "Shellguard Munitions Elite Series"
	icon = 'icons/mob/human_races/cyberlimbs/shellguard/shellguard_alt1.dmi'
	parts = list("head")
	has_subtypes = model
	is_monitor = TRUE
	selectable = FALSE

/* Vey-Med */
//Main
/datum/robolimb/veymed
	company = "Vey-Med"
	desc = "This replacement human limb is nearly indistringuishable from an organic one; maybe it was grown in a lab?"
	icon = 'icons/mob/human_races/cyberlimbs/veymed/veymed_main.dmi'
	has_subtypes = childless
	selectable = FALSE
	// Only available for Humans and at Chargen
	species_allowed = list("Human")


/* Ward Takahashi */
//Main
/datum/robolimb/wardtakahashi
	company = "Ward-Takahashi"
	desc = "This limb features sleek black and white polymers."
	icon = 'icons/mob/human_races/cyberlimbs/wardtakahashi/wardtakahashi_main.dmi'
	has_subtypes = brand

/datum/robolimb/wardtakahashi/monitor
	company = "Ward-Takahashi Classic"
	icon = 'icons/mob/human_races/cyberlimbs/wardtakahashi/wardtakahashi_monitor.dmi'
	parts = list("head")
	has_subtypes = model
	is_monitor = TRUE
	selectable = FALSE

//Economy
/datum/robolimb/wardeconomy
	company = "Ward-Takahashi Efficiency"
	desc = "This simple, robotic limb with a retro design seems rather stiff."
	icon = 'icons/mob/human_races/cyberlimbs/wardtakahashi/wardtakahashi_economy.dmi'
	has_subtypes = brand

/datum/robolimb/wardeconomy/monitor
	company = "Alternative Efficiency"
	icon = 'icons/mob/human_races/cyberlimbs/wardtakahashi/wardtakahashi_alt1.dmi'
	parts = list("head")
	has_subtypes = model
	is_monitor = TRUE
	selectable = FALSE

/* Xion */
//Main
/datum/robolimb/xion
	company = "Xion Manufacturing Group"
	desc = "This limb has a minimalist black and red casing."
	icon = 'icons/mob/human_races/cyberlimbs/xion/xion_main.dmi'
	has_subtypes = brand

/datum/robolimb/xion/monitor
	company = "Xion Original"
	icon = 'icons/mob/human_races/cyberlimbs/xion/xion_monitor.dmi'
	parts = list("head")
	has_subtypes = model
	is_monitor = TRUE
	selectable = FALSE

//Economy
/datum/robolimb/xioneconomy
	company = "Xion Economy"
	desc = "This mechanical limb is skeletal and has a minimalistic black-and-red casing."
	icon = 'icons/mob/human_races/cyberlimbs/xion/xion_econo.dmi'
	has_subtypes = brand

/datum/robolimb/xioneconomy/monitor
	company = "Economy Standard"
	icon = 'icons/mob/human_races/cyberlimbs/xion/xion_alt1.dmi'
	parts = list("head")
	has_subtypes = model
	is_monitor = TRUE
	selectable = FALSE


/* Zenghu */
//Zenghu - Main
/datum/robolimb/zenghu
	company = "Zeng-Hu Pharmaceuticals"
	desc = "This limb has a rubbery fleshtone covering with visible seams."
	icon = 'icons/mob/human_races/cyberlimbs/zenghu/zenghu_main.dmi'
	has_subtypes = childless

//Zenghu - Spirit
/datum/robolimb/spirit
	company = "Zeng-Hu Spirit"
	desc = "This limb has a sleek black-and-white polymer finish."
	icon = 'icons/mob/human_races/cyberlimbs/zenghu/zenghu_spirit.dmi'
	has_subtypes = childless
	selectable = FALSE
	// Only available for IPCs and at Chargen
	species_allowed = list("Machine")

#undef model
#undef brand
#undef childless
