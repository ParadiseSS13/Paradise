/datum/dog_fashion
	var/name
	var/desc
	var/emote_see
	var/emote_hear
	var/speak
	var/speak_emote

	// This isn't applied to the dog, but stores the icon_state of the
	// sprite that the associated item uses
	var/icon_file
	var/obj_icon_state
	var/obj_alpha
	var/obj_color

/datum/dog_fashion/New(mob/M)
	name = replacetext(name, "REAL_NAME", M.real_name)
	desc = replacetext(desc, "NAME", name)

/datum/dog_fashion/proc/apply(mob/living/simple_animal/pet/dog/D)
	if(name)
		D.name = name
	if(desc)
		D.desc = desc
	if(emote_see)
		D.emote_see = emote_see
	if(emote_hear)
		D.emote_hear = emote_hear
	if(speak)
		D.speak = speak
	if(speak_emote)
		D.speak_emote = speak_emote

/datum/dog_fashion/proc/get_overlay(dir)
	if(icon_file && obj_icon_state)
		var/image/corgI = image(icon_file, obj_icon_state, dir = dir)
		corgI.alpha = obj_alpha
		corgI.color = obj_color
		return corgI


/datum/dog_fashion/head
	icon_file = 'icons/mob/corgi_head.dmi'

/datum/dog_fashion/back
	icon_file = 'icons/mob/corgi_back.dmi'

/datum/dog_fashion/head/hardhat/apply(mob/living/simple_animal/pet/dog/D)
	..()
	D.set_light(4)

/datum/dog_fashion/head/hardhat
	name = "Engineer REAL_NAME"
	desc = "Trust him, he's an engineer."

/datum/dog_fashion/head/hardhat/white
	name = "Chief engineer REAL_NAME"
	desc = "Hasn't delamed the engine once."

/datum/dog_fashion/head/hardhat/red
	name = "Fire chief REAL_NAME"
	desc = "Some days you're the dog, some days you're the hydrant."

/datum/dog_fashion/head/helmet
	name = "Sergeant REAL_NAME"
	desc = "The ever-loyal, the ever-vigilant."

/datum/dog_fashion/head/chef
	name = "Sous chef REAL_NAME"
	desc = "Your food will be taste-tested. All of it."


/datum/dog_fashion/head/captain
	name = "Captain REAL_NAME"
	desc = "Probably better than the last captain."

/datum/dog_fashion/head/kitty
	name = "Runtime"
	emote_see = list("coughs up a furball", "stretches")
	emote_hear = list("purrs")
	speak = list("Purrr", "Meow!", "MAOOOOOW!", "HISSSSS", "MEEEEEEW")
	desc = "It's a cute little kitty-cat! ... wait ... what the hell?"

/datum/dog_fashion/head/rabbit
	name = "Hoppy"
	emote_see = list("twitches its nose", "hops around a bit")
	desc = "This is Hoppy. It's a corgi-...urmm... bunny rabbit."

/datum/dog_fashion/head/beret
	name = "Yann"
	desc = "Mon dieu! C'est un chien!"
	speak = list("le woof!", "le bark!", "JAPPE!!")
	emote_see = list("cowers in fear.", "surrenders.", "plays dead.","looks as though there is a wall in front of him.")


/datum/dog_fashion/head/detective
	name = "Detective REAL_NAME"
	desc = "NAME sees through your lies..."
	emote_see = list("investigates the area.","sniffs around for clues.","searches for scooby snacks.","takes a candycorn from the hat.")


/datum/dog_fashion/head/nurse
	name = "Nurse REAL_NAME"
	desc = "NAME needs 100cc of beef jerky... STAT!"

/datum/dog_fashion/head/pirate
	name = "Pirate-title Pirate-name"
	desc = "Yaarghh!! Thar' be a scurvy dog!"
	emote_see = list("hunts for treasure.","stares coldly...","gnashes his tiny corgi teeth!")
	emote_hear = list("growls ferociously!", "snarls.")
	speak = list("Arrrrgh!!","Grrrrrr!")

/datum/dog_fashion/head/pirate/New(mob/M)
	..()
	name = "[pick("Ol'","Scurvy","Black","Rum","Gammy","Bloody","Gangrene","Death","Long-John")] [pick("kibble","leg","beard","tooth","poop-deck","Threepwood","Le Chuck","corsair","Silver","Crusoe")]"

/datum/dog_fashion/head/ushanka
	name = "Communist-title Realname"
	desc = "A follower of Karl Barx."
	emote_see = list("contemplates the failings of the capitalist economic model.", "ponders the pros and cons of vanguardism.")

/datum/dog_fashion/head/ushanka/New(mob/M)
	..()
	name = "[pick("Comrade","Commissar","Glorious Leader")] [M.real_name]"

/datum/dog_fashion/head/warden
	name = "Officer REAL_NAME"
	emote_see = list("drools.","looks for donuts.")
	desc = "Stop right there criminal scum!"

/datum/dog_fashion/head/blue_wizard
	name = "Grandwizard REAL_NAME"
	speak = list("YAP", "Woof!", "Bark!", "AUUUUUU", "EI  NATH!")

/datum/dog_fashion/head/red_wizard
	name = "Pyromancer REAL_NAME"
	speak = list("YAP", "Woof!", "Bark!", "AUUUUUU", "ONI SOMA!")

/datum/dog_fashion/head/black_wizard
	name = "Necromancer REAL_NAME"
	speak = list("YAP", "Woof!", "Bark!", "AUUUUUU")

// CARDBORG OUTFITS
/datum/dog_fashion/head/cardborg
	name = "BORGI"
	speak = list("Ping!","Beep!","Woof!")
	emote_see = list("goes rogue.", "sniffs out non-humans.")
	desc = "Result of robotics budget cuts."

/datum/dog_fashion/head/cardborg/security
	name = "SECBORGI"
	speak = list("Ping!", "Beep!", "Woof!", "HALT!", "HALT! HALT! HALT!")
	emote_see = list("goes rogue.", "sniffs out criminals.")
	desc = "Result of robotics budget cuts and a ban on the station having real security cyborgs."

/datum/dog_fashion/head/cardborg/engineering
	name = "ENGI-IAN"
	speak = list("Ping!", "Beep!", "Woof!")
	emote_see = list("goes rogue.", "sniffs for wires.", "looks for an autolathe board.")
	desc = "Result of robotics budget cuts. Knows as much about atmospherics as the average engineer."

/datum/dog_fashion/head/cardborg/mining
	name = "DIGDOG"
	speak = list("Ping!", "Beep!", "Woof!")
	emote_see = list("goes rogue.", "sniffs for ores.", "digs into the floor.")
	desc = "Result of robotics budget cuts. Has dug up more bones than any other miner!"

/datum/dog_fashion/head/cardborg/service
	name = "Service dogbot"
	speak = list("Ping!", "Beep!", "Woof!")
	emote_see = list("goes rogue.")
	desc = "Result of robotics budget cuts. Still about as useful as a real service cyborg..."

/datum/dog_fashion/head/cardborg/medical
	name = "M3D1CAL_IANTERN"
	speak = list("Ping!", "Beep!", "Woof!")
	emote_see = list("goes rogue.", "sniffs out the injured.", "analyses your vitals.")
	desc = "Result of robotics budget cuts. Hopefully medical is more useful."

/datum/dog_fashion/head/cardborg/janitor
	name = "CLE-IAN-G"
	speak = list("Ping!", "Beep!", "Woof!")
	emote_see = list("goes rogue.", "sniffs for messes.", "licks the floor clean.")
	desc = "Result of robotics budget cuts. More pettable than 9 out of 10 janitors."

/datum/dog_fashion/head/cardborg/xeno
	name = "BORGIMORPH"
	speak = list("Ping!", "Beep!", "Woof!", "HISS!", "HISSHISSHISS!")
	emote_see = list("goes rogue.", "hisses.")
	desc = "Result of robotics budget cuts. If this is your last line of defence against a xenomorph outbreak, god help you."

/datum/dog_fashion/head/cardborg/deathbot
	name = "Epsilon-D0G1"
	speak = list("Ping!", "Beep!", "Woof!")
	emote_see = list("goes rogue.", "sniffs out survivors.", "prepares to destroy the station.")
	desc = "Result of robotics budget cuts. Looks just like the cyborg from the Deathsquad TV show!"

/datum/dog_fashion/head/ghost
	name = "\improper Ghost"
	speak = list("WoooOOOooo~","AUUUUUUUUUUUUUUUUUU")
	emote_see = list("stumbles around.", "shivers.")
	emote_hear = list("howls!","groans.")
	desc = "Spooky!"
	obj_icon_state = "sheet"

/datum/dog_fashion/head/santa
	name = "Santa's Corgi Helper"
	emote_hear = list("barks Christmas songs.", "yaps merrily!")
	emote_see = list("looks for presents.", "checks his list.")
	desc = "He's very fond of milk and cookies."

/datum/dog_fashion/head/cargo_tech
	name = "Corgi Tech REAL_NAME"
	desc = "The reason your yellow gloves have chew-marks."

/datum/dog_fashion/head/softcap

/datum/dog_fashion/head/reindeer
	name = "REAL_NAME the red-nosed Corgi"
	emote_hear = list("lights the way!", "illuminates.", "yaps!")
	desc = "He has a very shiny nose."

/datum/dog_fashion/head/reindeer/apply(mob/living/simple_animal/pet/dog/D)
	..()
	D.set_light(2, 2, LIGHT_COLOR_RED)

/datum/dog_fashion/head/sombrero
	name = "Segnor REAL_NAME"
	desc = "You must respect Elder Dogname."

/datum/dog_fashion/head/sombrero/New(mob/M)
	..()
	desc = "You must respect Elder [M.real_name]."

/datum/dog_fashion/head/hop
	name = "Lieutenant REAL_NAME"
	desc = "Can actually be trusted to not run off on his own."

/datum/dog_fashion/head/deathsquad
	name = "Trooper REAL_NAME"
	desc = "That's not red paint. That's real corgi blood."

/datum/dog_fashion/head/clown
	name = "REAL_NAME the Clown"
	desc = "Honkman's best friend."
	speak = list("HONK!", "Honk!")
	emote_see = list("plays tricks.", "slips.")

/datum/dog_fashion/back/deathsquad
	name = "Trooper REAL_NAME"
	desc = "That's not red paint. That's real corgi blood."

/datum/dog_fashion/head/not_ian
	name = "Definitely Not REAL_NAME"
	desc = "That's Definitely Not Dogname."

/datum/dog_fashion/head/not_ian/New(mob/M)
	..()
	desc = "That's Definitely Not [M.real_name]."

/datum/dog_fashion/head/cone
	name = "REAL_NAME"
	desc = "Omnicone's Chosen Champion."

/datum/dog_fashion/head/fried_vox_empty
	name = "Colonel REAL_NAME"
	desc = "Keep away from live vox."

/datum/dog_fashion/head/hos
	name = "Head of Security REAL_NAME"
	desc = "Probably better than the last HoS."

/datum/dog_fashion/head/beret/sec
	name = "Officer REAL_NAME"
	desc = "Ever-loyal, ever-vigilant."

/datum/dog_fashion/head/bowlerhat
	name = "REAL_NAME"
	desc = "A sophisticated city gent."

/datum/dog_fashion/head/surgery
	name = "Nurse-in-Training REAL_NAME"
	desc = "The most adorable bed-side manner ever."

/datum/dog_fashion/head/bucket
	name = "REAL_NAME"
	desc = "A janitor's best friend."

/datum/dog_fashion/head/justice_wig
	name = "Arbiter REAL_NAME"
	desc = "Head of the High Court of Cute."

/datum/dog_fashion/head/wizard/magus
	name = "Battlemage REAL_NAME"

/datum/dog_fashion/head/wizard/marisa
	name = "Witch REAL_NAME"
	desc = "Flying broom not included."

/datum/dog_fashion/head/roman
	name = "Imperator REAL_NAME"
	desc = "For the Senate and the people of Rome!"

/datum/dog_fashion/head/qm
	name = "Supplymaster REAL_NAME"
	desc = "A loyal watchdog for the most secure transportation."

/datum/dog_fashion/head/smith
	name = "Metalworker REAL_NAME"
	desc = "Whatever you do, don't let them hold the hot metal in their mouth."

/datum/dog_fashion/head/cmo
	name = "Head Surgeon REAL_NAME"
	desc = "The only one you can truly trust to perform surgery efficiently and cleanly."

/datum/dog_fashion/head/rd
	name = "Director REAL_NAME"
	desc = "The smartest puppy around."

/datum/dog_fashion/head/miningsoft
	name = "Spelunker REAL_NAME"
	desc = "Legions are just like walking chew toys for him."

/datum/dog_fashion/head/paramedic
	name = "EMT REAL_NAME"
	desc = "They will always find help when you need it."
