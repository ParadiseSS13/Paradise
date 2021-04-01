/*
Slimecrossing Potions
	Potions added by the slimecrossing system.
	Collected here for clarity.
*/

//Extract cloner - Charged Grey
/obj/item/slimepotion/extract_cloner
	name = "extract cloning potion"
	desc = "An more powerful version of the extract enhancer potion, capable of cloning regular slime extracts."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potpurple"

/obj/item/slimepotion/extract_cloner/afterattack(obj/item/target, mob/user , proximity)
	if(!proximity)
		return
	if(istype(target, /obj/item/reagent_containers))
		return ..(target, user, proximity)
	if(istype(target, /obj/item/slimecross))
		to_chat(user, "<span class='warning'>[target] is too complex for the potion to clone!</span>")
		return
	if(!istype(target, /obj/item/slime_extract))
		return
	var/obj/item/slime_extract/S = target
	if(S.recurring)
		to_chat(user, "<span class='warning'>[target] is too complex for the potion to clone!</span>")
		return
	var/path = S.type
	var/obj/item/slime_extract/C = new path(get_turf(target))
	C.Uses = S.Uses
	to_chat(user, "<span class='notice'>You pour the potion onto [target], and the fluid solidifies into a copy of it!</span>")
	qdel(src)
	return

/*
//Peace potion - Charged Light Pink
/obj/item/slimepotion/peacepotion
	name = "pacification potion"
	desc = "A light pink solution of chemicals, smelling like liquid peace. And mercury salts."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potlightpink"

/obj/item/slimepotion/peacepotion/attack(mob/living/M, mob/user)
	if(!isliving(M) || M.stat == DEAD)
		to_chat(user, "<span class='warning'>The pacification potion only works on the living.</span>")
		return ..()
	if(istype(M, /mob/living/simple_animal/hostile/megafauna))
		to_chat(user, "<span class='warning'>The pacification potion does not work on beings of pure evil!</span>")
		return ..()
	if(M != user)
		M.visible_message("<span class='danger'>[user] starts to feed [M] a pacification potion!</span>",
			"<span class='userdanger'>[user] starts to feed you a pacification!</span>")
	else
		M.visible_message("<span class='danger'>[user] starts to drink the pacification potion!</span>",
			"<span class='danger'>You start to drink the pacification potion!</span>")

	if(!do_after(user, 100, target = M))
		return
	if(M != user)
		to_chat(user, "<span class='notice'>You feed [M] the pacification potion!</span>")
	else
		to_chat(user, "<span class='warning'>You drink the pacification potion!</span>")
	if(isanimal(M))
		ADD_TRAIT(M, TRAIT_PACIFISM, MAGIC_TRAIT)
	else if(iscarbon(M))
		var/mob/living/carbon/C = M
		C.gain_trauma(/datum/brain_trauma/severe/pacifism, TRAUMA_RESILIENCE_SURGERY)
	qdel(src)
*/

/obj/item/slimepotion/slime_reviver
	name = "slime revival potion"
	desc = "Infused with plasma and compressed gel, this brings dead slimes back to life."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potsilver"

/obj/item/slimepotion/slime_reviver/attack(mob/living/simple_animal/slime/M, mob/user)
	if(!isslime(M))
		to_chat(user, "<span class='warning'>The potion only works on slimes!</span>")
		return ..()
	if(M.stat != DEAD)
		to_chat(user, "<span class='warning'>The slime is still alive!</span>")
		return
	if(M.maxHealth <= 0)
		to_chat(user, "<span class='warning'>The slime is too unstable to return!</span>")
	M.revive()
	M.stat = CONSCIOUS
	M.visible_message("<span class='notice'>[M] is filled with renewed vigor and blinks awake!</span>")
	M.maxHealth -= 10 //Revival isn't healthy.
	M.health -= 10
	M.regenerate_icons()
	qdel(src)

//Stabilizer potion - Charged Blue
/obj/item/slimepotion/slime/chargedstabilizer
	name = "slime omnistabilizer"
	desc = "An extremely potent chemical mix that will stop a slime from mutating completely."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potcyan"

/obj/item/slimepotion/slime/chargedstabilizer/attack(mob/living/simple_animal/slime/M, mob/user)
	if(!isslime(M))
		to_chat(user, "<span class='warning'>The stabilizer only works on slimes!</span>")
		return ..()
	if(M.stat)
		to_chat(user, "<span class='warning'>The slime is dead!</span>")
		return
	if(M.mutation_chance == 0)
		to_chat(user, "<span class='warning'>The slime already has no chance of mutating!</span>")
		return

	to_chat(user, "<span class='notice'>You feed the slime the omnistabilizer. It will not mutate this cycle!</span>")
	M.mutation_chance = 0
	qdel(src)

//Enhancer potion - Charged Cerulean
/obj/item/slimepotion/enhancer/max
	name = "extract maximizer"
	desc = "An extremely potent chemical mix that will maximize a slime extract's uses."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "potpurple"
