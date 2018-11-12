/obj/item/organ/internal/brain
	name = "brain"
	health = 400 //They need to live awhile longer than other organs.
	max_damage = 200
	icon_state = "brain2"
	force = 1.0
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 1.0
	throw_speed = 3
	throw_range = 5
	origin_tech = "biotech=5"
	attack_verb = list("attacked", "slapped", "whacked")
	var/mob/living/carbon/brain/brainmob = null
	organ_tag = "brain"
	parent_organ = "head"
	slot = "brain"
	vital = TRUE
	hidden_pain = TRUE //the brain has no pain receptors, and brain damage is meant to be a stealthy damage type.
	var/mmi_icon = 'icons/obj/assemblies.dmi'
	var/mmi_icon_state = "mmi_full"

/obj/item/organ/internal/brain/xeno
	name = "xenomorph brain"
	desc = "We barely understand the brains of terrestial animals. Who knows what we may find in the brain of such an advanced species?"
	icon_state = "brain-x"
	origin_tech = "biotech=6"
	mmi_icon = 'icons/mob/alien.dmi'
	mmi_icon_state = "AlienMMI"

/obj/item/organ/internal/brain/New()
	..()
	spawn(5)
		if(brainmob && brainmob.client)
			brainmob.client.screen.len = null //clear the hud

/obj/item/organ/internal/brain/proc/transfer_identity(var/mob/living/carbon/H)
	brainmob = new(src)
	if(isnull(dna)) // someone didn't set this right...
		log_runtime(EXCEPTION("[src] at [loc] did not contain a dna datum at time of removal."), src)
		dna = H.dna.Clone()
	name = "\the [dna.real_name]'s [initial(src.name)]"
	brainmob.dna = dna.Clone() // Silly baycode, what you do
//	brainmob.dna = H.dna.Clone() Putting in and taking out a brain doesn't make it a carbon copy of the original brain of the body you put it in
	brainmob.name = dna.real_name
	brainmob.real_name = dna.real_name
	brainmob.timeofhostdeath = H.timeofdeath
	if(H.mind)
		H.mind.transfer_to(brainmob)

	to_chat(brainmob, "<span class='notice'>You feel slightly disoriented. That's normal when you're just a [initial(src.name)].</span>")
	callHook("debrain", list(brainmob))

/obj/item/organ/internal/brain/examine(mob/user) // -- TLE
	..(user)
	if(brainmob && brainmob.client)//if thar be a brain inside... the brain.
		to_chat(user, "You can feel the small spark of life still left in this one.")
	else
		to_chat(user, "This one seems particularly lifeless. Perhaps it will regain some of its luster later..")

/obj/item/organ/internal/brain/remove(var/mob/living/user,special = 0)
	if(dna)
		name = "[dna.real_name]'s [initial(name)]"

	if(!owner) return ..() // Probably a redundant removal; just bail

	var/obj/item/organ/internal/brain/B = src
	if(!special)
		var/mob/living/simple_animal/borer/borer = owner.has_brain_worms()
		if(borer)
			borer.leave_host() //Should remove borer if the brain is removed - RR

		if(owner.mind && !non_primary)//don't transfer if the owner does not have a mind.
			B.transfer_identity(user)

	if(istype(owner,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = owner
		H.update_hair(1)
	. = ..()

/obj/item/organ/internal/brain/insert(var/mob/living/target,special = 0)

	name = "[initial(name)]"
	var/brain_already_exists = 0
	if(istype(target,/mob/living/carbon/human)) // No more IPC multibrain shenanigans
		if(target.get_int_organ(/obj/item/organ/internal/brain))
			brain_already_exists = 1

		var/mob/living/carbon/human/H = target
		H.update_hair(1)

	if(!brain_already_exists)
		if(brainmob)
			if(target.key)
				target.ghostize()
			if(brainmob.mind)
				brainmob.mind.transfer_to(target)
			else
				target.key = brainmob.key
	else
		log_debug("Multibrain shenanigans at ([target.x],[target.y],[target.z]), mob '[target]'")
	..(target, special = special)

/obj/item/organ/internal/brain/prepare_eat()
	return // Too important to eat.

/obj/item/organ/internal/brain/slime
	name = "slime core"
	desc = "A complex, organic knot of jelly and crystalline particles."
	icon = 'icons/mob/slimes.dmi'
	icon_state = "green slime extract"
	mmi_icon_state = "slime_mmi"
//	parent_organ = "chest" Hello I am from the ministry of rubber forehead aliens how are you

/obj/item/organ/internal/brain/golem
	name = "Runic mind"
	desc = "A tightly furled roll of paper, covered with indecipherable runes."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll"

/obj/item/organ/internal/brain/Destroy() //copypasted from MMIs.
	QDEL_NULL(brainmob)
	return ..()

/obj/item/organ/internal/brain/cluwne

/obj/item/organ/internal/brain/cluwne/insert(mob/living/target, special = 0, make_cluwne = 1)
	..(target, special = special)
	if(ishuman(target) && make_cluwne)
		var/mob/living/carbon/human/H = target
		H.makeCluwne() //No matter where you go, no matter what you do, you cannot escape