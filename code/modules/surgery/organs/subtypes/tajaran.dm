/obj/item/organ/internal/liver/tajaran
	alcohol_intensity = 1.4
	species = "Tajaran"

/obj/item/organ/internal/eyes/tajaran /*Most Tajara see in full colour as a result of genetic augmentation, although it cost them their darksight (darksight = 2)
										unless they choose otherwise by selecting the colourblind disability in character creation (darksight = 8 but colourblind).*/
	name = "tajaran eyeballs"
	species = "Tajaran"
	colourblind_matrix = MATRIX_TAJ_CBLIND //The colour matrix and darksight parameters that the mob will recieve when they get the disability.
	colourblind_darkview = 8

/obj/item/organ/internal/eyes/tajaran/farwa //Being the lesser form of Tajara, Farwas have an utterly incurable version of their colourblindness.
	name = "farwa eyeballs"
	species = "Farwa"
	colourmatrix = MATRIX_TAJ_CBLIND
	dark_view = 8
