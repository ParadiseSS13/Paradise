

/obj/item/clothing/head/centhat
	name = "\improper CentComm. hat"
	icon_state = "centcom"
	desc = "It's good to be emperor."
	item_state = "centhat"
	armor = list(melee = 50, bullet = 15, laser = 50, energy = 10, bomb = 25, bio = 0, rad = 0)
	siemens_coefficient = 0.9

/obj/item/clothing/head/hairflower
	name = "hair flower pin"
	icon_state = "hairflower"
	desc = "Smells nice."
	item_state = "hairflower"

/obj/item/clothing/head/hairflower/purple
	icon_state = "hairflowerp"
	item_state = "hairflowerp"
	item_state = "that"
	loose = 0 // centcom

/obj/item/clothing/head/powdered_wig
	name = "powdered wig"
	desc = "A powdered wig."
	icon_state = "pwig"
	item_state = "pwig"
	loose = 90 // fucking whigs

/obj/item/clothing/head/that
	name = "top-hat"
	desc = "It's an amish looking hat."
	icon_state = "tophat"
	item_state = "that"
	siemens_coefficient = 0.9
	loose = 70

/obj/item/clothing/head/redcoat
	name = "redcoat's hat"
	icon_state = "redcoat"
	desc = "<i>'I guess it's a redhead.'</i>"
	loose = 45

/obj/item/clothing/head/mailman
	name = "mailman's hat"
	icon_state = "mailman"
	desc = "<i>'Right-on-time'</i> mail service head wear."
	loose = 65

/obj/item/clothing/head/plaguedoctorhat
	name = "plague doctor's hat"
	desc = "These were once used by Plague doctors. They're pretty much useless."
	icon_state = "plaguedoctor"
	permeability_coefficient = 0.01
	siemens_coefficient = 0.9
	loose = 30

/obj/item/clothing/head/hasturhood
	name = "hastur's hood"
	desc = "It's unspeakably stylish"
	icon_state = "hasturhood"
	flags = HEADCOVERSEYES | BLOCKHAIR
	loose = 1

/obj/item/clothing/head/nursehat
	name = "nurse's hat"
	desc = "It allows quick identification of trained medical personnel."
	icon_state = "nursehat"
	siemens_coefficient = 0.9
	loose = 80 // allowing for awkward come-ons when he/she drops his/her hat and you get it for him/her.

/obj/item/clothing/head/syndicatefake
	name = "black and red space-helmet replica"
	icon_state = "syndicate-helm-black-red"
	item_state = "syndicate-helm-black-red"
	desc = "A plastic replica of a syndicate agent's space helmet, you'll look just like a real murderous syndicate agent in this! This is a toy, it is not made for use in space!"
	flags = BLOCKHAIR
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	siemens_coefficient = 2.0
	loose = 15 // not a very good replica

/obj/item/clothing/head/cueball
	name = "cueball helmet"
	desc = "A large, featureless white orb mean to be worn on your head. How do you even see out of this thing?"
	icon_state = "cueball"
	flags = HEADCOVERSEYES | HEADCOVERSMOUTH | BLOCKHAIR
	item_state="cueball"
	flags_inv = 0
	loose = 0

/obj/item/clothing/head/that
	name = "sturdy top-hat"
	desc = "It's an amish looking armored top hat."
	icon_state = "tophat"
	item_state = "that"
	flags_inv = 0
	loose = 70


/obj/item/clothing/head/greenbandana
	name = "green bandana"
	desc = "It's a green bandana with some fine nanotech lining."
	icon_state = "greenbandana"
	item_state = "greenbandana"
	flags_inv = 0
	loose = 1

/obj/item/clothing/head/cardborg
	name = "cardborg helmet"
	desc = "A helmet made out of a box."
	icon_state = "cardborg_h"
	item_state = "cardborg_h"
	flags = HEADCOVERSEYES | HEADCOVERSMOUTH
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	loose = 20

/obj/item/clothing/head/justice
	name = "justice hat"
	desc = "fight for what's righteous!"
	icon_state = "justicered"
	item_state = "justicered"
	flags = HEADCOVERSEYES | HEADCOVERSMOUTH | BLOCKHAIR
	loose = 0

/obj/item/clothing/head/justice/blue
	icon_state = "justiceblue"
	item_state = "justiceblue"

/obj/item/clothing/head/justice/yellow
	icon_state = "justiceyellow"
	item_state = "justiceyellow"

/obj/item/clothing/head/justice/green
	icon_state = "justicegreen"
	item_state = "justicegreen"

/obj/item/clothing/head/justice/pink
	icon_state = "justicepink"
	item_state = "justicepink"

/obj/item/clothing/head/rabbitears
	name = "rabbit ears"
	desc = "Wearing these makes you looks useless, and only good for your sex appeal."
	icon_state = "bunny"
	loose = 4

/obj/item/clothing/head/flatcap
	name = "flat cap"
	desc = "A working man's cap."
	icon_state = "flat_cap"
	item_state = "detective"
	siemens_coefficient = 0.9
	loose = 1

/obj/item/clothing/head/pirate
	name = "pirate hat"
	desc = "Yarr."
	icon_state = "pirate"
	item_state = "pirate"
	loose = 18

/obj/item/clothing/head/hgpiratecap
	name = "pirate hat"
	desc = "Yarr."
	icon_state = "hgpiratecap"
	item_state = "hgpiratecap"
	loose = 36

/obj/item/clothing/head/bandana
	name = "pirate bandana"
	desc = "Yarr."
	icon_state = "bandana"
	item_state = "bandana"
	loose = 0

//stylish bs12 hats

/obj/item/clothing/head/bowlerhat
	name = "bowler hat"
	icon_state = "bowler_hat"
	item_state = "bowler_hat"
	desc = "For that industrial age look."

/obj/item/clothing/head/beaverhat
	name = "beaver hat"
	icon_state = "beaver_hat"
	item_state = "beaver_hat"
	desc = "Like a top hat, but made of beavers."

/obj/item/clothing/head/boaterhat
	name = "boater hat"
	icon_state = "boater_hat"
	item_state = "boater_hat"
	desc = "Goes well with celery."

/obj/item/clothing/head/fedora
	name = "\improper fedora"
	icon_state = "fedora"
	item_state = "fedora"
	desc = "A great hat ruined by being within fifty yards of you."

//TIPS FEDORA
/obj/item/clothing/head/fedora/verb/tip_fedora()
	set name = "Tip Fedora"
	set category = "Object"
	set desc = "Show that CIS SCUM who's boss."

	usr.visible_message("[usr] tips their fedora.","You tip your fedora")

/obj/item/clothing/head/fez
	name = "\improper fez"
	icon_state = "fez"
	item_state = "fez"
	desc = "Put it on your monkey, make lots of cash money."

//end bs12 hats

/obj/item/clothing/head/witchwig
	name = "witch costume wig"
	desc = "Eeeee~heheheheheheh!"
	icon_state = "witch"
	item_state = "witch"
	flags = BLOCKHAIR
	siemens_coefficient = 2.0
	loose = 1

/obj/item/clothing/head/chicken
	name = "chicken suit head"
	desc = "Bkaw!"
	icon_state = "chickenhead"
	item_state = "chickensuit"
	flags = BLOCKHAIR
	siemens_coefficient = 2.0

/obj/item/clothing/head/corgi
	name = "corgi suit head"
	desc = "Woof!"
	icon_state = "corgihead"
	item_state = "chickensuit"
	flags = BLOCKHAIR | NODROP
	siemens_coefficient = 2.0

/obj/item/clothing/head/corgi/en
	name = "E-N suit head"
	icon_state = "enhead"

/obj/item/clothing/head/bearpelt
	name = "bear pelt hat"
	desc = "Fuzzy."
	icon_state = "bearpelt"
	item_state = "bearpelt"
	flags = BLOCKHAIR
	siemens_coefficient = 2.0
	loose = 0 // grrrr

/obj/item/clothing/head/xenos
	name = "xenos helmet"
	icon_state = "xenos"
	item_state = "xenos_helm"
	desc = "A helmet made out of chitinous alien hide."
	flags = BLOCKHAIR
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	siemens_coefficient = 2.0

/obj/item/clothing/head/crown
	name = "bananium crown"
	icon_state = "crown"
	item_state = "crown"
	desc = "A gliterring bananium crown with spessjewels in it. Swaggy."


/obj/item/clothing/head/fedora
	name = "fedora"
	desc = "Someone wearing this definitely makes them cool"
	icon_state = "fedora"

/obj/item/clothing/head/fedora/whitefedora
	name = "white fedora"
	icon_state = "wfedora"

/obj/item/clothing/head/fedora/brownfedora
	name = "brown fedora"
	icon_state = "bfedora"
	loose = 35

/obj/item/clothing/head/stalhelm
	name = "Clown Stalhelm"
	desc = "The typical clown soldier's helmet."
	icon_state = "stalhelm"
	item_state = "stalhelm"
	flags = BLOCKHAIR
	flags_inv = HIDEEARS

/obj/item/clothing/head/panzer
	name = "Clown HONKMech Cap"
	desc = "The softcap worn by HONK Mech pilots."
	icon_state = "panzercap"
	item_state = "panzercap"
	flags = BLOCKHAIR

/obj/item/clothing/head/naziofficer
	name = "Clown Officer Cap"
	desc = "The peaked clown officer's cap, disturbingly similar to the warden's."
	icon_state = "officercap"
	item_state = "officercap"
	flags = BLOCKHAIR
	flags_inv = HIDEEARS

/obj/item/clothing/head/beret/purple
	name = "Pierson Family Beret"
	desc = " A purple beret, with a small golden crescent moon sewn onto it."
	icon_state = "purpleberet"
	item_state = "purpleberet"

/obj/item/clothing/head/beret/centcom/officer
	name = "officers beret"
	desc = "A black beret adorned with the shield—a silver kite shield with an engraved sword—of the Nanotrasen security forces, announcing to the world that the wearer is a defender of Nanotrasen."
	icon_state = "centcomofficerberet"

/obj/item/clothing/head/beret/centcom/captain
	name = "captains beret"
	desc = "A white beret adorned with the shield—a cobalt kite shield with an engraved sword—of the Nanotrasen security forces, worn only by those captaining a vessel of the Nanotrasen Navy."
	icon_state = "centcomcaptain"

/obj/item/clothing/head/sombrero
	name = "sombrero"
	icon_state = "sombrero"
	item_state = "sombrero"
	desc = "You can practically taste the fiesta."

/obj/item/clothing/head/sombrero/green
	name = "green sombrero"
	icon_state = "greensombrero"
	item_state = "greensombrero"
	desc = "As elegant as a dancing cactus."

/obj/item/clothing/head/sombrero/shamebrero
	name = "shamebrero"
	icon_state = "shamebrero"
	item_state = "shamebrero"
	desc = "Once it's on, it never comes off."
	flags = NODROP

/obj/item/clothing/head/griffin
	name = "griffon head"
	desc = "Why not 'eagle head'? Who knows."
	icon_state = "griffinhat"
	item_state = "griffinhat"
	flags = BLOCKHAIR|NODROP
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	var/cooldown = 0
	action_button_name = "Caw"

/obj/item/clothing/head/griffin/attack_self()
	caw()

/obj/item/clothing/head/griffin/verb/caw()

	set category = "Object"
	set name = "Caw"
	set src in usr
	if(!istype(usr, /mob/living)) return
	if(usr.stat) return

	if(cooldown < world.time - 20) // A cooldown, to stop people being jerks
		playsound(src.loc, "sound/misc/caw.ogg", 50, 1)
		cooldown = world.time


/obj/item/clothing/head/lordadmiralhat
	name = "Lord Admiral's Hat"
	desc = "A hat suitable for any man of high and exalted rank."
	icon_state = "lordadmiralhat"
	item_state = "lordadmiralhat"