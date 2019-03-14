/obj/item/organ/internal/liver/vox
	name = "vox liver"
	icon = 'icons/obj/species_organs/vox.dmi'
	alcohol_intensity = 1.6


/obj/item/organ/internal/stack
	name = "cortical stack"
	icon = 'icons/obj/species_organs/vox.dmi'
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

/obj/item/organ/internal/eyes/vox
	name = "vox eyeballs"
	icon = 'icons/obj/species_organs/vox.dmi'

/obj/item/organ/internal/heart/vox
	name = "vox heart"
	icon = 'icons/obj/species_organs/vox.dmi'

/obj/item/organ/internal/brain/vox
	icon = 'icons/obj/species_organs/vox.dmi'
	desc = "A brain with spikes on top of it. It has some odd metallic slot with wires on the side."
	icon_state = "brain2"
	mmi_icon = 'icons/obj/species_organs/vox.dmi'
	mmi_icon_state = "mmi_full"

/obj/item/organ/internal/kidneys/vox
	name = "vox kidneys"
	icon = 'icons/obj/species_organs/vox.dmi'