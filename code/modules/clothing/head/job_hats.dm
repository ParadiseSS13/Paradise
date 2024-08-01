
//Bartender
/obj/item/clothing/head/chefhat
	name = "chef's hat"
	desc = "The commander in chef's head wear."
	icon_state = "chef"
	item_state = "chef"
	strip_delay = 10
	put_on_delay = 10
	dog_fashion = /datum/dog_fashion/head/chef

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi'
		)

//Captain
/obj/item/clothing/head/caphat
	name = "captain's hat"
	desc = "It's good being the king."
	icon_state = "captain_hat"
	item_state = "captain_hat"
	armor = list(MELEE = 15, BULLET = 10, LASER = 15, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = 50, ACID = 50)
	strip_delay = 60
	dog_fashion = /datum/dog_fashion/head/captain

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/head.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/head.dmi',
		)

/obj/item/clothing/head/caphat/parade
	name = "captain's parade cap"
	desc = "Worn only by Captains with an abundance of class."
	icon_state = "captain_cap"

//Head of Personnel
/obj/item/clothing/head/hop
	name = "head of personnel's cap"
	icon_state = "hopcap"
	desc = "The symbol of true bureaucratic micromanagement."
	armor = list(MELEE = 15, BULLET = 10, LASER = 15, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = 50, ACID = 50)
	dog_fashion = /datum/dog_fashion/head/hop
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/head.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/head.dmi'
	)

//Quartermaster
/obj/item/clothing/head/qm
	name = "quartermaster's cap"
	desc = "A cap issued to quartermasters. To show the warehouse workers who's boss."
	icon_state = "qmcap"
	dog_fashion = /datum/dog_fashion/head/qm
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/head.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/head.dmi'
	)

//Nanotrasen Representative
/obj/item/clothing/head/ntrep
	name = "Nanotrasen Representative's hat"
	desc = "A cap issued to Nanotrasen Representatives."
	icon_state = "ntrep"

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/head.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/head.dmi',
	)


//Chaplain
/obj/item/clothing/head/hooded/chaplain_hood
	name = "chaplain's hood"
	desc = "It's hood that covers the head. It keeps you warm during the space winters."
	icon_state = "chaplain_hood"
	flags = BLOCKHAIR
	flags_cover = HEADCOVERSEYES

//Chaplain
/obj/item/clothing/head/hooded/nun_hood
	name = "nun hood"
	desc = "Maximum piety in this star system."
	icon_state = "nun_hood"
	flags = BLOCKHAIR
	flags_cover = HEADCOVERSEYES

//Chaplain
/obj/item/clothing/head/hooded/monk_hood
	name = "monk hood"
	desc = "Wooden board not included."
	icon_state = "monk_hood"
	flags = BLOCKHAIR
	flags_cover = HEADCOVERSEYES

/obj/item/clothing/head/witchhunter_hat
	name = "witchhunter hat"
	desc = "This hat saw much use back in the day."
	icon_state = "witchhunterhat"
	item_state = "witchhunterhat"
	flags_cover = HEADCOVERSEYES

/obj/item/clothing/head/det_hat
	name = "hat"
	desc = "Someone who wears this will look very smart."
	icon_state = "detective"
	allowed = list(/obj/item/food/candy/candy_corn, /obj/item/pen)
	armor = list(MELEE = 15, BULLET = 5, LASER = 15, ENERGY = 5, BOMB = 0, RAD = 0, FIRE = 20, ACID = 50)
	dog_fashion = /datum/dog_fashion/head/detective

	sprite_sheets = list(
	"Vox" = 'icons/mob/clothing/species/vox/head.dmi',
	"Grey" = 'icons/mob/clothing/species/grey/head.dmi'
	)

//Security
/obj/item/clothing/head/HoS
	name = "head of security's cap"
	desc = "The robust standard-issue cap of the Head of Security. For showing the officers who's in charge."
	icon_state = "hos_cap"
	armor = list(MELEE = 35, BULLET = 20, LASER = 20, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = 50, ACID = 75)
	strip_delay = 80
	dog_fashion = /datum/dog_fashion/head/HoS

/obj/item/clothing/head/warden
	name = "warden's police hat"
	desc = "It's a special armored hat issued to the Warden of a security force. Protects the head from impacts."
	icon_state = "policehat"
	armor = list(MELEE = 35, BULLET = 20, LASER = 20, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = 20, ACID = 75)
	strip_delay = 60
	dog_fashion = /datum/dog_fashion/head/warden
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi'
		)


/obj/item/clothing/head/officer
	name = "officer's cap"
	desc = "A red cap with an old-fashioned badge on the front for establishing that you are, in fact, the law."
	icon_state = "sechat"
	item_state = "sechat"
	armor = list(MELEE = 25, BULLET = 20, LASER = 20, ENERGY = 5, BOMB = 0, RAD = 0, FIRE = 10, ACID = 50)
	strip_delay = 60
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi'
		)

/obj/item/clothing/head/drillsgt
	name = "security campaign hat"
	desc = "A wide-brimmed hat inspired by drill instructors, or when paired with red Security clothing, the Canadian Mounties of Terra."
	icon_state = "drillsgthat"
	item_state = "drillsgthat"
	armor = list(MELEE = 25, BULLET = 20, LASER = 20, ENERGY = 5, BOMB = 0, RAD = 0, FIRE = 10, ACID = 50)
	strip_delay = 60
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi'
		)

//Medical
/obj/item/clothing/head/surgery
	name = "blue surgical cap"
	desc = "A cap surgeons wear during operations. Keeps their hair from tickling your internal organs."
	icon_state = "surgcap_blue"
	flags = BLOCKHEADHAIR
	sprite_sheets = list(
		"Drask" = 'icons/mob/clothing/species/drask/head.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi'
		)

/obj/item/clothing/head/surgery/purple
	name = "purple surgical cap"
	desc = "A cap surgeons wear during operations. Keeps their hair from tickling your internal organs. This one is deep purple."
	icon_state = "surgcap_purple"
	dog_fashion = /datum/dog_fashion/head/surgery

/obj/item/clothing/head/surgery/blue
	name = "blue surgical cap"
	desc = "A cap surgeons wear during operations. Keeps their hair from tickling your internal organs. This one is baby blue."
	icon_state = "surgcap_blue"
	dog_fashion = /datum/dog_fashion/head/surgery

/obj/item/clothing/head/surgery/green
	name = "green surgical cap"
	desc = "A cap surgeons wear during operations. Keeps their hair from tickling your internal organs. This one is dark green."
	icon_state = "surgcap_green"
	dog_fashion = /datum/dog_fashion/head/surgery

/obj/item/clothing/head/surgery/black
	name = "coroner's cap"
	desc = "A cap coroners wear during autopsies. Keeps their hair from falling into the cadavers. It is as dark as the coroner's humor."
	icon_state = "surgcap_black"
	dog_fashion = /datum/dog_fashion/head/surgery
