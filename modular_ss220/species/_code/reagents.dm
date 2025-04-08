/obj/item/seeds/cabbage/Initialize(mapload)
	. = ..()
	reagents_add += list("cabbagilium" = 0.05)

/datum/reagent/cabbagilium
	name = "Cabbagilium"
	id = "cabbagilium"
	description = "An unusual reagent that can be found in cabbages and helpful in toxic treatments."
	reagent_state = LIQUID
	color = "#335517"
	taste_description = "awful but healthy"
	goal_department = "Science"
	goal_difficulty = REAGENT_GOAL_SKIP
	var/clone_damage_heal = -0.02

/datum/reagent/cabbagilium/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustCloneLoss(clone_damage_heal * REAGENTS_EFFECT_MULTIPLIER, FALSE)
	return ..() | update_flags

//Расширение на химикаты - новый химикат для серпентидов
//Химикат позволяет ускорять в 2 раза действия серпентидов (погрузка людей/ящиков, активация клинков)
//Для остальных видов он ускоряет действия при движении по прямой (если не двигаться более 1 секунды или сменить направление, бонус сбросится)
//Атакует сердце, мощнее мефедрона

#define SERPADRONE_SCREEN_FILTER "serpadrone_screen_filter"
#define SERPADRONE_SCREEN_BLUR "serpadrone_screen_blur"

/datum/reagent/serpadrone
	name = "Serpadrone"
	id = "serpadrone"
	description = "An unsual reagent that allows serptentids to haste their long-term actions and speed up them."
	reagent_state = LIQUID
	color = "#ff002b"
	taste_description = "television static"
	metabolization_rate = 0.1
	process_flags = ORGANIC
	var/last_move_count = 0
	var/last_move = null

/datum/reagent/serpadrone/on_mob_add(mob/living/carbon/L)
	RegisterSignal(L, COMSIG_MOVABLE_MOVED, PROC_REF(on_movement))
	RegisterSignal(L, COMSIG_HUMAN_CREATE_MOB_HUD, PROC_REF(no_hud_cheese))
	var/mob/living/carbon/human/H = L
	if(isserpentid(H))
		var/datum/species/spicie = H.dna.species
		spicie.action_mult = spicie.action_mult / 2
	if(!L.hud_used)
		return
	var/atom/movable/plane_master_controller/game_plane_master_controller = L.hud_used?.plane_master_controllers[PLANE_MASTERS_GAME]
	var/static/list/col_filter_green = list(1,0,0,0, \
		0, 0.66, 0, 0, \
		0, 0, 0.66, 0, \
		0, 0, 0, 1)
	game_plane_master_controller.add_filter(SERPADRONE_SCREEN_FILTER, 10, color_matrix_filter(col_filter_green, FILTER_COLOR_RGB))
	game_plane_master_controller.add_filter(SERPADRONE_SCREEN_BLUR, 1, list("type" = "radial_blur", "size" = 0.02))
	last_move_count = 0
	last_move = null

/datum/reagent/serpadrone/on_mob_delete(mob/living/carbon/L)
	UnregisterSignal(L, COMSIG_MOVABLE_MOVED)
	REMOVE_TRAIT(L, TRAIT_GOTTAGOFAST, id)
	REMOVE_TRAIT(L, TRAIT_GOTTAGONOTSOFAST, id)
	var/mob/living/carbon/human/H = L
	if(isserpentid(H))
		var/datum/species/spicie = H.dna.species
		spicie.action_mult = spicie.action_mult * 2
	if(!L.hud_used)
		return
	var/atom/movable/plane_master_controller/game_plane_master_controller = L.hud_used?.plane_master_controllers[PLANE_MASTERS_GAME]
	game_plane_master_controller.remove_filter(SERPADRONE_SCREEN_FILTER)
	game_plane_master_controller.remove_filter(SERPADRONE_SCREEN_BLUR)
	last_move_count = 0
	last_move = null

/// Leaves an afterimage behind the mob when they move
/datum/reagent/serpadrone/proc/on_movement(mob/living/carbon/L, atom/old_loc)
	SIGNAL_HANDLER
	if(HAS_TRAIT(L, TRAIT_IMMOBILIZED)) //No, dead people floating through space do not need afterimages
		return NONE
	if(last_move == L.last_movement_dir && world.time - L.last_movement < 10)
		if(last_move_count >= 5)
			if(!HAS_TRAIT(L, TRAIT_GOTTAGONOTSOFAST))
				ADD_TRAIT(L, TRAIT_GOTTAGONOTSOFAST, id)
			if(last_move_count >= 15)
				REMOVE_TRAIT(L, TRAIT_GOTTAGONOTSOFAST, id)
				ADD_TRAIT(L, TRAIT_GOTTAGOFAST, id)
			else
				last_move_count += 1
		else
			last_move_count += 1
	else
		last_move_count = 0
		REMOVE_TRAIT(L, TRAIT_GOTTAGOFAST, id)
		REMOVE_TRAIT(L, TRAIT_GOTTAGONOTSOFAST, id)
	new /obj/effect/temp_visual/decoy/serpadrone_afterimage(old_loc, L, 0.75 SECONDS)
	last_move = L.last_movement_dir

/// So. If a person changes up their hud settings (Changing their ui theme), the visual effects for this reagent will break, and they will be able to see easily. This 3 part proc waits for the plane controlers to be setup, and over 2 other procs, rengages the visuals
/datum/reagent/serpadrone/proc/no_hud_cheese(mob/living/carbon/L)
	SIGNAL_HANDLER
	addtimer(CALLBACK(src, PROC_REF(no_hud_cheese_2), L), 2 SECONDS) //Calling it instantly will not work, need to give it a moment

/// This part of the anticheese sets up the basic visual effects normally setup when the reagent gets into your system.
/datum/reagent/serpadrone/proc/no_hud_cheese_2(mob/living/carbon/L) //Basically if you change the UI you would remove the visuals. This fixes that.
	var/atom/movable/plane_master_controller/game_plane_master_controller = L.hud_used?.plane_master_controllers[PLANE_MASTERS_GAME]
	game_plane_master_controller.remove_filter(SERPADRONE_SCREEN_FILTER)
	game_plane_master_controller.remove_filter(SERPADRONE_SCREEN_BLUR)

	var/static/list/col_filter_green = list(1,0,0,0, 0,0.4,0,0, 0,0,0.4,0, 0,0,0,1)
	game_plane_master_controller.add_filter(SERPADRONE_SCREEN_FILTER, 10, color_matrix_filter(col_filter_green, FILTER_COLOR_RGB))
	game_plane_master_controller.add_filter(SERPADRONE_SCREEN_BLUR, 1, list("type" = "radial_blur", "size" = 0.02))

// Temp visual that changes color for that bootleg sandevistan effect
/obj/effect/temp_visual/decoy/serpadrone_afterimage
	duration = 0.75 SECONDS
	/// The color matrix it should be at spawn
	var/list/matrix_start = list(1, 0, 0, 0, \
		0, 1, 0, 0, \
		0, 0, 1, 0, \
		0, 0, 0, 1, \
		0.8, 0, 0.1, 0)
	/// The color matrix it should be by the time it despawns
	var/list/matrix_end = list(1, 0, 0, 0, \
		0, 1, 0, 0, \
		0, 0, 1, 0, \
		0, 0, 0, 1, \
		0.75, 0, 0.75, 0)

/obj/effect/temp_visual/decoy/serpadrone_afterimage/Initialize(mapload, atom/mimiced_atom, our_duration = 0.75 SECONDS)
	duration = our_duration
	. = ..()
	color = matrix_start
	animate(src, color = matrix_end, time = duration, easing = EASE_OUT)
	animate(src, alpha = 0, time = duration, easing = EASE_OUT)

#undef SERPADRONE_SCREEN_FILTER
#undef SERPADRONE_SCREEN_BLUR

/datum/chemical_reaction/serpadrone
	name = "Serpadrone"
	id = "serpadrone"
	result = "serpadrone"
	required_reagents = list("msg" = 5, "cabbagilium" = 10)
	result_amount = 1
	mix_message = "The mixture fizzes into a vibrant red solution that doesn't stay still."
	mix_sound = 'sound/goonstation/misc/fuse.ogg'

//Пара помощников - получить количество и путь химиката по его ID в теле куклы
/mob/living/carbon/human/proc/get_chemical_value(id)
	for(var/datum/reagent/R in src.reagents.reagent_list)
		if(R.id == id)
			return R.volume
	return 0

//Пара помощников - получить количество и путь химиката по его ID в теле куклы
/mob/living/carbon/human/proc/get_chemical_path(id)
	for(var/datum/reagent/R in src.reagents.reagent_list)
		if(R.id == id)
			return R
	return null
