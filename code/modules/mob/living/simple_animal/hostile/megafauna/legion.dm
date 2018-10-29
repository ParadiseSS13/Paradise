#define MEDAL_PREFIX "Legion"
/*

LEGION

Legion spawns from the necropolis gate in the far north of lavaland. It is the guardian of the Necropolis and emerges from within whenever an intruder tries to enter through its gate.
Whenever Legion emerges, everything in lavaland will receive a notice via color, audio, and text. This is because Legion is powerful enough to slaughter the entirety of lavaland with little effort.

It has two attack modes that it constantly rotates between.

In ranged mode, it will behave like a normal legion - retreating when possible and firing legion skulls at the target.
In charge mode, it will spin and rush its target, attacking with melee whenever possible.

When Legion dies, it drops a staff of storms, which allows its wielder to call and disperse ash storms at will and functions as a powerful melee weapon.

Difficulty: Medium

*/

/mob/living/simple_animal/hostile/megafauna/legion
	name = "Legion"
	health = 800
	maxHealth = 800
	icon_state = "legion"
	icon_living = "legion"
	desc = "One of many."
	icon = 'icons/mob/lavaland/legion.dmi'
	attacktext = "chomps"
	attack_sound = 'sound/misc/demon_attack1.ogg'
	speak_emote = list("echoes")
	armour_penetration = 50
	melee_damage_lower = 25
	melee_damage_upper = 25
	speed = 2
	ranged = 1
	del_on_death = 1
	retreat_distance = 5
	minimum_distance = 5
	ranged_cooldown_time = 20
	var/size = 5
	var/charging = 0
	medal_type = MEDAL_PREFIX
	score_type = LEGION_SCORE
	pixel_y = -90
	pixel_x = -75
	loot = list(/obj/item/stack/sheet/bone = 3)
	vision_range = 13
	elimination = 1
	idle_vision_range = 13
	appearance_flags = 0
	mouse_opacity = MOUSE_OPACITY_ICON
	stat_attack = 1 // Overriden from /tg/ - otherwise Legion starts chasing its minions

/mob/living/simple_animal/hostile/megafauna/legion/New()
	..()
	internal_gps = new/obj/item/gps/internal/legion(src)

/mob/living/simple_animal/hostile/megafauna/legion/AttackingTarget()
	..()
	if(ishuman(target))
		var/mob/living/L = target
		if(L.stat == UNCONSCIOUS)
			var/mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion/A = new(loc)
			A.infest(L)

/mob/living/simple_animal/hostile/megafauna/legion/OpenFire(the_target)
	if(world.time >= ranged_cooldown && !charging)
		if(prob(75))
			var/mob/living/simple_animal/hostile/asteroid/hivelordbrood/legion/A = new(loc)
			A.GiveTarget(target)
			A.friends = friends
			A.faction = faction
			ranged_cooldown = world.time + ranged_cooldown_time
		else
			visible_message("<span class='warning'><b>[src] charges!</b></span>")
			SpinAnimation(speed = 20, loops = 5)
			ranged = 0
			retreat_distance = 0
			minimum_distance = 0
			speed = 0
			charging = 1
			spawn(50)
				reset_charge()

/mob/living/simple_animal/hostile/megafauna/legion/proc/reset_charge()
	ranged = 1
	retreat_distance = 5
	minimum_distance = 5
	speed = 2
	charging = 0

/mob/living/simple_animal/hostile/megafauna/legion/can_die()
	return ..() && health <= 0

/mob/living/simple_animal/hostile/megafauna/legion/death()
	if(!can_die())
		return FALSE
	if(size > 1)
		adjustHealth(-maxHealth) //heal ourself to full in prep for splitting
		var/mob/living/simple_animal/hostile/megafauna/legion/L = new(loc)

		L.maxHealth = maxHealth * 0.6
		maxHealth = L.maxHealth

		L.health = L.maxHealth
		health = maxHealth

		size--
		L.size = size

		L.resize = L.size * 0.2
		transform = initial(transform)
		resize = size * 0.2

		L.update_transform()
		update_transform()

		L.faction = faction.Copy()

		L.GiveTarget(target)

		visible_message("<span class='boldannounce'>[src] splits in twain!</span>")
		return FALSE // not dead
	else
		// this must come before the parent call due to the setting of `loot` here
		var/last_legion = TRUE
		for(var/mob/living/simple_animal/hostile/megafauna/legion/other in GLOB.mob_list)
			if(other != src)
				last_legion = FALSE
				break
		if(last_legion)
			loot = list(/obj/item/staff/storm)
			elimination = 0
		else if(prob(5))
			loot = list(/obj/structure/closet/crate/necropolis/tendril)
		return ..()

/mob/living/simple_animal/hostile/megafauna/legion/Process_Spacemove(movement_dir = 0)
	return 1

/obj/item/gps/internal/legion
	icon_state = null
	gpstag = "Echoing Signal"
	desc = "The message repeats."
	invisibility = 100

#undef MEDAL_PREFIX
