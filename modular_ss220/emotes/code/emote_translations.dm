//////////////////////
/// Living Emotes ///
////////////////////

/datum/emote/living/scream
	message = "кричит!"
	message_mime = "как будто кричит!"
	message_simple = "скулит."
	message_alien = "рычит!"
	message_postfix = "на %t!"
	emote_type = EMOTE_VISIBLE | EMOTE_MOUTH

/datum/emote/flip
	message = "делает кувырок!"

/datum/emote/spin
	key_third_person = "крутится"

/datum/emote/living/blush
	message = "краснеет."

/datum/emote/living/bow
	message = "кланяется."
	message_param = "кланяется %t."
	message_postfix = "%t."

/datum/emote/living/burp
	message = "отрыгивает."
	message_mime = "довольно противно открывает рот."

/datum/emote/living/choke
	message = "подавился!"
	message_mime = "отчаянно хватается за горло!"
	emote_type = EMOTE_AUDIBLE | EMOTE_MOUTH

/datum/emote/living/collapse
	message = "падает!"

/datum/emote/living/dance
	message = "радостно танцует."

/datum/emote/living/deathgasp
	message = "цепенеет и расслабляется, взгляд становится пустым и безжизненным..."
	message_alien = "цепенеет и расслабляется, взгляд становится пустым и безжизненным..."
	message_robot = "на мгновение вздрагивает и замирает, глаза медленно темнеют."
	message_AI = "скрипит, экран мерцает, пока системы медленно выключаются."
	message_alien = "издает ослабевающий крик, зеленая кровь пузырится из пасти..."
	message_larva = "с тошнотворным шипением выдыхает воздух и падает на пол..."
	message_monkey = "издает слабый звон, когда рушится и перестает двигаться..."
	message_simple = "перестает двигаться..."

/datum/emote/living/drool
	message = "несет чепуху."

/datum/emote/living/quiver
	message = "дрожит."

/datum/emote/living/frown
	message = "хмурится."
	message_param = "хмурится, смотря на %t."

/datum/emote/living/gag
	message = "выворачивает содержимое желудка."
	message_mime = "будто бы выворачивает содержимое желудка."
	message_param = "выворачивает содержимое желудка на %t."

/datum/emote/living/glare
	message = "смотрит с ненавистью."
	message_param = "с ненавистью смотрит на %t."

/datum/emote/living/grin
	message = "скалится в улыбке."

/datum/emote/living/grimace
	message = "корчит рожицу."

/datum/emote/living/look
	message = "смотрит."
	message_param = "смотрит на %t."

/datum/emote/living/bshake
	message = "трясется."

/datum/emote/living/shudder
	message = "вздрагивает."

/datum/emote/living/point
	message = "показывает пальцем."
	message_param = "показывает пальцем на %t."

/datum/emote/living/pout
	message = "надувает губы."

/datum/emote/living/shake
	message = "трясет головой."

/datum/emote/living/shiver
	message = "дрожит."

/datum/emote/living/sigh
	message = "вздыхает."
	message_mime = "беззвучно вздыхает."
	emote_type = EMOTE_AUDIBLE | EMOTE_MOUTH

/datum/emote/living/sigh/happy
	message = "Удовлетворённо вздыхает."
	message_mime = "кажется, удовлетворенно вздыхает"
	muzzled_noises = list("расслабленный", "довольный")

/datum/emote/living/sit
	message = "садится."

/datum/emote/living/smile
	message = "улыбается."
	message_param = "улыбается, смотря на %t."

/datum/emote/living/smug
	message = "самодовольно ухмыляется."
	message_param = "самодовольно ухмыляется, смотря на %t."

/datum/emote/living/sniff
	message = "нюхает."
	message_mime = "бесшумно нюхнул."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/snore
	message = "храпит."
	message_mime = "крепко спит."
	message_simple = "ворочается во сне."
	message_robot = "мечтает об электроовцах"
	stat_allowed = CONSCIOUS
	max_stat_allowed = CONSCIOUS

/datum/emote/living/nightmare
	message = "ворочается во сне."

/datum/emote/living/stare
	message = "пялится."
	message_param = "пялится на %t."

/datum/emote/living/strech
	message = "разминает руки."
	message_robot = "проверяет приводы."

/datum/emote/living/sulk
	message = "печально опускает руки."

/datum/emote/living/sway
	message = "качается на месте."

/datum/emote/living/swear
	message = "ругается!"
	message_param = "говорит нелестное слово %t!"
	message_mime = "показывает оскорбительный жест!"
	message_simple = "издает недовольный звук!"
	message_robot = "издает особенно оскорбительную серию звуковых сигналов!"
	message_postfix = ", обращаясь к %t!"

/datum/emote/living/tilt
	message = "наклоняет голову в сторону."

/datum/emote/living/tremble
	message = "дрожит от страха!"

/datum/emote/living/twitch
	message = "сильно дёргается."

/datum/emote/living/twitch_s
	message = "дергается."

/datum/emote/living/whimper
	message = "хнычет."
	message_mime = "кажется, поранился."
	muzzled_noises = list("слабый", "жалкий")

/datum/emote/living/wsmile
	message = "слабо улыбается."

//////////////////////
/// Carbon Emotes ///
////////////////////

/datum/emote/living/carbon/blink
	message = "моргает."

/datum/emote/living/carbon/blink_r
	key = "blink_r"
	message = "быстро моргает."

/datum/emote/living/carbon/chuckle
	message = "усмехается."
	message_mime = "бесшумно усмехается."
	muzzled_noises = list("радостно", "оптимистично")
	emote_type = EMOTE_AUDIBLE | EMOTE_MOUTH | EMOTE_VISIBLE

/datum/emote/living/carbon/cough
	message = "кашляет!"
	message_mime = "бесшумно кашляет!"
	emote_type = EMOTE_VISIBLE | EMOTE_MOUTH | EMOTE_AUDIBLE

/datum/emote/living/carbon/moan
	message = "стонет!"
	message_mime = "как будто стонет!"
	muzzled_noises = list("болезненно")
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE

/datum/emote/living/carbon/giggle
	message = "хихикает."
	message_mime = "бесшумно хихикает!"
	muzzled_noises = list("булькающе")

/datum/emote/living/carbon/gurgle
	message = "издает неприятное бульканье."
	muzzled_noises = list("недовольно", "гортанно")

/datum/emote/living/carbon/inhale
	message = "вдыхает."
	muzzled_noises = list("воздушно")

/datum/emote/living/carbon/inhale/sharp
	message = "глубоко вдыхает!"

/datum/emote/living/carbon/kiss
	message = "целует."
	message_param = "целует %t!"
	muzzled_noises = list("smooching")

/datum/emote/living/carbon/wave
	message = "машет."
	message_param = "машет %t."

/datum/emote/living/carbon/yawn
	message = "зевает."
	muzzled_noises = list("устало", "медленно", "сонно")
	emote_type = EMOTE_AUDIBLE | EMOTE_MOUTH | EMOTE_SOUND

/datum/emote/living/carbon/exhale
	message = "выдыхает."

/datum/emote/living/carbon/laugh
	message = "смеется."
	message_mime = "бесшумно смеется!"
	message_param = "смеется над %t."
	muzzled_noises = list("счастливо", "весело")
	emote_type = EMOTE_AUDIBLE | EMOTE_MOUTH | EMOTE_VISIBLE

/datum/emote/living/carbon/scowl
	message = "хмурится."

/datum/emote/living/groan
	message = "болезненно вздыхает!"
	message_mime = "как будто болезненно вздыхает!"
	message_param = "болезненно вздыхает на %t."
	muzzled_noises = list("болезненно")

/datum/emote/living/carbon/sign
	message = "показывает несколько пальцев."
	message_param = "показывает %t пальцев."
	param_desc = "число(0-10)"

/datum/emote/living/carbon/faint
	message = "падает в обморок."

/////////////////////
/// Human Emotes ///
///////////////////

/datum/emote/living/carbon/human/airguitar
	message = "натягивает струны и бьет головой, как шимпанзе в сафари."

/datum/emote/living/carbon/human/clap
	message = "хлопает."
	message_mime = "бесшумно хлопает."
	message_param = "хлопает %t."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE

/datum/emote/living/carbon/human/cry
	message = "плачет."
	muzzled_noises = list("слабо", "жалко", "грустно")
	emote_type = EMOTE_AUDIBLE | EMOTE_MOUTH | EMOTE_VISIBLE

/datum/emote/living/carbon/human/crack
	message = "хрустит пальцами."

/datum/emote/living/carbon/human/eyebrow
	message = "приподнимает бровь."
	message_param = "приподнимает бровь на %t."

/datum/emote/living/carbon/human/wince
	message = "морщиться."
	message_param = "морщиться на %t."

/datum/emote/living/carbon/human/squint
	message = "прищуривается."
	message_param = "прищуривается на %t."

/datum/emote/living/carbon/human/facepalm
	message = "хлопает себя по лбу."

/datum/emote/living/carbon/human/palm
	message = "ожидающе протягивает руку."
	message_param = "ожидающе протягивает руку к %t."

/datum/emote/living/carbon/human/grumble
	message = "ворчит!"
	message_mime = "как будто ворчит!"
	message_postfix = "на %t!"
	muzzled_noises = list("беспокойно")

/datum/emote/living/carbon/human/hug
	message = "обнимает себя."
	message_param = "обнимает %t."

/datum/emote/living/carbon/human/mumble
	message = "бормочет!"
	message_mime = "кажется, что он говорит приятное ничто!"
	message_postfix = "на %t!"

/datum/emote/living/carbon/human/nod
	message = "кивает."
	message_param = "кивает, обращаясь к %t."

/datum/emote/living/carbon/human/shake
	message = "трясет головой."
	message_param = "трясет головой, обращяясь к %t."

/datum/emote/living/carbon/human/pale
	message = "на секунду бледнеет."

/datum/emote/living/carbon/human/raise
	message = "поднимает руку."

/datum/emote/living/carbon/human/salute
	message = "салютует."
	message_param = "салютует %t."
	emote_type = EMOTE_VISIBLE

/datum/emote/living/carbon/human/shrug
	message = "пожимает плечами."

/datum/emote/living/carbon/human/johnny
	message = "затягивается сигаретой и выдыхает дым в форме своего имени."
	message_param = "тупо"

/datum/emote/living/carbon/human/sneeze
	message = "чихает."
	muzzled_noises = list("странно", "остро")

/datum/emote/living/carbon/human/wink
	message = "подмигивает."

/datum/emote/living/carbon/human/snap
	message = "щелкает пальцами."
	message_param = "щелкает пальцами на %t."
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE

/datum/emote/living/carbon/human/fart
	message = "пердит."
	message_param = "пердит в направлении %t."
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE

/datum/emote/living/carbon/sign/signal
	message_param = "показывает %t пальцев."
	param_desc = "число(0-10)"

/datum/emote/living/carbon/human/wag
	message = "начинает вилять хвостом."

/datum/emote/living/carbon/human/wag/stop
	message = "перестает вилять хвостом."

/datum/emote/living/carbon/human/scream
	message = "кричит!"
	message_mime = "как будто кричит!"
	message_simple = "скулит."
	message_alien = "рычит!"
	message_postfix = "на %t!"
	muzzled_noises = list("очень громко")
	emote_type = EMOTE_VISIBLE | EMOTE_MOUTH

/datum/emote/living/carbon/human/gasp
	message = "задыхается!"
	message_mime = "кажется, задыхается!"
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE

/datum/emote/living/carbon/human/scream/screech
	message = "визжит!"
	message_param = "визжит на %t!"

/datum/emote/living/carbon/human/scream/screech/roar
	message = "ревет!"
	message_param = "ревет на %t!"

/datum/emote/living/carbon/human/monkey/roll
	message = "кружится."

/datum/emote/living/carbon/human/monkey/scratch
	message = "чешется."

/datum/emote/living/carbon/human/monkey/tail
	message = "машет хвостом."

/datum/emote/living/carbon/human/flap
	message = "хлопает крыльями."

/datum/emote/living/carbon/human/flutter
	message = "зло хлопает крыльями."

/datum/emote/living/carbon/human/flutter
	message = "трепещет крыльями."

/datum/emote/living/carbon/human/quill
	message = "шелестят перьями."
	message_param = "шелестят перьями на %t."
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE

/datum/emote/living/carbon/human/clack
	message = "клацает своими мандибулами."
	message_param = "клацает своими мандибулами на %t."
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE | EMOTE_MOUTH

/datum/emote/living/carbon/human/clack/click
	key = "click"
	key_third_person = "clicks"
	message = "щелкает своими мандибулами."
	message_param = "щелкает своими мандибулами на %t."
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE | EMOTE_MOUTH

/datum/emote/living/carbon/human/drask_talk/drone
	message = "жужжит."
	message_param = "жужжит на %t."

/datum/emote/living/carbon/human/drask_talk/hum
	message = "напевает."
	message_param = "напевает %t."
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE | EMOTE_MOUTH

/datum/emote/living/carbon/human/drask_talk/rumble
	message = "урчит."
	message_param = "урчит на %t."

/datum/emote/living/carbon/human/hiss
	message = "шипит."
	message_param = "шипит на %t."
	muzzled_noises = list("слабое шипение")
	emote_type = EMOTE_VISIBLE | EMOTE_MOUTH | EMOTE_AUDIBLE

/datum/emote/living/carbon/human/creak
	message = "скрипит."
	message_param = "скрипит на %t."
	emote_type = EMOTE_VISIBLE | EMOTE_AUDIBLE

/datum/emote/living/carbon/human/howl
	message = "воет."
	message_mime = "беззвучно воет."
	message_param = "воет на %t."
	emote_type = EMOTE_VISIBLE | EMOTE_MOUTH | EMOTE_AUDIBLE

/datum/emote/living/carbon/human/growl
	message = "рычит."
	message_mime = "бесшумно рычит."
	message_param = "рычит на %t."
	muzzled_noises = list("раздражённо")
	emote_type = EMOTE_VISIBLE | EMOTE_MOUTH | EMOTE_AUDIBLE

/datum/emote/living/carbon/human/rattle
	message = "гремит костями."
	message_param = "гремит костями на %t."

/datum/emote/living/carbon/human/crack/slime
	message = "сминает костяшки пальцев!"

/datum/emote/living/carbon/human/crack/diona
	message = "трещит ветками!"

/datum/emote/living/carbon/human/warble
	message = "издаёт трель."
	message_param = "издаёт трель для %t."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE

/datum/emote/living/carbon/human/slime/squish
	message = "хлюпает."
	message_param = "хлюпает на %t."
	emote_type = EMOTE_AUDIBLE | EMOTE_VISIBLE

/////////////////////
/// Alien Emotes ///
///////////////////

/datum/emote/living/carbon/alien/humanoid/roar
	message = "ревет!"
	message_param = "ревет на %t!"

/datum/emote/living/carbon/alien/humanoid/hiss
	message = "шипит!"
	message_param = "шипит %t!"

/datum/emote/living/carbon/alien/humanoid/gnarl
	message = "оскаливается и показывает зубы."
	message_param = "оскаливается и показывает зубы %t."

/////////////////////
/// Brain Emotes ///
///////////////////

/datum/emote/living/carbon/brain/alarm
	message = "подает сигнал тревоги."
	self_message = "Вы подаете сигнал тревоги."

/datum/emote/living/carbon/brain/alert
	message = "издаёт страдальческий звук."
	self_message = "Вы издаёте страдальческий звук."

/datum/emote/living/carbon/brain/notice
	message = "воспроизводит громкий звук."
	self_message = "Вы воспроизводите громкий звук."

/datum/emote/living/carbon/brain/flash
	message = "начинает быстро мигать лампочками!"

/datum/emote/living/carbon/brain/whistle
	message = "свистит."
	self_message = "Вы свистите."
	emote_type = EMOTE_AUDIBLE | EMOTE_MOUTH | EMOTE_SOUND
	sound = "modular_ss220/emotes/audio/whistle.ogg"

/datum/emote/living/carbon/brain/beep
	message = "бипает."
	self_message = "Вы бипаете."

/datum/emote/living/carbon/brain/boop
	message = "бупает."
	self_message = "вы бупаете."
