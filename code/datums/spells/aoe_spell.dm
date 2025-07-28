/datum/spell/aoe
	create_attack_logs = FALSE
	create_custom_logs = TRUE
	/// How far does it effect
	var/aoe_range = 7

// Normally, AoE spells will generate an attack log for every turf they loop over, while searching for targets.
// With this override, all /aoe type spells will only generate 1 log, saying that the user has cast the spell.
/datum/spell/aoe/write_custom_logs(list/targets, mob/user)
	add_attack_logs(user, null, "Cast the AoE spell [name]", ATKLOG_ALL)
