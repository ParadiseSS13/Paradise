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
		to_chat(user, span_notice("The crate is locked with a Deca-code lock."))
		var/input = clean_input("Enter [codelen] digits.", "Deca-Code Lock", "")
		if(in_range(src, user))
			if(input == code)
				to_chat(user, span_notice("The crate unlocks!"))
				locked = FALSE
				overlays.Cut()
				overlays += "securecrateg"
			else if(input == null || length(input) != codelen)
				to_chat(user, span_notice("You leave the crate alone."))
			else
				to_chat(user, span_warning("A red light flashes."))
				lastattempt = input
				attempts--
				if(attempts == 0)
					boom(user)
	else
		return ..()

/obj/structure/closet/crate/secure/loot/attackby__legacy__attackchain(obj/item/W, mob/user)
	if(locked)
		if(istype(W, /obj/item/card/emag))
			boom(user)
			return 1
		if(istype(W, /obj/item/multitool))
			to_chat(user, span_notice("DECA-CODE LOCK REPORT:"))
			if(attempts == 1)
				to_chat(user, span_warning("* Anti-Tamper Bomb will activate on next failed access attempt."))
			else
				to_chat(user, span_notice("* Anti-Tamper Bomb will activate after [attempts] failed access attempts."))
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

				to_chat(user, span_notice("Last code attempt had [bulls] correct digits at correct positions and [cows] correct digits at incorrect positions."))
			return 1
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
