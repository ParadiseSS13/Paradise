/datum/antagonist/survivalist
	name = "Survivalist"
	var/greet_message = ""

/datum/antagonist/survivalist/proc/forge_objectives()
	var/datum/objective/survive/survive = new
	survive.owner = owner
	objectives += survive
	owner.objectives |= objectives

/datum/antagonist/survivalist/on_gain()
	owner.special_role = "survivalist"
	forge_objectives()
	. = ..()

/datum/antagonist/survivalist/greet()
	to_chat(owner.current, "<B>Eres un sobreviviente! [greet_message]</B>")
	owner.announce_objectives()

/datum/antagonist/survivalist/guns
	greet_message = "Tu propia seguridad importa sobre todo, y la unica manera es recopilando armas! Toma todas las armas que puedas, bajo cualquier circunstancia necesaria. Asesina a cualquiera que se interponga en tu camino."

/datum/antagonist/survivalist/guns/forge_objectives()
	var/datum/objective/steal_five_of_type/summon_guns/guns = new
	guns.owner = owner
	objectives += guns
	..()

/datum/antagonist/survivalist/magic
	name = "Amateur Magician"
	greet_message = "Grow your newfound talent! Grab as many magical artefacts as possible, by any means necessary. Kill anyone who gets in your way."

/datum/antagonist/survivalist/magic/greet()
	..()
	to_chat(owner.current, "<span class='notice'>As a wonderful magician, you should remember that spellbooks don't mean anything if they are used up.</span>")

/datum/antagonist/survivalist/magic/forge_objectives()
	var/datum/objective/steal_five_of_type/summon_magic/magic = new
	magic.owner = owner
	objectives += magic
	..()
