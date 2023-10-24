/obj/effect/proc_holder
	var/panel = "Debug"//What panel the proc holder needs to go on.
	var/active = FALSE //Used by toggle based abilities.
	var/ranged_mousepointer
	var/mob/ranged_ability_user

/obj/effect/proc_holder/singularity_act()
	return

/obj/effect/proc_holder/singularity_pull()
	return

GLOBAL_LIST_INIT(spells, typesof(/obj/effect/proc_holder/spell))

/obj/effect/proc_holder/proc/InterceptClickOn(mob/user, params, atom/A)
	if(user.ranged_ability != src)
		to_chat(user, "<span class='warning'><b>[user.ranged_ability.name]</b> has been disabled.")
		user.ranged_ability.remove_ranged_ability(user)
		return TRUE //TRUE for failed, FALSE for passed.
	user.changeNext_click(CLICK_CD_CLICK_ABILITY)
	user.face_atom(A)
	return FALSE

/datum/click_intercept/proc_holder
	var/obj/effect/proc_holder/spell

/datum/click_intercept/proc_holder/New(client/C, obj/effect/proc_holder/spell_to_cast)
	. = ..()
	spell = spell_to_cast

/datum/click_intercept/proc_holder/InterceptClickOn(user, params, atom/object)
	spell.InterceptClickOn(user, params, object)

/datum/click_intercept/proc_holder/quit()
	spell.remove_ranged_ability(spell.ranged_ability_user)
	return ..()

/obj/effect/proc_holder/proc/add_ranged_ability(mob/user, msg)
	if(!user || !user.client)
		return
	if(user.ranged_ability && user.ranged_ability != src)
		to_chat(user, "<span class='warning'><b>[user.ranged_ability.name]</b> has been replaced by <b>[name]</b>.")
		user.ranged_ability.remove_ranged_ability(user)
	user.ranged_ability = src
	ranged_ability_user = user
	user.client.click_intercept = new /datum/click_intercept/proc_holder(user.client, user.ranged_ability)
	add_mousepointer(user.client)
	active = TRUE
	if(msg)
		to_chat(user, msg)
	update_icon()

/obj/effect/proc_holder/proc/add_mousepointer(client/C)
	if(C && ranged_mousepointer && C.mouse_pointer_icon == initial(C.mouse_pointer_icon))
		C.mouse_pointer_icon = ranged_mousepointer

/obj/effect/proc_holder/proc/remove_mousepointer(client/C)
	if(C && ranged_mousepointer && C.mouse_pointer_icon == ranged_mousepointer)
		C.mouse_pointer_icon = initial(C.mouse_pointer_icon)

/obj/effect/proc_holder/proc/remove_ranged_ability(mob/user, msg)
	if(!user || (user.ranged_ability && user.ranged_ability != src)) //To avoid removing the wrong ability
		return
	user.ranged_ability = null
	ranged_ability_user = null
	active = FALSE
	if(user.client)
		qdel(user.client.click_intercept)
		user.client.click_intercept = null
		remove_mousepointer(user.client)
		if(msg)
			to_chat(user, msg)
	update_icon()

/obj/effect/proc_holder/spell
	name = "Spell" // Only rename this if the spell you're making is not abstract
	desc = "A wizard spell"
	panel = "Spells"//What panel the proc holder needs to go on.
	density = FALSE
	opacity = FALSE

	var/school = "evocation" //not relevant at now, but may be important later if there are changes to how spells work. the ones I used for now will probably be changed... maybe spell presets? lacking flexibility but with some other benefit?
	///recharge time in deciseconds
	var/base_cooldown = 10 SECONDS
	var/starts_charged = TRUE //Does this spell start ready to go?
	var/should_recharge_after_cast = TRUE
	var/still_recharging_msg = "<span class='notice'>The spell is still recharging.</span>"

	var/holder_var_type = "bruteloss" //only used if charge_type equals to "holder_var"
	var/holder_var_amount = 20 //same. The amount adjusted with the mob's var when the spell is used

	var/ghost = FALSE // Skip life check.
	var/clothes_req = TRUE //see if it requires clothes
	var/human_req = FALSE //spell can only be cast by humans
	var/nonabstract_req = FALSE //spell can only be cast by mobs that are physical entities
	var/stat_allowed = CONSCIOUS //see if it requires being conscious/alive, need to set to 1 for ghostpells
	var/invocation = "HURP DURP" //what is uttered when the wizard casts the spell
	var/invocation_emote_self = null
	var/invocation_type = "none" //can be none, whisper and shout
	var/message = "" //whatever it says to the guy affected by it
	var/spell_level = 0 //if a spell can be taken multiple times, this raises
	var/level_max = 4 //The max possible level_max is 4
	var/cooldown_min = 0 //This defines what spell quickened four timeshas as a cooldown. Make sure to set this for every spell

	var/overlay = 0
	var/overlay_icon = 'icons/obj/wizard.dmi'
	var/overlay_icon_state = "spell"
	var/overlay_lifespan = 0

	var/sparks_spread = FALSE
	var/sparks_amt = 0

	///Determines if the spell has smoke, and if so what effect the smoke has. See spell defines.
	var/smoke_type = SMOKE_NONE
	var/smoke_amt = 0

	var/critfailchance = 0
	var/centcom_cancast = TRUE //Whether or not the spell should be allowed on the admin zlevel
	/// Whether or not the spell functions in a holy place
	var/holy_area_cancast = TRUE

	var/datum/action/spell_action/action = null
	var/action_icon = 'icons/mob/actions/actions.dmi'
	var/action_icon_state = "spell_default"
	var/action_background_icon_state = "bg_spell"

	var/sound = null //The sound the spell makes when it is cast
	var/gain_desc = null

	/// The message displayed when a click based spell gets activated
	var/selection_activated_message		= "<span class='notice'>Click on a target to cast the spell.</span>"
	/// The message displayed when a click based spell gets deactivated
	var/selection_deactivated_message	= "<span class='notice'>You choose to not cast this spell.</span>"

	/// does this spell generate attack logs?
	var/create_attack_logs = TRUE

	/// If this spell creates custom logs using the write_custom_logs() proc. Will ignore create_attack_logs
	var/create_custom_logs = FALSE

	/// Which targeting system is used. Set this in create_new_targeting
	var/datum/spell_targeting/targeting
	/// List with the targeting datums per spell type. Key = src.type, value = the targeting datum created by create_new_targeting()
	var/static/list/targeting_datums = list()

	/// Which spell_handler is used in addition to the normal spells behaviour, can be null. Set this in create_new_handler if needed
	var/datum/spell_handler/custom_handler
	/// List with the handler datums per spell type. Key = src.type, value = the handler datum created by create_new_handler()
	var/static/list/spell_handlers = list()
	/// handles a given spells cooldowns. tracks the time until its off cooldown,
	var/datum/spell_cooldown/cooldown_handler

/* Checks if the user can cast the spell
 * @param charge_check If the proc should do the cooldown check
 * @param start_recharge If the proc should set the cooldown
 * @param user The caster of the spell
*/
/obj/effect/proc_holder/spell/proc/cast_check(charge_check = TRUE, start_recharge = TRUE, mob/user = usr) //checks if the spell can be cast based on its settings; skipcharge is used when an additional cast_check is called inside the spell
	// SHOULD_NOT_OVERRIDE(TRUE) Todo for another refactor
	if(!can_cast(user, charge_check, TRUE))
		return FALSE

	if(ishuman(user))
		var/mob/living/carbon/human/caster = user
		if(caster.remoteview_target)
			caster.remoteview_target = null
			caster.reset_perspective(0)
			return 0

	if(start_recharge)
		spend_spell_cost(user)

	return 1

/**
 * Allows for spell specific target validation. Will be used by the spell_targeting datums
 *
 * Arguments:
 * * target - Who is being considered
 * * user - Who is the user of this spell
 */
/obj/effect/proc_holder/spell/proc/valid_target(target, user)
	return TRUE

/**
 * Will spend the cost of using this spell once. Will update the action button's icon if there is any
 *
 * Arguments:
 * * user - Who used this spell?
 */
/obj/effect/proc_holder/spell/proc/spend_spell_cost(mob/user)
	SHOULD_CALL_PARENT(TRUE)

	custom_handler?.spend_spell_cost(user, src)

	if(action)
		action.UpdateButtonIcon()

/obj/effect/proc_holder/spell/proc/invocation(mob/user) //spelling the spell out and setting it on recharge/reducing charges amount
	switch(invocation_type)
		if("shout")
			if(!user.IsVocal())
				user.custom_emote(EMOTE_VISIBLE, "makes frantic gestures!")
			else
				if(prob(50))//Auto-mute? Fuck that noise
					user.say(invocation)
				else
					user.say(replacetext(invocation," ","`"))
		if("whisper")
			if(prob(50))
				user.whisper(invocation)
			else
				user.whisper(replacetext(invocation," ","`"))
		if("emote")
			user.visible_message(invocation, invocation_emote_self) //same style as in mob/living/emote.dm

/obj/effect/proc_holder/spell/proc/playMagSound()
	playsound(get_turf(usr), sound,50,1)

/obj/effect/proc_holder/spell/New()
	..()
	action = new(src)
	still_recharging_msg = "<span class='notice'>[name] is still recharging.</span>"
	if(!gain_desc)
		gain_desc = "You can now use [src]."

	if(!targeting_datums[type])
		targeting_datums[type] = create_new_targeting()
		if(!targeting_datums[type])
			stack_trace("Spell of type [type] did not implement create_new_targeting")
	if(isnull(spell_handlers[type]))
		spell_handlers[type] = create_new_handler()

	if(spell_handlers[type] != NONE)
		custom_handler = spell_handlers[type]
	targeting = targeting_datums[type]
	cooldown_handler = create_new_cooldown()
	cooldown_handler.cooldown_init(src)

/obj/effect/proc_holder/spell/Destroy()
	QDEL_NULL(action)
	QDEL_NULL(cooldown_handler)
	return ..()

/**
 * Creates and returns the targeting datum for this spell type. Override this!
 * Should return a value of type [/datum/spell_targeting]
 */
/obj/effect/proc_holder/spell/proc/create_new_targeting()
	RETURN_TYPE(/datum/spell_targeting)
	return

/**
 * Creates and returns the handler datum for this spell type.
 * Override this if you want a custom spell handler.
 * Should return a value of type [/datum/spell_handler] or NONE
 */
/obj/effect/proc_holder/spell/proc/create_new_handler()
	RETURN_TYPE(/datum/spell_handler)
	return NONE

/**
 * Creates and returns the spells cooldown handler, defaults to the standard recharge handler.
 * Override this if you wish to use a different method of cooldown
 */

/obj/effect/proc_holder/spell/proc/create_new_cooldown()
	RETURN_TYPE(/datum/spell_cooldown)
	var/datum/spell_cooldown/S = new
	S.recharge_duration = base_cooldown
	S.starts_off_cooldown = starts_charged
	return S

/obj/effect/proc_holder/spell/Click()
	if(cast_check(TRUE, FALSE, usr))
		choose_targets(usr)
	return 1

/obj/effect/proc_holder/spell/AltClick(mob/user)
	return Click()

/obj/effect/proc_holder/spell/InterceptClickOn(mob/user, params, atom/A)
	. = ..()
	if(.)
		return
	targeting.InterceptClickOn(user, params, A, src)

///Lets the spell have a special effect applied to it when upgraded. By default, does nothing.
/obj/effect/proc_holder/spell/proc/on_purchase_upgrade()
	return

/**
 * Will try to choose targets using the targeting variable and perform the spell if it can
 * Do not override this! Override create_new_targeting instead
 *
 * Arguments:
 * * user - The caster of the spell
 */
/obj/effect/proc_holder/spell/proc/choose_targets(mob/user)
	SHOULD_NOT_OVERRIDE(TRUE)
	if(targeting.use_intercept_click)
		if(active)
			remove_ranged_ability(user, selection_deactivated_message)
			return

		if(targeting.try_auto_target && targeting.attempt_auto_target(user, src))
			return

		add_ranged_ability(user, selection_activated_message)
	else
		var/list/targets = targeting.choose_targets(user, src)
		try_perform(targets, user)

/**
 * Will try and perform the spell using the given targets and user. Will spend one charge of the spell
 *
 * Arguments:
 * * targets - The targets the spell is being performed on
 * * user - The caster of the spell
 */
/obj/effect/proc_holder/spell/proc/try_perform(list/targets, mob/user)
	SHOULD_NOT_OVERRIDE(TRUE)
	if(!length(targets))
		to_chat(user, "<span class='warning'>No suitable target found.</span>")
		return FALSE
	if(should_remove_click_intercept()) // returns TRUE by default
		remove_ranged_ability(user) // Targeting succeeded. So remove the click interceptor if there is one. Even if the cast didn't succeed afterwards
	if(!cast_check(TRUE, TRUE, user))
		return

	perform(targets, should_recharge_after_cast, user)

/**
 * Called in `try_perform` before removing the click interceptor. useful to override if you have a spell that requires more than 1 click
 */

/obj/effect/proc_holder/spell/proc/should_remove_click_intercept()
	return TRUE

/**
 * Handles all the code for performing a spell once the targets are known
 *
 * Arguments:
 * * targets - The list of targets the spell is being cast on. Will not be empty or null
 * * recharge - Whether or not the spell should go recharge
 * * user - The caster of the spell
 */
/obj/effect/proc_holder/spell/proc/perform(list/targets, recharge = TRUE, mob/user = usr) //if recharge is started is important for the trigger spells
	SHOULD_NOT_OVERRIDE(TRUE)
	before_cast(targets, user)
	invocation(user)
	if(user && user.ckey)
		if(create_custom_logs)
			write_custom_logs(targets, user)
		if(create_attack_logs)
			add_attack_logs(user, targets, "cast the spell [name]", ATKLOG_ALL)
	if(recharge)
		cooldown_handler.start_recharge()

	if(sound)
		playMagSound()

	if(prob(critfailchance))
		critfail(targets)
	else
		cast(targets, user = user)
	after_cast(targets, user)
	if(action)
		action.UpdateButtonIcon()

/**
 * Will write additional logs if create_custom_logs is TRUE and the caster has a ckey. Override this
 *
 * Arguments:
 * * targets - The targets being targeted by the spell
 * * user - The user of the spell
 */
/obj/effect/proc_holder/spell/proc/write_custom_logs(list/targets, mob/user)
	return


/obj/effect/proc_holder/spell/proc/before_cast(list/targets, mob/user)
	SHOULD_CALL_PARENT(TRUE)
	if(overlay)
		for(var/atom/target in targets)
			var/location
			if(isliving(target))
				location = target.loc
			else if(isturf(target))
				location = target
			var/obj/effect/overlay/spell = new /obj/effect/overlay(location)
			spell.icon = overlay_icon
			spell.icon_state = overlay_icon_state
			spell.anchored = TRUE
			spell.density = FALSE
			spawn(overlay_lifespan)
				qdel(spell)

	custom_handler?.before_cast(targets, user, src)

/obj/effect/proc_holder/spell/proc/after_cast(list/targets, mob/user)
	SHOULD_CALL_PARENT(TRUE)
	for(var/atom/target in targets)
		var/location
		if(isliving(target))
			location = target.loc
		else if(isturf(target))
			location = target
		if(isliving(target) && message)
			to_chat(target, text("[message]"))
		if(sparks_spread)
			do_sparks(sparks_amt, 0, location)
		if(smoke_type)
			var/datum/effect_system/smoke_spread/smoke
			switch(smoke_type)
				if(SMOKE_HARMLESS)
					smoke = new /datum/effect_system/smoke_spread()
				if(SMOKE_COUGHING)
					smoke = new /datum/effect_system/smoke_spread/bad()
				if(SMOKE_SLEEPING)
					smoke = new /datum/effect_system/smoke_spread/sleeping()
			smoke.set_up(smoke_amt, FALSE, location)
			smoke.start()

	custom_handler?.after_cast(targets, user, src)

/**
 * The proc where the actual spell gets cast.
 *
 * Arguments:
 * * targets - The targets being targeted by the spell
 * * user - The caster of the spell
 */
/obj/effect/proc_holder/spell/proc/cast(list/targets, mob/user = usr)
	return

/obj/effect/proc_holder/spell/proc/critfail(list/targets)
	return

/obj/effect/proc_holder/spell/proc/revert_cast(mob/user = usr) //resets recharge or readds a charge
	cooldown_handler.revert_cast()
	custom_handler?.revert_cast(user, src)

	if(action)
		action.UpdateButtonIcon()

/obj/effect/proc_holder/spell/proc/updateButtonIcon()
	if(action)
		action.UpdateButtonIcon()

/obj/effect/proc_holder/spell/proc/adjust_var(mob/living/target = usr, type, amount) //handles the adjustment of the var when the spell is used. has some hardcoded types
	switch(type)
		if("bruteloss")
			target.adjustBruteLoss(amount)
		if("fireloss")
			target.adjustFireLoss(amount)
		if("toxloss")
			target.adjustToxLoss(amount)
		if("oxyloss")
			target.adjustOxyLoss(amount)
		if("stunned")
			target.AdjustStunned(amount)
		if("weakened")
			target.AdjustWeakened(amount)
		if("paralysis")
			target.AdjustParalysis(amount)
		else
			target.vars[type] += amount //I bear no responsibility for the runtimes that'll happen if you try to adjust non-numeric or even non-existant vars
	return

/obj/effect/proc_holder/spell/aoe
	name = "Spell"
	create_attack_logs = FALSE
	create_custom_logs = TRUE
	/// How far does it effect
	var/aoe_range = 7

// Normally, AoE spells will generate an attack log for every turf they loop over, while searching for targets.
// With this override, all /aoe type spells will only generate 1 log, saying that the user has cast the spell.
/obj/effect/proc_holder/spell/aoe/write_custom_logs(list/targets, mob/user)
	add_attack_logs(user, null, "Cast the AoE spell [name]", ATKLOG_ALL)

/obj/effect/proc_holder/spell/proc/can_cast(mob/user = usr, charge_check = TRUE, show_message = FALSE)
	if(((!user.mind) || !(src in user.mind.spell_list)) && !(src in user.mob_spell_list))
		if(show_message)
			to_chat(user, "<span class='warning'>You shouldn't have this spell! Something's wrong.</span>")
		return FALSE

	if(!centcom_cancast) //Certain spells are not allowed on the centcom zlevel
		var/turf/T = get_turf(user)
		if(T && is_admin_level(T.z))
			return FALSE

	if(!holy_area_cancast && user.holy_check())
		return FALSE

	if(charge_check)
		if(cooldown_handler.is_on_cooldown())
			if(show_message)
				to_chat(user, still_recharging_msg)
			return FALSE

	if(!ghost)
		if(user.stat && !stat_allowed)
			if(show_message)
				to_chat(user, "<span class='notice'>You can't cast this spell while incapacitated.</span>")
			return FALSE
		if(ishuman(user) && (invocation_type == "whisper" || invocation_type == "shout") && user.is_muzzled())
			if(show_message)
				to_chat(user, "Mmmf mrrfff!")
			return FALSE

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/clothcheck = locate(/obj/effect/proc_holder/spell/noclothes) in user.mob_spell_list
		var/clothcheck2 = user.mind && (locate(/obj/effect/proc_holder/spell/noclothes) in user.mind.spell_list)
		if(clothes_req && !clothcheck && !clothcheck2) //clothes check
			var/obj/item/clothing/robe = H.wear_suit
			var/obj/item/clothing/hat = H.head
			var/obj/item/clothing/shoes = H.shoes
			if(!robe || !hat || !shoes)
				if(show_message)
					to_chat(user, "<span class='notice'>Your outfit isn't complete, you should put on your robe and wizard hat, as well as sandals.</span>")
				return FALSE
			if(!robe.magical || !hat.magical || !shoes.magical)
				if(show_message)
					to_chat(user, "<span class='notice'>Your outfit isn't magical enough, you should put on your robe and wizard hat, as well as your sandals.</span>")
				return FALSE
	else
		if(clothes_req || human_req)
			if(show_message)
				to_chat(user, "<span class='notice'>This spell can only be cast by humans!</span>")
			return FALSE
		if(nonabstract_req && (isbrain(user) || ispAI(user)))
			if(show_message)
				to_chat(user, "<span class='notice'>This spell can only be cast by physical beings!</span>")
			return FALSE

	if(custom_handler && !custom_handler.can_cast(user, charge_check, show_message, src))
		return FALSE

	return TRUE
/obj/effect/proc_holder/spell/summonmob
	name = "Summon Servant"
	desc = "This spell can be used to call your servant, whenever you need it."
	base_cooldown = 10 SECONDS
	clothes_req = FALSE
	invocation = "JE VES"
	invocation_type = "whisper"
	level_max = 0 //cannot be improved
	cooldown_min = 100

	var/mob/living/target_mob

	action_icon_state = "summons"

/obj/effect/proc_holder/spell/summonmob/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/effect/proc_holder/spell/summonmob/cast(list/targets, mob/user = usr)
	if(!target_mob)
		return
	var/turf/Start = get_turf(user)
	for(var/direction in GLOB.alldirs)
		var/turf/T = get_step(Start,direction)
		if(!T.density)
			target_mob.Move(T)
