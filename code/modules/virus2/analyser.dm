/obj/machinery/disease2/diseaseanalyser
	name = "Disease Analyser"
	icon = 'icons/obj/virology.dmi'
	icon_state = "analyser"
	anchored = 1
	density = 1

	var/scanning = 0
	var/pause = 0

	var/obj/item/weapon/virusdish/dish = null

/obj/machinery/disease2/diseaseanalyser/attackby(var/obj/O as obj, var/mob/user as mob)
	if(!istype(O,/obj/item/weapon/virusdish)) return

	if(dish)
		user << "\The [src] is already loaded."
		return

	dish = O
	user.drop_item()
	O.loc = src

	user.visible_message("[user] adds \a [O] to \the [src]!", "You add \a [O] to \the [src]!")

/obj/machinery/disease2/diseaseanalyser/process()
	if(stat & (NOPOWER|BROKEN))
		return

	if(scanning)
		scanning -= 1
		if(scanning == 0)
			if (dish.virus2.addToDB())
				ping("\The [src] pings, \"New pathogen added to data bank.\"")

			var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(src.loc)
			P.name = "paper - [dish.virus2.name()]"

			var/r = dish.virus2.get_info()
			P.info = {"
				[virology_letterhead("Post-Analysis Memo")]
				[r]
				<hr>
				<u>Additional Notes:</u>&nbsp;
"}
			dish.info = r
			dish.analysed = 1
			dish.loc = src.loc
			dish = null

			icon_state = "analyser"
			src.state("\The [src] prints a sheet of paper.")

	else if(dish && !scanning && !pause)
		if(dish.virus2 && dish.growth > 50)
			dish.growth -= 10
			scanning = 5
			icon_state = "analyser_processing"
		else
			pause = 1
			spawn(25)
				dish.loc = src.loc
				dish = null

				src.state("\The [src] buzzes, \"Insufficient growth density to complete analysis.\"")
				pause = 0
	return
