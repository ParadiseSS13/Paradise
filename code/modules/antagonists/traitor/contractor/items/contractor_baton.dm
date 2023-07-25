/obj/item/melee/classic_baton/telescopic/contractor
	name = "contractor baton"
	desc = "A compact, specialised baton issued to Syndicate contractors. Applies light electrical shocks to targets."
	// Overrides
	affect_silicon = TRUE
	stun_time = 2 SECONDS
	cooldown = 2.5 SECONDS
	force_off = 5
	force_on = 20
	block_chance = 30
	item_state_on = "contractor_baton"
	icon_state_off = "contractor_baton_0"
	icon_state_on = "contractor_baton_1"
	stun_sound = 'sound/weapons/contractorbatonhit.ogg'
	extend_sound = 'sound/weapons/contractorbatonextend.ogg'
	// Settings
	/// Stamina damage to deal on stun.
	var/stamina_damage = 70
	/// Jitter to deal on stun.
	var/jitter_amount = 5 SECONDS
	/// Stutter to deal on stun.
	var/stutter_amount = 10 SECONDS
	//Upgrade stuff
	var/list/upgrades = list()
	var/muteupgrade = 0
	var/silence_amount = 0
	var/cuffupgrade = 0
	var/cuffs = 0
	var/focusupgrade = 0
	var/antidropupgrade = 0

//upgrades
/obj/item/baton_upgrade
	name = "baton upgrade"
	desc = "makes baton better."
	icon_state = "cuff_upgrade"
	var/denied_type = /obj/item/baton_upgrade

/obj/item/baton_upgrade/proc/effect_desc()
	return //nice code

/obj/item/baton_upgrade/cuff
	name = "handcuff baton upgrade"
	desc = "Allows the user to apply cabble restraints to a target via baton, requires to be loaded with up to three prior."
	icon_state = "cuff_upgrade"
	denied_type = /obj/item/baton_upgrade/cuff

/obj/item/baton_upgrade/cuff/effect_desc()
	return "allows you to cabble cuff your target if your target is exhausted. Required to be loaded first"

/obj/item/baton_upgrade/mute
	name = "mute baton upgrade"
	desc = "Use of the baton on a target will mute them for a short period."
	icon_state = "mute_upgrade"
	denied_type = /obj/item/baton_upgrade/mute

/obj/item/baton_upgrade/mute/effect_desc()
	return "deprives the victim of the ability to speak for a small time"

/obj/item/baton_upgrade/focus
	name = "focus baton upgrade"
	desc = "Use of the baton on a target, should they be the subject of your contract, will be extra exhausted."
	icon_state = "focus_upgrade"
	denied_type = /obj/item/baton_upgrade/focus

/obj/item/baton_upgrade/focus/effect_desc()
	return "allows you to cause additional damage to the target of your current contract"

/obj/item/baton_upgrade/antidrop
	name = "Antidrop baton upgrade"
	desc = "This module grips the hand, not allowing the user to drop extended baton under any circumstances."
	icon_state = "antidrop_upgrade"
	denied_type = /obj/item/baton_upgrade/antidrop

/obj/item/baton_upgrade/antidrop/effect_desc()
	return "Allows you to keep your extended baton in hands no matter what happens with you"

//upgrade attaching

/obj/item/baton_upgrade/proc/add_to(obj/item/melee/classic_baton/telescopic/contractor/H, mob/living/user)
	for(var/m in H.upgrades)
		var/obj/item/baton_upgrade/M = m
		if(istype(m,denied_type) || istype(src, M.denied_type))
			to_chat(user,"<span class='warning'>You can't attach [src] to your baton.")
			return FALSE
	if(!user.drop_transfer_item_to_loc(src, H))
		return
	H.upgrades += src
	to_chat(user, "<span class='notice'>You attach [src] to [H].</span>")
	return TRUE

/obj/item/melee/classic_baton/telescopic/contractor/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/baton_upgrade))
		var/obj/item/baton_upgrade/M = I
		M.add_to(src, user)
	if(istype(I, /obj/item/restraints/handcuffs))
		if(istype(I, /obj/item/restraints/handcuffs/cable))
			var/obj/item/restraints/handcuffs/cable/M = I
			if(cuffs < 3)
				cuffs++
				qdel(M)//I can't make it better..
				to_chat(user, "You insert [M] in your baton.")
			else
				to_chat(user, "There is no room for more cabble restraints!")
		else
			to_chat(user, "Cuff module accepts only cable restraints.")

/obj/item/melee/classic_baton/telescopic/contractor/examine(mob/user)
	. = ..()
	if(cuffupgrade)
		. += "there is [cuffs] cabble restraints in baton."
	for(var/m in upgrades)
		var/obj/item/baton_upgrade/M = m
		. += "<span class='notice'>It has \a [M] installed, which [M.effect_desc()].</span>"

//Effects

/obj/item/baton_upgrade/mute/add_to(obj/item/melee/classic_baton/telescopic/contractor/H, mob/living/user)
	. = ..()
	H.muteupgrade = 1

/obj/item/baton_upgrade/cuff/add_to(obj/item/melee/classic_baton/telescopic/contractor/H, mob/living/user)
	. = ..()
	H.cuffupgrade = 1

/obj/item/baton_upgrade/focus/add_to(obj/item/melee/classic_baton/telescopic/contractor/H, mob/living/user)
	. = ..()
	H.focusupgrade = 1

/obj/item/baton_upgrade/antidrop/add_to(obj/item/melee/classic_baton/telescopic/contractor/H, mob/living/user)
	. = ..()
	H.antidropupgrade = 1

//attack

/obj/item/melee/classic_baton/telescopic/contractor/stun(mob/living/target, mob/living/user)
	. = ..()
	target.adjustStaminaLoss(stamina_damage)
	target.Jitter(jitter_amount)
	target.AdjustStuttering(stutter_amount)
	if(muteupgrade)
		target.Silence(10 SECONDS)
	if(cuffupgrade)//check for cuff
		if(cuffs > 0)
			if(target.getStaminaLoss() > 90 || target.health <= HEALTH_THRESHOLD_CRIT || target.IsSleeping())
				CuffAttack(target, user)
			else
				user.visible_message("<span class='warning'>This victim is still resisting!</span>")
	if(focusupgrade)//check for focus
		for(var/datum/antagonist/contractor/C in user.mind.antag_datums)
			if(target == C?.contractor_uplink?.hub?.current_contract?.contract?.target.current)//pain
				target.adjustStaminaLoss(30) //one punch to stun, if target. Prevents from onepunchcuff
				target.Jitter(20 SECONDS)

//cuff module

/obj/item/melee/classic_baton/telescopic/contractor/proc/CuffAttack(mob/living/carbon/target, mob/living/user)
	if(!target.handcuffed)
		playsound(loc, 'sound/weapons/cablecuff.ogg', 30, TRUE, -2)
		target.visible_message("<span class='danger'>[user] begins restraining [target] with contractor baton!</span>", \
		"<span class='userdanger'>[user] is trying to put handcuffs on you!</span>")
		if(do_mob(user, target, 10))
			if(!target.handcuffed)
				target.set_handcuffed(new /obj/item/restraints/handcuffs/cable(target))
				to_chat(user, "<span class='notice'>You shackle [target].</span>")
				add_attack_logs(user, target, "shackled")
				cuffs--
			else
				to_chat(user, "<span class='warning'>[target] is already bound.</span>")
		else
			to_chat(user, "<span class='warning'>You fail to shackle [target].</span>")
	else
		to_chat(user, "<span class='warning'>[target] is already bound.</span>")

//antidrop stuff

/obj/item/melee/classic_baton/telescopic/contractor/attack_self(mob/user)
	. = ..()
	if(antidropupgrade)
		if(on)
			to_chat(user, "<span class='notice'>The baton spikes burrows into your arm, preventing you to drop your baton.</span>")
			flags |= NODROP
			slot_flags = 0 //preventing putting baton to belt using hotkey
		else
			to_chat(user, "<span class='notice'>The baton spikes fold back, allowing you to move your hand freely.</span>")
			flags &= ~NODROP
