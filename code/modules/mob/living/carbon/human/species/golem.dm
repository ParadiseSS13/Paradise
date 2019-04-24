/datum/species/golem
	name = "Golem"
	name_plural = "Golems"

	icobase = 'icons/mob/human_races/r_golem.dmi'
	deform = 'icons/mob/human_races/r_golem.dmi'

	species_traits = list(NO_BREATHE, NO_BLOOD, NO_PAIN, RADIMMUNE, VIRUSIMMUNE, NOGUNS)
	dies_at_threshold = TRUE
	brute_mod = 0.45 //55% damage reduction
	burn_mod = 0.45
	tox_mod = 0.45

	dietflags = DIET_OMNI		//golems can eat anything because they are magic or something
	reagent_tag = PROCESS_ORG

	punchdamagelow = 5
	punchdamagehigh = 14
	punchstunthreshold = 11 //about 40% chance to stun

	warning_low_pressure = -1
	hazard_low_pressure = -1
	hazard_high_pressure = 999999999
	warning_high_pressure = 999999999

	cold_level_1 = -1
	cold_level_2 = -1
	cold_level_3 = -1

	heat_level_1 = 999999999
	heat_level_2 = 999999999
	heat_level_3 = 999999999

	blood_color = "#515573"
	flesh_color = "#137E8F"
	skinned_type = /obj/item/stack/sheet/metal
	slowdown = 3
	siemens_coeff = 0

	blacklisted = TRUE // To prevent golem subtypes from overwhelming the odds when random species changes, only the Random Golem type can be chosen
	dangerous_existence = TRUE

	has_organ = list(
		"brain" = /obj/item/organ/internal/brain/golem,
		"adamantine_resonator" = /obj/item/organ/internal/adamantine_resonator
		) //Has standard darksight of 2.

	suicide_messages = list(
		"is crumbling into dust!",
		"is smashing their body apart!")

	var/golem_colour = rgb(170, 170, 170)
	var/info_text = "As an <span class='danger'>Iron Golem</span>, you don't have any special traits."
	var/random_eligible = TRUE
	var/prefix = "Iron"
	var/list/special_names = list("Tarkus")
	var/human_surname_chance = 3
	var/special_name_chance = 5
	var/owner //dobby is a free golem

/datum/species/golem/get_random_name()
	var/golem_surname = pick(GLOB.golem_names)
	// 3% chance that our golem has a human surname, because cultural contamination
	if(prob(human_surname_chance))
		golem_surname = pick(GLOB.last_names)
	else if(special_names && special_names.len && prob(special_name_chance))
		golem_surname = pick(special_names)

	var/golem_name = "[prefix] [golem_surname]"
	return golem_name

/datum/species/golem/on_species_gain(mob/living/carbon/human/H)
	..()
	if(H.mind)
		H.mind.assigned_role = "Golem"
		if(owner)
			H.mind.special_role = SPECIAL_ROLE_GOLEM
		else
			H.mind.special_role = SPECIAL_ROLE_FREE_GOLEM
	H.real_name = get_random_name()
	H.name = H.real_name
	H.equip_to_slot_or_del(new /obj/item/clothing/under/golem(H), slot_w_uniform)
	H.equip_to_slot_or_del(new /obj/item/clothing/suit/golem(H), slot_wear_suit)
	H.equip_to_slot_or_del(new /obj/item/clothing/shoes/golem(H), slot_shoes)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/golem(H), slot_wear_mask)
	H.equip_to_slot_or_del(new /obj/item/clothing/gloves/golem(H), slot_gloves)
	H.regenerate_icons()
	to_chat(H, info_text)

/datum/species/golem/on_species_loss(mob/living/carbon/human/H)
	..()
	if(istype(H.w_uniform, /obj/item/clothing/under/golem)) // Doing these if checks here just in case the golem is somehow wearing something other than their golem shell, which should be impossible but you never know.
		qdel(H.w_uniform)
	if(istype(H.wear_suit, /obj/item/clothing/suit/golem))
		qdel(H.wear_suit)
	if(istype(H.shoes, /obj/item/clothing/shoes/golem))
		qdel(H.shoes)
	if(istype(H.wear_mask, /obj/item/clothing/mask/gas/golem))
		qdel(H.wear_mask)
	if(istype(H.gloves, /obj/item/clothing/gloves/golem))
		qdel(H.gloves)

//Random Golem

/datum/species/golem/random
	name = "Random Golem"
	blacklisted = FALSE
	dangerous_existence = FALSE
	var/static/list/random_golem_types

/datum/species/golem/random/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	if(!random_golem_types)
		random_golem_types = subtypesof(/datum/species/golem) - type
		for(var/V in random_golem_types)
			var/datum/species/golem/G = V
			if(!initial(G.random_eligible))
				random_golem_types -= G
	var/datum/species/golem/golem_type = pick(random_golem_types)
	var/mob/living/carbon/human/H = C
	H.set_species(golem_type)

//Golem subtypes

//Leader golems, can resonate to communicate with all other golems
/datum/species/golem/adamantine
	name = "Adamantine Golem"
	skinned_type = /obj/item/stack/sheet/mineral/adamantine
	has_organ = list(
		"brain" = /obj/item/organ/internal/brain/golem,
		"adamantine_resonator" = /obj/item/organ/internal/adamantine_resonator,
		"vocal_cords" = /obj/item/organ/internal/vocal_cords/adamantine
		)
	golem_colour = rgb(68, 238, 221)
	info_text = "As an <span class='danger'>Adamantine Golem</span>, you possess special vocal cords allowing you to \"resonate\" messages to all golems."
	prefix = "Adamantine"
	special_names = null

//The suicide bombers of golemkind
/datum/species/golem/plasma
	name = "Plasma Golem"
	skinned_type = /obj/item/stack/ore/plasma
	golem_colour = rgb(170, 51, 221)
	heat_level_1 = 360
	heat_level_2 = 400
	heat_level_3 = 460
	info_text = "As a <span class='danger'>Plasma Golem</span>, you burn easily. Be careful, if you get hot enough while burning, you'll blow up!"
	heatmod = 0 //fine until they blow up
	prefix = "Plasma"
	special_names = list("Flood", "Fire", "Bar", "Man")
	var/boom_warning = FALSE
	var/datum/action/innate/ignite/ignite

/datum/species/golem/plasma/handle_life(mob/living/carbon/human/H)
	if(H.bodytemperature > 750)
		if(!boom_warning && H.on_fire)
			to_chat(H, "<span class='userdanger'>You feel like you could blow up at any moment!</span>")
			boom_warning = TRUE
	else
		if(boom_warning)
			to_chat(H, "<span class='notice'>You feel more stable.</span>")
			boom_warning = FALSE

	if(H.bodytemperature > 850 && H.on_fire && prob(25))
		explosion(get_turf(H), 1, 2, 4, flame_range = 5)
		msg_admin_attack("Plasma Golem ([H.name]) exploded with radius 1, 2, 4 (flame_range: 5) at ([H.x],[H.y],[H.z]). User Ckey: [key_name_admin(H)]", ATKLOG_FEW)
		log_game("Plasma Golem ([H.name]) exploded with radius 1, 2, 4 (flame_range: 5) at ([H.x],[H.y],[H.z]). User Ckey: [key_name_admin(H)]", ATKLOG_FEW)
		if(H)
			H.gib()
	if(H.fire_stacks < 2) //flammable
		H.adjust_fire_stacks(1)
	..()

/datum/species/golem/plasma/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	if(ishuman(C))
		ignite = new
		ignite.Grant(C)

/datum/species/golem/plasma/on_species_loss(mob/living/carbon/C)
	if(ignite)
		ignite.Remove(C)
	..()

/datum/action/innate/ignite
	name = "Ignite"
	desc = "Set yourself aflame, bringing yourself closer to exploding!"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "sacredflame"

/datum/action/innate/ignite/Activate()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if(H.fire_stacks)
			to_chat(owner, "<span class='notice'>You ignite yourself!</span>")
		else
			to_chat(owner, "<span class='warning'>You try to ignite yourself, but fail!</span>")
		H.IgniteMob() //firestacks are already there passively

//Harder to hurt
/datum/species/golem/diamond
	name = "Diamond Golem"
	golem_colour = rgb(0, 255, 255)
	brute_mod = 0.3 //70% damage reduction up from 55%
	burn_mod = 0.3
	tox_mod = 0.3
	skinned_type = /obj/item/stack/ore/diamond
	info_text = "As a <span class='danger'>Diamond Golem</span>, you are more resistant than the average golem."
	prefix = "Diamond"
	special_names = list("Back")

//Faster but softer and less armoured
/datum/species/golem/gold
	name = "Gold Golem"
	golem_colour = rgb(204, 204, 0)
	slowdown = 2
	brute_mod = 0.75 //25% damage reduction down from 55%
	burn_mod = 0.75
	tox_mod = 0.75
	skinned_type = /obj/item/stack/ore/gold
	info_text = "As a <span class='danger'>Gold Golem</span>, you are faster but less resistant than the average golem."
	prefix = "Golden"
	special_names = list("Boy")

//Heavier, thus higher chance of stunning when punching
/datum/species/golem/silver
	name = "Silver Golem"
	golem_colour = rgb(221, 221, 221)
	punchstunthreshold = 9 //60% chance, from 40%
	skinned_type = /obj/item/stack/ore/silver
	info_text = "As a <span class='danger'>Silver Golem</span>, your attacks have a higher chance of stunning."
	prefix = "Silver"
	special_names = list("Surfer", "Chariot", "Lining")

//Harder to stun, deals more damage, but it's even slower
/datum/species/golem/plasteel
	name = "Plasteel Golem"
	golem_colour = rgb(187, 187, 187)
	stun_mod = 0.4
	punchdamagelow = 12
	punchdamagehigh = 21
	punchstunthreshold = 18 //still 40% stun chance
	slowdown = 5 //diona speed
	skinned_type = /obj/item/stack/ore/iron
	info_text = "As a <span class='danger'>Plasteel Golem</span>, you are slower, but harder to stun, and hit very hard when punching."
	prefix = "Plasteel"
	special_names = null
	unarmed_type = /datum/unarmed_attack/golem/plasteel

/datum/unarmed_attack/golem/plasteel
	attack_verb = list("smash")
	attack_sound = 'sound/effects/meteorimpact.ogg'

//More resistant to burn damage
//Add ashstorm resistance if we ever port lavaland
/datum/species/golem/titanium
	name = "Titanium Golem"
	golem_colour = rgb(255, 255, 255)
	skinned_type = /obj/item/stack/ore/titanium
	info_text = "As a <span class='danger'>Titanium Golem</span>, you are resistant to burn damage."
	burn_mod = 0.3
	prefix = "Titanium"
	special_names = list("Dioxide")

//Even more resistant to burn damage
//Add ashstorm and lava resistance if we ever port lavaland
/datum/species/golem/plastitanium
	name = "Plastitanium Golem"
	golem_colour = rgb(136, 136, 136)
	skinned_type = /obj/item/stack/ore/titanium
	info_text = "As a <span class='danger'>Plastitanium Golem</span>, you are very resistant to burn damage."
	burn_mod = 0.15
	prefix = "Plastitanium"
	special_names = null

//Fast and regenerates... but can only speak like an abductor
/datum/species/golem/alloy
	name = "Alien Alloy Golem"
	golem_colour = rgb(51, 51, 51)
	skinned_type = /obj/item/stack/sheet/mineral/abductor
	language = "Golem Mindlink"
	default_language = "Golem Mindlink"
	slowdown = 2 //faster
	info_text = "As an <span class='danger'>Alloy Golem</span>, you are made of advanced alien materials: you are faster and regenerate over time. You are, however, only able to speak telepathically to other alloy golems."
	prefix = "Alien"
	special_names = list("Outsider", "Technology", "Watcher", "Stranger") //ominous and unknown

//Regenerates because self-repairing super-advanced alien tech
/datum/species/golem/alloy/handle_life(mob/living/carbon/human/H)
	if(H.stat == DEAD)
		return
	H.adjustBruteLoss(-2)
	H.adjustFireLoss(-2)
	H.adjustToxLoss(-2)
	H.adjustOxyLoss(-2)

/datum/species/golem/alloy/can_understand(mob/other) //Can understand everyone, but they can only speak over their mindlink
	return TRUE

/datum/species/golem/alloy/on_species_gain(mob/living/carbon/human/H)
	..()
	H.languages.Cut()
	H.add_language("Golem Mindlink")

//Regenerates like dionas, less resistant
/datum/species/golem/wood
	name = "Wood Golem"
	golem_colour = rgb(158, 112, 75)
	skinned_type = /obj/item/stack/sheet/wood
	species_traits = list(NO_BREATHE, NO_BLOOD, NO_PAIN, RADIMMUNE, VIRUSIMMUNE, NOGUNS, IS_PLANT)
	//Can burn and take damage from heat
	brute_mod = 0.7 //30% damage reduction down from 55%
	burn_mod = 1
	heatmod = 1.5

	heat_level_1 = 300
	heat_level_2 = 340
	heat_level_3 = 400

	dietflags = 0		//Regenerate nutrition in light, no diet necessary
	taste_sensitivity = TASTE_SENSITIVITY_NO_TASTE

	info_text = "As a <span class='danger'>Wooden Golem</span>, you have plant-like traits: you take damage from extreme temperatures, can be set on fire, and have lower armor than a normal golem. You regenerate when in the light and wither in the darkness."
	prefix = "Wooden"
	special_names = list("Bark", "Willow", "Catalpa", "Oak", "Sap", "Twig", "Branch", "Maple", "Birch", "Elm", "Basswood", "Cottonwood", "Larch", "Aspen", "Ash", "Beech", "Buckeye", "Cedar", "Chestnut", "Cypress", "Fir", "Hawthorn", "Hazel", "Hickory", "Ironwood", "Juniper", "Leaf", "Mangrove", "Palm", "Pawpaw", "Pine", "Poplar", "Redwood", "Redbud", "Sassafras", "Spruce", "Sumac", "Trunk", "Walnut", "Yew")
	human_surname_chance = 0
	special_name_chance = 100

/datum/species/golem/wood/handle_life(mob/living/carbon/human/H)
	var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
	if(isturf(H.loc)) //else, there's considered to be no light
		var/turf/T = H.loc
		light_amount = min(T.get_lumcount() * 10, 5)  //hardcapped so it's not abused by having a ton of flashlights
	H.nutrition = min(H.nutrition+light_amount, NUTRITION_LEVEL_WELL_FED+10)

	if(light_amount > 0)
		H.clear_alert("nolight")
	else
		H.throw_alert("nolight", /obj/screen/alert/nolight)

	if((light_amount >= 5) && !H.suiciding) //if there's enough light, heal

		H.adjustBruteLoss(-(light_amount/2))
		H.adjustFireLoss(-(light_amount/4))
	if(H.nutrition < NUTRITION_LEVEL_STARVING+50)
		H.take_overall_damage(10,0)
	..()

//Radioactive
/datum/species/golem/uranium
	name = "Uranium Golem"
	golem_colour = rgb(119, 255, 0)
	skinned_type = /obj/item/stack/ore/uranium
	info_text = "As an <span class='danger'>Uranium Golem</span>, you emit radiation. It won't harm fellow golems, but organic lifeforms will be affected."
	prefix = "Uranium"
	special_names = list("Oxide", "Rod", "Meltdown")

/datum/species/golem/uranium/handle_life(mob/living/carbon/human/H)
	for(var/mob/living/L in range(2, H))
		if(isgolem(H))
			continue
		to_chat(L, "<span class='danger'>You are enveloped by a soft green glow emanating from [H].</span>")
		L.apply_effect(10, IRRADIATE)
	..()

//Ventcrawler
/datum/species/golem/plastic
	name = "Plastic Golem"
	prefix = "Plastic"
	special_names = null
	golem_colour = rgb(255, 255, 255)
	skinned_type = /obj/item/stack/sheet/plastic
	info_text = "As a <span class='danger'>Plastic Golem</span>, you are capable of ventcrawling if you're naked."

/datum/species/golem/plastic/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	C.ventcrawler = 1

/datum/species/golem/plastic/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.ventcrawler = initial(C.ventcrawler)

//Immune to physical bullets and resistant to brute, but very vulnerable to burn damage. Dusts on death.
/datum/species/golem/sand
	name = "Sand Golem"
	golem_colour = rgb(255, 220, 143)
	skinned_type = /obj/item/stack/ore/glass //this is sand
	brute_mod = 0.25
	burn_mod = 3
	info_text = "As a <span class='danger'>Sand Golem</span>, you are immune to physical bullets and take very little brute damage, but are extremely vulnerable to burn damage and energy weapons. You will also turn to sand when dying, preventing any form of recovery."
	unarmed_type = /datum/unarmed_attack/golem/sand
	prefix = "Sand"
	special_names = list("Castle", "Bag", "Dune", "Worm", "Storm")

/datum/species/golem/sand/handle_death(mob/living/carbon/human/H)
	H.visible_message("<span class='danger'>[H] turns into a pile of sand!</span>")
	for(var/obj/item/W in H)
		H.unEquip(W)
	for(var/i=1, i <= rand(3, 5), i++)
		new /obj/item/stack/ore/glass(get_turf(H))
	qdel(H)

/datum/species/golem/sand/bullet_act(obj/item/projectile/P, mob/living/carbon/human/H)
	if(!(P.original == H && P.firer == H))
		if(P.flag == "bullet" || P.flag == "bomb")
			playsound(H, 'sound/effects/shovel_dig.ogg', 70, 1)
			H.visible_message("<span class='danger'>The [P.name] sinks harmlessly in [H]'s sandy body!</span>", \
			"<span class='userdanger'>The [P.name] sinks harmlessly in [H]'s sandy body!</span>")
			return FALSE
	return TRUE

/datum/unarmed_attack/golem/sand
	attack_sound = 'sound/effects/shovel_dig.ogg'

//Reflects lasers and resistant to burn damage, but very vulnerable to brute damage. Shatters on death.
/datum/species/golem/glass
	name = "Glass Golem"
	golem_colour = rgb(90, 150, 180)
	skinned_type = /obj/item/shard
	brute_mod = 3 //very fragile
	burn_mod = 0.25
	info_text = "As a <span class='danger'>Glass Golem</span>, you reflect lasers and energy weapons, and are very resistant to burn damage. However, you are extremely vulnerable to brute damage. On death, you'll shatter beyond any hope of recovery."
	unarmed_type = /datum/unarmed_attack/golem/glass
	prefix = "Glass"
	special_names = list("Lens", "Prism", "Fiber", "Bead")

/datum/species/golem/glass/handle_death(mob/living/carbon/human/H)
	playsound(H, "shatter", 70, 1)
	H.visible_message("<span class='danger'>[H] shatters!</span>")
	for(var/obj/item/W in H)
		H.unEquip(W)
	for(var/i=1, i <= rand(3, 5), i++)
		new /obj/item/shard(get_turf(H))
	qdel(H)

/datum/species/golem/glass/bullet_act(obj/item/projectile/P, mob/living/carbon/human/H)
	if(!(P.original == H && P.firer == H)) //self-shots don't reflect
		if(P.is_reflectable)
			H.visible_message("<span class='danger'>The [P.name] gets reflected by [H]'s glass skin!</span>", \
			"<span class='userdanger'>The [P.name] gets reflected by [H]'s glass skin!</span>")
			if(P.starting)
				var/new_x = P.starting.x + pick(0, 0, 0, 0, 0, -1, 1, -2, 2)
				var/new_y = P.starting.y + pick(0, 0, 0, 0, 0, -1, 1, -2, 2)
				var/turf/curloc = get_turf(H)

				// redirect the projectile
				P.firer = src
				P.original = locate(new_x, new_y, P.z)
				P.starting = curloc
				P.current = curloc
				P.yo = new_y - curloc.y
				P.xo = new_x - curloc.x
				P.Angle = null
			return FALSE
	return TRUE

/datum/unarmed_attack/golem/glass
	attack_sound = 'sound/effects/glassbr2.ogg'

//Teleports when hit or when it wants to
/datum/species/golem/bluespace
	name = "Bluespace Golem"
	golem_colour = rgb(51, 51, 255)
	skinned_type = /obj/item/stack/ore/bluespace_crystal
	info_text = "As a <span class='danger'>Bluespace Golem</span>, you are spatially unstable: You will teleport when hit, and you can teleport manually at a long distance."
	prefix = "Bluespace"
	special_names = list("Crystal", "Polycrystal")
	unarmed_type = /datum/unarmed_attack/golem/bluespace

	var/datum/action/innate/unstable_teleport/unstable_teleport
	var/teleport_cooldown = 100
	var/last_teleport = 0
	var/tele_range = 6

/datum/species/golem/bluespace/proc/reactive_teleport(mob/living/carbon/human/H)
	H.visible_message("<span class='warning'>[H] teleports!</span>", "<span class='danger'>You destabilize and teleport!</span>")
	var/list/turfs = new/list()
	for(var/turf/T in orange(tele_range, H))
		if(T.density)
			continue
		if(T.x>world.maxx-tele_range || T.x<tele_range)
			continue
		if(T.y>world.maxy-tele_range || T.y<tele_range)
			continue
		turfs += T
	if(!turfs.len)
		turfs += pick(/turf in orange(tele_range, H))
	var/turf/picked = pick(turfs)
	if(!isturf(picked))
		return
	if(H.buckled)
		H.buckled.unbuckle_mob()
	do_teleport(H, picked)
	return TRUE

/datum/species/golem/bluespace/spec_hitby(atom/movable/AM, mob/living/carbon/human/H)
	..()
	var/obj/item/I
	if(istype(AM, /obj/item))
		I = AM
		if(I.thrownby == H) //No throwing stuff at yourself to trigger the teleport
			return 0
		else
			reactive_teleport(H)

/datum/species/golem/bluespace/spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/H, datum/martial_art/attacker_style)
	..()
	if(world.time > last_teleport + teleport_cooldown && M != H &&  M.a_intent != INTENT_HELP)
		reactive_teleport(H)

/datum/species/golem/bluespace/spec_attacked_by(obj/item/I, mob/living/user, obj/item/bodypart/affecting, intent, mob/living/carbon/human/H)
	..()
	if(world.time > last_teleport + teleport_cooldown && user != H)
		reactive_teleport(H)

/datum/species/golem/bluespace/bullet_act(obj/item/projectile/P, mob/living/carbon/human/H)
	if(world.time > last_teleport + teleport_cooldown)
		reactive_teleport(H)
	return TRUE

/datum/species/golem/bluespace/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	..()
	if(ishuman(C))
		unstable_teleport = new
		unstable_teleport.Grant(C)
		last_teleport = world.time

/datum/species/golem/bluespace/on_species_loss(mob/living/carbon/C)
	if(unstable_teleport)
		unstable_teleport.Remove(C)
	..()

/datum/action/innate/unstable_teleport
	name = "Unstable Teleport"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "blink"
	icon_icon = 'icons/mob/actions/actions.dmi'
	var/activated = FALSE // To prevent spamming
	var/cooldown = 150
	var/last_teleport = 0
	var/tele_range = 6

/datum/action/innate/unstable_teleport/IsAvailable()
	if(..())
		if(world.time > last_teleport + cooldown && !activated)
			return 1
		return 0

/datum/action/innate/unstable_teleport/Activate()
	activated = TRUE
	var/mob/living/carbon/human/H = owner
	H.visible_message("<span class='warning'>[H] starts vibrating!</span>", "<span class='danger'>You start charging your bluespace core...</span>")
	playsound(get_turf(H), 'sound/weapons/flash.ogg', 25, 1)
	addtimer(CALLBACK(src, .proc/teleport, H), 15)

/datum/action/innate/unstable_teleport/proc/teleport(mob/living/carbon/human/H)
	activated = FALSE
	H.visible_message("<span class='warning'>[H] teleports!</span>", "<span class='danger'>You teleport!</span>")
	var/list/turfs = new/list()
	for(var/turf/T in orange(tele_range, H))
		if(istype(T, /turf/space))
			continue
		if(T.density)
			continue
		if(T.x>world.maxx-tele_range || T.x<tele_range)
			continue
		if(T.y>world.maxy-tele_range || T.y<tele_range)
			continue
		turfs += T
	if(!turfs.len)
		turfs += pick(/turf in orange(tele_range, H))
	var/turf/picked = pick(turfs)
	if(!isturf(picked))
		return
	if(H.buckled)
		H.buckled.unbuckle_mob()
	do_teleport(H, picked)
	last_teleport = world.time
	UpdateButtonIcon() //action icon looks unavailable
	sleep(cooldown + 5)
	UpdateButtonIcon() //action icon looks available again

/datum/unarmed_attack/golem/bluespace
	attack_verb = "bluespace punch"
	attack_sound = 'sound/effects/phasein.ogg'

//honk
/datum/species/golem/bananium
	name = "Bananium Golem"
	golem_colour = rgb(255, 255, 0)
	punchdamagelow = 0
	punchdamagehigh = 0
	punchstunthreshold = 1 //Harmless and can't stun
	skinned_type = /obj/item/stack/ore/bananium
	info_text = "As a <span class='danger'>Bananium Golem</span>, you are made for pranking. Your body emits natural honks, and you can barely even hurt people when punching them. Your skin also bleeds banana peels when damaged."
	prefix = "Bananium"
	special_names = null
	unarmed_type = /datum/unarmed_attack/golem/bananium

	var/last_honk = 0
	var/honkooldown = 0
	var/last_banana = 0
	var/banana_cooldown = 100
	var/active = null

/datum/species/golem/bananium/on_species_gain(mob/living/carbon/human/H)
	..()
	last_banana = world.time
	last_honk = world.time
	H.job = "Clown"
	H.mutations.Add(COMIC)
	H.equip_to_slot_or_del(new /obj/item/reagent_containers/food/drinks/bottle/bottleofbanana(H), slot_r_store)
	H.equip_to_slot_or_del(new /obj/item/bikehorn(H), slot_l_store)

/datum/species/golem/bananium/get_random_name()
	var/clown_name = pick(GLOB.clown_names)
	var/golem_name = "[prefix] [clown_name]"
	return golem_name

/datum/species/golem/bananium/spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/H, datum/martial_art/attacker_style)
	..()
	if(world.time > last_banana + banana_cooldown && M != H &&  M.a_intent != INTENT_HELP)
		new/obj/item/grown/bananapeel/specialpeel(get_turf(H))
		last_banana = world.time

/datum/species/golem/bananium/spec_attacked_by(obj/item/I, mob/living/user, obj/item/bodypart/affecting, intent, mob/living/carbon/human/H)
	..()
	if(world.time > last_banana + banana_cooldown && user != H)
		new/obj/item/grown/bananapeel/specialpeel(get_turf(H))
		last_banana = world.time

/datum/species/golem/bananium/bullet_act(obj/item/projectile/P, mob/living/carbon/human/H)
	if(world.time > last_banana + banana_cooldown)
		new/obj/item/grown/bananapeel/specialpeel(get_turf(H))
		last_banana = world.time
	return TRUE

/datum/species/golem/bananium/spec_hitby(atom/movable/AM, mob/living/carbon/human/H)
	..()
	var/obj/item/I
	if(istype(AM, /obj/item))
		I = AM
		if(I.thrownby == H) //No throwing stuff at yourself to make bananas
			return 0
		else
			new/obj/item/grown/bananapeel/specialpeel(get_turf(H))
			last_banana = world.time

/datum/species/golem/bananium/handle_life(mob/living/carbon/human/H)
	if(!active)
		if(world.time > last_honk + honkooldown)
			active = 1
			playsound(get_turf(H), 'sound/items/bikehorn.ogg', 50, 1)
			last_honk = world.time
			honkooldown = rand(20, 80)
			active = null
	..()

/datum/species/golem/bananium/handle_death(mob/living/carbon/human/H)
	playsound(get_turf(H), 'sound/misc/sadtrombone.ogg', 70, 0)

/datum/unarmed_attack/golem/bananium
	attack_verb = list("HONK")
	attack_sound = 'sound/items/airhorn2.ogg'
	animation_type = ATTACK_EFFECT_DISARM
	harmless = TRUE

//...
/datum/species/golem/tranquillite
	name = "Tranquillite Golem"
	prefix = "Tranquillite"
	special_names = null
	golem_colour = rgb(255, 255, 255)
	skinned_type = /obj/item/stack/ore/tranquillite
	info_text = "As a <span class='danger'>Tranquillite Golem</span>, you are capable of creating invisible walls, and can regenerate by drinking your bottle of Nothing."
	unarmed_type = /datum/unarmed_attack/golem/tranquillite

/datum/species/golem/tranquillite/get_random_name()
	var/mime_name = pick(GLOB.mime_names)
	var/golem_name = "[prefix] [mime_name]"
	return golem_name

/datum/species/golem/tranquillite/on_species_gain(mob/living/carbon/human/H)
	..()
	H.job = "Mime"
	H.equip_to_slot_or_del(new 	/obj/item/clothing/head/beret(H), slot_head)
	H.equip_to_slot_or_del(new 	/obj/item/reagent_containers/food/drinks/bottle/bottleofnothing(H), slot_r_store)
	H.equip_to_slot_or_del(new 	/obj/item/cane(H), slot_l_hand)
	if(H.mind)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/conjure/mime_wall(null))
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/mime/speak(null))
		H.mind.miming = TRUE

/datum/unarmed_attack/golem/tranquillite
	attack_sound = null
	miss_sound = null

//Golem abstract items

/obj/item/clothing/under/golem
	name = "golem skin"
	desc = "a golem's skin"
	icon_state = "golem"
	item_state = "golem"
	item_color = "golem"
	has_sensor = 0
	flags = ABSTRACT | NODROP
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/suit/golem
	name = "golem shell"
	desc = "a golem's thick outter shell"
	icon_state = "golem"
	item_state = "golem"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.02
	body_parts_covered = HEAD | UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	flags_inv = HIDEGLOVES | HIDESHOES
	flags = STOPSPRESSUREDMAGE | ABSTRACT | NODROP | THICKMATERIAL
	flags_size = ONESIZEFITSALL
	cold_protection = HEAD | UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 100, rad = 0)

/obj/item/clothing/shoes/golem
	name = "golem's feet"
	desc = "sturdy golem feet"
	icon_state = "golem"
	item_state = "golem"
	flags = ABSTRACT | NODROP

/obj/item/clothing/mask/gas/golem
	name = "golem's face"
	desc = "the imposing face of a golem"
	icon_state = "golem"
	item_state = "golem"
	unacidable = 1
	flags = ABSTRACT | NODROP
	flags_inv = HIDEEARS | HIDEEYES

/obj/item/clothing/gloves/golem
	name = "golem's hands"
	desc = "strong golem hands"
	icon_state = "golem"
	item_state = null
	flags = ABSTRACT | NODROP
