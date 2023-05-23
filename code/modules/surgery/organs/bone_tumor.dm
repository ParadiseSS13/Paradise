/obj/item/organ/internal/bone_tumor
	name = "bone tumor"
	parent_organ = "groin"
	slot = "groin_tumor"
	destroy_on_removal = TRUE
	var/tumor_size = 0 //Changed in New to be dependent on amount of osseous reagent in the system when formed, determines damage done

/obj/item/organ/internal/bone_tumor/New(mob/living/carbon/holder)
	..()
	tumor_size = owner.reagents.get_reagent_amount("osseous_reagent")
	owner.reagents.remove_all_type(/datum/reagent/medicine/osseous_reagent, tumor_size)

/obj/item/organ/internal/bone_tumor/on_life()

	var/obj/item/organ/external/groin/G = owner.get_limb_by_name("groin")
	var/tumor_damage_modifier = sqrt(tumor_size - 30) //diminishing returns, tumor size can't be lower than 30

	if(prob(5))
		G.receive_damage(10 + tumor_damage_modifier, 0, FALSE)
		to_chat(owner, "<span class='danger'>Something sharp is moving around in your lower body!</span>")

	if(prob(1))
		to_chat(owner, "<span class='userdanger'>Something just tore in your lower body!</span>")

		var/list/other_groin_organs = G.internal_organs
		other_groin_organs -= src

		for(var/obj/item/organ/internal/I in other_groin_organs)
			I.receive_damage(rand(5, 15) + tumor_damage_modifier)
