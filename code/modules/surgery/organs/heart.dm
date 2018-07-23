/obj/item/organ/internal/heart
	name = "heart"
	icon_state = "heart-on"
	organ_tag = "heart"
	parent_organ = "chest"
	slot = "heart"
	origin_tech = "biotech=5"
	var/beating = TRUE
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
		if(H.stat == DEAD)
			Stop()
			return

	spawn(120)
		if(!owner)
			Stop()

/obj/item/organ/internal/heart/emp_act(intensity)
	if(!is_robotic() || emp_proof)
		return
	Stop()

/obj/item/organ/internal/heart/necrotize()
	..()
	Stop()

/obj/item/organ/internal/heart/attack_self(mob/user)
	..()
	if(status & ORGAN_DEAD)
		to_chat(user, "<span class='warning'>You can't restart a dead heart.</span>")
		return
	if(!beating)
		Restart()
		spawn(80)
			if(!owner)
				Stop()

/obj/item/organ/internal/heart/safe_replace(mob/living/carbon/human/target)
	Restart()
	..()

/obj/item/organ/internal/heart/proc/Stop()
	beating = FALSE
	update_icon()
	return TRUE

/obj/item/organ/internal/heart/proc/Restart()
	beating = TRUE
	update_icon()
	return TRUE

/obj/item/organ/internal/heart/prepare_eat()
	var/obj/S = ..()
	S.icon_state = dead_icon
	return S

/obj/item/organ/internal/heart/cursed
	name = "cursed heart"
	desc = "it needs to be pumped..."
	icon_state = "cursedheart-off"
	icon_base = "cursedheart"
	origin_tech = "biotech=6"
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
		if(NO_BLOOD in H.dna.species.species_traits)
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
			if(!(NO_BLOOD in H.dna.species.species_traits))
				H.blood_volume = max(H.blood_volume - blood_loss, 0)
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
			if(!(NO_BLOOD in H.dna.species.species_traits))
				H.blood_volume = min(H.blood_volume + cursed_heart.blood_loss*0.5, BLOOD_VOLUME_NORMAL)
				if(owner.client)
					owner.client.color = ""

				H.adjustBruteLoss(-cursed_heart.heal_brute)
				H.adjustFireLoss(-cursed_heart.heal_burn)
				H.adjustOxyLoss(-cursed_heart.heal_oxy)

/obj/item/organ/internal/heart/cybernetic
	name = "cybernetic heart"
	desc = "An electronic device designed to mimic the functions of an organic human heart. Offers no benefit over an organic heart other than being easy to make."
	icon_state = "heart-c-on"
	icon_base = "heart-c"
	dead_icon = "heart-c-off"
	origin_tech = "biotech=5"
	status = ORGAN_ROBOT