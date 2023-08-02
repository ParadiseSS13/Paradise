#define SPELL_TARGET_CLOSEST 1
#define SPELL_TARGET_RANDOM 2

#define SPELL_SELECTION_RANGE "range"
#define SPELL_SELECTION_VIEW "view"

#define SMOKE_NONE		0
#define SMOKE_HARMLESS	1
#define SMOKE_COUGHING	2
#define SMOKE_SLEEPING	3


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


/obj/effect/proc_holder/proc/InterceptClickOn(mob/user, params, atom/target)
	if(user.ranged_ability != src)
		to_chat(user, span_warning("<b>[user.ranged_ability.name]</b> has been disabled."))
		user.ranged_ability.remove_ranged_ability(user)
		return TRUE //TRUE for failed, FALSE for passed.
	user.changeNext_click(CLICK_CD_CLICK_ABILITY)
	user.face_atom(target)
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
		to_chat(user, span_warning("<b>[user.ranged_ability.name]</b> has been replaced by <b>[name]</b>."))
		user.ranged_ability.remove_ranged_ability(user)
	user.ranged_ability = src
	ranged_ability_user = user
	user.client.click_intercept = new /datum/click_intercept/proc_holder(user.client, user.ranged_ability)
	add_mousepointer(user.client)
	active = TRUE
	if(msg)
		to_chat(user, msg)
	update_icon()


/obj/effect/proc_holder/proc/add_mousepointer(client/our_client)
	if(our_client && ranged_mousepointer && our_client.mouse_pointer_icon == initial(our_client.mouse_pointer_icon))
		our_client.mouse_pointer_icon = ranged_mousepointer


/obj/effect/proc_holder/proc/remove_mousepointer(client/our_client)
	if(our_client && ranged_mousepointer && our_client.mouse_pointer_icon == ranged_mousepointer)
		our_client.mouse_pointer_icon = initial(our_client.mouse_pointer_icon)


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
	name = "Spell"
	desc = "A wizard spell"
	/// What panel the proc holder needs to go on.
	panel = "Spells"
	density = FALSE
	opacity = FALSE

	/// Not relevant at now, but may be important later if there are changes to how spells work. the ones I used for now will probably be changed... maybe spell presets? lacking flexibility but with some other benefit?
	var/school = "evocation"
	/// Recharge time in deciseconds
	var/base_cooldown = 10 SECONDS
	/// Does this spell start ready to go?
	var/starts_charged = TRUE
	/// Whether an ability should start cooldown after cast or not.
	var/should_recharge_after_cast = TRUE
	/// Messace user get when clicks on rechargins spell button.
	var/still_recharging_msg = span_notice("The spell is still recharging.")

	/// Spell can only be cast with special wizard garb, equipped in appropriete slots.
	var/clothes_req = TRUE
	/// Spell can only be cast by humans.
	var/human_req = TRUE
	/// Spell can only be cast by mobs that are physical entities. Currently checks whether caster is brain or pAI.
	var/nonabstract_req = FALSE
	/// Checks user stat on cast, could be "CONSCIOUS", "UNCONSCIOUS", "DEAD".
	var/stat_allowed = CONSCIOUS
	/// If set to `TRUE` spell will skip stat check, defined in "stat_allowed" variable.
	var/ghost = FALSE
	/// If set to `TRUE`, spell can be cast while phased, eg. blood crawling, ethereal jaunting.
	var/phase_allowed = FALSE
	/// What is uttered when the wizard casts the spell.
	var/invocation = "HURP DURP"
	/// If invocation_type is "emote", caster will perform emote on cast, should be same style as in [mob/living/emote.dm].
	var/invocation_emote_self = null
	/// Can be "none", "whisper", "shout" and "emote".
	var/invocation_type = "none"
	/// Whatever it says to the guy affected by it.
	var/message = ""
	/// If a spell can be taken multiple times, this raises.
	var/spell_level = 0
	/// The max possible level_max is 4.
	var/level_max = 4
	/// This defines what spell quickened four timeshas as a cooldown. Make sure to set this for every spell.
	var/cooldown_min = 0

	/// Wheter special overlay effect should be played on user, after spell cast.
	var/overlay = FALSE
	/// Special overlay icon file.
	var/overlay_icon = 'icons/obj/wizard.dmi'
	/// Special overlay icon state.
	var/overlay_icon_state = "spell"
	/// Time before special effect will be deleted.
	var/overlay_lifespan = 0

	/// Whether spell should make sparks visual effect on targets location, after the main cast.
	var/sparks_spread = FALSE
	/// Amount of sparks if "sparks_spread" is set to `TRUE`.
	var/sparks_amt = 0

	///Determines if the spell has smoke, and if so what effect the smoke has. See spell defines.
	var/smoke_type = SMOKE_NONE
	var/smoke_amt = 0

	var/critfailchance = 0
	/// Whether or not the spell should be allowed on admin Z-level.
	var/centcom_cancast = TRUE
	/// Whether or not the spell functions in a holy place
	var/holy_area_cancast = TRUE

	/// Action with a button linked to this spell.
	var/datum/action/spell_action/action = null
	/// Action icon file. Its a main image overlay, often without background.
	var/action_icon = 'icons/mob/actions/actions.dmi'
	/// State of the icon found in file, passed in "action_icon" variable.
	var/action_icon_state = "spell_default"
	/// Same as action icon, but used for image background overlay. Usefull when our action icon has no background at all.
	var/action_background_icon = 'icons/mob/actions/actions.dmi'
	/// State of the icon found in file, passed in "action_background_icon" variable.
	var/action_background_icon_state = "bg_spell"

	/// Whether this spell need a white frame around the button while active, usefull for click based targeting.
	var/need_active_overlay = FALSE

	/// The sound the spell makes when it is cast.
	var/sound = null
	/// This message will be shown to user upon receiving the spell.
	var/gain_desc = null

	/// The message displayed when a click based spell gets activated
	var/selection_activated_message	= span_notice("Click on a target to cast the spell.")
	/// The message displayed when a click based spell gets deactivated
	var/selection_deactivated_message = span_notice("You choose to not cast this spell.")

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
	/// Handles a given spells cooldowns. Tracks the time until its off cooldown.
	var/datum/spell_cooldown/cooldown_handler


/**
 * Checks if the user can cast the spell
 *
 * Arguments:
 * charge_check - If the proc should do the cooldown check
 * start_recharge - If the proc should set the cooldown
 * user - The caster of the spell
 */
/obj/effect/proc_holder/spell/proc/cast_check(charge_check = TRUE, start_recharge = TRUE, mob/user = usr) //checks if the spell can be cast based on its settings; skipcharge is used when an additional cast_check is called inside the spell
	if(!can_cast(user, charge_check, TRUE))
		return FALSE

	if(ishuman(user))
		var/mob/living/carbon/human/caster = user
		if(caster.remoteview_target)
			caster.remoteview_target = null
			caster.reset_perspective(0)
			return FALSE

	if(start_recharge)
		spend_spell_cost(user)

	return TRUE


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


/obj/effect/proc_holder/spell/proc/invocation(mob/user = usr) //spelling the spell out and setting it on recharge/reducing charges amount
	switch(invocation_type)
		if("shout")
			if(!user.IsVocal())
				user.custom_emote(1, "makes frantic gestures!")
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
	playsound(get_turf(usr), sound, 50, TRUE)


/obj/effect/proc_holder/spell/New()
	..()
	action = new(src)
	still_recharging_msg = span_notice("[name] is still recharging.")
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
	after_spell_init()


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
	var/datum/spell_cooldown/s_cooldown = new
	s_cooldown.recharge_duration = base_cooldown
	s_cooldown.starts_off_cooldown = starts_charged
	return s_cooldown


/**
 * This proc will trigger when all necessary initialization is done. Usefull for staff like changing spell name.
 */
/obj/effect/proc_holder/spell/proc/after_spell_init()


/**
 * This will apply on every tick of cooldown process.
 */
/obj/effect/proc_holder/spell/proc/on_cooldown_tick()


/obj/effect/proc_holder/spell/Click()
	if(cast_check(TRUE, FALSE, usr))
		choose_targets(usr)
	return TRUE


/obj/effect/proc_holder/spell/InterceptClickOn(mob/user, params, atom/A)
	. = ..()
	if(.)
		return
	targeting.InterceptClickOn(user, params, A, src)


/**
 * Lets the spell have a special effect applied to it when upgraded. By default, does nothing.
 */
/obj/effect/proc_holder/spell/proc/on_purchase_upgrade()
	return


/**
 * Will try to choose targets using the targeting variable and perform the spell if it can
 * Do not override this! Override create_new_targeting instead
 *
 * Arguments:
 * * user - The caster of the spell
 */
/obj/effect/proc_holder/spell/proc/choose_targets(mob/user = usr)
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
		to_chat(user, span_warning("No suitable target found."))
		return FALSE

	if(should_remove_click_intercept(user)) // returns TRUE by default
		remove_ranged_ability(user) // Targeting succeeded. So remove the click interceptor if there is one. Even if the cast didn't succeed afterwards

	if(!cast_check(TRUE, TRUE, user))
		return

	perform(targets, should_recharge_after_cast, user)


/**
 * Called in `try_perform` before removing the click interceptor. Useful to override if you have a spell that requires more than 1 click
 */
/obj/effect/proc_holder/spell/proc/should_remove_click_intercept(mob/user)
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


/**
 * Resets recharge or readds a charge.
 */
/obj/effect/proc_holder/spell/proc/revert_cast(mob/user = usr) //
	cooldown_handler.revert_cast()
	custom_handler?.revert_cast(user, src)

	if(action)
		action.UpdateButtonIcon()


/obj/effect/proc_holder/spell/proc/updateButtonIcon(change_name = FALSE)
	if(action)
		if(change_name)
			action.name = name
			action.desc = desc
		action.UpdateButtonIcon()


/**
 * Handles the adjustment of the var when the spell is used. Has some hardcoded types.
 */
/obj/effect/proc_holder/spell/proc/adjust_var(mob/living/target = usr, type, amount)
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


/obj/effect/proc_holder/spell/aoe
	name = "Spell"
	create_attack_logs = FALSE
	create_custom_logs = TRUE
	/// How far does it effect
	var/aoe_range = 7


/**
 * Normally, AoE spells will generate an attack log for every turf they loop over, while searching for targets.
 * With this override, all /aoe type spells will only generate 1 log, saying that the user has cast the spell.
 */
/obj/effect/proc_holder/spell/aoe/write_custom_logs(list/targets, mob/user)
	add_attack_logs(user, null, "Cast the AoE spell [name]", ATKLOG_ALL)


/obj/effect/proc_holder/spell/proc/can_cast(mob/user = usr, charge_check = TRUE, show_message = FALSE)
	if(((!user.mind) || !(src in user.mind.spell_list)) && !(src in user.mob_spell_list))
		if(show_message)
			to_chat(user, span_warning("You shouldn't have this spell! Something's wrong."))
		return FALSE

	if(!centcom_cancast) //Certain spells are not allowed on the centcom zlevel
		var/turf/user_turf = get_turf(user)
		if(user_turf && is_admin_level(user_turf.z))
			return FALSE

	if(!holy_area_cancast && user.holy_check())
		return FALSE

	if(charge_check)
		if(cooldown_handler.is_on_cooldown())
			if(show_message)
				to_chat(user, still_recharging_msg)
			return FALSE

	if(!ghost)
		if(stat_allowed < user.stat)
			if(show_message)
				if(user.stat == UNCONSCIOUS)
					to_chat(user, span_notice("You can't use <b>[name]</b> while unconscious."))
				if(user.stat == DEAD)
					to_chat(user, span_notice("You can't use <b>[name]</b> while dead."))
			return FALSE

		if(!phase_allowed && istype(user.loc, /obj/effect/dummy) || istype(user.loc, /obj/effect/immovablerod/wizard))
			if(show_message)
				to_chat(user, span_notice("[name] cannot be cast unless you are completely manifested in the material plane!"))
			return FALSE

		if(ishuman(user) && (invocation_type == "whisper" || invocation_type == "shout") && user.is_muzzled())
			if(show_message)
				to_chat(user, "Mmmf mrrfff!")
			return FALSE

	if(ishuman(user))

		var/mob/living/carbon/human/h_user = user
		var/clothcheck = locate(/obj/effect/proc_holder/spell/noclothes) in h_user.mob_spell_list
		var/clothcheck2 = h_user.mind && (locate(/obj/effect/proc_holder/spell/noclothes) in h_user.mind.spell_list)

		if(clothes_req && !clothcheck && !clothcheck2) //clothes check
			var/obj/item/clothing/robe = h_user.wear_suit
			var/obj/item/clothing/hat = h_user.head
			var/obj/item/clothing/shoes = h_user.shoes
			if(!robe || !hat || !shoes)
				if(show_message)
					to_chat(h_user, span_notice("Your outfit isn't complete, you should put on your robe and wizard hat, as well as sandals"))
				return FALSE

			if(!robe.magical || !hat.magical || !shoes.magical)
				if(show_message)
					to_chat(h_user, span_notice("Your outfit isn't magical enough, you should put on your robe and wizard hat, as well as your sandals."))
				return FALSE

	else
		if(clothes_req || human_req)
			if(show_message)
				to_chat(user, span_notice("This spell can only be cast by humans!"))
			return FALSE

		if(nonabstract_req && (isbrain(user) || ispAI(user)))
			if(show_message)
				to_chat(user, span_notice("This spell can only be cast by physical beings!"))
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
	cooldown_min = 10 SECONDS
	action_icon_state = "summons"
	var/mob/living/target_mob


/obj/effect/proc_holder/spell/summonmob/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/summonmob/cast(list/targets, mob/user = usr)
	if(!target_mob)
		return

	var/turf/Start = get_turf(user)
	for(var/direction in GLOB.alldirs)
		var/turf/step_turf = get_step(Start,direction)
		if(!step_turf.density)
			target_mob.Move(step_turf)

