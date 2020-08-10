#define GONARCH_MODE_REST 1
#define GONARCH_MODE_DEFENDING 2
#define GONARCH_MODE_RETURNING 3
#define GONARCH_MODE_NEWHOME 4
#define GONARCH_MODE_RAMPAGE 5

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
		if(!is_zombie && isturf(loc) && can_zombify)
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
				playsound(src, pick(speak), 200, 1)

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
	move_to_delay = 5
	speed = 1
	attacktext = "slashes"
	speak_emote = list("hisses")
	robust_searching = 1
	obj_damage = 200
	stat_attack = CONSCIOUS // They don't care for killing. They want their peace.
	armour_penetration = 5
	attack_sound = 'sound/creatures/gonarch_attack.ogg' //TODO maybe find a better sound. Something slashing maybe.
	death_sound = 'sound/creatures/gonarch_die.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	stop_automated_movement_when_pulled = 0
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	vision_range = 9
	aggro_vision_range = 9
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	mob_size = MOB_SIZE_LARGE
	layer = LARGE_MOB_LAYER //Looks weird with them slipping under mineral walls and cameras and shit otherwise
	mouse_opacity = MOUSE_OPACITY_OPAQUE // Easier to click on in melee, they're giant targets anyway
	//It has so many vars, to enable admins to change its behaviour on the fly. This is also the reason why its statemachine uses a lot of proc calls, so admins can call these manually.
	can_zombify = FALSE
	/// The Gonarch Standard Vision Range. As these are altered during the return state of the gonarch, a copy is saved here.
	var/gonarch_standard_vision_range = 9
	/// The Gonarch Aggro Vision Range. As these are altered during the return state of the gonarch, a copy is saved here.
	var/gonarch_aggro_vision_range = 9
	/// The Gonarch Standard Speed. As these are altered during the return state of the gonarch, a copy is saved here.
	var/gonarch_standard_speed = 2
	/// The home nest area is the whole area that the gonarch considers its nest. We save both the turf and the area, to allow the Gonarch to wander the area, rather than guarding a fixed spot.
	var/area/home_nest_area
	/// The home nest turf is the turf in an area that the Gonarch will walk back towards to find its nest.
	var/turf/home_nest_turf
	/// Homesick goes up when the Gonarch is not in its next. This is checked via an Area Check. If it is too high, it will cause the gonarch to go home. And if that turns too high (based on the rampage trigger, it will cause the gonarch to scream, spawn 4 headcrabs and quickly seek a new home.)
	var/homesick = 0
	/// The Rampage trigger is the amount of homesick that the gonarch is willing to gather before it goes into the rampage state. Then it will use its stunning scream, spawn 4 headcrabs and quickly seek a new home
	var/gonarch_rampage_trigger = 30
	/// The current mode its statemachine is in. Currently it has: Rest, Defending, Returning and Newhome (Looking for a new home) as well as Rampage.
	var/mode = GONARCH_MODE_REST
	/// The Gonarch Children list is be used to see how many headcrabs it has born. - It will be created with LazyAdd later.
	var/list/gonarch_children = null
	/// The Maximum amount of Children that the Gonarch will create. It also checks if its babies died so ultimately will always produce headcrabs up to this number.
	var/desired_child_count = 10
	/// The world.time that it last succesfully created a headcrab on as well as the spawn frequency. These are currently set to 1 every minute.
	var/time_last_babies = 0
	/// The Spawn frequency of the headcrabs. Currently its set to 1 every minute.
	var/gonarch_headcrab_spawn_frequency = 600
	/// The Frustration goes up, if the Gonarch makes no progress getting to its home. If it reaches the limit designated it will start to destroy more, but also cause more homesick.
	var/frustration = 0
	/// The limit of frustration it accepts before starting to destroy more stuff around it.
	var/frustration_limit = 3
	/// The range in which it looks for a suitable nest.
	var/gonarch_nestfind_range = 13
	/// The Screeching Range defines until what range carbons are effected by its stunning screen.
	var/gonarch_screech_range = 8
	/// This tracks how many times it looked for a new home, and sets a limit to its attempts. If this limit is reached, even rooms with light are now okay for the gonarch to use.
	var/gonarch_finding_home_attempts = 0
	/// The amount of attempts it is willing to look for a new home. If it reaches this number, the Gonarch will also consider areas with lights as its new breeding ground.
	var/gonarch_finding_home_limit_attempts = 2
	/// These are the soundlists of the gonarch. They are created null and will be filled when the gonarch is spawned to save memory and the hidden init proc.
	var/list/gonarch_soundlist_rampage = null
	/// These are the soundlists of the gonarch. They are created null and will be filled when the gonarch is spawned to save memory and the hidden init proc.
	var/list/gonarch_soundlist_return = null
	/// These are the soundlists of the gonarch. They are created null and will be filled when the gonarch is spawned to save memory and the hidden init proc.
	var/list/gonarch_soundlist_initialise = null
	/// These are the soundlists of the gonarch. They are created null and will be filled when the gonarch is spawned to save memory and the hidden init proc.
	var/list/gonarch_soundlist_birth = null
	/// These are the soundlists of the gonarch. They are created null and will be filled when the gonarch is spawned to save memory and the hidden init proc.
	var/list/gonarch_soundlist_defend = null

/// We need to adjust it's AI to ensure it never goes into AI_IDLE or AI_Z_IDLE or AI_OFF - To ensure it continues to produce headcrabs and follows its statemachine actions.

/mob/living/simple_animal/hostile/headcrab/gonarch/consider_wakeup()
	toggle_ai(AI_ON)

/// We need to adjust it's AI to ensure it never goes into AI_IDLE or AI_Z_IDLE or AI_OFF - To ensure it continues to produce headcrabs and follows its statemachine actions.
/mob/living/simple_animal/hostile/headcrab/gonarch/AIShouldSleep(var/list/possible_targets)
    FindTarget(possible_targets, 1)
    return FALSE

/mob/living/simple_animal/hostile/headcrab/gonarch/Initialize()
	. = ..()
	//Sound List Creation
	gonarch_soundlist_rampage = list('sound/creatures/gonarch_rampage.ogg')
	gonarch_soundlist_return = list('sound/creatures/gonarch_return.ogg')
	gonarch_soundlist_initialise = list('sound/creatures/gonarch_initialise.ogg')
	gonarch_soundlist_birth = list('sound/creatures/gonarch_birth1.ogg', 'sound/creatures/gonarch_birth2.ogg', 'sound/creatures/gonarch_birth3.ogg')
	gonarch_soundlist_defend = list('sound/creatures/gonarch_defending.ogg')
	home_nest_area = get_area(src)
	home_nest_turf = get_turf(src)
	do_gonarch_screech(8, 100, 8, 100)

/mob/living/simple_animal/hostile/headcrab/gonarch/handle_automated_action()
	. = ..()
	if(!.)
		return

	if(home_nest_area == get_area(src) && mode != GONARCH_MODE_DEFENDING)
		mode_switch(GONARCH_MODE_REST)
	else
		homesick++

	//combat
	if(target && target != home_nest_turf && mode != GONARCH_MODE_RAMPAGE && mode != GONARCH_MODE_RETURNING) //We do not have a fight while rampage is on or while we return to base.
		//we are in combat now, guaranteed.
		//Is our Homesick too high to go rampage and leave?
		if(homesick >= gonarch_rampage_trigger)
			mode_switch(GONARCH_MODE_RAMPAGE, gonarch_soundlist_rampage)
		else
			mode_switch(GONARCH_MODE_DEFENDING, gonarch_soundlist_defend)
		return

	//out of combat
	if(homesick >= gonarch_rampage_trigger && mode != GONARCH_MODE_RAMPAGE)
		mode_switch(GONARCH_MODE_RAMPAGE, gonarch_soundlist_rampage)
		return
	switch(mode)
		if(GONARCH_MODE_REST)		// idle
			gonarch_rest()
		if(GONARCH_MODE_RETURNING)		// returning home
			gonarch_return()
		if(GONARCH_MODE_NEWHOME)		// Seeking new home
			gonarch_newhome()
		if(GONARCH_MODE_RAMPAGE)		// Cannot find nest, frustration at max - rampage
			gonarch_rampage()
		if(GONARCH_MODE_DEFENDING) //If it goes down here, there is no target anymore. And it should return.
			mode_switch(GONARCH_MODE_RETURNING, gonarch_soundlist_return)

/mob/living/simple_animal/hostile/headcrab/gonarch/proc/mode_switch(mode_to_switch, sound_to_play, clear_targets = TRUE)
	if(mode_to_switch && mode_to_switch != mode)
		mode = mode_to_switch
		if(clear_targets)
			LoseTarget()
		if(sound_to_play)
			var/sound_picked = pick(sound_to_play)
			playsound(src, sound_picked, 200, 1, 15, pressure_affected = FALSE)

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
			mode_switch(GONARCH_MODE_RETURNING, gonarch_soundlist_return)

/mob/living/simple_animal/hostile/headcrab/gonarch/proc/gonarch_return()
	speed = -1
	var/turf/olddist = get_dist(src, home_nest_turf)
	step_towards(src, home_nest_turf, speed)
	target = home_nest_turf
	if(get_dist(src, target) >= olddist)
		frustration++
		if(frustration > frustration_limit)
			DestroyPathToTarget()
			homesick++
	else
		frustration = 0

/mob/living/simple_animal/hostile/headcrab/gonarch/proc/gonarch_newhome()
	var/list/turfs = list()
	var/list/turfs_in_range = range(src, 4)
	for(var/turf/T in range(src, gonarch_nestfind_range))
		if(T in turfs_in_range)
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
	mode_switch(GONARCH_MODE_RETURNING, gonarch_soundlist_return)

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
		C.Stun(12)
		C.Jitter(150)
	var/i //Workaround to avoid compiler complaints and use faster for-loops
	for(i in 1 to 4)
		spawn_headcrabs(FALSE)
	for(var/obj/structure/window/W in view(gonarch_screech_range))
		W.deconstruct(FALSE)
	mode_switch(GONARCH_MODE_NEWHOME, gonarch_soundlist_initialise)

/mob/living/simple_animal/hostile/headcrab/gonarch/proc/spawn_headcrabs(spawn_as_children = TRUE)
	var/list/spawn_types = list(/mob/living/simple_animal/hostile/headcrab, /mob/living/simple_animal/hostile/headcrab/fast, /mob/living/simple_animal/hostile/headcrab/poison)
	var/type_to_spawn = pick(spawn_types)
	var/mob/living/simple_animal/hostile/headcrab/B = new type_to_spawn(get_turf(src))
	var/chosen_sound = pick(gonarch_soundlist_birth)
	playsound(src, chosen_sound, 200, TRUE, 8)
	if(spawn_as_children)
		LAZYADD(gonarch_children, B)
		time_last_babies = world.time
		visible_message("<span class='warning'>[B] crawls out of [src]!</span>")

/mob/living/simple_animal/hostile/headcrab/gonarch/proc/make_headcrabs()
	listclearnulls(gonarch_children)
	if(world.time > time_last_babies + gonarch_headcrab_spawn_frequency && length(gonarch_children) < desired_child_count)
		spawn_headcrabs()


/mob/living/simple_animal/hostile/headcrab/gonarch/proc/do_gonarch_screech(light_range, light_chance, camera_range, camera_chance)
	playsound(src, gonarch_soundlist_initialise, 200, TRUE, 15, pressure_affected = FALSE)
	for(var/obj/machinery/light/L in range(light_range, src))
		if(L.on && prob(light_chance))
			L.break_light_tube()
	for(var/obj/machinery/camera/C in range(camera_range, src))
		if(C.status && prob(camera_chance))
			C.toggle_cam(src, 0)

#undef GONARCH_MODE_REST
#undef GONARCH_MODE_DEFENDING
#undef GONARCH_MODE_RETURNING
#undef GONARCH_MODE_NEWHOME
#undef GONARCH_MODE_RAMPAGE
