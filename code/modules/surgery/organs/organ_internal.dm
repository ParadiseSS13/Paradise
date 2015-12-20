#define PROCESS_ACCURACY 10

/****************************************************
				INTERNAL ORGANS DEFINES
****************************************************/
/obj/item/organ/internal
	origin_tech = "biotech=2"
	force = 1
	w_class = 2
	throwforce = 0
	organ_tag = "guts"
	parent_organ = "chest" //aka the zone
	var/slot
	vital = 0
	var/organ_action_name = null

/obj/item/organ/internal/proc/Insert(mob/living/carbon/M, special = 0)//insert the thing into the slot
	if(!iscarbon(M) || owner == M)
		return

	var/obj/item/organ/internal/replaced = M.get_organ_slot(slot)
	if(replaced)
		replaced.Remove(M, special = 1)

	owner = M
	M.internal_organs |= src
	M.internal_organs_by_name[organ_tag] = src
	loc = null
	if(organ_action_name)
		action_button_name = organ_action_name

/obj/item/organ/internal/proc/Remove(mob/living/carbon/M, special = 0)
	owner = null
	if(M)
		M.internal_organs_by_name[organ_tag] = null
		M.internal_organs_by_name -= organ_tag
		M.internal_organs_by_name -= null
		M.internal_organs -= src

		loc = get_turf(M)
		processing_objects |= src
		var/datum/reagent/blood/organ_blood
		if(reagents) organ_blood = locate(/datum/reagent/blood) in reagents.reagent_list
		if(!organ_blood || !organ_blood.data["blood_DNA"])
			M.vessel.trans_to(src, 5, 1, 1)

		if(vital && !special)
			//if(user)
			//	user.attack_log += "\[[time_stamp()]\]<font color='red'> removed a vital organ ([src]) from [key_name(M)] (INTENT: [uppertext(user.a_intent)])</font>"
			//	M.attack_log += "\[[time_stamp()]\]<font color='orange'> had a vital organ ([src]) removed by [key_name(user)] (INTENT: [uppertext(user.a_intent)])</font>"
			//	msg_admin_attack("[key_name_admin(user)] removed a vital organ ([src]) from [key_name_admin(M)]")
			M.death()


	if(organ_action_name)
		action_button_name = null

/obj/item/organ/internal/proc/on_find(mob/living/finder)
	return

/obj/item/organ/internal/proc/on_life()
	return


/obj/item/organ/internal/proc/prepare_eat()
	var/obj/item/weapon/reagent_containers/food/snacks/organ/S = new
	S.name = name
	S.desc = desc
	S.icon = icon
	S.icon_state = icon_state
	S.origin_tech = origin_tech
	S.w_class = w_class

	return S

/obj/item/weapon/reagent_containers/food/snacks/organ
	name = "appendix"
	icon_state = "appendix"
	icon = 'icons/obj/surgery.dmi'

	reagents.add_reagent("nutriment",5)


/obj/item/organ/internal/Destroy()
	if(owner)
		Remove(owner, 1)
	return

/obj/item/organ/internal/attack(mob/living/carbon/M, mob/user)
	if(robotic)
		return

	if(M == user && ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/weapon/reagent_containers/food/snacks/S = prepare_eat()
			if(S)
				H.unEquip()
				H.put_in_active_hand(S)
				if(fingerprints) S.fingerprints = fingerprints.Copy()
				if(fingerprintshidden) S.fingerprintshidden = fingerprintshidden.Copy()
				if(fingerprintslast) S.fingerprintslast = fingerprintslast
				S.attack(H, H)
				qdel(src)
	else
		..()


///THE ORGANS

// Brain is defined in brain_item.dm.
/obj/item/organ/internal/heart
	name = "heart"
	icon_state = "heart-on"
	organ_tag = "heart"
	parent_organ = "chest"
	slot = "heart"
	origin_tech = "biotech=3"
	vital = 1
	var/beating

/obj/item/organ/internal/heart/update_icon()
	if(beating)
		icon_state = "heart-on"
	else
		icon_state = "heart-off"

/obj/item/organ/internal/heart/Insert(mob/living/carbon/M, special = 0)
	..()
	beating = 1
	update_icon()

/obj/item/organ/internal/heart/Remove(mob/living/carbon/M, special = 0)
	..()
	spawn(120)
		beating = 0
		update_icon()

/obj/item/organ/internal/heart/prepare_eat()
	var/obj/S = ..()
	S.icon_state = "heart-off"
	return S

/obj/item/organ/internal/lungs
	name = "lungs"
	icon_state = "lungs"
	gender = PLURAL
	organ_tag = "lungs"
	parent_organ = "chest"
	slot = "lungs"
	origin_tech = "biotech=2"

/obj/item/organ/internal/lungs/process()///Fethas note, Should this be organ on life?
	..()
//to_do per fethas: Could we handle some of the species breathing in here?

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

/obj/item/organ/internal/kidneys
	name = "kidneys"
	icon_state = "kidneys"
	gender = PLURAL
	organ_tag = "kidneys"
	parent_organ = "groin"
	slot = "kidneys"
	origin_tech = "biotech=2"


/obj/item/organ/internal/kidneys/process()

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


/obj/item/organ/internal/eyes
	name = "eyeballs"
	icon_state = "eyes"
	gender = PLURAL
	organ_tag = "eyes"
	parent_organ = "head"
	slot = "eyes"
	origin_tech = "biotech=2"
	var/list/eye_colour = list(0,0,0)

/obj/item/organ/internal/eyes/proc/update_colour()
	if(!owner)
		return
	eye_colour = list(
		owner.r_eyes ? owner.r_eyes : 0,
		owner.g_eyes ? owner.g_eyes : 0,
		owner.b_eyes ? owner.b_eyes : 0
		)

/obj/item/organ/internal/eyes/Insert(mob/living/carbon/M, special = 0)
	..()
	// Apply our eye colour to the target.
	if(istype(M) && eye_colour)
		M.r_eyes = eye_colour[1]
		M.g_eyes = eye_colour[2]
		M.b_eyes = eye_colour[3]
		M.update_eyes()


/obj/item/organ/internal/eyes/surgeryize()
	if(!owner)
		return
	owner.disabilities &= ~NEARSIGHTED
	owner.sdisabilities &= ~BLIND
	owner.eye_blurry = 0
	owner.eye_blind = 0

/obj/item/organ/internal/liver
	name = "liver"
	icon_state = "liver"
	organ_tag = "liver"
	parent_organ = "groin"
	slot = "liver"
	origin_tech = "biotech=1"

/obj/item/organ/internal/liver/process()

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

/obj/item/organ/internal/appendix
	name = "appendix"
	icon_state = "appendix"
	organ_tag = "appendix"
	parent_organ = "groin"
	slot = "appendix"
	origin_tech = "biotech=1"

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

//shadowling brain tumor
/obj/item/organ/internal/shadowtumor
	name = "black tumor"
	desc = "A tiny black mass with red tendrils trailing from it. It seems to shrivel in the light."
	icon_state = "blacktumor"
	origin_tech = "biotech=4"
	w_class = 1
	organ_tag = "blacktumor"
	parent_organ = "head"
	slot = "brain_tumor"
	health = 3

/obj/item/organ/internal/shadowtumor/New()
	..()
	processing_object.Add(src)

/obj/item/organ/internal/shadowtumor/Destroy()
	processing_object.Remove(src)
	..()

/obj/item/organ/internal/shadowtumor/process()
	if(isturf(loc))
		var/turf/T = loc
		var/light_count = T.get_lumcount()
		if(light_count > 4 && health > 0) //Die in the light
			health--
		else if(light_count < 2 && health < 3) //Heal in the dark
			health++
		if(health <= 0)
			visible_message("<span class='warning'>[src] collapses in on itself!</span>")
			qdel(src)