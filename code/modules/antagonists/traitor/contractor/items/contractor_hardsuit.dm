//contractor hardsuit

/obj/item/clothing/head/helmet/space/hardsuit/contractor
	name = "Contractor hardsuit helmet"
	desc = "A top-tier syndicate helmet, a favorite of Syndicate field Contractors. Property of the Gorlex Marauders, with assistance from Cybersun Industries."
	icon_state = "hardsuit0-contractor"
	item_state = "contractor_helm"
	item_color = "contractor"
	armor = list("melee" = 40, "bullet" = 50, "laser" = 30, "energy" = 30, "bomb" = 35, "bio" = 100, "rad" = 50, "fire" = 50, "acid" = 90)
	actions_types = list(/datum/action/item_action/toggle_helmet_light)

/obj/item/clothing/suit/space/hardsuit/contractor
	name = "Contractor hardsuit"
	desc = "A top-tier syndicate hardsuit, a favorite of Syndicate field Contractors. Property of the Gorlex Marauders, with assistance from Cybersun Industries."
	icon_state = "hardsuit-contractor"
	item_state = "contractor_hardsuit"
	item_color = "contractor"
	armor = list("melee" = 40, "bullet" = 50, "laser" = 30, "energy" = 30, "bomb" = 35, "bio" = 100, "rad" = 50, "fire" = 50, "acid" = 90)
	slowdown = 0
	w_class = WEIGHT_CLASS_NORMAL
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/contractor
	jetpack = /obj/item/tank/jetpack/suit
	allowed = list(/obj/item/gun, /obj/item/ammo_box,/obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/melee/energy/sword, /obj/item/restraints/handcuffs, /obj/item/tank/internals)
	actions_types = list(
		/datum/action/item_action/toggle_helmet,
		/datum/action/item_action/advanced/chameleon_upgrade
		//datum/action/item_action/advanced/hook_upgrade
		)
	//working as ninja hook, deleted when droped
	var/obj/item/gun/magic/contractor_hook/scorpion
	var/disguise = FALSE

/obj/item/clothing/suit/space/hardsuit/contractor/Destroy()
	. = ..()
	QDEL_NULL(scorpion)

/obj/item/clothing/suit/space/hardsuit/contractor/ui_action_click(user, action)
	switch(action)
		if(/datum/action/item_action/toggle_helmet)
			ToggleHelmet()
			return TRUE
		if(/datum/action/item_action/advanced/hook_upgrade)
			toggle_hook()
			return TRUE
		if(/datum/action/item_action/advanced/chameleon_upgrade)
			toggle_chameleon()
			return TRUE
	return FALSE

/obj/item/clothing/suit/space/hardsuit/contractor/proc/update_suit()
	var/mob/living/carbon/human/H = src.loc
	H.update_inv_head()
	H.update_inv_wear_suit()

//agent version disguised as engi hardsuit

/obj/item/clothing/head/helmet/space/hardsuit/contractor/agent
	name = "engineering hardsuit helmet"
	desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has radiation shielding."
	description_antag = "Шлем хардсьюта-хамелеона, замаскированный изначально под инженерный шлем."
	icon_state = "hardsuit0-engineering"
	item_state = "eng_helm"

/obj/item/clothing/suit/space/hardsuit/contractor/agent
	name = "engineering hardsuit"
	desc = "A special suit that protects against hazardous, low pressure environments. Has radiation shielding."
	description_antag = "Хардсьют-хамелеон, замаскированный изначально под инженерный хардсьют. Красный - предатель!"
	icon_state = "hardsuit-engineering"
	item_state = "eng_hardsuit"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/contractor/agent

/*
		Hook
		Much worse version of lava and ninja hook for balance reasons.

*/
/datum/action/item_action/advanced/hook_upgrade
	name = "Hardsuit SCORPION hook module"
	desc = "A module installed in the wrist of your hardsuit, this highly illegal module uses a hardlight hook to forcefully pull a target towards you at high speed, knocking them down and partially exhausting them."
	charge_type = ADV_ACTION_TYPE_TOGGLE_RECHARGE
	charge_max = 6 SECONDS
	use_itemicon = FALSE
	icon_icon = 'icons/mob/actions/actions.dmi'
	button_icon_state = "hook"
	button_icon = 'icons/mob/actions/actions.dmi'

/obj/item/clothing/suit/space/hardsuit/contractor/proc/toggle_hook()
	if(scorpion)
		qdel(scorpion)
		scorpion = null
	else
		scorpion = new
		scorpion.suit = src
		for(var/datum/action/item_action/advanced/hook_upgrade/hook in actions)
			scorpion.hook_action = hook
			hook.action_ready = TRUE
			hook.toggle_button_on_off()
			break
		usr.put_in_hands(scorpion)
		playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
		to_chat(usr, "<span class='notice'>You engage the [scorpion].</span>")

/datum/action/item_action/advanced/hook_upgrade/toggle_button_on_off()
	if(action_ready)
		background_icon_state = icon_state_active
	else
		background_icon_state = icon_state_disabled
	UpdateButtonIcon()

/obj/item/gun/magic/contractor_hook
	name = "SCORPION hook"
	desc = "A hardlight hook used to non-lethally pull targets much closer to the user."
	ammo_type = /obj/item/ammo_casing/magic/contractor_hook
	icon = 'icons/obj/weapons/energy.dmi'
	icon_state = "hook_weapon"
	item_state = "gun"
	fire_sound = 'sound/weapons/batonextend.ogg'
	max_charges = 1
	recharge_rate = 0
	charge_tick = 1
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_MEDIUM
	slot_flags = 0
	flags = DROPDEL | ABSTRACT | NOBLUDGEON | NOPICKUP
	force = 0
	var/obj/item/clothing/suit/space/hardsuit/contractor/suit = null
	var/datum/action/item_action/advanced/hook_upgrade/hook_action  = null

/obj/item/gun/magic/contractor_hook/Destroy()
	. = ..()
	suit.scorpion = null
	suit = null
	hook_action.action_ready = FALSE
	hook_action.toggle_button_on_off()
	hook_action = null

/obj/item/gun/magic/contractor_hook/can_trigger_gun(mob/living/user)
	if(!hook_action.IsAvailable(show_message = TRUE, ignore_ready = TRUE))
		return FALSE
	else
		hook_action.use_action()
		return TRUE

/obj/item/gun/magic/contractor_hook/equip_to_best_slot(mob/M)
	qdel(src)

/obj/item/ammo_casing/magic/contractor_hook
	name = "Hardlight hook"
	desc = "a hardlight hook."
	projectile_type = /obj/item/projectile/contractor_hook
	caliber = "hardlight_hook"
	icon_state = "hard_hook"
	muzzle_flash_effect = null

/obj/item/projectile/contractor_hook
	name = "Hardlight hook"
	icon_state = "hard_hook"
	icon = 'icons/obj/weapons/projectiles.dmi'
	pass_flags = PASSTABLE
	damage = 0
	stamina = 25
	hitsound = 'sound/weapons/whip.ogg'
	weaken = 2 SECONDS
	ricochet_chance = 0
	range = 7

/obj/item/projectile/contractor_hook/fire(setAngle)
	if(firer)
		chain = firer.Beam(src, icon_state = "hard_chain", time = INFINITY, maxdistance = INFINITY, beam_sleep_time = 1)
	..()

/obj/item/projectile/contractor_hook/on_hit(atom/target, blocked = 0)
	. = ..()
	if(blocked >= 100)
		return 0
	if(isliving(target))
		var/mob/living/L = target
		if(!L.anchored && L.loc)
			L.visible_message("<span class='danger'>[L] is snagged by [firer]'s hook!</span>")

			var/old_density = L.density
			L.density = FALSE // Ensures the hook does not hit the target multiple times
			L.forceMove(get_turf(firer))
			L.density = old_density
			firer.drop_item_ground(src)



/obj/item/projectile/contractor_hook/Destroy()
	QDEL_NULL(chain)
	return ..()
/*
	Chameleon
		Hardsuit chameleon module, very limited choice, shutting down when EMP'd.
*/

/datum/action/item_action/advanced/chameleon_upgrade
	name = "Advanced hardsuit chameleon module"
	desc = "An advanced version of chameleon tech, allowing you to disguise your hardsuit, giving you the opportunity to walk in full view of security and personnel without any difficulties."
	charge_type = ADV_ACTION_TYPE_TOGGLE
	use_itemicon = FALSE
	icon_icon = 'icons/mob/actions/actions.dmi'
	button_icon_state = "chameleon"
	button_icon = 'icons/mob/actions/actions.dmi'

/obj/item/clothing/suit/space/hardsuit/contractor/proc/toggle_chameleon()
	if(disguise)
		disguise = FALSE
		disable_chameleon()
		usr.visible_message("<span class='warning'>[usr] changes the look of his hardsuit!</span>", "<span class='notice'>Turning off the disguise..</span>")
		return
	var/list/choices = list(
		"EVA" = image(icon = 'icons/mob/contractor.dmi', icon_state = "EVA"),
		"Mining Hardsuit" = image(icon = 'icons/mob/contractor.dmi', icon_state = "mining"),
		"Medical Hardsuit" = image(icon = 'icons/mob/contractor.dmi', icon_state = "medical"),
		"Security Hardsuit" = image(icon = 'icons/mob/contractor.dmi', icon_state = "security"),
		"Engineering Hardsuit" = image(icon = 'icons/mob/contractor.dmi', icon_state = "engineering")
	)
	var/selected_chameleon = show_radial_menu(usr, loc, choices, require_near = TRUE)
	switch(selected_chameleon)
		if("EVA")
			src.name = "EVA suit"
			src.icon_state = "spacenew"
			src.desc = "A lightweight space suit with the basic ability to protect the wearer from the vacuum of space during emergencies."
			helmet.name = "EVA helmet"
			helmet.desc = "A lightweight space helmet with the basic ability to protect the wearer from the vacuum of space during emergencies."
			helmet.icon_state = "spacenew"
			helmet.item_color = "medical"
		if("Mining Hardsuit")
			src.name = "mining hardsuit"
			src.icon_state = "hardsuit-mining"
			src.desc = "A special suit that protects against hazardous, low pressure environments. Has reinforced plating."
			helmet.name = "mining hardsuit helmet"
			helmet.desc = "A special helmet designed for work in a hazardous, low pressure environment. Has reinforced plating."
			helmet.icon_state = "hardsuit0-mining"
			helmet.item_color = "mining"
		if("Medical Hardsuit")
			src.name = "medical hardsuit"
			src.icon_state = "hardsuit-medical"
			src.desc = "A special suit designed for work in a hazardous, low pressure environment. Built with lightweight materials for extra comfort."
			helmet.name = "medical hardsuit helmet"
			helmet.desc = "A special helmet designed for work in a hazardous, low pressure environment. Built with lightweight materials for extra comfort, but does not protect the eyes from intense light."
			helmet.icon_state = "hardsuit0-medical"
			helmet.item_color = "medical"
		if("Security Hardsuit")
			src.name = "security hardsuit"
			src.icon_state = "hardsuit-sec"
			src.desc = "A special suit that protects against hazardous, low pressure environments. Has an additional layer of armor."
			helmet.name = "security hardsuit helmet"
			helmet.desc = "A special helmet designed for work in a hazardous, low pressure environment. Has an additional layer of armor."
			helmet.icon_state = "hardsuit0-sec"
			helmet.item_color = "sec"
		if("Engineering Hardsuit")
			src.name = "engineering hardsuit"
			src.icon_state = "hardsuit-engineering"
			src.desc = "A special suit that protects against hazardous, low pressure environments. Has radiation shielding."
			helmet.name = "engineering hardsuit helmet"
			helmet.desc = "A special helmet designed for work in a hazardous, low-pressure environment. Has radiation shielding."
			helmet.icon_state = "hardsuit0-engineering"
			helmet.item_color = "engineering"
		else
			return
	to_chat(usr, "<span class='notice'>Turning on the disguise..</span>")
	sleep(25)
	usr.visible_message("<span class='warning'>[usr] changes the look of his hardsuit!</span>", "<span class='notice'>[selected_chameleon] selected.</span>")
	playsound(loc, 'sound/items/screwdriver2.ogg', 50, 1)
	update_suit()
	disguise = TRUE


/obj/item/clothing/suit/space/hardsuit/contractor/proc/disable_chameleon()
	src.name = initial(src.name)
	src.icon_state = initial(src.icon_state)
	src.desc = initial(src.desc)
	helmet.name = initial(helmet.name)
	helmet.desc = initial(helmet.desc)
	helmet.icon_state = initial(helmet.icon_state)
	helmet.item_color = initial(helmet.item_color)
	update_suit()

/obj/item/clothing/suit/space/hardsuit/contractor/emp_act(severity)
	. = ..()
	if(disguise)
		usr.visible_message("<span class='warning'>[usr] disguise is falling off!</span>", "<span class='notice'>Chameleon module overloading! Shutting down...</span>")
		disguise = FALSE
		disable_chameleon()

