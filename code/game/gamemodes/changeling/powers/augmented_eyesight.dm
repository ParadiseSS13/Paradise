//Augmented Eyesight: Gives you thermal and night vision - bye bye, flashlights. Also, high DNA cost because of how powerful it is.
//Possible todo: make a custom message for directing a penlight/flashlight at the eyes - not sure what would display though.

/obj/effect/proc_holder/changeling/augmented_eyesight
	name = "Augmented Eyesight"
	desc = "Creates heat receptors in our eyes and dramatically increases light sensing ability."
	helptext = "Grants us night vision and thermal vision. It may be toggled on or off."
	chemical_cost = 0
	dna_cost = 2 //Would be 1 without thermal vision

/obj/effect/proc_holder/changeling/augmented_eyesight/sting_action(var/mob/user)
	if(!user.vision_type)
		user << "<span class='notice'>We feel a minute twitch in our eyes, and darkness creeps away.</span>"
		user.vision_type = new /datum/vision_override/nightvision/thermals/ling_augmented_eyesight
	else
		user << "<span class='notice'>Our vision dulls. Shadows gather.</span>"
		user.vision_type = null
	return 1

/obj/effect/proc_holder/changeling/augmented_eyesight/on_refund(mob/user)
	user.vision_type = null