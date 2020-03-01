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
		var/datum/reagent/N = O.reagents.has_reagent(/datum/reagent/consumable/nutriment)
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
	icon = 'icons/obj/food/slimecookies.dmi'
	var/taste = "error"
	var/nutrition = 5
	icon_state = "base"
	force = 0
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	throw_speed = 3
	throw_range = 6

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
			M.reagents.add_reagent(/datum/reagent/consumable/nutriment,nutrition)
		do_effect(M, user)
		qdel(src)
		return
	..()

/obj/item/slimecross/consuming/lightpink
	colour = "light pink"
	effect_desc = "Creates a slime cookie that makes the target, and anyone next to the target, pacifistic for a small amount of time."
	cookietype = /obj/item/slime_cookie/lightpink

/obj/item/slime_cookie/lightpink
	name = "peace cookie"
	desc = "A light pink cookie with a peace symbol in the icing. Lovely!"
	icon_state = "lightpink"
	taste = "strawberry icing and P.L.U.R" //Literal candy raver.

/obj/item/slime_cookie/lightpink/do_effect(mob/living/M, mob/user)
	M.apply_status_effect(/datum/status_effect/peacecookie)
