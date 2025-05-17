#define MORPHS_ANNOUNCE_THRESHOLD 7

GLOBAL_VAR_INIT(MORPHS_NUMBER, 0)
GLOBAL_VAR_INIT(MORPHS_ANNOUNCED, FALSE)

/mob/living/simple_animal/hostile/morph/Initialize(mapload)
	. = ..()
	GLOB.MORPHS_NUMBER++
	if((GLOB.MORPHS_NUMBER > MORPHS_ANNOUNCE_THRESHOLD) && !GLOB.MORPHS_ANNOUNCED)
		GLOB.major_announcement.Announce("На борту [station_name()] обнаружены множественные биологические сигнатуры морфов. Всему персоналу надлежит немедленно приступить к сдерживанию.", "ВНИМАНИЕ: Обнаружена биоугроза.", 'sound/effects/siren-spooky.ogg', new_sound2 = 'sound/AI/outbreak_xeno.ogg')
		GLOB.MORPHS_ANNOUNCED = TRUE


/mob/living/simple_animal/hostile/morph/death(gibbed)
	. = ..()

	if(.)
		GLOB.MORPHS_NUMBER--
