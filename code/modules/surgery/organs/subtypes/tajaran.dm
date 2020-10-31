/obj/item/organ/internal/liver/tajaran
	species_type = /datum/species/tajaran
	name = "tajaran liver"
	icon = 'icons/obj/species_organs/tajaran.dmi'
	alcohol_intensity = 1.4

/obj/item/organ/internal/eyes/tajaran
	species_type = /datum/species/tajaran
	icon = 'icons/obj/species_organs/tajaran.dmi'
	name = "tajaran eyeballs"
	colourblind_matrix = MATRIX_TAJ_CBLIND //The colour matrix and darksight parameters that the mob will recieve when they get the disability.
	replace_colours = TRITANOPIA_COLOR_REPLACE
	see_in_dark = 8

/obj/item/organ/internal/eyes/tajaran/farwa //Being the lesser form of Tajara, Farwas have an utterly incurable version of their colourblindness.
	species_type = /datum/species/monkey/tajaran
	name = "farwa eyeballs"
	colourmatrix = MATRIX_TAJ_CBLIND
	see_in_dark = 8
	replace_colours = TRITANOPIA_COLOR_REPLACE

/obj/item/organ/internal/heart/tajaran
	species_type = /datum/species/tajaran
	name = "tajaran heart"
	icon = 'icons/obj/species_organs/tajaran.dmi'

/obj/item/organ/internal/brain/tajaran
	species_type = /datum/species/tajaran
	icon = 'icons/obj/species_organs/tajaran.dmi'
	icon_state = "brain2"
	mmi_icon = 'icons/obj/species_organs/tajaran.dmi'
	mmi_icon_state = "mmi_full"

/obj/item/organ/internal/lungs/tajaran
	species_type = /datum/species/tajaran
	name = "tajaran lungs"
	icon = 'icons/obj/species_organs/tajaran.dmi'

/obj/item/organ/internal/kidneys/tajaran
	species_type = /datum/species/tajaran
	name = "tajaran kidneys"
	icon = 'icons/obj/species_organs/tajaran.dmi'
