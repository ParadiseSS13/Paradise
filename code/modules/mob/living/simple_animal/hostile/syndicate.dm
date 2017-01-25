/mob/living/simple_animal/hostile/syndicate
	name = "Syndicate Operative"
	desc = "Death to Nanotrasen."
	icon_state = "syndicate"
	icon_living = "syndicate"
	icon_dead = "syndicate_dead"
	icon_gib = "syndicate_gib"
	speak_chance = 0
	turns_per_move = 5
	response_help = "pokes the"
	response_disarm = "shoves the"
	response_harm = "hits the"
	speed = 0
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	melee_damage_lower = 10
	melee_damage_upper = 10
	attacktext = "punches"
	attack_sound = 'sound/weapons/punch1.ogg'
	a_intent = I_HARM
	unsuitable_atmos_damage = 15
	faction = list("syndicate")
	check_friendly_fire = 1
	status_flags = CANPUSH
	loot = list(/obj/effect/landmark/mobcorpse/syndicatesoldier)
	del_on_death = 1

///////////////Sword and shield////////////

/mob/living/simple_animal/hostile/syndicate/melee
	melee_damage_lower = 20
	melee_damage_upper = 25
	icon_state = "syndicatemelee"
	icon_living = "syndicatemelee"
	attacktext = "slashes"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	armour_penetration = 28
	status_flags = 0
	loot = list(/obj/effect/landmark/mobcorpse/syndicatesoldier, /obj/item/weapon/melee/energy/sword/saber/red, /obj/item/weapon/shield/energy)

/mob/living/simple_animal/hostile/syndicate/melee/attackby(var/obj/item/O as obj, var/mob/user as mob, params)
	if(O.force)
		if(prob(80))
			var/damage = O.force
			if(O.damtype == STAMINA)
				damage = 0
			health -= damage
			visible_message("\red \b [src] has been attacked with the [O] by [user]. ")
		else
			visible_message("\red \b [src] blocks the [O] with its shield! ")
		playsound(loc, O.hitsound, 25, 1, -1)
	else
		to_chat(usr, "\red This weapon is ineffective, it does no damage.")
		visible_message("\red [user] gently taps [src] with the [O]. ")


/mob/living/simple_animal/hostile/syndicate/melee/bullet_act(var/obj/item/projectile/Proj)
	if(!Proj)	return
	if(prob(65))
		if((Proj.damage_type == BRUTE || Proj.damage_type == BURN))
			adjustHealth(Proj.damage)
	else
		visible_message("<span class='danger'>[src] blocks [Proj] with its shield!</span>")
	return 0


/mob/living/simple_animal/hostile/syndicate/melee/space
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	icon_state = "syndicatemeleespace"
	icon_living = "syndicatemeleespace"
	name = "Syndicate Commando"
	speed = 1
	loot = list(/obj/effect/landmark/mobcorpse/syndicatecommando, /obj/item/weapon/melee/energy/sword/saber/red, /obj/item/weapon/shield/energy)

/mob/living/simple_animal/hostile/syndicate/melee/space/Process_Spacemove(var/movement_dir = 0)
	return

/mob/living/simple_animal/hostile/syndicate/ranged
	ranged = 1
	rapid = 1
	retreat_distance = 5
	minimum_distance = 5
	icon_state = "syndicateranged"
	icon_living = "syndicateranged"
	casingtype = /obj/item/ammo_casing/c45
	loot = list(/obj/effect/landmark/mobcorpse/syndicatesoldier, /obj/item/weapon/gun/projectile/automatic/c20r)

/mob/living/simple_animal/hostile/syndicate/ranged/space
	icon_state = "syndicaterangedpsace"
	icon_living = "syndicaterangedpsace"
	name = "Syndicate Commando"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	speed = 1
	loot = list(/obj/effect/landmark/mobcorpse/syndicatecommando, /obj/item/weapon/gun/projectile/automatic/c20r)


/mob/living/simple_animal/hostile/syndicate/ranged/space/Process_Spacemove(var/movement_dir = 0)
	return



/mob/living/simple_animal/hostile/viscerator
	name = "viscerator"
	desc = "A small, twin-bladed machine capable of inflicting very deadly lacerations."
	icon = 'icons/mob/critter.dmi'
	icon_state = "viscerator_attack"
	icon_living = "viscerator_attack"
	pass_flags = PASSTABLE
	health = 15
	maxHealth = 15
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "cuts"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	faction = list("syndicate")
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	mob_size = MOB_SIZE_TINY
	flying = 1
	gold_core_spawnable = CHEM_MOB_SPAWN_HOSTILE
	del_on_death = 1
	deathmessage = "is smashed into pieces!"