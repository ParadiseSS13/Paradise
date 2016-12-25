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

//Sergeant Dornan's helmet
/obj/item/clothing/head/atmta/dornan
	name = "Sergeant's helmet"
	desc = "This helmet's appearance will make you cry."
	icon_state = "dornan"
	item_state = "dornan"
	actions_types = list(/datum/action/item_action/selectphrase, /datum/action/item_action/idiot)
	flags = HEADCOVERSEYES | HEADBANGPROTECT | BLOCKHAIR | HEADCOVERSMOUTH
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	armor = list(melee = 15, bullet = 40, laser = 10, energy = 10, bomb = 40, bio = 0, rad = 0)
	var/phrase = 1 //AY ay.

/obj/item/clothing/head/atmta/dornan/ui_action_click(mob/user, actiontype)
	if(actiontype == /datum/action/item_action/idiot)
		idiot()
	else if(actiontype == /datum/action/item_action/selectphrase)
		switch(phrase)
			if(1)
				to_chat(user, "<span class='notice'>You set the phrase to: Не сметь обсуждать приказы начальства!</span>")
				phrase = 2
			if(2)
				to_chat(user, "<span class='notice'>You set the phrase to: Скажу прыгать - будешь прыгать!</span>")
				phrase = 3
			if(3)
				to_chat(user, "<span class='notice'>You set the phrase to: Ясно излагаю?</span>")
				phrase = 4
			if(4)
				to_chat(user, "<span class='notice'>You set the phrase to: Думаете, я этому поверю?</span>")
				phrase = 5
			if(5)
				to_chat(user, "<span class='notice'>You set the phrase to: Вы допустили потерю!</span>")
				phrase = 6
			if(6)
				to_chat(user, "<span class='notice'>You set the phrase to: Стоимость будет вычтена!</span>")
				phrase = 7
			if(7)
				to_chat(user, "<span class='notice'>You set the phrase to: Служить 510 лет!</span>")
				phrase = 8
			if(8)
				to_chat(user, "<span class='notice'>You set the phrase to: Идиот!</span>")
				phrase = 1

/obj/item/clothing/head/atmta/dornan/verb/idiot()
	set category = "Object"
	set name = "I-DI-OT!!!!"
	set src in usr
	if(!istype(usr, /mob/living)) return
	if(usr.stat) return

	var/phrase_text = null
	var/phrase_sound = null

	if(cooldown < world.time - 50)
		switch(phrase)	//VI DOPUSTILI CKOPIROVANIE KODA!
			if(1)				// VI BUDETE ADMINIT DO TEH POR POEKA VAM NE ISPOLNITSA 510 LET!
				phrase_text = sanitize("ИДИОТ!!!")
				phrase_sound = "idiot1"
			if(2)
				phrase_text = sanitize("Не сметь обсуждать приказы начальства!!")
				phrase_sound = "idiot2"
			if(3)
				phrase_text = sanitize("Скажу прыгать - будешь прыгать! Скажу драться - будешь драться! Скажу умереть за родину - умрешь без разговоров!!")
				phrase_sound = "idiot3"
			if(4)
				phrase_text = sanitize("Я ясно излагаю?!")
				phrase_sound = "idiot4"
			if(5)
				phrase_text = sanitize("Вот как? И вы думаете, я этому поверю, салага?!")
				phrase_sound = "idiot5"
			if(6)
				phrase_text = sanitize("Вы допустили потерю дорогостоящего обмундирования!")
				phrase_sound = "idiot6"
			if(7)
				phrase_text = sanitize("Его стоимость будет вычтена из вашего жалования!!")
				phrase_sound = "idiot7"
			if(8)
				phrase_text = sanitize("И вы будете служить пока вам не исполнится ПЯТЬСОТ ДЕСЯТЬ ЛЕТ!!!")
				phrase_sound = "idiot8"
		usr.visible_message("[usr] screams ferociously: <font color='red' size='4'><b>[phrase_text]</b></font>")
		playsound(src.loc, "sound/voice/dornan/[phrase_sound].ogg", 80, 0, 4)
		cooldown = world.time

// SLASTENA
/obj/item/clothing/under/atmta/slastena
	name = "Slastena's dress"
	desc = "Pink and cyan. Cute and formal."
	icon_state = "slastena"
	item_state = "slastena"
	item_color = "slastena"

/obj/item/clothing/shoes/atmta/slastena
	name = "Slastena's shoes"
	desc = "Well... That's pink ballet shoes."
	icon_state = "slastena"
	item_state = "slastena"

/obj/item/clothing/head/atmta/slastena
	name = "Slastena's hair"
	desc = "Made of genuine cotton candy"
	icon_state = "slastena"
	item_state = "slastena"
	flags = BLOCKHAIR