//Here you can see the karma outfits, which you can buy from karma shop
//DIO's outfit
/obj/item/clothing/head/atmta/dio
	name = "DIO's heart headband"
	desc = "Why is there a heart on this headband? The World may never know."
	icon_state = "DIO"
	item_state = "DIO"

/obj/item/clothing/under/atmta/dio
	name = "DIO's backless vest"
	desc = "Walk into the room wearing this, everyone stops."
	icon_state = "DIO"
	item_state = "DIO"
	item_color = "DIO"

/obj/item/clothing/suit/atmta/dio
	name = "DIO's yellow jacket"
	desc = "So fashionable it's menacing."
	icon_state = "DIO"
	item_state = "DIO"

/obj/item/clothing/gloves/atmta/dio
	name = "DIO's metal wristbands"
	desc = "These wristbands look fabulous, it's useless useless useless to deny."
	icon_state = "DIO"
	item_state = "DIO"
	item_color="DIO"

/obj/item/clothing/shoes/atmta/dio
	name = "DIO's ring shoes"
	desc = "These help you stand."
	icon_state = "DIO"
	item_color = "DIO"
	item_state = "DIO"

//Phantom blood Dio
/obj/item/clothing/suit/atmta/phantomblood
	name = "Dio Brando's ancient outfit"
	desc = "From the good ol'times when mask can get you STONED."
	icon_state = "vclothes"
	item_state = "vclothes"

//Adeptus Mechanicus robes
/obj/item/clothing/suit/atmta/mechanicus
	name = "Adeptus Mechanicus robes"
	desc = "Sweet ol'grim dark future."
	icon_state = "adeptus"
	item_state = "adeptus"

//MGS suit
/obj/item/clothing/suit/atmta/oldsnake
  name = "Old Man's sneaking suit"
  desc = "Cigs and octocamos not included."
  icon_state = "sneakmans"
  item_state = "sneakmans"

//Fullmetal Alch suit
/obj/item/clothing/suit/atmta/fullmetal
  name = "Alchemist's suit"
  desc = "Full-metal jacket (not really)"
  icon_state = "alchrobe"
  item_state = "alchrobe"

//HEV
/obj/item/clothing/suit/atmta/space/hev
  name = "HEV suit"
  desc = "It will save you from the products of half-life"
  icon_state = "hev"
  item_state = "hev"


//TTGL
//Simon's coat
/obj/item/clothing/suit/atmta/simoncoat
  name = "NT's Honorable long coat"
  desc = "For those men who pierced the sky out."
  icon_state = "simon_coat"
  item_state = "simon_coat"
  ignore_suitadjust = 0
  suit_adjusted = 0


//Kamina's cape
/obj/item/weapon/bedsheet/kaminacape
  name = "Sky-piercer cape"
  desc = "The symbol of man's will."
  icon = 'hyntatmta/icons/obj/items.dmi'
  icon_override = 'hyntatmta/icons/mob/back.dmi'
  icon_state = "kaminacape"
  item_state = "kaminacape"
  actions_types = list(/datum/action/item_action/sprial_power)
  var/cooldown = 0

/obj/item/weapon/bedsheet/kaminacape/ui_action_click(mob/user, actiontype)
	if(actiontype == /datum/action/item_action/sprial_power)
		rowrow(user)

/obj/item/weapon/bedsheet/kaminacape/proc/rowrow(mob/user)
	if(cooldown > world.time)
		var/remaining = cooldown - world.time
		remaining = remaining*0.1
		to_chat(user, "<span class='warning'>Ability on cooldown - [remaining] seconds remaining.</span>")
		return
	else
		user.overlays += image("icon"='hyntatmta/icons/mob/aura.dmi', "icon_state"="spiral")
		user.visible_message("<span class='green'><b>[user]</b> glows with very STRONG and MANLY aura!</span>", "You awaken your inner power!")
		spawn(200)
		user.overlays -= image("icon"='hyntatmta/icons/mob/aura.dmi', "icon_state"="spiral")
		cooldown = world.time + 3000

