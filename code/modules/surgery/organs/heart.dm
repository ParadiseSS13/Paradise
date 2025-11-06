/obj/item/organ/internal/heart
	name = "heart"
	icon_state = "heart-on"
	organ_tag = "heart"
	slot = "heart"
	origin_tech = "biotech=5"
	dead_icon = "heart-off"
	base_icon_state = "heart"
	organ_datums = list(/datum/organ/heart)

/obj/item/organ/internal/heart/update_icon_state()
	var/datum/organ/heart/heart = organ_datums[ORGAN_DATUM_HEART]
	if(heart.beating)
		icon_state = "[base_icon_state]-on"
	else
		icon_state = "[base_icon_state]-off"

/obj/item/organ/internal/heart/attack_self__legacy__attackchain(mob/user)
	..()
	if(status & ORGAN_DEAD)
		to_chat(user, "<span class='warning'>You can't restart a dead heart.</span>")
		return
	var/datum/organ/heart/heart = organ_datums[ORGAN_DATUM_HEART]
	heart.try_restart(8 SECONDS)

/obj/item/organ/internal/heart/safe_replace(mob/living/carbon/human/target)
	var/datum/organ/heart/heart = organ_datums[ORGAN_DATUM_HEART]
	heart.change_beating(TRUE)
	..()

/obj/item/organ/internal/heart/cursed
	name = "cursed heart"
	desc = "it needs to be pumped..."
	icon_state = "cursedheart-off"
	base_icon_state = "cursedheart"
	origin_tech = "biotech=6"
	actions_types = list(/datum/action/item_action/organ_action/cursed_heart)
	organ_datums = list(/datum/organ/heart, /datum/organ/battery) // This doesn't actually work for IPCs but it also doesn't kill you, and it's funny
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

/obj/item/organ/internal/heart/cursed/attack__legacy__attackchain(mob/living/carbon/human/H, mob/living/carbon/human/user, obj/target)
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
		in_grace_period = TRUE
		addtimer(VARSET_CALLBACK(src, in_grace_period, FALSE), revival_grace_period)

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
/datum/action/item_action/organ_action/cursed_heart/Trigger(left_click)
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

/datum/action/item_action/organ_action/cursed_heart/Grant(mob/M)
	..()
	INVOKE_ASYNC(src, PROC_REF(poll_keybinds))

/datum/action/item_action/organ_action/cursed_heart/proc/poll_keybinds()
	if(alert(owner, "You've been given a cursed heart! Do you want to bind its action to a keybind?", "Cursed Heart", "Yes", "No") == "Yes")
		return
		// button.set_to_keybind(owner)
		// TODO GAHHH SORRY GDN

/obj/item/organ/internal/heart/cybernetic
	name = "cybernetic heart"
	desc = "An electronic device designed to mimic the functions of an organic human heart. Offers no benefit over an organic heart other than being easy to make."
	icon_state = "heart-c-on"
	base_icon_state = "heart-c"
	dead_icon = "heart-c-off"
	status = ORGAN_ROBOT
	organ_datums = list(/datum/organ/heart, /datum/organ/battery)

/obj/item/organ/internal/heart/cybernetic/upgraded
	name = "upgraded cybernetic heart"
	desc = "A more advanced version of a cybernetic heart. Grants the user additional stamina and heart stability, but the electronics are vulnerable to shock."
	icon_state = "heart-c-u-on"
	base_icon_state = "heart-c-u"
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

	if(status & ORGAN_DEAD)
		return

	var/boost = emagged ? 2 : 1
	owner.AdjustParalysis(-2 SECONDS * boost)
	owner.AdjustStunned(-2 SECONDS * boost)
	owner.AdjustWeakened(-2 SECONDS * boost)
	owner.AdjustKnockDown(-2 SECONDS * boost)
	owner.adjustStaminaLoss(-10 * boost)

	if(attempted_restart)
		return

	var/datum/organ/heart/heart_datum = organ_datums[ORGAN_DATUM_HEART]

	if(!heart_datum.beating)
		to_chat(owner, "<span class='warning'>Your [name] detects a cardiac event and attempts to return to its normal rhythm!</span>")
		if(prob(20) && emagged)
			attempted_restart = TRUE
			heart_datum.change_beating(TRUE) // Mötley Crüe - Kickstart My Heart
			owner.adjustOxyLoss(-100)
			owner.SetLoseBreath(0)
			addtimer(CALLBACK(src, PROC_REF(message_to_owner), owner, "<span class='warning'>Your [name] returns to its normal rhythm!</span>"), 3 SECONDS)
			addtimer(CALLBACK(src, PROC_REF(recharge)), 20 SECONDS)
		else if(prob(10))
			attempted_restart = TRUE
			heart_datum.change_beating(TRUE)
			owner.adjustOxyLoss(-100)
			owner.SetLoseBreath(0)
			addtimer(CALLBACK(src, PROC_REF(message_to_owner), owner, "<span class='warning'>Your [name] returns to its normal rhythm!</span>"), 3 SECONDS)
			addtimer(CALLBACK(src, PROC_REF(recharge)), 30 SECONDS)
		else
			attempted_restart = TRUE
			if(emagged)
				addtimer(CALLBACK(src, PROC_REF(recharge)), 10 SECONDS)
			else
				addtimer(CALLBACK(src, PROC_REF(recharge)), 15 SECONDS)
			addtimer(CALLBACK(src, PROC_REF(message_to_owner), owner, "<span class='warning'>Your [name] fails to return to its normal rhythm!</span>"), 3 SECONDS)

	if(owner.HasDisease(/datum/disease/critical/heart_failure))
		to_chat(owner, "<span class='warning'>Your [name] detects a cardiac event and attempts to return to its normal rhythm!</span>")
		if(prob(40) && emagged)
			attempted_restart = TRUE
			for(var/datum/disease/critical/heart_failure/HF in owner.viruses)
				HF.cure()
			addtimer(CALLBACK(src, PROC_REF(message_to_owner), owner, "<span class='warning'>Your [name] returns to its normal rhythm!</span>"), 30)
			addtimer(CALLBACK(src, PROC_REF(recharge)), 20 SECONDS)
		else if(prob(25))
			attempted_restart = TRUE
			for(var/datum/disease/critical/heart_failure/HF in owner.viruses)
				HF.cure()
			addtimer(CALLBACK(src, PROC_REF(message_to_owner), owner, "<span class='warning'>Your [name] returns to its normal rhythm!</span>"), 30)
			addtimer(CALLBACK(src, PROC_REF(recharge)), 20 SECONDS)
		else
			attempted_restart = TRUE
			if(emagged)
				addtimer(CALLBACK(src, PROC_REF(recharge)), 10 SECONDS)
			else
				addtimer(CALLBACK(src, PROC_REF(recharge)), 15 SECONDS)
			addtimer(CALLBACK(src, PROC_REF(message_to_owner), owner, "<span class='warning'>Your [name] fails to return to its normal rhythm!</span>"), 30)


/obj/item/organ/internal/heart/cybernetic/upgraded/proc/message_to_owner(mob/M, message)
	to_chat(M, message)


/obj/item/organ/internal/heart/cybernetic/upgraded/proc/recharge()
	attempted_restart = FALSE


/obj/item/organ/internal/heart/cybernetic/upgraded/emag_act(mob/user)
	if(!emagged)
		to_chat(user, "<span class='warning'>You disable the safeties on [src]</span>")
		emagged = TRUE
		return TRUE
	else
		to_chat(user, "<span class='warning'>You re-enable the safeties on [src]</span>")
		emagged = FALSE


/obj/item/organ/internal/heart/cybernetic/upgraded/proc/shock_heart(mob/living/carbon/human/source, intensity)
	SIGNAL_HANDLER  // COMSIG_LIVING_MINOR_SHOCK + COMSIG_LIVING_ELECTROCUTE_ACT

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
			// invoke asyncs here because this sleeps
			INVOKE_ASYNC(owner, TYPE_PROC_REF(/mob/living/carbon/human, adjustBruteLoss), numHigh)
		if(prob(numHigh))
			to_chat(owner, "<span class='warning'>Your [name] shocks you painfully!</span>")
			INVOKE_ASYNC(owner, TYPE_PROC_REF(/mob/living/carbon/human, adjustFireLoss), numHigh)
		if(prob(numMid))
			to_chat(owner, "<span class='warning'>Your [name] lurches awkwardly!</span>")
			owner.ForceContractDisease(new /datum/disease/critical/heart_failure(0))
		if(prob(numMid))
			to_chat(owner, "<span class='danger'>Your [name] stops beating!</span>")
			var/datum/organ/heart/heart_datum = organ_datums[ORGAN_DATUM_HEART]
			heart_datum.change_beating(FALSE) // Rambunctious Crew - Stop My Fucking Heart
		if(prob(numLow))
			to_chat(owner, "<span class='danger'>Your [name] shuts down!</span>")
			INVOKE_ASYNC(src, PROC_REF(necrotize))
	else if(!emagged && !(status & ORGAN_DEAD))
		if(prob(numMid))
			to_chat(owner, "<span class='warning'>Your [name] spasms violently!</span>")
			INVOKE_ASYNC(owner, TYPE_PROC_REF(/mob/living/carbon/human, adjustBruteLoss), numMid)
		if(prob(numMid))
			to_chat(owner, "<span class='warning'>Your [name] shocks you painfully!</span>")
			INVOKE_ASYNC(owner, TYPE_PROC_REF(/mob/living/carbon/human, adjustFireLoss), numMid)
		if(prob(numLow))
			to_chat(owner, "<span class='warning'>Your [name] lurches awkwardly!</span>")
			owner.ForceContractDisease(new /datum/disease/critical/heart_failure(0))

/obj/item/organ/internal/heart/cybernetic/upgraded/hardened
	name = "hardened overclocked cybernetic heart"
	emp_proof = TRUE
	emagged = TRUE
