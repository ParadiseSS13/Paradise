/*
Consuming extracts:
	Can eat food items.
	After consuming enough, produces special cookies.
*/
/obj/item/slimecross/consuming
	name = "consuming extract"
	desc = "It hungers... for <i>more</i>." //My slimecross has finally decided to eat... my buffet!
	icon_state = "consuming"
	effect = "consuming"
	var/nutriment_eaten = 0
	var/nutriment_required = 10
	var/cooldown = 600 //1 minute.
	var/last_produced = 0
	var/cookies = 5 //Number of cookies to spawn
	var/cookietype = /obj/item/slime_cookie

/obj/item/slimecross/consuming/attackby(obj/item/O, mob/user)
	if(istype(O,/obj/item/reagent_containers/food/snacks))
		if(last_produced + cooldown > world.time)
			to_chat(user, "<span class='warning'>[src] is still digesting after its last meal!</span>")
			return
		var/datum/reagent/N = O.reagents.has_reagent("nutriment")
		if(N)
			nutriment_eaten += N.volume
			to_chat(user, "<span class='notice'>[src] opens up and swallows [O] whole!</span>")
			qdel(O)
			playsound(src, 'sound/items/eatfood.ogg', 20, TRUE)
		else
			to_chat(user, "<span class='warning'>[src] burbles unhappily at the offering.</span>")
		if(nutriment_eaten >= nutriment_required)
			nutriment_eaten = 0
			user.visible_message("<span class='notice'>[src] swells up and produces a small pile of cookies!</span>")
			playsound(src, 'sound/effects/splat.ogg', 40, TRUE)
			last_produced = world.time
			for(var/i in 1 to cookies)
				var/obj/item/S = spawncookie()
				S.pixel_x = rand(-5, 5)
				S.pixel_y = rand(-5, 5)
		return
	..()

/obj/item/slimecross/consuming/proc/spawncookie()
	return new cookietype(get_turf(src))

/obj/item/slime_cookie //While this technically acts like food, it's so removed from it that I made it its' own type.
	name = "error cookie"
	desc = "A weird slime cookie. You shouldn't see this."
	icon = 'icons/hispania/obj/food/slimecookies.dmi'
	var/taste = "error"
	var/nutrition = 5
	icon_state = "base"
	force = 0
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	throw_speed = 3
	throw_range = 6
	var/effect_type

/obj/item/slime_cookie/proc/do_effect(mob/living/M, mob/user)
	return

/obj/item/slime_cookie/attack(mob/living/M, mob/user)
	var/fed = FALSE
	if(M == user)
		M.visible_message("<span class='notice'>[user] eats [src]!</span>", "<span class='notice'>You eat [src].</span>")
		fed = TRUE
	else
		M.visible_message("<span class='danger'>[user] tries to force [M] to eat [src]!</span>", "<span class='userdanger'>[user] tries to force you to eat [src]!</span>")
		if(do_after(user, 20, target = M))
			fed = TRUE
			M.visible_message("<span class='danger'>[user] forces [M] to eat [src]!</span>", "<span class='warning'>[user] forces you to eat [src].</span>")
	if(fed)
		var/mob/living/carbon/human/H = M

		if(!istype(H) || !HAS_TRAIT(H, TRAIT_AGEUSIA))
			to_chat(M, "<span class='notice'>Tastes like [taste].</span>")
		playsound(get_turf(M), 'sound/items/eatfood.ogg', 20, TRUE)
		if(nutrition)
			M.reagents.add_reagent("nutriment", nutrition)
		do_effect(M, user)
		qdel(src)
		return
	..()

/obj/item/slimecross/consuming/grey
	colour = "grey"
	effect_desc = "Creates a slime cookie."
	cookietype = /obj/item/slime_cookie/grey

/obj/item/slime_cookie/grey
	name = "slime cookie"
	desc = "A grey-ish transparent cookie. Nutritious, probably."
	icon_state = "grey"
	taste = "goo"
	nutrition = 15

/obj/item/slimecross/consuming/purple
	colour = "purple"
	effect_desc = "Creates a slime cookie that heals the target from every type of damage."
	cookietype = /obj/item/slime_cookie/purple

/obj/item/slime_cookie/purple
	name = "health cookie"
	desc = "A purple cookie with a cross pattern. Soothing."
	icon_state = "purple"
	taste = "fruit jam and cough medicine"

/obj/item/slime_cookie/purple/do_effect(mob/living/M, mob/user)
	M.adjustBruteLoss(-5)
	M.adjustFireLoss(-5)
	M.adjustToxLoss(-5)
	M.adjustOxyLoss(-5)
	M.adjustCloneLoss(-5)
	M.adjustBrainLoss(-5)

/obj/item/slimecross/consuming/blue
	colour = "blue"
	effect_desc = "Creates a slime cookie that wets the floor around you and makes you immune to water based slipping for a short time."
	cookietype = /obj/item/slime_cookie/blue

/obj/item/slime_cookie/blue
	name = "water cookie"
	desc = "A transparent blue cookie. Constantly dripping wet."
	icon_state = "blue"
	taste = "water"
	effect_type = /datum/status_effect/watercookie

/obj/item/slime_cookie/blue/do_effect(mob/living/M, mob/user)
	if(!M.has_status_effect(effect_type))
		M.apply_status_effect(effect_type)

/obj/item/slimecross/consuming/metal
	colour = "metal"
	effect_desc = "Creates a slime cookie that increases the target's resistance to brute damage."
	cookietype = /obj/item/slime_cookie/metal

/obj/item/slime_cookie/metal
	name = "metallic cookie"
	desc = "A shiny grey cookie. Hard to the touch."
	icon_state = "metal"
	taste = "copper"
	effect_type = /datum/status_effect/metalcookie

/obj/item/slime_cookie/metal/do_effect(mob/living/M, mob/user)
	if(!M.has_status_effect(effect_type))
		M.apply_status_effect(effect_type)

/obj/item/slimecross/consuming/yellow
	colour = "yellow"
	effect_desc = "Creates a slime cookie that makes the target immune to electricity for a short time."
	cookietype = /obj/item/slime_cookie/yellow

/obj/item/slime_cookie/yellow
	name = "sparking cookie"
	desc = "A yellow cookie with a lightning pattern. Has a rubbery texture."
	icon_state = "yellow"
	taste = "lemon cake and rubber gloves"
	effect_type = /datum/status_effect/adamantinecookie

/obj/item/slime_cookie/yellow/do_effect(mob/living/M, mob/user)
	if(!M.has_status_effect(effect_type))
		M.apply_status_effect(effect_type)

/obj/item/slimecross/consuming/darkblue
	colour = "dark blue"
	effect_desc = "Creates a slime cookie that chills the target and extinguishes them."
	cookietype = /obj/item/slime_cookie/darkblue

/obj/item/slime_cookie/darkblue
	name = "frosty cookie"
	desc = "A dark blue cookie with a snowflake pattern. Feels cold."
	icon_state = "darkblue"
	taste = "mint and bitter cold"

/obj/item/slime_cookie/darkblue/do_effect(mob/living/M, mob/user)
	M.adjust_bodytemperature(-110)
	M.ExtinguishMob()

/obj/item/slimecross/consuming/silver
	colour = "silver"
	effect_desc = "Creates a slime cookie that never gets the target fat."
	cookietype = /obj/item/slime_cookie/silver

/obj/item/slime_cookie/silver
	name = "waybread cookie"
	desc = "A warm, crispy cookie, sparkling silver in the light. Smells wonderful."
	icon_state = "silver"
	taste = "masterful elven baking"
	nutrition = 0 //We don't want normal nutriment

/obj/item/slime_cookie/silver/do_effect(mob/living/M, mob/user)
	M.reagents.add_reagent("nutriestable", 10)

/obj/item/slimecross/consuming/cerulean
	colour = "cerulean"
	effect_desc = "Creates a slime cookie that has a chance to make another once you eat it."
	cookietype = /obj/item/slime_cookie/cerulean
	cookies = 3 //You're gonna get more.

/obj/item/slime_cookie/cerulean
	name = "duplicookie"
	desc = "A cerulean cookie with strange proportions. It feels like it could break apart easily."
	icon_state = "cerulean"
	taste = "a sugar cookie"

/obj/item/slime_cookie/cerulean/do_effect(mob/living/M, mob/user)
	if(prob(50))
		to_chat(M, "<span class='notice'>A piece of [src] breaks off while you chew, and falls to the ground.</span>")
		var/obj/item/slime_cookie/cerulean/C = new(get_turf(M))
		C.taste = taste + " and a sugar cookie"

/obj/item/slimecross/consuming/pyrite
	colour = "pyrite"
	effect_desc = "Creates a slime cookie that randomly colors the target."
	cookietype = /obj/item/slime_cookie/pyrite

/obj/item/slime_cookie/pyrite
	name = "color cookie"
	desc = "A yellow cookie with rainbow-colored icing. Reflects the light strangely."
	icon_state = "pyrite"
	taste = "vanilla and " //Randomly selected color dye.
	var/colour = "#FFFFFF"

/obj/item/slime_cookie/pyrite/Initialize()
	. = ..()
	var/tastemessage = "paint remover"
	switch(rand(1,8))
		if(1)
			tastemessage = "red dye"
			colour = "#FF0000"
		if(2)
			tastemessage = "orange dye"
			colour = "#FFA500"
		if(3)
			tastemessage = "yellow dye"
			colour = "#FFFF00"
		if(4)
			tastemessage = "green dye"
			colour = "#00FF00"
		if(5)
			tastemessage = "blue dye"
			colour = "#0000FF"
		if(6)
			tastemessage = "indigo dye"
			colour = "#4B0082"
		if(7)
			tastemessage = "violet dye"
			colour = "#FF00FF"
	taste += tastemessage

/obj/item/slime_cookie/pyrite/do_effect(mob/living/M, mob/user)
	M.add_atom_colour(colour,WASHABLE_COLOUR_PRIORITY)

/obj/item/slimecross/consuming/red
	colour = "red"
	effect_desc = "Creates a slime cookie that creates a spatter of blood on the floor, while also restoring some of the target's blood."
	cookietype = /obj/item/slime_cookie/red

/obj/item/slime_cookie/red
	name = "blood cookie"
	desc = "A red cookie, oozing a thick red fluid. Vampires might enjoy it."
	icon_state = "red"
	taste = "red velvet and iron"

/obj/item/slime_cookie/red/do_effect(mob/living/M, mob/user)
	new /obj/effect/decal/cleanable/blood(get_turf(M))
	playsound(get_turf(M), 'sound/effects/splat.ogg', 10, TRUE)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		C.blood_volume += 25 //Half a vampire drain.

/obj/item/slimecross/consuming/lightpink
	colour = "light pink"
	effect_desc = "Creates a slime cookie that makes the target, and anyone next to the target, pacifistic for a small amount of time."
	cookietype = /obj/item/slime_cookie/lightpink

/obj/item/slime_cookie/lightpink
	name = "peace cookie"
	desc = "A light pink cookie with a peace symbol in the icing. Lovely!"
	icon_state = "lightpink"
	taste = "strawberry icing and P.L.U.R" //Literal candy raver.
	effect_type = /datum/status_effect/peacecookie

/obj/item/slime_cookie/lightpink/do_effect(mob/living/M, mob/user)
	if(!M.has_status_effect(effect_type))
		M.apply_status_effect(effect_type)

/obj/item/slimecross/consuming/adamantine
	colour = "adamantine"
	effect_desc = "Creates a slime cookie that increases the target's resistance to burn damage."
	cookietype = /obj/item/slime_cookie/adamantine

/obj/item/slime_cookie/adamantine
	name = "crystal cookie"
	desc = "A translucent rock candy in the shape of a cookie. Surprisingly chewy."
	icon_state = "adamantine"
	taste = "crystalline sugar and metal"
	effect_type = /datum/status_effect/adamantinecookie

/obj/item/slime_cookie/adamantine/do_effect(mob/living/M, mob/user)
	if(!M.has_status_effect(effect_type))
		M.apply_status_effect(effect_type)

/obj/item/slimecross/consuming/bluespace
	colour = "bluespace"
	effect_desc = "Creates a slime cookie that teleports the target to a random place in the area."
	cookietype = /obj/item/slime_cookie/bluespace

/obj/item/slime_cookie/bluespace
	name = "space cookie"
	desc = "A white cookie with green icing. Surprisingly hard to hold."
	icon_state = "bluespace"
	taste = "sugar and starlight"

/obj/item/slime_cookie/bluespace/do_effect(mob/living/M, mob/user)
	var/list/L = get_area_turfs(get_area(get_turf(M)))
	var/turf/target
	while (L.len && !target)
		var/I = rand(1, L.len)
		var/turf/T = L[I]
		if(!T.density)
			var/clear = TRUE
			for(var/obj/O in T)
				if(O.density)
					clear = FALSE
					break
			if(clear)
				target = T
		if (!target)
			L.Cut(I,I+1)

	if(target)
		do_teleport(M, target, 0, asoundin = 'sound/effects/phasein.ogg')
		new /obj/effect/particle_effect/sparks(get_turf(M))
		playsound(get_turf(M), "sparks", 50, TRUE)
