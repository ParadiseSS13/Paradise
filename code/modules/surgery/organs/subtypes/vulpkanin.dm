/obj/item/organ/internal/liver/vulpkanin
	alcohol_intensity = 1.4
	species = "Vulpkanin"

/obj/item/organ/internal/eyes/vulpkanin /*Most Vulpkanin are surgically augmented at birth for full colour vision, although it cost them their darksight (darksight = 2) unless they choose otherwise in character creation (darksight = 8 but colourblind).
										However, this organ define is for unaugmented eyes so cloned Vulpkanin are colourblind but have excellent darksight.*/
	name = "vulpkanin eyeballs"
	species = "Vulpkanin"
	dark_view = 8
	colourmatrix = list(0.5,0.4,0.1,\
						0.5,0.4,0.1,\
						0.0,0.2,0.8) //Seeing in tones of blues and yellows, blind to greens. More richness of hue and saturation of colour than Tajara.
