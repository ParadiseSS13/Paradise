/obj/item/clothing/mask/thief
	name = "mastermind's mask"
	desc = "A white strap mask with some distingished pattern. Designed to hide the wearer's identity."
	icon = 'icons/hispania/obj/clothing/masks.dmi'
	icon_state = "dallas"
	item_state = "dallas"
	item_color = "dallas"
	hispania_icon = TRUE
	species_restricted = list("exclude", "Unathi", "Plasmaman", "Grey", "Vox", "Kidan")
	flags_inv = HIDEFACE
	flags_cover = MASKCOVERSMOUTH

/obj/item/clothing/mask/thief/wolf
	name = "technician's mask"
	icon_state = "wolf"
	item_state = "wolf"
	item_color = "wolf"

/obj/item/clothing/mask/thief/hoxton
	name = "fugitive's mask"
	icon_state = "hoxton"
	item_state = "hoxton"
	item_color = "hoxton"

/obj/item/clothing/mask/thief/chains
	name = "enforcer's mask"
	icon_state = "chains"
	item_state = "chains"
	item_color = "chains"
/obj/item/clothing/mask/gas/sechailer/cloaker
	name = "\improper SWAT mask"
	desc = "A close-fitting tactical mask with an especially aggressive Cloaker-o-nator 3500."
	icon_state = "cloaker"
	actions_types = list(/datum/action/item_action/halt, /datum/action/item_action/selectphrase)
	phrase_list = list(

								"forums" 		= "NOW GO TO THE FORUMS AND CRY LIKE THE LITTLE BITCH YOU ARE!",
								"beep" 		= "WULULULULULULU!",
								"difficulty-tweak"			= "WE CALL THIS A DIFFICULTY TWEAK!",
								"celilitis"			= "I'M GONNA BEAT THE CELILITIS OUT OF YOU!",
								"corners"			= "NEXT TIME CHECK YOUR CORNERS!",
								"beated"			= "I BET YOU LET YOURSELF GET BEAT UP JUST TO HEAR WHAT I HAVE TO SAY",
								"pants"			= "YOU WEAR THIS SHIT IN YOUR PANTS PROUDLY LIKE A BADGE OF HONOR",
								"resisting"			= "YOU CALL THIS RESISTING ARREST? YOU ASKED FOR IT!",
								"cry"			= "NOW CRY FOR MOM TO CHANGE YOUR DIAPERS!",
								"expected"			= "I EXPECTED BETTER",
								"hitting-yourself"			= "STOP HITTING YOURSELF! STOP HITTING YOURSELF!",
								"im_late"			= "I know I know, I'm late",
								"meeting"			= "We gotta stop meeting like this you know?",
								"missed"			= "MISSED ME, DIDN'T YA?",
								"no-return"			= "THIS IS THE POINT OF NO RETURN!",
								"not-tough"			= "NOT SO TOUGH NOW, HUH?!",
								"speak-up"			= "SPEAK UP, I CANT HEAR YOU!",
								"s-word"			= "ALRIGHT, THE SAFE WORD IS 'POLICE BRUTALITY'",
								"wish-true"			= "SOMETIMES, WISHES DO COME TRUE",
								"work-smarter"			= "WORK SMARTER, NOT HARDER!"
								)

/obj/item/clothing/mask/gas/sechailer/cloaker/ui_action_click(mob/user, actiontype)
    if(actiontype == /datum/action/item_action/halt)
        halt()
    else if(actiontype == /datum/action/item_action/selectphrase)
        var/key = phrase_list[phrase]
        var/message = phrase_list[key]

        phrase = (phrase < 20) ? (phrase + 1) : 1
        key = phrase_list[phrase]
        message = phrase_list[key]
        to_chat(user,"<span class='notice'>You set the restrictor to: [message]</span>")

/obj/item/clothing/mask/gas/sechailer/cloaker/halt()
	var/key = phrase_list[phrase]
	var/message = phrase_list[key]
	if(cooldown < world.time - 35)
		usr.visible_message("[usr]'s Cloaker-o-Nator: <font color='red' size='4'><b>[message]</b></font>")
		playsound(src.loc, "sound/voice/complionator/cloaker/[key].ogg", 100, 0, 4)
		cooldown = world.time


