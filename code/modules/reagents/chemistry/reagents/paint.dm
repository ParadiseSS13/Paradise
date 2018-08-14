/datum/reagent/paint
	name = "Paint"
	id = "paint_"
	description = "Floor paint is used to color floor tiles."
	reagent_state = LIQUID
	color = "#808080"
	taste_message = "paint"

/datum/reagent/paint/reaction_turf(turf/T, volume)
	if(!isspaceturf(T))
		T.color = color

/datum/reagent/paint/reaction_obj(obj/O, volume)
	if(istype(O, /obj/item/light))
		O.color = color

/datum/reagent/paint/red
	name = "Red Paint"
	id = "paint_red"
	color = "#FF0000"

/datum/reagent/paint/green
	name = "Green Paint"
	id = "paint_green"
	color = "#00FF00"

/datum/reagent/paint/blue
	name = "Blue Paint"
	id = "paint_blue"
	color = "#0000FF"

/datum/reagent/paint/yellow
	name = "Yellow Paint"
	id = "paint_yellow"
	color = "#FFFF00"

/datum/reagent/paint/violet
	name = "Violet Paint"
	id = "paint_violet"
	color = "#FF00FF"

/datum/reagent/paint/black
	name = "Black Paint"
	id = "paint_black"
	color = "#333333"

/datum/reagent/paint/white
	name = "White Paint"
	id = "paint_white"
	color = "#FFFFFF"

/datum/reagent/paint_remover
	name = "Paint Remover"
	id = "paint_remover"
	description = "Paint remover is used to remove floor paint from floor tiles."
	reagent_state = LIQUID
	color = "#808080"
	taste_message = "alcohol"

/datum/reagent/paint_remover/reaction_turf(turf/T, volume)
	if(!isspaceturf(T))
		T.color = initial(T.color)
