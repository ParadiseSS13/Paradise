/datum/quirk/freerunning
	name = "Freerunning"
	desc = "You're great at quick moves! You can climb tables more quickly and take no damage from short falls."
	value = 2
	mob_trait = TRAIT_FREERUNNING
	gain_text = "<span class='notice'>You feel lithe on your feet!</span>"
	lose_text = "<span class='danger'>You feel clumsy again.</span>"
	medical_record_text = "Patient scored highly on cardio tests."

/datum/quirk/hudmedimplant
	name = "Medhud Implant"
	desc = "You start with a MedHud Implant already set."
	value = 1
	gain_text = "<span class='notice'>Your MedHUD implant starts working.</span>"
	lose_text = "<span class='notice'>Where is your MedHUD implant?</span>"

/datum/quirk/hudmedimplant/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/organ/internal/cyberimp/eyes/hud/medical/implant = new
	implant.insert(H)

/datum/quirk/nutriimplant
	name = "Nutriment Implant"
	desc = "You start with a Nutriment Implant already set."
	value = 1
	gain_text = "<span class='notice'>Your Nutriment implant starts working.</span>"
	lose_text = "<span class='notice'>Where is your Nutriment implant?</span>"

/datum/quirk/nutriimplant/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/organ/internal/cyberimp/chest/nutriment/implant = new
	implant.insert(H)

/datum/quirk/huddiagimplant
	name = "DiagnosticHUD Implant"
	desc = "You start with a DiagnosticHUD Implant already set."
	value = 1
	gain_text = "<span class='notice'>Your Nutriment implant starts working.</span>"
	lose_text = "<span class='notice'>Where is your DiagnosticHUD implant?</span>"

/datum/quirk/huddiagimplant/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/organ/internal/cyberimp/eyes/hud/diagnostic/implant = new
	implant.insert(H)

/datum/quirk/mesonimplant
	name = "Meson Implant"
	desc = "You start with a Meson Implant already set."
	value = 1
	gain_text = "<span class='notice'>Your Meson implant starts working.</span>"
	lose_text = "<span class='notice'>Where is your Meson implant?</span>"

/datum/quirk/mesonimplant/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/organ/internal/eyes/cybernetic/meson/implant = new
	implant.insert(H)
