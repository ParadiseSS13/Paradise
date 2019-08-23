/datum/action/changeling/headslug
	name = "Last Resort"
	desc = "We sacrifice our current body in a moment of need, placing us in control of a vessel that can plant our likeness in a new host. Costs 20 chemicals."
	helptext = "We will be placed in control of a small, fragile creature. We may attack a corpse like this to plant an egg which will slowly mature into a new form for us."
	button_icon_state = "last_resort"
	chemical_cost = 20
	dna_cost = 1
	req_human = 1

/datum/action/changeling/headslug/try_to_sting(mob/user, mob/target)
    if(alert("Are you sure you wish to do this? This action cannot be undone.",,"Yes","No")=="No")
        return
    ..()

/datum/action/changeling/headslug/sting_action(mob/user)
	var/datum/mind/M = user.mind
	var/list/organs = user.get_organs_zone("head", 1)

	for(var/obj/item/organ/internal/I in organs)
		I.remove(user, 1)

	explosion(get_turf(user),0,0,2,0,silent=1)
	for(var/mob/living/carbon/human/H in range(2,user))
		to_chat(H, "<span class='userdanger'>You are blinded by a shower of blood!</span>")
		H.Stun(1)
		H.EyeBlurry(20)
		var/obj/item/organ/internal/eyes/E = H.get_int_organ(/obj/item/organ/internal/eyes)
		if(istype(E))
			E.receive_damage(5, 1)
		H.AdjustConfused(3)
	for(var/mob/living/silicon/S in range(2,user))
		to_chat(S, "<span class='userdanger'>Your sensors are disabled by a shower of blood!</span>")
		S.Weaken(3)
	var/new_location = user.drop_location()
	spawn(5) // So it's not killed in explosion
		var/mob/living/simple_animal/hostile/headslug/crab = new(new_location)
		for(var/obj/item/organ/internal/I in organs)
			I.loc = crab
		crab.origin = M
		if(crab.origin)
			crab.origin.active = 1
			crab.origin.transfer_to(crab)
			to_chat(crab, "<span class='warning'>You burst out of the remains of your former body in a shower of gore!</span>")
	user.gib()
	feedback_add_details("changeling_powers","LR")
	return 1
