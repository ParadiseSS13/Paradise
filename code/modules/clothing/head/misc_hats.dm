

/obj/item/clothing/head/centhat
	name = "\improper CentComm. hat"
	desc = "It's good to be emperor."
	icon_state = "centcom"
	inhand_icon_state = "tophat"
	armor = list(MELEE = 20, BULLET = 10, LASER = 20, ENERGY = 5, BOMB = 15, RAD = 0, FIRE = 50, ACID = 50)
	strip_delay = 80

/obj/item/clothing/head/hairflower
	name = "hair flower pin"
	desc = "Smells nice."
	icon_state = "hairflower"

/obj/item/clothing/head/powdered_wig
	name = "powdered wig"
	desc = "A powdered wig."
	icon_state = "pwig"

/obj/item/clothing/head/justice_wig
	name = "justice wig"
	desc = "A fancy powdered wig given to arbitrators of the law. It looks itchy."
	icon_state = "jwig"
	dog_fashion = /datum/dog_fashion/head/justice_wig

/obj/item/clothing/head/that
	name = "top-hat"
	desc = "It's an amish looking hat."
	icon_state = "tophat"
	dog_fashion = /datum/dog_fashion/head
	sprite_sheets = list("Vox" = 'icons/mob/clothing/species/vox/head.dmi')

/obj/item/clothing/head/redcoat
	name = "redcoat's hat"
	icon_state = "redcoat"
	desc = "<i>'I guess it's a redhead.'</i>"

/obj/item/clothing/head/mailman
	name = "mailman's hat"
	icon_state = "mailman"
	desc = "<i>'Right-on-time'</i> mail service head wear."

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi'
		)

/obj/item/clothing/head/plaguedoctorhat
	name = "plague doctor's hat"
	desc = "These were once used by Plague doctors. They're pretty much useless."
	icon_state = "plaguedoctor"
	permeability_coefficient = 0.01

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi'
		)

/obj/item/clothing/head/hasturhood
	name = "hastur's hood"
	desc = "It's unspeakably stylish."
	icon_state = "hasturhood"
	flags = BLOCKHAIR
	flags_cover = HEADCOVERSEYES

/obj/item/clothing/head/nursehat
	name = "nurse's hat"
	desc = "It allows quick identification of trained medical personnel."
	icon_state = "nursehat"
	dog_fashion = /datum/dog_fashion/head/nurse

/obj/item/clothing/head/syndicatefake
	name = "black and red space-helmet replica"
	icon_state = "syndicate-helm-black-red"
	desc = "A plastic replica of a syndicate agent's space helmet, you'll look just like a real murderous syndicate agent in this! This is a toy, it is not made for use in space!"
	flags = BLOCKHAIR
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/helmet.dmi'
	sprite_sheets = list(
		"Grey" = 'icons/mob/clothing/species/grey/helmet.dmi',
		"Tajaran" = 'icons/mob/clothing/species/tajaran/helmet.dmi',
		"Unathi" = 'icons/mob/clothing/species/unathi/helmet.dmi',
		"Vulpkanin" = 'icons/mob/clothing/species/vulpkanin/helmet.dmi',
		"Vox" = 'icons/mob/clothing/species/vox/helmet.dmi')

/obj/item/clothing/head/cueball
	name = "cueball helmet"
	desc = "A large, featureless white orb meant to be worn on your head. How do you even see out of this thing?"
	icon_state = "cueball"
	flags = BLOCKHAIR
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	sprite_sheets = list("Grey" = 'icons/mob/clothing/species/grey/head.dmi')

/obj/item/clothing/head/snowman
	name = "snowman head"
	desc = "A ball of white styrofoam. So festive."
	icon_state = "snowman_h"
	flags = BLOCKHAIR
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	sprite_sheets = list("Grey" = 'icons/mob/clothing/species/grey/head.dmi')

/obj/item/clothing/head/greenbandana
	name = "green bandana"
	desc = "It's a green bandana with some fine nanotech lining."
	icon_state = "greenbandana"
	flags_inv = 0

/obj/item/clothing/head/justice
	name = "justice hat"
	desc = "Fight for what's righteous!"
	icon_state = "justicered"
	flags = BLOCKHAIR
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH

/obj/item/clothing/head/justice/blue
	icon_state = "justiceblue"

/obj/item/clothing/head/justice/yellow
	icon_state = "justiceyellow"

/obj/item/clothing/head/justice/green
	icon_state = "justicegreen"

/obj/item/clothing/head/justice/pink
	icon_state = "justicepink"

/obj/item/clothing/head/rabbitears
	name = "rabbit ears"
	desc = "Wearing these makes you look useless, and only good for your sex appeal."
	icon_state = "bunny"
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/hat.dmi'
	dog_fashion = /datum/dog_fashion/head/rabbit

/obj/item/clothing/head/flatcap
	name = "flat cap"
	desc = "A working man's cap."
	icon_state = "flat_cap"
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/hat.dmi'

/obj/item/clothing/head/pirate
	name = "pirate hat"
	desc = "Yarr."
	icon_state = "pirate"
	dog_fashion = /datum/dog_fashion/head/pirate
	sprite_sheets = list("Vox" = 'icons/mob/clothing/species/vox/head.dmi')

/obj/item/clothing/head/hgpiratecap
	name = "pirate hat"
	desc = "Yarr."
	icon_state = "hgpiratecap"
	sprite_sheets = list("Vox" = 'icons/mob/clothing/species/vox/head.dmi')

/obj/item/clothing/head/bandana
	name = "pirate bandana"
	desc = "Yarr."
	icon_state = "bandana"
	sprite_sheets = list("Vox" = 'icons/mob/clothing/species/vox/head.dmi')

//stylish bs12 hats

/obj/item/clothing/head/bowlerhat
	name = "bowler hat"
	desc = "For that industrial age look."
	icon_state = "bowler_hat"
	dog_fashion = /datum/dog_fashion/head/bowlerhat
	sprite_sheets = list("Vox" = 'icons/mob/clothing/species/vox/head.dmi')

/obj/item/clothing/head/beaverhat
	name = "beaver hat"
	desc = "Like a top hat, but made of beavers."
	icon_state = "beaver_hat"
	sprite_sheets = list("Vox" = 'icons/mob/clothing/species/vox/head.dmi')

/obj/item/clothing/head/boaterhat
	name = "boater hat"
	desc = "Goes well with celery."
	icon_state = "boater_hat"
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi'
		)

/obj/item/clothing/head/cowboyhat
	name = "cowboy hat"
	desc = "For the Rancher in us all."
	icon_state = "cowboyhat"
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/head.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/head.dmi'
		)

/obj/item/clothing/head/cowboyhat/tan
	name = "tan cowboy hat"
	desc = "There's a new sheriff in town. Pass the whiskey."
	icon_state = "cowboyhat_tan"

/obj/item/clothing/head/cowboyhat/black
	name = "black cowboy hat"
	desc = "This station ain't big enough for the two ah' us."
	icon_state = "cowboyhat_black"

/obj/item/clothing/head/cowboyhat/white
	name = "white cowboy hat"
	desc = "Authentic Marshall hair case. Now ya can protect this here homestead. Navy Model not included."
	icon_state = "cowboyhat_white"

/obj/item/clothing/head/cowboyhat/pink
	name = "cowgirl hat"
	desc = "For those buckle bunnies wanta' become a real buckaroo."
	icon_state = "cowboyhat_pink"

/obj/item/clothing/head/cowboyhat/sec
	name = "security cowboy hat"
	desc = "Secway is your horse."
	icon_state = "cowboyhat_sec"

/obj/item/clothing/head/fedora
	name = "fedora"
	desc = "A great hat ruined by being within fifty yards of you."
	icon_state = "fedora"
	actions_types = list(/datum/action/item_action/tip_fedora)
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/head.dmi'
	)

/obj/item/clothing/head/fedora/attack_self__legacy__attackchain(mob/user)
	tip_fedora(user)

/obj/item/clothing/head/fedora/item_action_slot_check(slot)
	if(slot == ITEM_SLOT_HEAD)
		return TRUE

/obj/item/clothing/head/fedora/proc/tip_fedora(mob/user)
	user.visible_message("<span class='notice'>[user] tips [user.p_their()] fedora.</span>", "<span class='notice'>You tip your fedora.</span>")

/obj/item/clothing/head/fedora/whitefedora
	name = "white fedora"
	icon_state = "wfedora"

/obj/item/clothing/head/fedora/brownfedora
	name = "brown fedora"
	icon_state = "bfedora"

/obj/item/clothing/head/fez
	name = "fez"
	desc = "Put it on your monkey, make lots of cash money."
	icon_state = "fez"
	sprite_sheets = list("Vox" = 'icons/mob/clothing/species/vox/head.dmi')

//end bs12 hats

/obj/item/clothing/head/witchwig
	name = "witch costume wig"
	desc = "Eeeee~heheheheheheh!"
	icon_state = "witch"
	flags = BLOCKHAIR
	sprite_sheets = list("Vox" = 'icons/mob/clothing/species/vox/head.dmi')

/obj/item/clothing/head/chicken
	name = "chicken suit head"
	desc = "Bkaw!"
	icon_state = "chickenhead"
	inhand_icon_state = "chickensuit"
	flags = BLOCKHAIR
	sprite_sheets = list("Grey" = 'icons/mob/clothing/species/grey/head.dmi')

/obj/item/clothing/head/corgi
	name = "corgi suit head"
	desc = "Woof!"
	icon_state = "corgihead"
	inhand_icon_state = "chickensuit"
	flags = BLOCKHAIR

/obj/item/clothing/head/corgi/en
	name = "E-N suit head"
	icon_state = "enhead"

/obj/item/clothing/head/corgi/super_hero
	name = "super-hero corgi suit head"
	desc = "Woof! This one seems to pulse with a strange power"
	flags = BLOCKHAIR | NODROP

/obj/item/clothing/head/corgi/super_hero/en
	name = "E-N suit head"
	icon_state = "enhead"

/obj/item/clothing/head/bearpelt
	name = "space bear pelt hat"
	desc = "Fuzzy."
	icon_state = "bearpelt"
	flags = BLOCKHAIR
	sprite_sheets = list("Vox" = 'icons/mob/clothing/species/vox/head.dmi')

/obj/item/clothing/head/bearpelt/black
	name = "black bear pelt hat"
	icon_state = "black_bearpelt"

/obj/item/clothing/head/bearpelt/brown
	name = "brown bear pelt hat"
	icon_state = "brown_bearpelt"

/obj/item/clothing/head/bearpelt/polar
	name = "polar bear pelt hat"
	desc = "Fuzzy, and also stained with blood."
	icon_state = "polar_bearpelt"

/obj/item/clothing/head/xenos
	name = "xeno helmet"
	desc = "A helmet made out of chitinous alien hide."
	icon_state = "xenos"
	flags = BLOCKHAIR
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE

/// Why do these exist - Because they aren't specifically Nazi Germany
/obj/item/clothing/head/stalhelm
	name = "clown stalhelm"
	desc = "The typical clown soldier's helmet."
	icon_state = "stalhelm"
	flags = BLOCKHAIR
	flags_inv = HIDEEARS

/obj/item/clothing/head/foragecap
	name = "clown HONKMech cap"
	desc = "The softcap worn by HONK Mech pilots."
	icon_state = "foragecap"
	flags = BLOCKHAIR

/obj/item/clothing/head/armyofficer
	name = "clown officer cap"
	desc = "The peaked clown officer's cap."
	icon_state = "armyofficer"
	flags = BLOCKHAIR
	flags_inv = HIDEEARS

/// Fluff?
/obj/item/clothing/head/beret/purple
	name = "Pierson Family Beret"
	desc = "A purple beret, with a small golden crescent moon sewn onto it."
	icon = 'icons/obj/clothing/hats.dmi'
	icon_state = "beret_purple"

/obj/item/clothing/head/sombrero
	name = "sombrero"
	desc = "You can practically taste the fiesta."
	icon_state = "sombrero"
	dog_fashion = /datum/dog_fashion/head/sombrero
	sprite_sheets = list("Vox" = 'icons/mob/clothing/species/vox/head.dmi')

/obj/item/clothing/head/sombrero/green
	name = "green sombrero"
	desc = "As elegant as a dancing cactus."
	icon_state = "greensombrero"
	dog_fashion = null

/obj/item/clothing/head/sombrero/shamebrero
	name = "shamebrero"
	desc = "Once it's on, it never comes off."
	icon_state = "shamebrero"
	flags = NODROP
	dog_fashion = null

/obj/item/clothing/head/cone
	name = "warning cone"
	desc = "This cone is trying to warn you of something!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "cone"
	force = 1.0
	throwforce = 3.0
	throw_range = 5
	attack_verb = list("warned", "cautioned", "smashed")
	resistance_flags = NONE
	dog_fashion = /datum/dog_fashion/head/cone
	magical = TRUE // It's pointy, it's funny!

/obj/item/clothing/head/jester
	name = "jester hat"
	desc = "A hat with bells, to add some merryness to the suit."
	icon_state = "jester_hat"

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi'
		)

/obj/item/clothing/head/rice_hat
	name = "rice hat"
	desc = "Welcome to the rice fields, motherfucker."
	icon_state = "rice_hat"

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi'
		)

/obj/item/clothing/head/griffin
	name = "griffon head"
	desc = "Why not 'eagle head'? Who knows."
	icon_state = "griffinhat"
	flags = BLOCKHAIR
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/hat.dmi'
	sprite_sheets = list("Grey" = 'icons/mob/clothing/species/grey/head.dmi')
	actions_types = list(/datum/action/item_action/caw)

/obj/item/clothing/head/griffin/attack_self__legacy__attackchain()
	caw()

/obj/item/clothing/head/griffin/proc/caw()
	if(cooldown < world.time - 20) // A cooldown, to stop people being jerks
		playsound(src.loc, 'sound/creatures/caw.ogg', 50, 1)
		cooldown = world.time

/obj/item/clothing/head/lordadmiralhat
	name = "lord admiral's hat"
	desc = "A hat suitable for any man of high and exalted rank."
	icon_state = "lordadmiralhat"

/obj/item/clothing/head/human_head
	name = "bloated human head"
	desc = "A horribly bloated and mismatched human head."
	icon_state = "lingspacehelmet"
	icon_monitor = 'icons/mob/clothing/species/machine/monitor/helmet.dmi'

/obj/item/clothing/head/papersack
	name = "paper sack hat"
	desc = "A paper sack with crude holes cut out for eyes. Useful for hiding one's identity or ugliness."
	icon_state = "papersack"
	flags = BLOCKHAIR
	flags_inv = HIDEFACE|HIDEEARS

	sprite_sheets = list(
	"Grey" = 'icons/mob/clothing/species/grey/head.dmi'
	)

/obj/item/clothing/head/papersack/smiley
	desc = "A paper sack with crude holes cut out for eyes and a sketchy smile drawn on the front. Not creepy at all."
	icon_state = "papersack_smile"

	sprite_sheets = list(
	"Grey" = 'icons/mob/clothing/species/grey/head.dmi'
	)

/obj/item/clothing/head/crown
	name = "crown"
	desc = "A crown fit for a king, a petty king maybe."
	icon_state = "crown"
	armor = list(MELEE = 10, BULLET = 0, LASER = 0, ENERGY = 10, BOMB = 0, RAD = 0, FIRE = INFINITY, ACID = 50)
	resistance_flags = FIRE_PROOF
	can_be_hat = FALSE

/obj/item/clothing/head/crown/fancy
	name = "magnificent crown"
	desc = "A crown worn by only the highest emperors of the land."
	icon_state = "fancycrown"

/obj/item/clothing/head/zepelli
	name = "chequered diamond hat"
	desc = "Wearing this makes you feel like a real mozzarella cheeseball. "
	icon_state = "zepelli"

/obj/item/clothing/head/cuban_hat
	name = "rhumba hat"
	desc = "Now just to find some maracas!"
	icon_state = "cuban_hat"
	sprite_sheets = list("Vox" = 'icons/mob/clothing/species/vox/head.dmi')

/obj/item/clothing/head/flower_crown
	name = "flower crown"
	desc = "A colorful flower crown made out of lilies, sunflowers and poppies."
	icon_state = "flower_crown"
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/head.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/head.dmi'
		)

/obj/item/clothing/head/sunflower_crown
	name = "sunflower crown"
	desc = "A bright flower crown made out sunflowers that is sure to brighten up anyone's day!"
	icon_state = "sunflower_crown"
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/head.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/head.dmi'
		)

/obj/item/clothing/head/poppy_crown
	name = "poppy crown"
	desc = "A flower crown made out of a string of bright red poppies."
	icon_state = "poppy_crown"
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/head.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/head.dmi'
		)

/obj/item/clothing/head/lily_crown
	name = "lily crown"
	desc = "A leafy flower crown with a cluster of large white lilies at the front."
	icon_state = "lily_crown"
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/head.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/head.dmi'
		)

/obj/item/clothing/head/geranium_crown
	name = "geranium crown"
	desc = "A flower crown made out of an array of rich purple geraniums."
	icon_state = "geranium_crown"
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/head.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/head.dmi'
		)

/obj/item/clothing/head/cool_bandana
	name = "badass bandana"
	desc = "You know what time it is."
	icon_state = "tmc_hat"
	inhand_icon_state = "armor"
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/head.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/head.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/head.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/head.dmi'
	)

/obj/item/clothing/head/hooded/dark_hood
	name = "dark hood"
	desc = "A dark hood for dark times."
	icon_state = "dark_hood"
	flags = BLOCKHAIR
	flags_cover = HEADCOVERSEYES

