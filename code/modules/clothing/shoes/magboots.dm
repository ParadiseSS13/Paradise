/obj/item/clothing/shoes/magboots
	desc = "Magnetic boots, often used during extravehicular activity to ensure the user remains safely attached to the vehicle."
	name = "magboots"
	icon_state = "magboots0"
	origin_tech = "materials=3;magnets=4;engineering=4"
	var/magboot_state = "magboots"
	var/magpulse = 0
	var/slowdown_active = 2
	var/slowdown_passive = SHOES_SLOWDOWN
	var/magpulse_name = "mag-pulse traction system"
	actions_types = list(/datum/action/item_action/toggle)
	strip_delay = 70
	put_on_delay = 70
	resistance_flags = FIRE_PROOF

/obj/item/clothing/shoes/magboots/attack_self(mob/user)
	if(magpulse)
		flags &= ~NOSLIP
		slowdown = slowdown_passive
	else
		flags |= NOSLIP
		slowdown = slowdown_active
	magpulse = !magpulse
	icon_state = "[magboot_state][magpulse]"
	to_chat(user, "You [magpulse ? "enable" : "disable"] the [magpulse_name].")
	user.update_inv_shoes()	//so our mob-overlays update
	user.update_gravity(user.mob_has_gravity())
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/clothing/shoes/magboots/negates_gravity()
	return flags & NOSLIP

/obj/item/clothing/shoes/magboots/examine(mob/user)
	. = ..()
	. += "Its [magpulse_name] appears to be [magpulse ? "enabled" : "disabled"]."


/obj/item/clothing/shoes/magboots/advance
	desc = "Advanced magnetic boots that have a lighter magnetic pull, placing less burden on the wearer."
	name = "advanced magboots"
	icon_state = "advmag0"
	magboot_state = "advmag"
	slowdown_active = SHOES_SLOWDOWN
	origin_tech = null
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/clothing/shoes/magboots/syndie
	desc = "Reverse-engineered magnetic boots that have a heavy magnetic pull. Property of Gorlex Marauders."
	name = "blood-red magboots"
	icon_state = "syndiemag0"
	magboot_state = "syndiemag"
	origin_tech = "magnets=4;syndicate=2"

obj/item/clothing/shoes/magboots/syndie/advance //For the Syndicate Strike Team
	desc = "Reverse-engineered magboots that appear to be based on an advanced model, as they have a lighter magnetic pull. Property of Gorlex Marauders."
	name = "advanced blood-red magboots"
	slowdown_active = SHOES_SLOWDOWN

/obj/item/clothing/shoes/magboots/clown
	desc = "The prankster's standard-issue clowning shoes. Damn they're huge! There's a red light on the side."
	name = "clown shoes"
	icon_state = "clownmag0"
	magboot_state = "clownmag"
	item_state = "clown_shoes"
	slowdown = SHOES_SLOWDOWN+1
	slowdown_active = SHOES_SLOWDOWN+1
	slowdown_passive = SHOES_SLOWDOWN+1
	magpulse_name = "honk-powered traction system"
	item_color = "clown"
	silence_steps = 1
	shoe_sound = "clownstep"
	origin_tech = "magnets=4;syndicate=2"
	var/enabled_waddle = TRUE
	var/datum/component/waddle

/obj/item/clothing/shoes/magboots/clown/equipped(mob/user, slot)
	. = ..()
	if(slot == slot_shoes && enabled_waddle)
		waddle = user.AddComponent(/datum/component/waddling)

/obj/item/clothing/shoes/magboots/clown/dropped(mob/user)
	. = ..()
	QDEL_NULL(waddle)

/obj/item/clothing/shoes/magboots/clown/CtrlClick(mob/living/user)
	if(!isliving(user))
		return
	if(user.get_active_hand() != src)
		to_chat(user, "You must hold [src] in your hand to do this.")
		return
	if(!enabled_waddle)
		to_chat(user, "<span class='notice'>You switch off the waddle dampeners!</span>")
		enabled_waddle = TRUE
	else
		to_chat(user, "<span class='notice'>You switch on the waddle dampeners!</span>")
		enabled_waddle = FALSE

/obj/item/clothing/shoes/magboots/wizard //bundled with the wiz hardsuit
	name = "boots of gripping"
	desc = "These magical boots, once activated, will stay gripped to any surface without slowing you down."
	icon_state = "wizmag0"
	magboot_state = "wizmag"
	slowdown_active = SHOES_SLOWDOWN //wiz hardsuit already slows you down, no need to double it
	magpulse_name = "gripping ability"
	magical = TRUE

/obj/item/clothing/shoes/magboots/wizard/attack_self(mob/user)
	if(user)
		if(user.mind in SSticker.mode.wizards)
			if(magpulse) //faint blue light when shoes are turned on gives a reason to turn them off when not needed in maint
				set_light(0)
			else
				set_light(2, 1, LIGHT_COLOR_LIGHTBLUE)
			..()
		else
			to_chat(user, "<span class='notice'>You poke the gem on [src]. Nothing happens.</span>")
