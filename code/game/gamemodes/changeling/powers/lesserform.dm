/obj/effect/proc_holder/changeling/lesserform
	name = "Lesser form"
	desc = "We debase ourselves and become lesser. We become a monkey."
	chemical_cost = 5
	dna_cost = 1
	genetic_damage = 3
	req_human = 1

//Transform into a monkey.
/obj/effect/proc_holder/changeling/lesserform/sting_action(var/mob/living/carbon/human/user)
	var/datum/changeling/changeling = user.mind.changeling
	if(!user)
		return 0
	if(user.has_brain_worms())
		to_chat(user, "<span class='warning'>We cannot perform this ability at the present time!</span>")
		return

	var/mob/living/carbon/human/H = user

	if(!istype(H) || !H.species.primitive_form)
		to_chat(H, "<span class='warning'>We cannot perform this ability in this form!</span>")
		return

	var/datum/dna/DNA = changeling.GetDNA(user.dna.real_name)
	user.dna = DNA ? DNA.Clone() : user.dna

	H.visible_message("<span class='warning'>[H] transforms!</span>")
	changeling.geneticdamage = 30
	to_chat(H, "<span class='warning'>Our genes cry out!</span>")
	var/list/implants = list() //Try to preserve implants.
	for(var/obj/item/weapon/implant/W in H)
		implants += W

	user.dna.SetSEState(MONKEYBLOCK,1,1)
	genemutcheck(user,MONKEYBLOCK,null,MUTCHK_FORCED)
	changeling.purchasedpowers += new /obj/effect/proc_holder/changeling/humanform(null)
	feedback_add_details("changeling_powers","LF")
	return 1