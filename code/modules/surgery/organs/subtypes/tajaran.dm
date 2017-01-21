/obj/item/organ/internal/liver/tajaran
	alcohol_intensity = 1.4
	species = "Tajaran"

/obj/item/organ/internal/eyes/tajaran /*Most Tajara see in full colour as a result of genetic augmentation, although it cost them their darksight (darksight = 2)
										unless they choose otherwise by selecting the colourblind disability in character creation (darksight = 8 but colourblind).*/
	name = "tajaran eyeballs"
	species = "Tajaran"
	colourblind_special = list("colour_matrix" = MATRIX_TAJ_CBLIND, "darkview" = 8) //The colour matrix and darksight parameters that the mob will recieve when they get the disability.
