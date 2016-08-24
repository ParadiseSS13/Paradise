/mob/living/carbon/human/KnockOut(updating = 1)
	. = ..()
	if(.)
		// Notify our AI if they can now control the suit.
		if(wearing_rig)
			wearing_rig.notify_ai("<span class='danger'>Warning: user consciousness failure. Mobility control passed to integrated intelligence system.</span>")

/mob/living/carbon/human/can_be_revived()
	. = ..()
	if(getBrainLoss() >= 120)
		. = FALSE
