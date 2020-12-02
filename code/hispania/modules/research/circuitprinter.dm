/*///////////////Circuit Imprinter (By Darem)////////////////////////
	Used to print new circuit boards (for computers and similar systems) and AI modules. Each circuit board pattern are stored in
a /datum/desgin on the linked R&D console. You can then print them out in a fasion similar to a regular lathe. However, instead of
using metal and glass, it uses glass and reagents (usually sulfuric acis).
*/
/obj/machinery/r_n_d/circuit_imprinter/inge
	name = "Engineers Circuit Imprinter"
	desc = "Manufactures circuit boards for the construction of machines."
	icon_state = "circuit_imprinter"

	categories = list(
								"Computer Parts",
								"Engineering Machinery",
								"Hydroponics Machinery",
								"Medical Machinery",
								"Misc. Machinery",
								"Subspace Telecomms"
								)

	reagents = new()

/obj/machinery/r_n_d/circuit_imprinter/inge/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/circuit_imprinter/inge(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	component_parts += new /obj/item/reagent_containers/glass/beaker(null)
	component_parts += new /obj/item/reagent_containers/glass/beaker(null)
	RefreshParts()
	reagents.my_atom = src

/obj/machinery/r_n_d/circuit_imprinter/inge/upgraded/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/circuit_imprinter/inge(null)
	component_parts += new /obj/item/stock_parts/matter_bin/super(null)
	component_parts += new /obj/item/stock_parts/manipulator/pico(null)
	component_parts += new /obj/item/reagent_containers/glass/beaker/large(null)
	component_parts += new /obj/item/reagent_containers/glass/beaker/large(null)
	RefreshParts()
	reagents.my_atom = src
