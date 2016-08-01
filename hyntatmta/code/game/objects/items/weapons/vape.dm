/obj/item/device/vape
	name = "E-cig"
	desc = "Самая простенькая электронная сигарета"
	icon = 'hyntatmta/icons/obj/vape.dmi'
	icon_state = "classic"
	w_class = 1
	flags = OPENCONTAINER
	var/on = 0
	var/lastHolder = null
	var/smoketime = 300
	var/chem_volume = 30
	var/vape_cooldown = 0
	var/vape_delay = 30
	var/vape_consume = 0.25

/obj/item/device/vape/New()
	create_reagents(chem_volume) // making the cigarrete a chemical holder with a maximum volume of 30

/obj/item/device/vape/Destroy()
	qdel(reagents)
	return ..()

/obj/item/device/vape/attack(var/mob/living/carbon/M, mob/user as mob, def_zone)
	if(vape_cooldown > world.time)
		to_chat(user, "<span class='warning'><B>[name]</B> слегка перегрелся и остывает!</span>")
		return
	if(M == user)
		if(!on)
			to_chat(user, "You must turn your [name] ON!")
		else
			to_chat(user, "Вы вдыхаете содержимое [name]...")
			if(do_after(user, 15, target = src))
				vaping(user)
				user.visible_message("<span class='notice'><B>[user]</B> выдыхает пар, сделанный [name]</span>", "<span class='notice'>Вы выдыхаете пар, сделанный [name]</span>")
				vape_cooldown = world.time + vape_delay
	return

/obj/item/device/vape/afterattack(obj/item/weapon/reagent_containers/glass/glass, mob/user as mob, proximity)
	..()
	if(!proximity) return
	if(istype(glass))	//you can dip cigarettes into beakers
		var/transfered = glass.reagents.trans_to(src, chem_volume)
		if(transfered)	//if reagents were transfered, show the message
			to_chat(user, "<span class='notice'>Вы залили жидкость в [src] из [glass].</span>")
		else			//if not, either the beaker was empty, or the cigarette was full
			if(!glass.reagents.total_volume)
				to_chat(user, "<span class='notice'>[glass] пуст.</span>")
			else
				to_chat(user, "<span class='notice'>[name] полон.</span>")

/obj/item/device/vape/proc/vaping(mob/user as mob)
	if(reagents && reagents.total_volume)	//	check if it has any reagents at all
		var/mob/living/carbon/C = loc
		reagents.trans_to(C, vape_consume*4)
		var/datum/effect/system/chem_smoke_spread/smoke = new
		smoke.set_up(reagents, 1, 0, src.loc, 0, silent = 1)
		playsound(src.loc, 'sound/effects/bamf.ogg', 50, 1, -3)
		smoke.start(2)
		if(!reagents.total_volume) // There were reagents, but now they're gone
			to_chat(C, "<span class='notice'>Жидкость внутри [name] закончилась.</span>")
	else // else just remove some of the reagents
		reagents.remove_any(vape_consume)
	return

/obj/item/device/vape/attack_self(mob/user as mob)
	switch(on) // fam
		if(TRUE)
			on = FALSE // not chill dude
			icon_state = "[initial(icon_state)]"
			to_chat(user, "Вы выключили [name].")
		if(FALSE)
			on = TRUE // chill dude
			icon_state = "[initial(icon_state)]-on"
			to_chat(user, "Вы включили [name].")
			if(reagents.get_reagent_amount("plasma")) // the plasma explodes when exposed to fire
				var/datum/effect/system/reagents_explosion/e = new()
				e.set_up(round(reagents.get_reagent_amount("plasma") / 2.5, 1), get_turf(src), 0, 0)
				e.start()
				if(ismob(loc))
					var/mob/M = loc
					M.unEquip(src, 1)
				qdel(src)
				return
			if(reagents.get_reagent_amount("fuel")) // the fuel explodes, too, but much less violently
				var/datum/effect/system/reagents_explosion/e = new()
				e.set_up(round(reagents.get_reagent_amount("fuel") / 5, 1), get_turf(src), 0, 0)
				e.start()
				if(ismob(loc))
					var/mob/M = loc
					M.unEquip(src, 1)
				qdel(src)
				return
			flags &= ~NOREACT // allowing reagents to react after being lit
			reagents.handle_reactions()
	return ..()

/obj/item/device/vape/random
	name = "VapeX RandomRoulette"
	desc = "Содержимое этой штуки неизвестно."
	icon_state = "random"

/obj/item/device/vape/random/New()
	..()
	var/random_reagent = pick("fuel","saltpetre","synaptizine","green_vomit","potass_iodide","msg","lexorin","mannitol","spaceacillin","cryoxadone","holywater","tea","egg","haloperidol","mutagen","omnizine","carpet","aranesp","cryostylane","chocolate","bilk","cheese","rum","blood","charcoal","coffee","ectoplasm","space_drugs","milk","mutadone","antihol","teporone","insulin","salbutamol","toxin")
	reagents.add_reagent(random_reagent, 10)

/obj/item/device/vape/stylish
	name = "VapeNation eCig"
	desc = "Стиль решает все. Го грин."
	icon_state = "stylish"
	w_class = 3
