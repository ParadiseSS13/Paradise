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

/datum/dog_fashion/proc/get_overlay(var/dir)
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

/datum/dog_fashion/head/helmet
	name = "Sargento REAL_NAME"
	desc = "El siempre-leal, el siempre-vigilante."

/datum/dog_fashion/head/chef
	name = "Sous chef REAL_NAME"
	desc = "Tu comida sera probada con sabor.  Toda ella."


/datum/dog_fashion/head/captain
	name = "Capitan REAL_NAME"
	desc = "Probablemente mejor que el ultimo capitan."

/datum/dog_fashion/head/kitty
	name = "Runtime"
	emote_see = list("coughs up a furball", "stretches")
	emote_hear = list("purrs")
	speak = list("Purrr", "Meow!", "MAOOOOOW!", "HISSSSS", "MEEEEEEW")
	desc = "Es un lindo pequenio gatito! ... espera ... pero que demonios?"

/datum/dog_fashion/head/rabbit
	name = "Hoppy"
	emote_see = list("twitches its nose", "hops around a bit")
	desc = "Este es Hoppy. Es un corgi-...ummm... conejito."

/datum/dog_fashion/head/beret
	name = "Yann"
	desc = "Mon dieu! C'est un chien!"
	speak = list("le woof!", "le bark!", "JAPPE!!")
	emote_see = list("cowers in fear.", "surrenders.", "plays dead.","looks as though there is a wall in front of him.")


/datum/dog_fashion/head/detective
	name = "Detective REAL_NAME"
	desc = "NAME ve a traves de tus mentiras..."
	emote_see = list("investigates the area.","sniffs around for clues.","searches for scooby snacks.","takes a candycorn from the hat.")


/datum/dog_fashion/head/nurse
	name = "Enfermero REAL_NAME"
	desc = "NAME necesita 100cc de carne seca... ahora!"

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
	desc = "Un seguidor de of Karl Barx."
	emote_see = list("contemplates the failings of the capitalist economic model.", "ponders the pros and cons of vanguardism.")

/datum/dog_fashion/head/ushanka/New(mob/M)
	..()
	name = "[pick("Comrade","Commissar","Glorious Leader")] [M.real_name]"

/datum/dog_fashion/head/warden
	name = "Oficial REAL_NAME"
	emote_see = list("drools.","looks for donuts.")
	desc = "Detente justo ahi, escoria criminal!"

/datum/dog_fashion/head/blue_wizard
	name = "Gran Mago REAL_NAME"
	speak = list("YAP", "Woof!", "Bark!", "AUUUUUU", "EI  NATH!")

/datum/dog_fashion/head/red_wizard
	name = "Pyromancer REAL_NAME"
	speak = list("YAP", "Woof!", "Bark!", "AUUUUUU", "ONI SOMA!")

/datum/dog_fashion/head/cardborg
	name = "Borgi"
	speak = list("Ping!","Beep!","Woof!")
	emote_see = list("goes rogue.", "sniffs out non-humans.")
	desc = "Resultado de los recortes presupuestarios de robotica."

/datum/dog_fashion/head/ghost
	name = "\improper Fantasma"
	speak = list("WoooOOOooo~","AUUUUUUUUUUUUUUUUUU")
	emote_see = list("stumbles around.", "shivers.")
	emote_hear = list("howls!","groans.")
	desc = "Escalofriante!"
	obj_icon_state = "sheet"

/datum/dog_fashion/head/santa
	name = "Santa's Corgi Helper"
	emote_hear = list("barks Christmas songs.", "yaps merrily!")
	emote_see = list("looks for presents.", "checks his list.")
	desc = "Le gusta mucho la leche y las galletas."

/datum/dog_fashion/head/cargo_tech
	name = "Corgi Tech REAL_NAME"
	desc = "La razon por la que tus guantes amarillos tienen marcas de masticacion."

/datum/dog_fashion/head/reindeer
	name = "REAL_NAME el Corgi de nariz roja"
	emote_hear = list("lights the way!", "illuminates.", "yaps!")
	desc = "Tiene una nariz muy brillante."

/datum/dog_fashion/head/reindeer/apply(mob/living/simple_animal/pet/dog/D)
	..()
	D.set_light(2, 2, LIGHT_COLOR_RED)

/datum/dog_fashion/head/sombrero
	name = "Señor REAL_NAME"
	desc = "Debes respetar al Anciano Dogname"

/datum/dog_fashion/head/sombrero/New(mob/M)
	..()
	desc = "Debes respetar al Anciano [M.real_name]."

/datum/dog_fashion/head/hop
	name = "Teniente REAL_NAME"
	desc = "Puedes confiar en que no huira solo."

/datum/dog_fashion/head/deathsquad
	name = "Soldado REAL_NAME"
	desc = "Eso no es pintura roja. Eso es sangre de corgi real."

/datum/dog_fashion/head/clown
	name = "REAL_NAME el Payaso"
	desc = "El mejor amigo del hombre Honk."
	speak = list("HONK!", "Honk!")
	emote_see = list("plays tricks.", "slips.")

/datum/dog_fashion/back/deathsquad
	name = "Trooper REAL_NAME"
	desc = "That's not red paint. That's real corgi blood."

/datum/dog_fashion/head/not_ian
	name = "Definitivamente no REAL_NAME"
	desc = "Ese es Definitivamente no Dogname"

/datum/dog_fashion/head/not_ian/New(mob/M)
	..()
	desc = "That's Definitely Not [M.real_name]."

/datum/dog_fashion/back/hardsuit
	name = "Explorador Espacial REAL_NAME"
	desc = "Este es un pequeño paso para un corgi. Un ladrido gigante para su especie."

/datum/dog_fashion/back/hardsuit/apply(mob/living/simple_animal/pet/dog/D)
	..()
	D.mutations.Add(BREATHLESS)
	D.atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	D.minbodytemp = 0
