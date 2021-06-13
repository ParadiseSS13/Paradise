/mob/living/simple_animal/hostile/asteroid/poison/plazmite
	name = "plazmite"
	desc = "A small bug-like creature with a toxin sting, they emit a bright light."
	icon = 'icons/hispania/mob/animals.dmi'
	icon_state = "Plazmite"
	icon_living = "Plazmite"
	icon_aggro = "Plazmite"
	icon_dead = "Plazmite_dead"
	icon_gib = "syndicate_gib"
	vision_range = 4
	speed = 4
	move_to_delay = 4
	maxHealth = 140
	health = 140
	harm_intent_damage = 12
	melee_damage_lower = 12
	melee_damage_upper = 12
	obj_damage = 60
	attacktext = "stings"
	attack_sound = 'sound/weapons/bulletflyby2.ogg'
	a_intent = INTENT_HARM
	speak_emote = list("screeches")
	throw_message = "does nothing against the hard shell of"
	status_flags = PASSTABLE
	response_help  = "pets"
	response_harm   = "hits"
	stat_attack = 1
	flying = TRUE
	robust_searching = 1
	light_range = 2
	light_power = 2.5
	light_color = LIGHT_COLOR_YELLOW
	loot = list()
	aggro_vision_range = 9
	butcher_results = list(/obj/item/stack/sheet/bone = 1, /obj/item/reagent_containers/food/snacks/monstermeat/plazmiteleg = 2, /obj/item/stack/sheet/cartiplaz = 2)
	var/venom_per_bite = 4

/mob/living/simple_animal/hostile/asteroid/poison/plazmite/AttackingTarget()
	// This is placed here, NOT on /poison, because the other subtypes of /poison/ already override AttackingTarget() completely, and as such it would do nothing but confuse people there.
	. = ..()
	if(. && venom_per_bite > 0 && iscarbon(target) && (!client || a_intent == INTENT_HARM))
		var/mob/living/carbon/C = target
		var/inject_target = pick("chest", "head")
		if(C.can_inject(null, 0, inject_target, 0))
			C.reagents.add_reagent("plazmitevenom", venom_per_bite)

/mob/living/simple_animal/hostile/asteroid/poison/plazmite/tendril
	fromtendril = TRUE
