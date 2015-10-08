// Add custom items you give to people here, and put their icons in custom_items.dmi
// Remember to change 'icon = 'custom_items.dmi'' for items not using /obj/item/fluff as a base
// Clothing item_state doesn't use custom_items.dmi. Just add them to the normal clothing files.

///////////////////////////////////////////////////////////////////////
/////////////////////PARADISE STATION CUSTOM ITEMS/////////////////////
///////////////////////////////////////////////////////////////////////

//////////////////////////////////
////////// Usable Items //////////
//////////////////////////////////

/obj/item/weapon/claymore/fluff // MrBarrelrolll: Maximus Greenwood
	name = "Greenwood's Blade"
	desc = "A replica claymore with strange markings scratched into the blade."
	force = 5
	sharp = 0
	edge = 0

/obj/item/weapon/claymore/fluff/IsShield()
	return 0
	
/obj/item/weapon/crowbar/fluff/zelda_creedy_1 // Zomgponies: Griffin Rowley
	name = "Zelda's Crowbar"
	desc = "A pink crow bar that has an engraving that reads, 'To Zelda. Love always, Dawn'"
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "zeldacrowbar"
	item_state = "crowbar"
	
/obj/item/clothing/glasses/meson/fluff/book_berner_1 // Adrkiller59: Adam Cooper
	name = "bespectacled mesonic surveyors"
	desc = "One of the older meson scanner models retrofitted to perform like its modern counterparts."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "book_berner_1"
	
/obj/item/weapon/lighter/zippo/fluff/purple // GodOfOreos: Jason Conrad
	name = "purple engraved zippo"
	desc = "All craftsspacemanship is of the highest quality. It is encrusted with refined plasma sheets. On the item is an image of a dwarf and the words 'Strike the Earth!' etched onto the side."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "purple_zippo_off"
	icon_on = "purple_zippo_on"
	icon_off = "purple_zippo_off"
	
/obj/item/weapon/lighter/zippo/fluff/michael_guess_1 // mrbits: Callista Gold
	name = "engraved lighter"
	desc = "A golden lighter, engraved with some ornaments and a G."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "guessip"
	icon_on = "guessipon"
	icon_off = "guessip"
	
//////////////////////////////////
//////////// Clothing ////////////
//////////////////////////////////

//////////// Gloves ////////////

//////////// Eye Wear ////////////

//////////// Hats ////////////
/obj/item/clothing/head/fluff/heather_winceworth // Regens: Heather Winceworth
	name= "Heather's rose"
	desc= "A beautiful purple rose for your hair."
	icon= 'icons/obj/clothing/hats.dmi'
	icon_state = "hairflowerp"
	item_state = "hairflowerp"

/obj/item/clothing/head/bearpelt/fluff/polar //Gibson1027: Sploosh
	name = "polar bear pelt hat"
	desc = "Fuzzy, and also stained with blood."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "polarbearpelt"
	item_state = "polarbearpelt"
	
/obj/item/clothing/head/fluff/sparkyninja_beret // Sparkyninja: Neil Wilkinson
	name = "royal marines commando beret"
	desc = "Dark Green beret with an old insignia on it."
	icon_state = "sparkyninja_beret"
	
//////////// Suits ////////////
/obj/item/clothing/suit/storage/labcoat/fluff/aeneas_rinil //Socialsystem: Lynn Fea
	name = "Robotics labcoat"
	desc = "A labcoat with a few markings denoting it as the labcoat of roboticist."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "aeneasrinil_open"
	
/obj/item/clothing/suit/jacket/fluff/kidosvest // Anxipal: Kido Qasteth
	name = "Kido's Vest"
	desc = "A rugged leather vest with a tag labelled \"Men of Mayhem.\""
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "kidosvest"
	item_state = "kidosvest"

/obj/item/clothing/suit/fluff/kluys // Kluys: Cripty Pandaen
	name = "Nano Fibre Jacket"
	desc = "A Black Suit made out of nanofibre. The newest of cyberpunk fashion using hightech liquid to solid materials."
	icon_state = "Kluysfluff1"
	item_state = "Kluysfluff1"
	blood_overlay_type = "coat"
	body_parts_covered = UPPER_TORSO|ARMS

/obj/item/clothing/suit/fluff/kluys/verb/toggle()
	set name = "Toggle Nanofibre Mode"
	set category = "Object"
	set src in usr

	if(usr.stat || usr.restrained())
		return 0

	switch(icon_state)
		if("Kluysfluff1")
			src.icon_state = "Kluysfluff2"
			usr << "The fibre unfolds into a jacket."
		else if("Kluysfluff2")
			src.icon_state = "Kluysfluff3"
			usr << "The fibre unfolds into a coat."
		else if("Kluysfluff3")
			src.icon_state = "Kluysfluff1"
			usr << "The fibre gets sucked back into its holder."
		else
			usr << "You attempt to hit the button but can't."
			return
	usr.update_inv_wear_suit()
	
/obj/item/clothing/suit/storage/labcoat/fluff/red // Sweetjealousy: Sophie Faust-Noms	
	name = "red labcoat"
	desc = "A suit that protects against minor chemical spills. Has a red stripe on the shoulders and rolled up sleeves."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "labcoat_red_open"
	
/obj/item/clothing/suit/fluff/stobarico_greatcoat // Stobarico: F.U.R.R.Y
	name = "\improper F.U.R.R.Y's Nanotrasen Greatcoat"
	desc = "A greatcoat with Nanotrasen colors."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "stobarico_jacket"

//////////// Uniforms ////////////
/obj/item/clothing/under/fluff/WornTurtleneck // DaveTheHeadcrab: Makkota Atani
	name = "Worn Combat Turtleneck"
	desc = "A worn out turtleneck with 'J.C. NSS Regnare' stitched on the inside of the collar. The tag reveals it to be 99% NanoCotton."
	icon= 'icons/obj/clothing/uniforms.dmi'
	icon_state = "syndicate"
	item_state = "bl_suit"
	item_color = "syndicate"
	has_sensor = 1 // Jumpsuit has no sensor by default
	displays_id = 0 // Purely astetic, the ID does not show up on the player sprite when equipped. Examining still reveals it.
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0) // Standard Security jumpsuit stats
	siemens_coefficient = 0

/obj/item/clothing/under/fluff/kharshai // Kharshai: Athena Castile
	name = "Castile formal outfit"
	desc = "A white and gold formal uniform, accompanied by a small pin with the numbers '004' etched upon it."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "castile_dress"
	item_state = "castile_dress"
	item_color = "castile_dress"
	
/obj/item/clothing/under/psysuit/fluff/isaca_sirius_1 // Xilia: Isaca Sirius
	name = "Isaca's suit"
	desc = "Black, comfortable and nicely fitting suit. Made not to hinder the wearer in any way. Made of some exotic fabric. And some strange glowing jewel at the waist. Name labels says; Property of Isaca Sirius; The Seeder."

/obj/item/clothing/under/fluff/jane_sidsuit // SyndiGirl: Zoey Scyth
	name = "NT-SID jumpsuit"
	desc = "A Nanotrasen Synthetic Intelligence Division jumpsuit, issued to 'volunteers'. On other people it looks fine, but right here a scientist has noted: on you it looks stupid."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "jane_sid_suit"
	item_state = "jane_sid_suit"
	item_color = "jane_sid_suit"
	has_sensor = 2
	sensor_mode = 3

/obj/item/clothing/under/fluff/jane_sidsuit/verb/toggle_zipper()
	set name = "Toggle Jumpsuit Zipper"
	set category = "Object"
	set src in usr

	if(usr.stat || usr.restrained())
		return 0

	if(src.icon_state == "jane_sid_suit_down")
		src.item_color = "jane_sid_suit"
		usr << "You zip up \the [src]."
	else
		src.item_color = "jane_sid_suit_down"
		usr << "You unzip and roll down \the [src]."

	src.icon_state = "[item_color]"
	src.item_state = "[item_color]"
	usr.update_inv_w_uniform()

//////////// Masks ////////////

//////////// Shoes ////////////

//////////// Sets ////////////
// Fox P McCloud: Fox McCloud
/obj/item/clothing/suit/jacket/fluff/fox
	name = "Aeronautics Jacket"
	desc = "An aviator styled jacket made from a peculiar material; this one seems very old."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "fox_jacket"
	item_state = "fox_jacket"
	
/obj/item/clothing/under/fluff/fox 
	name = "Aeronautics Jumpsuit"
	desc = "A jumpsuit tailor made for spacefaring fighter pilots; this one seems very old."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "fox_suit"
	item_state = "g_suit"
	item_color = "fox_suit"
	displays_id = 0 //still appears on examine; this is pure fluff.

// TheFlagbearer: Willow Walker
/obj/item/clothing/under/fluff/arachno_suit
	name = "Arachno-Man costume"
	desc = "It's what an evil genius would design if he switched brains with the Amazing Arachno-Man. Actually, he'd probably add weird tentacles that come out the back, too."
	icon = 'icons/obj/clothing/uniforms.dmi'
	icon_state = "superior_suit"
	item_state = "superior_suit"
	item_color = "superior_suit"
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
