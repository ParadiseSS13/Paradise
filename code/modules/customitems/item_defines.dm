// Add custom items you give to people here, and put their icons in custom_items.dmi
// Remember to change 'icon = 'custom_items.dmi'' for items not using /obj/item/fluff as a base
// Clothing item_state doesn't use custom_items.dmi. Just add them to the normal clothing files.

/obj/item/fluff // so that they don't spam up the object tree
	icon = 'icons/obj/custom_items.dmi'
	w_class = 1.0



///////////////////////////////////////////////////////////////////////
/////////////////////PARADISE STATION CUSTOM ITEMS////////////////////
//////////////////////////////////////////////////////////////////////

/obj/item/clothing/head/fluff/heather_winceworth // regens: Heather Winceworth
	name= "Heather's rose"
	desc= "A beautiful purple rose for your hair."
	icon= 'icons/obj/clothing/hats.dmi'
	icon_state = "hairflowerp"
	item_state = "hairflowerp"

/obj/item/clothing/under/fluff/WornTurtleneck // DaveTheHeadcrab: Makkota Atani
	name = "Worn Combat Turtleneck"
	desc = "A worn out turtleneck with 'J.C. NSS Regnare' stitched on the inside of the collar. The tag reveals it to be 99% NanoCotton."
	icon= 'icons/obj/clothing/uniforms.dmi'
	icon_state = "syndicate"
	item_state = "bl_suit"
	_color = "syndicate"
	has_sensor = 1 // Jumpsuit has no sensor by default
	displays_id = 0 // Purely astetic, the ID does not show up on the player sprite when equipped. Examining still reveals it.
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0) // Standard Security jumpsuit stats
	siemens_coefficient = 0.

/obj/item/clothing/under/fluff/blackschoolGirl // Black schoolgirl uniform
	name = "Black Schoolgirl Uniform"
	desc = "A Japanese style school uniform for girls"
	icon= 'icons/obj/clothing/uniforms.dmi'
	icon_state = "schoolgirl_black"
	_color = "schoolgirl_black"
	item_state = "schoolgirl_black"
	has_sensor = 1 // Just to make sure it has a sensor
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0) // Standar Jumpsuit stats

/obj/item/clothing/head/fluff/sparkyninja_beret //Sparkyninja: Neil Wilkinson
	name = "royal marines commando beret"
	desc = "Dark Green beret with an old insignia on it."
	icon_state = "sparkyninja_beret"

/obj/item/weapon/book/manual/security_space_law/black
	name = "Space Law - Limited Edition"
	desc = "A leather-bound, immaculately-written copy of JUSTICE."
	icon_state = "bookSpaceLawblack"
	title = "Space Law - Limited Edition"

//////////////////////////////////
////////// Usable Items //////////
//////////////////////////////////

/obj/item/weapon/pen/fluff/fountainpen //paththegreat: Eli Stevens
	name = "Engraved Fountain Pen"
	desc = "An expensive looking pen with the initials E.S. engraved into the side."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "fountainpen"

/obj/item/weapon/card/id/fluff/lifetime	//fastler: Fastler Greay; it seemed like something multiple people would have
	name = "Lifetime ID Card"
	desc = "A modified ID card given only to those people who have devoted their lives to the better interests of Nanotrasen. It sparkles blue."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "lifetimeid"

/obj/item/weapon/crowbar/fluff/zelda_creedy_1 //daaneesh: Zelda Creedy
	name = "Zelda's Crowbar"
	desc = "A pink crow bar that has an engraving that reads, 'To Zelda. Love always, Dawn'"
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "zeldacrowbar"
	item_state = "crowbar"

//////////////////////////////////
//////////// Clothing ////////////
//////////////////////////////////

//////////// Gloves ////////////
//////////// Eye Wear ////////////

/obj/item/clothing/glasses/meson/fluff/book_berner_1 //asanadas: Book Berner
	name = "bespectacled mesonic surveyors"
	desc = "One of the older meson scanner models retrofitted to perform like its modern counterparts."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "book_berner_1"

//////////// Hats ////////////
/obj/item/clothing/head/welding/fluff/alice_mccrea_1 //madmalicemccrea: Alice McCrea
	name = "flame decal welding helmet"
	desc = "A welding helmet adorned with flame decals, and several cryptic slogans of varying degrees of legibility. \"Fly the Friendly Skies\" is clearly visible, written above the visor, for some reason."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "alice_mccrea_1"

/obj/item/clothing/head/welding/fluff/yuki_matsuda_1 //searif: Yuki Matsuda
	name = "white decal welding helmet"
	desc = "A white welding helmet with a character written across it."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "yuki_matsuda_1"

/obj/item/clothing/head/welding/fluff/norah_briggs_1 //bountylord13: Norah Briggs
	name = "blue flame decal welding helmet"
	desc = "A welding helmet with blue flame decals on it."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "norah_briggs_1"

//////////// Suits ////////////

/obj/item/clothing/suit/storage/labcoat/fluff/aeneas_rinil //Robotics Labcoat - Aeneas Rinil [APPR]
	name = "Robotics labcoat"
	desc = "A labcoat with a few markings denoting it as the labcoat of roboticist."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "aeneasrinil_open"

/obj/item/clothing/suit/armor/vest/fluff/deus_blueshield //deusdactyl
	name = "blueshield security armor"
	desc = "An armored vest with the badge of a Blueshield Lieutenant."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "deus_blueshield"
	item_state = "deus_blueshield"

//////////// Uniforms ////////////
/obj/item/clothing/under/psysuit/fluff/isaca_sirius_1 // Xilia: Isaca Sirius
	name = "Isaca's suit"
	desc = "Black, comfortable and nicely fitting suit. Made not to hinder the wearer in any way. Made of some exotic fabric. And some strange glowing jewel at the waist. Name labels says; Property of Isaca Sirius; The Seeder."


/////// NT-SID Suit //Zuhayr: Jane Doe

/obj/item/clothing/under/fluff/jane_sidsuit
	name = "NT-SID jumpsuit"
	desc = "A Nanotrasen Synthetic Intelligence Division jumpsuit, issued to 'volunteers'. On other people it looks fine, but right here a scientist has noted: on you it looks stupid."

	icon = 'icons/obj/custom_items.dmi'
	icon_state = "jane_sid_suit"
	item_state = "jane_sid_suit"
	_color = "jane_sid_suit"
	has_sensor = 2
	sensor_mode = 3

//Suit roll-down toggle.
/obj/item/clothing/under/fluff/jane_sidsuit/verb/toggle_zipper()
	set name = "Toggle Jumpsuit Zipper"
	set category = "Object"
	set src in usr

	if(!usr.canmove || usr.stat || usr.restrained())
		return 0

	if(src.icon_state == "jane_sid_suit_down")
		src._color = "jane_sid_suit"
		usr << "You zip up the [src]."
	else
		src._color = "jane_sid_suit_down"
		usr << "You unzip and roll down the [src]."

	src.icon_state = "[_color]"
	src.item_state = "[_color]"
	usr.update_inv_w_uniform()

//////////// Masks ////////////
//////////// Shoes ////////////
//////////// Sets ////////////

////// Short Sleeve Medical Outfit //erthilo: Farah Lants

/obj/item/clothing/under/rank/medical/fluff/short
	name = "short sleeve medical jumpsuit"
	desc = "Made of a special fiber that gives special protection against biohazards. Has a cross on the chest denoting that the wearer is trained medical personnel and short sleeves."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "medical_short"
	_color = "medical_short"

/obj/item/clothing/suit/storage/labcoat/fluff/red
	name = "red labcoat"
	desc = "A suit that protects against minor chemical spills. Has a red stripe on the shoulders and rolled up sleeves."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "labcoat_red_open"

////// Blue and Bloody Set //deimosvezzati: Hiro Mezu

/obj/item/clothing/under/fluff/customblue // Personal jumpsuit (blue tie / belt buckle)
	name = "custom-fitted blue jumpsuit"
	desc = "A custom blue uniform made for a trapped soul. It has the initials H.M. on the tag."
	icon= 'icons/obj/clothing/uniforms.dmi'
	icon_state = "hm_suit"
	_color = "hm_suit"
	item_state = "hm_suit"
	has_sensor = 1 // Just to make sure it has a sensor
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0) // Standard Jumpsuit stats

/obj/item/clothing/suit/armor/vest/fluff/bloody //Bloody armor vest
	name = "bloodied security armor"
	desc = "A vest drenched in the blood of Greytide. It has seen better days. It has the initials H.M. scratched into the inside."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "hm_armorvest"
	item_state = "hm_armorvest"

/obj/item/clothing/mask/gas/sechailer/fluff/bluemask //Blue security mask
	name = "custom SWAT mask"
	desc = "A neon blue swat mask, used for demoralizing Greytide in the wild. It has the initials H.M. on the side."
	action_button_name = "HALT!"
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "hm_sec_mask"
	item_state = "hm_sec_mask"
	aggressiveness = 3
	ignore_maskadjust = 1

///// Noble's Clothes Set //theoricus: Baron Robot VII

/obj/item/clothing/under/fluff/noble_clothes // Custom jumpsuit
	name = "noble clothes"
	desc = "They fall just short of majestic."
	icon = 'icons/obj/clothing/uniforms.dmi'
	icon_state = "noble_clothes"
	_color = "noble_clothes"
	item_state = "noble_clothes"
	has_sensor = 1 // Just to make sure it has a sensor
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0) // Standard Jumpsuit stats

/obj/item/clothing/suit/fluff/noble_coat // A nauseatingly colored coat
	name = "noble coat"
	desc = "The livid blues, purples and greens are awesome enough to evoke a visceral response in you; it is not dissimilar to indigestion."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "noble_coat"
	item_state = "noble_coat"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/shoes/fluff/noble_boot
	name = "noble boots"
	desc = "The boots are economically designed to balance function and comfort, so that you can step on peasants without having to worry about blisters. The leather also resists unwanted blood stains."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "noble_boot"
	_color = "noble_boot"
	item_state = "noble_boot"
	
/////Arachno-Man Costume set //the flagbearer: Willow Walker
/obj/item/clothing/under/fluff/arachno_suit // Custom Jumpsuit
	name = "Arachno-Man costume"
	desc = "It's what an evil genius would design if he switched brains with the Amazing Arachno-Man. Actually, he'd probably add weird tentacles that come out the back, too."
	icon = 'icons/obj/clothing/uniforms.dmi'
	icon_state = "superior_suit"
	item_state = "superior_suit"
	_color = "superior_suit"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	flags_inv = HIDEGLOVES|HIDESHOES
	
/obj/item/clothing/head/fluff/arachno_mask
	name = "Arachno-Man mask"
	desc = "Put it on. The mask, it's gonna make you stronger!"
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "superior_mask"
	item_state = "superior_mask"
	body_parts_covered = HEAD
	flags = BLOCKHAIR
	flags_inv = HIDEFACE

//////////// Weapons ////////////
