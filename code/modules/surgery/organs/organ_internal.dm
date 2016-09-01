#define PROCESS_ACCURACY 10

/obj/item/organ/internal
	origin_tech = "biotech=2"
	force = 1
	w_class = 2
	throwforce = 0
	var/zone = "chest"
	var/slot
	vital = 0
	var/non_primary = 0

/obj/item/organ/internal/New(var/mob/living/carbon/holder)
	if(istype(holder))
		insert(holder)
	..()

/obj/item/organ/internal/Destroy()
	if(owner)
		remove(owner, 1)
	return ..()

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
	var/obj/item/organ/external/parent
	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		parent = H.get_organ(check_zone(parent_organ))
		if(!istype(parent))
			log_runtime(EXCEPTION("[src] attempted to insert into a [parent_organ], but [parent_organ] wasn't an organ! [atom_loc_line(M)]"), src)
		else
			parent.internal_organs |= src
	//M.internal_organs_by_name[src] |= src(H,1)
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

	for(var/X in actions)
		var/datum/action/A = X
		A.Remove(M)
	return src

/obj/item/organ/internal/replaced(var/mob/living/carbon/human/target,var/obj/item/organ/external/affected)
    insert(target)
    ..()

/obj/item/organ/internal/item_action_slot_check(slot, mob/user)
	return

/obj/item/organ/internal/proc/on_find(mob/living/finder)
	return

/obj/item/organ/internal/proc/on_life()
	return

/obj/item/organ/internal/proc/prepare_eat()
	if(status == ORGAN_ROBOT)
		return //no eating cybernetic implants!
	var/obj/item/weapon/reagent_containers/food/snacks/organ/S = new
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

/obj/item/weapon/reagent_containers/food/snacks/organ
	name = "appendix"
	icon_state = "appendix"
	icon = 'icons/obj/surgery.dmi'

/obj/item/weapon/reagent_containers/food/snacks/organ/New()
	..()

	reagents.add_reagent("nutriment", 5)


/obj/item/organ/internal/Destroy()
	if(owner)
		remove(owner, 1)
	return ..()

/obj/item/organ/internal/attack(mob/living/carbon/M, mob/user)
	if(M == user && ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/weapon/reagent_containers/food/snacks/S = prepare_eat()
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

/obj/item/organ/internal/heart
	name = "heart"
	icon_state = "heart-on"
	organ_tag = "heart"
	parent_organ = "chest"
	slot = "heart"
	origin_tech = "biotech=3"
	var/beating = 1
	dead_icon = "heart-off"
	var/icon_base = "heart"

/obj/item/organ/internal/heart/update_icon()
	if(beating)
		icon_state = "[icon_base]-on"
	else
		icon_state = "[icon_base]-off"

/obj/item/organ/internal/heart/remove(mob/living/carbon/M, special = 0)
	. = ..()
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.stat == DEAD || H.heart_attack)
			Stop()
			return
		if(!special)
			H.heart_attack = 1

	spawn(120)
		if(!owner)
			Stop()

/obj/item/organ/internal/heart/attack_self(mob/user)
	..()
	if(!beating)
		Restart()
		spawn(80)
			if(!owner)
				Stop()


/obj/item/organ/internal/heart/insert(mob/living/carbon/M, special = 0)
	..()
	if(ishuman(M) && beating)
		var/mob/living/carbon/human/H = M
		if(H.heart_attack)
			H.heart_attack = 0
			return

/obj/item/organ/internal/heart/proc/Stop()
	beating = 0
	update_icon()
	return 1

/obj/item/organ/internal/heart/proc/Restart()
	beating = 1
	update_icon()
	return 1

/obj/item/organ/internal/heart/prepare_eat()
	var/obj/S = ..()
	S.icon_state = "heart-off"
	return S

/obj/item/organ/internal/heart/cursed
	name = "cursed heart"
	desc = "it needs to be pumped..."
	icon_state = "cursedheart-off"
	icon_base = "cursedheart"
	origin_tech = "biotech=5"
	actions_types = list(/datum/action/item_action/organ_action/cursed_heart)
	var/last_pump = 0
	var/pump_delay = 30 //you can pump 1 second early, for lag, but no more (otherwise you could spam heal)
	var/blood_loss = 100 //600 blood is human default, so 5 failures (below 122 blood is where humans die because reasons?)

	//How much to heal per pump, negative numbers would HURT the player
	var/heal_brute = 0
	var/heal_burn = 0
	var/heal_oxy = 0


/obj/item/organ/internal/heart/cursed/attack(mob/living/carbon/human/H, mob/living/carbon/human/user, obj/target)
	if(H == user && istype(H))
		if(H.species.flags & NO_BLOOD || H.species.exotic_blood)
			to_chat(H, "<span class = 'userdanger'>\The [src] is not compatible with your form!</span>")
			return
		playsound(user,'sound/effects/singlebeat.ogg', 40, 1)
		user.drop_item()
		insert(user)
	else
		return ..()

/obj/item/organ/internal/heart/cursed/on_life()
	if(world.time > (last_pump + pump_delay))
		if(ishuman(owner) && owner.client) //While this entire item exists to make people suffer, they can't control disconnects.
			var/mob/living/carbon/human/H = owner
			H.vessel.remove_reagent("blood", blood_loss)
			to_chat(H, "<span class='userdanger'>You have to keep pumping your blood!</span>")
			if(H.client)
				H.client.color = "red" //bloody screen so real
		else
			last_pump = world.time //lets be extra fair *sigh*

/obj/item/organ/internal/heart/cursed/insert(mob/living/carbon/M, special = 0)
	..()
	if(owner)
		to_chat(owner, "<span class='userdanger'>Your heart has been replaced with a cursed one, you have to pump this one manually otherwise you'll die!</span>")


/datum/action/item_action/organ_action/cursed_heart
	name = "pump your blood"

//You are now brea- pumping blood manually
/datum/action/item_action/organ_action/cursed_heart/Trigger()
	. = ..()
	if(. && istype(target,/obj/item/organ/internal/heart/cursed))
		var/obj/item/organ/internal/heart/cursed/cursed_heart = target

		if(world.time < (cursed_heart.last_pump + (cursed_heart.pump_delay-10))) //no spam
			to_chat(owner, "<span class='userdanger'>Too soon!</span>")
			return

		cursed_heart.last_pump = world.time
		playsound(owner,'sound/effects/singlebeat.ogg',40,1)
		to_chat(owner, "<span class = 'notice'>Your heart beats.</span>")

		var/mob/living/carbon/human/H = owner
		if(istype(H))
			H.vessel.add_reagent("blood", (cursed_heart.blood_loss*0.5))//gain half the blood back from a failure
			if(owner.client)
				owner.client.color = ""

			H.adjustBruteLoss(-cursed_heart.heal_brute)
			H.adjustFireLoss(-cursed_heart.heal_burn)
			H.adjustOxyLoss(-cursed_heart.heal_oxy)

/obj/item/organ/internal/lungs
	name = "lungs"
	icon_state = "lungs"
	gender = PLURAL
	organ_tag = "lungs"
	parent_organ = "chest"
	slot = "lungs"
	vital = 1

//Insert something neat here.
///obj/item/organ/internal/lungs/remove(mob/living/carbon/M, special = 0)
//	owner.losebreath += 10
	//insert oxy damage extream here.
//	. = ..()


/obj/item/organ/internal/lungs/process()
	..()

	if(!owner)
		return
	if(germ_level > INFECTION_LEVEL_ONE)
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
	var/list/eye_colour = list(0,0,0)

/obj/item/organ/internal/eyes/proc/update_colour()
	dna.write_eyes_attributes(src)

/obj/item/organ/internal/eyes/insert(mob/living/carbon/M, special = 0)
	..()
	if(istype(M) && eye_colour)
		var/mob/living/carbon/human/H = M
		// Apply our eye colour to the target.
		H.update_body()

/obj/item/organ/internal/eyes/surgeryize()
	if(!owner)
		return
	owner.disabilities &= ~NEARSIGHTED
	owner.disabilities &= ~BLIND
	owner.eye_blurry = 0
	owner.eye_blind = 0


/obj/item/organ/internal/liver
	name = "liver"
	icon_state = "liver"
	organ_tag = "liver"
	parent_organ = "groin"
	slot = "liver"
	var/alcohol_intensity = 1

/obj/item/organ/internal/liver/process()

	..()

	if(!owner)
		return

	if(germ_level > INFECTION_LEVEL_ONE)
		if(prob(1))
			to_chat(owner, "<span class='warning'> Your skin itches.</span>")
	if(germ_level > INFECTION_LEVEL_TWO)
		if(prob(1))
			spawn owner.vomit()

	if(owner.life_tick % PROCESS_ACCURACY == 0)

		//High toxins levels are dangerous
		if(owner.getToxLoss() >= 60 && !owner.reagents.has_reagent("charcoal"))
			//Healthy liver suffers on its own
			if(src.damage < min_broken_damage)
				src.damage += 0.2 * PROCESS_ACCURACY
			//Damaged one shares the fun
			else
				var/obj/item/organ/internal/O = pick(owner.internal_organs)
				if(O)
					O.damage += 0.2  * PROCESS_ACCURACY

		//Detox can heal small amounts of damage
		if(src.damage && src.damage < src.min_bruised_damage && owner.reagents.has_reagent("charcoal"))
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
	origin_tech = "biotech=4"
	w_class = 1
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
	w_class = 1
	parent_organ = "head"
	slot = "brain_tumor"
	health = 3
	var/organhonked = 0

/obj/item/organ/internal/honktumor/New()
	..()
	processing_objects.Add(src)

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

/obj/item/organ/internal/honktumor/Destroy()
	processing_objects.Remove(src)
	return ..()

/obj/item/organ/internal/honktumor/process()
	if(isturf(loc))
		visible_message("<span class='warning'>[src] honks in on itself!</span>")
		new /obj/item/weapon/bananapeel(get_turf(loc))
		qdel(src)


/obj/item/organ/internal/honktumor/on_life()

	if(!owner)
		return

	if(organhonked < world.time)
		organhonked = world.time+900
		to_chat(owner, "<font color='red' size='7'>HONK</font>")
		owner.sleeping = 0
		owner.stuttering = 20
		owner.adjustEarDamage(0, 30)
		owner.Weaken(3)
		owner << 'sound/items/AirHorn.ogg'
		if(prob(30))
			owner.Stun(10)
			owner.Paralyse(4)
		else
			owner.Jitter(500)

		if(istype(owner, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = owner
			if(isobj(H.shoes))
				var/thingy = H.shoes
				if(H.unEquip(H.shoes))
					walk_away(thingy,H,15,2)
					spawn(20)
						if(thingy)
							walk(thingy,0)
	..()

/obj/item/organ/internal/honktumor/cursed

/obj/item/organ/internal/honktumor/cursed/remove(mob/living/carbon/M, special = 0, clean_remove = 0)
	. = ..()
	if(!clean_remove)
		visible_message("<span class='warning'>[src] vanishes into dust, and a [M] emits a loud honk!</span>", "<span class='notice'>You hear a loud honk.</span>")
		insert(M) //You're not getting away that easily!
	else
		qdel(src)

/obj/item/organ/internal/beard
	name = "beard organ"
	desc = "Let they who is worthy wear the beard of Thorbjorndottir."
	icon_state = "liver"
	origin_tech = "biotech=1"
	w_class = 1
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
			head_organ.r_hair = 216
			head_organ.g_hair = 192
			head_organ.b_hair = 120
			H.update_hair()
		if(!(head_organ.f_style == "Very Long Beard"))
			head_organ.f_style = "Very Long Beard"
			head_organ.r_facial = 216
			head_organ.g_facial = 192
			head_organ.b_facial = 120
			H.update_fhair()
