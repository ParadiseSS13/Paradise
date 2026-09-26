/datum/technode/alien
	name = "Alien Basenode"
	desc = "If you see me, make a bug report!"
	id = "alien_base"
	node_type = "Alien Technology"
	cost_hidden = list("Alien" = 50)

/datum/technode/alien/alien_tools
	name = "Alien Tools"
	desc = "Strange but very efficient tools used by an advanced species."
	id = "alien_tools"
	prereqs = list()
	unlocks = list("alien_wrench", "alien_wirecutters", "alien_screwdriver", "alien_crowbar", "alien_welder", "alien_multitool", "ci-hacking", "alienalloy")

/datum/technode/alien/alien_medical
	name = "Alien Medical Equipment"
	desc = "Strange surgical tools from some advanced species with a similar biology to those working on Nanotrasen stations."
	id = "alien_medical"
	prereqs = list()
	unlocks = list("alien_scalpel", "alien_hemostat", "alien_retractor", "alien_saw", "alien_drill", "alien_bonegel", "alien_bonesetter", "alien_fixovein", "dissection_manager_alien", "ci-med-abductor", "alienalloy")

/datum/technode/alien/alien_jani
	name = "Alien Janitorial Equipment"
	desc = "Strange cleaning equipment from an advanced species that is seemingly messier then those working on Nanotrasen stations.. somehow."
	id = "alien_jani"
	prereqs = list()
	unlocks = list("alien_mop", "alien_light_replacer", "alien_flyswatter", "ci-jani-abductor", "alienalloy")
