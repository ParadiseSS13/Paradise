/obj/item/organ/internal/liver/vulpkanin
	name = "vulpkanin liver"
	icon = 'icons/obj/species_organs/vulpkanin.dmi'
	alcohol_intensity = 1.4

/obj/item/organ/internal/eyes/vulpkanin
	name = "vulpkanin eyeballs"
	icon = 'icons/obj/species_organs/vulpkanin.dmi'
	colourblind_matrix = MATRIX_VULP_CBLIND //The colour matrix and darksight parameters that the mob will recieve when they get the disability.
	replace_colours = LIST_VULP_REPLACE
	see_in_dark = 8

/obj/item/organ/internal/eyes/vulpkanin/wolpin //Being the lesser form of Vulpkanin, Wolpins have an utterly incurable version of their colourblindness.
	name = "wolpin eyeballs"
	colourmatrix = MATRIX_VULP_CBLIND
	see_in_dark = 8
	replace_colours = LIST_VULP_REPLACE

/obj/item/organ/internal/heart/vulpkanin
	name = "vulpkanin heart"
	icon = 'icons/obj/species_organs/vulpkanin.dmi'

/obj/item/organ/internal/brain/vulpkanin
	icon = 'icons/obj/species_organs/vulpkanin.dmi'
	icon_state = "brain2"
	mmi_icon = 'icons/obj/species_organs/vulpkanin.dmi'
	mmi_icon_state = "mmi_full"

/obj/item/organ/internal/lungs/vulpkanin
	name = "vulpkanin lungs"
	icon = 'icons/obj/species_organs/vulpkanin.dmi'

/obj/item/organ/internal/kidneys/vulpkanin
	name = "vulpkanin kidneys"
	icon = 'icons/obj/species_organs/vulpkanin.dmi'
