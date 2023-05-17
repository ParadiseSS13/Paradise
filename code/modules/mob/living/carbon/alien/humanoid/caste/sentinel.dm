/mob/living/carbon/alien/humanoid/sentinel
	name = "alien sentinel"
	caste = "s"
	maxHealth = 250
	health = 250
	attack_damage = 25
	time_to_open_doors = 0.2 SECONDS
	icon_state = "aliens_s"

	var/obj/effect/proc_holder/spell/xeno_plant/plant_spell = new
	var/datum/action/innate/xeno_action/break_vents/break_vents_action = new
	var/datum/action/innate/xeno_action/evolve_to_praetorian/evolve_to_praetorian_action = new

/mob/living/carbon/alien/humanoid/sentinel/GrantAlienActions()
	. = ..()
	plant_spell.action.Grant(src)
	break_vents_action.Grant(src)
	evolve_to_praetorian_action.Grant(src)

/mob/living/carbon/alien/humanoid/sentinel/New()
	if(name == "alien sentinel")
		name = text("alien sentinel ([rand(1, 1000)])")
	real_name = name
	alien_organs += new /obj/item/organ/internal/xenos/plasmavessel/sentinel
	alien_organs += new /obj/item/organ/internal/xenos/acidgland/sentinel
	alien_organs += new /obj/item/organ/internal/xenos/neurotoxin
	..()

/datum/action/innate/xeno_action/evolve_to_praetorian
	name = "Evolve (500)"
	desc = "Become a Praetorian, Royal Guard to the Queen."
	button_icon_state = "aliens_s"
	icon_icon = 'icons/mob/alien.dmi'


/datum/action/innate/xeno_action/evolve_to_praetorian/Activate()
	var/mob/living/carbon/alien/humanoid/sentinel/host = owner

	if(plasmacheck(500))
		host.adjustPlasma(-500)
		to_chat(host, "<span class='noticealien'>You begin to evolve!</span>")
		for(var/mob/O in viewers(host, null))
			O.show_message(text("<span class='alertalien'>[host] begins to twist and contort!</span>"), 1)
		var/mob/living/carbon/alien/humanoid/praetorian/new_xeno = new(host.loc)
		host.mind.transfer_to(new_xeno)
		new_xeno.mind.name = new_xeno.name
		qdel(host)
	return

/mob/living/carbon/alien/humanoid/praetorian
	name = "alien praetorian"
	icon = 'icons/mob/alienlarge.dmi'
	icon_state = "prat_s"
	pixel_x = -16
	maxHealth = 300
	health = 300
	large = 1
	ventcrawler = 0
	attack_damage = 30
	armour_penetration = 30
	obj_damage = 80
	time_to_open_doors = 0.2 SECONDS
	environment_smash = ENVIRONMENT_SMASH_WALLS

	var/obj/effect/proc_holder/spell/xeno_plant/plant_spell = new

/mob/living/carbon/alien/humanoid/praetorian/New()
	if(name == "alien praetorian")
		name = text("alien praetorian ([rand(1, 1000)])")
	real_name = name
	alien_organs += new /obj/item/organ/internal/xenos/plasmavessel/sentinel
	alien_organs += new /obj/item/organ/internal/xenos/acidgland/praetorian
	alien_organs += new /obj/item/organ/internal/xenos/neurotoxin
	..()

/mob/living/carbon/alien/humanoid/praetorian/update_icons()
	overlays.Cut()
	if(stat == DEAD)
		icon_state = "prat_dead"
	else if(stat == UNCONSCIOUS || lying || resting)
		icon_state = "prat_sleep"
	else
		icon_state = "prat_s"

	for(var/image/I in overlays_standing)
		overlays += I

/mob/living/carbon/alien/humanoid/praetorian/GrantAlienActions()
	. = ..()
	plant_spell.action.Grant(src)
