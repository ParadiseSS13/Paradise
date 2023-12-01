
#define USE_COOLDOWN 2 SECONDS

/obj/item/hailer
	name = "hailer"
	desc = "Used by obese officers to save their breath for running."
	icon = 'icons/obj/device.dmi'
	icon_state = "voice0"
	item_state = "flashtool"	//looks exactly like a flash (and nothing like a flashbang)
	w_class = WEIGHT_CLASS_TINY
	flags = CONDUCT
	var/next_use_time
	var/spamcheck = FALSE

/obj/item/hailer/attack_self(mob/living/carbon/user as mob)
	if(world.time < next_use_time)
		return

	if(emagged)
		playsound(get_turf(src), 'sound/voice/binsult.ogg', 100, 1, vary = 0)//hueheuheuheuheuheuhe
		user.visible_message("<span class='warning'>[user]'s [name] gurgles, \"FUCK YOUR CUNT YOU SHIT EATING CUNT TILL YOU ARE A MASS EATING SHIT CUNT. EAT PENISES IN YOUR FUCK FACE AND SHIT OUT ABORTIONS TO FUCK UP SHIT IN YOUR ASS YOU COCK FUCK SHIT MONKEY FROM THE DEPTHS OF SHIT\"</span>")
	else
		playsound(get_turf(src), 'sound/voice/halt.ogg', 100, 1, vary = 0)
		user.visible_message("<span class='warning'>[user]'s [name] rasps, \"Halt! Security!\"</span>")

	next_use_time = world.time + USE_COOLDOWN

/obj/item/hailer/emag_act(user as mob)
	if(!emagged)
		to_chat(user, "<span class='warning'>You overload \the [src]'s voice synthesizer.</span>")
		emagged = TRUE

#undef USE_COOLDOWN

/obj/item/clothing/mask/whistle
	name = "whistle"
	desc = "A metal pea-whistle. Can be blown while held, or worn in the mouth."
	icon_state = "whistle"
	item_state = "whistle"
	w_class = WEIGHT_CLASS_TINY
	flags = CONDUCT
	body_parts_covered = null
	actions_types = list(/datum/action/item_action/whistle)
	COOLDOWN_DECLARE(whistle_cooldown)
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/mask.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/mask.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/mask.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/mask.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/mask.dmi'
		)

/obj/item/clothing/mask/whistle/attack_self(mob/user)
	if(!COOLDOWN_FINISHED(src, whistle_cooldown))
		return

	playsound(src, pick('sound/items/whistle1.ogg', 'sound/items/whistle2.ogg', 'sound/items/whistle3.ogg'), 25)
	COOLDOWN_START(src, whistle_cooldown, 4 SECONDS)
