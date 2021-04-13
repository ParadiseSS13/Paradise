GLOBAL_LIST_EMPTY(all_robolimbs)
GLOBAL_LIST_EMPTY(chargen_robolimbs)
GLOBAL_LIST_EMPTY(selectable_robolimbs)
GLOBAL_DATUM(basic_robolimb, /datum/robolimb)


#define model        0
#define brand        1
#define childless    2
/datum/robolimb
	var/company = "Unbranded"								// Shown when selecting the limb. Dio Unbrando.
	var/desc = "A generic unbranded robotic prosthesis."	// Seen when examining a limb.
	var/icon = 'icons/mob/human_races/robotic.dmi'			// Icon base to draw from.
	var/unavailable_at_chargen = FALSE						// If TRUE, not available at chargen.
	var/selectable = TRUE	// If set, is it available for selection on attack_self with a robo limb?
							// This also affects character set up. Setting everything to TRUE by default. If we want to change this, let me know (Iren / Kiyahitayika)
	var/is_monitor			// If set, limb is a monitor and should be getting monitor styles.
	// If 0, object is a model. If 1, object is a brand (that serves as the default model) with child models. If 2, object is a brand that has no child models and thus also serves as the model..
	var/has_subtypes = childless
	var/parts = list("chest", "groin", "head", "r_arm", "r_hand", "r_leg", "r_foot", "l_leg", "l_foot", "l_arm", "l_hand")	// Defines what parts said brand can replace on a body.

/* Nanotrasen */
/datum/robolimb/nanotrasen
	company = "Nanotrasen Modular Mechanics"
	desc = "This limb is made from a cheap polymer."
	icon = 'icons/mob/human_races/cyberlimbs/nanotrasen/nanotrasen_main.dmi'
	has_subtypes = childless
	is_monitor = TRUE

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


//Rook
/datum/robolimb/rook
	company = "Bishop Rook"
	desc = "This limb has a polished metallic casing and a holographic face emitter."
	icon = 'icons/mob/human_races/cyberlimbs/bishop/bishop_rook.dmi'
	has_subtypes = brand

/datum/robolimb/rook/monitor
	company = "Bishop Castle"
	icon = 'icons/mob/human_races/cyberlimbs/bishop/bishop_monitor.dmi'
	parts = list("head")
	has_subtypes = model
	is_monitor = TRUE

/* Hesphiastos */
//Main
/datum/robolimb/hesphiastos
	company = "Hesphiastos Industries"
	desc = "This limb has a militaristic black and green casing with gold stripes."
	icon = 'icons/mob/human_races/cyberlimbs/hesphiastos/hesphiastos_main.dmi'
	has_subtypes = brand

/datum/robolimb/hesphiastos/monitor
	company ="Industrial Revolution"
	icon = 'icons/mob/human_races/cyberlimbs/hesphiastos/hesphiastos_monitor.dmi'
	parts = list("head")
	has_subtypes = model
	is_monitor = TRUE

//Titan
/datum/robolimb/titan
	company = "Hesphiastos Titan"
	desc = "This limb has a casing of an olive drab finish, providing a reinforced housing look."
	icon = 'icons/mob/human_races/cyberlimbs/hesphiastos/hesphiastos_titan.dmi'
	has_subtypes = brand

/datum/robolimb/titan/monitor
	company = "Titan Enforcer"
	icon = 'icons/mob/human_races/cyberlimbs/hesphiastos/hesphiastos_alt1.dmi'
	parts = list("head")
	has_subtypes = model
	is_monitor = TRUE

/* Morpheus */
//Main
/datum/robolimb/morpheus
	company = "Morpheus Cyberkinetics"
	desc = "This limb is simple and functional; no effort has been made to make it look human."
	icon = 'icons/mob/human_races/cyberlimbs/morpheus/morpheus_main.dmi'
	has_subtypes = brand
	is_monitor = TRUE	//Needed for default loadout.

/datum/robolimb/morpheus/monitor
	company = "Cyberkinetics Sport"
	icon = 'icons/mob/human_races/cyberlimbs/morpheus/morpheus_alt1.dmi'
	parts = list("head")
	has_subtypes = model //Look, I'm not sure what they're talking about in the original comment below, but this is becoming a model, not childless, so that it will NOT show up in the IPC Synthetic Shell loadout options.
	is_monitor = TRUE
	//Edge case. We want to be able to pick this one, and if we had it left as null for has_subtypes we'd be assuming it'll be chosen as a child model, and since the parent is unavailable at chargen, we wouldn't be able to see it in the list anyway. Now, we'll be able to select the Morpheus Ckt. Alt. head as a solo-model.

//Mantis
/datum/robolimb/mantis
	company = "Morpheus Mantis"
	desc = "This limb has a casing of sleek black metal and innovative insectile design."
	icon = 'icons/mob/human_races/cyberlimbs/morpheus/morpheus_mantis.dmi'
	has_subtypes = brand

/datum/robolimb/mantis/monitor
	company = "Morpheus Blitz"
	icon = 'icons/mob/human_races/cyberlimbs/morpheus/morpheus_blitz.dmi'
	parts = list("head")
	has_subtypes = model
	is_monitor = TRUE

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

//Economy
/datum/robolimb/wardeconomy
	company = "Ward-Takahashi Efficiency"
	desc = "A simple robotic limb with retro design. Seems rather stiff."
	icon = 'icons/mob/human_races/cyberlimbs/wardtakahashi/wardtakahashi_economy.dmi'
	has_subtypes = brand

/datum/robolimb/wardeconomy/monitor
	company = "Alternative Efficiency"
	icon = 'icons/mob/human_races/cyberlimbs/wardtakahashi/wardtakahashi_alt1.dmi'
	parts = list("head")
	has_subtypes = model
	is_monitor = TRUE

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

//Economy
/datum/robolimb/xioneconomy
	company = "Xion Economy"
	desc = "This skeletal mechanical limb has a minimalist black and red casing."
	icon = 'icons/mob/human_races/cyberlimbs/xion/xion_econo.dmi'
	has_subtypes = brand

/datum/robolimb/xioneconomy/monitor
	company = "Economy Standard"
	icon = 'icons/mob/human_races/cyberlimbs/xion/xion_alt1.dmi'
	parts = list("head")
	has_subtypes = model
	is_monitor = TRUE

/* Shellguard */
//Main
/datum/robolimb/shellguard
	company = "Shellguard Munitions"
	desc = "This limb features exposed robust steel and paint to match Shellguards motifs"
	icon = 'icons/mob/human_races/cyberlimbs/shellguard/shellguard_main.dmi'
	has_subtypes = brand

/datum/robolimb/shellguard/monitor
	company = "Shellguard Munitions Standard Series"
	icon = 'icons/mob/human_races/cyberlimbs/shellguard/shellguard_monitor.dmi'
	parts = list("head")
	has_subtypes = model
	is_monitor = TRUE

//Elite
/datum/robolimb/shellguard/alt1
	company = "Shellguard Munitions Elite Series"
	icon = 'icons/mob/human_races/cyberlimbs/shellguard/shellguard_alt1.dmi'
	parts = list("head")
	has_subtypes = model
	is_monitor = TRUE

/* Zenghu */
//Zenghu - Main
/datum/robolimb/zenghu
	company = "Zeng-Hu Pharmaceuticals"
	desc = "This limb has a rubbery fleshtone covering with visible seams."
	icon = 'icons/mob/human_races/cyberlimbs/zenghu/zenghu_main.dmi'
	has_subtypes = childless
	is_monitor = TRUE


//Zenghu - Spirit
/datum/robolimb/spirit
	company = "Zeng-Hu Spirit"
	desc = "This limb has a sleek black and white polymer finish."
	icon = 'icons/mob/human_races/cyberlimbs/zenghu/zenghu_spirit.dmi'
	has_subtypes = childless
	is_monitor = TRUE

#undef model
#undef brand
#undef childless
