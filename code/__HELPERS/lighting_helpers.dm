/// Produces a mutable appearance glued to the [EMISSIVE_PLANE] dyed to be the [EMISSIVE_COLOR]. Order of application matters: Default generated blockers are overlays, and will block its own emissive underlays. If you want an object to be both a blocker, and have their own emissive, it has to be an overlay instead. Grayscale lightmasks are visible in the BYOND right-click and Examine pane, unless they're covered up by another overlay.
/proc/emissive_appearance(icon, icon_state = "", layer = FLOAT_LAYER, alpha = 255, appearance_flags = NONE)
	var/mutable_appearance/appearance = mutable_appearance(icon, icon_state, layer, EMISSIVE_PLANE, alpha, appearance_flags | EMISSIVE_APPEARANCE_FLAGS)
	appearance.color = EMISSIVE_COLOR
	appearance.alpha = alpha
	return appearance

/// Produces a mutable appearance glued to the [EMISSIVE_PLANE] dyed to be the [EM_BLOCK_COLOR].
/proc/emissive_blocker(icon, icon_state = "", layer = FLOAT_LAYER, alpha = 255, appearance_flags = NONE)
	var/mutable_appearance/appearance = mutable_appearance(icon, icon_state, layer, EMISSIVE_PLANE, alpha, appearance_flags | EMISSIVE_APPEARANCE_FLAGS)
	appearance.color = EM_BLOCK_COLOR
	return appearance
