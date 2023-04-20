/obj/effect/ebeam/chain
	name = "lightning chain"
	layer = LYING_MOB_LAYER

/mob/living/simple_animal/hostile/guardian/beam
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "бьёт током"
	melee_damage_type = BURN
	attack_sound = 'sound/machines/defib_zap.ogg'
	damage_transfer = 0.6
	range = 7
	tts_seed = "Archmage"
	playstyle_string = "Как тип <b>Молния</b>, вы будете иметь связующую смертоносную цепь молнии к своему призывателю. Цепь молний поражает всех, кто находится рядом с ней. Так же у вас есть заклинание цепной молнии, оглушающее врагов по площади."
	magic_fluff_string = "...и вытаскиваете Теслу, шокирующий, смертоносный источник энергии."
	tech_fluff_string = "Последовательность загрузки завершена. Модуль молний активны. Голопаразитный рой в сети."
	bio_fluff_string = "Ваш рой скарабеев заканчивает мутировать и оживает, готовый наэлектризовать ваших врагов."
	var/datum/beam/summonerchain
	var/list/enemychains = list()
	var/successfulshocks = 0

/mob/living/simple_animal/hostile/guardian/beam/Initialize(mapload, mob/living/host)
	. = ..()
	if(!summoner)
		return
	if(!(NO_SHOCK in summoner.mutations))
		summoner.mutations.Add(NO_SHOCK)

/mob/living/simple_animal/hostile/guardian/beam/New()
	..()
	AddSpell(new /obj/effect/proc_holder/spell/targeted/lightning/guardian)

/mob/living/simple_animal/hostile/guardian/beam/electrocute_act(shock_damage, obj/source, siemens_coeff = 1, safety = FALSE, override = FALSE, tesla_shock = FALSE, illusion = FALSE, stun = TRUE)
	return FALSE //You are lightning, you should not be hurt by such things.

/mob/living/simple_animal/hostile/guardian/beam/Manifest()
	..()
	if(summoner)
		summonerchain = Beam(summoner, "lightning[rand(1,12)]", 'icons/effects/effects.dmi', time=INFINITY, maxdistance=INFINITY, beam_type=/obj/effect/ebeam/chain)
	while(loc != summoner)
		if(successfulshocks > 5)
			successfulshocks = 0
		if(shockallchains())
			successfulshocks++
		sleep(3)

/mob/living/simple_animal/hostile/guardian/beam/Recall()
	. = ..()
	if(.)
		removechains()

/mob/living/simple_animal/hostile/guardian/beam/proc/cleardeletedchains()
	if(summonerchain && QDELETED(summonerchain))
		summonerchain = null
	if(enemychains.len)
		for(var/chain in enemychains)
			var/datum/cd = chain
			if(!chain || QDELETED(cd))
				enemychains -= chain

/mob/living/simple_animal/hostile/guardian/beam/proc/shockallchains()
	. = 0
	cleardeletedchains()
	if(summoner)
		if(!summonerchain)
			summonerchain = Beam(summoner, "lightning[rand(1,12)]", 'icons/effects/effects.dmi', time=INFINITY, maxdistance=INFINITY, beam_type=/obj/effect/ebeam/chain)
		. += chainshock(summonerchain)
	if(enemychains.len)
		for(var/chain in enemychains)
			. += chainshock(chain)

/mob/living/simple_animal/hostile/guardian/beam/proc/removechains()
	if(summonerchain)
		QDEL_NULL(summonerchain)
	if(enemychains.len)
		for(var/chain in enemychains)
			qdel(chain)
		enemychains = list()

/mob/living/simple_animal/hostile/guardian/beam/proc/chainshock(datum/beam/B)
	. = 0
	var/list/turfs = list()
	for(var/E in B.elements)
		var/obj/effect/ebeam/chainpart = E
		if(chainpart && chainpart.x && chainpart.y && chainpart.z)
			var/turf/T = get_turf_pixel(chainpart)
			turfs |= T
			if(T != get_turf(B.origin) && T != get_turf(B.target))
				for(var/turf/TU in circlerange(T, 1))
					turfs |= TU
	for(var/turf in turfs)
		var/turf/T = turf
		for(var/mob/living/L in T)
			if(L.stat != DEAD && L != src && L != summoner)
				var/mob/living/simple_animal/hostile/guardian/G = L
				if(istype(G) && G.summoner == summoner)
					continue
				if(successfulshocks > 4)
					L.visible_message(
						"<span class='danger'>[L] was shocked by the lightning chain!</span>", \
						"<span class='userdanger'>You are shocked by the lightning chain!</span>", \
						"<span class='italics'>You hear a heavy electrical crack.</span>" \
					)
				L.adjustFireLoss(3)
				. = 1

/mob/living/simple_animal/hostile/guardian/beam/death(gibbed)
    if(summoner && (NO_SHOCK in summoner.mutations))
        summoner.mutations.Remove(NO_SHOCK)
    return ..()
