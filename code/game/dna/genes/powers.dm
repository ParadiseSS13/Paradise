///////////////////////////////////
// POWERS
///////////////////////////////////

/datum/dna/gene/basic/nobreath
	name="No Breathing"
	activation_messages=list("You feel no need to breathe.")
	mutation=NO_BREATH
	instability=2
	activation_prob=10

	New()
		block=NOBREATHBLOCK


/datum/dna/gene/basic/regenerate
	name="Regenerate"
	activation_messages=list("You feel better.")
	mutation=REGEN
	instability=2

	New()
		block=REGENERATEBLOCK

/datum/dna/gene/basic/increaserun
	name="Super Speed"
	activation_messages=list("Your leg muscles pulsate.")
	mutation=RUN
	instability=1

	New()
		block=INCREASERUNBLOCK


/datum/dna/gene/basic/heat_resist
	name="Heat Resistance"
	activation_messages=list("Your skin is icy to the touch.")
	mutation=RESIST_HEAT
	instability=2

	New()
		block=COLDBLOCK

	can_activate(var/mob/M,var/flags)
		if(flags & MUTCHK_FORCED)
			return !(/datum/dna/gene/basic/cold_resist in M.active_genes)
		// Probability check
		var/_prob = 15
		if(RESIST_COLD in M.mutations)
			_prob=5
		if(probinj(_prob,(flags&MUTCHK_FORCED)))
			return 1

	OnDrawUnderlays(var/mob/M,var/g,var/fat)
		return "cold[fat]_s"

/datum/dna/gene/basic/cold_resist
	name="Cold Resistance"
	activation_messages=list("Your body is filled with warmth.")
	mutation=RESIST_COLD
	instability=2

	New()
		block=FIREBLOCK

	can_activate(var/mob/M,var/flags)
		if(flags & MUTCHK_FORCED)
			return !(/datum/dna/gene/basic/heat_resist in M.active_genes)
		// Probability check
		var/_prob=30
		if(RESIST_HEAT in M.mutations)
			_prob=5
		if(probinj(_prob,(flags&MUTCHK_FORCED)))
			return 1

	OnDrawUnderlays(var/mob/M,var/g,var/fat)
		return "fire[fat]_s"

/datum/dna/gene/basic/noprints
	name="No Prints"
	activation_messages=list("Your fingers feel numb.")
	mutation=FINGERPRINTS
	instability=1

	New()
		block=NOPRINTSBLOCK

/datum/dna/gene/basic/noshock
	name="Shock Immunity"
	activation_messages=list("Your skin feels strange.")
	mutation=NO_SHOCK
	instability=2

	New()
		block=SHOCKIMMUNITYBLOCK

/datum/dna/gene/basic/midget
	name="Midget"
	activation_messages=list("Everything around you seems bigger now...")
	deactivation_messages = list("Everything around you seems to shrink...")
	mutation=DWARF
	instability=1

	New()
		block=SMALLSIZEBLOCK

	can_activate(var/mob/M,var/flags)
		// Can't be big and small.
		if(HULK in M.mutations)
			return 0
		return ..(M,flags)

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
	mutation=HULK
	activation_prob=5

	New()
		block=HULKBLOCK

	can_activate(var/mob/M,var/flags)
		// Can't be big AND small.
		if(DWARF in M.mutations)
			return 0
		return ..(M,flags)

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
	mutation=XRAY
	activation_prob=10
	instability=2

	New()
		block=XRAYBLOCK

/datum/dna/gene/basic/tk
	name="Telekenesis"
	activation_messages=list("You feel smarter.")
	mutation=TK
	activation_prob=10
	instability=5

	New()
		block=TELEBLOCK

	OnDrawUnderlays(var/mob/M,var/g,var/fat)
		return "telekinesishead[fat]_s"