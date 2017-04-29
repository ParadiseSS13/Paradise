#define TARGET_CLOSEST 1
#define TARGET_RANDOM 2

/obj/effect/proc_holder
	var/panel = "Debug"//What panel the proc holder needs to go on.
	var/active = FALSE //Used by toggle based abilities.
	var/ranged_mousepointer

var/list/spells = typesof(/obj/effect/proc_holder/spell) //needed for the badmin verb for now

/obj/effect/proc_holder/proc/InterceptClickOn(mob/living/user, params, atom/A)
	if(user.ranged_ability != src)
		to_chat(user, "<span class='warning'><b>[user.ranged_ability.name]</b> has been disabled.")
		user.ranged_ability.remove_ranged_ability(user)
		return TRUE //TRUE for failed, FALSE for passed.
	user.next_click = world.time + CLICK_CD_CLICK_ABILITY
	user.face_atom(A)
	return FALSE

/obj/effect/proc_holder/proc/add_ranged_ability(mob/living/user, var/msg)
	if(!user || !user.client)
		return
	if(user.ranged_ability && user.ranged_ability != src)
		to_chat(user, "<span class='warning'><b>[user.ranged_ability.name]</b> has been replaced by <b>[name]</b>.")
		user.ranged_ability.remove_ranged_ability(user)
	user.ranged_ability = src
	user.client.click_intercept = user.ranged_ability
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

/obj/effect/proc_holder/proc/remove_ranged_ability(mob/living/user, var/msg)
	if(!user || !user.client || (user.ranged_ability && user.ranged_ability != src)) //To avoid removing the wrong ability
		return
	user.ranged_ability = null
	user.client.click_intercept = null
	remove_mousepointer(user.client)
	active = FALSE
	if(msg)
		to_chat(user, msg)
	update_icon()

/obj/effect/proc_holder/spell
	name = "Spell"
	desc = "A wizard spell"
	panel = "Spells"//What panel the proc holder needs to go on.
	density = 0
	opacity = 0

	var/school = "evocation" //not relevant at now, but may be important later if there are changes to how spells work. the ones I used for now will probably be changed... maybe spell presets? lacking flexibility but with some other benefit?

	var/charge_type = "recharge" //can be recharge or charges, see charge_max and charge_counter descriptions; can also be based on the holder's vars now, use "holder_var" for that

	var/charge_max = 100 //recharge time in deciseconds if charge_type = "recharge" or starting charges if charge_type = "charges"
	var/charge_counter = 0 //can only cast spells if it equals recharge, ++ each decisecond if charge_type = "recharge" or -- each cast if charge_type = "charges"
	var/still_recharging_msg = "<span class='notice'>The spell is still recharging.</span>"

	var/holder_var_type = "bruteloss" //only used if charge_type equals to "holder_var"
	var/holder_var_amount = 20 //same. The amount adjusted with the mob's var when the spell is used

	var/ghost = 0 // Skip life check.
	var/clothes_req = 1 //see if it requires clothes
	var/human_req = 0 //spell can only be cast by humans
	var/nonabstract_req = 0 //spell can only be cast by mobs that are physical entities
	var/stat_allowed = 0 //see if it requires being conscious/alive, need to set to 1 for ghostpells
	var/invocation = "HURP DURP" //what is uttered when the wizard casts the spell
	var/invocation_emote_self = null
	var/invocation_type = "none" //can be none, whisper and shout
	var/range = 7 //the range of the spell; outer radius for aoe spells
	var/message = "" //whatever it says to the guy affected by it
	var/selection_type = "view" //can be "range" or "view"
	var/spell_level = 0 //if a spell can be taken multiple times, this raises
	var/level_max = 4 //The max possible level_max is 4
	var/cooldown_min = 0 //This defines what spell quickened four timeshas as a cooldown. Make sure to set this for every spell

	var/overlay = 0
	var/overlay_icon = 'icons/obj/wizard.dmi'
	var/overlay_icon_state = "spell"
	var/overlay_lifespan = 0

	var/sparks_spread = 0
	var/sparks_amt = 0 //cropped at 10
	var/smoke_spread = 0 //1 - harmless, 2 - harmful
	var/smoke_amt = 0 //cropped at 10

	var/critfailchance = 0
	var/centcom_cancast = 1 //Whether or not the spell should be allowed on z2

	var/datum/action/spell_action/action = null
	var/action_icon = 'icons/mob/actions.dmi'
	var/action_icon_state = "spell_default"
	var/action_background_icon_state = "bg_spell"

	var/sound = null //The sound the spell makes when it is cast

/obj/effect/proc_holder/spell/proc/cast_check(skipcharge = 0, mob/living/user = usr) //checks if the spell can be cast based on its settings; skipcharge is used when an additional cast_check is called inside the spell
	if(((!user.mind) || !(src in user.mind.spell_list)) && !(src in user.mob_spell_list))
		to_chat(user, "<span class='warning'>You shouldn't have this spell! Something's wrong.</span>")
		return 0

	if(ishuman(user))
		var/mob/living/carbon/human/caster = user
		if(caster.remoteview_target)
			caster.remoteview_target = null
			caster.reset_perspective(0)
			return 0

	if(is_admin_level(user.z) && (!centcom_cancast || ticker.mode.name == "ragin' mages")) //Certain spells are not allowed on the centcom zlevel
		return 0

	if(!skipcharge)
		switch(charge_type)
			if("recharge")
				if(charge_counter < charge_max)
					to_chat(user, still_recharging_msg)
					return 0
			if("charges")
				if(!charge_counter)
					to_chat(user, "<span class='notice'>[name] has no charges left.</span>")
					return 0

	if(!ghost)
		if(user.stat && !stat_allowed)
			to_chat(user, "<span class='notice'>You can't cast this spell while incapacitated.</span>")
			return 0
		if(ishuman(user) && (invocation_type == "whisper" || invocation_type == "shout") && user.is_muzzled())
			to_chat(user, "Mmmf mrrfff!")
			return 0

	var/obj/effect/proc_holder/spell/noclothes/clothes_spell = locate() in (user.mob_spell_list | (user.mind ? user.mind.spell_list : list()))
	if((ishuman(user) && clothes_req) && !istype(clothes_spell))//clothes check
		var/mob/living/carbon/human/H = user
		if(!istype(H.wear_suit, /obj/item/clothing/suit/wizrobe) && !istype(H.wear_suit, /obj/item/clothing/suit/space/hardsuit/wizard))
			to_chat(user, "<span class='notice'>I don't feel strong enough without my robe.</span>")
			return 0
		if(!istype(H.shoes, /obj/item/clothing/shoes/sandal))
			to_chat(user, "<span class='notice'>I don't feel strong enough without my sandals.</span>")
			return 0
		if(!istype(H.head, /obj/item/clothing/head/wizard) && !istype(H.head, /obj/item/clothing/head/helmet/space/hardsuit/wizard))
			to_chat(user, "<span class='notice'>I don't feel strong enough without my hat.</span>")
			return 0
	else if(!ishuman(user))
		if(clothes_req || human_req)
			to_chat(user, "<span class='notice'>This spell can only be cast by humans!</span>")
			return 0
		if(nonabstract_req && (isbrain(user) || ispAI(user)))
			to_chat(user, "<span class='notice'>This spell can only be cast by physical beings!</span>")
			return 0

	if(!skipcharge)
		switch(charge_type)
			if("recharge")
				charge_counter = 0 //doesn't start recharging until the targets selecting ends
			if("charges")
				charge_counter-- //returns the charge if the targets selecting fails
			if("holdervar")
				adjust_var(user, holder_var_type, holder_var_amount)

	return 1

/obj/effect/proc_holder/spell/proc/invocation(mob/user = usr) //spelling the spell out and setting it on recharge/reducing charges amount
	switch(invocation_type)
		if("shout")
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
	charge_counter = charge_max

/obj/effect/proc_holder/spell/Destroy()
	QDEL_NULL(action)
	return ..()

/obj/effect/proc_holder/spell/Click()
	if(cast_check())
		choose_targets()
	return 1

/obj/effect/proc_holder/spell/proc/choose_targets(mob/user = usr) //depends on subtype - /targeted or /aoe_turf
	return

/obj/effect/proc_holder/spell/proc/start_recharge()
	if(action)
		action.UpdateButtonIcon()
	while(charge_counter < charge_max)
		sleep(1)
		charge_counter++
	if(action)
		action.UpdateButtonIcon()

/obj/effect/proc_holder/spell/proc/perform(list/targets, recharge = 1, mob/user = usr) //if recharge is started is important for the trigger spells
	before_cast(targets)
	invocation()
	if(user && user.ckey)
		user.create_attack_log("<font color='red'>[user.real_name] ([user.ckey]) cast the spell [name].</font>")
	spawn(0)
		if(charge_type == "recharge" && recharge)
			start_recharge()

	if(sound)
		playMagSound()

	if(prob(critfailchance))
		critfail(targets)
	else
		cast(targets, user = user)
	after_cast(targets)

/obj/effect/proc_holder/spell/proc/before_cast(list/targets)
	if(overlay)
		for(var/atom/target in targets)
			var/location
			if(istype(target,/mob/living))
				location = target.loc
			else if(istype(target,/turf))
				location = target
			var/obj/effect/overlay/spell = new /obj/effect/overlay(location)
			spell.icon = overlay_icon
			spell.icon_state = overlay_icon_state
			spell.anchored = 1
			spell.density = 0
			spawn(overlay_lifespan)
				qdel(spell)

/obj/effect/proc_holder/spell/proc/after_cast(list/targets)
	for(var/atom/target in targets)
		var/location
		if(istype(target,/mob/living))
			location = target.loc
		else if(istype(target,/turf))
			location = target
		if(istype(target,/mob/living) && message)
			to_chat(target, text("[message]"))
		if(sparks_spread)
			var/datum/effect/system/spark_spread/sparks = new /datum/effect/system/spark_spread()
			sparks.set_up(sparks_amt, 0, location) //no idea what the 0 is
			sparks.start()
		if(smoke_spread)
			if(smoke_spread == 1)
				var/datum/effect/system/harmless_smoke_spread/smoke = new /datum/effect/system/harmless_smoke_spread()
				smoke.set_up(smoke_amt, 0, location) //no idea what the 0 is
				smoke.start()
			else if(smoke_spread == 2)
				var/datum/effect/system/bad_smoke_spread/smoke = new /datum/effect/system/bad_smoke_spread()
				smoke.set_up(smoke_amt, 0, location) //no idea what the 0 is
				smoke.start()
			else if(smoke_spread == 3)
				var/datum/effect/system/sleep_smoke_spread/smoke = new /datum/effect/system/sleep_smoke_spread()
				smoke.set_up(smoke_amt, 0, location) // same here
				smoke.start()

/obj/effect/proc_holder/spell/proc/cast(list/targets, mob/user = usr)
	return

/obj/effect/proc_holder/spell/proc/critfail(list/targets)
	return

/obj/effect/proc_holder/spell/proc/revert_cast(mob/user = usr) //resets recharge or readds a charge
	switch(charge_type)
		if("recharge")
			charge_counter = charge_max
		if("charges")
			charge_counter++
		if("holdervar")
			adjust_var(user, holder_var_type, -holder_var_amount)

	return

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

/obj/effect/proc_holder/spell/targeted //can mean aoe for mobs (limited/unlimited number) or one target mob
	var/max_targets = 1 //leave 0 for unlimited targets in range, 1 for one selectable target in range, more for limited number of casts (can all target one guy, depends on target_ignore_prev) in range
	var/target_ignore_prev = 1 //only important if max_targets > 1, affects if the spell can be cast multiple times at one person from one cast
	var/include_user = 0 //if it includes usr in the target list
	var/random_target = 0 // chooses random viable target instead of asking the caster
	var/random_target_priority = TARGET_CLOSEST // if random_target is enabled how it will pick the target


/obj/effect/proc_holder/spell/aoe_turf //affects all turfs in view or range (depends)
	var/inner_radius = -1 //for all your ring spell needs

/obj/effect/proc_holder/spell/targeted/choose_targets(mob/user = usr)
	var/list/targets = list()

	switch(max_targets)
		if(0) //unlimited
			for(var/mob/living/target in view_or_range(range, user, selection_type))
				targets += target
		if(1) //single target can be picked
			if(range < 0)
				targets += user
			else
				var/possible_targets = list()

				for(var/mob/living/M in view_or_range(range, user, selection_type))
					if(!include_user && user == M)
						continue
					possible_targets += M

				//targets += input("Choose the target for the spell.", "Targeting") as mob in possible_targets
				//Adds a safety check post-input to make sure those targets are actually in range.
				var/mob/M
				if(!random_target)
					M = input("Choose the target for the spell.", "Targeting") as mob in possible_targets
				else
					switch(random_target_priority)
						if(TARGET_RANDOM)
							M = pick(possible_targets)
						if(TARGET_CLOSEST)
							for(var/mob/living/L in possible_targets)
								if(M)
									if(get_dist(user,L) < get_dist(user,M))
										if(los_check(user,L))
											M = L
								else
									if(los_check(user,L))
										M = L
				if(M in view_or_range(range, user, selection_type)) targets += M

		else
			var/list/possible_targets = list()
			for(var/mob/living/target in view_or_range(range, user, selection_type))
				possible_targets += target
			for(var/i=1,i<=max_targets,i++)
				if(!possible_targets.len)
					break
				if(target_ignore_prev)
					var/target = pick(possible_targets)
					possible_targets -= target
					targets += target
				else
					targets += pick(possible_targets)

	if(!include_user && (user in targets))
		targets -= user

	if(!targets.len) //doesn't waste the spell
		revert_cast(user)
		return

	perform(targets, user=user)

	return

/obj/effect/proc_holder/spell/aoe_turf/choose_targets(mob/user = usr)
	var/list/targets = list()

	for(var/turf/target in view_or_range(range,user,selection_type))
		if(!(target in view_or_range(inner_radius,user,selection_type)))
			targets += target

	if(!targets.len) //doesn't waste the spell
		revert_cast()
		return

	perform(targets, user=user)

	return


/obj/effect/proc_holder/spell/targeted/proc/los_check(mob/A,mob/B)
	//Checks for obstacles from A to B
	var/obj/dummy = new(A.loc)
	dummy.pass_flags |= PASSTABLE
	for(var/turf/turf in getline(A,B))
		for(var/atom/movable/AM in turf)
			if(!AM.CanPass(dummy,turf,1))
				qdel(dummy)
				return 0
	qdel(dummy)
	return 1

/obj/effect/proc_holder/spell/proc/can_cast(mob/user = usr)
	if(((!user.mind) || !(src in user.mind.spell_list)) && !(src in user.mob_spell_list))
		return 0

	if(is_admin_level(user.z) && (!centcom_cancast || ticker.mode.name == "ragin' mages")) //Certain spells are not allowed on the centcom zlevel
		return 0

	switch(charge_type)
		if("recharge")
			if(charge_counter < charge_max)
				return 0
		if("charges")
			if(!charge_counter)
				return 0

	if(user.stat && !stat_allowed)
		return 0

	if(ishuman(user))
		var/mob/living/carbon/human/H = user

		if((invocation_type == "whisper" || invocation_type == "shout") && H.is_muzzled())
			return 0

		var/clothcheck = locate(/obj/effect/proc_holder/spell/noclothes) in user.mob_spell_list
		var/clothcheck2 = user.mind && (locate(/obj/effect/proc_holder/spell/noclothes) in user.mind.spell_list)
		if(clothes_req && !clothcheck && !clothcheck2) //clothes check
			if(!istype(H.wear_suit, /obj/item/clothing/suit/wizrobe) && !istype(H.wear_suit, /obj/item/clothing/suit/space/hardsuit/wizard))
				return 0
			if(!istype(H.shoes, /obj/item/clothing/shoes/sandal))
				return 0
			if(!istype(H.head, /obj/item/clothing/head/wizard) && !istype(H.head, /obj/item/clothing/head/helmet/space/hardsuit/wizard))
				return 0
	else
		if(clothes_req  || human_req)
			return 0
		if(nonabstract_req && (isbrain(user) || ispAI(user)))
			return 0
	return 1
