/obj/item/organ/internal/liver/vulpkanin
	alcohol_intensity = 1.4
	species = SPECIES_VULPKANIN

/obj/item/organ/internal/eyes/vulpkanin
	name = "vulpkanin eyeballs"
	species = SPECIES_VULPKANIN
	colourblind_matrix = MATRIX_VULP_CBLIND //The colour matrix and darksight parameters that the mob will recieve when they get the disability.
	replace_colours = LIST_VULP_REPLACE
	dark_view = 8

/obj/item/organ/internal/eyes/vulpkanin/wolpin //Being the lesser form of Vulpkanin, Wolpins have an utterly incurable version of their colourblindness.
	name = "wolpin eyeballs"
	species = SPECIES_WOLPIN
	colourmatrix = MATRIX_VULP_CBLIND
	dark_view = 8
	replace_colours = LIST_VULP_REPLACE
