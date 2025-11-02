
// Chef
/obj/item/clothing/head/chefhat
	name = "chef's hat"
	desc = "The commander in chef's head wear."
	icon_state = "chef"
	inhand_icon_state = "chefhat"
	strip_delay = 10
	put_on_delay = 10
	dog_fashion = /datum/dog_fashion/head/chef
	sprite_sheets = list(
		"Drask" = 'icons/mob/clothing/species/drask/head.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/head.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/head.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi'
	)

/obj/item/clothing/head/chefhat/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/clothing_adjustment/monitor_headgear, 0, 1)

//Captain
/obj/item/clothing/head/caphat
	name = "captain's hat"
	desc = "It's good being the king."
	icon_state = "captain_hat"
	armor = list(MELEE = 15, BULLET = 10, LASER = 15, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = 50, ACID = 50)
	strip_delay = 60
	dog_fashion = /datum/dog_fashion/head/captain
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/head.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/head.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/head.dmi'
	)

/obj/item/clothing/head/caphat/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/clothing_adjustment/monitor_headgear, 0, 1)

/obj/item/clothing/head/caphat/parade
	name = "captain's parade cap"
	desc = "Worn only by Captains with an abundance of class."
	icon_state = "captain_capblue"

/obj/item/clothing/head/caphat/parade/Initialize(mapload)
	. = ..()
	RemoveElement(/datum/element/clothing_adjustment/monitor_headgear, 0, 1)

/obj/item/clothing/head/caphat/parade/white
	icon_state = "captain_capwhite"

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

/obj/item/clothing/head/hop/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/clothing_adjustment/monitor_headgear, 0, 1)

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
		"Grey" = 'icons/mob/clothing/species/grey/head.dmi'
	)


//Chaplain
/obj/item/clothing/head/hooded/chaplain_hood
	name = "chaplain's hood"
	desc = "It's hood that covers the head. It keeps you warm during the space winters."
	icon_state = "chaplain_hood"
	flags = BLOCKHAIR
	flags_cover = HEADCOVERSEYES
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/hood.dmi'
	sprite_sheets = list(
		"Drask" = 'icons/mob/clothing/species/drask/head.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/head.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/head.dmi',
		"Skrell" = 'icons/mob/clothing/species/skrell/head.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/head.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/head.dmi'
	)

//Chaplain
/obj/item/clothing/head/hooded/nun_hood
	name = "nun hood"
	desc = "Maximum piety in this star system."
	icon_state = "nun_hood"
	flags = BLOCKHAIR
	flags_cover = HEADCOVERSEYES
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/hood.dmi'
	sprite_sheets = list(
		"Drask" = 'icons/mob/clothing/species/drask/head.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/head.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/head.dmi',
		"Nian" = 'icons/mob/clothing/species/nian/head.dmi',
		"Skrell" = 'icons/mob/clothing/species/skrell/head.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/head.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/head.dmi'
	)

//Chaplain
/obj/item/clothing/head/hooded/monk_hood
	name = "monk hood"
	desc = "Wooden board not included."
	icon_state = "monk_hood"
	flags = BLOCKHAIR
	flags_cover = HEADCOVERSEYES
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/hood.dmi'

//Chaplain
/obj/item/clothing/head/turban_orange
	name = "dastar"
	desc = "One of the essential five K's for any Sikh."
	icon_state = "turban_orange"
	flags = BLOCKHAIR
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/hat.dmi'
	sprite_sheets = list(
		"Drask" = 'icons/mob/clothing/species/drask/head.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/head.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/head.dmi',
		"Nian" = 'icons/mob/clothing/species/nian/head.dmi',
		"Skrell" = 'icons/mob/clothing/species/skrell/head.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/head.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/head.dmi'
	)

//Chaplain
/obj/item/clothing/head/turban_green
	name = "turban"
	desc = "A choice color for Islamic leaders."
	icon_state = "turban_green"
	flags = BLOCKHAIR
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/hat.dmi'
	sprite_sheets = list(
		"Drask" = 'icons/mob/clothing/species/drask/head.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/head.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/head.dmi',
		"Nian" = 'icons/mob/clothing/species/nian/head.dmi',
		"Skrell" = 'icons/mob/clothing/species/skrell/head.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/head.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/head.dmi'
	)

//Chaplain
/obj/item/clothing/head/eboshi
	name = "eboshi"
	desc = "Headwear for a Shinto priest."
	icon_state = "eboshi"
	flags = BLOCKHAIR
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/hat.dmi'
	sprite_sheets = list(
		"Drask" = 'icons/mob/clothing/species/drask/head.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/head.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/head.dmi',
		"Nian" = 'icons/mob/clothing/species/nian/head.dmi',
		"Skrell" = 'icons/mob/clothing/species/skrell/head.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/head.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/head.dmi'
	)

//Chaplain
/obj/item/clothing/head/kippah
	name = "kippah"
	desc = "A small, round head covering."
	icon_state = "kippah"
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/hat.dmi'
	sprite_sheets = list(
		"Drask" = 'icons/mob/clothing/species/drask/head.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/head.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/head.dmi',
		"Skrell" = 'icons/mob/clothing/species/skrell/head.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/head.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/head.dmi'
	)

//Chaplain
/obj/item/clothing/head/shtreimel
	name = "shtreimel"
	desc = "Festive head covering for Jewish men."
	icon_state = "shtreimel"
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/hat.dmi'
	sprite_sheets = list(
		"Drask" = 'icons/mob/clothing/species/drask/head.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/head.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/head.dmi',
		"Skrell" = 'icons/mob/clothing/species/skrell/head.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/head.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/head.dmi'
	)

//Chaplain
/obj/item/clothing/head/hijab
	name = "hijab"
	desc = "A cloth worn around the head for modesty and dignity."
	icon_state = "hijab"
	flags = BLOCKHAIR
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/hood.dmi'
	sprite_sheets = list(
		"Drask" = 'icons/mob/clothing/species/drask/head.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/head.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/head.dmi',
		"Nian" = 'icons/mob/clothing/species/nian/head.dmi',
		"Skrell" = 'icons/mob/clothing/species/skrell/head.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/head.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/head.dmi'
	)

/obj/item/clothing/head/witchhunter_hat
	name = "witchhunter hat"
	desc = "This hat saw much use back in the day."
	icon_state = "witchhunterhat"
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
/obj/item/clothing/head/hos
	name = "head of security's cap"
	desc = "The robust standard-issue cap of the Head of Security. For showing the officers who's in charge."
	icon_state = "hos_cap"
	armor = list(MELEE = 35, BULLET = 20, LASER = 20, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = 50, ACID = 75)
	strip_delay = 80
	dog_fashion = /datum/dog_fashion/head/hos

/obj/item/clothing/head/hos/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/clothing_adjustment/monitor_headgear, 0, 1)

/obj/item/clothing/head/warden
	name = "warden's police hat"
	desc = "It's a special armored hat issued to the Warden of a security force. Protects the head from impacts."
	icon_state = "policehat"
	armor = list(MELEE = 35, BULLET = 20, LASER = 20, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = 20, ACID = 75)
	strip_delay = 60
	dog_fashion = /datum/dog_fashion/head/warden
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/hat.dmi'
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi'
	)

/obj/item/clothing/head/officer
	name = "officer's cap"
	desc = "A red cap with an old-fashioned badge on the front for establishing that you are, in fact, the law."
	icon_state = "sechat"
	armor = list(MELEE = 25, BULLET = 20, LASER = 20, ENERGY = 5, BOMB = 0, RAD = 0, FIRE = 10, ACID = 50)
	strip_delay = 60
	sprite_sheets = list("Vox" = 'icons/mob/clothing/species/vox/head.dmi')

/obj/item/clothing/head/drillsgt
	name = "security campaign hat"
	desc = "A wide-brimmed hat inspired by drill instructors, or when paired with red Security clothing, the Canadian Mounties of Terra."
	icon_state = "drillsgthat"
	armor = list(MELEE = 25, BULLET = 20, LASER = 20, ENERGY = 5, BOMB = 0, RAD = 0, FIRE = 10, ACID = 50)
	strip_delay = 60
	sprite_sheets = list("Vox" = 'icons/mob/clothing/species/vox/head.dmi')

//Research
/obj/item/clothing/head/rd
	name = "research director's cap"
	desc = "Fancy hat for a bureaucratic command member. Not very practical for research use, but that's Nanotrasen!"
	icon_state = "rdcap"
	dog_fashion = /datum/dog_fashion/head/rd
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/head.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/head.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/head.dmi'
	)

//Medical
/obj/item/clothing/head/cmo
	name = "chief medical officer's cap"
	desc = "Fancy hat for a bureaucratic command member. Not very practical for medical use, but that's Nanotrasen!"
	icon_state = "cmocap"
	dog_fashion = /datum/dog_fashion/head/cmo
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/head.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/head.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/head.dmi'
	)

/obj/item/clothing/head/surgery
	name = "blue surgical cap"
	desc = "A cap surgeons wear during operations. Keeps their hair from tickling your internal organs."
	icon_state = "surgcap_blue"
	flags = BLOCKHEADHAIR
	sprite_sheets = list(
		"Drask" = 'icons/mob/clothing/species/drask/head.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi'
		)
	permeability_coefficient = 0.01

/obj/item/clothing/head/surgery/purple
	name = "purple surgical cap"
	desc = "A cap surgeons wear during operations. Keeps their hair from tickling your internal organs. This one is deep purple."
	icon_state = "surgcap_purple"
	dog_fashion = /datum/dog_fashion/head/surgery

/obj/item/clothing/head/surgery/blue
	desc = "A cap surgeons wear during operations. Keeps their hair from tickling your internal organs. This one is baby blue."
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

// NT Career Trainer
/obj/item/clothing/head/drilltrainer
	name = "campaign hat"
	desc = "A wide-brimmed campaign hat with a drill sergeant feel, worn by Career Trainers to project knowledge and guide new employees with classic style."
	icon_state = "trainercampaign"
	sprite_sheets = list("Vox" = 'icons/mob/clothing/species/vox/head.dmi')
