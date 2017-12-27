/obj/item/organ/internal/liver/vulpkanin
	alcohol_intensity = 1.4
	species = "Vulpkanin"

/obj/item/organ/internal/eyes/vulpkanin /*Most Vulpkanin see in full colour as a result of genetic augmentation, although it cost them their darksight (darksight = 2)
										  unless they choose otherwise by selecting the colourblind disability in character creation (darksight = 8 but colourblind).*/
	name = "vulpkanin eyeballs"
	species = "Vulpkanin"
	colourblind_matrix = MATRIX_VULP_CBLIND //The colour matrix and darksight parameters that the mob will recieve when they get the disability.
	colourblind_darkview = 8

/obj/item/organ/internal/eyes/vulpkanin/wolpin //Being the lesser form of Vulpkanin, Wolpins have an utterly incurable version of their colourblindness.
	name = "wolpin eyeballs"
	species = "Wolpin"
	colourmatrix = MATRIX_VULP_CBLIND
	dark_view = 8
