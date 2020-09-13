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
	wander = 0
	speed = 2
	ranged = 1
	del_on_death = 1
	retreat_distance = 5
	minimum_distance = 5
	ranged_cooldown_time = 20
	var/size = 5
	var/charging = 0
	internal_type = /obj/item/gps/internal/legion
	medal_type = BOSS_MEDAL_LEGION
	score_type = LEGION_SCORE
	pixel_y = -90
	pixel_x = -75
	loot = list(/obj/item/stack/sheet/bone = 3)
	vision_range = 13
	elimination = 1
	appearance_flags = 0
	mouse_opacity = MOUSE_OPACITY_ICON
	stat_attack = UNCONSCIOUS // Overriden from /tg/ - otherwise Legion starts chasing its minions

/mob/living/simple_animal/hostile/megafauna/legion/AttackingTarget()
	. = ..()
	if(. && ishuman(target))
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
			loot = list(/obj/structure/closet/crate/necropolis/legion)
			if(!true_spawn)
				loot = null
		return ..()

/mob/living/simple_animal/hostile/megafauna/legion/Process_Spacemove(movement_dir = 0)
	return 1

/obj/item/gps/internal/legion
	icon_state = null
	gpstag = "Echoing Signal"
	desc = "The message repeats."
	invisibility = 100

/obj/structure/closet/crate/necropolis/legion
	name = "Legion chest"
	desc = "You feel the pressure of many thousand souls looking at you angrily."

/obj/structure/closet/crate/necropolis/legion/New(add_loot = TRUE)
	..()

	if(!add_loot)
		return

	var/loot = rand(1, 26)
	switch(loot)
		if(1)
			new /obj/item/shared_storage/red(src)
		if(2)
			new /obj/item/clothing/head/helmet/space/cult(src)
			new /obj/item/clothing/suit/space/cult(src)
		if(3)
			new /obj/item/soulstone/anybody(src)
		if(4)
			new /obj/item/katana/cursed(src)
		if(5)
			new /obj/item/clothing/glasses/godeye(src)
		if(6)
			new /obj/item/pickaxe/diamond(src)
		if(7)
			new /obj/item/clothing/suit/hooded/cultrobes(src)
			new /obj/item/bedsheet/cult(src)
		if(8)
			if(prob(50))
				new /obj/item/disk/design_disk/modkit_disc/resonator_blast(src)
			else
				new /obj/item/disk/design_disk/modkit_disc/rapid_repeater(src)
		if(9)
			new /obj/item/rod_of_asclepius(src)
		if(10)
			new /obj/item/organ/internal/heart/cursed/wizard(src)
		if(11)
			new /obj/item/ship_in_a_bottle(src)
		if(12)
			new /obj/item/clothing/suit/space/hardsuit/ert/paranormal/berserker(src)
		if(13)
			new /obj/item/jacobs_ladder(src)
		if(14)
			new /obj/item/nullrod/scythe/talking(src)
		if(15)
			new /obj/item/nullrod/armblade(src)
		if(16)
			new /obj/item/guardiancreator(src)
		if(17)
			if(prob(50))
				new /obj/item/disk/design_disk/modkit_disc/mob_and_turf_aoe(src)
			else
				new /obj/item/disk/design_disk/modkit_disc/bounty(src)
		if(18)
			new /obj/item/warp_cube/red(src)
		if(19)
			new /obj/item/wisp_lantern(src)
		if(20)
			new /obj/item/immortality_talisman(src)
		if(21)
			new /obj/item/gun/magic/hook(src)
		if(22)
			new /obj/item/voodoo(src)
		if(23)
			new /obj/item/grenade/clusterbuster/inferno(src)
		if(24)
			new /obj/item/reagent_containers/food/drinks/bottle/holywater/hell(src)
			new /obj/item/clothing/suit/space/hardsuit/ert/paranormal/inquisitor(src)
		if(25)
			new /obj/item/spellbook/oneuse/summonitem(src)
		if(26)
			new /obj/item/book_of_babel(src)
		if(27)
			new /obj/item/borg/upgrade/modkit/lifesteal(src)
			new /obj/item/bedsheet/cult(src)
