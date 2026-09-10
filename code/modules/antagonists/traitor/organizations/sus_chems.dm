/obj/item/reagent_containers/glass/bottle/experiment
	desc = "It has a small ID number and some indecipherable instructions."

/obj/item/reagent_containers/glass/bottle/experiment/Initialize(mapload)
	. = ..()
	reagents.add_reagent(pick_list("chemistry_tools.json", "traitor_poison_bottle"), 20)
	reagents.add_reagent(pick(medicines), 20)

/var/list/medicines = list("mitocholide", "hydrocodone", "synaptizine", "cryoxadone", "rezadone", "salglu_solution", "omnizine",
	"perfluorodecalin", "stimulants", "teporone", "heparin", "haloperidol")
