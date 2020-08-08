#define MODE_REST 1
#define MODE_DEFENDING 2
#define MODE_RETURNING 3
#define MODE_NEWHOME 4
#define MODE_RAMPAGE 5

/mob/living/simple_animal/hostile/headcrab
	name = "headcrab"
	desc = "A small parasitic creature that would like to connect with your brain stem."
	icon = 'icons/mob/headcrab.dmi'
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
	attacktext = "bites"
	attack_sound = 'sound/creatures/headcrab_attack.ogg'
	speak_emote = list("hisses")
	var/is_zombie = 0
	stat_attack = DEAD // Necessary for them to attack (zombify) dead humans
	robust_searching = 1
	var/can_zombify = TRUE
	var/host_species = ""
	var/list/human_overlays = list()

/mob/living/simple_animal/hostile/headcrab/Life(seconds, times_fired)
	if(..() && !stat)
		if(!is_zombie && isturf(src.loc) && can_zombify)
			for(var/mob/living/carbon/human/H in oview(src, 1)) //Only for corpse right next to/on same tile
				if(H.stat == DEAD || (!H.check_death_method() && H.health <= HEALTH_THRESHOLD_DEAD))
					Zombify(H)
					break
		var/cycles = 4
		if(cycles >= 4)
			for(var/mob/living/simple_animal/K in oview(src, 1)) //Only for corpse right next to/on same tile
				if(K.stat == DEAD || (!K.check_death_method() && K.health <= HEALTH_THRESHOLD_DEAD))
					visible_message("<span class='danger'>[src] consumes [K] whole!</span>")
					if(health < maxHealth)
						health += 10
					qdel(K)
					break
				cycles = 0
		cycles++

/mob/living/simple_animal/hostile/headcrab/OpenFire(atom/A)
	if(check_friendly_fire)
		for(var/turf/T in getline(src,A)) // Not 100% reliable but this is faster than simulating actual trajectory
			for(var/mob/living/L in T)
				if(L == src || L == A)
					continue
				if(faction_check_mob(L) && !attack_same)
					return
	visible_message("<span class='danger'><b>[src]</b> [ranged_message] at [A]!</span>")
	throw_at(A, jumpdistance, jumpspeed, spin = FALSE, diagonals_first = TRUE)
	ranged_cooldown = world.time + ranged_cooldown_time

/mob/living/simple_animal/hostile/headcrab/proc/Zombify(mob/living/carbon/human/H)
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
	speak = list('sound/creatures/zombie_idle1.ogg','sound/creatures/zombie_idle2.ogg','sound/creatures/zombie_idle3.ogg')
	speak_chance = 50
	speak_emote = list("groans")
	attacktext = "bites"
	attack_sound = 'sound/creatures/zombie_attack.ogg'
	icon_state = "zombie2_s"
	if(head_organ)
		head_organ.h_style = null
	H.update_hair()
	host_species = H.dna.species.name
	human_overlays = H.overlays
	update_icons()
	H.forceMove(src)
	visible_message("<span class='warning'>The corpse of [H.name] suddenly rises!</span>")

/mob/living/simple_animal/hostile/headcrab/death()
	..()
	if(is_zombie)
		qdel(src)


/mob/living/simple_animal/hostile/headcrab/handle_automated_speech() // This way they have different screams when attacking, sometimes. Might be seen as sphagetthi code though.
	if(speak_chance)
		if(rand(0,200) < speak_chance)
			if(speak && speak.len)
				playsound(get_turf(src), pick(speak), 200, 1)

/mob/living/simple_animal/hostile/headcrab/Destroy()
	if(contents)
		for(var/mob/M in contents)
			M.loc = get_turf(src)
	return ..()


/mob/living/simple_animal/hostile/headcrab/update_icons()
	. = ..()
	if(is_zombie)
		overlays.Cut()
		overlays = human_overlays
		var/image/I = image('icons/mob/headcrab.dmi', icon_state = "headcrabpod")
		if(host_species == "Vox")
			I = image('icons/mob/headcrab.dmi', icon_state = "headcrabpod_vox")
		else if(host_species == "Gray")
			I = image('icons/mob/headcrab.dmi', icon_state = "headcrabpod_gray")
		overlays += I

/mob/living/simple_animal/hostile/headcrab/CanAttack(atom/the_target)
	if(stat_attack == DEAD && isliving(the_target) && !ishuman(the_target))
		var/mob/living/L = the_target
		if(L.stat == DEAD)
			// Override default behavior of stat_attack, to stop headcrabs targeting dead mobs they cannot infect, such as silicons.
			return FALSE
	return ..()

/mob/living/simple_animal/hostile/headcrab/fast
	name = "fast headcrab"
	desc = "A fast parasitic creature that would like to connect with your brain stem."
	icon = 'icons/mob/headcrab.dmi'
	icon_state = "fast_headcrab"
	icon_living = "fast_headcrab"
	icon_dead = "fast_headcrab_dead"
	health = 40
	maxHealth = 40
	ranged_cooldown_time = 30
	jumpdistance = 8
	jumpspeed = 2
	speak_emote = list("screech")

/mob/living/simple_animal/hostile/headcrab/fast/update_icons()
	. = ..()
	if(is_zombie)
		overlays.Cut()
		overlays = human_overlays
		var/image/I = image('icons/mob/headcrab.dmi', icon_state = "fast_headcrabpod")
		if(host_species == "Vox")
			I = image('icons/mob/headcrab.dmi', icon_state = "fast_headcrabpod_vox")
		else if(host_species == "Gray")
			I = image('icons/mob/headcrab.dmi', icon_state = "fast_headcrabpod_gray")
		overlays += I

/mob/living/simple_animal/hostile/headcrab/fast/Zombify(mob/living/carbon/human/H)
	. = ..()
	speak = list('sound/creatures/fast_zombie_idle1.ogg','sound/creatures/fast_zombie_idle2.ogg','sound/creatures/fast_zombie_idle3.ogg')

/mob/living/simple_animal/hostile/headcrab/poison
	name = "poison headcrab"
	desc = "A poison parasitic creature that would like to connect with your brain stem."
	icon = 'icons/mob/headcrab.dmi'
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
	attack_sound = 'sound/creatures/ph_scream1.ogg'
	speak_emote = list("screech")

/mob/living/simple_animal/hostile/headcrab/poison/update_icons()
	. = ..()
	if(is_zombie)
		overlays.Cut()
		overlays = human_overlays
		var/image/I = image('icons/mob/headcrab.dmi', icon_state = "poison_headcrabpod")
		if(host_species == "Vox")
			I = image('icons/mob/headcrab.dmi', icon_state = "poison_headcrabpod_vox")
		else if(host_species == "Gray")
			I = image('icons/mob/headcrab.dmi', icon_state = "poison_headcrabpod_gray")
		overlays += I


/mob/living/simple_animal/hostile/headcrab/poison/AttackingTarget()
	. = ..()
	if(iscarbon(target) && target.reagents)
		var/inject_target = pick("chest", "head")
		var/mob/living/carbon/C = target
		if(C.stunned || C.can_inject(null, FALSE, inject_target, FALSE))
			if(C.eye_blurry < 60)
				C.AdjustEyeBlurry(10)
				visible_message("<span class='danger'>[src] buries its fangs deep into the [inject_target] of [target]!</span>")


/mob/living/simple_animal/hostile/headcrab/gonarch
	name = "gonarch"
	desc = "This is a... headcrab? Looks more like a walking tank."
	icon = 'icons/mob/gonarch.dmi'
	icon_state = "gonarch"
	icon_living = "gonarch"
	icon_dead = "gonarch"
	pixel_x = -16
	health = 800
	maxHealth = 800
	force_threshold = 16
	dodging = 1
	gender = FEMALE //doesn't matter though
	melee_damage_lower = 45
	melee_damage_upper = 75
	ranged = 0
	move_to_delay = 10
	speed = 1.5
	attacktext = "slashes"
	attack_sound = 'sound/creatures/gonarch_attack.ogg' //TODO maybe find a better sound. Something slashing maybe.
	speak_emote = list("hisses")
	robust_searching = 1
	obj_damage = 200
	stat_attack = CONSCIOUS // They don't care for killing. They want their peace.
	armour_penetration = 5
	attack_sound = 'sound/effects/blobattack.ogg'
	death_sound = 'sound/creatures/gonarch_die.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	stop_automated_movement_when_pulled = 0
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	vision_range = 9
	aggro_vision_range = 9
	pass_flags = PASSTABLE | PASSMOB //It is so big, you can walk through its legs.
	density = FALSE //Same as above.
	//It has so many vars, to enable admins to change its behaviour on the fly. This is also the reason why its statemachine uses a lot of proc calls, so admins can call these manually.
	can_zombify = FALSE
	var/gonarch_standard_vision_range = 9
	var/gonarch_aggro_vision_range = 9
	var/gonarch_standard_speed = 2
	var/area/home_nest_area
	var/turf/home_nest_turf
	var/homesick = 0
	var/mode = MODE_REST
	var/list/children = list()
	var/desired_child_count = 10
	var/time_last_babies = 0
	var/list/path_to_home
	var/frustration = 0
	var/frustration_limit = 10
	var/gonarch_nestfind_range = 8
	var/gonarch_rampage_trigger = 30
	var/gonarch_screech_range = 8
	var/gonarch_finding_home_limit_attempts = 2
	var/gonarch_finding_home_attempts = 0
	var/gonarch_headcrab_spawn_frequency = 600

//For testing on a server without players/1 player, uncomment the following block
/*
/mob/living/simple_animal/hostile/headcrab/gonarch/consider_wakeup()
	toggle_ai(AI_ON)

//For testing purposes
/mob/living/simple_animal/hostile/headcrab/gonarch/AIShouldSleep(var/list/possible_targets)
    FindTarget(possible_targets, 1)
    return FALSE
*/
/mob/living/simple_animal/hostile/headcrab/gonarch/Initialize()
	. = ..()
	home_nest_area = get_area(src)
	home_nest_turf = get_turf(src)
	do_gonarch_screech(8, 100, 8, 100)

/mob/living/simple_animal/hostile/headcrab/gonarch/handle_automated_action()
	. = ..()
	if(!.)
		return

	if(home_nest_area == get_area(src))
		mode_switch(MODE_REST)
	else
		homesick++

	//combat
	if(target && target != home_nest_turf && mode != MODE_RAMPAGE && mode != MODE_RETURNING) //We do not have a fight while rampage is on or while we return to base.
		//we are in combat now, guaranteed.
		//Is our Homesick too high to go rampage and leave?
		if(homesick >= gonarch_rampage_trigger)
			mode_switch(MODE_RAMPAGE, list('sound/creatures/gonarch_rampage.ogg'))
		else
			mode_switch(MODE_DEFENDING)
		return

	//out of combat
	if(homesick >= gonarch_rampage_trigger && mode != MODE_RAMPAGE)
		mode_switch(MODE_RAMPAGE, list('sound/creatures/gonarch_rampage.ogg'))
		return
	switch(mode)
		if(MODE_REST)		// idle
			gonarch_rest()
		if(MODE_RETURNING)		// returning home
			gonarch_return()
		if(MODE_NEWHOME)		// Seeking new home
			gonarch_newhome()
		if(MODE_RAMPAGE)		// Cannot find nest, frustration at max - rampage
			gonarch_rampage()
		if(MODE_DEFENDING) //If it goes down here, there is no target anymore. And it should return.
			mode_switch(MODE_RETURNING, list('sound/creatures/gonarch_return.ogg'))

/mob/living/simple_animal/hostile/headcrab/gonarch/proc/mode_switch(mode_to_switch, sound_to_play)
	if(mode_to_switch)
		mode = mode_to_switch
		if(sound_to_play)
			var/sound_picked = pick(sound_to_play)
			playsound(get_turf(src), sound_picked, 200, 1, 15, null, null, null, FALSE, TRUE)
	else
		stack_trace("[src] tried to switch to a NULL mode.")

/mob/living/simple_animal/hostile/headcrab/gonarch/proc/gonarch_rest()
	if(get_area(src) == home_nest_area) // If I am home & Everything is calm
		if(aggro_vision_range != gonarch_aggro_vision_range || vision_range != gonarch_standard_vision_range || speed != gonarch_standard_speed)
			aggro_vision_range = gonarch_aggro_vision_range
			vision_range = gonarch_standard_vision_range
			speed = gonarch_standard_speed
		if(homesick)
			homesick = 0
			step_towards(src, home_nest_turf, speed)
		make_headcrabs() //Its its own proc, so they can be called by admins.
	else
		if(homesick >= 5)
			mode_switch(MODE_RETURNING, list('sound/creatures/gonarch_return.ogg'))

/mob/living/simple_animal/hostile/headcrab/gonarch/proc/gonarch_return()
	speed = -1
	var/turf/olddist = get_dist(src, home_nest_turf)
	step_towards(src, home_nest_turf, speed)
	target = home_nest_turf
	if((get_dist(src, target)) >= (olddist))
		frustration++
		if(frustration > frustration_limit)
			DestroyPathToTarget()
			homesick++
	else
		frustration = 0

/mob/living/simple_animal/hostile/headcrab/gonarch/proc/gonarch_newhome()
	var/list/turfs = new/list()
	for(var/turf/T in range(src, gonarch_nestfind_range))
		if(T in range(src, 4))
			continue
		if(istype(T, /turf/space))
			continue
		if(T.density)
			continue
		var/lightingcount = T.get_lumcount(0.5) * 10
		if(lightingcount > 1 || gonarch_finding_home_attempts >= gonarch_finding_home_limit_attempts)
			continue
		turfs += T
	if(!turfs.len)
		gonarch_nestfind_range += 5
		gonarch_finding_home_attempts++
		return
	home_nest_turf = pick(turfs)
	home_nest_area = get_area(home_nest_turf)
	mode_switch(MODE_RETURNING, list('sound/creatures/gonarch_return.ogg'))

/mob/living/simple_animal/hostile/headcrab/gonarch/proc/gonarch_rampage()
	//We want to lose all targets, and get the hell out of here. Vision/care is restored when back in base.
	aggro_vision_range = 0
	vision_range = 0
	LoseTarget()
	homesick = 0
	for(var/mob/living/carbon/C in hearers(gonarch_screech_range, src))
		to_chat(C, "<span class='warning'><font size='3'><b>You hear a ear piercing shriek and your senses dull!</font></b></span>")
		C.Weaken(25)
		C.MinimumDeafTicks(20)
		C.Stuttering(20)
		C.Stun(25)
		C.Jitter(150)
	var/i //Workaround to avoid compiler complaints and use faster for-loops
	for(i in 1 to 4)
		spawn_headcrabs(FALSE)
	for(var/obj/structure/window/W in view(gonarch_screech_range))
		W.deconstruct(FALSE)
	mode_switch(MODE_NEWHOME, 'sound/creatures/gonarch_initialise.ogg')

/mob/living/simple_animal/hostile/headcrab/gonarch/proc/spawn_headcrabs(spawn_as_children = TRUE)
	var/list/spawn_types = list(/mob/living/simple_animal/hostile/headcrab, /mob/living/simple_animal/hostile/headcrab/fast, /mob/living/simple_animal/hostile/headcrab/poison)
	var/type_to_spawn = pick(spawn_types)
	var/mob/living/simple_animal/hostile/headcrab/B = new type_to_spawn(get_turf(src))
	var/list/birth_sounds = list('sound/creatures/gonarch_birth1.ogg', 'sound/creatures/gonarch_birth2.ogg', 'sound/creatures/gonarch_birth3.ogg')
	var/chosen_sound = pick(birth_sounds)
	playsound(get_turf(src), chosen_sound, 200, 1, 8)
	if(spawn_as_children)
		children += B
		time_last_babies = world.time
		visible_message("<span class='warning'>[B] crawls out of [src]!</span>")

/mob/living/simple_animal/hostile/headcrab/gonarch/proc/make_headcrabs()
	listclearnulls(children)
	if(world.time > time_last_babies + gonarch_headcrab_spawn_frequency && length(children) < desired_child_count)
		spawn_headcrabs()


/mob/living/simple_animal/hostile/headcrab/gonarch/proc/do_gonarch_screech(light_range, light_chance, camera_range, camera_chance)
	playsound(get_turf(src), 'sound/creatures/gonarch_initialise.ogg', 200, 1, 15, null, null, null, FALSE, TRUE)
	for(var/obj/machinery/light/L in range(light_range, src))
		if(L.on && prob(light_chance))
			L.break_light_tube()
	for(var/obj/machinery/camera/C in range(camera_range, src))
		if(C.status && prob(camera_chance))
			C.toggle_cam(src, 0)

#undef MODE_REST
#undef MODE_DEFENDING
#undef MODE_RETURNING
#undef MODE_NEWHOME
#undef MODE_RAMPAGE
