/datum/technode/illegal
	name = "Illegal Basenode"
	desc = "If you see me, make a bug report!"
	id = "illegal_base"
	node_type = "Illegal Technology"
	cost_hidden = list("Illegal" = 50)

/datum/technode/illegal/module_illegal
	name = "Syndicate Modules"
	desc = "MODsuit modules of dubious origin."
	id = "module_illegal"
	prereqs = list()
	unlocks = list("mod_storage_syndicate", "mod_stealth", "mod_compression")

/datum/technode/illegal/mech_equip_illegal
	name = "Exosuit Syndicate Equipment"
	desc = "Advanced and dangerous weaponry for use on combat exosuits."
	id = "mech_equip_illegal"
	prereqs = list()
	unlocks = list("mech_scattershot", "clusterbang_launcher")

/datum/technode/illegal/implants_illegal
	name = "Black Market Implants"
	desc = "Powerful implants typically restricted to special operations or syndicate personnel."
	id = "implants_illegal"
	prereqs = list()
	unlocks = list("mantis_blade_nt", "muscle_implant", "ci-razorwire-spool", "ci-shell_launcher", "ci-sensory-enhancer")

/datum/technode/illegal/weap_illegal
	name = "Infiltration Weaponry"
	desc = "Quiet and lethal weaponry, useful for infiltration or escaping."
	id = "weap_illegal"
	prereqs = list()
	unlocks = list("largecrossbow", "silencer")
