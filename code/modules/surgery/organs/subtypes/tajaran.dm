/obj/item/organ/internal/liver/tajaran
	alcohol_intensity = 1.4
	species = "Tajaran"

/obj/item/organ/internal/eyes/tajaran /*Most Tajara are surgically augmented at birth for full colour vision, although it cost them their darksight (darksight = 2) unless they choose otherwise in character creation (darksight = 8 but colourblind).
										However, this organ define is for unaugmented eyes so cloned Tajara are colourblind but have excellent darksight.*/
	name = "tajaran eyeballs"
	species = "Tajaran"
	dark_view = 8
	colourmatrix = list(0.4,0.2,0.4,\
						0.4,0.6,0.0,\
						0.2,0.2,0.6) //Slightly less richness of hues or saturation of colours than Vulpkanin eyes.	Pastel colour scheme, blues slightly green-shifted, reds slightly blue-shifted, greens yellow-shifted.
