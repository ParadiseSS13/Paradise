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

/obj/item/organ/internal/heart/update_icon_state()
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

	if(!special)
		addtimer(CALLBACK(src, PROC_REF(stop_if_unowned)), 120)

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
		addtimer(CALLBACK(src, PROC_REF(stop_if_unowned)), 80)

/obj/item/organ/internal/heart/safe_replace(mob/living/carbon/human/target)
	Restart()
	..()

/obj/item/organ/internal/heart/proc/stop_if_unowned()
	if(!owner)
		Stop()

/obj/item/organ/internal/heart/proc/Stop()
	beating = FALSE
	update_icon(UPDATE_ICON_STATE)
	return TRUE

/obj/item/organ/internal/heart/proc/Restart()
	beating = TRUE
	update_icon(UPDATE_ICON_STATE)
	return TRUE

/obj/item/organ/internal/heart/prepare_eat()
	var/obj/S = ..()
	if(S)
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

	// Give the user a chance to be shocked to life with the heart in, since defibs put them to sleep.
	/// How long the shock pumps their heart for them.
	var/revival_grace_period = 10 SECONDS
	/// If true, the user doesn't need to pump their heart.
	var/in_grace_period = FALSE
	/// Times that it's been shocked.
	var/times_shocked = 0
	/// Max times that the shock will work before it'll just refuse.
	var/max_shocks_allowed = 5

	//How much to heal per pump, negative numbers would HURT the player
	var/heal_brute = 0
	var/heal_burn = 0
	var/heal_oxy = 0

/obj/item/organ/internal/heart/cursed/attack(mob/living/carbon/human/H, mob/living/carbon/human/user, obj/target)
	if(H == user && istype(H))
		if(NO_BLOOD in H.dna.species.species_traits)
			to_chat(H, "<span class='userdanger'>[src] is not compatible with your form!</span>")
			return
		playsound(user,'sound/effects/singlebeat.ogg', 40, 1)
		user.drop_item()
		insert(user)
	else
		return ..()

/obj/item/organ/internal/heart/cursed/on_life()
	if(world.time > (last_pump + pump_delay) && !in_grace_period)
		if(ishuman(owner) && owner.client) //While this entire item exists to make people suffer, they can't control disconnects.
			var/mob/living/carbon/human/H = owner
			if(!(NO_BLOOD in H.dna.species.species_traits))
				H.blood_volume = max(H.blood_volume - blood_loss, 0)
				to_chat(H, "<span class='userdanger'>You have to keep pumping your blood!</span>")
				if(H?.client?.prefs.colourblind_mode == COLOURBLIND_MODE_NONE)
					H.client.color = "red" //bloody screen so real
		else
			last_pump = world.time //lets be extra fair *sigh*

/obj/item/organ/internal/heart/cursed/insert(mob/living/carbon/M, special = 0)
	..()
	if(owner)
		to_chat(owner, "<span class='userdanger'>Your heart has been replaced with a cursed one, you have to pump this one manually otherwise you'll die!</span>")
		RegisterSignal(owner, COMSIG_LIVING_PRE_DEFIB, PROC_REF(just_before_revive))
		RegisterSignal(owner, COMSIG_LIVING_DEFIBBED, PROC_REF(on_defib_revive))

/obj/item/organ/internal/heart/cursed/remove(mob/living/carbon/M, special)
	if(owner?.client?.prefs.colourblind_mode == COLOURBLIND_MODE_NONE)
		owner.client.color = ""

	UnregisterSignal(owner, COMSIG_LIVING_PRE_DEFIB, PROC_REF(just_before_revive))
	UnregisterSignal(owner, COMSIG_LIVING_DEFIBBED, PROC_REF(on_defib_revive))
	return ..()


/obj/item/organ/internal/heart/cursed/proc/on_defib_revive(mob/living/carbon/shocked, mob/living/carbon/shocker, obj/item/defib, mob/dead/observer/ghost = null)
	SIGNAL_HANDLER  // COMSIG_LIVING_DEFIBBED

	if(!owner || !istype(owner) || owner.stat != DEAD)
		return

	if(times_shocked >= max_shocks_allowed)
		shocker.visible_message(
			"<span class='userdanger'>Tendrils of ghastly electricity surge from [shocked] as [shocked.p_their()] heart seems to outright refuse defibrillation!<span>",
			blind_message = "<span class='danger'>You hear a loud shock.</span>"
		)
		tesla_zap(owner, 4, 8000, ZAP_MOB_STUN | ZAP_MOB_DAMAGE)
		// NO, YOU!
		playsound(get_turf(owner), 'sound/magic/lightningshock.ogg', 50, 1)

		defib.audible_message("<span class='boldnotice'>[defib] buzzes: Resuscitation failed - Anomalous heart activity detected while administering shock.</span>")
		playsound(defib, "defib_saftyon.ogg", 50, FALSE)

		return COMPONENT_DEFIB_OVERRIDE

	in_grace_period = TRUE
	times_shocked++
	// wake up
	addtimer(CALLBACK(src, PROC_REF(after_revive)), 2 SECONDS)  // grab a brush and put a little make-up
	addtimer(CALLBACK(src, PROC_REF(on_end_grace_period)), revival_grace_period)  // hide the scars to fade away the shake-up

/obj/item/organ/internal/heart/cursed/proc/after_revive()
	owner.SetSleeping(0)
	owner.SetParalysis(0)

/// Run this just before the shock is applied so we end up with enough blood to revive.
/obj/item/organ/internal/heart/cursed/proc/just_before_revive(mob/living/carbon/shocked, mob/living/carbon/shocker, mob/dead/observer/ghost = null)
	SIGNAL_HANDLER  // COMSIG_LIVING_PRE_DEFIB

	if(owner.stat == DEAD)
		owner.blood_volume = BLOOD_VOLUME_OKAY

/obj/item/organ/internal/heart/cursed/proc/on_end_grace_period()
	in_grace_period = FALSE
	if(!owner)
		return
	to_chat(owner, "<span class='userdanger'>The effects of the shock seem to wear off, and you feel a familiar tightness in your chest! Get pumping!</span>")

	if(times_shocked < max_shocks_allowed - 1)
		to_chat(owner, "<span class='warning'>It doesn't feel like your [name] enjoyed that.</span>")
	else if(times_shocked == max_shocks_allowed - 1)
		to_chat(owner, "<span class='danger'>Your [name] starts to feel heavy in your chest. It doesn't seem like it'll be able to take many more shocks!</span>")
	else
		to_chat(owner, "<span class='userdanger'>Your [name] feels like lead. Something tells you that if you die with it again, you won't get another chance!</span>")

/datum/action/item_action/organ_action/cursed_heart
	name = "Pump your heart"

//You are now brea- pumping blood manually
/datum/action/item_action/organ_action/cursed_heart/Trigger()
	. = ..()
	if(. && istype(target, /obj/item/organ/internal/heart/cursed))
		var/obj/item/organ/internal/heart/cursed/cursed_heart = target

		if(world.time < (cursed_heart.last_pump + (cursed_heart.pump_delay - 10))) //no spam
			to_chat(owner, "<span class='userdanger'>Too soon!</span>")
			return

		cursed_heart.last_pump = world.time
		playsound(owner,'sound/effects/singlebeat.ogg',40,1)
		to_chat(owner, "<span class='notice'>Your heart beats.</span>")

		var/mob/living/carbon/human/H = owner
		if(istype(H))
			if(!(NO_BLOOD in H.dna.species.species_traits))
				H.blood_volume = min(H.blood_volume + cursed_heart.blood_loss * 0.5, BLOOD_VOLUME_NORMAL)
				if(owner?.client?.prefs.colourblind_mode == COLOURBLIND_MODE_NONE)
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
	status = ORGAN_ROBOT

/obj/item/organ/internal/heart/cybernetic/upgraded
	name = "upgraded cybernetic heart"
	desc = "A more advanced version of a cybernetic heart. Grants the user additional stamina and heart stability, but the electronics are vulnerable to shock."
	icon_state = "heart-c-u-on"
	icon_base = "heart-c-u"
	dead_icon = "heart-c-u-off"
	var/attempted_restart = FALSE

/obj/item/organ/internal/heart/cybernetic/upgraded/insert(mob/living/carbon/M, special = FALSE)
	..()
	RegisterSignal(M, COMSIG_LIVING_MINOR_SHOCK, PROC_REF(shock_heart))
	RegisterSignal(M, COMSIG_LIVING_ELECTROCUTE_ACT, PROC_REF(shock_heart))

/obj/item/organ/internal/heart/cybernetic/upgraded/remove(mob/living/carbon/M, special = FALSE)
	UnregisterSignal(M, COMSIG_LIVING_MINOR_SHOCK)
	UnregisterSignal(M, COMSIG_LIVING_ELECTROCUTE_ACT)
	return  ..()


/obj/item/organ/internal/heart/cybernetic/upgraded/on_life()
	if(!ishuman(owner))
		return

	if(!(status & ORGAN_DEAD) && !attempted_restart && !beating)
		to_chat(owner, "<span class='warning'>Your [name] detects a cardiac event and attempts to return to its normal rhythm!</span>")
		if(prob(20) && emagged)
			attempted_restart = TRUE
			Restart()
			addtimer(CALLBACK(src, PROC_REF(message_to_owner), owner, "<span class='warning'>Your [name] returns to its normal rhythm!</span>"), 30)
			addtimer(CALLBACK(src, PROC_REF(recharge)), 200)
		else if(prob(10))
			attempted_restart = TRUE
			Restart()
			addtimer(CALLBACK(src, PROC_REF(message_to_owner), owner, "<span class='warning'>Your [name] returns to its normal rhythm!</span>"), 30)
			addtimer(CALLBACK(src, PROC_REF(recharge)), 300)
		else
			attempted_restart = TRUE
			if(emagged)
				addtimer(CALLBACK(src, PROC_REF(recharge)), 200)
			else
				addtimer(CALLBACK(src, PROC_REF(recharge)), 300)
			addtimer(CALLBACK(src, PROC_REF(message_to_owner), owner, "<span class='warning'>Your [name] fails to return to its normal rhythm!</span>"), 30)

	if(!(status & ORGAN_DEAD) && !attempted_restart && owner.HasDisease(new /datum/disease/critical/heart_failure(0)))
		to_chat(owner, "<span class='warning'>Your [name] detects a cardiac event and attempts to return to its normal rhythm!</span>")
		if(prob(40) && emagged)
			attempted_restart = TRUE
			for(var/datum/disease/critical/heart_failure/HF in owner.viruses)
				HF.cure()
			addtimer(CALLBACK(src, PROC_REF(message_to_owner), owner, "<span class='warning'>Your [name] returns to its normal rhythm!</span>"), 30)
			addtimer(CALLBACK(src, PROC_REF(recharge)), 200)
		else if(prob(25))
			attempted_restart = TRUE
			for(var/datum/disease/critical/heart_failure/HF in owner.viruses)
				HF.cure()
			addtimer(CALLBACK(src, PROC_REF(message_to_owner), owner, "<span class='warning'>Your [name] returns to its normal rhythm!</span>"), 30)
			addtimer(CALLBACK(src, PROC_REF(recharge)), 200)
		else
			attempted_restart = TRUE
			if(emagged)
				addtimer(CALLBACK(src, PROC_REF(recharge)), 200)
			else
				addtimer(CALLBACK(src, PROC_REF(recharge)), 300)
			addtimer(CALLBACK(src, PROC_REF(message_to_owner), owner, "<span class='warning'>Your [name] fails to return to its normal rhythm!</span>"), 30)

	if(!(status & ORGAN_DEAD))
		var/boost = emagged ? 2 : 1
		owner.AdjustParalysis(-2 SECONDS * boost)
		owner.AdjustStunned(-2 SECONDS * boost)
		owner.AdjustWeakened(-2 SECONDS * boost)
		owner.AdjustKnockDown(-2 SECONDS * boost)
		owner.adjustStaminaLoss(-10 * boost)


/obj/item/organ/internal/heart/cybernetic/upgraded/proc/message_to_owner(mob/M, message)
	to_chat(M, message)


/obj/item/organ/internal/heart/cybernetic/upgraded/proc/recharge()
	attempted_restart = FALSE


/obj/item/organ/internal/heart/cybernetic/upgraded/emag_act(mob/user)
	if(!emagged)
		to_chat(user, "<span class='warning'>You disable the safeties on [src]</span>")
		emagged = TRUE
	else
		to_chat(user, "<span class='warning'>You re-enable the safeties on [src]</span>")
		emagged = FALSE


/obj/item/organ/internal/heart/cybernetic/upgraded/emp_act(severity)
	..()
	if(emp_proof)
		return
	necrotize()

/obj/item/organ/internal/heart/cybernetic/upgraded/proc/shock_heart(mob/living/carbon/human/source, intensity)
	SIGNAL_HANDLER_DOES_SLEEP

	if(!ishuman(owner))
		return
	if(emp_proof)
		return
	intensity = min(intensity, 100)
	var/numHigh = round(intensity / 5)
	var/numMid = round(intensity / 10)
	var/numLow = round(intensity / 20)
	if(emagged && !(status & ORGAN_DEAD))
		if(prob(numHigh))
			to_chat(owner, "<span class='warning'>Your [name] spasms violently!</span>")
			owner.adjustBruteLoss(numHigh)
		if(prob(numHigh))
			to_chat(owner, "<span class='warning'>Your [name] shocks you painfully!</span>")
			owner.adjustFireLoss(numHigh)
		if(prob(numMid))
			to_chat(owner, "<span class='warning'>Your [name] lurches awkwardly!</span>")
			owner.ForceContractDisease(new /datum/disease/critical/heart_failure(0))
		if(prob(numMid))
			to_chat(owner, "<span class='danger'>Your [name] stops beating!</span>")
			Stop()
		if(prob(numLow))
			to_chat(owner, "<span class='danger'>Your [name] shuts down!</span>")
			necrotize()
	else if(!emagged && !(status & ORGAN_DEAD))
		if(prob(numMid))
			to_chat(owner, "<span class='warning'>Your [name] spasms violently!</span>")
			owner.adjustBruteLoss(numMid)
		if(prob(numMid))
			to_chat(owner, "<span class='warning'>Your [name] shocks you painfully!</span>")
			owner.adjustFireLoss(numMid)
		if(prob(numLow))
			to_chat(owner, "<span class='warning'>Your [name] lurches awkwardly!</span>")
			owner.ForceContractDisease(new /datum/disease/critical/heart_failure(0))
