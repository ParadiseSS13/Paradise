#define SOLID 1
#define LIQUID 2
#define GAS 3
#define REM REAGENTS_EFFECT_MULTIPLIER

var/list/random_color_list = list("#00aedb","#a200ff","#f47835","#d41243","#d11141","#00b159","#00aedb","#f37735","#ffc425","#008744","#0057e7","#d62d20","#ffa700")

datum/reagent/oil
	name = "Oil"
	id = "oil"
	description = "A decent lubricant for machines. High in benzene, naptha and other hydrocarbons."
	reagent_state = LIQUID
	color = "#3C3C3C"

datum/reagent/iodine
	name = "Iodine"
	id = "iodine"
	description = "A purple gaseous element."
	reagent_state = GAS
	color = "#493062"

datum/reagent/carpet
	name = "Carpet"
	id = "carpet"
	description = "A covering of thick fabric used on floors. This type looks particularly gross."
	reagent_state = LIQUID
	color = "#701345"

/datum/reagent/carpet/reaction_turf(var/turf/simulated/T, var/volume)
	if(T.is_plating() || T.is_plasteel_floor())
		var/turf/simulated/floor/F = T
		F.ChangeTurf(/turf/simulated/floor/carpet)
	..()
	return

datum/reagent/bromine
	name = "Bromine"
	id = "bromine"
	description = "A red-brown liquid element."
	reagent_state = LIQUID
	color = "#4E3A3A"

datum/reagent/phenol
	name = "Phenol"
	id = "phenol"
	description = "Also known as carbolic acid, this is a useful building block in organic chemistry."
	reagent_state = LIQUID
	color = "#525050"

datum/reagent/ash
	name = "Ash"
	id = "ash"
	description = "Ashes to ashes, dust to dust."
	reagent_state = LIQUID
	color = "#191919"

datum/reagent/acetone
	name = "Acetone"
	id = "acetone"
	description = "Pure 100% nail polish remover, also works as an industrial solvent."
	reagent_state = LIQUID
	color = "#474747"

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

/datum/chemical_reaction/ash
	name = "Ash"
	id = "ash"
	result = "ash"
	required_reagents = list("oil" = 1)
	result_amount = 0.5
	required_temp = 480
	mix_sound = null
	no_message = 1

datum/reagent/colorful_reagent
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

datum/reagent/colorful_reagent/reaction_mob(var/mob/living/simple_animal/M, var/method=TOUCH, var/volume)
    if(M && istype(M))
        M.color = pick(random_color_list)
    ..()
    return

datum/reagent/colorful_reagent/reaction_obj(var/obj/O, var/volume)
	if(O)
		O.color = pick(random_color_list)
	..()
	return
datum/reagent/colorful_reagent/reaction_turf(var/turf/T, var/volume)
	if(T)
		T.color = pick(random_color_list)
	..()
	return

/datum/chemical_reaction/corgium
	name = "corgium"
	id = "corgium"
	result = null
	required_reagents = list("nutriment" = 1, "colorful_reagent" = 1, "strange_reagent" = 1, "blood" = 1)
	result_amount = 3
	required_temp = 374

datum/reagent/corgium
	name = "Corgium"
	id = "corgium"
	description = "Corgi in liquid form. Don't ask."
	reagent_state = LIQUID
	color = "#F9A635"

/datum/chemical_reaction/corgium/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	new /mob/living/simple_animal/corgi(location)
	..()
	return


/datum/chemical_reaction/flaptonium
	name = "Flaptonium"
	id = "flaptonium"
	result = null
	required_reagents = list("egg" = 1, "colorful_reagent" = 1, "chicken_soup" = 1, "strange_reagent" = 1, "blood" = 1)
	result_amount = 5
	required_temp = 374
	mix_message = "The substance turns an airy sky-blue and foams up into a new shape."

/datum/chemical_reaction/flaptonium/on_reaction(var/datum/reagents/holder, var/created_volume)
	var/location = get_turf(holder.my_atom)
	new /mob/living/simple_animal/parrot(location)
	..()
	return


datum/reagent/hair_dye
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

datum/reagent/hair_dye/reaction_mob(var/mob/living/M, var/volume)
	if(M && ishuman(M))
		var/mob/living/carbon/human/H = M
		H.r_facial = rand(0,255)
		H.g_facial = rand(0,255)
		H.b_facial = rand(0,255)
		H.r_hair = rand(0,255)
		H.g_hair = rand(0,255)
		H.b_hair = rand(0,255)
		H.update_hair()
	..()
	return

datum/reagent/hairgrownium
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

datum/reagent/hairgrownium/reaction_mob(var/mob/living/M, var/volume)
	if(M && ishuman(M))
		var/mob/living/carbon/human/H = M
		H.h_style = random_hair_style(H.gender, H.species)
		H.f_style = random_facial_hair_style(H.gender, H.species)
		H.update_hair()
	..()
	return

datum/reagent/super_hairgrownium
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

datum/reagent/super_hairgrownium/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(M && ishuman(M))
		var/mob/living/carbon/human/H = M
		H.h_style = "Very Long Hair"
		H.f_style = "Very Long Beard"
		H.update_hair()
		if(!H.wear_mask || H.wear_mask && !istype(H.wear_mask, /obj/item/clothing/mask/fakemoustache))
			if(H.wear_mask)
				H.unEquip(H.wear_mask)
			var/obj/item/clothing/mask/fakemoustache = new /obj/item/clothing/mask/fakemoustache
			H.equip_to_slot(fakemoustache, slot_wear_mask)
			H << "<span class = 'notice'>Hair bursts forth from your every follicle!"
	..()
	return

datum/reagent/fartonium
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

datum/reagent/fartonium/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.emote("fart")
	if(holder.has_reagent("simethicone"))
		if(prob(30))
			switch(pick(1,2))
				if(1)
					M << "<span class = 'danger'>Something isn't right!"
					M.adjustBruteLoss(1)
				if(2)
					M.emote("me",1,"strains, but nothing happens.")
					M.adjustBruteLoss(2)
				if(3)
					M.emote("scream")
					M.adjustBruteLoss(2)
				if(4)
					M << "<span class = 'danger'>Oh gosh, the pain!"
					M.adjustBruteLoss(1)
				if(5)
					M << "<span class = 'danger'>THE PAIN!"
					M.adjustBruteLoss(1)
	..()
	return


///Alchemical Reagents

datum/reagent/eyenewt
	name = "Eye of newt"
	id = "eyenewt"
	description = "A potent alchemic ingredient."
	reagent_state = LIQUID
	color = "#050519"

datum/reagent/toefrog
	name = "Toe of frog"
	id = "toefrog"
	description = "A potent alchemic ingredient."
	reagent_state = LIQUID
	color = "#092D09"

datum/reagent/woolbat
	name = "Wool of bat"
	id = "woolbat"
	description = "A potent alchemic ingredient."
	reagent_state = LIQUID
	color = "#080808"

datum/reagent/tonguedog
	name = "Tongue of dog"
	id = "tonguedog"
	description = "A potent alchemic ingredient."
	reagent_state = LIQUID
	color = "#2D0909"

datum/reagent/triplepiss
	name = "Triplepiss"
	id = "triplepiss"
	description = "Ewwwwwwwww."
	reagent_state = LIQUID
	color = "#857400"