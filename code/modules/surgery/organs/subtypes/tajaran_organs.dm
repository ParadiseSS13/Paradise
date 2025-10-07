/obj/item/organ/internal/liver/tajaran
	name = "tajaran liver"
	icon = 'icons/obj/species_organs/tajaran.dmi'
	alcohol_intensity = 1.4

/obj/item/organ/internal/eyes/tajaran
	icon = 'icons/obj/species_organs/tajaran.dmi'
	name = "tajaran eyeballs"
	colorblind_matrix = MATRIX_TAJ_CBLIND //The colour matrix and darksight parameters that the mob will receive when they get the disability.
	replace_colours = TRITANOPIA_COLOR_REPLACE
	see_in_dark = 3

/// Being the lesser form of Tajara, Farwas have an utterly incurable version of their colourblindness.
/obj/item/organ/internal/eyes/tajaran/farwa
	name = "farwa eyeballs"
	colormatrix = MATRIX_TAJ_CBLIND
	replace_colours = TRITANOPIA_COLOR_REPLACE

/obj/item/organ/internal/heart/tajaran
	name = "tajaran heart"
	icon = 'icons/obj/species_organs/tajaran.dmi'

/obj/item/organ/internal/brain/tajaran
	icon = 'icons/obj/species_organs/tajaran.dmi'
	mmi_icon = 'icons/obj/species_organs/tajaran.dmi'

/obj/item/organ/internal/kidneys/tajaran
	name = "tajaran kidneys"
	icon = 'icons/obj/species_organs/tajaran.dmi'
