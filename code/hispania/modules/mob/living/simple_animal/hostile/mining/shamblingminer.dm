//A FAST, melee, crazy miner.
/mob/living/simple_animal/hostile/asteroid/miner
	name = "shambling miner"
	desc = "Consumed by the ash storm, this shell of a human being only seeks to harm those he once called coworkers."
	icon = 'icons/hispania/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "miner"
	icon_living = "miner"
	icon_aggro = "miner"
	icon_dead = "miner_dead"
	icon_gib = "syndicate_gib"
	ranged = FALSE
	speak_emote = list("moans")
	speed = 1
	move_to_delay = 3
	maxHealth = 200
	health = 200
	obj_damage = 100
	melee_damage_lower = 20
	melee_damage_upper = 20
	attacktext = "smashes"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	throw_message = "barely affects the"
	vision_range = 3
	aggro_vision_range = 7
	loot = list()
	crusher_loot = /obj/item/crusher_trophy/blaster_tubes/mask
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/human = 2, /obj/item/stack/sheet/animalhide/human = 1, /obj/item/stack/sheet/bone = 1)
	robust_searching = FALSE
	minimum_distance = 1

/mob/living/simple_animal/hostile/asteroid/miner/death(gibbed)
	if(prob(15))
		new /obj/item/twohanded/kinetic_crusher(src.loc)
	. = ..()

/mob/living/simple_animal/hostile/asteroid/miner/tendril
	fromtendril = TRUE

//shambling miner crusher trophy
/obj/item/crusher_trophy/blaster_tubes/mask
	name = "mask of a shambling miner"
	desc = "It really doesn't seem like it could be worn. Suitable as a crusher trophy."
	icon = 'icons/hispania/obj/lavaland/artefacts.dmi'
	icon_state = "miner_mask"
	bonus_value = 5

/obj/item/crusher_trophy/blaster_tubes/mask/effect_desc()
	return "the crusher to deal <b>[bonus_value]</b> extra melee damage"

/obj/item/crusher_trophy/blaster_tubes/mask/on_projectile_fire(obj/item/projectile/destabilizer/marker, mob/living/user)
	if(deadly_shot)
		marker.name = "kinetic [marker.name]"
		marker.icon_state = "ka_tracer"
		marker.damage = bonus_value
		marker.nodamage = FALSE
		deadly_shot = FALSE

/obj/item/crusher_trophy/blaster_tubes/mask/on_mark_application(mob/living/target, datum/status_effect/crusher_mark/mark, had_mark)
	new /obj/effect/temp_visual/kinetic_blast(target)
	playsound(target.loc, 'sound/weapons/kenetic_accel.ogg', 60, 0)

/obj/item/crusher_trophy/blaster_tubes/mask/add_to(obj/item/twohanded/kinetic_crusher/H, mob/living/user)
	. = ..()
	H.force += bonus_value

/obj/item/crusher_trophy/blaster_tubes/mask/remove_from(obj/item/twohanded/kinetic_crusher/H, mob/living/user)
	. = ..()
	H.force -= bonus_value
