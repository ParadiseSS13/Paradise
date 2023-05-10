/obj/item/hardsuit_shield
	name = "Hardsuit Shield Upgrade module"
	desc = "This upgrade grants shields to any hardsuit."
	icon = 'icons/obj/hardsuits_modules.dmi'
	icon_state = "powersink"
	var/obj/item/clothing/suit/space/hardsuit/hardsuit = null
	var/current_charges = 3
	var/max_charges = 3 //How many charges total the shielding has
	var/recharge_delay = 200 //How long after we've been shot before we can start recharging. 20 seconds here
	var/recharge_cooldown = 0 //Time since we've last been shot
	var/recharge_rate = 1 //How quickly the shield recharges once it starts charging
	var/shield_state = "shield-old"
	var/shield_on = "shield-old"
	var/allowed_to_change_color = FALSE

/obj/item/hardsuit_shield/syndi
	allowed_to_change_color = TRUE
	shield_state = "shield-red"
	shield_on = "shield-red"

/obj/item/hardsuit_shield/wizard
	current_charges = 15
	max_charges = 15
	recharge_cooldown = INFINITY
	recharge_rate = 0
	shield_state = "shield-red"
	shield_on = "shield-red"

/obj/item/hardsuit_shield/wizard/arch
	recharge_cooldown = 0
	recharge_rate = 1

/obj/item/hardsuit_shield/multitool_act(mob/user, obj/item/I)
	if(!allowed_to_change_color)
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(shield_state == "broken")
		to_chat(user, "<span class='warning'>You can't interface with the hardsuit's software if the shield's broken!</span>")
		return

	if(shield_state == "shield-red")
		shield_state = "shield-old"
		shield_on = "shield-old"
		to_chat(user, "<span class='warning'>You roll back the hardsuit's software, changing the shield's color!</span>")
	else
		shield_state = "shield-red"
		shield_on = "shield-red"
		to_chat(user, "<span class='warning'>You update the hardsuit's hardware, changing back the shield's color to red.</span>")

	user.update_inv_wear_suit()

/obj/item/hardsuit_shield/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!hardsuit)
		return FALSE
	recharge_cooldown = world.time + recharge_delay
	if(current_charges > 0)
		do_sparks(2, 1, src)
		owner.visible_message("<span class='danger'>[owner]'s shields deflect [attack_text] in a shower of sparks!</span>")
		current_charges--
		if(recharge_rate)
			START_PROCESSING(SSobj, src)
		if(current_charges <= 0)
			owner.visible_message("<span class='warning'>[owner]'s shield overloads!</span>")
			shield_state = "broken"
			owner.update_inv_wear_suit()
		return TRUE
	return FALSE

/obj/item/hardsuit_shield/process()
	if(world.time > recharge_cooldown && current_charges < max_charges)
		current_charges = clamp((current_charges + recharge_rate), 0, max_charges)
		playsound(loc, 'sound/magic/charge.ogg', 50, TRUE)
		if(current_charges == max_charges)
			playsound(loc, 'sound/machines/ding.ogg', 50, TRUE)
			STOP_PROCESSING(SSobj, src)
		shield_state = "[shield_on]"
		if(hardsuit && ishuman(hardsuit.loc))
			var/mob/living/carbon/human/C = hardsuit.loc
			C.update_inv_wear_suit()

/obj/item/hardsuit_shield/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/storage/box/ert_hardsuit_shield_upgrade
	name = "Hardsuit Shield Upgrade Box"
	desc = "A Exclusive and Expensive upgrade for Hardsuits."
	icon_state = "box_ert"

/obj/item/storage/box/ert_hardsuit_shield_upgrade/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/hardsuit_shield(src)
