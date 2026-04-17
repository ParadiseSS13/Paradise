/datum/asset/icon_cache/clothing
	var/list/sprite_sheets = list()

/datum/asset/icon_cache/clothing/New()
	. = ..()
	for(var/each_subtype in subtypesof(/obj/item/clothing/under/color))
		var/obj/item/clothing/under/color/jumpsuit_type = each_subtype
		// If it doesn't have a palette key, the icon already exists and we don't need to generate it again.
		// UNLESS it's the psychedelic jumpsuits.
		var/is_psychedelic = jumpsuit_type::icon_state == "psyche" || jumpsuit_type::icon_state == "psycheskirt"
		if(!jumpsuit_type::icon_palette_key && !is_psychedelic)
			continue

		var/palette_keys = is_psychedelic ? list(DYE_DARKBLUE, DYE_RED, DYE_BLACK, DYE_YELLOW, DYE_AQUA, DYE_PURPLE, DYE_LIGHTGREEN, DYE_PINK) : list(jumpsuit_type::icon_palette_key)
		var/registry_key = ispath(jumpsuit_type, /obj/item/clothing/under/color/jumpskirt) ? DYE_REGISTRY_JUMPSKIRT : DYE_REGISTRY_UNDER
		var/list/all_sheets = list(
			"Vox" = 'icons/mob/clothing/species/vox/under/color.dmi',
			"Skkulakin" = 'icons/mob/clothing/species/skkulakin/under/color.dmi',
			"Drask" = 'icons/mob/clothing/species/drask/under/color.dmi',
			"Grey" = 'icons/mob/clothing/species/grey/under/color.dmi',
			"Kidan" = 'icons/mob/clothing/species/kidan/under/color.dmi',
			"Human" = jumpsuit_type::worn_icon,
			"Obj" = jumpsuit_type::icon,
			"Lefthand" = jumpsuit_type::lefthand_file,
			"Righthand" = jumpsuit_type::righthand_file)
		var/list/state_names = list(jumpsuit_type::icon_state,
			"[jumpsuit_type::worn_icon_state || jumpsuit_type::icon_state]_s",
			"[jumpsuit_type::worn_icon_state || jumpsuit_type::icon_state]_d_s",
			jumpsuit_type::inhand_icon_state,)
		// For every sprite sheet...
		for(var/sheet_key in all_sheets)
			var/filepath = all_sheets[sheet_key]
			var/icon/jumpsuit = new(filepath)
			var/icon/new_suit = new()

			// If each icon state exists in the file...
			for(var/white_state in state_names)
				if(!white_state)
					continue
				if(!(white_state in jumpsuit.IconStates()))
					continue

				// For every frame of color we need to dye it...
				for(var/frame_num in 1 to length(palette_keys))
					// Dye it the color we want.
					var/icon/colored_icon = new(filepath, white_state)
					colored_icon.swap_palette(
						GLOB.palette_registry[registry_key][jumpsuit_type::default_palette_key],
						GLOB.palette_registry[registry_key][palette_keys[frame_num]]
					)
					new_suit.Insert(colored_icon, white_state, frame = frame_num, delay = 1)

			// Set the new sprite we just made to the one this jumpsuit uses.
			all_sheets[sheet_key] = new_suit
		var/suit_key = is_psychedelic ? jumpsuit_type::icon_state : jumpsuit_type::icon_palette_key
		if(!sprite_sheets[registry_key])
			sprite_sheets[registry_key] = list()
		sprite_sheets[registry_key][suit_key] = all_sheets
