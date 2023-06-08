

/datum/action/item_action/advanced/ninja/toggle_shuriken_fire_mode
	name = "Energy shuriken emitter"
	desc = "Enable special suit system that generates Shurikens made of pure energy and capable of slowing and damaging enemies far away from you! Energy cost: 300 per burst"
	charge_type = ADV_ACTION_TYPE_TOGGLE
	use_itemicon = FALSE
	icon_icon = 'icons/mob/actions/actions_ninja.dmi'
	button_icon_state = "shuriken"
	button_icon = 'icons/mob/actions/actions_ninja.dmi'
	background_icon_state = "background_green"
	action_initialisation_text = "Pure Energy Shuriken Emitter"

/obj/item/clothing/suit/space/space_ninja/proc/toggle_shuriken_fire_mode()
	var/mob/living/carbon/human/ninja = affecting
	if(shuriken_emitter)
		qdel(shuriken_emitter)
		shuriken_emitter = null
	else
		shuriken_emitter = new
		shuriken_emitter.my_suit = src
		for(var/datum/action/item_action/advanced/ninja/toggle_shuriken_fire_mode/ninja_action in actions)
			shuriken_emitter.my_action = ninja_action
			ninja_action.action_ready = TRUE
			ninja_action.use_action()
			break
		ninja.put_in_hands(shuriken_emitter)

/obj/item/gun/energy/shuriken_emitter
	name = "shuriken emitter"
	desc = "A device sneakily hidden inside Spider Clans ninja suits. Shoots 3 energy shurikens that slows and temporary blinds their targets"
	icon = 'icons/obj/ninjaobjects.dmi'
	icon_state = "shuriken_emitter"
	item_state = ""
	ninja_weapon = TRUE
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_MEDIUM
	slot_flags = 0
	flags = DROPDEL | ABSTRACT | NOBLUDGEON | NOPICKUP
	ammo_type = list(/obj/item/ammo_casing/energy/shuriken)
	can_charge = 0
	burst_size = 3
	var/cost = 100
	var/obj/item/clothing/suit/space/space_ninja/my_suit = null
	var/datum/action/item_action/advanced/ninja/toggle_shuriken_fire_mode/my_action = null


/obj/item/gun/energy/shuriken_emitter/Destroy()
	. = ..()
	my_suit.shuriken_emitter = null
	my_suit = null
	my_action.action_ready = FALSE
	my_action.use_action()
	my_action = null

/obj/item/gun/energy/shuriken_emitter/equip_to_best_slot(mob/M)
	qdel(src)

/obj/item/gun/energy/shuriken_emitter/can_shoot()
	return !my_suit.ninjacost(cost*burst_size)

/obj/item/ammo_casing/energy/shuriken
	projectile_type = /obj/item/projectile/beam/shuriken
	muzzle_flash_color = LIGHT_COLOR_GREEN
	select_name  = "shuriken"
	e_cost = 0
	fire_sound = 'sound/weapons/bulletflyby.ogg'
	click_cooldown_override = 2
	harmful = FALSE
	delay = 3

/obj/item/projectile/beam/shuriken
	name = "energy shuriken"
	icon = 'icons/obj/ninjaobjects.dmi'
	icon_state = "shuriken_projectile"
	damage = 5
	stamina = 15
	shockbull = TRUE
	damage_type = BURN
	flag = "energy"
	hitsound = 'sound/weapons/parry.ogg'
	eyeblur = 2
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_particles
	light_color = LIGHT_COLOR_GREEN

/obj/effect/temp_visual/impact_effect/green_particles
	icon_state = "mech_toxin"
	duration = 2
