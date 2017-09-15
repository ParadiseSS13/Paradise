/*/datum/reagent/silicate
	name = "Silicate"
	id = "silicate"
	description = "A compound that can be used to reinforce glass."
	reagent_state = LIQUID
	color = "#C7FFFF" // rgb: 199, 255, 255

/datum/reagent/silicate/reaction_obj(obj/O, volume)
	if(istype(O, /obj/structure/window))
		if(O:silicate <= 200)

			O:silicate += volume
			O:health += volume * 3

			if(!O:silicateIcon)
				var/icon/I = icon(O.icon,O.icon_state,O.dir)

				var/r = (volume / 100) + 1
				var/g = (volume / 70) + 1
				var/b = (volume / 50) + 1
				I.SetIntensity(r,g,b)
				O.icon = I
				O:silicateIcon = I
			else
				var/icon/I = O:silicateIcon

				var/r = (volume / 100) + 1
				var/g = (volume / 70) + 1
				var/b = (volume / 50) + 1
				I.SetIntensity(r,g,b)
				O.icon = I
				O:silicateIcon = I */


/datum/reagent/oxygen
	name = "Oxygen"
	id = "oxygen"
	description = "A colorless, odorless gas."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	taste_message = null

/datum/reagent/nitrogen
	name = "Nitrogen"
	id = "nitrogen"
	description = "A colorless, odorless, tasteless gas."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	taste_message = null

/datum/reagent/hydrogen
	name = "Hydrogen"
	id = "hydrogen"
	description = "A colorless, odorless, nonmetallic, tasteless, highly combustible diatomic gas."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	taste_message = null

/datum/reagent/potassium
	name = "Potassium"
	id = "potassium"
	description = "A soft, low-melting solid that can easily be cut with a knife. Reacts violently with water."
	reagent_state = SOLID
	color = "#A0A0A0" // rgb: 160, 160, 160
	taste_message = "bad ideas"

/datum/reagent/sulfur
	name = "Sulfur"
	id = "sulfur"
	description = "A chemical element."
	reagent_state = SOLID
	color = "#BF8C00" // rgb: 191, 140, 0
	taste_message = "impulsive decisions"

/datum/reagent/sodium
	name = "Sodium"
	id = "sodium"
	description = "A chemical element."
	reagent_state = SOLID
	color = "#808080" // rgb: 128, 128, 128
	taste_message = "horrible misjudgement"

/datum/reagent/phosphorus
	name = "Phosphorus"
	id = "phosphorus"
	description = "A chemical element."
	reagent_state = SOLID
	color = "#832828" // rgb: 131, 40, 40
	taste_message = "misguided choices"

/datum/reagent/carbon
	name = "Carbon"
	id = "carbon"
	description = "A chemical element."
	reagent_state = SOLID
	color = "#1C1300" // rgb: 30, 20, 0
	taste_message = "like a pencil or something"

/datum/reagent/carbon/reaction_turf(turf/T, volume)
	if(!(locate(/obj/effect/decal/cleanable/dirt) in T) && !isspaceturf(T)) // Only add one dirt per turf.  Was causing people to crash.
		new /obj/effect/decal/cleanable/dirt(T)

/datum/reagent/gold
	name = "Gold"
	id = "gold"
	description = "Gold is a dense, soft, shiny metal and the most malleable and ductile metal known."
	reagent_state = SOLID
	color = "#F7C430" // rgb: 247, 196, 48
	taste_message = "bling"


/datum/reagent/silver
	name = "Silver"
	id = "silver"
	description = "A lustrous metallic element regarded as one of the precious metals."
	reagent_state = SOLID
	color = "#D0D0D0" // rgb: 208, 208, 208
	taste_message = "sub-par bling"


/datum/reagent/aluminum
	name = "Aluminum"
	id = "aluminum"
	description = "A silvery white and ductile member of the boron group of chemical elements."
	reagent_state = SOLID
	color = "#A8A8A8" // rgb: 168, 168, 168
	taste_message = null


/datum/reagent/silicon
	name = "Silicon"
	id = "silicon"
	description = "A tetravalent metalloid, silicon is less reactive than its chemical analog carbon."
	reagent_state = SOLID
	color = "#A8A8A8" // rgb: 168, 168, 168
	taste_message = "a CPU"


/datum/reagent/copper
	name = "Copper"
	id = "copper"
	description = "A highly ductile metal."
	color = "#6E3B08" // rgb: 110, 59, 8
	taste_message = "copper"


/datum/reagent/iron
	name = "Iron"
	id = "iron"
	description = "Pure iron is a metal."
	reagent_state = SOLID
	color = "#C8A5DC" // rgb: 200, 165, 220
	taste_message = "metal"

/datum/reagent/iron/on_mob_life(mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!H.species.exotic_blood && !(NO_BLOOD in H.species.species_traits))
			if(H.blood_volume < BLOOD_VOLUME_NORMAL)
				H.blood_volume += 0.8
	..()

//foam
/datum/reagent/fluorosurfactant
	name = "Fluorosurfactant"
	id = "fluorosurfactant"
	description = "A perfluoronated sulfonic acid that forms a foam when mixed with water."
	reagent_state = LIQUID
	color = "#9E6B38" // rgb: 158, 107, 56
	taste_message = null

// metal foaming agent
// this is lithium hydride. Add other recipies (e.g. LiH + H2O -> LiOH + H2) eventually
/datum/reagent/ammonia
	name = "Ammonia"
	id = "ammonia"
	description = "A caustic substance commonly used in fertilizer or household cleaners."
	reagent_state = GAS
	color = "#404030" // rgb: 64, 64, 48
	taste_message = "floor cleaner"

/datum/reagent/diethylamine
	name = "Diethylamine"
	id = "diethylamine"
	description = "A secondary amine, useful as a plant nutrient and as building block for other compounds."
	reagent_state = LIQUID
	color = "#322D00"
	taste_message = null

/datum/reagent/oil
	name = "Oil"
	id = "oil"
	description = "A decent lubricant for machines. High in benzene, naptha and other hydrocarbons."
	reagent_state = LIQUID
	color = "#3C3C3C"
	taste_message = "motor oil"

/datum/reagent/iodine
	name = "Iodine"
	id = "iodine"
	description = "A purple gaseous element."
	reagent_state = GAS
	color = "#493062"
	taste_message = null

/datum/reagent/carpet
	name = "Carpet"
	id = "carpet"
	description = "A covering of thick fabric used on floors. This type looks particularly gross."
	reagent_state = LIQUID
	color = "#701345"
	taste_message = "a carpet...what?"

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
	taste_message = null

/datum/reagent/phenol
	name = "Phenol"
	id = "phenol"
	description = "Also known as carbolic acid, this is a useful building block in organic chemistry."
	reagent_state = LIQUID
	color = "#525050"
	taste_message = null

/datum/reagent/ash
	name = "Ash"
	id = "ash"
	description = "Ashes to ashes, dust to dust."
	reagent_state = LIQUID
	color = "#191919"
	taste_message = "ash"

/datum/reagent/acetone
	name = "Acetone"
	id = "acetone"
	description = "Pure 100% nail polish remover, also works as an industrial solvent."
	reagent_state = LIQUID
	color = "#474747"
	taste_message = null

/datum/reagent/acetone/on_mob_life(mob/living/M)
	M.adjustToxLoss(1.5)
	..()

/datum/reagent/saltpetre
	name = "Saltpetre"
	id = "saltpetre"
	description = "Volatile."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	taste_message = null

/datum/reagent/colorful_reagent
	name = "Colorful Reagent"
	id = "colorful_reagent"
	description = "It's pure liquid colors. That's a thing now."
	reagent_state = LIQUID
	color = "#FFFFFF"
	taste_message = "the rainbow"

/datum/reagent/colorful_reagent/reaction_mob(mob/living/simple_animal/M, method=TOUCH, volume)
    if(isanimal(M))
        M.color = pick(random_color_list)
    ..()

/datum/reagent/colorful_reagent/reaction_obj(obj/O, volume)
	O.color = pick(random_color_list)

/datum/reagent/colorful_reagent/reaction_turf(turf/T, volume)
	T.color = pick(random_color_list)

/datum/reagent/hair_dye
	name = "Quantum Hair Dye"
	id = "hair_dye"
	description = "A rather tubular and gnarly way of coloring totally bodacious hair. Duuuudddeee."
	reagent_state = LIQUID
	color = "#960096"
	taste_message = "the 2559 Autumn release of the Le Jeune Homme catalogue for professional hairdressers"

/datum/reagent/hair_dye/reaction_mob(mob/living/M, volume)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/head/head_organ = H.get_organ("head")
		head_organ.facial_colour = rand_hex_color()
		head_organ.sec_facial_colour = rand_hex_color()
		head_organ.hair_colour = rand_hex_color()
		head_organ.sec_hair_colour = rand_hex_color()
		H.update_hair()
		H.update_fhair()
	..()

/datum/reagent/hairgrownium
	name = "Hairgrownium"
	id = "hairgrownium"
	description = "A mysterious chemical purported to help grow hair. Often found on late-night TV infomercials."
	reagent_state = LIQUID
	color = "#5DDA5D"
	penetrates_skin = TRUE
	taste_message = "someone's beard"

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
	penetrates_skin = TRUE
	taste_message = "multiple beards"

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
	taste_message = "mexican cuisine"

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

/datum/reagent/hugs
	name = "Pure hugs"
	id = "hugs"
	description = "Hugs, in liquid form.  Yes, the concept of a hug.  As a liquid.  This makes sense in the future."
	reagent_state = LIQUID
	color = "#FF97B9"
	taste_message = "<font color='pink'><b>hugs</b></font>"

/datum/reagent/love
	name = "Pure love"
	id = "love"
	description = "What is this emotion you humans call \"love?\"  Oh, it's this?  This is it? Huh, well okay then, thanks."
	reagent_state = LIQUID
	color = "#FF83A5"
	process_flags = ORGANIC | SYNTHETIC // That's the power of love~
	taste_message = "<font color='pink'><b>love</b></font>"

/datum/reagent/love/on_mob_life(mob/living/M)
	if(M.a_intent != INTENT_HELP)
		M.a_intent_change(INTENT_HELP)
	M.can_change_intents = 0 //Now you have no choice but to be helpful.

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

/datum/reagent/love/on_mob_delete(mob/living/M)
	M.can_change_intents = 1
	..()

/datum/reagent/love/reaction_mob(mob/living/M, method=TOUCH, volume)
	to_chat(M, "<span class='notice'>You feel loved!</span>")


/datum/reagent/royal_bee_jelly
	name = "royal bee jelly"
	id = "royal_bee_jelly"
	description = "Royal Bee Jelly, if injected into a Queen Space Bee said bee will split into two bees."
	color = "#00ff80"
	taste_message = "sweetness"

/datum/reagent/royal_bee_jelly/on_mob_life(mob/living/M)
	if(prob(2))
		M.say(pick("Bzzz...","BZZ BZZ","Bzzzzzzzzzzz..."))
	..()

/datum/reagent/growthserum
	name = "Growth serum"
	id = "growthserum"
	description = "A commercial chemical designed to help older men in the bedroom." //not really it just makes you a giant
	color = "#ff0000"//strong red. rgb 255, 0, 0
	var/current_size = 1
	taste_message = "enhancement"

/datum/reagent/growthserum/on_mob_life(mob/living/carbon/H)
	var/newsize = current_size
	switch(volume)
		if(0 to 19)
			newsize = 1.1
		if(20 to 49)
			newsize = 1.2
		if(50 to 99)
			newsize = 1.25
		if(100 to 199)
			newsize = 1.3
		if(200 to INFINITY)
			newsize = 1.5

	H.resize = newsize/current_size
	current_size = newsize
	H.update_transform()
	..()

/datum/reagent/growthserum/on_mob_delete(mob/living/M)
	M.resize = 1/current_size
	M.update_transform()
	..()

/datum/reagent/toxin/coffeepowder
	name = "Coffee Grounds"
	id = "coffeepowder"
	description = "Finely ground Coffee beans, used to make coffee."
	reagent_state = SOLID
	color = "#5B2E0D" // rgb: 91, 46, 13
	taste_message = "bitterness"

/datum/reagent/toxin/teapowder
	name = "Ground Tea Leaves"
	id = "teapowder"
	description = "Finely shredded Tea leaves, used for making tea."
	reagent_state = SOLID
	color = "#7F8400" // rgb: 127, 132, 0"
	taste_message = "bitterness"

//////////////////////////////////Hydroponics stuff///////////////////////////////

/datum/reagent/plantnutriment
	name = "Generic nutriment"
	id = "plantnutriment"
	description = "Some kind of nutriment. You can't really tell what it is. You should probably report it, along with how you obtained it."
	color = "#000000" // RBG: 0, 0, 0
	var/tox_prob = 0
	taste_message = "puke"

/datum/reagent/plantnutriment/on_mob_life(mob/living/M)
	if(prob(tox_prob))
		M.adjustToxLoss(1*REAGENTS_EFFECT_MULTIPLIER)
	..()

/datum/reagent/plantnutriment/eznutriment
	name = "E-Z-Nutrient"
	id = "eznutriment"
	description = "Cheap and extremely common type of plant nutriment."
	color = "#376400" // RBG: 50, 100, 0
	tox_prob = 10

/datum/reagent/plantnutriment/left4zednutriment
	name = "Left 4 Zed"
	id = "left4zednutriment"
	description = "Unstable nutriment that makes plants mutate more often than usual."
	color = "#1A1E4D" // RBG: 26, 30, 77
	tox_prob = 25

/datum/reagent/plantnutriment/robustharvestnutriment
	name = "Robust Harvest"
	id = "robustharvestnutriment"
	description = "Very potent nutriment that prevents plants from mutating."
	color = "#9D9D00" // RBG: 157, 157, 0
	tox_prob = 15

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
