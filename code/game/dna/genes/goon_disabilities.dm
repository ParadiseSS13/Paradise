//////////////////
// DISABILITIES //
//////////////////

////////////////////////////////////////
// Totally Crippling
////////////////////////////////////////

// WAS: /datum/bioEffect/mute
/datum/dna/gene/disability/mute
	name = "Mute"
	desc = "Completely shuts down the speech center of the subject's brain."
	activation_message   = "You feel unable to express yourself at all."
	deactivation_message = "You feel able to speak freely again."
	instability = -GENE_INSTABILITY_MODERATE
	disability = MUTE

/datum/dna/gene/disability/mute/New()
	..()
	block=MUTEBLOCK

/datum/dna/gene/disability/mute/OnSay(var/mob/M, var/message)
	return ""

////////////////////////////////////////
// Harmful to others as well as self
////////////////////////////////////////

/datum/dna/gene/disability/radioactive
	name = "Radioactive"
	desc = "The subject suffers from constant radiation sickness and causes the same on nearby organics."
	activation_message = "You feel a strange sickness permeate your whole body."
	deactivation_message = "You no longer feel awful and sick all over."
	instability = -GENE_INSTABILITY_MAJOR
	mutation = RADIOACTIVE

/datum/dna/gene/disability/radioactive/New()
	..()
	block=RADBLOCK


/datum/dna/gene/disability/radioactive/can_activate(var/mob/M,var/flags)
	if(!..())
		return 0
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if((RADIMMUNE in H.dna.species.species_traits) && !(flags & MUTCHK_FORCED))
			return 0
	return 1

/datum/dna/gene/disability/radioactive/OnMobLife(var/mob/living/owner)
	var/radiation_amount = abs(min(owner.radiation - 20,0))
	owner.apply_effect(radiation_amount, IRRADIATE)
	for(var/mob/living/L in range(1, owner))
		if(L == owner)
			continue
		to_chat(L, "<span class='danger'>You are enveloped by a soft green glow emanating from [owner].</span>")
		L.apply_effect(5, IRRADIATE)
	return

/datum/dna/gene/disability/radioactive/OnDrawUnderlays(var/mob/M,var/g,var/fat)
	return "rads[fat]_s"

////////////////////////////////////////
// Other disabilities
////////////////////////////////////////

// WAS: /datum/bioEffect/fat
/datum/dna/gene/disability/fat
	name = "Obesity"
	desc = "Greatly slows the subject's metabolism, enabling greater buildup of lipid tissue."
	activation_message = "You feel blubbery and lethargic!"
	deactivation_message = "You feel fit!"
	instability = -GENE_INSTABILITY_MINOR
	mutation = OBESITY

/datum/dna/gene/disability/fat/New()
	..()
	block=FATBLOCK

// WAS: /datum/bioEffect/chav
/datum/dna/gene/disability/speech/chav
	name = "Chav"
	desc = "Forces the language center of the subject's brain to construct sentences in a more rudimentary manner."
	activation_message = "Ye feel like a reet prat like, innit?"
	deactivation_message = "You no longer feel like being rude and sassy."
	mutation = CHAV

/datum/dna/gene/disability/speech/chav/New()
	..()
	block=CHAVBLOCK

/datum/dna/gene/disability/speech/chav/OnSay(var/mob/M, var/message)
	// THIS ENTIRE THING BEGS FOR REGEX
	message = replacetext(message,"dick","prat")
	message = replacetext(message,"comdom","knob'ead")
	message = replacetext(message,"looking at","gawpin' at")
	message = replacetext(message,"great","bangin'")
	message = replacetext(message,"man","mate")
	message = replacetext(message,"friend",pick("mate","bruv","bledrin"))
	message = replacetext(message,"what","wot")
	message = replacetext(message,"drink","wet")
	message = replacetext(message,"get","giz")
	message = replacetext(message,"what","wot")
	message = replacetext(message,"no thanks","wuddent fukken do one")
	message = replacetext(message,"i don't know","wot mate")
	message = replacetext(message,"no","naw")
	message = replacetext(message,"robust","chin")
	message = replacetext(message," hi ","how what how")
	message = replacetext(message,"hello","sup bruv")
	message = replacetext(message,"kill","bang")
	message = replacetext(message,"murder","bang")
	message = replacetext(message,"windows","windies")
	message = replacetext(message,"window","windy")
	message = replacetext(message,"break","do")
	message = replacetext(message,"your","yer")
	message = replacetext(message,"security","coppers")
	return message

// WAS: /datum/bioEffect/swedish
/datum/dna/gene/disability/speech/swedish
	name = "Swedish"
	desc = "Forces the language center of the subject's brain to construct sentences in a vaguely norse manner."
	activation_message = "You feel Swedish, however that works."
	deactivation_message = "The feeling of Swedishness passes."
	mutation = SWEDISH

/datum/dna/gene/disability/speech/swedish/New()
	..()
	block=SWEDEBLOCK

/datum/dna/gene/disability/speech/swedish/OnSay(var/mob/M, var/message)
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
	if(prob(30) && !M.is_muzzled())
		message += " Bork[pick("",", bork",", bork, bork")]!"
	return message

// WAS: /datum/bioEffect/unintelligable
/datum/dna/gene/disability/unintelligable
	name = "Unintelligable"
	desc = "Heavily corrupts the part of the brain responsible for forming spoken sentences."
	activation_message = "You can't seem to form any coherent thoughts!"
	deactivation_message = "Your mind feels more clear."
	instability = -GENE_INSTABILITY_MINOR
	mutation = SCRAMBLED

/datum/dna/gene/disability/unintelligable/New()
	..()
	block=SCRAMBLEBLOCK

/datum/dna/gene/disability/unintelligable/OnSay(var/mob/M, var/message)
	var/prefix=copytext(message,1,2)
	if(prefix == ";")
		message = copytext(message,2)
	else if(prefix in list(":","#"))
		prefix += copytext(message,2,3)
		message = copytext(message,3)
	else
		prefix=""

	var/list/words = splittext(message," ")
	var/list/rearranged = list()
	for(var/i=1;i<=words.len;i++)
		var/cword = pick(words)
		words.Remove(cword)
		var/suffix = copytext(cword,length(cword)-1,length(cword))
		while(length(cword)>0 && suffix in list(".",",",";","!",":","?"))
			cword  = copytext(cword,1              ,length(cword)-1)
			suffix = copytext(cword,length(cword)-1,length(cword)  )
		if(length(cword))
			rearranged += cword
	return "[prefix][uppertext(jointext(rearranged," "))]!!"

//////////////////
// USELESS SHIT //
//////////////////

// WAS: /datum/bioEffect/strong
/datum/dna/gene/disability/strong
	// pretty sure this doesn't do jack shit, putting it here until it does
	name = "Strong"
	desc = "Enhances the subject's ability to build and retain heavy muscles."
	activation_message = "You feel buff!"
	deactivation_message = "You feel wimpy and weak."
	mutation = STRONG

/datum/dna/gene/disability/strong/New()
	..()
	block=STRONGBLOCK

// WAS: /datum/bioEffect/horns
/datum/dna/gene/disability/horns
	name = "Horns"
	desc = "Enables the growth of a compacted keratin formation on the subject's head."
	activation_message = "A pair of horns erupt from your head."
	deactivation_message = "Your horns crumble away into nothing."
	mutation = HORNS

/datum/dna/gene/disability/horns/New()
	..()
	block=HORNSBLOCK

/datum/dna/gene/disability/horns/OnDrawUnderlays(var/mob/M,var/g,var/fat)
	return "horns_s"

////////////////////////////////////////////////////////////////////////
// WAS: /datum/bioEffect/immolate
/datum/dna/gene/basic/grant_spell/immolate
	name = "Incendiary Mitochondria"
	desc = "The subject becomes able to convert excess cellular energy into thermal energy."
	activation_messages = list("You suddenly feel rather hot.")
	deactivation_messages = list("You no longer feel uncomfortably hot.")
	mutation = IMMOLATE

	spelltype=/obj/effect/proc_holder/spell/targeted/immolate

/datum/dna/gene/basic/grant_spell/immolate/New()
	..()
	block = IMMOLATEBLOCK

/obj/effect/proc_holder/spell/targeted/immolate
	name = "Incendiary Mitochondria"
	desc = "The subject becomes able to convert excess cellular energy into thermal energy."
	panel = "Abilities"

	charge_type = "recharge"
	charge_max = 600

	clothes_req = 0
	stat_allowed = 0
	invocation_type = "none"
	range = -1
	selection_type = "range"
	var/list/compatible_mobs = list(/mob/living/carbon/human)
	include_user = 1

	action_icon_state = "genetic_incendiary"

/obj/effect/proc_holder/spell/targeted/immolate/cast(list/targets, mob/living/user = usr)
	var/mob/living/carbon/L = user
	L.adjust_fire_stacks(0.5)
	L.visible_message("<span class='danger'>[L.name]</b> suddenly bursts into flames!</span>")
	L.IgniteMob()
	playsound(L.loc, 'sound/effects/bamf.ogg', 50, 0)
