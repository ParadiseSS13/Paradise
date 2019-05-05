/mob/living/simple_animal/hostile/spiderman
	name = "The Amazing Spiderman"
	desc = "He looks powerful and responsible."
	icon = 'icons/mob/spiderman.dmi'
	icon_state = "Spidey"
	icon_living = "Spidey"
	wander = 1
	universal_speak = 1
	health = 200
	maxHealth = 200
	see_in_dark = 10
	pass_flags = PASSTABLE
	obj_damage = 60
	melee_damage_lower = 15
	melee_damage_upper = 20
	melee_damage_type = BRUTE
	attacktext = "fwips"
	attack_sound = 'sound/weapons/cqchit1.ogg'
	projectiletype = /obj/item/projectile/web
	projectilesound = 'sound/weapons/thudswoosh.ogg'
	faction = list("neutral")
	response_help  = "high fives"
	response_disarm = "shoves"
	response_harm   = "punches"
	ranged = 1
	mob_size = MOB_SIZE_SMALL
	speak_emote = list("says","chitters") // I mean he's part spider

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 500

	can_hide = 1
	ventcrawler = 2
	loot = list(/obj/item/reagent_containers/food/snacks/spidermeat)
	del_on_death = 1

/obj/item/projectile/web
	name = "web"
	icon_state = "web_end"
	pass_flags = PASSTABLE
	damage = 0
	damage_type = BRUTE
	range = 8
	hitsound = 'sound/weapons/thudswoosh.ogg'
	var/chain

/obj/item/projectile/web/fire(setAngle)
	if(firer)
		chain = firer.Beam(src, icon_state = "web_beam", time = INFINITY, maxdistance = INFINITY, beam_sleep_time = 1)
	..()

/obj/item/projectile/web/Destroy()
	qdel(chain)
	return ..()

/obj/item/projectile/web/on_hit(atom/the_target, blocked = 0)
	dir = get_dir(src,the_target)
	step(the_target,get_dir(the_target,src))
	if (istype(the_target,/mob))
		var/mob/M = the_target
		M.Weaken(3)
	..()
