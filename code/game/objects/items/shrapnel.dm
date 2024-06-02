/obj/item/shrapnel // frag grenades
	name = "shrapnel shard"
	icon = 'icons/obj/shards.dmi'
	icon_state = "shrapnel1"
	w_class = WEIGHT_CLASS_TINY
	flags = DROPDEL

/obj/item/shrapnel/stingball // stingbang grenades
	name = "stingball"
	icon_state = "tiny"
	sharp = FALSE

/obj/item/shrapnel/bullet // bullets
	name = "bullet"
	icon = 'icons/obj/ammo.dmi'
	icon_state = "s-casing"
	embedding = null // embedding vars are taken from the projectile itself

/**
 * Shrapnel projectiles turn into this after trying to embed
 */
/obj/item/projectile/bullet/shrapnel
	name = "flying shrapnel shard"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "magspear"
	damage = 14
	range = 20
	dismemberment = 5
	ricochets_max = 2
	ricochet_chance = 70
	ricochet_incidence_leeway = 60
	shrapnel_type = /obj/item/shrapnel
	embedding = list(embed_chance = 70, ignore_throwspeed_threshold = TRUE, fall_chance = 1)

/obj/item/projectile/bullet/shrapnel/short_range
	range = 5

/obj/item/projectile/bullet/shrapnel/mega
	name = "flying shrapnel hunk"
	range = 45
	dismemberment = 15
	ricochets_max = 6
	ricochet_chance = 130
	ricochet_incidence_leeway = 0
	ricochet_decay_chance = 0.9

/obj/item/projectile/bullet/shrapnel/ied
	name = "flying glass shrapnel"
	damage = 15
	range = 6
	ricochets_max = 1
	ricochet_chance = 40
	ricochet_incidence_leeway = 60
	shrapnel_type = /obj/item/shard

/obj/item/projectile/bullet/pellet/stingball
	name = "stingball pellet"
	damage = 3
	stamina = 8
	ricochets_max = 4
	ricochet_chance = 66
	ricochet_decay_chance = 1
	ricochet_decay_damage = 0.9
	ricochet_auto_aim_angle = 10
	ricochet_auto_aim_range = 2
	ricochet_incidence_leeway = 0
	shrapnel_type = /obj/item/shrapnel/stingball
	embedding = list(embed_chance=55, fall_chance=2, jostle_chance=7, ignore_throwspeed_threshold=TRUE, pain_stam_pct=0.7, pain_mult=3, jostle_pain_mult=3, rip_time=15)

/obj/item/projectile/bullet/pellet/stingball/mega
	name = "megastingball pellet"
	ricochets_max = 6
	ricochet_chance = 110

/obj/item/projectile/bullet/pellet/capmine
	name = "\improper AP shrapnel shard"
	range = 7
	damage = 8
	stamina = 8
	ricochets_max = 2
	ricochet_chance = 140
	shrapnel_type = /obj/item/shrapnel/capmine
	embedding = list(embed_chance=90, fall_chance=3, jostle_chance=7, ignore_throwspeed_threshold=TRUE, pain_stam_pct=0.7, pain_mult=5, jostle_pain_mult=6, rip_time=15)

/obj/item/shrapnel/capmine
	name = "\improper AP shrapnel shard"
