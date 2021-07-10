/obj/item/clothing/mask/gas/sechailer/cloaker
	name = "\improper cloaker SWAT mask"
	desc = "A close-fitting tactical mask with an especially aggressive Cloaker-o-nator 3500."
	icon = 'icons/hispania/obj/clothing/masks.dmi'
	icon_state = "cloaker"
	item_state = "cloaker"
	hispania_icon = TRUE
	sprite_sheets = list(
	"Vox" = 'icons/hispania/mob/species/vox/mask.dmi',
	"Grey" = 'icons/hispania/mob/species/grey/mask.dmi',
	"Unathi" = 'icons/hispania/mob/species/unathi/mask.dmi',
	"Drask" = 'icons/hispania/mob/species/drask/mask.dmi',
	"Tajaran" = 'icons/hispania/mob/species/tajaran/mask.dmi')
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
		playsound(src.loc, "sound/hispania/voice/hailer/cloaker/[key].ogg", 100, 0, 4)
		cooldown = world.time
