/obj/item/organ/internal/liver/vox
	alcohol_intensity = 1.6


/obj/item/organ/internal/stack
	name = "cortical stack"
	icon_state = "cortical-stack"
	parent_organ = "head"
	organ_tag = "stack"
	slot = "vox_stack"
	status = ORGAN_ROBOT
	vital = TRUE
	var/stackdamaged = FALSE

/obj/item/organ/internal/stack/on_life()
	if(damage < 1 && stackdamaged)
		owner.mutations.Remove(SCRAMBLED)
		owner.dna.SetSEState(SCRAMBLEBLOCK,0)
		genemutcheck(owner,SCRAMBLEBLOCK,null,MUTCHK_FORCED)
		stackdamaged = FALSE
	..()


/obj/item/organ/internal/stack/emp_act(severity)
	if(owner)
		owner.mutations.Add(SCRAMBLED)
		owner.dna.SetSEState(SCRAMBLEBLOCK,1,1)
		genemutcheck(owner,SCRAMBLEBLOCK,null,MUTCHK_FORCED)
		owner.AdjustConfused(4)
		if(!stackdamaged)
			stackdamaged = TRUE
	..()