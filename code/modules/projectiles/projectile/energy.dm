#define NO_DEFLECTION 0		//defines to avoid magic numbers, used for taser glancing off of armor
#define PARTIAL_DEFLECTION 1
#define FULL_DEFLECTION 2

/obj/item/projectile/energy
	name = "energy"
	icon_state = "spark"
	damage = 0
	damage_type = BURN
	flag = "energy"
	is_reflectable = TRUE

/obj/item/projectile/energy/electrode
	name = "electrode"
	icon_state = "spark"
	color = "#FFFF00"
	nodamage = 1
	stun = 5
	weaken = 5
	stutter = 5
	jitter = 20
	hitsound = 'sound/weapons/tase.ogg'
	range = 7
	//Damage will be handled on the MOB side, to prevent window shattering.

/obj/item/projectile/energy/electrode/on_hit(var/atom/target, var/blocked = 0)
	var/deflected = NO_DEFLECTION //0 for not deflected, 1 for partially, 2 for totally.
	if(ishuman(target)) //have to do this stuff before we call ..(), but I want the messages to come in the right order. So the deflected var.
		var/mob/living/carbon/human/H = target//typecast
		var/protection = H.getarmor(def_zone, "shock") //checks for taser resistance of worn armor
		if(prob(protection)) //chance to completely negate taser hit
			stun = 0
			weaken = 0
			stutter = 0
			jitter = 0
			deflected = FULL_DEFLECTION
		else if(prob(protection)) //chance for a glancing blow if first check fails
			stun = 0
			weaken = 0
			H.apply_effect(stamina, 50, 0) //stamina damage, still better than being stunned.
			deflected = PARTIAL_DEFLECTION
	. = ..()
	if(deflected == PARTIAL_DEFLECTION)
		target.visible_message("<span class='danger'>The shock is weakened by the armor!</span>", \
								"<span class='userdanger'>The shock is weakened by your armor!</span>")
	else if(deflected == FULL_DEFLECTION)
		target.visible_message("<span class='danger'>The electrode glance off of the armor!</span>", \
								"<span class='userdanger'>The electrode glance off of your armor!</span>")
	if(!ismob(target) || blocked >= 100) //Fully blocked by mob or collided with dense object - burst into sparks!
		var/datum/effect_system/spark_spread/sparks = new /datum/effect_system/spark_spread
		sparks.set_up(1, 1, src)
		sparks.start()
	else if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(HULK in C.mutations)
			C.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		else if((C.status_flags & CANWEAKEN) && (deflected != FULL_DEFLECTION))
			spawn(5)
				C.do_jitter_animation(jitter)

/obj/item/projectile/energy/electrode/on_range() //to ensure the bolt sparks when it reaches the end of its range if it didn't hit a target yet
	var/datum/effect_system/spark_spread/sparks = new /datum/effect_system/spark_spread
	sparks.set_up(1, 1, src)
	sparks.start()
	..()

/obj/item/projectile/energy/declone
	name = "declone"
	icon_state = "declone"
	damage = 20
	damage_type = CLONE
	irradiate = 10

/obj/item/projectile/energy/dart
	name = "dart"
	icon_state = "toxin"
	damage = 5
	damage_type = TOX
	weaken = 5
	range = 7

/obj/item/projectile/energy/shuriken
	name = "shuriken"
	icon_state = "toxin"
	damage = 10
	damage_type = TOX
	weaken = 5
	stutter = 5

/obj/item/projectile/energy/bolt
	name = "bolt"
	icon_state = "cbbolt"
	damage = 15
	damage_type = TOX
	nodamage = 0
	weaken = 5
	stutter = 5

/obj/item/projectile/energy/bolt/large
	damage = 20

/obj/item/projectile/energy/shock_revolver
	name = "shock bolt"
	icon_state = "purple_laser"
	var/chain

/obj/item/ammo_casing/energy/shock_revolver/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	..()
	var/obj/item/projectile/energy/shock_revolver/P = BB
	spawn(1)
		P.chain = P.Beam(user,icon_state="purple_lightning",icon = 'icons/effects/effects.dmi',time=1000, maxdistance = 30)

/obj/item/projectile/energy/shock_revolver/on_hit(atom/target)
	. = ..()
	if(isliving(target))
		tesla_zap(src, 3, 10000)
	qdel(chain)

/obj/item/projectile/energy/toxplasma
	name = "plasma bolt"
	icon_state = "energy"
	damage = 20
	damage_type = TOX
	irradiate = 20
