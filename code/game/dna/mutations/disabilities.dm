/////////////////////
// DISABILITY MUTATIONS
//
//
//
// Mutation is always activated.
/////////////////////

/datum/mutation/disability
	name = "DISABILITY"

/datum/mutation/disability/can_activate(mob/M, flags)
	return TRUE // Always set!

/datum/mutation/disability/hallucinate
	name = "Hallucinate"
	activation_messages = list("Your mind says 'Hello'.")
	deactivation_messages = list("Sanity returns. Or does it?")
	instability = -GENE_INSTABILITY_MAJOR

/datum/mutation/disability/hallucinate/New()
	..()
	block = GLOB.hallucinationblock

/datum/mutation/disability/hallucinate/on_life(mob/living/carbon/human/H)
	if(prob(1))
		H.AdjustHallucinate(45 SECONDS)

/datum/mutation/disability/epilepsy
	name = "Epilepsy"
	activation_messages = list("You get a headache.")
	deactivation_messages = list("Your headache is gone, at last.")
	instability = -GENE_INSTABILITY_MODERATE

/datum/mutation/disability/epilepsy/New()
	..()
	block = GLOB.epilepsyblock

/datum/mutation/disability/epilepsy/on_life(mob/living/carbon/human/H)
	if((prob(1) && !H.IsParalyzed()))
		H.visible_message("<span class='danger'>[H] starts having a seizure!</span>","<span class='alert'>You have a seizure!</span>")
		H.Paralyse(20 SECONDS)
		H.Jitter(2000 SECONDS)

/datum/mutation/disability/cough
	name = "Coughing"
	activation_messages = list("You start coughing.")
	deactivation_messages = list("Your throat stops aching.")
	instability = -GENE_INSTABILITY_MINOR

/datum/mutation/disability/cough/New()
	..()
	block = GLOB.coughblock

/datum/mutation/disability/cough/on_life(mob/living/carbon/human/H)
	if((prob(5) && H.AmountParalyzed() <= 1))
		H.drop_item()
		H.emote("cough")

/datum/mutation/disability/clumsy
	name = "Clumsiness"
	activation_messages = list("You feel lightheaded.")
	deactivation_messages = list("You regain some control of your movements")
	instability = -GENE_INSTABILITY_MODERATE
	traits_to_add = list(TRAIT_CLUMSY)

/datum/mutation/disability/clumsy/New()
	..()
	block = GLOB.clumsyblock

/datum/mutation/disability/nervousness
	name = "Nervousness"
	activation_messages = list("You feel nervous.")
	deactivation_messages = list("You feel much calmer.")

/datum/mutation/disability/nervousness/New()
	..()
	block = GLOB.nervousblock

/datum/mutation/disability/nervousness/on_life(mob/living/carbon/human/H)
	if(prob(10))
		H.Stuttering(20 SECONDS)

/datum/mutation/disability/blindness
	name = "Blindness"
	activation_messages = list("You can't seem to see anything.")
	deactivation_messages = list("You can see now, in case you didn't notice...")
	instability = -GENE_INSTABILITY_MAJOR
	traits_to_add = list(TRAIT_BLIND)

/datum/mutation/disability/blindness/New()
	..()
	block = GLOB.blindblock

/datum/mutation/disability/blindness/activate(mob/M)
	..()
	M.update_blind_effects()

/datum/mutation/disability/blindness/deactivate(mob/M)
	..()
	M.update_blind_effects()

/datum/mutation/disability/colourblindness
	name = "Colourblindness"
	activation_messages = list("You feel a peculiar prickling in your eyes while your perception of colour changes.")
	deactivation_messages = list("Your eyes tingle unsettlingly, though everything seems to become a lot more colourful.")
	instability = -GENE_INSTABILITY_MINOR
	traits_to_add = list(TRAIT_COLORBLIND)

/datum/mutation/disability/colourblindness/New()
	..()
	block = GLOB.colourblindblock

/datum/mutation/disability/colourblindness/activate(mob/M)
	..()
	M.update_client_colour() //Handle the activation of the colourblindness on the mob.
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.update_misc_effects()

/datum/mutation/disability/colourblindness/deactivate(mob/M)
	..()
	M.update_client_colour() //Handle the deactivation of the colourblindness on the mob.
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.update_misc_effects()

/datum/mutation/disability/deaf
	name = "Deafness"
	activation_messages = list("It's kinda quiet.")
	deactivation_messages = list("You can hear again!")
	instability = -GENE_INSTABILITY_MAJOR
	traits_to_add = list(TRAIT_DEAF)

/datum/mutation/disability/deaf/New()
	..()
	block = GLOB.deafblock

/datum/mutation/disability/nearsighted
	name = "Nearsightedness"
	activation_messages = list("Your eyes feel weird...")
	deactivation_messages = list("You can see clearly now")
	instability = -GENE_INSTABILITY_MODERATE
	traits_to_add = list(TRAIT_NEARSIGHT)

/datum/mutation/disability/nearsighted/New()
	..()
	block = GLOB.glassesblock

/datum/mutation/disability/nearsighted/activate(mob/living/M)
	..()
	M.update_nearsighted_effects()

/datum/mutation/disability/nearsighted/deactivate(mob/living/M)
	..()
	M.update_nearsighted_effects()

/datum/mutation/disability/lisp
	name = "Lisp"
	desc = "I wonder wath thith doeth."
	activation_messages = list("Thomething doethn't feel right.")
	deactivation_messages = list("You now feel able to pronounce consonants.")

/datum/mutation/disability/lisp/New()
	..()
	block = GLOB.lispblock

/datum/mutation/disability/lisp/on_say(mob/M, message)
	return replacetext(message,"s","th")

/datum/mutation/disability/comic
	name = "Comic"
	desc = "This will only bring death and destruction."
	activation_messages = list("<span class='sans'>Uh oh!</span>")
	deactivation_messages = list("Well thank god that's over with.")
	traits_to_add = list(TRAIT_COMIC_SANS)

/datum/mutation/disability/comic/New()
	..()
	block = GLOB.comicblock

/datum/mutation/disability/wingdings
	name = "Alien Voice"
	desc = "Garbles the subject's voice into an incomprehensible speech."
	activation_messages = list("<span class='wingdings'>Your vocal cords feel alien.</span>")
	deactivation_messages = list("Your vocal cords no longer feel alien.")
	instability = -GENE_INSTABILITY_MODERATE
	traits_to_add = list(TRAIT_WINGDINGS)

/datum/mutation/disability/wingdings/New()
	..()
	block = GLOB.wingdingsblock

/datum/mutation/disability/wingdings/on_say(mob/M, message)
	var/garbled_message = ""
	for(var/i in 1 to length(message))
		if(message[i] in GLOB.alphabet_uppercase)
			garbled_message += pick(GLOB.alphabet_uppercase)
		else if(message[i] in GLOB.alphabet)
			garbled_message += pick(GLOB.alphabet)
		else
			garbled_message += message[i]
	message = garbled_message
	return message

//////////////////
// DISABILITIES //
//////////////////

////////////////////////////////////////
// MARK: Totally Crippling
////////////////////////////////////////

// WAS: /datum/bioEffect/mute
/datum/mutation/disability/mute
	name = "Mute"
	desc = "Completely shuts down the speech center of the subject's brain."
	activation_messages = list("You feel unable to express yourself at all.")
	deactivation_messages = list("You feel able to speak freely again.")
	instability = -GENE_INSTABILITY_MAJOR
	traits_to_add = list(TRAIT_MUTE)

/datum/mutation/disability/mute/New()
	..()
	block = GLOB.muteblock

/datum/mutation/disability/mute/on_say(mob/M, message)
	return ""

/datum/mutation/disability/paraplegic
	name = "Paraplegic"
	desc = "Your legs don't work, even with prosthetics."
	activation_messages = list("MY LEG!")
	deactivation_messages = list("You can feel your legs again.")
	instability = -GENE_INSTABILITY_MAJOR
	traits_to_add = list(TRAIT_PARAPLEGIC)

/datum/mutation/disability/paraplegic/New()
	..()
	block = GLOB.paraplegicblock

////////////////////////////////////////
// MARK: Harmful to everyone
////////////////////////////////////////

/datum/mutation/disability/radioactive
	name = "Radioactive"
	desc = "The subject suffers from constant radiation sickness and causes the same on nearby organics."
	activation_messages = list("You feel a strange sickness permeate your whole body.")
	deactivation_messages = list("You no longer feel awful and sick all over.")
	instability = -GENE_INSTABILITY_MAJOR

/datum/mutation/disability/radioactive/New()
	..()
	block = GLOB.radblock


/datum/mutation/disability/radioactive/can_activate(mob/M, flags)
	if(!..())
		return FALSE
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(HAS_TRAIT(H, TRAIT_RADIMMUNE) && !(flags & MUTCHK_FORCED))
			return FALSE
	return TRUE

/datum/mutation/disability/radioactive/on_life(mob/living/carbon/human/H)
	radiation_pulse(H, 80, ALPHA_RAD)

/datum/mutation/disability/radioactive/on_draw_underlays(mob/M, g)
	return "rads_s"

////////////////////////////////////////
// MARK: Other disabilities
////////////////////////////////////////

// WAS: /datum/bioEffect/fat
/datum/mutation/disability/fat
	name = "Obesity"
	desc = "Greatly slows the subject's metabolism, enabling greater buildup of lipid tissue."
	activation_messages = list("You feel blubbery and lethargic!")
	deactivation_messages = list("You feel fit!")
	traits_to_add = list(TRAIT_SLOWDIGESTION)

/datum/mutation/disability/fat/New()
	..()
	block = GLOB.fatblock

// WAS: /datum/bioEffect/chav
/datum/mutation/disability/speech/chav
	name = "Chav"
	desc = "Forces the language center of the subject's brain to construct sentences in a more rudimentary manner."
	activation_messages = list("Ye feel like a rite prat like, innit?")
	deactivation_messages = list("You no longer feel like being rude and sassy.")
	traits_to_add = list(TRAIT_CHAV)
	//List of swappable words. Normal word first, chav word second.
	var/static/list/chavlinks = list(
	"arrest" = "nick",
	"arrested" = "nicked",
	"ass" = "arse",
	"bad" = "pants",
	"bar" = "spoons",
	"brain" = "noggin",
	"break" = "smash",
	"broke" = "smashed",
	"broken" = "gone kaput",
	"comdom" = "knob'ed",
	"cool" = "ace",
	"crazy" = "well mad",
	"cup of tea" = "cuppa",
	"destroyed" = "rekt",
	"dick" = "prat",
	"disappointed" = "gutted",
	"disgusting" = "minging",
	"disposals" = "bins",
	"drink" = "bevvy",
	"engineer" = "sparky",
	"excited" = "jacked",
	"fight" = "scuffle",
	"food" = "nosh",
	"friend" = "blud",
	"fuck" = "fook",
	"get" = "giz",
	"girl" = "bird",
	"go away" = "jog on",
	"good" = "mint",
	"great" = "bangin'",
	"happy" = "chuffed",
	"hello" = "orite",
	"hi" = "sup",
	"idiot" = "twit",
	"isn't it" = "innit",
	"kill" = "bang",
	"killed" = "banged",
	"man" = "bloke",
	"mess" = "shambles",
	"mistake" = "cock-up",
	"murder" = "hench",
	"murdered" = "henched",
	"no" = "naw",
	"really" = "propa",
	"robust" = "'ard",
	"run" = "leg it",
	"sec" = "cops",
	"security" = "coppers",
	"silly" = "daft",
	"steal" = "nick",
	"stole" = "nicked",
	"surprised" = "gobsmacked",
	"suspicious" = "dodgy",
	"tired" = "knackered",
	"wet" = "moist",
	"what" = "wot",
	"window" = "windy",
	"windows" = "windies",
	"yes" = "ye",
	"yikes" = "blimey",
	"your" = "yur"
	)

/datum/mutation/disability/speech/chav/New()
	..()
	block = GLOB.chavblock

/datum/mutation/disability/speech/chav/on_say(mob/M, message)
	var/static/regex/R = regex("\\b([chavlinks.Join("|")])\\b", "g")
	message = R.Replace(message, /datum/mutation/disability/speech/chav/proc/replace_speech)
	return message

/datum/mutation/disability/speech/chav/proc/replace_speech(matched)
	REGEX_REPLACE_HANDLER
	return chavlinks[matched]

// WAS: /datum/bioEffect/swedish
/datum/mutation/disability/speech/swedish
	name = "Swedish"
	desc = "Forces the language center of the subject's brain to construct sentences in a vaguely norse manner."
	activation_messages = list("You feel Swedish, however that works.")
	deactivation_messages = list("The feeling of Swedishness passes.")

/datum/mutation/disability/speech/swedish/New()
	..()
	block = GLOB.swedeblock

/datum/mutation/disability/speech/swedish/on_say(mob/living/M, message)
	// svedish
	message = replacetextEx(message,"W","V")
	message = replacetextEx(message,"w","v")
	message = replacetextEx(message,"J","Y")
	message = replacetextEx(message,"j","y")
	message = replacetextEx(message,"A",pick("Å","Ä","Æ","A"))
	message = replacetextEx(message,"a",pick("å","ä","æ","a"))
	message = replacetextEx(message,"BO","BJO")
	message = replacetextEx(message,"Bo","Bjo")
	message = replacetextEx(message,"bo","bjo")
	message = replacetextEx(message,"O",pick("Ö","Ø","O"))
	message = replacetextEx(message,"o",pick("ö","ø","o"))
	if(prob(30) && !M.is_muzzled() && !M.is_facehugged())
		message += " Bork[pick("",", bork",", bork, bork")]!"
	return message

// WAS: /datum/bioEffect/unintelligable
/datum/mutation/disability/unintelligable
	name = "Unintelligable"
	desc = "Heavily corrupts the part of the brain responsible for forming spoken sentences."
	activation_messages = list("You can't seem to form any coherent thoughts!")
	deactivation_messages = list("Your mind feels more clear.")
	instability = -GENE_INSTABILITY_MINOR

/datum/mutation/disability/unintelligable/New()
	..()
	block = GLOB.scrambleblock

/datum/mutation/disability/unintelligable/on_say(mob/M, message)
	var/prefix = copytext(message,1,2)
	if(prefix == ";")
		message = copytext(message,2)
	else if(prefix in list(":","#"))
		prefix += copytext(message,2,3)
		message = copytext(message,3)
	else
		prefix=""

	var/list/words = splittext(message," ")
	var/list/rearranged = list()
	for(var/i=1;i<=length(words);i++)
		var/cword = pick(words)
		words.Remove(cword)
		var/suffix = copytext(cword,length(cword)-1,length(cword))
		while(length(cword)>0 && (suffix in list(".",",",";","!",":","?")))
			cword  = copytext(cword,1              ,length(cword)-1)
			suffix = copytext(cword,length(cword)-1,length(cword)  )
		if(length(cword))
			rearranged += cword
	return "[prefix][uppertext(jointext(rearranged," "))]!!"

//////////////////
// MARK: USELESS SHIT
//////////////////

// WAS: /datum/bioEffect/strong
/datum/mutation/disability/strong
	// pretty sure this doesn't do jack shit, putting it here until it does
	name = "Strong"
	desc = "Enhances the subject's ability to build and retain heavy muscles."
	activation_messages = list("You feel buff!")
	deactivation_messages = list("You feel wimpy and weak.")

/datum/mutation/disability/strong/New()
	..()
	block = GLOB.strongblock

// WAS: /datum/bioEffect/horns
/datum/mutation/disability/horns
	name = "Horns"
	desc = "Enables the growth of a compacted keratin formation on the subject's head."
	activation_messages = list("A pair of horns erupt from your head.")
	deactivation_messages = list("Your horns crumble away into nothing.")

/datum/mutation/disability/horns/New()
	..()
	block = GLOB.hornsblock

/datum/mutation/disability/horns/on_draw_underlays(mob/M, g)
	return "horns_s"

/datum/mutation/grant_spell/immolate
	name = "Incendiary Mitochondria"
	desc = "The subject becomes able to convert excess cellular energy into thermal energy."
	activation_messages = list("You suddenly feel rather hot.")
	deactivation_messages = list("You no longer feel uncomfortably hot.")
	spelltype = /datum/spell/immolate

/datum/mutation/grant_spell/immolate/New()
	..()
	block = GLOB.immolateblock

/datum/spell/immolate
	name = "Incendiary Mitochondria"
	desc = "The subject becomes able to convert excess cellular energy into thermal energy."

	base_cooldown = 600

	clothes_req = FALSE
	var/list/compatible_mobs = list(/mob/living/carbon/human)

	action_icon_state = "genetic_incendiary"

/datum/spell/immolate/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/immolate/cast(list/targets, mob/living/user = usr)
	var/mob/living/carbon/L = user
	L.adjust_fire_stacks(0.5)
	L.visible_message("<span class='danger'>[L.name]</b> suddenly bursts into flames!</span>")
	L.IgniteMob()
	playsound(L.loc, 'sound/effects/bamf.ogg', 50, 0)

/datum/mutation/disability/speech/loud
	name = "Loud"
	desc = "Forces the speaking centre of the subjects brain to yell every sentence."
	activation_messages = list("YOU FEEL LIKE YELLING!")
	deactivation_messages = list("You feel like being quiet..")

/datum/mutation/disability/speech/loud/New()
	..()
	block = GLOB.loudblock



/datum/mutation/disability/speech/loud/on_say(mob/M, message)
	message = replacetext(message,".","!")
	message = replacetext(message,"?","?!")
	message = replacetext(message,"!","!!")
	return uppertext(message)

/datum/mutation/disability/dizzy
	name = "Dizzy"
	desc = "Causes the cerebellum to shut down in some places."
	activation_messages = list("You feel very dizzy...")
	deactivation_messages = list("You regain your balance.")
	instability = -GENE_INSTABILITY_MODERATE

/datum/mutation/disability/dizzy/New()
	..()
	block = GLOB.dizzyblock


/datum/mutation/disability/dizzy/on_life(mob/living/carbon/human/M)
	if(!istype(M))
		return
	M.Dizzy(600 SECONDS)

/datum/mutation/disability/dizzy/deactivate(mob/living/M)
	..()
	M.SetDizzy(0)
