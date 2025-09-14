//Originally coded by ISaidNo, later modified by Kelenius. Ported from Baystation12.

/obj/structure/closet/crate/secure/loot
	name = "abandoned crate"
	desc = "What could be inside?"
	var/code = null
	var/lastattempt = null
	var/attempts = 10
	var/codelen = 4
	integrity_failure = 0 //no breaking open the crate

/obj/structure/closet/crate/secure/loot/Initialize(mapload)
	. = ..()
	var/list/digits = list("1", "2", "3", "4", "5", "6", "7", "8", "9", "0")
	code = ""
	for(var/i = 0, i < codelen, i++)
		var/dig = pick(digits)
		code += dig
		digits -= dig  //Player can enter codes with matching digits, but there are never matching digits in the answer

/obj/structure/closet/crate/secure/loot/attack_hand(mob/user)
	if(locked)
		to_chat(user, "<span class='notice'>The crate is locked with a Deca-code lock.</span>")
		var/input = clean_input("Enter [codelen] digits.", "Deca-Code Lock", "")
		if(in_range(src, user))
			if(input == code)
				to_chat(user, "<span class='notice'>The crate unlocks!</span>")
				locked = FALSE
				overlays.Cut()
				overlays += "securecrateg"
			else if(input == null || length(input) != codelen)
				to_chat(user, "<span class='notice'>You leave the crate alone.</span>")
			else
				to_chat(user, "<span class='warning'>A red light flashes.</span>")
				lastattempt = input
				attempts--
				if(attempts == 0)
					boom(user)
	else
		return ..()

/obj/structure/closet/crate/secure/loot/item_interaction(mob/living/user, obj/item/W, list/modifiers)
	if(locked)
		if(istype(W, /obj/item/card/emag))
			boom(user)
			return ITEM_INTERACT_COMPLETE
		if(istype(W, /obj/item/multitool))
			to_chat(user, "<span class='notice'>DECA-CODE LOCK REPORT:</span>")
			if(attempts == 1)
				to_chat(user, "<span class='warning'>* Anti-Tamper Bomb will activate on next failed access attempt.</span>")
			else
				to_chat(user, "<span class='notice'>* Anti-Tamper Bomb will activate after [attempts] failed access attempts.</span>")
			if(lastattempt != null)
				var/bulls = 0
				var/cows = 0
				var/list/banned = list()
				for(var/i in 1 to codelen)
					var/list/a = copytext(lastattempt, i, i + 1)
					if(a in banned)
						continue
					var/g = findtext(code, a)
					if(g)
						banned += a
						if(g == i)
							++bulls
						else
							++cows

				to_chat(user, "<span class='notice'>Last code attempt had [bulls] correct digits at correct positions and [cows] correct digits at incorrect positions.</span>")
			return ITEM_INTERACT_COMPLETE

	return ..()

/obj/structure/closet/crate/secure/loot/emag_act(mob/user)
	if(locked)
		boom(user)

/obj/structure/closet/crate/secure/loot/togglelock(mob/user)
	if(locked)
		attack_hand(user)
	else
		..()

/obj/structure/closet/crate/secure/loot/deconstruct(disassembled = TRUE)
	boom()
