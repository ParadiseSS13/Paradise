/obj/item/clothing/glasses/hud/security/eyepatch
	name = "повязка на глаз с secHUD"
	desc = "Прототип повязки на глаз с интегрированным secHUD. От этого исполнения отказались в пользу более удобного и легковесного размещения в очках, однако на устройство все еще спрос среди ценителей. Данную повязку можно носить как на правом, так и на левом глазу."
	icon = 'modular_ss220/clothing/icons/object/eyes.dmi'
	icon_state = "hudpatch"
	item_state = "hudpatch"
	item_color = "hudpatch"
	sprite_sheets = list(
		"Human" = 'modular_ss220/clothing/icons/mob/eyes.dmi',
		"Tajaran" = 'modular_ss220/clothing/icons/mob/eyes.dmi',
		"Vulpkanin" = 'modular_ss220/clothing/icons/mob/eyes.dmi',
		"Kidan" = 'modular_ss220/clothing/icons/mob/species/kidan/eyes.dmi',
		"Skrell" = 'modular_ss220/clothing/icons/mob/eyes.dmi',
		"Nucleation" = 'modular_ss220/clothing/icons/mob/eyes.dmi',
		"Skeleton" = 'modular_ss220/clothing/icons/mob/eyes.dmi',
		"Slime People" = 'modular_ss220/clothing/icons/mob/eyes.dmi',
		"Unathi" = 'modular_ss220/clothing/icons/mob/eyes.dmi',
		"Grey" = 'modular_ss220/clothing/icons/mob/species/grey/eyes.dmi',
		"Abductor" = 'modular_ss220/clothing/icons/mob/eyes.dmi',
		"Golem" = 'modular_ss220/clothing/icons/mob/eyes.dmi',
		"Machine" = 'modular_ss220/clothing/icons/mob/eyes.dmi',
		"Diona" = 'modular_ss220/clothing/icons/mob/eyes.dmi',
		"Nian" = 'modular_ss220/clothing/icons/mob/eyes.dmi',
		"Shadow" = 'modular_ss220/clothing/icons/mob/eyes.dmi',
		"Vox" = 'modular_ss220/clothing/icons/mob/species/vox/eyes.dmi',
		"Drask" = 'modular_ss220/clothing/icons/mob/species/drask/eyes.dmi',
	)
	prescription_upgradable = FALSE
	var/flipped = FALSE

/obj/item/clothing/glasses/hud/security/eyepatch/update_icon_state()
	item_state = flipped ? "[initial(item_state)]_flipped" : initial(item_state)
	icon_state = flipped ? "[initial(icon_state)]_flipped" : initial(icon_state)

/obj/item/clothing/glasses/hud/security/eyepatch/attack_self__legacy__attackchain(mob/user)
	flipped = !flipped
	to_chat(user, "You flip [src] [flipped ? "left" : "right"].")
	update_icon(UPDATE_ICON_STATE)
