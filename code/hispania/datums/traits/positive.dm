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
	value = 5
	gain_text = "<span class='notice'>Your MedHUD implant starts working.</span>"
	lose_text = "<span class='notice'>Where is your MedHUD implant?</span>"

/datum/quirk/hudmedimplant/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/organ/internal/cyberimp/eyes/hud/medical/implant = new
	implant.insert(H)

/datum/quirk/nutriimplant
	name = "Nutriment Implant"
	desc = "You start with a Nutriment Implant already set."
	value = 5
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
	value = 2
	gain_text = "<span class='notice'>Your Meson implant starts working.</span>"
	lose_text = "<span class='notice'>Where is your Meson implant?</span>"

/datum/quirk/mesonimplant/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/organ/internal/eyes/cybernetic/meson/implant = new
	implant.insert(H)

/datum/quirk/chadasfuck
	name = "Exceptional individual"
	desc = "Your life experiences made your body exceptionally unique. You can take more damage than usual."
	value = 6
	gain_text = "<span class='danger'>I'm sure this shift its going to be easy.</span>"
	lose_text = "<span class='notice'>I better be careful on what i do.</span>"

/datum/quirk/chadasfuck/add()
	quirk_holder.dna.species.total_health += 20

/datum/quirk/jackichanlol
	name = "Hit Catcher"
	desc = "Your difficult life has taught you to learn to take hits. Strikes do slightly less damage."
	value = 5
	gain_text = "<span class='danger'>This ain't nothing, i had it worst back then.</span>"
	lose_text = "<span class='notice'>Well maybe i'm going to think and plan now on what i can and can't do.</span>"

/datum/quirk/jackichanlol/add()
	quirk_holder.dna.species.armor += 3

/datum/quirk/chadpunches
	name = "Self-Defense trained"
	desc = "You have basic self defense training, your unarmed strikes can do slightly more damage."
	value = 4
	gain_text = "<span class='danger'>Remember the basics of Self Defense.</span>"
	lose_text = "<span class='notice'>I can't seem to remember the basics of self defense.</span>"

/datum/quirk/chadpunches/add()
	quirk_holder.dna.species.punchdamagelow += 1 //Base es 0 y queda en 1 esto implica que no puedes fallar un puñetazo
	quirk_holder.dna.species.punchdamagehigh += 1 //Base es 9 y queda en 10


