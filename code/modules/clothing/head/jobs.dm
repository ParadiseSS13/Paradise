
//Bartender
/obj/item/clothing/head/chefhat
	name = "chef's hat"
	desc = "It's a hat used by chefs to keep hair out of your food. Judging by the food in the mess, they don't work."
	icon_state = "chef"
	item_state = "chef"
	desc = "The commander in chef's head wear."
	siemens_coefficient = 0.9
	loose = 35 // why-a do people always push-a me over

//Captain
/obj/item/clothing/head/caphat
	name = "captain's hat"
	icon_state = "captain"
	desc = "It's good being the king."
	item_state = "caphat"
	siemens_coefficient = 0.9
	armor = list(melee = 50, bullet = 15, laser = 50, energy = 10, bomb = 25, bio = 0, rad = 0)
	loose = 43 // not the answer

//Captain: no longer space-worthy
/obj/item/clothing/head/caphat/parade
	name = "captain's parade cap"
	desc = "Worn only by Captains with an abundance of class."
	icon_state = "capcap"

//Head of Personnel
/obj/item/clothing/head/hopcap
	name = "head of personnel's cap"
	icon_state = "hopcap"
	desc = "The symbol of true bureaucratic micromanagement."
	siemens_coefficient = 0.9
	armor = list(melee = 50, bullet = 15, laser = 50, energy = 10, bomb = 25, bio = 0, rad = 0)
	loose = 43 // not the answer

//Nanotrasen Representative
/obj/item/clothing/head/ntrep
	name = "Nanotrasen Representative hat"
	desc = "A cap issued to the Nanotrasen Representative"
	icon_state = "ntrep"


//Chaplain
/obj/item/clothing/head/chaplain_hood
	name = "chaplain's hood"
	desc = "It's hood that covers the head. It keeps you warm during the space winters."
	icon_state = "chaplain_hood"
	flags = HEADCOVERSEYES | BLOCKHAIR
	siemens_coefficient = 0.9
	loose = 2

//Chaplain
/obj/item/clothing/head/nun_hood
	name = "nun hood"
	desc = "Maximum piety in this star system."
	icon_state = "nun_hood"
	flags = HEADCOVERSEYES | BLOCKHAIR
	siemens_coefficient = 0.9
	loose = 2

/obj/item/clothing/head/det_hat
	name = "hat"
	desc = "Someone who wears this will look very smart."
	icon_state = "detective"
	allowed = list(/obj/item/weapon/reagent_containers/food/snacks/candy_corn, /obj/item/weapon/pen)
	armor = list(melee = 50, bullet = 5, laser = 25,energy = 10, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 0.9

//Mime
/obj/item/clothing/head/beret
	name = "beret"
	desc = "A beret, an artists favorite headwear."
	icon_state = "beret"
	siemens_coefficient = 0.9
	loose = 16

//Security
/obj/item/clothing/head/HoS
	name = "head of security cap"
	desc = "The robust standard-issue cap of the Head of Security. For showing the officers who's in charge."
	icon_state = "hoscap"
	armor = list(melee = 80, bullet = 60, laser = 50, energy = 10, bomb = 25, bio = 10, rad = 0)

/obj/item/clothing/head/HoS/beret
	name = "head of security beret"
	desc = "A robust beret for the Head of Security, for looking stylish while not sacrificing protection."
	icon_state = "hosberetblack"

/obj/item/clothing/head/warden
	name = "warden's police hat"
	desc = "It's a special armored hat issued to the Warden of a security force. Protects the head from impacts."
	icon_state = "policehelm"
	armor = list(melee = 60, bullet = 5, laser = 25, energy = 10, bomb = 25, bio = 0, rad = 0)

/obj/item/clothing/head/customs
	name = "customs officer's hat"
	desc = "A serious looking hat for a serious job."
	icon_state = "customshelm"
	item_state = "customshelm"
	armor = list(melee = 30, bullet = 25, laser = 25, energy = 10, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/head/beret/sec
	name = "security beret"
	desc = "A beret with the security insignia emblazoned on it. For officers that are more inclined towards style than safety."
	icon_state = "beret_badge"
	armor = list(melee = 30, bullet = 25, laser = 25, energy = 10, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/head/beret/sec/warden
	name = "warden's beret"
	desc = "A special beret with the Warden's insignia emblazoned on it. For wardens with class."
	icon_state = "wardenberet"
	armor = list(melee = 60, bullet = 5, laser = 25, energy = 10, bomb = 25, bio = 0, rad = 0)

/obj/item/clothing/head/beret/eng
	name = "engineering beret"
	desc = "A beret with the engineering insignia emblazoned on it. For engineers that are more inclined towards style than safety."
	icon_state = "e_beret_badge"

/obj/item/clothing/head/beret/atmos
	name = "atmospherics beret"
	desc = "A beret for those who have shown immaculate proficienty in piping. Or plumbing."
	icon_state = "a_beret_badge"

//Medical
/obj/item/clothing/head/surgery
	name = "surgical cap"
	desc = "A cap surgeons wear during operations. Keeps their hair from tickling your internal organs."
	icon_state = "surgcap_blue"
	flags = BLOCKHEADHAIR
	loose = 13

/obj/item/clothing/head/surgery/purple
	desc = "A cap surgeons wear during operations. Keeps their hair from tickling your internal organs. This one is deep purple."
	icon_state = "surgcap_purple"

/obj/item/clothing/head/surgery/blue
	desc = "A cap surgeons wear during operations. Keeps their hair from tickling your internal organs. This one is baby blue."
	icon_state = "surgcap_blue"

/obj/item/clothing/head/surgery/green
	desc = "A cap surgeons wear during operations. Keeps their hair from tickling your internal organs. This one is dark green."
	icon_state = "surgcap_green"

/obj/item/clothing/head/surgery/black
	desc = "A cap coroners wear during autopsies. Keeps their hair from falling into the cadavers.  It is as dark than the coroner's humor."
	icon_state = "surgcap_black"