/obj/item/biocore
	name = "biocore"
	desc = "Острое биоядро с живым организмом внутри. Оно пульсирует и ответно реагирует толчками на каждые взаимодействия."
	icon = 'modular_ss220/antagonists/icons/guns/vox_guns.dmi'
	icon_state = "biocore"
	item_state = "cottoncandy_purple"

	var/mob/living/mob_spawner_type = /mob/living/simple_animal/hostile/creature
	var/spawn_amount = 1	// сколько в одном ядре
	var/is_spin = TRUE

	// Дополнительные эффекты при втыкании в гуманоида
	var/stun = 0
	var/weaken = 5 SECONDS
	var/knockdown = 2 SECONDS
	var/paralyze = 0
	var/irradiate = 0
	var/stutter = 5 SECONDS
	var/slur = 0
	var/eyeblur = 0
	var/drowsy = 0
	var/stamina = 30
	var/jitter = 10 SECONDS
	throwforce = 20
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/biocore/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback)
	playsound(loc,'sound/weapons/bolathrow.ogg', 50, TRUE)
	. = ..()

/obj/item/biocore/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	spawn_mobs()
	hurt_impact(hit_atom)

/obj/item/biocore/AltClick(mob/user)
	. = ..()
	spawn_mobs()

/obj/item/biocore/proc/spawn_mobs()
	var/turf/T = get_turf(src)
	for(var/i in 1 to spawn_amount)
		var/atom/movable/x = new mob_spawner_type(T)
		x.admin_spawned = admin_spawned
		if(prob(50))
			for(var/j = 1, j <= rand(1, 3), j++)
				step(x, pick(NORTH,SOUTH,EAST,WEST))
	do_sparks(5, TRUE, T)
	qdel(src)

/obj/item/biocore/proc/hurt_impact(atom/hit_atom)
	if(isliving(hit_atom))
		var/mob/living/L = hit_atom
		L.apply_effects(stun, weaken, knockdown, paralyze, irradiate, slur, stutter, eyeblur, drowsy, 0, stamina, jitter)


// ============== Ядра ==============

/obj/item/biocore/viscerator
	name = "biocore (viscerator)"
	spawn_amount = 3
	mob_spawner_type = /mob/living/simple_animal/hostile/viscerator/vox

/obj/item/biocore/stamina
	name = "biocore (stakikamka)"
	spawn_amount = 3
	mob_spawner_type = /mob/living/simple_animal/hostile/viscerator/vox/stamina

/obj/item/biocore/acid
	name = "biocore (acikikid)"
	spawn_amount = 1
	mob_spawner_type = /mob/living/simple_animal/hostile/viscerator/vox/acid

/obj/item/biocore/kusaka
	name = "biocore (kusakika)"
	spawn_amount = 4
	mob_spawner_type = /mob/living/simple_animal/hostile/viscerator/vox/kusaka

/obj/item/biocore/taran
	name = "biocore (tarakikan)"
	spawn_amount = 1
	mob_spawner_type = /mob/living/simple_animal/hostile/viscerator/vox/taran

/obj/item/biocore/tox
	name = "biocore (toxikikic)"
	spawn_amount = 3
	mob_spawner_type = /mob/living/simple_animal/hostile/viscerator/vox/tox
