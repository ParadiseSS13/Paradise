/datum/keybinding/emote
	category = KB_CATEGORY_EMOTE_GENERIC
	var/datum/emote/linked_emote

/datum/keybinding/emote/can_use(client/C, mob/M)
	return ..() //We don't need custom logic here as emotes handle their own useability, see USABLE_DEAD_EMOTES

/datum/keybinding/emote/down(client/user)
	. = ..()
	user.mob.emote(initial(linked_emote.key), intentional = TRUE)

/datum/keybinding/emote/flip
	linked_emote = /datum/emote/flip
	name = "Flip"

/datum/keybinding/emote/spin
	linked_emote = /datum/emote/spin
	name = "Spin"

/datum/keybinding/emote/jump
	linked_emote = /datum/emote/jump
	name = "Jump"

/datum/keybinding/emote/blush
	linked_emote = /datum/emote/living/blush
	name = "Blush"

/datum/keybinding/emote/bow
	linked_emote = /datum/emote/living/bow
	name = "Bow"

/datum/keybinding/emote/burp
	linked_emote = /datum/emote/living/burp
	name = "Burp"

/datum/keybinding/emote/choke
	linked_emote = /datum/emote/living/choke
	name = "Choke"

/datum/keybinding/emote/collapse
	linked_emote = /datum/emote/living/collapse
	name = "Collapse"

/datum/keybinding/emote/dance
	linked_emote = /datum/emote/living/dance
	name = "Dance"

/datum/keybinding/emote/deathgasp
	linked_emote = /datum/emote/living/deathgasp
	name = "Deathgasp"

/datum/keybinding/emote/drool
	linked_emote = /datum/emote/living/drool
	name = "Drool"

/datum/keybinding/emote/quiver
	linked_emote = /datum/emote/living/quiver
	name = "Quiver"

/datum/keybinding/emote/frown
	linked_emote = /datum/emote/living/frown
	name = "Frown"

/datum/keybinding/emote/gag
	linked_emote = /datum/emote/living/gag
	name = "Gag"

/datum/keybinding/emote/glare
	linked_emote = /datum/emote/living/glare
	name = "Glare"

/datum/keybinding/emote/grin
	linked_emote = /datum/emote/living/grin
	name = "Grin"

/datum/keybinding/emote/grimace
	linked_emote = /datum/emote/living/grimace
	name = "Grimace"

/datum/keybinding/emote/groan
	linked_emote = /datum/emote/living/groan
	name = "Groan"

/datum/keybinding/emote/look
	linked_emote = /datum/emote/living/look
	name = "Look"

/datum/keybinding/emote/bshake
	linked_emote = /datum/emote/living/bshake
	name = "Shake"

/datum/keybinding/emote/shudder
	linked_emote = /datum/emote/living/shudder
	name = "Shudder"

/datum/keybinding/emote/point
	linked_emote = /datum/emote/living/point
	name = "Point"

/datum/keybinding/emote/pout
	linked_emote = /datum/emote/living/pout
	name = "Pout"

/datum/keybinding/emote/scream
	linked_emote = /datum/emote/living/scream
	name = "Scream"

/datum/keybinding/emote/shake
	linked_emote = /datum/emote/living/shake
	name = "Head Shake"

/datum/keybinding/emote/shiver
	linked_emote = /datum/emote/living/shiver
	name = "Shiver"

/datum/keybinding/emote/sigh
	linked_emote = /datum/emote/living/sigh
	name = "Sigh"

/datum/keybinding/emote/happy
	linked_emote = /datum/emote/living/sigh/happy
	name = "Sigh (Happy)"

/datum/keybinding/emote/sit
	linked_emote = /datum/emote/living/sit
	name = "Sit"

/datum/keybinding/emote/smile
	linked_emote = /datum/emote/living/smile
	name = "Smile"

/datum/keybinding/emote/smug
	linked_emote = /datum/emote/living/smug
	name = "Smug"

/datum/keybinding/emote/sniff
	linked_emote = /datum/emote/living/sniff
	name = "Sniff"

/datum/keybinding/emote/snore
	linked_emote = /datum/emote/living/snore
	name = "Snore"

/datum/keybinding/emote/nightmare
	linked_emote = /datum/emote/living/nightmare
	name = "Nightmare"

/datum/keybinding/emote/stare
	linked_emote = /datum/emote/living/stare
	name = "Stare"

/datum/keybinding/emote/stretch
	linked_emote = /datum/emote/living/strech
	name = "Stretch"

/datum/keybinding/emote/sulk
	linked_emote = /datum/emote/living/sulk
	name = "Sulk"

/datum/keybinding/emote/sway
	linked_emote = /datum/emote/living/sway
	name = "Sway"

/datum/keybinding/emote/swear
	linked_emote = /datum/emote/living/swear
	name = "Swear"

/datum/keybinding/emote/tilt
	linked_emote = /datum/emote/living/tilt
	name = "Tilt"

/datum/keybinding/emote/tremble
	linked_emote = /datum/emote/living/tremble
	name = "Tremble"

/datum/keybinding/emote/twitch
	linked_emote = /datum/emote/living/twitch
	name = "Twitch (Violent)"

/datum/keybinding/emote/twitch_s
	linked_emote = /datum/emote/living/twitch_s
	name = "Twitch"

/datum/keybinding/emote/whimper
	linked_emote = /datum/emote/living/whimper
	name = "Whimper"

/datum/keybinding/emote/wsmile
	linked_emote = /datum/emote/living/wsmile
	name = "Smile (Weak)"

/datum/keybinding/emote/carbon
	category = KB_CATEGORY_EMOTE_CARBON

/datum/keybinding/emote/carbon/can_use(client/C, mob/M)
	return iscarbon(M) && ..()

/datum/keybinding/emote/carbon/blink
	linked_emote = /datum/emote/living/carbon/blink
	name = "Blink"

/datum/keybinding/emote/carbon/blink_r
	linked_emote = /datum/emote/living/carbon/blink_r
	name = "Blink (Rapid)"

/datum/keybinding/emote/carbon/cross
	linked_emote = /datum/emote/living/carbon/cross
	name = "Cross Arms"

/datum/keybinding/emote/carbon/chuckle
	linked_emote = /datum/emote/living/carbon/chuckle
	name = "Chuckle"

/datum/keybinding/emote/carbon/cough
	linked_emote = /datum/emote/living/carbon/cough
	name = "Cough"

/datum/keybinding/emote/carbon/moan
	linked_emote = /datum/emote/living/carbon/moan
	name = "Moan"

/datum/keybinding/emote/carbon/giggle
	linked_emote = /datum/emote/living/carbon/giggle
	name = "Giggle"

/datum/keybinding/emote/carbon/gurgle
	linked_emote = /datum/emote/living/carbon/gurgle
	name = "Gurgle"

/datum/keybinding/emote/carbon/inhale
	linked_emote = /datum/emote/living/carbon/inhale
	name = "Inhale"

/datum/keybinding/emote/carbon/inhale/sharp
	linked_emote = /datum/emote/living/carbon/inhale/sharp
	name = "Inhale (Sharp)"

/datum/keybinding/emote/carbon/kiss
	linked_emote = /datum/emote/living/carbon/kiss
	name = "Kiss" //PG13

/datum/keybinding/emote/carbon/wave
	linked_emote = /datum/emote/living/carbon/wave
	name = "Wave"

/datum/keybinding/emote/carbon/yawn
	linked_emote = /datum/emote/living/carbon/yawn
	name = "Yawn"

/datum/keybinding/emote/carbon/exhale
	linked_emote = /datum/emote/living/carbon/exhale
	name = "Exhale"

/datum/keybinding/emote/carbon/laugh
	linked_emote = /datum/emote/living/carbon/laugh
	name = "Laugh"

/datum/keybinding/emote/carbon/scowl
	linked_emote = /datum/emote/living/carbon/scowl
	name = "Scowl"

/datum/keybinding/emote/carbon/twirl
	linked_emote = /datum/emote/living/carbon/twirl
	name = "Twirl"

/datum/keybinding/emote/carbon/faint
	linked_emote = /datum/emote/living/carbon/faint
	name = "Faint"

/datum/keybinding/emote/carbon/sign
	linked_emote = /datum/emote/living/carbon/sign
	name = "Sign"

/datum/keybinding/emote/carbon/alien
	category = KB_CATEGORY_EMOTE_ALIEN

/datum/keybinding/emote/carbon/alien/can_use(client/C, mob/M)
	return isalien(M) && ..()

/datum/keybinding/emote/carbon/alien/humanoid/roar
	linked_emote = /datum/emote/living/carbon/alien_humanoid/roar
	name = "Roar"

/datum/keybinding/emote/carbon/alien/humanoid/hiss
	linked_emote = /datum/emote/living/carbon/alien_humanoid/hiss
	name = "Hiss"

/datum/keybinding/emote/carbon/alien/humanoid/gnarl
	linked_emote = /datum/emote/living/carbon/alien_humanoid/gnarl
	name = "Gnarl"

/datum/keybinding/emote/carbon/brain
	category = KB_CATEGORY_EMOTE_BRAIN

/datum/keybinding/emote/carbon/brain/can_use(client/C, mob/M)
	return isbrain(M) && ..()

/datum/keybinding/emote/carbon/brain/alarm
	linked_emote = /datum/emote/living/brain/alarm
	name = "Alarm"

/datum/keybinding/emote/carbon/brain/alert
	linked_emote = /datum/emote/living/brain/alert
	name = "Alert"

/datum/keybinding/emote/carbon/brain/notice
	linked_emote = /datum/emote/living/brain/notice
	name = "Notice"

/datum/keybinding/emote/carbon/brain/flash
	linked_emote = /datum/emote/living/brain/flash
	name = "Flash"

/datum/keybinding/emote/carbon/brain/whistle
	linked_emote = /datum/emote/living/brain/whistle
	name = "Whistle"

/datum/keybinding/emote/carbon/brain/beep
	linked_emote = /datum/emote/living/brain/beep
	name = "Beep"

/datum/keybinding/emote/carbon/brain/boop
	linked_emote = /datum/emote/living/brain/boop
	name = "Boop"

/datum/keybinding/emote/carbon/human
	category = KB_CATEGORY_EMOTE_HUMAN

/datum/keybinding/emote/carbon/human/can_use(client/C, mob/M)
	return ishuman(M) && ..()

/datum/keybinding/emote/carbon/human/airguitar
	linked_emote = /datum/emote/living/carbon/human/airguitar
	name = "Airguitar"

/datum/keybinding/emote/carbon/human/clap
	linked_emote = /datum/emote/living/carbon/human/clap
	name = "Clap"

/datum/keybinding/emote/carbon/human/cry
	linked_emote = /datum/emote/living/carbon/human/cry
	name = "Cry"

/datum/keybinding/emote/carbon/human/dap
	linked_emote = /datum/emote/living/carbon/human/highfive/dap
	name = "Dap"

/datum/keybinding/emote/carbon/human/eyebrow
	linked_emote = /datum/emote/living/carbon/human/eyebrow
	name = "Eyebrow"

/datum/keybinding/emote/carbon/human/facepalm
	linked_emote = /datum/emote/living/carbon/human/facepalm
	name = "Facepalm"

/datum/keybinding/emote/carbon/human/grumble
	linked_emote = /datum/emote/living/carbon/human/grumble
	name = "Grumble"

/datum/keybinding/emote/carbon/human/hug
	linked_emote = /datum/emote/living/carbon/human/hug
	name = "Hug"

/datum/keybinding/emote/carbon/human/mumble
	linked_emote = /datum/emote/living/carbon/human/mumble
	name = "Mumble"

/datum/keybinding/emote/carbon/human/nod
	linked_emote = /datum/emote/living/carbon/human/nod
	name = "Nod"

/datum/keybinding/emote/carbon/human/palm
	linked_emote = /datum/emote/living/carbon/human/palm
	name = "Extend palm"

/datum/keybinding/emote/carbon/human/scream
	linked_emote = /datum/emote/living/carbon/human/scream
	name = "Scream"

/datum/keybinding/emote/carbon/human/gasp
	linked_emote = /datum/emote/living/carbon/human/gasp
	name = "Gasp"

/datum/keybinding/emote/carbon/human/shake
	linked_emote = /datum/emote/living/carbon/human/shake
	name = "Shake Head"

/datum/keybinding/emote/carbon/human/pale
	linked_emote = /datum/emote/living/carbon/human/pale
	name = "Pale"

/datum/keybinding/emote/carbon/human/raise
	linked_emote = /datum/emote/living/carbon/human/raise
	name = "Raise"

/datum/keybinding/emote/carbon/human/salute
	linked_emote = /datum/emote/living/carbon/human/salute
	name = "Salute"

/datum/keybinding/emote/carbon/human/signal
	linked_emote = /datum/emote/living/carbon/sign/signal
	name = "Signal"

/datum/keybinding/emote/carbon/human/shrug
	linked_emote = /datum/emote/living/carbon/human/shrug
	name = "Shrug"

/datum/keybinding/emote/carbon/human/sniff
	linked_emote = /datum/emote/living/carbon/human/sniff
	name = "Sniff"

/datum/keybinding/emote/carbon/human/johnny
	linked_emote = /datum/emote/living/carbon/human/johnny
	name = "Johnny"

/datum/keybinding/emote/carbon/human/sneeze
	linked_emote = /datum/emote/living/carbon/human/sneeze
	name = "Sneeze"

/datum/keybinding/emote/carbon/human/slap
	linked_emote = /datum/emote/living/carbon/human/slap
	name = "Slap"

/datum/keybinding/emote/carbon/human/wince
	linked_emote = /datum/emote/living/carbon/human/wince
	name = "Wince"

/datum/keybinding/emote/carbon/human/squint
	linked_emote = /datum/emote/living/carbon/human/squint
	name = "Squint"

/datum/keybinding/emote/carbon/human/wink
	linked_emote = /datum/emote/living/carbon/human/wink
	name = "Wink"

/datum/keybinding/emote/carbon/human/highfive
	linked_emote = /datum/emote/living/carbon/human/highfive
	name = "High Five"

/datum/keybinding/emote/carbon/human/handshake
	linked_emote = /datum/emote/living/carbon/human/highfive/handshake
	name = "Handshake"

/datum/keybinding/emote/carbon/human/snap
	linked_emote = /datum/emote/living/carbon/human/snap
	name = "Snap"

/datum/keybinding/emote/carbon/human/crack
	linked_emote = /datum/emote/living/carbon/human/crack
	name = "Crack"

/datum/keybinding/emote/carbon/human/fart
	linked_emote = /datum/emote/living/carbon/human/fart
	name = "Fart"

/datum/keybinding/emote/carbon/human/wag
	linked_emote = /datum/emote/living/carbon/human/wag
	name = "Wag"

/datum/keybinding/emote/carbon/human/wag/stop
	linked_emote = /datum/emote/living/carbon/human/wag/stop
	name = "Stop Wag"

/datum/keybinding/emote/carbon/human/flap
	linked_emote = /datum/emote/living/carbon/human/flap
	name = "Flap"

/datum/keybinding/emote/carbon/human/flap/angry
	linked_emote = /datum/emote/living/carbon/human/flap/angry
	name = "Angry Flap"

/datum/keybinding/emote/carbon/human/flutter
	linked_emote = /datum/emote/living/carbon/human/flutter
	name = "Flutter"

/datum/keybinding/emote/carbon/human/quill
	linked_emote = /datum/emote/living/carbon/human/quill
	name = "Quill"

/datum/keybinding/emote/carbon/human/caw
	linked_emote = /datum/emote/living/carbon/human/caw
	name = "Caw"

/datum/keybinding/emote/carbon/human/warble
	linked_emote = /datum/emote/living/carbon/human/warble
	name = "Warble"

/datum/keybinding/emote/carbon/human/clack
	linked_emote = /datum/emote/living/carbon/human/clack
	name = "Clack"

/datum/keybinding/emote/carbon/human/clack/click
	linked_emote = /datum/emote/living/carbon/human/clack/click
	name = "Click"

/datum/keybinding/emote/carbon/human/drask_talk/drone
	linked_emote = /datum/emote/living/carbon/human/drask_talk/drone
	name = "Drone"

/datum/keybinding/emote/carbon/human/drask_talk/hum
	linked_emote = /datum/emote/living/carbon/human/drask_talk/hum
	name = "Hum"

/datum/keybinding/emote/carbon/human/drask_talk/rumble
	linked_emote = /datum/emote/living/carbon/human/drask_talk/rumble
	name = "Rumble"

/datum/keybinding/emote/carbon/human/hiss
	linked_emote = /datum/emote/living/carbon/human/hiss
	name = "Hiss (Unathi)"

/datum/keybinding/emote/carbon/human/thump
	linked_emote = /datum/emote/living/carbon/human/thump
	name = "Tail Thump"

/datum/keybinding/emote/carbon/human/creak
	linked_emote = /datum/emote/living/carbon/human/creak
	name = "Creak"

/datum/keybinding/emote/carbon/human/diona_chirp
	linked_emote = /datum/emote/living/carbon/human/diona_chirp
	name = "Chirp (Diona)"

/datum/keybinding/emote/carbon/human/squish
	linked_emote = /datum/emote/living/carbon/human/slime/squish
	name = "Squish"

/datum/keybinding/emote/carbon/human/howl
	linked_emote = /datum/emote/living/carbon/human/howl
	name = "Howl"

/datum/keybinding/emote/carbon/human/growl
	linked_emote = /datum/emote/living/carbon/human/growl
	name = "Growl"

/datum/keybinding/emote/carbon/human/hiss/tajaran
	linked_emote = /datum/emote/living/carbon/human/hiss/tajaran
	name = "Hiss (Tajaran)"

/datum/keybinding/emote/carbon/human/rattle
	linked_emote = /datum/emote/living/carbon/human/rattle
	name = "Rattle"

/datum/keybinding/emote/carbon/human/bubble
	linked_emote = /datum/emote/living/carbon/human/slime/bubble
	name = "Bubble"

/datum/keybinding/emote/carbon/human/pop
	linked_emote = /datum/emote/living/carbon/human/slime/pop
	name = "Pop"

/datum/keybinding/emote/carbon/human/monkey/can_use(client/C, mob/M)
	return ismonkeybasic(M) && ..()

/datum/keybinding/emote/carbon/human/monkey/gnarl
	linked_emote = /datum/emote/living/carbon/human/monkey/gnarl
	name = "Gnarl (Monkey)"

/datum/keybinding/emote/carbon/human/monkey/roll
	linked_emote = /datum/emote/living/carbon/human/monkey/roll
	name = "Roll (Monkey)"

/datum/keybinding/emote/carbon/human/monkey/scratch
	linked_emote = /datum/emote/living/carbon/human/monkey/scratch
	name = "Scratch (Monkey)"

/datum/keybinding/emote/carbon/human/monkey/tail
	linked_emote = /datum/emote/living/carbon/human/monkey/tail
	name = "Tail (Monkey)"

/datum/keybinding/emote/carbon/human/monkey/screech
	linked_emote = /datum/emote/living/carbon/human/scream/screech
	name = "Screech (Monkey)"

/datum/keybinding/emote/carbon/human/monkey/screech/roar
	linked_emote = /datum/emote/living/carbon/human/scream/screech/roar
	name = "Roar (Monkey)"

/datum/keybinding/emote/silicon
	category = KB_CATEGORY_EMOTE_SILICON

/datum/keybinding/emote/silicon/can_use(client/C, mob/M)
	return (issilicon(M) || ismachineperson(M)) && ..()

/datum/keybinding/emote/silicon/scream
	linked_emote = /datum/emote/living/silicon/scream
	name = "Scream"

/datum/keybinding/emote/silicon/ping
	linked_emote = /datum/emote/living/silicon/ping
	name = "Ping"

/datum/keybinding/emote/silicon/buzz
	linked_emote = /datum/emote/living/silicon/buzz
	name = "Buzz"

/datum/keybinding/emote/silicon/buzz2
	linked_emote = /datum/emote/living/silicon/buzz2
	name = "Buzzz"

/datum/keybinding/emote/silicon/beep
	linked_emote = /datum/emote/living/silicon/beep
	name = "Beep"

/datum/keybinding/emote/silicon/boop
	linked_emote = /datum/emote/living/silicon/boop
	name = "Boop"

/datum/keybinding/emote/silicon/yes
	linked_emote = /datum/emote/living/silicon/yes
	name = "Yes"

/datum/keybinding/emote/silicon/no
	linked_emote = /datum/emote/living/silicon/no
	name = "No"

/datum/keybinding/emote/silicon/law
	linked_emote = /datum/emote/living/silicon/law
	name = "Law"

/datum/keybinding/emote/silicon/halt
	linked_emote = /datum/emote/living/silicon/halt
	name = "Halt"

/datum/keybinding/emote/silicon/salute
	linked_emote = /datum/emote/living/silicon/salute
	name = "Salute"

/datum/keybinding/emote/simple_animal
	category = KB_CATEGORY_EMOTE_ANIMAL

/datum/keybinding/emote/simple_animal/can_use(client/C, mob/M)
	return isanimal_or_basicmob(M) && ..()

/datum/keybinding/emote/simple_animal/diona_chirp
	linked_emote = /datum/emote/living/simple_animal/diona_chirp
	name = "Chirp (Nymph)"

/datum/keybinding/emote/simple_animal/diona_chirp/can_use(client/C, mob/M)
	return isnymph(M) && ..()

/datum/keybinding/emote/simple_animal/gorilla_ooga
	linked_emote = /datum/emote/living/basic_mob/gorilla/ooga
	name = "Ooga (Gorilla)"

/datum/keybinding/emote/simple_animal/gorilla_ooga/can_use(client/C, mob/M)
	return isgorilla(M) && ..()

/datum/keybinding/emote/simple_animal/pet/dog/bark
	linked_emote = /datum/emote/living/simple_animal/pet/dog/bark
	name = "Bark (Dog)"

/datum/keybinding/emote/simple_animal/pet/dog/yelp
	linked_emote = /datum/emote/living/simple_animal/pet/dog/yelp
	name = "Yelp (Dog)"

/datum/keybinding/emote/simple_animal/pet/dog/growl
	linked_emote = /datum/emote/living/simple_animal/pet/dog/growl
	name = "Growl (Dog)"

/datum/keybinding/emote/simple_animal/pet/dog/can_use(client/C, mob/M)
	return isdog(M) && ..()

/datum/keybinding/emote/simple_animal/mouse/squeak
	linked_emote = /datum/emote/living/simple_animal/mouse/squeak
	name = "Squeak (Mouse)"

/datum/keybinding/emote/simple_animal/mouse/can_use(client/C, mob/M)
	return ismouse(M) && ..()

/datum/keybinding/emote/simple_animal/pet/cat/meow
	linked_emote = /datum/emote/living/simple_animal/pet/cat/meow
	name = "Meow (Cat)"

/datum/keybinding/emote/simple_animal/pet/cat/hiss
	linked_emote = /datum/emote/living/simple_animal/pet/cat/hiss
	name = "Hiss (Cat)"

/datum/keybinding/emote/simple_animal/pet/cat/purr
	linked_emote = /datum/emote/living/simple_animal/pet/cat/purr
	name = "Purr (Cat)"

/datum/keybinding/emote/simple_animal/pet/cat/sit
	linked_emote = /datum/emote/living/sit/cat
	name = "Sit/Stand (Cat)"

/datum/keybinding/emote/simple_animal/pet/cat/can_use(client/C, mob/M)
	return iscat(M) && ..()

/datum/keybinding/emote/simple_animal/lizard/whicker
	linked_emote = /datum/emote/lizard/whicker
	name = "Whicker (Lizard)"

/datum/keybinding/custom
	category = KB_CATEGORY_EMOTE_CUSTOM
	var/default_emote_text = "Insert custom me emote text."
	var/donor_exclusive = FALSE

/datum/keybinding/custom/down(client/C)
	. = ..()
	if(!C.prefs?.active_character?.custom_emotes) //Checks the current character save for any custom emotes
		return

	var/desired_emote = C.prefs.active_character.custom_emotes[name] //check the custom emotes list for this keybind name

	if(!desired_emote)
		return

	C.mob.me_verb(html_decode(desired_emote)) //do the thing!

/datum/keybinding/custom/can_use(client/C, mob/M)
	if(donor_exclusive && !(C.donator_level || C.holder || C.prefs.unlock_content)) //is this keybind restricted to donors/byond members/admins, and are you one or not?
		return

	return isliving(M) && ..()

/datum/keybinding/custom/one
	name = "Custom Emote 1"

/datum/keybinding/custom/two
	name = "Custom Emote 2"

/datum/keybinding/custom/three
	name = "Custom Emote 3"

/datum/keybinding/custom/four
	name = "Custom Emote 4"
	donor_exclusive = TRUE

/datum/keybinding/custom/five
	name = "Custom Emote 5"
	donor_exclusive = TRUE

/datum/keybinding/custom/six
	name = "Custom Emote 6"
	donor_exclusive = TRUE

/datum/keybinding/custom/seven
	name = "Custom Emote 7"
	donor_exclusive = TRUE

/datum/keybinding/custom/eight
	name = "Custom Emote 8"
	donor_exclusive = TRUE

/datum/keybinding/custom/nine
	name = "Custom Emote 9"
	donor_exclusive = TRUE

/datum/keybinding/custom/ten
	name = "Custom Emote 10"
	donor_exclusive = TRUE
