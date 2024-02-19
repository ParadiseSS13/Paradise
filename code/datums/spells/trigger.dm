/datum/spell/trigger
	desc = "This spell triggers another spell or a few."

	var/list/linked_spells = list() //those are just referenced by the trigger spell and are unaffected by it directly
	var/list/starting_spells = list() //those are added on New() to contents from default spells and are deleted when the trigger spell is deleted to prevent memory leaks

/datum/spell/trigger/New()
	..()
	for(var/spell in starting_spells)
		var/spell_to_add = text2path(spell)
		var/datum/spell/created_spell = new spell_to_add
		linked_spells += created_spell

/datum/spell/trigger/Destroy()
	for(var/spell in linked_spells)
		qdel(spell)
	linked_spells = null
	starting_spells = null
	return ..()

/datum/spell/trigger/cast(list/targets, mob/user = usr)
	for(var/mob/living/target in targets)
		for(var/datum/spell/spell in linked_spells)
			spell.perform(list(target), 0, user = user)
