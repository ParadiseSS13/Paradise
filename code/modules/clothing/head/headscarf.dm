/obj/item/clothing/head/headscarf
	name = "white headscarf"
	desc = "A stylish headscarf that can be worn several ways. You can rewrap it inhand."
	icon_state = "headscarf_dyeable"
	worn_icon_state = "hijab_dyeable"
	var/worn_as = "hijab"
	flags = BLOCKHAIR
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/hood.dmi'
	sprite_sheets = list(
		"Drask" = 'icons/mob/clothing/species/drask/head.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/head.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/head.dmi',
		"Nian" = 'icons/mob/clothing/species/nian/head.dmi',
		"Skrell" = 'icons/mob/clothing/species/skrell/head.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/head.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/head.dmi'
	)
	dyeable = TRUE
	dyeing_key = DYE_REGISTRY_HEADSCARF

/obj/item/clothing/head/headscarf/activate_self(mob/user)
	if(..())
		return ITEM_INTERACT_COMPLETE
	if(!ishuman(user))
		return
	var/list/variant_names = list("hijab", "dastar", "twisted")
	var/list/image/variant_icons = list()
	for(var/each_name in variant_names)
		var/icon_name = each_name == "hijab" ? "[each_name]_dyeable" : "turban_[each_name]_dyeable"
		var/image/each_image = image(icon = 'icons/obj/clothing/hats.dmi', icon_state = icon_name)
		each_image.color = color
		variant_icons[each_name] = each_image
	var/mob/living/carbon/human/H = user
	var/choice = show_radial_menu(H, src, variant_icons, null, 40, CALLBACK(src, PROC_REF(radial_check), H), TRUE)
	if(!choice || !radial_check(H))
		return

	var/picked_type = choice
	worn_icon_state = picked_type == "hijab" ? "[picked_type]_dyeable" : "turban_[picked_type]_dyeable"
	worn_as = picked_type == "hijab" ? picked_type : "turban_[picked_type]"
	if(picked_type == "hijab")
		icon_monitor = 'icons/mob/clothing/species/machine/monitor/hood.dmi'
	else
		icon_monitor = 'icons/mob/clothing/species/machine/monitor/hat.dmi'
	update_icon()

	return ITEM_INTERACT_COMPLETE

/obj/item/clothing/head/headscarf/proc/radial_check(mob/living/carbon/human/user)
	if(!src || !user.is_in_hands(src) || user.incapacitated())
		return FALSE
	return TRUE

/obj/item/clothing/head/headscarf/black
	name = "black headscarf"
	color = "#4A4A4B" //Grey but it looks black

/obj/item/clothing/head/headscarf/red
	name = "red headscarf"
	color = "#D91414" //Red

/obj/item/clothing/head/headscarf/green
	name = "green headscarf"
	color = "#5C9E54" //Green

/obj/item/clothing/head/headscarf/darkblue
	name = "dark blue headscarf"
	color = "#1E85BC" //Blue

/obj/item/clothing/head/headscarf/purple
	name = "purple headscarf"
	color = "#9557C5" //purple

/obj/item/clothing/head/headscarf/yellow
	name = "yellow headscarf"
	color = "#ffd814" //Yellow

/obj/item/clothing/head/headscarf/orange
	name = "orange headscarf"
	color = "#e97901" //orange

/obj/item/clothing/head/headscarf/cyan
	name = "cyan headscarf"
	color = "#70dbff" //Cyan (Or close to it)
