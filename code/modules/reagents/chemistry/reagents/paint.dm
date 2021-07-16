/datum/reagent/paint
	name = "Paint"
	description = "Floor paint is used to color floor tiles."
	reagent_state = LIQUID
	color = "#808080"
	taste_description = "paint"

/datum/reagent/paint/reaction_turf(turf/T, volume)
	if(!isspaceturf(T))
		T.color = color

/datum/reagent/paint/reaction_obj(obj/O, volume)
	if(istype(O, /obj/item/light))
		O.color = color

/datum/reagent/paint/red
	name = "Red Paint"
	color = "#FF0000"

/datum/reagent/paint/green
	name = "Green Paint"
	color = "#00FF00"

/datum/reagent/paint/blue
	name = "Blue Paint"
	color = "#0000FF"

/datum/reagent/paint/yellow
	name = "Yellow Paint"
	color = "#FFFF00"

/datum/reagent/paint/violet
	name = "Violet Paint"
	color = "#FF00FF"

/datum/reagent/paint/black
	name = "Black Paint"
	color = "#333333"

/datum/reagent/paint/white
	name = "White Paint"
	color = "#FFFFFF"

/datum/reagent/paint_remover
	name = "Paint Remover"
	description = "Paint remover is used to remove floor paint from floor tiles."
	reagent_state = LIQUID
	color = "#808080"
	taste_description = "alcohol"

/datum/reagent/paint_remover/reaction_turf(turf/T, volume)
	if(!isspaceturf(T))
		T.color = initial(T.color)
