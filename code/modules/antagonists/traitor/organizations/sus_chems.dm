/obj/item/reagent_containers/glass/bottle/experiment
	desc = "It has a small ID number and some indecipherable instructions."

/obj/item/reagent_containers/glass/bottle/experiment/Initialize(mapload)
	. = ..()
	reagents.add_reagent(pick(poisons), 20)
	reagents.add_reagent(pick(medicines), 20)

/var/list/poisons = list("sarin", "cyanide", "sulfonal", "initropidril", "coniine", "venom", "ketamine", "amanitin",
	"polonium", "curare", "pancuronium", "sodium_thiopental", "gibbis", "nanomachines", "prions", "spidereggs",
	"concentrated_initro", "heartworms", "bacon_grease", "lexorin", "frigidi")

/var/list/medicines = list("mitocholide", "hydrocodone", "synaptizine", "cryoxadone", "rezadone", "salglu_solution", "omnizine",
	"perfluorodecalin", "stimulants", "teporone", "heparin", "haloperidol")
