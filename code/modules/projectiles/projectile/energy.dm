/obj/item/projectile/energy
	name = "energy"
	icon_state = "spark"
	damage = 0
	damage_type = BURN
	flag = "energy"


/obj/item/projectile/energy/electrode
	name = "electrode"
	icon_state = "spark"
	nodamage = 1
	stun = 5
	weaken = 5
	stutter = 5
	hitsound = 'sound/weapons/tase.ogg'
	//Damage will be handled on the MOB side, to prevent window shattering.

	on_hit(var/atom/target, var/blocked = 0)
		if(!ismob(target) || blocked >= 2) //Fully blocked by mob or collided with dense object - burst into sparks!
			var/datum/effect/effect/system/spark_spread/sparks = new /datum/effect/effect/system/spark_spread
			sparks.set_up(1, 1, src)
			sparks.start()
		..()

/obj/item/projectile/energy/electrode/revolver
	name = "electrode"
	icon_state = "spark"
	nodamage = 1
/*	stun = 2
	weaken = 2
	stutter = 10 */
	agony = 50
	damage_type = HALLOSS
	hitsound = 'sound/weapons/tase.ogg'
	//Damage will be handled on the MOB side, to prevent window shattering.

/obj/item/projectile/energy/declone
	name = "declone"
	icon_state = "declone"
	damage = 40
	damage_type = CLONE
	irradiate = 40


/obj/item/projectile/energy/dart
	name = "dart"
	icon_state = "toxin"
	damage = 5
	damage_type = TOX
	weaken = 5


/obj/item/projectile/energy/bolt
	name = "bolt"
	icon_state = "cbbolt"
	damage = 10
	damage_type = TOX
	nodamage = 0
	weaken = 5
	stutter = 5

/obj/item/projectile/energy/bolt/large
	name = "largebolt"
	damage = 20

/obj/item/projectile/energy/plasma
	name = "plasma bolt"
	icon_state = "energy"
	damage = 20
	damage_type = TOX
	irradiate = 20

/obj/item/projectile/energy/disabler
	name = "disabler beam"
	icon_state = "omnilaser"
	damage = 34
	damage_type = STAMINA
	var/range = 8

/obj/item/projectile/energy/disabler/Range()
	range--
	if(range <= 0)
		del(src)