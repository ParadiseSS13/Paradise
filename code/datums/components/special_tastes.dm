/// Allows humanoids to eat arbitrary items
/datum/component/special_tastes
	/// associated list of item to reagents and tastes
	/// Typepath = (list(reagents = list(reagents), tastes = list(tastes)); Ex: list(/obj/item/stack/sheet/mineral/silver = list("reagents" = list("nutriment" = 5, "vitamin" = 1), "tastes" = list("metal and blood" = 1)))
	var/list/obj/item/edible_items = list() 

/datum/component/special_tastes/Initialize(list/edible_items)
	if(!length(edible_items))
		return COMPONENT_INCOMPATIBLE
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	for(var/obj/item/current_item as anything in edible_items)
		if(!islist(edible_items[current_item])) // if not a list of reagents
			return COMPONENT_INCOMPATIBLE
	src.edible_items = edible_items
	RegisterSignal(parent, COMSIG_ATTACK_BY, PROC_REF(attempt_ingest))

/// check if item is in the list of potential food
/datum/component/special_tastes/proc/attempt_ingest(datum/source, obj/item/attacking_item, mob/living/carbon/human/attacker)
	SIGNAL_HANDLER  // COMSIG_ATTACK_BY
	if(parent != attacker) // only if they attack themselves with it
		return
	var/is_edible = FALSE
	var/obj/item/similar_to
	for(var/potential_type in edible_items)
		if(istype(attacking_item, potential_type))
			is_edible = TRUE
			similar_to = potential_type
			break
	if(!is_edible)
		return
	attempt_to_eat(attacker, attacking_item, similar_to)
	return COMPONENT_SKIP_AFTERATTACK

/// Handle eating and nutrition gain from eating minerals
/datum/component/special_tastes/proc/attempt_to_eat(mob/living/carbon/human/user, obj/item/attacking_item, obj/item/similar_to)
	if(istype(attacking_item, /obj/item/stack))
		var/obj/item/stack/stacked_item = attacking_item
		if(stacked_item.amount > 1)
			to_chat(user, "<span class='notice'>You can only eat one of [stacked_item] at a time.</span>")
			return
	var/obj/item/food/food = turn_into_food(attacking_item, similar_to)
	user.drop_item_to_ground(attacking_item, TRUE, TRUE)
	user.put_in_active_hand(food)
	var/fullness = user.nutrition + 10
	for(var/datum/reagent/consumable/chem in food.reagents.reagent_list)
		fullness += chem.nutriment_factor * chem.volume / (chem.metabolization_rate * user.metabolism_efficiency)
	if(!(fullness > (600 * (1 + user.overeatduration / 2000)))) // need to work around the sleep()'s in eat()
		user.consume(food)
		food.On_Consume(user, user)
		qdel(attacking_item)
		return // couldnt eat it, undo
	to_chat(user, "<span class='notice'>You are too full to eat [attacking_item].</span>")
	user.drop_item_to_ground(food, TRUE, TRUE)
	user.put_in_active_hand(attacking_item)
	qdel(food)

/// Turn the item into food, can only be eaten in 1 bite to prevent creating a half-eaten item that those without the trait can also eat.
/datum/component/special_tastes/proc/turn_into_food(obj/item/future_food, obj/item/similar_to)
	var/obj/item/food/food = new
	food.name = future_food.name
	food.desc = future_food.desc
	food.icon = future_food.icon
	food.icon_state = future_food.icon_state
	var/list/food_info = edible_items[similar_to]
	var/list/chem_info = food_info["reagents"]
	var/list/taste_info = food_info["tastes"]
	for(var/reagent_id in chem_info)
		var/reagent_amount = chem_info[reagent_id]
		food.reagents.add_reagent(reagent_id, reagent_amount, taste_info.Copy())
	food.bitesize = food.reagents.total_volume
	return food

/datum/component/special_tastes/Destroy(force, silent)
	UnregisterSignal(parent, COMSIG_ATTACK_BY)
	return ..()
