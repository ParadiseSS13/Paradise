/datum/species
	scream_verb = "кричит"
	var/male_cry_sound = list(
		'modular_ss220/emotes/audio/male/cry_male_1.ogg',
		'modular_ss220/emotes/audio/male/cry_male_2.ogg')
	var/female_cry_sound = list(
		'modular_ss220/emotes/audio/female/cry_female_1.ogg',
		'modular_ss220/emotes/audio/female/cry_female_2.ogg',
		'modular_ss220/emotes/audio/female/cry_female_3.ogg')
	var/male_giggle_sound = list(
		'modular_ss220/emotes/audio/male/giggle_male_1.ogg',
		'modular_ss220/emotes/audio/male/giggle_male_2.ogg')
	var/female_giggle_sound = list(
		'modular_ss220/emotes/audio/female/giggle_female_1.ogg',
		'modular_ss220/emotes/audio/female/giggle_female_2.ogg',
		'modular_ss220/emotes/audio/female/giggle_female_3.ogg',
		'modular_ss220/emotes/audio/female/giggle_female_4.ogg')
	var/male_laugh_sound = list(
		'modular_ss220/emotes/audio/male/laugh_male_1.ogg',
		'modular_ss220/emotes/audio/male/laugh_male_2.ogg',
		'modular_ss220/emotes/audio/male/laugh_male_3.ogg')
	var/female_laugh_sound = list(
		'modular_ss220/emotes/audio/female/laugh_female_1.ogg',
		'modular_ss220/emotes/audio/female/laugh_female_2.ogg',
		'modular_ss220/emotes/audio/female/laugh_female_3.ogg')
	var/male_sigh_sound = list('modular_ss220/emotes/audio/male/sigh_male.ogg')
	var/female_sigh_sound = list('modular_ss220/emotes/audio/female/sigh_female.ogg')
	var/male_moan_sound = list(
		'modular_ss220/emotes/audio/male/moan_male_1.ogg',
		'modular_ss220/emotes/audio/male/moan_male_2.ogg',
		'modular_ss220/emotes/audio/male/moan_male_3.ogg')
	var/female_moan_sound = list(
		'modular_ss220/emotes/audio/female/moan_female_1.ogg',
		'modular_ss220/emotes/audio/female/moan_female_2.ogg',
		'modular_ss220/emotes/audio/female/moan_female_3.ogg')
	var/female_gasp_sound = list(
		'modular_ss220/emotes/audio/female/gasp_female_1.ogg',
		'modular_ss220/emotes/audio/female/gasp_female_2.ogg',
		'modular_ss220/emotes/audio/female/gasp_female_3.ogg',
		'modular_ss220/emotes/audio/female/gasp_female_4.ogg',
		'modular_ss220/emotes/audio/female/gasp_female_5.ogg',
		'modular_ss220/emotes/audio/female/gasp_female_6.ogg',
		'modular_ss220/emotes/audio/female/gasp_female_7.ogg')
	gasp_sound = list(
		'modular_ss220/emotes/audio/male/gasp_male_1.ogg',
		'modular_ss220/emotes/audio/male/gasp_male_2.ogg',
		'modular_ss220/emotes/audio/male/gasp_male_3.ogg',
		'modular_ss220/emotes/audio/male/gasp_male_4.ogg',
		'modular_ss220/emotes/audio/male/gasp_male_5.ogg',
		'modular_ss220/emotes/audio/male/gasp_male_6.ogg',
		'modular_ss220/emotes/audio/male/gasp_male_7.ogg')
	male_cough_sounds = list(
		'modular_ss220/emotes/audio/male/cough_male_1.ogg',
		'modular_ss220/emotes/audio/male/cough_male_2.ogg',
		'modular_ss220/emotes/audio/male/cough_male_3.ogg')
	female_cough_sounds = list(
		'modular_ss220/emotes/audio/female/cough_female_1.ogg',
		'modular_ss220/emotes/audio/female/cough_female_2.ogg',
		'modular_ss220/emotes/audio/female/cough_female_3.ogg')
	female_sneeze_sound = 'modular_ss220/emotes/audio/female/sneeze_female.ogg'
	suicide_messages = list(
		"пытается откусить себе язык!",
		"выдавливает свои глазницы большими пальцами!",
		"сворачивает себе шею!",
		"задерживает дыхание!")

/datum/species/diona
	suicide_messages = list(
		"теряет ветви!",
		"вытаскивает из тайника бутыль с гербицидом и делает большой глоток!",
		"разваливается на множество нимф!")

/datum/species/drask
	autohiss_basic_map = list(
			"o" = list("oo", "ooo"),
			"u" = list("uu", "uuu"),
			"о" = list("оо", "ооо"),
			"у" = list("уу", "ууу")
		)
	autohiss_extra_map = list(
			"m" = list("mm", "mmm"),
			"м" = list("мм", "ммм")
		)
	autohiss_exempt = list("Orluum")
	suicide_messages = list(
		"трёт себя до возгорания!",
		"давит пальцами на свои большие глаза!",
		"втягивает теплый воздух!",
		"задерживает дыхание!")

/datum/species/golem
	suicide_messages = list(
		"рассыпается в прах!",
		"разбивает своё тело на части!")

/datum/species/kidan
	autohiss_basic_map = list(
			"z" = list("zz", "zzz", "zzzz"),
			"v" = list("vv", "vvv", "vvvv"),
			"з" = list("зз", "ззз", "зззз"),
			"в" = list("вв", "ввв", "вввв"))
	autohiss_extra_map = list(
			"s" = list("z", "zs", "zzz", "zzsz"),
			"с" = list("з", "зс", "ззз", "ззсз"))
	autohiss_exempt = list("Chittin")

	scream_verb = "визжит"
	speech_sounds = list(
		'modular_ss220/emotes/audio/kidan/talk_kidan_1.ogg',
		'modular_ss220/emotes/audio/kidan/talk_kidan_2.ogg',
		'modular_ss220/emotes/audio/kidan/talk_kidan_3.ogg')
	speech_chance = 20
	male_scream_sound = 'modular_ss220/emotes/audio/kidan/scream_kidan.ogg'
	female_scream_sound = 'modular_ss220/emotes/audio/kidan/scream_kidan.ogg'
	male_cry_sound = list(
		'modular_ss220/emotes/audio/kidan/cry_kidan_1.ogg',
		'modular_ss220/emotes/audio/kidan/cry_kidan_2.ogg')
	female_cry_sound = list(
		'modular_ss220/emotes/audio/kidan/cry_kidan_1.ogg',
		'modular_ss220/emotes/audio/kidan/cry_kidan_2.ogg')
	male_giggle_sound = list(
		'modular_ss220/emotes/audio/kidan/giggle_kidan_1.ogg',
		'modular_ss220/emotes/audio/kidan/giggle_kidan_2.ogg')
	female_giggle_sound = list(
		'modular_ss220/emotes/audio/kidan/giggle_kidan_1.ogg',
		'modular_ss220/emotes/audio/kidan/giggle_kidan_2.ogg')
	male_laugh_sound = list(
		'modular_ss220/emotes/audio/kidan/laugh_kidan_1.ogg',
		'modular_ss220/emotes/audio/kidan/laugh_kidan_2.ogg',
		'modular_ss220/emotes/audio/kidan/laugh_kidan_3.ogg',
		'modular_ss220/emotes/audio/kidan/laugh_kidan_4.ogg')
	female_laugh_sound = list(
		'modular_ss220/emotes/audio/kidan/laugh_kidan_1.ogg',
		'modular_ss220/emotes/audio/kidan/laugh_kidan_2.ogg',
		'modular_ss220/emotes/audio/kidan/laugh_kidan_3.ogg',
		'modular_ss220/emotes/audio/kidan/laugh_kidan_4.ogg')
	male_sigh_sound = list(
		'modular_ss220/emotes/audio/kidan/sigh_kidan_1.ogg',
		'modular_ss220/emotes/audio/kidan/sigh_kidan_2.ogg')
	female_sigh_sound = list(
		'modular_ss220/emotes/audio/kidan/sigh_kidan_1.ogg',
		'modular_ss220/emotes/audio/kidan/sigh_kidan_2.ogg')
	male_moan_sound = list('modular_ss220/emotes/audio/kidan/moan_kidan.ogg')
	female_moan_sound = list('modular_ss220/emotes/audio/kidan/moan_kidan.ogg')
	male_cough_sounds = list('modular_ss220/emotes/audio/kidan/cough_kidan.ogg')
	female_cough_sounds = list('modular_ss220/emotes/audio/kidan/cough_kidan.ogg')
	male_sneeze_sound = list(
		'modular_ss220/emotes/audio/kidan/sneeze_kidan_1.ogg',
		'modular_ss220/emotes/audio/kidan/sneeze_kidan_2.ogg',
		'modular_ss220/emotes/audio/kidan/sneeze_kidan_3.ogg')
	female_sneeze_sound = list(
		'modular_ss220/emotes/audio/kidan/sneeze_kidan_1.ogg',
		'modular_ss220/emotes/audio/kidan/sneeze_kidan_2.ogg',
		'modular_ss220/emotes/audio/kidan/sneeze_kidan_3.ogg')
	male_dying_gasp_sounds = list(
		'modular_ss220/emotes/audio/kidan/dying_gasp_kidan_1.ogg',
		'modular_ss220/emotes/audio/kidan/dying_gasp_kidan_2.ogg',
		'modular_ss220/emotes/audio/kidan/dying_gasp_kidan_3.ogg')
	female_dying_gasp_sounds = list(
		'modular_ss220/emotes/audio/kidan/dying_gasp_kidan_1.ogg',
		'modular_ss220/emotes/audio/kidan/dying_gasp_kidan_2.ogg',
		'modular_ss220/emotes/audio/kidan/dying_gasp_kidan_3.ogg')
	death_sounds = 'modular_ss220/emotes/audio/kidan/deathsound_kidan.ogg'
	suicide_messages = list(
		"пытается откусить себе усики!",
		"вонзает когти в свои глазницы!",
		"сворачивает себе шею!",
		"разбивает себе панцирь",
		"протыкает себя челюстями!",
		"задерживает дыхание!")

/datum/species/machine
	suicide_messages = list(
		"отключает питание!",
		"разбивает свой монитор!",
		"выкручивает себе шею!",
		"загружает дополнительную оперативную память!",
		"замыкает свои микросхемы!",
		"блокирует свой вентиляционный порт!")

/datum/species/moth
	scream_verb = "жужжит"
	female_giggle_sound = 'modular_ss220/emotes/audio/moth/moth_chitter.ogg'
	male_giggle_sound = 'modular_ss220/emotes/audio/moth/moth_chitter.ogg'
	male_scream_sound = 'modular_ss220/emotes/audio/moth/moth_scream.ogg'
	female_scream_sound = 'modular_ss220/emotes/audio/moth/moth_scream.ogg'
	male_sneeze_sound = 'modular_ss220/emotes/audio/moth/moth_sneeze.ogg'
	female_sneeze_sound = 'modular_ss220/emotes/audio/moth/moth_sneeze.ogg'
	female_laugh_sound = 'modular_ss220/emotes/audio/moth/moth_laugh.ogg'
	male_laugh_sound = 'modular_ss220/emotes/audio/moth/moth_laugh.ogg'
	female_cough_sounds = 'modular_ss220/emotes/audio/moth/moth_cough.ogg'
	male_cough_sounds = 'modular_ss220/emotes/audio/moth/moth_cough.ogg'
	suicide_messages = list(
		"откусывает свои усики!",
		"вспарывает себе живот!",
		"отрывает себе крылья!",
		"заддерживает своё дыхание!")

/datum/species/plasmaman
	autohiss_basic_map = list(
			"s" = list("ss", "sss", "ssss"),
			"с" = list("сс", "ссс", "сссс"))

	male_scream_sound = list(
		'modular_ss220/emotes/audio/plasmaman/scream_plasmaman_1.ogg',
		'modular_ss220/emotes/audio/plasmaman/scream_plasmaman_2.ogg',
		'modular_ss220/emotes/audio/plasmaman/scream_plasmaman_3.ogg')
	female_scream_sound = list(
		'modular_ss220/emotes/audio/plasmaman/scream_plasmaman_1.ogg',
		'modular_ss220/emotes/audio/plasmaman/scream_plasmaman_2.ogg',
		'modular_ss220/emotes/audio/plasmaman/scream_plasmaman_3.ogg')
	suicide_messages = list(
		"сворачивает себе шею!",
		"впускает себе немного O2!",
		"осознает экзистенциальную проблему быть рождённым из плазмы!",
		"показывает свою истинную природу, которая оказывается плазмой!")

/datum/species/shadow
	suicide_messages = list(
		"пытается откусить себе язык!",
		"выдавливает большими пальцами себе глазницы!",
		"сворачивает себе шею!",
		"пялится на ближайший источник света!")

/datum/species/skeleton
	suicide_messages = list(
		"ломает себе кости!",
		"сваливается в кучу!",
		"разваливается!",
		"откручивает себе череп!")

/datum/species/skrell
	male_giggle_sound = 'modular_ss220/emotes/audio/skrell/giggle_male_1.ogg'
	female_giggle_sound = 'modular_ss220/emotes/audio/skrell/giggle_female_1.ogg'
	male_laugh_sound = list(
		'modular_ss220/emotes/audio/skrell/laugh_male_1.ogg',
		'modular_ss220/emotes/audio/skrell/laugh_male_2.ogg',
		'modular_ss220/emotes/audio/skrell/laugh_male_3.ogg')
	female_laugh_sound = list(
		'modular_ss220/emotes/audio/skrell/laugh_female_1.ogg',
		'modular_ss220/emotes/audio/skrell/laugh_female_2.ogg',
		'modular_ss220/emotes/audio/skrell/laugh_female_3.ogg')
	suicide_messages = list(
		"пытается откусить себе язык!",
		"выдавливает большими пальцами свои глазницы!",
		"сворачивает себе шею!",
		"задыхается словно рыба!",
		"душит себя собственными усиками!")

/datum/species/slime
	male_scream_sound = 'modular_ss220/emotes/audio/scream_jelly.ogg'
	female_scream_sound = 'modular_ss220/emotes/audio/scream_jelly.ogg'
	suicide_messages = list(
		"тает в лужу!",
		"растекается в лужу!",
		"становится растаявшим желе!",
		"вырывает собственное ядро!",
		"становится коричневым, тусклым и растекается в лужу!")

/datum/species/tajaran
	autohiss_basic_map = list(
			"r" = list("rr", "rrr", "rrrr"),
			"р" = list("рр", "ррр", "рррр"))
	autohiss_exempt = list("Siik'tajr")

	male_scream_sound = 'modular_ss220/emotes/audio/tajaran/scream_tajaran.ogg'
	female_scream_sound = 'modular_ss220/emotes/audio/tajaran/scream_tajaran.ogg'
	suicide_messages = list(
		"пытается откусить себе язык!",
		"вонзает когти себе в глазницы!",
		"сворачивает себе шею!",
		"задерживает дыхание!")

/datum/species/unathi
	autohiss_basic_map = list(
			"s" = list("ss", "sss", "ssss"),
			"с" = list("сс", "ссс", "сссс"))
	autohiss_extra_map = list(
			"x" = list("ks", "kss", "ksss"),
			"ш" = list("шш", "шшш", "шшшш"),
			"ч" = list("щ", "щщ", "щщщ"))
	autohiss_exempt = list("Sinta'unathi")

	speech_sounds = list(
		'modular_ss220/emotes/audio/unathi/talk_unathi_1.ogg',
		'modular_ss220/emotes/audio/unathi/talk_unathi_2.ogg',
		'modular_ss220/emotes/audio/unathi/talk_unathi_3.ogg')
	speech_chance = 20
	male_scream_sound = 'modular_ss220/emotes/audio/unathi/scream_male.ogg'
	female_scream_sound = 'modular_ss220/emotes/audio/unathi/scream_female.ogg'
	male_sneeze_sound = 'modular_ss220/emotes/audio/unathi/sneeze_male.ogg'
	female_sneeze_sound = 'modular_ss220/emotes/audio/unathi/sneeze_female.ogg'
	death_sounds = 'modular_ss220/emotes/audio/unathi/deathsound_unathi.ogg'
	suicide_messages = list(
		"пытается откусить себе язык!",
		"вонзает когти себе в глазницы!",
		"сворачивает себе шею!",
		"задерживает дыхание!")

/datum/species/vox
	autohiss_basic_map = list(
			"ch" = list("ch", "chch", "chich"),
			"k" = list("k", "kk", "kik"),
			"ч" = list("ч", "чч", "чич"),
			"к" = list("к", "кк", "кик"))
	autohiss_exempt = list("Vox-pidgin")

	scream_verb = "скрипит"
	suicide_messages = list(
		"пытается откусить себе язык!",
		"вонзает когти себе в глазницы!",
		"сворачивает себе шею!",
		"задерживает дыхание!",
		"глубоко вдыхает кислород!")

/datum/species/vulpkanin
	autohiss_basic_map = list(
			"r" = list("r", "rr", "rrr"),
			"р" = list("р", "рр", "ррр"))
	autohiss_exempt = list("Canilunzt")

	scream_verb = "скулит"
	suicide_messages = list(
		"пытается откусить себе язык!",
		"выдавливает когтями свои глазницы!",
		"сворачивает себе шею!",
		"задерживает дыхание!")

/datum/species/monkey
	scream_verb = "визжит"
