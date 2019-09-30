//Largely beneficial effects go here, even if they have drawbacks. An example is provided in Shadow Mend.

/datum/status_effect/shadow_mend
	id = "shadow_mend"
	duration = 30
	alert_type = /obj/screen/alert/status_effect/shadow_mend

/obj/screen/alert/status_effect/shadow_mend
	name = "Shadow Mend"
	desc = "Shadowy energies wrap around your wounds, sealing them at a price. After healing, you will slowly lose health every three seconds for thirty seconds."
	icon_state = "shadow_mend"

/datum/status_effect/shadow_mend/on_apply()
	owner.visible_message("<span class='notice'>Violet light wraps around [owner]'s body!</span>", "<span class='notice'>Violet light wraps around your body!</span>")
	playsound(owner, 'sound/magic/teleport_app.ogg', 50, 1)
	return ..()

/datum/status_effect/shadow_mend/tick()
	owner.adjustBruteLoss(-15)
	owner.adjustFireLoss(-15)

/datum/status_effect/shadow_mend/on_remove()
	owner.visible_message("<span class='warning'>The violet light around [owner] glows black!</span>", "<span class='warning'>The tendrils around you cinch tightly and reap their toll...</span>")
	playsound(owner, 'sound/magic/teleport_diss.ogg', 50, 1)
	owner.apply_status_effect(STATUS_EFFECT_VOID_PRICE)


/datum/status_effect/void_price
	id = "void_price"
	duration = 300
	tick_interval = 30
	alert_type = /obj/screen/alert/status_effect/void_price

/obj/screen/alert/status_effect/void_price
	name = "Void Price"
	desc = "Black tendrils cinch tightly against you, digging wicked barbs into your flesh."
	icon_state = "shadow_mend"

/datum/status_effect/void_price/tick()
	playsound(owner, 'sound/weapons/bite.ogg', 50, 1)
	owner.adjustBruteLoss(3)

/datum/status_effect/blooddrunk
	id = "blooddrunk"
	duration = 10
	tick_interval = 0
	alert_type = /obj/screen/alert/status_effect/blooddrunk

/obj/screen/alert/status_effect/blooddrunk
	name = "Blood-Drunk"
	desc = "You are drunk on blood! Your pulse thunders in your ears! Nothing can harm you!" //not true, and the item description mentions its actual effect
	icon_state = "blooddrunk"

/datum/status_effect/blooddrunk/on_apply()
	. = ..()
	if(.)
		if(ishuman(owner))
			owner.status_flags |= IGNORESLOWDOWN
			var/mob/living/carbon/human/H = owner
			for(var/X in H.bodyparts)
				var/obj/item/organ/external/BP = X
				BP.brute_mod *= 0.1
				BP.burn_mod *= 0.1
			H.dna.species.tox_mod *= 0.1
			H.dna.species.oxy_mod *= 0.1
			H.dna.species.clone_mod *= 0.1
			H.dna.species.stamina_mod *= 0.1
		add_attack_logs(owner, owner, "gained blood-drunk stun immunity", ATKLOG_ALL)
		owner.add_stun_absorption("blooddrunk", INFINITY, 4)
		owner.playsound_local(get_turf(owner), 'sound/effects/singlebeat.ogg', 40, 1)

/datum/status_effect/blooddrunk/on_remove()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		for(var/X in H.bodyparts)
			var/obj/item/organ/external/BP = X
			BP.brute_mod *= 10
			BP.burn_mod *= 10
		H.dna.species.tox_mod *= 10
		H.dna.species.oxy_mod *= 10
		H.dna.species.clone_mod *= 10
		H.dna.species.stamina_mod *= 10
	add_attack_logs(owner, owner, "lost blood-drunk stun immunity", ATKLOG_ALL)
	owner.status_flags &= ~IGNORESLOWDOWN
	if(islist(owner.stun_absorption) && owner.stun_absorption["blooddrunk"])
		owner.stun_absorption -= "blooddrunk"

/datum/status_effect/exercised
	id = "Exercised"
	duration = 1200
	alert_type = null

/datum/status_effect/exercised/on_creation(mob/living/new_owner, ...)
	. = ..()
	STOP_PROCESSING(SSfastprocess, src)
	START_PROCESSING(SSprocessing, src) //this lasts 20 minutes, so SSfastprocess isn't needed.

/datum/status_effect/exercised/Destroy()
	. = ..()
	STOP_PROCESSING(SSprocessing, src)

/obj/screen/alert/status_effect/regenerative_core
	name = "Reinforcing Tendrils"
	desc = "You can move faster than your broken body could normally handle!"
	icon_state = "regenerative_core"
	name = "Regenerative Core Tendrils"

/datum/status_effect/regenerative_core
	id = "Regenerative Core"
	duration = 1 MINUTES
	status_type = STATUS_EFFECT_REPLACE
	alert_type = /obj/screen/alert/status_effect/regenerative_core

/datum/status_effect/regenerative_core/on_apply()
	owner.status_flags |= IGNORESLOWDOWN
	owner.revive()
	return TRUE

/datum/status_effect/regenerative_core/on_remove()
	owner.status_flags &= ~IGNORESLOWDOWN