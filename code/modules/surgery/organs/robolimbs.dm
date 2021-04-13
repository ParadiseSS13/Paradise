GLOBAL_LIST_EMPTY(all_robolimbs)
GLOBAL_LIST_EMPTY(chargen_robolimbs)
GLOBAL_LIST_EMPTY(selectable_robolimbs)
GLOBAL_DATUM(basic_robolimb, /datum/robolimb)


#define model        0	// Model = This iconset contains ONLY a monitor and is a subtypeof a Brand
#define brand        1	// Brand = This iconset contains all body parts (including a monitor) and there are other monitor Models for this type/Brand
#define childless    2	// Childless = This iconset contains all body parts (including a monitor). There are no other monitor Models for this type
/datum/robolimb
	var/company = "Unbranded"								// Shown when selecting the limb. Dio Unbrando.
	var/desc = "A generic unbranded robotic prosthesis."	// Seen when examining a limb.
	var/icon = 'icons/mob/human_races/robotic.dmi'			// Icon base to draw from.
	var/unavailable_at_chargen = FALSE						// If TRUE, not available at chargen.
	var/selectable = TRUE	// If set, is it available for selection on attack_self with a robo limb?
	var/is_monitor			// If set, limb is a monitor and CANNOT USE HAIR. See ipc_face and ipc_optics for how hair and facial accessories work for IPCs.
	var/has_subtypes = childless
	var/parts = list("chest", "groin", "head", "r_arm", "r_hand", "r_leg", "r_foot", "l_leg", "l_foot", "l_arm", "l_hand")	// Defines what parts said brand can replace on a body.


/*
	/* Robo Company Name */
	// Body Parts Sprite File name
	/datum/robolimb/companyname
		company = (how you want the limb names to appear)
		desc = (description of the limbs)
		icon = (the .dmi file path)
		has_subtypes = (use this to override childless - see #defines above)
		is_monitor = (TRUE if the monitor/head sprite uses a SCREEN | FALSE means no screen and then the IPC monitor - see ipc_face.dm)
		unavailable_at_chargen = (use this to override FALSE - see preferences.dm)

	/datum/robolimb/companyname/monitorname -- Used for Additional Monitor Sprites
		company = (how you want this alternative monitor name to appear)
		icon = (the .dmi file path)
		parts = list("head")	(use this to override the parts list so that it will only appear in the "head" menu in chargen)
		has_subtypes = model	(it's monitor model!)
		is_monitor = (TRUE if the monitor/head sprite uses a SCREEN | FALSE means no screen - see ipc_face.dm)
		selectable = FALSE	(use this override TRUE [up to you!] - see robo_parts.dm)
		unavailable_at_chargen = (use this to override FALSE - see preferences.dm)
*/


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
	selectable = FALSE

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
	selectable = TRUE	// Let 'em the cheap stuff

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

/* Zenghu */
//Zenghu - Main
/datum/robolimb/zenghu
	company = "Zeng-Hu Pharmaceuticals"
	desc = "This limb has a rubbery fleshtone covering with visible seams."
	icon = 'icons/mob/human_races/cyberlimbs/zenghu/zenghu_main.dmi'
	has_subtypes = childless
	// Zeng-Hu Pharm is fairly human-looking, so we're going to make this unavailable at chargen. This is inheriting selectable = TRUE, see robo_parts.dm
	unavailable_at_chargen = TRUE

//Zenghu - Spirit
/datum/robolimb/spirit
	company = "Zeng-Hu Spirit"
	desc = "This limb has a sleek black-and-white polymer finish."
	icon = 'icons/mob/human_races/cyberlimbs/zenghu/zenghu_spirit.dmi'
	has_subtypes = childless

#undef model
#undef brand
#undef childless
