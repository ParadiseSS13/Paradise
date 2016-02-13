/obj/item/organ/internal/brain
	name = "brain"
	health = 400 //They need to live awhile longer than other organs.
	max_damage = 200
	icon_state = "brain2"
	force = 1.0
	w_class = 2.0
	throwforce = 1.0
	throw_speed = 3
	throw_range = 5
	origin_tech = "biotech=3"
	attack_verb = list("attacked", "slapped", "whacked")
	var/mob/living/carbon/brain/brainmob = null
	organ_tag = "brain"
	parent_organ = "head"
	slot = "brain"
	vital = 1

/obj/item/organ/internal/brain/surgeryize()
	if(!owner)
		return
	owner.ear_damage = 0 //Yeah, didn't you...hear? The ears are totally inside the brain.
	owner.ear_deaf = 0

/obj/item/organ/internal/brain/xeno
	name = "thinkpan"
	desc = "It looks kind of like an enormous wad of purple bubblegum."
	icon_state = "brain-x-d"

/obj/item/organ/internal/brain/New()
	..()
	spawn(5)
		if(brainmob && brainmob.client)
			brainmob.client.screen.len = null //clear the hud

/obj/item/organ/internal/brain/proc/transfer_identity(var/mob/living/carbon/H)
	brainmob = new(src)
	if(isnull(dna)) // someone didn't set this right...
		log_to_dd("[src] at [loc] did not contain a dna datum at time of removal.")
		dna = H.dna.Clone()
	name = "\the [dna.real_name]'s [initial(src.name)]"
	brainmob.dna = dna.Clone() // Silly baycode, what you do
//	brainmob.dna = H.dna.Clone() Putting in and taking out a brain doesn't make it a carbon copy of the original brain of the body you put it in
	brainmob.name = dna.real_name
	brainmob.real_name = dna.real_name
	brainmob.timeofhostdeath = H.timeofdeath
	if(H.mind)
		H.mind.transfer_to(brainmob)

	brainmob << "<span class='notice'>You feel slightly disoriented. That's normal when you're just a [initial(src.name)].</span>"
	callHook("debrain", list(brainmob))

/obj/item/organ/internal/brain/examine(mob/user) // -- TLE
	..(user)
	if(brainmob && brainmob.client)//if thar be a brain inside... the brain.
		user << "You can feel the small spark of life still left in this one."
	else
		user << "This one seems particularly lifeless. Perhaps it will regain some of its luster later.."

/obj/item/organ/internal/brain/remove(var/mob/living/user,var/special)

	//if(!owner) return ..() // Probably a redundant removal; just bail

	var/obj/item/organ/internal/brain/B = src
	if(istype(B) && istype(owner) && is_primary_organ())
		var/mob/living/simple_animal/borer/borer = owner.has_brain_worms()

		if(borer)
			borer.detatch() //Should remove borer if the brain is removed - RR

		owner.brain_op_stage = 4.0
		B.transfer_identity(owner)

	..()

/obj/item/organ/internal/brain/insert(var/mob/living/target)

	var/brain_already_exists = 0
	if(istype(target,/mob/living/carbon/human)) // No more IPC multibrain shenanigans
		//var/mob/living/carbon/human/H = target
		if(target.get_int_organ(/obj/item/organ/internal/brain))
			brain_already_exists = 1

	if(!brain_already_exists)
		if(target.key)
			target.ghostize()
		var/mob/living/carbon/C = target
		if(istype(C))
			C.brain_op_stage = 1.0
		if(brainmob)
			if(brainmob.mind)
				brainmob.mind.transfer_to(target)
			else
				target.key = brainmob.key
	..()

/obj/item/organ/internal/brain/prepare_eat()
	return // Too important to eat.

/obj/item/organ/internal/brain/slime
	name = "slime core"
	desc = "A complex, organic knot of jelly and crystalline particles."
	icon = 'icons/mob/slimes.dmi'
	icon_state = "green slime extract"

/obj/item/organ/internal/brain/golem
	name = "Runic mind"
	desc = "A tightly furled roll of paper, covered with indecipherable runes."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll"

/obj/item/organ/internal/brain/Destroy() //copypasted from MMIs.
	if(brainmob)
		qdel(brainmob)
		brainmob = null
	return ..()
