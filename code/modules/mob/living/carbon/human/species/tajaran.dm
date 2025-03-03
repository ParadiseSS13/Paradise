/datum/species/tajaran
	name = "Tajaran"
	name_plural = "Tajaran"
	icobase = 'icons/mob/human_races/r_tajaran.dmi'
	language = "Siik'tajr"
	tail = "tajtail"
	skinned_type = /obj/item/stack/sheet/fur
	unarmed_type = /datum/unarmed_attack/claws

	blurb = "Таяран - вид всеядных млекопитающих, имеющих внешнее сходство с земными кошачьими, родом происходящие с богатой минералами планеты Адомай. \
	Они появились на галактической арене в результате обнаружения экспедиционным флотом проекта \"Новые Горизонты\", после освобождения из рабства были приняты частичные условия интеграции в Человеко-Скреллианский Альянс.<br/><br/> \
	В их религиозной практике преобладают учения С'рандарра и солнечная иконография, \
	сами Таяры часто говорят о себе в третьем лице из-за отсутствия обращений от первого лица в их родном языке."

	cold_level_1 = 240
	cold_level_2 = 180
	cold_level_3 = 100

	heat_level_1 = 340
	heat_level_2 = 380
	heat_level_3 = 440

	primitive_form = /datum/species/monkey/tajaran

	species_traits = list(LIPS)
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_TAIL | HAS_HEAD_ACCESSORY | HAS_MARKINGS | HAS_SKIN_COLOR | TAIL_WAGGING | TAIL_OVERLAPPED
	dietflags = DIET_OMNI
	taste_sensitivity = TASTE_SENSITIVITY_SHARP
	reagent_tag = PROCESS_ORG

	flesh_color = "#b5a69b"
	base_color = "#424242"
	butt_sprite = "tajaran"

	has_organ = list(
		"heart" =    /obj/item/organ/internal/heart/tajaran,
		"lungs" =    /obj/item/organ/internal/lungs/tajaran,
		"liver" =    /obj/item/organ/internal/liver/tajaran,
		"kidneys" =  /obj/item/organ/internal/kidneys/tajaran,
		"brain" =    /obj/item/organ/internal/brain/tajaran,
		"appendix" = /obj/item/organ/internal/appendix,
		"eyes" =     /obj/item/organ/internal/eyes/tajaran /*Most Tajara see in full colour as a result of genetic augmentation, although it cost them their darksight (darksight = 2)
															unless they choose otherwise by selecting the colourblind disability in character creation (darksight = 8 but colourblind).*/
		)

	allowed_consumed_mobs = list(/mob/living/simple_animal/mouse, /mob/living/simple_animal/chick, /mob/living/simple_animal/butterfly, /mob/living/simple_animal/parrot, /mob/living/simple_animal/hostile/poison/bees)

	suicide_messages = list(
		"is attempting to bite their tongue off!",
		"is jamming their claws into their eye sockets!",
		"is twisting their own neck!",
		"is holding their breath!")
	autohiss_basic_map = list(
			"r" = list("rr", "rrr", "rrrr")
		)
	autohiss_exempt = list("Siik'tajr")

	plushie_type = /obj/item/toy/plushie/grey_cat

/datum/species/tajaran/handle_death(gibbed, mob/living/carbon/human/H)
	H.stop_tail_wagging()
