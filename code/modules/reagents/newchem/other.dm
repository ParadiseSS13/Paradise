#define SOLID 1
#define LIQUID 2
#define GAS 3
#define REM REAGENTS_EFFECT_MULTIPLIER

var/list/random_color_list = list("#00aedb","#a200ff","#f47835","#d41243","#d11141","#00b159","#00aedb","#f37735","#ffc425","#008744","#0057e7","#d62d20","#ffa700")

/datum/reagent/oil
	name = "Oil"
	id = "oil"
	description = "A decent lubricant for machines. High in benzene, naptha and other hydrocarbons."
	reagent_state = LIQUID
	color = "#3C3C3C"

/datum/reagent/iodine
	name = "Iodine"
	id = "iodine"
	description = "A purple gaseous element."
	reagent_state = GAS
	color = "#493062"

/datum/reagent/carpet
	name = "Carpet"
	id = "carpet"
	description = "A covering of thick fabric used on floors. This type looks particularly gross."
	reagent_state = LIQUID
	color = "#701345"

/datum/reagent/carpet/reaction_turf(turf/simulated/T, volume)
	if(istype(T, /turf/simulated/floor/plating) || istype(T, /turf/simulated/floor/plasteel))
		var/turf/simulated/floor/F = T
		F.ChangeTurf(/turf/simulated/floor/carpet)
	..()

/datum/reagent/bromine
	name = "Bromine"
	id = "bromine"
	description = "A red-brown liquid element."
	reagent_state = LIQUID
	color = "#4E3A3A"

/datum/reagent/phenol
	name = "Phenol"
	id = "phenol"
	description = "Also known as carbolic acid, this is a useful building block in organic chemistry."
	reagent_state = LIQUID
	color = "#525050"

/datum/reagent/ash
	name = "Ash"
	id = "ash"
	description = "Ashes to ashes, dust to dust."
	reagent_state = LIQUID
	color = "#191919"

/datum/reagent/acetone
	name = "Acetone"
	id = "acetone"
	description = "Pure 100% nail polish remover, also works as an industrial solvent."
	reagent_state = LIQUID
	color = "#474747"

/datum/reagent/acetone/on_mob_life(mob/living/M)
	M.adjustToxLoss(1.5)
	..()

/datum/chemical_reaction/acetone
	name = "acetone"
	id = "acetone"
	result = "acetone"
	required_reagents = list("oil" = 1, "fuel" = 1, "oxygen" = 1)
	result_amount = 3
	mix_message = "The smell of paint thinner assaults you as the solution bubbles."

/datum/chemical_reaction/carpet
	name = "carpet"
	id = "carpet"
	result = "carpet"
	required_reagents = list("fungus" = 1, "blood" = 1)
	result_amount = 2
	mix_message = "The substance turns thick and stiff, yet soft."


/datum/chemical_reaction/oil
	name = "Oil"
	id = "oil"
	result = "oil"
	required_reagents = list("fuel" = 1, "carbon" = 1, "hydrogen" = 1)
	result_amount = 3
	mix_message = "An iridescent black chemical forms in the container."

/datum/chemical_reaction/phenol
	name = "phenol"
	id = "phenol"
	result = "phenol"
	required_reagents = list("water" = 1, "chlorine" = 1, "oil" = 1)
	result_amount = 3
	mix_message = "The mixture bubbles and gives off an unpleasant medicinal odor."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/ash
	name = "Ash"
	id = "ash"
	result = "ash"
	required_reagents = list("oil" = 1)
	result_amount = 0.5
	min_temp = 480
	mix_sound = null
	no_message = 1

/datum/reagent/colorful_reagent
	name = "Colorful Reagent"
	id = "colorful_reagent"
	description = "It's pure liquid colors. That's a thing now."
	reagent_state = LIQUID
	color = "#FFFFFF"

/datum/chemical_reaction/colorful_reagent
	name = "colorful_reagent"
	id = "colorful_reagent"
	result = "colorful_reagent"
	required_reagents = list("plasma" = 1, "radium" = 1, "space_drugs" = 1, "cryoxadone" = 1, "triple_citrus" = 1, "stabilizing_agent" = 1)
	result_amount = 6
	mix_message = "The substance flashes multiple colors and emits the smell of a pocket protector."

/datum/reagent/colorful_reagent/reaction_mob(mob/living/simple_animal/M, method=TOUCH, volume)
    if(isanimal(M))
        M.color = pick(random_color_list)
    ..()

/datum/reagent/colorful_reagent/reaction_obj(obj/O, volume)
	if(O)
		O.color = pick(random_color_list)
	..()

/datum/reagent/colorful_reagent/reaction_turf(turf/T, volume)
	if(T)
		T.color = pick(random_color_list)
	..()

/datum/chemical_reaction/corgium
	name = "corgium"
	id = "corgium"
	result = null
	required_reagents = list("nutriment" = 1, "colorful_reagent" = 1, "strange_reagent" = 1, "blood" = 1)
	result_amount = 3
	min_temp = 374

/datum/reagent/corgium
	name = "Corgium"
	id = "corgium"
	description = "Corgi in liquid form. Don't ask."
	reagent_state = LIQUID
	color = "#F9A635"

/datum/chemical_reaction/corgium/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /mob/living/simple_animal/pet/corgi(location)
	..()

/datum/chemical_reaction/flaptonium
	name = "Flaptonium"
	id = "flaptonium"
	result = null
	required_reagents = list("egg" = 1, "colorful_reagent" = 1, "chicken_soup" = 1, "strange_reagent" = 1, "blood" = 1)
	result_amount = 5
	min_temp = 374
	mix_message = "The substance turns an airy sky-blue and foams up into a new shape."

/datum/chemical_reaction/flaptonium/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /mob/living/simple_animal/parrot(location)
	..()

/datum/reagent/hair_dye
	name = "Quantum Hair Dye"
	id = "hair_dye"
	description = "A rather tubular and gnarly way of coloring totally bodacious hair. Duuuudddeee."
	reagent_state = LIQUID
	color = "#960096"

/datum/chemical_reaction/hair_dye
	name = "hair_dye"
	id = "hair_dye"
	result = "hair_dye"
	required_reagents = list("colorful_reagent" = 1, "hairgrownium" = 1)
	result_amount = 2

/datum/reagent/hair_dye/reaction_mob(mob/living/M, volume)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/head/head_organ = H.get_organ("head")
		head_organ.r_facial = rand(0,255)
		head_organ.g_facial = rand(0,255)
		head_organ.b_facial = rand(0,255)
		head_organ.r_hair = rand(0,255)
		head_organ.g_hair = rand(0,255)
		head_organ.b_hair = rand(0,255)
		H.update_hair()
		H.update_fhair()
	..()

/datum/reagent/hairgrownium
	name = "Hairgrownium"
	id = "hairgrownium"
	description = "A mysterious chemical purported to help grow hair. Often found on late-night TV infomercials."
	reagent_state = LIQUID
	color = "#5DDA5D"
	penetrates_skin = 1

/datum/chemical_reaction/hairgrownium
	name = "hairgrownium"
	id = "hairgrownium"
	result = "hairgrownium"
	required_reagents = list("carpet" = 1, "synthflesh" = 1, "ephedrine" = 1)
	result_amount = 3
	mix_message = "The liquid becomes slightly hairy."

/datum/reagent/hairgrownium/reaction_mob(mob/living/M, volume)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/head/head_organ = H.get_organ("head")
		head_organ.h_style = random_hair_style(H.gender, head_organ.species.name)
		head_organ.f_style = random_facial_hair_style(H.gender, head_organ.species.name)
		H.update_hair()
		H.update_fhair()
	..()

/datum/reagent/super_hairgrownium
	name = "Super Hairgrownium"
	id = "super_hairgrownium"
	description = "A mysterious and powerful chemical purported to cause rapid hair growth."
	reagent_state = LIQUID
	color = "#5DD95D"
	penetrates_skin = 1


/datum/chemical_reaction/super_hairgrownium
	name = "Super Hairgrownium"
	id = "super_hairgrownium"
	result = "super_hairgrownium"
	required_reagents = list("iron" = 1, "methamphetamine" = 1, "hairgrownium" = 1)
	result_amount = 3
	mix_message = "The liquid becomes amazingly furry and smells peculiar."

/datum/reagent/super_hairgrownium/reaction_mob(mob/living/M, volume)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/head/head_organ = H.get_organ("head")
		var/datum/sprite_accessory/tmp_hair_style = hair_styles_list["Very Long Hair"]
		var/datum/sprite_accessory/tmp_facial_hair_style = facial_hair_styles_list["Very Long Beard"]

		if(head_organ.species.name in tmp_hair_style.species_allowed) //If 'Very Long Hair' is a style the person's species can have, give it to them.
			head_organ.h_style = "Very Long Hair"
		else //Otherwise, give them a random hair style.
			head_organ.h_style = random_hair_style(H.gender, head_organ.species.name)
		if(head_organ.species.name in tmp_facial_hair_style.species_allowed) //If 'Very Long Beard' is a style the person's species can have, give it to them.
			head_organ.f_style = "Very Long Beard"
		else //Otherwise, give them a random facial hair style.
			head_organ.f_style = random_facial_hair_style(H.gender, head_organ.species.name)
		H.update_hair()
		H.update_fhair()
		if(!H.wear_mask || H.wear_mask && !istype(H.wear_mask, /obj/item/clothing/mask/fakemoustache))
			if(H.wear_mask)
				H.unEquip(H.wear_mask)
			var/obj/item/clothing/mask/fakemoustache = new /obj/item/clothing/mask/fakemoustache
			H.equip_to_slot(fakemoustache, slot_wear_mask)
			to_chat(H, "<span class='notice'>Hair bursts forth from your every follicle!")
	..()

/datum/reagent/fartonium
	name = "Fartonium"
	id = "fartonium"
	description = "Oh god it never ends, IT NEVER STOPS!"
	reagent_state = GAS
	color = "#D06E27"

/datum/chemical_reaction/fartonium
	name = "Fartonium"
	id = "fartonium"
	result = "fartonium"
	required_reagents = list("fake_cheese" = 1, "beans" = 1, "????" = 1, "egg" = 1)
	result_amount = 2
	mix_message = "The substance makes a little 'toot' noise and starts to smell pretty bad."

/datum/reagent/fartonium/on_mob_life(mob/living/M)
	if(prob(66))
		M.emote("fart")

	if(holder.has_reagent("simethicone"))
		if(prob(25))
			to_chat(M, "<span class='danger'>[pick("Oh god, something doesn't feel right!", "IT HURTS!", "FUCK!", "Something is seriously wrong!", "THE PAIN!", "You feel like you're gonna die!")]</span>")
			M.adjustBruteLoss(1)
		if(prob(10))
			M.custom_emote(1,"strains, but nothing happens.")
			M.adjustBruteLoss(2)
		if(prob(5))
			M.emote("scream")
			M.adjustBruteLoss(4)
	..()

/datum/chemical_reaction/soapification
	name = "Soapification"
	id = "soapification"
	result = null
	required_reagents = list("liquidgibs" = 10, "lye"  = 10) // requires two scooped gib tiles
	min_temp = 374
	result_amount = 1


/datum/chemical_reaction/soapification/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/weapon/soap/homemade(location)

/datum/chemical_reaction/candlefication
	name = "Candlefication"
	id = "candlefication"
	result = null
	required_reagents = list("liquidgibs" = 5, "oxygen"  = 5) //
	min_temp = 374
	result_amount = 1

/datum/chemical_reaction/candlefication/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/candle(location)

/datum/chemical_reaction/meatification
	name = "Meatification"
	id = "meatification"
	result = null
	required_reagents = list("liquidgibs" = 10, "nutriment" = 10, "carbon" = 10)
	result_amount = 1

/datum/chemical_reaction/meatification/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/weapon/reagent_containers/food/snacks/meat/slab/meatproduct(location)

/datum/chemical_reaction/lye
	name = "lye"
	id = "lye"
	result = "lye"
	required_reagents = list("sodium" = 1, "hydrogen" = 1, "oxygen" = 1)
	result_amount = 3

/datum/reagent/hugs
	name = "Pure hugs"
	id = "hugs"
	description = "Hugs, in liquid form.  Yes, the concept of a hug.  As a liquid.  This makes sense in the future."
	reagent_state = LIQUID
	color = "#FF97B9"

/datum/reagent/love
	name = "Pure love"
	id = "love"
	description = "What is this emotion you humans call \"love?\"  Oh, it's this?  This is it? Huh, well okay then, thanks."
	reagent_state = LIQUID
	color = "#FF83A5"

/datum/reagent/love/reaction_mob(mob/living/M, method=TOUCH, volume)
	to_chat(M, "<span class='notice'>You feel loved!</span>")

/datum/reagent/love/on_mob_life(mob/living/M)
	if(M.a_intent == I_HARM)
		M.a_intent = I_HELP

	if(prob(8))
		var/lovely_phrase = pick("appreciated", "loved", "pretty good", "really nice", "pretty happy with yourself, even though things haven't always gone as well as they could")
		to_chat(M, "<span class='notice'>You feel [lovely_phrase].</span>")

	else if(!M.restrained())
		for(var/mob/living/carbon/C in orange(1, M))
			if(C)
				if(C == M)
					continue
				if(!C.stat)
					M.visible_message("<span class='notice'>[M] gives [C] a [pick("hug","warm embrace")].</span>")
					playsound(get_turf(M), 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
					break
	..()

/datum/chemical_reaction/love
	name = "pure love"
	id = "love"
	result = "love"
	required_reagents = list("hugs" = 1, "chocolate" = 1)
	result_amount = 2
	mix_message = "The substance gives off a lovely scent!"

///Alchemical Reagents

/datum/reagent/eyenewt
	name = "Eye of newt"
	id = "eyenewt"
	description = "A potent alchemic ingredient."
	reagent_state = LIQUID
	color = "#050519"

/datum/reagent/toefrog
	name = "Toe of frog"
	id = "toefrog"
	description = "A potent alchemic ingredient."
	reagent_state = LIQUID
	color = "#092D09"

/datum/reagent/woolbat
	name = "Wool of bat"
	id = "woolbat"
	description = "A potent alchemic ingredient."
	reagent_state = LIQUID
	color = "#080808"

/datum/reagent/tonguedog
	name = "Tongue of dog"
	id = "tonguedog"
	description = "A potent alchemic ingredient."
	reagent_state = LIQUID
	color = "#2D0909"

/datum/reagent/triplepiss
	name = "Triplepiss"
	id = "triplepiss"
	description = "Ewwwwwwwww."
	reagent_state = LIQUID
	color = "#857400"

/datum/reagent/royal_bee_jelly
	name = "royal bee jelly"
	id = "royal_bee_jelly"
	description = "Royal Bee Jelly, if injected into a Queen Space Bee said bee will split into two bees."
	color = "#00ff80"

/datum/reagent/royal_bee_jelly/on_mob_life(mob/living/M)
	if(prob(2))
		M.say(pick("Bzzz...","BZZ BZZ","Bzzzzzzzzzzz..."))
	..()

/datum/chemical_reaction/royal_bee_jelly
	name = "royal bee jelly"
	id = "royal_bee_jelly"
	result = "royal_bee_jelly"
	required_reagents = list("mutagen" = 10, "honey" = 40)
	result_amount = 5