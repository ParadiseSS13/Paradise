///////////////////////////////////
// POWERS
///////////////////////////////////

/datum/dna/gene/basic/nobreath
	name="No Breathing"
	activation_messages=list("You feel no need to breathe.")
	deactivation_messages=list("You feel the need to breathe, once more.")
	instability = GENE_INSTABILITY_MODERATE
	mutation = BREATHLESS
	activation_prob=25

/datum/dna/gene/basic/nobreath/New()
	block = GLOB.breathlessblock


/datum/dna/gene/basic/regenerate
	name="Regenerate"
	activation_messages=list("Your wounds start healing.")
	deactivation_messages=list("Your regenerative powers feel like they've vanished.")
	instability = GENE_INSTABILITY_MINOR
	mutation=REGEN

/datum/dna/gene/basic/regenerate/New()
	block=GLOB.regenerateblock

/datum/dna/gene/basic/increaserun
	name="Super Speed"
	activation_messages=list("You feel swift and unencumbered.")
	deactivation_messages=list("You feel slow.")
	instability = GENE_INSTABILITY_MINOR
	mutation=RUN

/datum/dna/gene/basic/increaserun/New()
	block=GLOB.increaserunblock

/datum/dna/gene/basic/increaserun/can_activate(var/mob/M,var/flags)
	if(!..())
		return 0
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.dna.species && H.dna.species.speed_mod && !(flags & MUTCHK_FORCED))
			return 0
	return 1

/datum/dna/gene/basic/heat_resist
	name="Heat Resistance"
	activation_messages=list("Your skin is icy to the touch.")
	deactivation_messages=list("Your skin no longer feels icy to the touch.")
	instability = GENE_INSTABILITY_MODERATE
	mutation = HEATRES

/datum/dna/gene/basic/heat_resist/New()
	block=GLOB.coldblock

/datum/dna/gene/basic/heat_resist/OnDrawUnderlays(var/mob/M,var/g,var/fat)
	return "cold[fat]_s"

/datum/dna/gene/basic/cold_resist
	name="Cold Resistance"
	activation_messages=list("Your body is filled with warmth.")
	deactivation_messages=list("Your body is no longer filled with warmth.")
	instability = GENE_INSTABILITY_MODERATE
	mutation = COLDRES

/datum/dna/gene/basic/cold_resist/New()
	block=GLOB.fireblock

/datum/dna/gene/basic/cold_resist/OnDrawUnderlays(var/mob/M,var/g,var/fat)
	return "fire[fat]_s"

/datum/dna/gene/basic/noprints
	name="No Prints"
	activation_messages=list("Your fingers feel numb.")
	deactivation_messages=list("your fingers no longer feel numb.")
	instability = GENE_INSTABILITY_MINOR
	mutation=FINGERPRINTS

/datum/dna/gene/basic/noprints/New()
	block=GLOB.noprintsblock

/datum/dna/gene/basic/noshock
	name="Shock Immunity"
	activation_messages=list("Your skin feels dry and unreactive.")
	deactivation_messages=list("Your skin no longer feels dry and unreactive.")
	instability = GENE_INSTABILITY_MODERATE
	mutation=NO_SHOCK

/datum/dna/gene/basic/noshock/New()
	block=GLOB.shockimmunityblock

/datum/dna/gene/basic/midget
	name="Midget"
	activation_messages=list("Everything around you seems bigger now...")
	deactivation_messages = list("Everything around you seems to shrink...")
	instability = GENE_INSTABILITY_MINOR
	mutation=DWARF

/datum/dna/gene/basic/midget/New()
	block=GLOB.smallsizeblock

/datum/dna/gene/basic/midget/activate(var/mob/M, var/connected, var/flags)
	..(M,connected,flags)
	M.pass_flags |= PASSTABLE
	M.resize = 0.8
	M.update_transform()

/datum/dna/gene/basic/midget/deactivate(var/mob/M, var/connected, var/flags)
	..()
	M.pass_flags &= ~PASSTABLE
	M.resize = 1.25
	M.update_transform()

// OLD HULK BEHAVIOR
/datum/dna/gene/basic/hulk
	name="Hulk"
	activation_messages=list("Your muscles hurt.")
	deactivation_messages=list("Your muscles shrink.")
	instability = GENE_INSTABILITY_MAJOR
	mutation=HULK
	activation_prob=15

/datum/dna/gene/basic/hulk/New()
	block=GLOB.hulkblock

/datum/dna/gene/basic/hulk/activate(var/mob/M, var/connected, var/flags)
	..()
	var/status = CANSTUN | CANWEAKEN | CANPARALYSE | CANPUSH
	M.status_flags &= ~status

/datum/dna/gene/basic/hulk/deactivate(var/mob/M, var/connected, var/flags)
	..()
	M.status_flags |= CANSTUN | CANWEAKEN | CANPARALYSE | CANPUSH

/datum/dna/gene/basic/hulk/OnDrawUnderlays(var/mob/M,var/g,var/fat)
	if(HULK in M.mutations)
		if(fat)
			return "hulk_[fat]_s"
		else
			return "hulk_[g]_s"
	return 0

/datum/dna/gene/basic/hulk/OnMobLife(var/mob/living/carbon/human/M)
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
	name="X-Ray Vision"
	activation_messages=list("The walls suddenly disappear.")
	deactivation_messages=list("the walls around you re-appear.")
	instability = GENE_INSTABILITY_MAJOR
	mutation=XRAY
	activation_prob=15

/datum/dna/gene/basic/xray/New()
	block=GLOB.xrayblock

/datum/dna/gene/basic/xray/activate(mob/living/M, connected, flags)
	..()
	M.update_sight()
	M.update_icons() //Apply eyeshine as needed.

/datum/dna/gene/basic/xray/deactivate(mob/living/M, connected, flags)
	..()
	M.update_sight()
	M.update_icons() //Remove eyeshine as needed.

/datum/dna/gene/basic/tk
	name="Telekenesis"
	activation_messages = list("You feel smarter.")
	deactivation_messages = list("You feel dumber.")
	instability = GENE_INSTABILITY_MAJOR
	mutation=TK
	activation_prob=15

/datum/dna/gene/basic/tk/New()
	block=GLOB.teleblock

/datum/dna/gene/basic/tk/OnDrawUnderlays(var/mob/M,var/g,var/fat)
	return "telekinesishead[fat]_s"
