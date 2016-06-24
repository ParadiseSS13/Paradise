// Add custom items you give to people here, and put their icons in custom_items.dmi
// Remember to change 'icon = 'custom_items.dmi'' for items not using /obj/item/fluff as a base
// Clothing item_state doesn't use custom_items.dmi. Just add them to the normal clothing files.

///////////////////////////////////////////////////////////////////////
/////////////////////PARADISE STATION CUSTOM ITEMS/////////////////////
///////////////////////////////////////////////////////////////////////

//////////////////////////////////
////////// Usable Items //////////
//////////////////////////////////

/obj/item/device/fluff/tattoo_gun // Generic tattoo gun, make subtypes for different folks
	name = "dispoable tattoo pen"
	desc = "A cheap plastic tattoo application pen."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "tatgun"
	force = 0
	throwforce = 0
	w_class = 1.0
	var/used = 0
	var/tattoo_name = "tiger stripe tattoo" // Tat name for visible messages
	var/tattoo_icon = "Tiger Body" // body_accessory.dmi, new icons defined in sprite_accessories.dm
	var/tattoo_r = 1 // RGB values for the body markings
	var/tattoo_g = 1
	var/tattoo_b = 1

/obj/item/device/fluff/tattoo_gun/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(user.a_intent == "harm")
		user.visible_message("<span class='warning'>[user] stabs [M] with the [src]!</span>", "<span class='warning'>You stab [M] with the [src]!</span>")
		to_chat(M, "<span class='userdanger'>[user] stabs you with the [src]!<br></span><span class = 'warning'>You feel a tiny prick!</span>")
		return

	if(used)
		to_chat(user, "<span class= 'notice'>The [src] is out of ink.</span>")
		return

	if(!istype(M, /mob/living/carbon/human))
		to_chat(user, "<span class= 'notice'>You don't think tattooing [M] is the best idea.</span>")
		return

	var/mob/living/carbon/human/target = M

	if(istype(target.species, /datum/species/machine))
		to_chat(user, "<span class= 'notice'>[target] has no skin, how do you expect to tattoo them?</span>")
		return

	if(target.m_style != "None")
		to_chat(user, "<span class= 'notice'>[target] already has body markings, any more would look silly!</span>")
		return

	if(target == user)
		to_chat(user, "<span class= 'notice'>You use the [src] to apply a [tattoo_name] to yourself!</span>")

	else
		user.visible_message("<span class='notice'>[user] begins to apply a [tattoo_name] [target] with the [src].</span>", "<span class='notice'>You begin to tattoo [target] with the [src]!</span>")
		if(!do_after(user,30, target = M))
			return
		user.visible_message("<span class='notice'>[user] finishes the [tattoo_name] on [target].</span>", "<span class='notice'>You finish the [tattoo_name].</span>")

	if(!used) // No exploiting do_after to tattoo multiple folks.
		target.m_style = tattoo_icon
		target.r_markings = tattoo_r
		target.g_markings = tattoo_g
		target.b_markings = tattoo_b

		target.update_markings()

		playsound(src.loc, 'sound/items/Welder2.ogg', 20, 1)
		used = 1
		update_icon()

/obj/item/device/fluff/tattoo_gun/update_icon()
	..()

	overlays.Cut()

	if(!used)
		var/image/ink = image(src.icon, src, "ink_overlay")
		ink.icon += rgb(tattoo_r, tattoo_g, tattoo_b, 190)
		overlays += ink

/obj/item/device/fluff/tattoo_gun/New()
	..()
	update_icon()


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

/obj/item/weapon/fluff/dogwhistle //phantasmicdream: Zeke Varloss
	name = "Sax's whistle"
	desc = "This whistle seems to have a strange aura about it. Maybe you should blow on it?"
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "dogwhistle"
	item_state = "dogwhistle"
	force = 2

/obj/item/weapon/fluff/dogwhistle/attack_self(mob/user)
	user.visible_message("<span class='notice'>[user] blows on the whistle, but no sound comes out.</span>", "<span class='notice'>You blow on the whistle, but don't hear anything.</span>")
	spawn(20)
		var/mob/living/simple_animal/pet/corgi/C = new /mob/living/simple_animal/pet/corgi(get_turf(user))
		var/obj/item/clothing/head/det_hat/D = new /obj/item/clothing/head/det_hat(C)
		D.flags |= NODROP
		C.inventory_head = D
		C.regenerate_icons()
		C.name = "Detective Sax"
		C.visible_message("<span class='notice'>[C] suddenly winks into existence at [user]'s feet!</span>")
		to_chat(user, "<span class='danger'>[src] crumbles to dust in your hands!</span>")
		qdel(src)

/obj/item/weapon/storage/toolbox/fluff/lunchbox //godoforeos: Jason Conrad
	name = "lunchpail"
	desc = "A simple black lunchpail."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "lunch_box"
	item_state = "lunch_box"
	force = 5
	throwforce = 5
	w_class = 3
	max_combined_w_class = 9
	storage_slots = 3

/obj/item/weapon/storage/toolbox/fluff/lunchbox/New()
	..()
	new /obj/item/weapon/reagent_containers/food/snacks/sandwich(src)
	new /obj/item/weapon/reagent_containers/food/snacks/chips(src)
	new /obj/item/weapon/reagent_containers/food/drinks/cans/cola(src)


/obj/item/device/guitar/jello_guitar //Antcolon3: Dan Jello
	name = "Dan Jello's Pink Guitar"
	desc = "Dan Jello's special pink guitar."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "jello_guitar"
	item_state = "jello_guitar"

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
	item_state = "sparkyninja_beret"

/obj/item/clothing/head/beret/fluff/sigholt //sigholtstarsong: Sigholt Starsong
	name = "Lieutenant Starsong's beret"
	desc = "This beret bears insignia of the SOLGOV Marine Corps 417th Regiment, 2nd Battalion, Bravo Company. It looks meticulously maintained."
	icon_state = "beret_hos"
	item_state = "beret_hos"

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
	ignore_suitadjust = 1
	action_button_name = null
	adjust_flavour = null

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
			to_chat(usr, "The fibre unfolds into a jacket.")
		if("Kluysfluff2")
			src.icon_state = "Kluysfluff3"
			to_chat(usr, "The fibre unfolds into a coat.")
		if("Kluysfluff3")
			src.icon_state = "Kluysfluff1"
			to_chat(usr, "The fibre gets sucked back into its holder.")
		else
			to_chat(usr, "You attempt to hit the button but can't.")
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
		to_chat(usr, "You zip up \the [src].")
	else
		src.item_color = "jane_sid_suit_down"
		to_chat(usr, "You unzip and roll down \the [src].")

	src.icon_state = "[item_color]"
	src.item_state = "[item_color]"
	usr.update_inv_w_uniform()

/obj/item/clothing/under/fluff/honourable // MrBarrelrolll: Maximus Greenwood
	name = "Viridi Protegat"
	desc = "A set of chainmail adorned with a hide mantle. \"Greenwood\" is engraved into the right breast."
	icon = 'icons/obj/clothing/uniforms.dmi'
	icon_state = "roman"
	item_state = "maximus_armor"
	item_color = "maximus_armor"
	displays_id = 0
	strip_delay = 100

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
	ignore_suitadjust = 1
	action_button_name = null
	adjust_flavour = null

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

/obj/item/weapon/nullrod/fluff/chronx //chronx100: Hughe O'Splash
	fluff_transformations = list(/obj/item/weapon/nullrod/fluff/chronx/scythe)

/obj/item/weapon/nullrod/fluff/chronx/scythe
	name = "Soul Collector"
	desc = "An ancient scythe used by the worshipers of Cthulhu. Tales say it is used to prepare souls for Cthulhu's great devouring. Someone carved their name into the handle: Hughe O'Splash"
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "chronx_scythe"
	item_state = "chronx_scythe"

/obj/item/clothing/head/fluff/chronx //chronx100: Hughe O'Splash
	name = "Cthulhu's Hood"
	desc = "Hood worn by the worshipers of Cthulhu. You see a name inscribed in blood on the inside: Hughe O'Splash"
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "chronx_hood"
	item_state = "chronx_hood"
	flags = HEADCOVERSEYES | BLOCKHAIR
	action_button_name = "Transform Hood"
	var/adjusted = 0

/obj/item/clothing/head/fluff/chronx/ui_action_click()
	adjust()

/obj/item/clothing/head/fluff/chronx/verb/adjust()
	set name = "Transform Hood"
	set category = "Object"
	set src in usr
	if(isliving(usr) && !usr.incapacitated())
		if(adjusted)
			icon_state = initial(icon_state)
			item_state = initial(item_state)
			to_chat(usr, "You untransform \the [src].")
			adjusted = 0
		else
			icon_state += "_open"
			item_state += "_open"
			to_chat(usr, "You transform \the [src].")
			adjusted = 1
		usr.update_inv_head()

/obj/item/clothing/suit/chaplain_hoodie/fluff/chronx //chronx100: Hughe O'Splash
	name = "Cthulhu's Robes"
	desc = "Robes worn by  the worshipers of Cthulhu. You see a name inscribed in blood on the inside: Hughe O'Splash"
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "chronx_robe"
	item_state = "chronx_robe"
	flags = ONESIZEFITSALL
	action_button_name = "Transform Robes"
	adjust_flavour = "untransform"
	ignore_suitadjust = 0

/obj/item/clothing/suit/chaplain_hoodie/fluff/chronx/New()
	..()
	verbs -= /obj/item/clothing/suit/verb/openjacket

/obj/item/clothing/suit/chaplain_hoodie/fluff/chronx/verb/adjust()
	set name = "Transform Robes"
	set category = "Object"
	set src in usr
	if(!istype(usr, /mob/living))
		return
	adjustsuit(usr)

/obj/item/clothing/shoes/black/fluff/chronx //chronx100: Hughe O'Splash
	name = "Cthulhu's Boots"
	desc = "Boots worn by the worshipers of Cthulhu. You see a name inscribed in blood on the inside: Hughe O'Splash"
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "chronx_shoes"
	item_state = "chronx_shoes"

/obj/item/clothing/suit/armor/vest/fluff/tactical //m3hillus: Medusa Schlofield
	name = "tactical armor vest"
	desc = "A tactical vest with armored plate inserts."
	icon = 'icons/obj/clothing/ties.dmi'
	icon_state = "vest_black"
	item_state = "vest_black"

/obj/item/clothing/under/pants/fluff/combat
	name = "combat pants"
	desc = "Medium style tactical pants, for the fashion aware combat units out there."
	icon_state = "chaps"
	item_color = "combat_pants"

/obj/item/clothing/suit/jacket/fluff/elliot_windbreaker // DaveTheHeadcrab: Elliot Campbell
	name = "nylon windbreaker"
	desc = "A cheap nylon windbreaker, according to the tag it was manufactured in New Chiba, Earth.<br>The color reminds you of a television tuned to a dead channel."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "elliot_windbreaker_open"
	item_state = "elliot_windbreaker_open"
	adjust_flavour = "unzip"
	suit_adjusted = 1

/obj/item/device/fluff/tattoo_gun/elliot_cybernetic_tat
	desc = "A cheap plastic tattoo application pen.<br>This one seems heavily used."
	tattoo_name = "circuitry tattoo"
	tattoo_icon = "Elliot Circuit Tattoo"
	tattoo_r = 48
	tattoo_g = 138
	tattoo_b = 176

/obj/item/device/fluff/tattoo_gun/elliot_cybernetic_tat/attack_self(mob/user as mob)
	if(!used)
		var/ink_color = input("Please select an ink color.", "Tattoo Ink Color", rgb(tattoo_r, tattoo_g, tattoo_b)) as color|null
		if(ink_color && !(user.incapacitated() || used) )
			tattoo_r = hex2num(copytext(ink_color, 2, 4))
			tattoo_g = hex2num(copytext(ink_color, 4, 6))
			tattoo_b = hex2num(copytext(ink_color, 6, 8))

			to_chat(user, "<span class='notice'>You change the color setting on the [src].</span>")

			update_icon()

	else
		to_chat(user, "<span class='notice'>The [src] is out of ink!</span>")