/turf/simulated/wall/update_overlays()
	. = ..()
	if(rusted_overlay)
		rusted_overlay = icon('modular_ss220/aesthetics/rust/icons/rust.dmi', pick("rust", "rust2", "rust3", "rust4", "rust5", "rust6"))
		.[1] = rusted_overlay
