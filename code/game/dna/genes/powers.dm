///////////////////////////////////
// POWERS
///////////////////////////////////

/datum/dna/gene/basic/nobreath
	name="No Breathing"
	activation_messages=list("You feel no need to breathe.")
	deactivation_messages=list("You feel the need to breathe, once more.")
	mutation=NO_BREATH
	activation_prob=10

	New()
		block=NOBREATHBLOCK


/datum/dna/gene/basic/regenerate
	name="Regenerate"
	activation_messages=list("Your wounds start healing.")
	deactivation_messages=list("Your regenerative powers feel like they've vanished.")
	mutation=REGEN

	New()
		block=REGENERATEBLOCK

/datum/dna/gene/basic/increaserun
	name="Super Speed"
	activation_messages=list("You feel swift and unencumbered.")
	deactivation_messages=list("You feel slow.")
	mutation=RUN

	New()
		block=INCREASERUNBLOCK


/datum/dna/gene/basic/heat_resist
	name="Heat Resistance"
	activation_messages=list("Your skin is icy to the touch.")
	deactivation_messages=list("Your skin no longer feels icy to the touch.")
	mutation=RESIST_HEAT

	New()
		block=COLDBLOCK

	OnDrawUnderlays(var/mob/M,var/g,var/fat)
		return "cold[fat]_s"

/datum/dna/gene/basic/cold_resist
	name="Cold Resistance"
	activation_messages=list("Your body is filled with warmth.")
	deactivation_messages=list("Your body is no longer filled with warmth.")
	mutation=RESIST_COLD

	New()
		block=FIREBLOCK

	OnDrawUnderlays(var/mob/M,var/g,var/fat)
		return "fire[fat]_s"

/datum/dna/gene/basic/noprints
	name="No Prints"
	activation_messages=list("Your fingers feel numb.")
	deactivation_messages=list("your fingers no longer feel numb.")
	mutation=FINGERPRINTS

	New()
		block=NOPRINTSBLOCK

/datum/dna/gene/basic/noshock
	name="Shock Immunity"
	activation_messages=list("Your skin feels dry and unreactive.")
	deactivation_messages=list("Your skin no longer feels dry and unreactive.")
	mutation=NO_SHOCK

	New()
		block=SHOCKIMMUNITYBLOCK

/datum/dna/gene/basic/midget
	name="Midget"
	activation_messages=list("Everything around you seems bigger now...")
	deactivation_messages = list("Everything around you seems to shrink...")
	mutation=DWARF

	New()
		block=SMALLSIZEBLOCK

	activate(var/mob/M, var/connected, var/flags)
		..(M,connected,flags)
		M.pass_flags |= PASSTABLE
		M.resize = 0.8

	deactivate(var/mob/M, var/connected, var/flags)
		..()
		M.pass_flags &= ~PASSTABLE
		M.resize = 1.25

// OLD HULK BEHAVIOR
/datum/dna/gene/basic/hulk
	name="Hulk"
	activation_messages=list("Your muscles hurt.")
	deactivation_messages=list("Your muscles shrink.")
	mutation=HULK
	activation_prob=5

	New()
		block=HULKBLOCK

	activate(var/mob/M, var/connected, var/flags)
		..()
		var/status = CANSTUN | CANWEAKEN | CANPARALYSE | CANPUSH
		M.status_flags &= ~status

	deactivate(var/mob/M, var/connected, var/flags)
		..()
		M.status_flags |= CANSTUN | CANWEAKEN | CANPARALYSE | CANPUSH

	OnDrawUnderlays(var/mob/M,var/g,var/fat)
		if(HULK in M.mutations)
			if(fat)
				return "hulk_[fat]_s"
			else
				return "hulk_[g]_s"
		return 0

	OnMobLife(var/mob/living/carbon/human/M)
		if(!istype(M)) return
		if ((HULK in M.mutations) && M.health <= 0)
			M.mutations.Remove(HULK)
			M.dna.SetSEState(HULKBLOCK,0)
			genemutcheck(M, HULKBLOCK,null,MUTCHK_FORCED)
			M.update_mutations()		//update our mutation overlays
			M.update_body()
			M.status_flags |= CANSTUN | CANWEAKEN | CANPARALYSE | CANPUSH //temporary fix until the problem can be solved.
			to_chat(M, "<span class='danger'>You suddenly feel very weak.</span>")

/datum/dna/gene/basic/xray
	name="X-Ray Vision"
	activation_messages=list("The walls suddenly disappear.")
	deactivation_messages=list("the walls around you re-appear.")
	mutation=XRAY
	activation_prob=10

	New()
		block=XRAYBLOCK

/datum/dna/gene/basic/tk
	name="Telekenesis"
	activation_messages=list("You feel smarter.")
	deactivation_messages=("You feel dumber.")
	mutation=TK
	activation_prob=10

	New()
		block=TELEBLOCK

	OnDrawUnderlays(var/mob/M,var/g,var/fat)
		return "telekinesishead[fat]_s"