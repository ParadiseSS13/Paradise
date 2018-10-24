/obj/item/organ/internal/liver/vulpkanin
	alcohol_intensity = 1.4

/obj/item/organ/internal/eyes/vulpkanin
	name = "vulpkanin eyeballs"
	colourblind_matrix = MATRIX_VULP_CBLIND //The colour matrix and darksight parameters that the mob will recieve when they get the disability.
	replace_colours = LIST_VULP_REPLACE
	dark_view = 8

/obj/item/organ/internal/eyes/vulpkanin/wolpin //Being the lesser form of Vulpkanin, Wolpins have an utterly incurable version of their colourblindness.
	name = "wolpin eyeballs"
	colourmatrix = MATRIX_VULP_CBLIND
	dark_view = 8
	replace_colours = LIST_VULP_REPLACE