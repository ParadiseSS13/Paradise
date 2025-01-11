// MARK: Attack
/proc/ru_attack_verb(attack_verb, list/override)
	var/list/list_to_use = override || GLOB.ru_attack_verbs
	return list_to_use[attack_verb] || attack_verb

// MARK: Eat
/proc/ru_eat_verb(eat_verb)
	return GLOB.ru_eat_verbs[eat_verb] || eat_verb

// MARK: Say
/proc/ru_say_verb(say_verb)
	return GLOB.ru_say_verbs[say_verb] || say_verb
