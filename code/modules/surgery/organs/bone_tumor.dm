/obj/item/organ/internal/bone_tumor
	name = "bone tumor"
	parent_organ = "groin"
	slot = "groin_tumor"
	destroy_on_removal = TRUE

/obj/item/organ/internal/bone_tumor/on_life()

	var/obj/item/organ/external/groin/G = owner.get_limb_by_name("groin")

	if(prob(5))
		G.receive_damage(10, 0, FALSE)
		to_chat(owner, "<span class='danger'>Something sharp is moving around in your lower body!</span>")

	if(prob(1))
		to_chat(owner, "<span class='danger'>Something just tore in your lower body!</span>")

		var/list/other_groin_organs = G.internal_organs
		other_groin_organs -= src

		for(var/obj/item/organ/internal/I in other_groin_organs)
			I.receive_damage(rand(5, 15))
