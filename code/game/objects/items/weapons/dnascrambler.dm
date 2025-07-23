/obj/item/dnascrambler
	name = "dna scrambler"
	desc = "An illegal genetic serum designed to randomize the user's identity."
	icon = 'icons/obj/hypo.dmi'
	icon_state = "lepopen"
	inhand_icon_state = "syringe_0"
	var/used = FALSE

/obj/item/dnascrambler/update_icon_state()
	if(used)
		icon_state = "lepopen0"
	else
		icon_state = "lepopen"

/obj/item/dnascrambler/attack__legacy__attackchain(mob/M as mob, mob/user as mob)
	if(!M || !user)
		return

	if(!ishuman(M) || !ishuman(user))
		return

	if(used)
		return

	if(HAS_TRAIT(M, TRAIT_GENELESS))
		to_chat(user, "<span class='warning'>You failed to inject [M], as [M.p_they()] [M.p_have()] no DNA to scramble, nor flesh to inject.</span>")
		return

	if(M == user)
		user.visible_message("<span class='danger'>[user] injects [user.p_themselves()] with [src]!</span>")
		injected(user, user)
	else
		user.visible_message("<span class='danger'>[user] is trying to inject [M] with [src]!</span>")
		if(do_mob(user,M,30))
			user.visible_message("<span class='danger'>[user] injects [M] with [src].</span>")
			injected(M, user)
		else
			to_chat(user, "<span class='warning'>You failed to inject [M].</span>")

/obj/item/dnascrambler/proc/injected(mob/living/carbon/human/target, mob/living/carbon/user)
	if(istype(target))
		var/mob/living/carbon/human/H = target
		H.get_dna_scrambled()
	target.update_icons()

	add_attack_logs(user, target, "injected with [src]")
	used = TRUE
	update_icon(UPDATE_ICON_STATE)
	name = "used " + name
