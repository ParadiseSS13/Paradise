/datum/spell/charge
	name = "Charge"
	desc = "This spell can be used to recharge a variety of things in your hands, from magical artifacts to electrical components. A creative wizard can even use it to grant magical power to a fellow magic user."
	base_cooldown = 1 MINUTES
	clothes_req = FALSE
	invocation = "DIRI CEL"
	invocation_type = "whisper"
	cooldown_min = 400 //50 deciseconds reduction per rank
	action_icon_state = "charge"

/datum/spell/charge/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/charge/cast(list/targets, mob/user = usr)
	for(var/mob/living/L in targets)
		var/list/hand_items = list(L.get_active_hand(),L.get_inactive_hand())
		var/charged_item = null
		var/burnt_out = FALSE

		if(L.pulling && (isliving(L.pulling)))
			var/mob/living/M =	L.pulling
			if(length(M.mob_spell_list) != 0 || (M.mind && length(M.mind.spell_list) != 0))
				for(var/datum/spell/S in M.mob_spell_list)
					S.cooldown_handler.revert_cast()
				if(M.mind)
					for(var/datum/spell/S in M.mind.spell_list)
						S.cooldown_handler.revert_cast()
				to_chat(M, "<span class='notice'>You feel raw magical energy flowing through you, it feels good!</span>")
			else
				to_chat(M, "<span class='notice'>You feel very strange for a moment, but then it passes.</span>")
				burnt_out = TRUE
			charged_item = M
			break
		for(var/obj/item in hand_items)
			if(istype(item, /obj/item/spellbook))
				if(istype(item, /obj/item/spellbook/oneuse))
					var/obj/item/spellbook/oneuse/I = item
					if(prob(80))
						L.visible_message("<span class='warning'>[I] catches fire!</span>")
						qdel(I)
					else
						I.used = FALSE
						charged_item = I
						break
				else
					to_chat(L, "<span class='caution'>Glowing red letters appear on the front cover...</span>")
					to_chat(L, "<span class='warning'>[pick("NICE TRY BUT NO!","CLEVER BUT NOT CLEVER ENOUGH!", "SUCH FLAGRANT CHEESING IS WHY WE ACCEPTED YOUR APPLICATION!", "CUTE!", "YOU DIDN'T THINK IT'D BE THAT EASY, DID YOU?")]</span>")
					burnt_out = TRUE
			else if(istype(item, /obj/item/book/granter))
				var/obj/item/book/granter/I = item
				if(prob(80))
					L.visible_message("<span class='warning'>[I] catches fire!</span>")
					qdel(I)
				else
					I.uses += 1
					charged_item = I
					break

			else if(istype(item, /obj/item/gun/magic))
				var/obj/item/gun/magic/I = item
				if(prob(80) && !I.can_charge)
					I.max_charges--
				if(I.max_charges <= 0)
					I.max_charges = 0
					burnt_out = TRUE
				I.charges = I.max_charges
				if(istype(item,/obj/item/gun/magic/wand) && I.max_charges != 0)
					var/obj/item/gun/magic/W = item
					W.icon_state = initial(W.icon_state)
				charged_item = I
				break
			else if(istype(item, /obj/item/stock_parts/cell/))
				var/obj/item/stock_parts/cell/C = item
				C.charge = C.maxcharge
				charged_item = C
				break
			else if(item.contents)
				var/obj/I = null
				for(I in item.contents)
					if(istype(I, /obj/item/stock_parts/cell/))
						var/obj/item/stock_parts/cell/C = I
						C.charge = C.maxcharge
						item.update_icon()
						charged_item = item
						break
		if(!charged_item)
			to_chat(L, "<span class='notice'>You feel magical power surging to your hands, but the feeling rapidly fades...</span>")
		else if(burnt_out)
			to_chat(L, "<span class='caution'>[charged_item] doesn't seem to be reacting to the spell...</span>")
		else
			to_chat(L, "<span class='notice'>[charged_item] suddenly feels very warm!</span>")
