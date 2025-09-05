/// An ore-devouring but easily scared creature
/mob/living/basic/mining/goldgrub
	name = "goldgrub"
	desc = "A worm that grows fat from eating everything in its sight. Seems to enjoy precious metals and other shiny things, hence the name."
	icon_state = "Goldgrub"
	icon_living = "Goldgrub"
	icon_aggro = "Goldgrub_alert"
	icon_dead = "Goldgrub_dead"
	icon_gib = "syndicate_gib"
	friendly_verb_continuous = "harmlessly rolls into"
	friendly_verb_simple = "harmlessly roll into"
	speed = 3
	maxHealth = 45
	health = 45
	harm_intent_damage = 5
	attack_verb_continuous = "barrels into"
	attack_verb_simple = "barrel into"
	a_intent = INTENT_HELP
	speak_emote = list("screeches")
	throw_blocked_message = "sinks in slowly, before being pushed out of "
	death_message = "spits up the contents of its stomach before dying!"
	status_flags = CANPUSH
	contains_xeno_organ = TRUE
	surgery_container = /datum/xenobiology_surgery_container/goldgrub
	ai_controller = /datum/ai_controller/basic_controller/goldgrub
	/// Hungry hungry goldgrubs
	var/food_types = list(/obj/item/stack/ore)
	/// Does this creature burrow?
	var/will_burrow = TRUE

/mob/living/basic/mining/goldgrub/Initialize(mapload)
	. = ..()
	faction |= "goldgrub"

	AddElement(/datum/element/basic_eating, food_types_ = food_types, add_to_contents_ = TRUE)
	ai_controller.set_blackboard_key(BB_BASIC_FOODS, typecacheof(food_types))

	var/i = rand(1,3)
	while(i)
		loot += pick(/obj/item/stack/ore/silver, /obj/item/stack/ore/gold, /obj/item/stack/ore/uranium, /obj/item/stack/ore/diamond)
		i--

/mob/living/basic/mining/goldgrub/death(gibbed)
	barf_contents(gibbed)
	return ..()

/mob/living/basic/mining/goldgrub/proc/barf_contents(gibbed)
	for(var/obj/item/stack/ore/ore in src)
		ore.forceMove(loc)

/mob/living/basic/mining/goldgrub/bullet_act(obj/item/projectile/P)
	if(P.armor_penetration_flat + P.armor_penetration_percentage >= 100)
		return ..()
	visible_message("<span class='danger'>[P.name] was repelled by [name]'s girth!</span>")
