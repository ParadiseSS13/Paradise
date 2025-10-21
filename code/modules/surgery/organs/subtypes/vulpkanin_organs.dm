/obj/item/organ/internal/liver/vulpkanin
	name = "vulpkanin liver"
	icon = 'icons/obj/species_organs/vulpkanin.dmi'
	alcohol_intensity = 1.4

/obj/item/organ/internal/eyes/vulpkanin
	name = "vulpkanin eyeballs"
	icon = 'icons/obj/species_organs/vulpkanin.dmi'
	colorblind_matrix = MATRIX_VULP_CBLIND //The colour matrix and darksight parameters that the mob will receive when they get the disability.
	replace_colours = PROTANOPIA_COLOR_REPLACE
	see_in_dark = 3

/// Being the lesser form of Vulpkanin, Wolpins have an utterly incurable version of their colourblindness.
/obj/item/organ/internal/eyes/vulpkanin/wolpin
	name = "wolpin eyeballs"
	colormatrix = MATRIX_VULP_CBLIND
	replace_colours = PROTANOPIA_COLOR_REPLACE

/obj/item/organ/internal/heart/vulpkanin
	name = "vulpkanin heart"
	icon = 'icons/obj/species_organs/vulpkanin.dmi'

/obj/item/organ/internal/brain/vulpkanin
	icon = 'icons/obj/species_organs/vulpkanin.dmi'
	mmi_icon = 'icons/obj/species_organs/vulpkanin.dmi'

/obj/item/organ/internal/lungs/vulpkanin
	name = "vulpkanin lungs"
	icon = 'icons/obj/species_organs/vulpkanin.dmi'

/obj/item/organ/internal/kidneys/vulpkanin
	name = "vulpkanin kidneys"
	icon = 'icons/obj/species_organs/vulpkanin.dmi'
