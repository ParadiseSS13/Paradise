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
		user << "<span class='warning'>We cannot perform this ability at the present time!</span>"
		return
	user << "<span class='warning'>Our genes cry out!</span>"

	var/mob/living/carbon/C = user

	//TODO replace with monkeyize proc
	var/list/implants = list() //Try to preserve implants.
	for(var/obj/item/weapon/implant/W in C)
		implants += W

	C.notransform = 1
	C.canmove = 0
	C.icon = null
	C.overlays.Cut()
	C.invisibility = 101

	var/atom/movable/overlay/animation = new /atom/movable/overlay( C.loc )
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src
	flick("h2monkey", animation)
	sleep(30)
	del(animation)

	var/mob/living/carbon/monkey/O = new /mob/living/carbon/monkey(src)
	O.dna = C.dna.Clone()
	C.dna = null

	for(var/obj/item/W in C)
		C.unEquip(W)
	for(var/obj/T in C)
		del(T)

	O.loc = C.loc
	O.name = "monkey ([copytext(md5(C.real_name), 2, 6)])"
	O.setToxLoss(C.getToxLoss())
	O.adjustBruteLoss(C.getBruteLoss())
	O.setOxyLoss(C.getOxyLoss())
	O.adjustFireLoss(C.getFireLoss())
	O.stat = C.stat
	O.a_intent = "harm"
	for(var/obj/item/weapon/implant/I in implants)
		I.loc = O
		I.implanted = O

	C.mind.transfer_to(O)
	O.mind.changeling.purchasedpowers += new /obj/effect/proc_holder/changeling/humanform(null)
	O.changeling_update_languages(changeling.absorbed_languages)

	feedback_add_details("changeling_powers","LF")
	qdel(C)
	return 1