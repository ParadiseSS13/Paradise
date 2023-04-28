#define SLIMEPERSON_COLOR_SHIFT_TRIGGER 0.1
#define SLIMEPERSON_ICON_UPDATE_PERIOD 200 // 20 seconds
#define SLIMEPERSON_BLOOD_SCALING_FACTOR 5 // Used to adjust how much of an effect the blood has on the rate of color change. Higher is slower.

#define SLIMEPERSON_HUNGERCOST 50
#define SLIMEPERSON_MINHUNGER 250
#define SLIMEPERSON_REGROWTHDELAY 450 // 45 seconds
#define SLIMEPERSON_HAIRGROWTHDELAY 50
#define SLIMEPERSON_HAIRGROWTHCOST 10

/datum/species/slime
	name = "Slime People"
	name_plural = "Slime People"
	language = "Bubblish"
	icobase = 'icons/mob/human_races/r_slime.dmi'
	deform = 'icons/mob/human_races/r_slime.dmi'
	remains_type = /obj/effect/decal/remains/slime
	inherent_factions = list("slime")

	// More sensitive to the cold
	cold_level_1 = 280
	cold_level_2 = 240
	cold_level_3 = 200
	coldmod = 3

	brain_mod = 1.5

	male_cough_sounds = list('sound/effects/slime_squish.ogg')
	female_cough_sounds = list('sound/effects/slime_squish.ogg')

	species_traits = list(LIPS, IS_WHITELISTED, NO_SCAN, EXOTIC_COLOR)
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_SKIN_COLOR | NO_EYES
	reagent_tag = PROCESS_ORG

	flesh_color = "#5fe8b1"
	blood_color = "#0064C8"
	exotic_blood = "slimejelly"

	butt_sprite = "slime"
	//Has default darksight of 2.

	has_organ = list(
		"brain" = /obj/item/organ/internal/brain/slime,
		"heart" = /obj/item/organ/internal/heart/slime,
		"lungs" = /obj/item/organ/internal/lungs/slime
		)
	mutantears = null
	has_limbs = list(
		"chest" =  list("path" = /obj/item/organ/external/chest/unbreakable),
		"groin" =  list("path" = /obj/item/organ/external/groin/unbreakable),
		"head" =   list("path" = /obj/item/organ/external/head/unbreakable),
		"l_arm" =  list("path" = /obj/item/organ/external/arm/unbreakable),
		"r_arm" =  list("path" = /obj/item/organ/external/arm/right/unbreakable),
		"l_leg" =  list("path" = /obj/item/organ/external/leg/unbreakable),
		"r_leg" =  list("path" = /obj/item/organ/external/leg/right/unbreakable),
		"l_hand" = list("path" = /obj/item/organ/external/hand/unbreakable),
		"r_hand" = list("path" = /obj/item/organ/external/hand/right/unbreakable),
		"l_foot" = list("path" = /obj/item/organ/external/foot/unbreakable),
		"r_foot" = list("path" = /obj/item/organ/external/foot/right/unbreakable)
		)
	suicide_messages = list(
		"тает в лужу!",
		"растекается в лужу!",
		"становится растаявшим желе!",
		"вырывает собственное ядро!",
		"становится коричневым, тусклым и растекается в лужу!")

	var/reagent_skin_coloring = FALSE

	disliked_food = SUGAR | FRIED
	liked_food = MEAT | TOXIC | RAW

/datum/species/slime/on_species_gain(mob/living/carbon/human/H)
	..()
	var/datum/action/innate/regrow/grow = locate() in H.actions
	if(!grow)
		grow = new
		grow.Grant(H)
	var/datum/action/innate/slimecolor/recolor = locate() in H.actions
	if(!recolor)
		recolor = new
		recolor.Grant(H)
	var/datum/action/innate/slimehair/changehair = locate() in H.actions
	if(!changehair)
		changehair = new
		changehair.Grant(H)
	var/datum/action/innate/slimebeard/changebeard = locate() in H.actions
	if(!changebeard)
		changebeard = new
		changebeard.Grant(H)
	ADD_TRAIT(H, TRAIT_WATERBREATH, "species")
	RegisterSignal(H, COMSIG_HUMAN_UPDATE_DNA, /datum/species/slime/./proc/blend)
	blend(H)
	H.verbs |= /mob/living/carbon/human/proc/emote_squish


/datum/species/slime/on_species_loss(mob/living/carbon/human/H)
	..()
	var/datum/action/innate/regrow/grow = locate() in H.actions
	if(grow)
		grow.Remove(H)
	var/datum/action/innate/slimecolor/recolor = locate() in H.actions
	if(recolor)
		recolor.Remove(H)
	var/datum/action/innate/slimehair/changehair = locate() in H.actions
	if(changehair)
		changehair.Remove(H)
	var/datum/action/innate/slimebeard/changebeard = locate() in H.actions
	if(changebeard)
		changebeard.Remove(H)
	REMOVE_TRAIT(H, TRAIT_WATERBREATH, "species")
	UnregisterSignal(H, COMSIG_HUMAN_UPDATE_DNA)
	H.verbs -= /mob/living/carbon/human/proc/emote_squish

/datum/species/slime/proc/blend(mob/living/carbon/human/H)
	var/new_color = BlendRGB(H.skin_colour, "#acacac", 0.5) // Blends this to make it work better
	if(H.blood_color != new_color) // Put here, so if it's a roundstart, dyed, or CMA'd slime, their blood changes to match skin
		H.blood_color = new_color
		H.dna.species.blood_color = H.blood_color

/datum/species/slime/handle_life(mob/living/carbon/human/H)
	// Slowly shifting to the color of the reagents
	if(reagent_skin_coloring && H.reagents.total_volume > SLIMEPERSON_COLOR_SHIFT_TRIGGER)
		var/blood_amount = H.blood_volume
		var/r_color = mix_color_from_reagents(H.reagents.reagent_list)
		var/new_body_color = BlendRGB(r_color, H.skin_colour, (blood_amount*SLIMEPERSON_BLOOD_SCALING_FACTOR)/((blood_amount*SLIMEPERSON_BLOOD_SCALING_FACTOR)+(H.reagents.total_volume)))
		H.skin_colour = new_body_color
		if(world.time % SLIMEPERSON_ICON_UPDATE_PERIOD > SLIMEPERSON_ICON_UPDATE_PERIOD - 20) // The 20 is because this gets called every 2 seconds, from the mob controller
			for(var/organname in H.bodyparts_by_name)
				var/obj/item/organ/external/E = H.bodyparts_by_name[organname]
				if(istype(E) && E.dna && istype(E.dna.species, /datum/species/slime))
					E.sync_colour_to_human(H)
			H.update_hair()
			H.update_body()
			blend(H)
	..()



/datum/species/slime/can_hear() // fucking snowflakes
	. = TRUE

/datum/action/innate/slimecolor
	name = "Toggle Recolor"
	check_flags = AB_CHECK_CONSCIOUS
	icon_icon = 'icons/mob/actions/actions.dmi'
	button_icon_state = "slime_change"

/datum/action/innate/slimecolor/Activate()
	var/mob/living/carbon/human/H = owner
	var/datum/species/slime/S = H.dna.species
	if(S.reagent_skin_coloring)
		S.reagent_skin_coloring = FALSE
		to_chat(H, "Вы настраиваете свою внутреннюю химию, чтобы отфильтровывать пигменты из употребляемых продуктов.")
	else
		S.reagent_skin_coloring = TRUE
		to_chat(H, "Вы настраиваете свою внутреннюю химию, позволяя окрашивать себя пигментами употребляемых веществ.")

/datum/action/innate/regrow
	name = "Regrow limbs"
	check_flags = AB_CHECK_CONSCIOUS
	icon_icon = 'icons/mob/actions/actions.dmi'
	button_icon_state = "slime_renew"

/datum/action/innate/regrow/Activate()
	var/mob/living/carbon/human/H = owner
	if(H.nutrition < SLIMEPERSON_MINHUNGER)
		to_chat(H, "<span class='warning'>Вы слишком голодны для регенерации конечности!</span>")
		return

	var/list/missing_limbs = list()
	for(var/l in H.bodyparts_by_name)
		var/obj/item/organ/external/E = H.bodyparts_by_name[l]
		if(!istype(E))
			var/list/limblist = H.dna.species.has_limbs[l]
			var/obj/item/organ/external/limb = limblist["path"]
			var/parent_organ = initial(limb.parent_organ)
			var/obj/item/organ/external/parentLimb = H.bodyparts_by_name[parent_organ]
			if(!istype(parentLimb))
				continue
			missing_limbs[initial(limb.name)] = l

	if(!missing_limbs.len)
		to_chat(H, "<span class='warning'>Ваши конечности на месте!</span>")
		return

	var/limb_select = input(H, "Choose a limb to regrow", "Limb Regrowth") as null|anything in missing_limbs
	if(!limb_select) // If the user hit cancel on the popup, return
		return
	var/chosen_limb = missing_limbs[limb_select]

	//перевод конечности со склонением
	var/chosen_limb_rus = chosen_limb
	switch (chosen_limb_rus)
		if ("l_leg", 	"left leg", 	"the left leg") 	chosen_limb_rus = "левой ноги"
		if ("r_leg", 	"right leg", 	"the right leg") 	chosen_limb_rus = "правой ноги"
		if ("l_foot", 	"left foot", 	"the left foot") 	chosen_limb_rus = "левой ступни"
		if ("r_foot", 	"right foot", 	"the right foot") 	chosen_limb_rus = "правой ступни"
		if ("groin", 	"lower body", 	"the lower body") 	chosen_limb_rus = "нижней части тела"
		if ("l_arm", 	"left arm", 	"the left arm") 	chosen_limb_rus = "левой руки"
		if ("r_arm", 	"right arm", 	"the right arm") 	chosen_limb_rus = "правой руки"
		if ("l_hand", 	"left hand", 	"the left hand") 	chosen_limb_rus = "левой кисти"
		if ("r_hand", 	"right hand", 	"the right hand") 	chosen_limb_rus = "правой кисти"

	H.visible_message("<span class='notice'>[H] замирает и концентрируется на [genderize_ru(H.gender,"его","её","своей","их")] потерянной [chosen_limb_rus]...</span>", "<span class='notice'>Вы концентрируетесь на отращивании [chosen_limb_rus]... (Это займет [round(SLIMEPERSON_REGROWTHDELAY/10)] секунд, нужно подождать в спокойствии.)</span>")
	if(do_after(H, SLIMEPERSON_REGROWTHDELAY, FALSE, H, extra_checks = list(CALLBACK(H, /mob.proc/IsStunned)), use_default_checks = FALSE)) // Override the check for weakness, only check for stunned
		if(H.incapacitated(ignore_lying = TRUE, extra_checks = list(CALLBACK(H, /mob.proc/IsStunned)), use_default_checks = FALSE)) // Override the check for weakness, only check for stunned
			to_chat(H, "<span class='warning'>Вы не можете регенерировать недостающие конечности в текущем состоянии</span>")
			return

		if(H.nutrition < SLIMEPERSON_MINHUNGER)
			to_chat(H, "<span class='warning'>Вы слишком голодны чтобы регенерировать!</span>")
			return

		var/obj/item/organ/external/O = H.bodyparts_by_name[chosen_limb]

		var/stored_brute = 0
		var/stored_burn = 0
		if(istype(O))
			to_chat(H, "<span class='warning'>Вы распределяете поврежденную ткань по всему телу, освобождая место для ложноножки!</span>")
			var/obj/item/organ/external/doomedStump = O
			stored_brute = doomedStump.brute_dam
			stored_burn = doomedStump.burn_dam
			qdel(O)

		var/limb_list = H.dna.species.has_limbs[chosen_limb]
		var/obj/item/organ/external/limb_path = limb_list["path"]
		// Parent check
		var/obj/item/organ/external/potential_parent = H.bodyparts_by_name[initial(limb_path.parent_organ)]
		if(!istype(potential_parent))
			to_chat(H, "<span class='danger'>Вы потеряли орган, на котором выращивали новую конечность!</span>")
			return // No rayman for you
		// Grah this line will leave a "not used" warning, in spite of the fact that the new() proc WILL do the thing.
		// Bothersome.
		var/obj/item/organ/external/new_limb = new limb_path(H)
		new_limb.open = 0 // This is just so that the compiler won't think that new_limb is unused, because the compiler is horribly stupid.
		H.adjustBruteLoss(stored_brute)
		H.adjustFireLoss(stored_burn)
		H.update_body()
		H.updatehealth()
		H.UpdateDamageIcon()
		H.adjust_nutrition(-SLIMEPERSON_HUNGERCOST)

		//перевод конечности со склонением
		var/new_limb_rus = new_limb.name
		switch (new_limb_rus)
			if ("l_leg", 	"left leg", 	"the left leg") 	new_limb_rus = "левую ногу"
			if ("r_leg", 	"right leg", 	"the right leg") 	new_limb_rus = "правую ногу"
			if ("l_foot", 	"left foot", 	"the left foot") 	new_limb_rus = "левую ступню"
			if ("r_foot", 	"right foot", 	"the right foot") 	new_limb_rus = "правую ступню"
			if ("groin", 	"lower body", 	"the lower body") 	new_limb_rus = "нижнюю часть тела"
			if ("l_arm", 	"left arm", 	"the left arm") 	new_limb_rus = "левую руку"
			if ("r_arm", 	"right arm", 	"the right arm") 	new_limb_rus = "правую руку"
			if ("l_hand", 	"left hand", 	"the left hand") 	new_limb_rus = "левую кисть"
			if ("r_hand", 	"right hand", 	"the right hand") 	new_limb_rus = "правую кисть"

		H.visible_message("<span class='notice'>[H] отращивает [genderize_ru(H.gender,"его","её","своей","их")] потерянную [new_limb_rus]!</span>", "<span class='notice'>Вы отрастили [new_limb_rus]</span>")
	else
		to_chat(H, "<span class='warning'>Для отращивания конечности вам нужно стоять на месте!</span>")

/datum/action/innate/slimehair
	name = "Change Hairstyle"
	check_flags = AB_CHECK_CONSCIOUS
	icon_icon = 'icons/effects/effects.dmi'
	button_icon_state = "greenglow"

/datum/action/innate/slimehair/Activate()
	var/mob/living/carbon/human/H = owner
	var/list/valid_hairstyles = H.generate_valid_hairstyles()
	var/obj/item/organ/external/head/head_organ = H.get_organ("head")
	var/new_style = input("Please select hair style", "Character Generation", head_organ.h_style) as null|anything in valid_hairstyles
	if(new_style)
		H.visible_message("<span class='notice'>Волосы на голове [H] начинают шевелиться!.</span>", "<span class='notice'>Вы концентрируетесь на своей прическе.</span>")
		if(do_after(H, SLIMEPERSON_HAIRGROWTHDELAY, target = H))
			H.change_hair(new_style)
			H.adjust_nutrition(-SLIMEPERSON_HAIRGROWTHCOST)
			H.visible_message("<span class='notice'>[H] изменил свою прическу.</span>", "<span class='notice'>Вы изменили свою прическу.</span>")
		else
			to_chat(H, "<span class='warning'>Вы теряете концентрацию.</span>")

/datum/action/innate/slimebeard
	name = "Change Beard"
	check_flags = AB_CHECK_CONSCIOUS
	icon_icon = 'icons/effects/effects.dmi'
	button_icon_state = "greenglow"

/datum/action/innate/slimebeard/Activate()
	var/mob/living/carbon/human/H = owner
	var/list/valid_facial_hairstyles = H.generate_valid_facial_hairstyles()
	var/obj/item/organ/external/head/head_organ = H.get_organ("head")
	if(H.gender == FEMALE)
		to_chat(H, "<span class='warning'> Вы не можете изменить бороду.</span>")
		return
	var/new_style = input("Please select facial style", "Character Generation", head_organ.f_style) as null|anything in valid_facial_hairstyles
	if(new_style)
		H.visible_message("<span class='notice'>Волосы на лице [H] начинают шевелиться!.</span>", "<span class='notice'>Вы концентрируетесь на своей бороде.</span>")
		if(do_after(H, SLIMEPERSON_HAIRGROWTHDELAY, target = H))
			H.change_facial_hair(new_style)
			H.adjust_nutrition(-SLIMEPERSON_HAIRGROWTHCOST)
			H.visible_message("<span class='notice'>[H] изменил свою бороду.</span>", "<span class='notice'>Вы изменили свою бороду.</span>")
		else
			to_chat(H, "<span class='warning'>Вы теряете концентрацию.</span>")

#undef SLIMEPERSON_COLOR_SHIFT_TRIGGER
#undef SLIMEPERSON_ICON_UPDATE_PERIOD
#undef SLIMEPERSON_BLOOD_SCALING_FACTOR

#undef SLIMEPERSON_HUNGERCOST
#undef SLIMEPERSON_MINHUNGER
#undef SLIMEPERSON_REGROWTHDELAY
#undef SLIMEPERSON_HAIRGROWTHDELAY
#undef SLIMEPERSON_HAIRGROWTHCOST
