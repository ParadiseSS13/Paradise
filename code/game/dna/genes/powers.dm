///////////////////////////////////
// POWERS
///////////////////////////////////

/datum/dna/gene/basic/nobreath
	name = "No Breathing"
	activation_messages = list("You feel no need to breathe.")
	deactivation_messages = list("You feel the need to breathe, once more.")
	instability = GENE_INSTABILITY_MODERATE
	mutation = BREATHLESS
	activation_prob = 25

/datum/dna/gene/basic/nobreath/New()
	..()
	block = GLOB.breathlessblock


/datum/dna/gene/basic/regenerate
	name = "Regenerate"
	activation_messages = list("Your wounds start healing.")
	deactivation_messages = list("Your regenerative powers feel like they've vanished.")
	instability = GENE_INSTABILITY_MINOR
	mutation = REGEN

/datum/dna/gene/basic/regenerate/New()
	..()
	block = GLOB.regenerateblock

/datum/dna/gene/basic/regenerate/OnMobLife(mob/living/carbon/human/H)
	H.adjustBruteLoss(-0.1, FALSE)
	H.adjustFireLoss(-0.1)

/datum/dna/gene/basic/increaserun
	name = "Super Speed"
	activation_messages = list("You feel swift and unencumbered.")
	deactivation_messages = list("You feel slow.")
	instability = GENE_INSTABILITY_MINOR
	mutation = RUN

/datum/dna/gene/basic/increaserun/New()
	..()
	block = GLOB.increaserunblock

/datum/dna/gene/basic/increaserun/can_activate(mob/M, flags)
	if(!..())
		return FALSE
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.dna.species && H.dna.species.speed_mod && !(flags & MUTCHK_FORCED))
			return FALSE
	return TRUE

/datum/dna/gene/basic/heat_resist
	name = "Heat Resistance"
	activation_messages = list("Your skin is icy to the touch.")
	deactivation_messages = list("Your skin no longer feels icy to the touch.")
	instability = GENE_INSTABILITY_MODERATE
	mutation = HEATRES

/datum/dna/gene/basic/heat_resist/New()
	..()
	block = GLOB.coldblock

/datum/dna/gene/basic/heat_resist/OnDrawUnderlays(mob/M, g)
	return "cold_s"

/datum/dna/gene/basic/cold_resist
	name = "Cold Resistance"
	activation_messages = list("Your body is filled with warmth.")
	deactivation_messages = list("Your body is no longer filled with warmth.")
	instability = GENE_INSTABILITY_MODERATE
	mutation = COLDRES

/datum/dna/gene/basic/cold_resist/New()
	..()
	block = GLOB.fireblock

/datum/dna/gene/basic/cold_resist/OnDrawUnderlays(mob/M, g)
	return "fire_s"

/datum/dna/gene/basic/noprints
	name = "No Prints"
	activation_messages = list("Your fingers feel numb.")
	deactivation_messages = list("your fingers no longer feel numb.")
	instability = GENE_INSTABILITY_MINOR
	mutation = FINGERPRINTS

/datum/dna/gene/basic/noprints/New()
	..()
	block = GLOB.noprintsblock

/datum/dna/gene/basic/noshock
	name = "Shock Immunity"
	activation_messages = list("Your skin feels dry and unreactive.")
	deactivation_messages = list("Your skin no longer feels dry and unreactive.")
	instability = GENE_INSTABILITY_MODERATE
	mutation = NO_SHOCK

/datum/dna/gene/basic/noshock/New()
	..()
	block = GLOB.shockimmunityblock

/datum/dna/gene/basic/midget
	name = "Midget"
	activation_messages = list("Everything around you seems bigger now...")
	deactivation_messages = list("Everything around you seems to shrink...")
	instability = GENE_INSTABILITY_MINOR
	mutation = DWARF

/datum/dna/gene/basic/midget/New()
	..()
	block = GLOB.smallsizeblock

/datum/dna/gene/basic/midget/activate(mob/M, connected, flags)
	..()
	M.pass_flags |= PASSTABLE
	M.resize = 0.8
	M.update_transform()

/datum/dna/gene/basic/midget/deactivate(mob/M, connected, flags)
	..()
	M.pass_flags &= ~PASSTABLE
	M.resize = 1.25
	M.update_transform()

// OLD HULK BEHAVIOR
/datum/dna/gene/basic/hulk
	name = "Hulk"
	activation_messages = list("Your muscles hurt.")
	deactivation_messages = list("Your muscles shrink.")
	instability = GENE_INSTABILITY_MAJOR
	mutation = HULK
	activation_prob = 15

/datum/dna/gene/basic/hulk/New()
	..()
	block = GLOB.hulkblock

/datum/dna/gene/basic/hulk/activate(mob/M)
	..()
	M.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/hulk/hulk_transform)

/datum/dna/gene/basic/hulk/deactivate(mob/M)
	..()
	M.RemoveSpell(/obj/effect/proc_holder/spell/aoe_turf/hulk/hulk_transform)

/datum/dna/gene/basic/hulk/OnDrawUnderlays(mob/M, g)
	if(HULK in M.mutations)
		return "hulk_[g]_s"
	return FALSE

/datum/dna/gene/basic/hulk/OnMobLife(mob/living/carbon/human/M)
	if(!istype(M))
		return
	if((HULK in M.mutations) && M.health <= 0)
		M.mutations.Remove(HULK)
		M.dna.SetSEState(GLOB.hulkblock,0)
		genemutcheck(M, GLOB.hulkblock,null,MUTCHK_FORCED)
		M.update_mutations()		//update our mutation overlays
		M.update_body()
		M.status_flags |= CANSTUN | CANWEAKEN | CANPARALYSE | CANPUSH //temporary fix until the problem can be solved.
		to_chat(M, "<span class='danger'>You suddenly feel very weak.</span>")

/datum/dna/gene/basic/xray
	name = "X-Ray Vision"
	activation_messages = list("The walls suddenly disappear.")
	deactivation_messages = list("the walls around you re-appear.")
	instability = GENE_INSTABILITY_MAJOR
	mutation = XRAY
	activation_prob = 15

/datum/dna/gene/basic/xray/New()
	..()
	block = GLOB.xrayblock

/datum/dna/gene/basic/xray/activate(mob/living/M, connected, flags)
	..()
	M.update_sight()
	M.update_icons() //Apply eyeshine as needed.

/datum/dna/gene/basic/xray/deactivate(mob/living/M, connected, flags)
	..()
	M.update_sight()
	M.update_icons() //Remove eyeshine as needed.

/datum/dna/gene/basic/tk
	name = "Telekenesis"
	activation_messages = list("You feel smarter.")
	deactivation_messages = list("You feel dumber.")
	instability = GENE_INSTABILITY_MAJOR
	mutation = TK
	activation_prob = 15

/datum/dna/gene/basic/tk/New()
	..()
	block = GLOB.teleblock

/datum/dna/gene/basic/tk/OnDrawUnderlays(mob/M, g)
	return "telekinesishead_s"
