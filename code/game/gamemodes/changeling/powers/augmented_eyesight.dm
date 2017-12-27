//Augmented Eyesight: Gives you thermal and night vision - bye bye, flashlights. Also, high DNA cost because of how powerful it is.
//Possible todo: make a custom message for directing a penlight/flashlight at the eyes - not sure what would display though.

/obj/effect/proc_holder/changeling/augmented_eyesight
	name = "Augmented Eyesight"
	desc = "Creates heat receptors in our eyes and dramatically increases light sensing ability."
	helptext = "Grants us thermal vision or flash protection. We will become a lot more vulnerable to flash-based devices while thermal vision is active."
	chemical_cost = 0
	dna_cost = 2 //Would be 1 without thermal vision

/obj/effect/proc_holder/changeling/augmented_eyesight/sting_action(mob/living/carbon/human/user)
	if(!istype(user))
		return
	if(user.get_int_organ(/obj/item/organ/internal/cyberimp/eyes/thermals/ling))
		var/obj/item/organ/internal/cyberimp/eyes/O = new /obj/item/organ/internal/cyberimp/eyes/shield/ling()
		O.insert(user)

	else
		var/obj/item/organ/internal/cyberimp/eyes/O = new /obj/item/organ/internal/cyberimp/eyes/thermals/ling()
		O.insert(user)

	return 1


/obj/effect/proc_holder/changeling/augmented_eyesight/on_refund(mob/user)
	var/obj/item/organ/internal/cyberimp/eyes/O = user.get_organ_slot("eye_ling")
	if(O)
		O.remove(user)
		qdel(O)





/obj/item/organ/internal/cyberimp/eyes/shield/ling
	name = "protective membranes"
	desc = "These variable transparency organic membranes will protect you from welders and flashes and heal your eye damage."
	icon_state = "ling_eyeshield"
	eye_colour = null
	implant_overlay = null
	slot = "eye_ling"
	status = 0
	aug_message = "We feel a minute twitch in our eyes, our eyes feel more durable."

/obj/item/organ/internal/cyberimp/eyes/shield/ling/on_life()
	..()
	var/obj/item/organ/internal/eyes/E = owner.get_int_organ(/obj/item/organ/internal/eyes)
	if(owner.eye_blind || owner.eye_blurry || (owner.disabilities & BLIND) || (owner.disabilities & NEARSIGHTED) || (E.damage > 0))
		owner.reagents.add_reagent("oculine", 1)

/obj/item/organ/internal/cyberimp/eyes/shield/ling/prepare_eat()
	var/obj/S = ..()
	S.reagents.add_reagent("oculine", 15)
	return S


/obj/item/organ/internal/cyberimp/eyes/thermals/ling
	name = "heat receptors"
	desc = "These heat receptors dramatically increases eyes light sensing ability."
	icon_state = "ling_thermal"
	eye_colour = null
	implant_overlay = null
	slot = "eye_ling"
	status = 0
	aug_message = "We feel a minute twitch in our eyes, and darkness creeps away."

/obj/item/organ/internal/cyberimp/eyes/thermals/ling/emp_act(severity)
	return

/obj/item/organ/internal/cyberimp/eyes/thermals/ling/insert(mob/living/carbon/M, special = 0)
	..()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.weakeyes = 1
		if(!H.vision_type)
			H.vision_type = new /datum/vision_override/nightvision

/obj/item/organ/internal/cyberimp/eyes/thermals/ling/remove(mob/living/carbon/M, special = 0)
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.weakeyes = 0
		H.vision_type = null
	..()
