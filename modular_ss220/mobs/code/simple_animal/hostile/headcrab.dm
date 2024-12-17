// port old headcrabs
/mob/living/simple_animal/hostile/blackmesa/xen/headcrab
	name = "headcrab"
	desc = "A small parasitic creature that would like to connect with your brain stem."
	icon = 'modular_ss220/mobs/icons/mob/headcrab.dmi'
	icon_state = "headcrab"
	icon_living = "headcrab"
	icon_dead = "headcrab_dead"
	health = 60
	maxHealth = 60
	dodging = 1
	melee_damage_lower = 5
	melee_damage_upper = 10
	ranged = 1
	ranged_message = "leaps"
	ranged_cooldown_time = 40
	var/jumpdistance = 4
	var/jumpspeed = 1
	attacktext = "грызёт"
	attack_sound = 'modular_ss220/mobs/sound/creatures/headcrab_attack.ogg'
	speak_emote = list("hisses")
	var/is_zombie = 0
	stat_attack = DEAD // Necessary for them to attack (zombify) dead humans
	robust_searching = 1
	var/host_species = ""
	var/list/human_overlays = list()

/mob/living/simple_animal/hostile/blackmesa/xen/headcrab/Life(seconds, times_fired)
	if(..() && !stat)
		if(!is_zombie && isturf(src.loc))
			for(var/mob/living/carbon/human/H in oview(src, 1)) //Only for corpse right next to/on same tile
				if(H.stat == DEAD || (!H.check_death_method() && H.health <= HEALTH_THRESHOLD_DEAD))
					Zombify(H)
					break
		if(times_fired % 4 == 0)
			for(var/mob/living/simple_animal/K in oview(src, 1)) //Only for corpse right next to/on same tile
				if(K.stat == DEAD || (!K.check_death_method() && K.health <= HEALTH_THRESHOLD_DEAD))
					visible_message(span_danger("[src] consumes [K] whole!"))
					if(health < maxHealth)
						health += 10
					qdel(K)
					break

/mob/living/simple_animal/hostile/blackmesa/xen/headcrab/OpenFire(atom/A)
	if(check_friendly_fire)
		for(var/turf/T in get_line(src,A)) // Not 100% reliable but this is faster than simulating actual trajectory
			for(var/mob/living/L in T)
				if(L == src || L == A)
					continue
				if(faction_check_mob(L) && !attack_same)
					return
	visible_message(span_danger("<b>[src]</b> [ranged_message] at [A]!"))
	throw_at(A, jumpdistance, jumpspeed, spin = FALSE, diagonals_first = TRUE)
	ranged_cooldown = world.time + ranged_cooldown_time

/mob/living/simple_animal/hostile/blackmesa/xen/headcrab/proc/Zombify(mob/living/carbon/human/H)
	if(!H.check_death_method())
		H.death()
	var/obj/item/organ/external/head/head_organ = H.get_organ("head")
	is_zombie = TRUE
	if(H.wear_suit)
		var/obj/item/clothing/suit/armor/A = H.wear_suit
		if(A.armor && A.armor.getRating("melee"))
			maxHealth += A.armor.getRating("melee") //That zombie's got armor, I want armor!
	maxHealth += 200
	health = maxHealth
	name = "zombie"
	desc = "A corpse animated by the alien being on its head."
	melee_damage_lower = 10
	melee_damage_upper = 15
	ranged = 0
	stat_attack = CONSCIOUS // Disables their targeting of dead mobs once they're already a zombie
	icon = H.icon
	speak = list('modular_ss220/mobs/sound/creatures/zombie_idle1.ogg','modular_ss220/mobs/sound/creatures/zombie_idle2.ogg','modular_ss220/mobs/sound/creatures/zombie_idle3.ogg')
	speak_chance = 50
	speak_emote = list("groans")
	attacktext = "грызёт"
	attack_sound = 'modular_ss220/mobs/sound/creatures/zombie_attack.ogg'
	icon_state = "zombie2_s"
	if(head_organ)
		head_organ.h_style = null
	H.update_hair()
	host_species = H.dna.species.name
	human_overlays = H.overlays
	update_icons()
	H.forceMove(src)
	visible_message(span_warning("The corpse of [H.name] suddenly rises!"))

/mob/living/simple_animal/hostile/blackmesa/xen/headcrab/death()
	..()
	if(is_zombie)
		qdel(src)

/mob/living/simple_animal/hostile/blackmesa/xen/headcrab/handle_automated_speech() // This way they have different screams when attacking, sometimes. Might be seen as sphagetthi code though.
	if(speak_chance)
		if(rand(0,200) < speak_chance)
			if(speak && speak.len)
				playsound(get_turf(src), pick(speak), 200, 1)

/mob/living/simple_animal/hostile/blackmesa/xen/headcrab/Destroy()
	if(contents)
		for(var/mob/M in contents)
			M.loc = get_turf(src)
	return ..()

/mob/living/simple_animal/hostile/blackmesa/xen/headcrab/update_icons()
	. = ..()
	if(is_zombie)
		overlays.Cut()
		overlays = human_overlays
		var/image/I = image('modular_ss220/mobs/icons/mob/headcrab.dmi', icon_state = "headcrabpod")
		if(host_species == "Vox")
			I = image('modular_ss220/mobs/icons/mob/headcrab.dmi', icon_state = "headcrabpod_vox")
		else if(host_species == "Gray")
			I = image('modular_ss220/mobs/icons/mob/headcrab.dmi', icon_state = "headcrabpod_gray")
		overlays += I

/mob/living/simple_animal/hostile/blackmesa/xen/headcrab/CanAttack(atom/the_target)
	if(stat_attack == DEAD && isliving(the_target) && !ishuman(the_target))
		var/mob/living/L = the_target
		if(L.stat == DEAD)
			// Override default behavior of stat_attack, to stop headcrabs targeting dead mobs they cannot infect, such as silicons.
			return FALSE
	return ..()

/mob/living/simple_animal/hostile/blackmesa/xen/headcrab/fast
	name = "fast headcrab"
	desc = "A fast parasitic creature that would like to connect with your brain stem."
	icon = 'modular_ss220/mobs/icons/mob/headcrab.dmi'
	icon_state = "fast_headcrab"
	icon_living = "fast_headcrab"
	icon_dead = "fast_headcrab_dead"
	health = 40
	maxHealth = 40
	ranged_cooldown_time = 30
	jumpdistance = 8
	jumpspeed = 2
	speak_emote = list("screech")

/mob/living/simple_animal/hostile/blackmesa/xen/headcrab/fast/update_icons()
	. = ..()
	if(is_zombie)
		overlays.Cut()
		overlays = human_overlays
		var/image/I = image('modular_ss220/mobs/icons/mob/headcrab.dmi', icon_state = "fast_headcrabpod")
		if(host_species == "Vox")
			I = image('modular_ss220/mobs/icons/mob/headcrab.dmi', icon_state = "fast_headcrabpod_vox")
		else if(host_species == "Gray")
			I = image('modular_ss220/mobs/icons/mob/headcrab.dmi', icon_state = "fast_headcrabpod_gray")
		overlays += I

/mob/living/simple_animal/hostile/blackmesa/xen/headcrab/fast/Zombify(mob/living/carbon/human/H)
	. = ..()
	speak = list('modular_ss220/mobs/sound/creatures/fast_zombie_idle1.ogg','modular_ss220/mobs/sound/creatures/fast_zombie_idle2.ogg','modular_ss220/mobs/sound/creatures/fast_zombie_idle3.ogg')

/mob/living/simple_animal/hostile/blackmesa/xen/headcrab/poison
	name = "poison headcrab"
	desc = "A poison parasitic creature that would like to connect with your brain stem."
	icon = 'modular_ss220/mobs/icons/mob/headcrab.dmi'
	icon_state = "poison_headcrab"
	icon_living = "poison_headcrab"
	icon_dead = "poison_headcrab_dead"
	health = 80
	maxHealth = 80
	ranged_cooldown_time = 50
	jumpdistance = 3
	jumpspeed = 1
	melee_damage_lower = 8
	melee_damage_upper = 20
	attack_sound = 'modular_ss220/mobs/sound/creatures/ph_scream1.ogg'
	speak_emote = list("screech")

/mob/living/simple_animal/hostile/blackmesa/xen/headcrab/poison/update_icons()
	. = ..()
	if(is_zombie)
		overlays.Cut()
		overlays = human_overlays
		var/image/I = image('modular_ss220/mobs/icons/mob/headcrab.dmi', icon_state = "poison_headcrabpod")
		if(host_species == "Vox")
			I = image('modular_ss220/mobs/icons/mob/headcrab.dmi', icon_state = "poison_headcrabpod_vox")
		else if(host_species == "Gray")
			I = image('modular_ss220/mobs/icons/mob/headcrab.dmi', icon_state = "poison_headcrabpod_gray")
		overlays += I


/mob/living/simple_animal/hostile/blackmesa/xen/headcrab/poison/AttackingTarget()
	. = ..()
	if(iscarbon(target) && target.reagents)
		var/inject_target = pick("chest", "head")
		var/mob/living/carbon/C = target
		if(C.IsStunned() || C.can_inject(null, FALSE, inject_target, FALSE))
			if(C.AmountEyeBlurry() < 60)
				C.AdjustEyeBlurry(10)
				visible_message(span_danger("[src] buries its fangs deep into the [inject_target] of [target]!"))
