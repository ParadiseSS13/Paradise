/obj/item/organ/internal
	origin_tech = "biotech=3"
	force = 1
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 0
	var/slot
	// DO NOT add slots with matching names to different zones - it will break internal_organs_slot list!
	var/non_primary = 0
	var/unremovable = FALSE //Whether it shows up as an option to remove during surgery.

/obj/item/organ/internal/New(var/mob/living/carbon/holder)
	..()
	if(istype(holder))
		insert(holder)

/obj/item/organ/internal/proc/insert(mob/living/carbon/M, special = 0, var/dont_remove_slot = 0)
	if(!iscarbon(M) || owner == M)
		return

	var/obj/item/organ/internal/replaced = M.get_organ_slot(slot)
	if(replaced)
		if(dont_remove_slot)
			non_primary = 1
		else
			replaced.remove(M, special = 1)

	owner = M

	M.internal_organs |= src
	M.internal_organs_slot[slot] = src
	var/obj/item/organ/external/parent
	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		parent = H.get_organ(check_zone(parent_organ))
		if(!istype(parent))
			log_runtime(EXCEPTION("[src] attempted to insert into a [parent_organ], but [parent_organ] wasn't an organ! [atom_loc_line(M)]"), src)
		else
			parent.internal_organs |= src
	//M.internal_bodyparts_by_name[src] |= src(H,1)
	loc = null
	for(var/X in actions)
		var/datum/action/A = X
		A.Grant(M)

// Removes the given organ from its owner.
// Returns the removed object, which is usually just itself
// However, you MUST set the object's positiion yourself when you call this!
/obj/item/organ/internal/remove(mob/living/carbon/M, special = 0)
	if(!owner)
		log_runtime(EXCEPTION("\'remove\' called on [src] without an owner! Mob: [M], [atom_loc_line(M)]"), src)
	owner = null
	if(M)
		M.internal_organs -= src
		if(M.internal_organs_slot[slot] == src)
			M.internal_organs_slot.Remove(slot)
		if(vital && !special)
			if(M.stat != DEAD)//safety check!
				M.death()

	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/parent = H.get_organ(check_zone(parent_organ))
		if(!istype(parent))
			log_runtime(EXCEPTION("[src] attempted to remove from a [parent_organ], but [parent_organ] didn't exist! [atom_loc_line(M)]"), src)
		else
			parent.internal_organs -= src
		H.update_int_organs()

	for(var/X in actions)
		var/datum/action/A = X
		A.Remove(M)
	return src

/obj/item/organ/internal/replaced(var/mob/living/carbon/human/target)
    insert(target)

/obj/item/organ/internal/item_action_slot_check(slot, mob/user)
	return

/obj/item/organ/internal/proc/on_find(mob/living/finder)
	return

/obj/item/organ/internal/proc/on_life()
	return

//abstract proc called by carbon/death()
/obj/item/organ/internal/proc/on_owner_death()
 	return

/obj/item/organ/internal/proc/prepare_eat()
	if(is_robotic())
		return //no eating cybernetic implants!
	var/obj/item/reagent_containers/food/snacks/organ/S = new
	S.name = name
	S.desc = desc
	S.icon = icon
	S.icon_state = icon_state
	S.origin_tech = origin_tech
	S.w_class = w_class

	return S

/obj/item/organ/internal/attempt_become_organ(obj/item/organ/external/parent,mob/living/carbon/human/H)
	if(parent_organ != parent.limb_name)
		return 0
	insert(H)
	return 1

// Rendering!
/obj/item/organ/internal/proc/render()
	return

/obj/item/reagent_containers/food/snacks/organ
	name = "appendix"
	icon_state = "appendix"
	icon = 'icons/obj/surgery.dmi'

/obj/item/reagent_containers/food/snacks/organ/New()
	..()

	reagents.add_reagent("nutriment", 5)

/obj/item/organ/internal/attack(mob/living/carbon/M, mob/user)
	if(M == user && ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/reagent_containers/food/snacks/S = prepare_eat()
		if(S)
			H.drop_item()
			H.put_in_active_hand(S)
			S.attack(H, H)
			qdel(src)
	else
		..()

/****************************************************
				INTERNAL ORGANS DEFINES
****************************************************/


// Brain is defined in brain_item.dm.

/obj/item/organ/internal/robotize()
	if(!is_robotic())
		var/list/states = icon_states('icons/obj/surgery.dmi') //Insensitive to specially-defined icon files for species like the Drask or whomever else. Everyone gets the same robotic heart.
		if(slot == "heart" && ("[slot]-c-on" in states) && ("[slot]-c-off" in states)) //Give the robotic heart its robotic heart icons if they exist.
			var/obj/item/organ/internal/heart/H = src
			H.icon = icon('icons/obj/surgery.dmi')
			H.icon_base = "[slot]-c"
			H.dead_icon = "[slot]-c-off"
			H.update_icon()
		else if("[slot]-c" in states) //Give the robotic organ its robotic organ icons if they exist.
			icon = icon('icons/obj/surgery.dmi')
			icon_state = "[slot]-c"
		name = "cybernetic [slot]"
	..() //Go apply all the organ flags/robotic statuses.

/obj/item/organ/internal/appendix
	name = "appendix"
	icon_state = "appendix"
	organ_tag = "appendix"
	parent_organ = "groin"
	slot = "appendix"
	var/inflamed = 0

/obj/item/organ/internal/appendix/remove(mob/living/carbon/M, special = 0)
	for(var/datum/disease/appendicitis/A in M.viruses)
		A.cure()
		inflamed = 1
	update_icon()
	. = ..()

/obj/item/organ/internal/appendix/insert(mob/living/carbon/M, special = 0)
	..()
	if(inflamed)
		M.AddDisease(new /datum/disease/appendicitis)

/obj/item/organ/internal/appendix/prepare_eat()
	var/obj/S = ..()
	if(inflamed)
		S.reagents.add_reagent("????", 5)
	return S

//shadowling tumor
/obj/item/organ/internal/shadowtumor
	name = "black tumor"
	desc = "A tiny black mass with red tendrils trailing from it. It seems to shrivel in the light."
	icon_state = "blacktumor"
	origin_tech = "biotech=5"
	w_class = WEIGHT_CLASS_TINY
	parent_organ = "head"
	slot = "brain_tumor"
	health = 3

/obj/item/organ/internal/shadowtumor/New()
	..()
	processing_objects.Add(src)

/obj/item/organ/internal/shadowtumor/Destroy()
	processing_objects.Remove(src)
	return ..()

/obj/item/organ/internal/shadowtumor/process()
	if(isturf(loc))
		var/turf/T = loc
		var/light_count = T.get_lumcount()*10
		if(light_count > 4 && health > 0) //Die in the light
			health--
		else if(light_count < 2 && health < 3) //Heal in the dark
			health++
		if(health <= 0)
			visible_message("<span class='warning'>[src] collapses in on itself!</span>")
			qdel(src)

//debug and adminbus....

/obj/item/organ/internal/honktumor
	name = "banana tumor"
	desc = "A tiny yellow mass shaped like..a banana?"
	icon_state = "honktumor"
	origin_tech = "biotech=1"
	w_class = WEIGHT_CLASS_TINY
	parent_organ = "head"
	slot = "brain_tumor"
	health = 3
	var/organhonked = 0
	var/suffering_delay = 900

/obj/item/organ/internal/honktumor/insert(mob/living/carbon/M, special = 0)
	..()
	M.mutations.Add(CLUMSY)
	M.mutations.Add(COMICBLOCK)
	M.dna.SetSEState(CLUMSYBLOCK,1,1)
	M.dna.SetSEState(COMICBLOCK,1,1)
	genemutcheck(M,CLUMSYBLOCK,null,MUTCHK_FORCED)
	genemutcheck(M,COMICBLOCK,null,MUTCHK_FORCED)
	organhonked = world.time

/obj/item/organ/internal/honktumor/remove(mob/living/carbon/M, special = 0)
	. = ..()

	M.mutations.Remove(CLUMSY)
	M.mutations.Remove(COMICBLOCK)
	M.dna.SetSEState(CLUMSYBLOCK,0)
	M.dna.SetSEState(COMICBLOCK,0)
	genemutcheck(M,CLUMSYBLOCK,null,MUTCHK_FORCED)
	genemutcheck(M,COMICBLOCK,null,MUTCHK_FORCED)
	qdel(src)

/obj/item/organ/internal/honktumor/on_life()
	if(organhonked < world.time)
		organhonked = world.time + suffering_delay
		to_chat(owner, "<font color='red' size='7'>HONK</font>")
		owner.SetSleeping(0)
		owner.Stuttering(20)
		owner.MinimumDeafTicks(30)
		owner.Weaken(3)
		owner << 'sound/items/airhorn.ogg'
		if(prob(30))
			owner.Stun(10)
			owner.Paralyse(4)
		else
			owner.Jitter(500)

		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if(isobj(H.shoes))
				var/thingy = H.shoes
				if(H.unEquip(H.shoes))
					walk_away(thingy,H,15,2)
					spawn(20)
						if(thingy)
							walk(thingy,0)

/obj/item/organ/internal/honktumor/cursed
	unremovable = TRUE

/obj/item/organ/internal/honktumor/cursed/on_life() //No matter what you do, no matter who you are, no matter where you go, you're always going to be a fat, stuttering dimwit.
	..()
	owner.setBrainLoss(80)
	owner.nutrition = 9000
	owner.overeatduration = 9000

/obj/item/organ/internal/beard
	name = "beard organ"
	desc = "Let they who is worthy wear the beard of Thorbjorndottir."
	icon_state = "liver"
	origin_tech = "biotech=1"
	w_class = WEIGHT_CLASS_TINY
	parent_organ = "head"
	slot = "hair_organ"

/obj/item/organ/internal/beard/on_life()

	if(!owner)
		return

	if(istype(owner, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = owner
		var/obj/item/organ/external/head/head_organ = H.get_organ("head")
		if(!(head_organ.h_style == "Very Long Hair" || head_organ.h_style == "Mohawk"))
			if(prob(10))
				head_organ.h_style = "Mohawk"
			else
				head_organ.h_style = "Very Long Hair"
			head_organ.hair_colour = "#D8C078"
			H.update_hair()
		if(!(head_organ.f_style == "Very Long Beard"))
			head_organ.f_style = "Very Long Beard"
			head_organ.facial_colour = "#D8C078"
			H.update_fhair()
