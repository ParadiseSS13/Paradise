/mob/living/simple_animal/hostile/guardian/fire
	melee_damage_lower = 15
	melee_damage_upper = 15
	melee_damage_type = BURN
	attack_sound = 'sound/items/welder.ogg'
	attacktext = "жжёт"
	damage_transfer = 0.8
	range = 10
	playstyle_string = "Как <b>Хаос</b>, вы обладаете лишь легким сопротивлением урону, но поджигаете любого врага, с которым столкнетесь. Кроме того, ваши атаки ближнего боя случайным образом телепортируют врагов. У вас есть мощное заклинание, призывающее сильнейшие галлюцинации."
	environment_smash = 1
	magic_fluff_string = "....и вытаскиваете Колдуна, создателя бесконечного хаоса!"
	tech_fluff_string = "Последовательность загрузки завершена. Модуль контроля толпы активирован. Рой голопаразитов активирован."
	bio_fluff_string = "Ваш рой скарабеев заканчивает мутировать и оживает, готовый сеять хаос в произвольном порядке."
	var/toggle = FALSE

/mob/living/simple_animal/hostile/guardian/fire/Life(seconds, times_fired) //Dies if the summoner dies
	..()
	if(summoner)
		summoner.ExtinguishMob()
		summoner.adjust_fire_stacks(-20)

/mob/living/simple_animal/hostile/guardian/fire/New()
	. = ..()
	src.AddSpell(new /obj/effect/proc_holder/spell/aoe/guardian_hallucination(summoner))

/mob/living/simple_animal/hostile/guardian/fire/AttackingTarget()
	. = ..()
	if(prob(45))
		if(ismovable(target))
			var/atom/movable/M = target
			if(!M.anchored && M != summoner)
				new /obj/effect/temp_visual/guardian/phase/out(get_turf(M))
				var/turf/T = get_turf(M)
				do_teleport(M, M, 10)
				investigate_log("[key_name_log(src)] teleported [key_name_log(target)] from [COORD(T)] to [COORD(M)].", INVESTIGATE_TELEPORTATION)
				new /obj/effect/temp_visual/guardian/phase/out(get_turf(M))
				summoner.AdjustHallucinate(10 SECONDS)

/mob/living/simple_animal/hostile/guardian/fire/Crossed(AM as mob|obj, oldloc)
	..()
	collision_ignite(AM)

/mob/living/simple_animal/hostile/guardian/fire/Bumped(atom/movable/moving_atom)
	..()
	collision_ignite(moving_atom)

/mob/living/simple_animal/hostile/guardian/fire/Bump(AM as mob|obj)
	..()
	collision_ignite(AM)

/mob/living/simple_animal/hostile/guardian/fire/proc/collision_ignite(AM as mob|obj)
	if(isliving(AM))
		var/mob/living/M = AM
		if(AM != summoner && M.fire_stacks < 7)
			M.fire_stacks = 7
			M.IgniteMob()

/mob/living/simple_animal/hostile/guardian/fire/Bump(AM as mob|obj)
	..()
	collision_ignite(AM)


/obj/effect/proc_holder/spell/aoe/guardian_hallucination
	name = "Волна галлюцинаций"
	desc = "Призовите самый темный страх на ваших жертв. Хозяин невосприимчив к эффекту."
	action_icon_state = "blight"
	action_background_icon_state = "bg_spell"
	base_cooldown = 12 SECONDS
	clothes_req = FALSE
	human_req = FALSE
	phase_allowed = TRUE
	var/mob/living/summoner = null
	var/list/stunning_hallucinations = list("singulo", "koolaid", "fake")
	aoe_range = 10


/obj/effect/proc_holder/spell/aoe/guardian_hallucination/New(mob/living/summoned_by)
	. = ..()
	summoner = summoned_by


/obj/effect/proc_holder/spell/aoe/guardian_hallucination/Destroy()
	summoner = null
	return ..()


/obj/effect/proc_holder/spell/aoe/guardian_hallucination/create_new_targeting()
	var/datum/spell_targeting/aoe/turf/T = new()
	T.range = aoe_range
	T.use_turf_of_user = TRUE
	return T


/obj/effect/proc_holder/spell/aoe/guardian_hallucination/cast(list/targets, mob/user = usr)
	for(var/turf/T in targets)
		for(var/mob/target in T.contents)
			if(iscarbon(target) && target != summoner)
				var/mob/living/carbon/M = target
				var/random_hallucination = pick(stunning_hallucinations)
				M.AdjustHallucinate(50 SECONDS)
				M.hallucinate_living(random_hallucination)
			else if(issilicon(target))
				var/mob/living/silicon/silicon = target
				to_chat(silicon, "<span class='warning'><b>ERROR $!(@ ERROR )#^! SENSORY OVERLOAD \[$(!@#</b></span>")
				silicon << 'sound/misc/interference.ogg'
				playsound(silicon, 'sound/machines/warning-buzzer.ogg', 50, 1)
				do_sparks(5, 1, silicon)
				silicon.Weaken(6 SECONDS)

