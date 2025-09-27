/obj/item/organ/internal
	origin_tech = "biotech=3"
	force = 1
	w_class = WEIGHT_CLASS_SMALL
	var/slot
	// DO NOT add slots with matching names to different zones - it will break internal_organs_slot list!
	var/non_primary = 0
	var/unremovable = FALSE //Whether it shows up as an option to remove during surgery.
	/// An associated list of organ datums that this organ has.
	var/list/datum/organ/organ_datums
	/// This contains the hidden RnD levels of an organ to prevent rnd from using it.
	var/hidden_origin_tech
	/// What is the level of tech for the hidden tech type?
	var/hidden_tech_level = 1
	/// How much is this organ worth in the xenobiology organ analyzer?
	var/analyzer_price = 10
	/// what quality is this organ? Only useful for xeno organs
	var/organ_quality = ORGAN_NORMAL
	/// Does this organ originate from the xenobiology dissection loop?
	var/is_xeno_organ = FALSE
	/// Does this organ give a warning upon being inserted?
	var/warning = FALSE
	/// Does this organ show outside the mob, and what is the icon state?
	var/augment_state = null
	/// Does this organ actually have a sprite for it being on the arm? And what is the path of it.
	var/augment_icon = null
	/// Does this organ have a extra render mechanic?
	var/do_extra_render = FALSE
	/// Does this organ ignore skin covers?
	var/always_show_augment = FALSE
	/// Does this organ have augmented skin to apply to the user on install? If so, apply it to the user and remove it.
	var/self_augmented_skin_level = 0

/obj/item/organ/internal/New(mob/living/carbon/holder)
	..()
	if(istype(holder))
		insert(holder)

/obj/item/organ/internal/Initialize(mapload)
	. = ..()
	if(!organ_datums)
		return
	var/list/temp_list = organ_datums.Copy()
	organ_datums = list()
	for(var/path in temp_list)
		var/datum/organ/organ_datum = new path(src)
		if(!organ_datum.organ_tag)
			stack_trace("There was an organ datum [organ_datum] ([organ_datum.type]), that had no organ tag.")
			continue
		organ_datums[organ_datum.organ_tag] = organ_datum

/obj/item/organ/internal/Destroy()
	if(owner) // we have to remove BEFORE organ_datums are qdel'd, or we can just live even if our heart organ got deleted
		remove(owner, TRUE)
	QDEL_LIST_ASSOC_VAL(organ_datums) // The removal from internal_organ_datums should be handled when the organ is removed
	. = ..()

/obj/item/organ/internal/examine(mob/user)
	. = ..()
	if(is_xeno_organ)
		. += "<span class='info'>It looks like it would replace \the [slot]."
	if(self_augmented_skin_level)
		. += "<span class='info'>It seems to have level-[self_augmented_skin_level] synthetic skin applied."

/obj/item/organ/internal/proc/insert(mob/living/carbon/M, special = 0, dont_remove_slot = 0)
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

	for(var/organ_tag in organ_datums)
		var/datum/organ/new_organ = organ_datums[organ_tag]
		M.internal_organ_datums[new_organ.organ_tag] = new_organ
		new_organ.on_insert(M)

	var/obj/item/organ/external/parent
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		parent = H.get_organ(check_zone(parent_organ))
		H.update_int_organs()
		if(!istype(parent))
			stack_trace("[src] attempted to insert into a [parent_organ], but [parent_organ] wasn't an organ! [atom_loc_line(M)]")
		else
			parent.internal_organs |= src
		if(self_augmented_skin_level)
			parent.apply_augmented_skin(self_augmented_skin_level)
			self_augmented_skin_level = 0
	loc = null
	for(var/X in actions)
		var/datum/action/A = X
		A.Grant(M)
	if(vital)
		M.update_stat("Vital organ inserted")
	STOP_PROCESSING(SSobj, src)
	if(owner.stat == DEAD)
		ADD_TRAIT(src, TRAIT_ORGAN_INSERTED_WHILE_DEAD, "[UID()]")
		RegisterSignal(owner, COMSIG_LIVING_DEFIBBED, PROC_REF(on_revival))


// Removes the given organ from its owner.
// Returns the removed object, which is usually just itself
// However, you MUST set the object's positiion yourself when you call this!
/obj/item/organ/internal/remove(mob/living/carbon/M, special = 0)
	if(!owner)
		stack_trace("\'remove\' called on [src] without an owner! Mob: [M], [atom_loc_line(M)]")
	SEND_SIGNAL(owner, COMSIG_CARBON_LOSE_ORGAN)
	REMOVE_TRAIT(src, TRAIT_ORGAN_INSERTED_WHILE_DEAD, "[UID()]")
	UnregisterSignal(owner, COMSIG_LIVING_DEFIBBED)

	owner = null
	if(M)
		M.internal_organs -= src
		if(M.internal_organs_slot[slot] == src)
			M.internal_organs_slot.Remove(slot)


		for(var/removal_tag in organ_datums)
			if(M.internal_organ_datums[removal_tag] == organ_datums[removal_tag])
				M.internal_organ_datums -= removal_tag
				var/datum/organ/removed = organ_datums[removal_tag]
				removed.on_remove(M)

		// Lets see if we have any backup organ datums from other internal organs.
		for(var/obj/item/organ/internal/backup_organ in M.internal_organs)
			for(var/replacement_tag in backup_organ.organ_datums)
				if(M.internal_organ_datums[replacement_tag]) // some other organ is already covering it
					continue
				var/datum/organ/replacement_organ = backup_organ.organ_datums[replacement_tag]
				M.internal_organ_datums[replacement_organ.organ_tag] = replacement_organ
				replacement_organ.on_replace(M)

		if(vital && !special)
			if(M.stat != DEAD)//safety check!
				M.death()

	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/parent = H.get_organ(check_zone(parent_organ))
		if(!istype(parent))
			stack_trace("[src] attempted to remove from a [parent_organ], but [parent_organ] didn't exist! [atom_loc_line(M)]")
		else
			parent.internal_organs -= src
		H.update_int_organs()

	for(var/X in actions)
		var/datum/action/A = X
		A.Remove(M)
	START_PROCESSING(SSobj, src)
	if(destroy_on_removal && !QDELETED(src))
		qdel(src)
		return
	return src

/obj/item/organ/internal/emp_act(severity)
	if(!is_robotic() || emp_proof)
		return

	var/we_done = FALSE
	for(var/organ_tag in organ_datums)
		var/datum/organ/borgan = organ_datums[organ_tag]
		if(borgan.on_successful_emp())
			we_done = TRUE

	if(we_done)
		return

	// No EMP handling was done, lets just give em damage
	switch(severity)
		if(EMP_HEAVY)
			receive_damage(20, 1)
		if(EMP_LIGHT)
			receive_damage(7, 1)
		if(EMP_WEAKENED)
			receive_damage(3, 1)

/obj/item/organ/internal/replaced(mob/living/carbon/human/target)
	insert(target)

/obj/item/organ/internal/necrotize(update_sprite, ignore_vital_death = FALSE)
	for(var/organ_tag in organ_datums) // let the organ datums handle first
		var/datum/organ/dead_organ = organ_datums[organ_tag]
		dead_organ.on_necrotize()
	return ..()

/obj/item/organ/internal/item_action_slot_check(slot, mob/user)
	return

/obj/item/organ/internal/proc/on_find(mob/living/finder)
	return

/obj/item/organ/internal/proc/on_life()
	return

/obj/item/organ/internal/proc/dead_process()
	return

//abstract proc called by carbon/death()
/obj/item/organ/internal/proc/on_owner_death()
	return

/obj/item/organ/internal/proc/prepare_eat()
	if(is_robotic())
		return //no eating cybernetic implants!
	var/obj/item/food/organ/S = new
	S.name = name
	S.desc = desc
	S.icon = icon
	S.icon_state = icon_state
	S.origin_tech = origin_tech
	S.w_class = w_class

	for(var/organ_tag in organ_datums)
		var/datum/organ/delicious = organ_datums[organ_tag]
		delicious.on_prepare_eat(S)

	return S

/obj/item/organ/internal/attempt_become_organ(obj/item/organ/external/parent,mob/living/carbon/human/H)
	if(parent_organ != parent.limb_name && parent_organ != "eyes" && parent_organ != "mouth")
		return FALSE
	insert(H)
	return TRUE

// Rendering!
/obj/item/organ/internal/proc/render()
	if(!augment_state || !augment_icon || !owner)
		return FALSE
	var/obj/item/organ/external/our_parent = owner.get_organ(parent_organ)
	if(!our_parent) // I don't know how you pulled that off, let us be safe.
		return FALSE
	if(our_parent.augmented_skin_cover_level && !always_show_augment)
		return FALSE

	return TRUE

// An extra render used in certain situations.
/obj/item/organ/internal/proc/extra_render()
	if(!augment_state || !augment_icon || !owner || !do_extra_render)
		return FALSE
	var/obj/item/organ/external/our_parent = owner.get_organ(parent_organ)
	if(!our_parent) // I don't know how you pulled that off, let us be safe.
		return FALSE
	if(our_parent.augmented_skin_cover_level && !always_show_augment)
		return FALSE

	return TRUE

/obj/item/organ/internal/attack__legacy__attackchain(mob/living/carbon/M, mob/user)
	if(M == user && ishuman(user))
		var/mob/living/carbon/human/H = user
		if(is_xeno_organ)
			to_chat(user, "<span class='warning'>It wouldnt be a very good idea to eat this.</span>")
			return ..()
		var/obj/item/food/S = prepare_eat()
		if(S)
			H.drop_item()
			H.put_in_active_hand(S)
			S.interact_with_atom(H, H)
			qdel(src)
	else
		..()

/obj/item/organ/internal/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	if(is_robotic() && istype(I, /obj/item/stack/synthetic_skin))
		var/obj/item/stack/synthetic_skin/skin = I
		skin.use(1)
		self_augmented_skin_level = skin.skin_level
		to_chat(user, "<span class='notice'>You apply [skin] to [src].</span>")
		return
	return ..()


/****************************************************
				INTERNAL ORGANS DEFINES
****************************************************/


// Brain is defined in brain_item.dm.

/obj/item/organ/internal/robotize(make_tough)
	if(!is_robotic())
		var/list/states = icon_states('icons/obj/surgery.dmi') //Insensitive to specially-defined icon files for species like the Drask or whomever else. Everyone gets the same robotic heart.
		if(slot == "heart" && ("[slot]-c-on" in states) && ("[slot]-c-off" in states)) //Give the robotic heart its robotic heart icons if they exist.
			var/obj/item/organ/internal/heart/H = src
			H.icon = icon('icons/obj/surgery.dmi')
			H.base_icon_state = "[slot]-c"
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


//debug and adminbus....

/obj/item/organ/internal/honktumor
	name = "banana tumor"
	desc = "A tiny yellow mass shaped like..a banana?"
	icon_state = "honktumor"
	origin_tech = "biotech=1"
	w_class = WEIGHT_CLASS_TINY
	parent_organ = "head"
	slot = "brain_tumor"
	destroy_on_removal = TRUE

	var/organhonked = 0
	var/suffering_delay = 900
	var/datum/component/squeak

/obj/item/organ/internal/honktumor/insert(mob/living/carbon/M, special = 0)
	..()
	M.dna.SetSEState(GLOB.clumsyblock, TRUE, TRUE)
	M.dna.SetSEState(GLOB.comicblock, TRUE, TRUE)
	singlemutcheck(M, GLOB.clumsyblock, MUTCHK_FORCED)
	singlemutcheck(M, GLOB.comicblock, MUTCHK_FORCED)
	organhonked = world.time
	M.AddElement(/datum/element/waddling)
	squeak = M.AddComponent(/datum/component/squeak, list('sound/items/bikehorn.ogg' = 1), 50, falloff_exponent = 20)

/obj/item/organ/internal/honktumor/remove(mob/living/carbon/M, special = 0)
	M.dna.SetSEState(GLOB.clumsyblock, FALSE)
	M.dna.SetSEState(GLOB.comicblock, FALSE)
	singlemutcheck(M, GLOB.clumsyblock, MUTCHK_FORCED)
	singlemutcheck(M, GLOB.comicblock, MUTCHK_FORCED)
	M.RemoveElement(/datum/element/waddling)
	QDEL_NULL(squeak)
	return ..()

/obj/item/organ/internal/honktumor/on_life()
	if(organhonked < world.time)
		organhonked = world.time + suffering_delay
		to_chat(owner, "<font color='red' size='7'>HONK</font>")
		owner.SetSleeping(0)
		owner.Stuttering(40 SECONDS)
		owner.Deaf(30 SECONDS)
		owner.Weaken(6 SECONDS)
		SEND_SOUND(owner, sound('sound/items/airhorn.ogg'))
		if(prob(30))
			owner.Stun(20 SECONDS)
			owner.Paralyse(8 SECONDS)
		else
			owner.Jitter(1000 SECONDS)

		if(ishuman(owner))
			var/mob/living/carbon/human/H = owner
			if(isobj(H.shoes))
				var/thingy = H.shoes
				if(H.drop_item_to_ground(H.shoes))
					GLOB.move_manager.move_away(thingy, H, 15, 2, timeout = 20)

/obj/item/organ/internal/honktumor/cursed
	unremovable = TRUE

/obj/item/organ/internal/honktumor/cursed/on_life() //No matter what you do, no matter who you are, no matter where you go, you're always going to be a fat, stuttering dimwit.
	..()
	owner.setBrainLoss(80, use_brain_mod = FALSE)
	owner.set_nutrition(9000)
	owner.overeatduration = 9000


/obj/item/organ/internal/honkbladder
	name = "honk bladder"
	desc = "a air filled sac that produces honking noises."
	icon_state = "honktumor"//Not making a new icon
	origin_tech = "biotech=1"
	w_class = WEIGHT_CLASS_TINY
	parent_organ = "groin"
	slot = "honk_bladder"
	destroy_on_removal = TRUE

	var/datum/component/squeak

/obj/item/organ/internal/honkbladder/insert(mob/living/carbon/M, special = 0)

	squeak = M.AddComponent(/datum/component/squeak, list('sound/effects/clownstep1.ogg'=1,'sound/effects/clownstep2.ogg'=1), 50, falloff_exponent = 20)

/obj/item/organ/internal/honkbladder/remove(mob/living/carbon/M, special = 0)
	QDEL_NULL(squeak)
	return ..()

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

	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		var/obj/item/organ/external/head/head_organ = H.get_organ("head")  // damn well better have a head if you have a beard
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

/obj/item/organ/internal/handle_germs()
	..()
	if(germ_level >= INFECTION_LEVEL_TWO)
		if(prob(3))	//about once every 30 seconds
			receive_damage(1, silent = prob(30))

/obj/item/organ/internal/proc/on_revival() //The goal of this proc / trait is to prevent one implanting organs in a corpse, in order to remove them with the organ extractor. Has to be legitimently implanted, or on just a living person, which has risk
	SIGNAL_HANDLER
	REMOVE_TRAIT(src, TRAIT_ORGAN_INSERTED_WHILE_DEAD, "[UID()]")
	UnregisterSignal(owner, COMSIG_LIVING_DEFIBBED)

/// Checks that the organ is inside of a host and that they are a valid recipient. Used for abductor glands
/obj/item/organ/internal/proc/owner_check()
	if(ishuman(owner) || iscarbon(owner))
		return TRUE
	return FALSE
