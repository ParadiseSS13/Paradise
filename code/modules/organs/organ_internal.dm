#define PROCESS_ACCURACY 10

/****************************************************
				INTERNAL ORGANS DEFINES
****************************************************/
// What's in your guts should probably be of a different type than what goes on your body
// Limbs don't have an organ they're INSIDE, while internal ones do
// If you can't tell I'm aping this off of -tg-code while keeping things relatively similar to how they are now
// Maybe I'll shatter 50 planets as I try this. Oops. -- Crazylemon
/obj/item/organ/internal
	force = 1
	var/slot
	w_class  = 2 // What better to keep close to your heart, than another heart? Take this as literally as you please
	// I think parent_organ should handle organ containment
	var/organ_action_name = null // Hmm, I get a bad feeling about this one

/obj/item/organ/internal/New(var/mob/living/carbon/holder)
	,.(holder)
	if(istype(holder)) // We can't just do species and human checks, or xenos get left out of the fun


// Use 0 if, for some cruel reason, you want to kill someone while giving them a cool new heart
/obj/item/organ/internal/proc/Insert(var/mob/living/carbon/M, var/mob/living/user = null, var/swapout = 1)
	if(!iscarbon(M) || owner == M)
		return
	removed(user) // now admins can insert someone's heart into someone else and have !!FUN!! results

	var/obj/item/organ/internal/replaced = M.getorganslot(slot)
	if(replaced)
		replaced.removed(user, swapout)

	owner = M
	M.internal_organs |= src
	loc = owner // Maybe I should stick this in the parent_organ, I'll find out with other's insight
	if (organ_action_name)
		action_button_name = organ_action_name

/obj/item/organ/internal/removed(var/mob/living/user, var/swapout = 0)
	if(!owner)
		return

	owner.internal_organs_by_name[organ_tag] = null
	owner.internal_organs_by_name -= organ_tag
	owner.internal_organs_by_name -= null
	owner.internal_organs -= src

	var/obj/item/organ/external/affected = owner.get_organ(parent_organ)
	if(affected) affected.internal_organs -= src

	owner = null

// Brain is defined in brain_item.dm.
/obj/item/organ/heart
	name = "heart"
	icon_state = "heart-on"
	organ_tag = "heart"
	parent_organ = "chest"
	dead_icon = "heart-off"
	vital = 1

/obj/item/organ/lungs
	name = "lungs"
	icon_state = "lungs"
	gender = PLURAL
	organ_tag = "lungs"
	parent_organ = "chest"

/obj/item/organ/lungs/process()
	..()

	if(!owner)
		return

	if (germ_level > INFECTION_LEVEL_ONE)
		if(prob(5))
			owner.emote("cough")		//respitory tract infection

	if(is_bruised())
		if(prob(2))
			spawn owner.custom_emote(1, "coughs up blood!")
			owner.drip(10)
		if(prob(4))
			spawn owner.custom_emote(1, "gasps for air!")
			owner.losebreath += 5

/obj/item/organ/kidneys
	name = "kidneys"
	icon_state = "kidneys"
	gender = PLURAL
	organ_tag = "kidneys"
	parent_organ = "groin"

/obj/item/organ/kidneys/process()

	..()

	if(!owner)
		return

	// Coffee is really bad for you with busted kidneys.
	// This should probably be expanded in some way, but fucked if I know
	// what else kidneys can process in our reagent list.
	var/datum/reagent/coffee = locate(/datum/reagent/drink/coffee) in owner.reagents.reagent_list
	if(coffee)
		if(is_bruised())
			owner.adjustToxLoss(0.1 * PROCESS_ACCURACY)
		else if(is_broken())
			owner.adjustToxLoss(0.3 * PROCESS_ACCURACY)


/obj/item/organ/eyes
	name = "eyeballs"
	icon_state = "eyes"
	gender = PLURAL
	organ_tag = "eyes"
	parent_organ = "head"
	var/list/eye_colour = list(0,0,0)

/obj/item/organ/eyes/proc/update_colour()
	if(!owner)
		return
	eye_colour = list(
		owner.r_eyes ? owner.r_eyes : 0,
		owner.g_eyes ? owner.g_eyes : 0,
		owner.b_eyes ? owner.b_eyes : 0
		)

/obj/item/organ/eyes/surgeryize()
	if(!owner)
		return
	owner.disabilities &= ~NEARSIGHTED
	owner.sdisabilities &= ~BLIND
	owner.eye_blurry = 0
	owner.eye_blind = 0

/obj/item/organ/liver
	name = "liver"
	icon_state = "liver"
	organ_tag = "liver"
	parent_organ = "groin"

/obj/item/organ/liver/process()

	..()

	if(!owner)
		return

	if (germ_level > INFECTION_LEVEL_ONE)
		if(prob(1))
			owner << "\red Your skin itches."
	if (germ_level > INFECTION_LEVEL_TWO)
		if(prob(1))
			spawn owner.vomit()

	if(owner.life_tick % PROCESS_ACCURACY == 0)

		//High toxins levels are dangerous
		if(owner.getToxLoss() >= 60 && !owner.reagents.has_reagent("charcoal"))
			//Healthy liver suffers on its own
			if (src.damage < min_broken_damage)
				src.damage += 0.2 * PROCESS_ACCURACY
			//Damaged one shares the fun
			else
				var/obj/item/organ/O = pick(owner.internal_organs)
				if(O)
					O.damage += 0.2  * PROCESS_ACCURACY

		//Detox can heal small amounts of damage
		if (src.damage && src.damage < src.min_bruised_damage && owner.reagents.has_reagent("charcoal"))
			src.damage -= 0.2 * PROCESS_ACCURACY

		if(src.damage < 0)
			src.damage = 0

		// Get the effectiveness of the liver.
		var/filter_effect = 3
		if(is_bruised())
			filter_effect -= 1
		if(is_broken())
			filter_effect -= 2

		// Damaged liver means some chemicals are very dangerous
		if(src.damage >= src.min_bruised_damage)
			for(var/datum/reagent/R in owner.reagents.reagent_list)
				// Ethanol and all drinks are bad
				if(istype(R, /datum/reagent/ethanol))
					owner.adjustToxLoss(0.1 * PROCESS_ACCURACY)

			// Can't cope with toxins at all
			for(var/toxin in list("toxin", "plasma", "sacid", "facid", "cyanide", "amanitin", "carpotoxin"))
				if(owner.reagents.has_reagent(toxin))
					owner.adjustToxLoss(0.3 * PROCESS_ACCURACY)

/obj/item/organ/appendix
	name = "appendix"
	icon_state = "appendix"
	organ_tag = "appendix"
	parent_organ = "groin"


/*
/obj/item/organ/appendix/removed()

	if(owner)
		var/inflamed = 0
		for(var/datum/disease/appendicitis/appendicitis in owner.viruses)
			inflamed = 1
			appendicitis.cure()
			owner.resistances += appendicitis
		if(inflamed)
			icon_state = "appendixinflamed"
			name = "inflamed appendix"
	..()
*/