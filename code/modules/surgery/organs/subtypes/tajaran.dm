/obj/item/organ/internal/liver/tajaran
	name = "tajaran liver"
	icon = 'icons/obj/species_organs/tajaran.dmi'
	alcohol_intensity = 1.4

/obj/item/organ/internal/eyes/tajaran
	icon = 'icons/obj/species_organs/tajaran.dmi'
	name = "tajaran eyeballs"
	colourblind_matrix = MATRIX_TAJ_CBLIND //The colour matrix and darksight parameters that the mob will recieve when they get the disability.
	replace_colours = LIST_TAJ_REPLACE
	see_in_dark = 8

/obj/item/organ/internal/eyes/tajaran/farwa //Being the lesser form of Tajara, Farwas have an utterly incurable version of their colourblindness.
	name = "farwa eyeballs"
	colourmatrix = MATRIX_TAJ_CBLIND
	see_in_dark = 8
	replace_colours = LIST_TAJ_REPLACE

/obj/item/organ/internal/heart/tajaran
	name = "tajaran heart"
	icon = 'icons/obj/species_organs/tajaran.dmi'

/obj/item/organ/internal/brain/tajaran
	icon = 'icons/obj/species_organs/tajaran.dmi'
	icon_state = "brain2"
	mmi_icon = 'icons/obj/species_organs/tajaran.dmi'
	mmi_icon_state = "mmi_full"

/obj/item/organ/internal/lungs/tajaran
	name = "tajaran lungs"
	icon = 'icons/obj/species_organs/tajaran.dmi'

/obj/item/organ/internal/kidneys/tajaran
	name = "tajaran kidneys"
	icon = 'icons/obj/species_organs/tajaran.dmi'