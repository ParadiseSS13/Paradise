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
	flags = FPRINT|TABLEPASS

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

//////////////////////////////////
////////// Fluff Items ///////////
//////////////////////////////////

/obj/item/weapon/paper/fluff/sue_donem // aikasan: Sue Donem
	name = "cyborgification waiver"
	desc = "It's some kind of official-looking contract."

/obj/item/weapon/paper/fluff/sue_donem/New()
	..()

	info = "<B>Organic Carrier AIA and Standard Cyborgification Agreement</B><BR>\n<BR>\nUnder the authority of Nanotrasen Synthetic Intelligence Division, this document hereby authorizes an accredited Roboticist of the NSS Exodus or a deputized authority to perform a regulation lobotomisation upon the person of one '<I>Sue Donem</I>' (hereafter referred to as the Subject) with intent to enact a live Artificial Intelligence Assimilation (AIA) or live Cyborgification proceedure.<BR>\n<BR>\nNo further station authorization is required, and the Subject waives all rights as a human under Nanotrasen internal and external legal protocol. This document is subject to amendment under Nanotrasen internal protocol \[REDACTED\].<BR>\n<BR>\nSigned: <I>Sue Donem</I><BR>\n"

	stamps = (stamps=="" ? "<HR>" : "<BR>") + "<i>This paper has been stamped with the NanoTrasen Synthetic Intelligence Division rubber stamp.</i>"

	var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
	stampoverlay.pixel_x = rand(-2, 2)
	stampoverlay.pixel_y = rand(-3, 2)
	stampoverlay.icon_state = "paper_stamp-rd"
	overlays += stampoverlay

	update_icon()

/obj/item/fluff/wes_solari_1 //tzefa: Wes Solari
	name = "family photograph"
	desc = "A family photograph of a couple and a young child, Written on the back it says \"See you soon Dad -Roy\"."
	icon_state = "wes_solari_1"

/obj/item/fluff/sarah_calvera_1 //fniff: Sarah Calvera
	name = "old photo"
	desc = "Looks like it was made on a really old, cheap camera. Low quality. The camera shows a young hispanic looking girl with red hair wearing a white dress is standing in front of\
 an old looking wall. On the back there is a note in black marker that reads \"Sara, Siempre pens√© que eras tan linda con ese vestido. Tu hermano, Carlos.\""
	icon_state = "sarah_calvera_1"

/obj/item/fluff/angelo_wilkerson_1 //fniff: Angleo Wilkerson
	name = "fancy watch"
	desc = "An old and expensive pocket watch. Engraved on the bottom is \"Odium est Source De Dolor\". On the back, there is an engraving that does not match the bottom and looks more recent.\
 \"Angelo, If you find this, you shall never see me again. Please, for your sake, go anywhere and do anything but stay. I'm proud of you and I will always love you. Your father, Jacob Wilkerson.\"\
  Jacob Wilkerson... Wasn't he that serial killer?"
	icon_state = "angelo_wilkerson_1"

/obj/item/fluff/sarah_carbrokes_1 //gvazdas: Sarah Carbrokes
	name = "locket"
	desc = "A grey locket with a picture of a black haired man in it. The text above it reads: \"Edwin Carbrokes\"."
	icon_state = "sarah_carbrokes_1"

/obj/item/fluff/ethan_way_1 //whitellama: Ethan Way
	name = "old ID"
	desc = "A scratched and worn identification card; it appears too damaged to inferface with any technology. You can almost make out \"Tom Cabinet\" in the smeared ink."
	icon_state = "ethan_way_1"

/obj/item/fluff/val_mcneil_1 //silentthunder: Val McNeil
	name = "rosary pendant"
	desc = "A cross on a ring of beads, has McNeil etched onto the back."
	icon_state = "val_mcneil_1"

/obj/item/fluff/steve_johnson_1 //thebreadbocks: Steve Johnson
	name = "bottle of hair dye"
	desc = "A bottle of pink hair dye. So that's how he gets his beard so pink..."
	icon_state = "steve_johnson_1"
	item_state = "steve_johnson_1"

/obj/item/fluff/david_fanning_1 //sicktrigger: David Fanning
	name = "golden scalpel"
	desc = "A fine surgical cutting tool covered in thin gold leaf. Does not seem able to cut anything."
	icon_state = "david_fanning_1"
	item_state = "david_fanning_1"

/obj/item/fluff/john_mckeever_1 //kirbyelder: John McKeever
	name = "Suspicious Paper"
	desc = "A piece of paper reading: Smash = 1/3 Leaf Juice, 1/3 Tricker, 1/3 Aajkli Extract"
	icon_state = "paper"
	item_state = "paper"

/obj/item/fluff/maurice_bedford_1
	name = "Monogrammed Handkerchief"
	desc = "A neatly folded handkerchief embroidered with a 'M'."
	icon_state = "maurice_bedford_1"

/obj/item/weapon/book/fluff/johnathan_falcian_1
	name = "sketchbook"
	desc = "A small, well-used sketchbook."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "johnathan_notebook"
	dat = "In the notebook there are numerous drawings of various crew-mates, locations, and scenes on the ship. They are of fairly good quality."
	author = "Johnathan Falcian"
	title = "Falcian's sketchbook"

//////////////////////////////////
////////// Usable Items //////////
//////////////////////////////////

/obj/item/weapon/folder/blue/fluff/matthew_riebhardt //Matthew Riebhardt - ZekeSulastin
	name = "academic journal"
	desc = "An academic journal, seemingly pertaining to medical genetics. This issue is for the second quarter of 2557. Paper flags demarcate some articles the owner finds interesting."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "matthewriebhardt"

/obj/item/weapon/pen/fluff/multi //spaceman96: Trenna Seber
	name = "multicolor pen"
	desc = "It's a cool looking pen. Lots of colors!"

/obj/item/weapon/pen/fluff/fancypen //orangebottle: Lillian Levett, Lilliana Reade
	name = "fancy pen"
	desc = "A fancy metal pen. It uses blue ink. An inscription on one side reads,\"L.L. - L.R.\""
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "fancypen"

/obj/item/weapon/pen/fluff/eugene_bissegger_1 //metamorp: eugene bisseger
	name = "Gilded Pen"
	desc = "A golden pen that is gilded with a meager amount of gold material. The word 'NanoTrasen' is etched on the clip of the pen."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "eugene_pen"

/obj/item/weapon/pen/fluff/fountainpen //paththegreat: Eli Stevens
	name = "Engraved Fountain Pen"
	desc = "An expensive looking pen with the initials E.S. engraved into the side."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "fountainpen"

/obj/item/fluff/victor_kaminsky_1 //chinsky: Victor Kaminski
	name = "golden detective's badge"
	desc = "NanoTrasen Security Department detective's badge, made from gold. Badge number is 564."
	icon_state = "victor_kaminsky_1"

/obj/item/fluff/victor_kaminsky_1/attack_self(mob/user as mob)
	for(var/mob/O in viewers(user, null))
		O.show_message(text("[] shows you: \icon[] [].", user, src, src.name), 1)
	src.add_fingerprint(user)

/obj/item/fluff/ana_issek_2 //suethecake: Ana Issek
	name = "Faded Badge"
	desc = "A faded badge, backed with leather, that reads 'NT Security Force' across the front. It bears the emblem of the Forensic division."
	icon_state = "ana_badge"
	item_state = "ana_badge"
	_color = "ana_badge"

/obj/item/fluff/ana_issek_2/attack_self(mob/user as mob)
	if(isliving(user))
		user.visible_message("\red [user] flashes their golden security badge.\nIt reads: Ana Issek, NT Security.","\red You display the faded bage.\nIt reads: Ana Issek, NT Security.")

/obj/item/fluff/ana_issek_2/attack(mob/living/carbon/human/M, mob/living/user)
	if(isliving(user))
		user.visible_message("\red [user] invades [M]'s personal space, thrusting [src] into their face insistently.","\red You invade [M]'s personal space, thrusting [src] into their face insistently. You are the law.")

/obj/item/weapon/soap/fluff/azare_siraj_1 //mister fox: Azare Siraj
	name = "S'randarr's Tongue Leaf"
	desc = "A waxy, scentless leaf."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "siraj_tongueleaf"
	item_state = "siraj_tongueleaf"

/obj/item/weapon/clipboard/fluff/smallnote //lexusjjss: Lexus Langg, Zachary Tomlinson
	name = "small notebook"
	desc = "A generic small spiral notebook that flips upwards."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "smallnotetext"
	item_state = "smallnotetext"

/obj/item/weapon/storage/fluff/maye_daye_1 //morrinn: Maye Day
	name = "pristine lunchbox"
	desc = "A pristine stainless steel lunch box. The initials M.D. are engraved on the inside of the lid."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "maye_daye_1"

/obj/item/weapon/reagent_containers/food/drinks/flask/fluff/william_hackett
	name = "handmade flask"
	desc = "A wooden flask with a silver lid and bottom. It has a matte, dark blue paint on it with the initials \"W.H.\" etched in black."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "williamhackett"

/obj/item/weapon/storage/firstaid/fluff/asus_rose //Kerbal22 - Asus Rose
	name = "rugged medkit"
	desc = "A dinged up medkit, it seems to have seen quite a bit of use."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "asusrose"

/obj/item/weapon/reagent_containers/food/drinks/flask/fluff/johann_erzatz_1 //leonheart11:  Johann Erzatz
	name = "vintage thermos"
	desc = "An older thermos with a faint shine."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "johann_erzatz_1"
	volume = 50

/obj/item/weapon/lighter/zippo/fluff/li_matsuda_1 //mangled: Li Matsuda
	name = "blue zippo lighter"
	desc = "A zippo lighter made of some blue metal."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "bluezippo"
	icon_on = "bluezippoon"
	icon_off = "bluezippo"

/obj/item/weapon/lighter/zippo/fluff/michael_guess_1 //Dragor23: Michael Guess
	name = "engraved lighter"
	desc = "A golden lighter, engraved with some ornaments and a G."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "guessip"
	icon_on = "guessipon"
	icon_off = "guessip"

/obj/item/weapon/lighter/zippo/fluff/riley_rohtin_1 //rawrtaicho: Riley Rohtin
	name = "Riley's black zippo"
	desc = "A black zippo lighter, which holds some form of sentimental value."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "blackzippo"
	icon_on = "blackzippoon"
	icon_off = "blackzippo"

/obj/item/weapon/lighter/zippo/fluff/fay_sullivan_1 //furohman: Fay Sullivan
	name = "Graduation Lighter"
	desc = "A silver engraved lighter with 41 on one side and Tharsis University on the other. The lid reads Fay Sullivan, Cybernetic Engineering, 2541"
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "gradzippo"
	icon_on = "gradzippoon"
	icon_off = "gradzippo"

/obj/item/weapon/lighter/zippo/fluff/executivekill_1 //executivekill: Hunter Duke
	name = "Gonzo Fist zippo"
	desc = "A Zippo lighter with the iconic Gonzo Fist on a matte black finish."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "gonzozippo"
	icon_on = "gonzozippoon"
	icon_off = "gonzozippo"

/obj/item/weapon/lighter/zippo/fluff/naples_1 //naples: Russell Vierson
	name = "Engraved zippo"
	desc = "A intricately engraved Zippo lighter."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "engravedzippo"
	icon_on = "engravedzippoon"
	icon_off = "engravedzippo"

/obj/item/weapon/lighter/zippo/fluff/nt_rep
	name = "gold engraved zippo"
	desc = "An engraved golden Zippo lighter with the letters NT on it."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "zippo_nt_off"
	icon_on = "zippo_nt_on"
	icon_off = "zippo_nt_off"

/obj/item/weapon/lighter/zippo/fluff/purple
	name = "purple engraved zippo"
	desc = "All craftsspacemanship is of the highest quality. It is encrusted with refined plasma sheets. On the item is an image of a dwarf and the words 'Strike the Earth!' etched onto the side."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "purple_zippo_off"
	icon_on = "purple_zippo_on"
	icon_off = "purple_zippo_off"


/obj/item/weapon/fluff/cado_keppel_1 //sparklysheep: Cado Keppel
	name = "purple comb"
	desc = "A pristine purple comb made from flexible plastic. It has a small K etched into its side."
	w_class = 1.0
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "purplecomb"
	item_state = "purplecomb"

	attack_self(mob/user)
		if(user.r_hand == src || user.l_hand == src)
			for(var/mob/O in viewers(user, null))
				O.show_message(text("\red [] uses [] to comb their hair with incredible style and sophistication. What a [].", user, src, user.gender == FEMALE ? "lady" : "guy"), 1)
		return

/obj/item/weapon/fluff/hugo_cinderbacth_1 //thatoneguy: Hugo Cinderbatch
	name = "Old Cane"
	desc = "An old brown cane made from wood. It has a a large, itallicized H on it's handle."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "special_cane"

/obj/item/device/camera/fluff/orange //chinsky: Summer Springfield
	name = "orange camera"
	icon = 'icons/obj/custom_items.dmi'
	desc = "A modified detective's camera, painted in bright orange. On the back you see \"Have fun\" written in small accurate letters with something black."
	icon_state = "orangecamera"
	icon_on = "orangecamera"
	icon_off = "camera_off"
	pictures_left = 30

/obj/item/device/camera/fluff/oldcamera //magmaram: Maria Crash
	name = "Old Camera"
	icon = 'icons/obj/custom_items.dmi'
	desc = "An old, slightly beat-up digital camera, with a cheap photo printer taped on. It's a nice shade of blue."
	icon_state = "oldcamera"
	icon_on = "oldcamera"
	icon_off = "oldcamera_off"
	pictures_left = 30

/obj/item/weapon/id_wallet/fluff/reese_mackenzie  //Reese MacKenzie - ThoseDernSquirrels

	name = "ID wallet"
	desc = "A wallet made of black leather, holding an ID and a gold badge that reads 'NT.' The ID has a small picture of a man, with the caption Reese James MacKenzie, with other pieces of information to the right of the picture."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "reesemackenzie"

/obj/item/weapon/card/id/fluff/lifetime	//fastler: Fastler Greay; it seemed like something multiple people would have
	name = "Lifetime ID Card"
	desc = "A modified ID card given only to those people who have devoted their lives to the better interests of NanoTrasen. It sparkles blue."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "lifetimeid"

/obj/item/weapon/reagent_containers/food/drinks/flask/fluff/shinyflask //lexusjjss: Lexus Langg & Zachary Tomlinson
	name = "shiny flask"
	desc = "A shiny metal flask. It appears to have a Greek symbol inscribed on it."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "shinyflask"
	volume = 50

/obj/item/weapon/reagent_containers/food/drinks/flask/fluff/lithiumflask //mcgulliver: Wox Derax
	name = "Lithium Flask"
	desc = "A flask with a Lithium Atom symbol on it."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "lithiumflask"
	volume = 50

/obj/item/weapon/reagent_containers/glass/beaker/large/fluff/nashida_bishara_1 //rukral:Nashida Bisha'ra
	name = "Nashida's Etched Beaker"
	desc = "The message: 'Please do not be removing this beaker from the chemistry lab. If lost, return to Nashida Bisha'ra' can be seen etched into the side of this 100 unit beaker."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "beakerlarge"
	g_amt = 5000
	volume = 100

/obj/item/weapon/reagent_containers/glass/beaker/fluff/eleanor_stone //Rkf45: Eleanor Stone
	name = "teapot"
	desc = "An elegant teapot. The engraving on the bottom reads 'ENS'"
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "eleanorstone"
	item_state = "eleanorstone"

	volume = 150
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30,50,150)

/obj/item/weapon/storage/pill_bottle/fluff/listermedbottle //compactninja: Lister Black
	name = "Pill bottle (anti-depressants)"
	desc = "Contains pills used to deal with depression. They appear to be prescribed to Lister Black"
	New()
		..()
		new /obj/item/weapon/reagent_containers/pill/fluff/listermed( src )
		new /obj/item/weapon/reagent_containers/pill/fluff/listermed( src )
		new /obj/item/weapon/reagent_containers/pill/fluff/listermed( src )
		new /obj/item/weapon/reagent_containers/pill/fluff/listermed( src )
		new /obj/item/weapon/reagent_containers/pill/fluff/listermed( src )
		new /obj/item/weapon/reagent_containers/pill/fluff/listermed( src )
		new /obj/item/weapon/reagent_containers/pill/fluff/listermed( src )

/obj/item/weapon/reagent_containers/pill/fluff/listermed
	name = "anti-depressant pill"
	desc = "Used to deal with depression."
	icon_state = "pill9"
	New()
		..()
		reagents.add_reagent("stoxin", 5)
		reagents.add_reagent("sugar", 10)
		reagents.add_reagent("ethanol", 5)

/obj/item/clothing/mask/fluff/electriccig //CubeJackal: Barry Sharke
	name = "Electronic cigarette"
	desc = "An electronic cigarette. Most of the relief of a real cigarette with none of the side effects. Often used by smokers who are trying to quit the habit."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "cigon"
	throw_speed = 0.5
	item_state = "ciglit"
	w_class = 1
	body_parts_covered = null
	flags = FPRINT|TABLEPASS

//Strange penlight, Nerezza: Asher Spock

/obj/item/weapon/reagent_containers/hypospray/fluff/asher_spock_1
	name = "strange penlight"
	desc = "Besides the coloring, this penlight looks rather normal and innocent. However, you get a nagging feeling whenever you see it..."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "asher_spock_1"
	amount_per_transfer_from_this = 5
	volume = 15

/obj/item/weapon/reagent_containers/hypospray/fluff/asher_spock_1/New()
	..()
	reagents.remove_reagent("tricordrazine", 30)
	reagents.add_reagent("oxycodone", 15)
	update_icon()
	return

/obj/item/weapon/reagent_containers/hypospray/fluff/asher_spock_1/attack_self(mob/user as mob)
	user << "\blue You click \the [src] but get no reaction. Must be dead."

/obj/item/weapon/reagent_containers/hypospray/fluff/asher_spock_1/attack(mob/M as mob, mob/user as mob)
	if (user.ckey != "nerezza") //Because this can end up in the wrong hands, let's make it useless for them!
		user << "\blue You click \the [src] but get no reaction. Must be dead."
		return
	if(!reagents.total_volume)
		user << "\red \The [src] is empty."
		return
	if (!( istype(M, /mob) ))
		return
	if (reagents.total_volume)
		if (M == user && user.ckey == "nerezza") //Make sure this is being used by the right person, for the right reason (self injection)
			visible_message("\blue [user] presses their \
				penlight against their skin, quickly clicking the button once.", \
				"\blue You press the disguised autoinjector against your skin and click the button. There's a sharp pain at the injection site that rapidly fades.", \
				"You hear a rustle as someone moves nearby, then a sharp click.")
		if (M != user && user.ckey == "nerezza") //Woah now, you better be careful partner
			user << "\blue You don't want to contaminate the autoinjector."
			return
		src.reagents.reaction(M, INGEST)
		if(M.reagents)
			var/trans = reagents.trans_to(M, amount_per_transfer_from_this)
			user << "\blue [trans] units injected. [reagents.total_volume] units remaining in \the [src]."
	return

/obj/item/weapon/reagent_containers/hypospray/fluff/asher_spock_1/examine(mob/user as mob)
	..()
	if(user.ckey != "nerezza") return //Only the owner knows how to examine the contents.
	if(reagents && reagents.reagent_list.len)
		for(var/datum/reagent/R in reagents.reagent_list)
			usr << "\blue You examine the penlight closely and see that it has [R.volume] units of [R.name] stored."
	else
		usr << "\blue You examine the penlight closely and see that it is currently empty."

//End strange penlight

/obj/item/weapon/card/id/fluff/asher_spock_2 //Nerezza: Asher Spock
	name = "Odysses Specialist ID card"
	desc = "A special identification card with a red cross signifying an emergency physician has specialised in Odysseus operations and maintenance.\nIt grants the owner recharge bay access."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "odysseus_spec_id"

/obj/item/weapon/clipboard/fluff/mcreary_journal //sirribbot: James McReary
	name = "McReary's journal"
	desc = "A journal with a warning sticker on the front cover. The initials \"J.M.\" are written on the back."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "mcreary_journal"
	item_state = "mcreary_journal"

/obj/item/device/flashlight/fluff/thejesster14_1 //thejesster14: Rosa Wolff
	name = "old red flashlight"
	desc = "A very old, childlike flashlight."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "wolfflight"
	item_state = "wolfflight"

/obj/item/weapon/crowbar/fluff/zelda_creedy_1 //daaneesh: Zelda Creedy
	name = "Zelda's Crowbar"
	desc = "A pink crow bar that has an engraving that reads, 'To Zelda. Love always, Dawn'"
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "zeldacrowbar"
	item_state = "crowbar"

////// Ripley customisation kit - Butchery Royce - MayeDay

/obj/item/weapon/paintkit/fluff/butcher_royce_1
	name = "Ripley customisation kit"
	desc = "A kit containing all the needed tools and parts to turn an APLU Ripley into a Titan's Fist worker mech."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "royce_kit"

	new_name = "APLU \"Titan's Fist\""
	new_desc = "This ordinary mining Ripley has been customized to look like a unit of the Titans Fist."
	new_icon = "titan"
	allowed_types = list("ripley","firefighter")

////// Ripley customisation kit - Sven Fjeltson - Mordeth221

/obj/item/weapon/paintkit/fluff/sven_fjeltson_1
	name = "Mercenary APLU kit"
	desc = "A kit containing all the needed tools and parts to turn an APLU Ripley into an old Mercenaries APLU."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "sven_kit"

	new_name = "APLU \"Strike the Earth!\""
	new_desc = "Looks like an over worked, under maintained Ripley with some horrific damage."
	new_icon = "earth"
	allowed_types = list("ripley","firefighter")

//////////////////////////////////
//////////// Clothing ////////////
//////////////////////////////////

//////////// Gloves ////////////

/obj/item/clothing/gloves/fluff/murad_hassim_1
	name = "Tajaran Surgical Gloves"
	desc = "Reinforced sterile gloves custom tailored to comfortably accommodate Tajaran claws."
	icon_state = "latex"
	item_state = "lgloves"
	siemens_coefficient = 0.30
	permeability_coefficient = 0.01
	_color="white"

/obj/item/clothing/gloves/fluff/walter_brooks_1 //botanistpower: Walter Brooks
	name = "mittens"
	desc = "A pair of well worn, blue mittens."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "walter_brooks_1"
	item_state = "bluegloves"
	_color="blue"

/obj/item/clothing/gloves/fluff/chal_appara_1 //furlucis: Chal Appara
	name = "Left Black Glove"
	desc = "The left one of a pair of black gloves. Wonder where the other one went..."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "chal_appara_1"

/obj/item/clothing/gloves/fluff/ashley_rifler_1 //Vinceluk: Ashley Rifler
	name = "Purple Glove"
	desc = "A single, purple glove. Initials A.R. are written on the inside of it."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "ashley_rifler_1"

//////////// Eye Wear ////////////

/obj/item/clothing/glasses/meson/fluff/book_berner_1 //asanadas: Book Berner
	name = "bespectacled mesonic surveyors"
	desc = "One of the older meson scanner models retrofitted to perform like its modern counterparts."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "book_berner_1"

/obj/item/clothing/glasses/fluff/uzenwa_sissra_1 //sparklysheep: Uzenwa Sissra
	name = "Scanning Goggles"
	desc = "A very oddly shaped pair of goggles with bits of wire poking out the sides. A soft humming sound emanates from it."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "uzenwa_sissra_1"

////// Medical eyepatch - Thysse Ezinwa - Jadepython
/obj/item/clothing/glasses/eyepatch/fluff/thysse_1
	name = "medical eyepatch"
	desc = "On the strap, EZINWA is written in white block letters."

////// Safety Goggles - Arjun Chopra - MindPhyre - APPROVED
/obj/item/clothing/glasses/fluff/arjun_chopra_1
	name = "safety goggles"
	desc = "A used pair of leather safety goggles."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "arjun_chopra"
	item_state = "arjun_chopra"

//////////// Hats ////////////

/obj/item/clothing/head/secsoft/fluff/swatcap //deusdactyl: James Girard
	name = "\improper SWAT hat"
	desc = "A black hat.  The inside has the words, \"Lieutenant James Girard, LPD SWAT Team Four.\""
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "swatcap"

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

/obj/item/clothing/head/helmet/greenbandana/fluff/taryn_kifer_1 //themij: Taryn Kifer
	name = "orange bandana"
	desc = "Hey, I think we're missing a hazard vest..."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "taryn_kifer_1"

/obj/item/clothing/head/fluff/edvin_telephosphor_1 //foolamancer: Edvin Telephosphor
	name = "Edvin's Hat"
	desc = "A hat specially tailored for Skrellian anatomy. It has a yellow badge on the front, with a large red 'T' inscribed on it."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "edvin_telephosphor_1"

/obj/item/clothing/head/fluff/krinnhat //Shirotyrant: Krinn Seeskale
	name = "saucepan hat"
	desc = "This hat is the shiniest shiny Krinn has ever owned."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "krinn_hat"

/obj/item/clothing/head/fluff/bruce_hachert //Stup1dg33kz: Bruce Hachert
	name = "worn hat"
	desc = "A worn-looking hat. It is slightly faded in color."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "brucehachert"

//////////// Suits ////////////

/obj/item/clothing/suit/storage/labcoat/fluff/aeneas_rinil //Robotics Labcoat - Aeneas Rinil [APPR]
	name = "Robotics labcoat"
	desc = "A labcoat with a few markings denoting it as the labcoat of roboticist."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "aeneasrinil_open"

/obj/item/clothing/suit/storage/labcoat/fluff/pink //spaceman96: Trenna Seber
	name = "pink labcoat"
	desc = "A suit that protects against minor chemical spills. Has a pink stripe down from the shoulders."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "labcoat_pink_open"

/obj/item/clothing/suit/storage/det_suit/fluff/graycoat //vinceluk: Seth Sealis
	name = "gray coat"
	desc = "Old, worn out coat. It's seen better days."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "graycoat"
	item_state = "graycoat"
	_color = "graycoat"

/obj/item/clothing/suit/storage/det_suit/fluff/leatherjack //atomicdog92: Seth Sealis
	name = "leather jacket"
	desc = "A black leather coat, popular amongst punks, greasers, and other galactic scum."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "leatherjack"
	item_state = "leatherjack"
	_color = "leatherjack"

/obj/item/clothing/suit/armor/vest/fluff/deus_blueshield //deusdactyl
	name = "blue shield security armor"
	desc = "An armored vest with the badge of a Blue Shield Security lieutenant."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "deus_blueshield"
	item_state = "deus_blueshield"

/obj/item/clothing/suit/fluff/oldscarf //Writerer2: Javaria Zara
	name = "old scarf"
	desc = "An old looking scarf, it seems to be fairly worn."
	icon = 'icons/obj/clothing/suits.dmi'
	icon_state = "mantle-unathi"
	item_state = "mantle-unathi"
	body_parts_covered = UPPER_TORSO

//////////// Uniforms ////////////

/obj/item/clothing/under/fluff/milo_hachert //Field Dress Uniform - Milo Hachert - Commissar_Drew
	name = "customs uniform"
	desc = "A uniform jacket, its buttons polished to a shine, coupled with a dark pair of trousers. 'Customs' is embroidered upon the jacketís shoulder bar."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "milohachert"
	item_state = "milohachert"
	_color = "milohachert"

/obj/item/clothing/under/fluff/jumpsuitdown //searif: Yuki Matsuda
	name = "rolled down jumpsuit"
	desc = "A rolled down jumpsuit. Great for mechanics."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "jumpsuitdown"
	item_state = "jumpsuitdown"
	_color = "jumpsuitdown"

/obj/item/clothing/under/fluff/lilith_vinous_1 //slyhidden: Lilith Vinous
	name = "casual security uniform"
	desc = "A less formal version of the traditional dark red Security uniform. It has the top button undone, rolled up sleeves and different belt."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "lilith_uniform"
	item_state = "lilith_uniform"
	_color = "lilith_uniform"

/obj/item/clothing/under/fluff/ana_issek_1 //suethecake: Ana Issek
	name = "retired uniform"
	desc = "A silken blouse paired with dark-colored slacks. It has the words 'Chief Investigator' embroidered into the shoulder bar."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "ana_uniform"
	item_state = "ana_uniform"
	_color = "ana_uniform"

/obj/item/clothing/under/fluff/olddressuniform //desiderium: Momiji Inubashiri
	name = "retired dress uniform"
	desc = "A retired Station Head of Staff uniform, phased out twenty years ago for the newer jumpsuit design, but still acceptable dress. Lovingly maintained."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "olddressuniform"
	item_state = "olddressuniform"
	_color = "olddressuniform"

/obj/item/clothing/under/rank/security/fluff/jeremy_wolf_1 //whitewolf41: Jeremy Wolf
	name = "worn officer's uniform"
	desc = "An old red security jumpsuit. Seems to have some slight modifications."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "jeremy_wolf_1"
	_color = "jeremy_wolf_1"

/obj/item/clothing/under/fluff/tian_dress //phaux: Tian Yinhu
	name = "purple dress"
	desc = "A nicely tailored purple dress made for the taller woman."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "tian_dress"
	item_state = "tian_dress"
	_color = "tian_dress"

/obj/item/clothing/under/rank/bartender/fluff/classy	//searif: Ara Al-Jazari
	name = "classy bartender uniform"
	desc = "A prim and proper uniform that looks very similar to a bartender's, the only differences being a red tie, waistcoat and a rag hanging out of the back pocket."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "ara_bar_uniform"
	item_state = "ara_bar_uniform"
	_color = "ara_bar_uniform"

/obj/item/clothing/under/fluff/callum_suit //roaper: Callum Leamus
	name = "knockoff suit"
	desc = "A knockoff of a suit commonly worn by the upper class."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "callum_suit"
	item_state = "callum_suit"
	_color = "callum_suit"

/obj/item/clothing/under/fluff/solara_light_1 //bluefishie: Solara Born-In-Light
	name = "Elaborate Purple Dress"
	desc = "An expertly tailored dress, made out of fine fabrics. The interwoven necklace appears to be made out of gold, with three complicated symbols engraved in the front."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "solara_dress"
	item_state = "solara_dress"
	_color = "solara_dress"

/obj/item/clothing/under/psysuit/fluff/isaca_sirius_1 // Xilia: Isaca Sirius
	name = "Isaca's suit"
	desc = "Black, comfortable and nicely fitting suit. Made not to hinder the wearer in any way. Made of some exotic fabric. And some strange glowing jewel at the waist. Name labels says; Property of Isaca Sirius; The Seeder."


/////// NT-SID Suit //Zuhayr: Jane Doe

/obj/item/clothing/under/fluff/jane_sidsuit
	name = "NT-SID jumpsuit"
	desc = "A NanoTrasen Synthetic Intelligence Division jumpsuit, issued to 'volunteers'. On other people it looks fine, but right here a scientist has noted: on you it looks stupid."

	icon = 'icons/obj/custom_items.dmi'
	icon_state = "jane_sid_suit"
	item_state = "jane_sid_suit"
	_color = "jane_sid_suit"
	has_sensor = 2
	sensor_mode = 3
	flags = FPRINT | TABLEPASS

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

////// Wyatt's Ex-Commander Jumpsuit - RawrTaicho
/obj/item/clothing/under/fluff/wyatt_1

	name = "ex-commander jumpsuit"
	desc = "A standard Central Command Engineering Commander jumpsuit tailored to fight the wearer tightly. It has a Medal of Service pinned onto the left side of it."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "wyatt_uniform"
	item_state = "wyatt_uniform"
	_color = "wyatt_uniform"

//////////// Masks ////////////

/*
/obj/item/clothing/mask/fluff/flagmask //searif: Tsiokeriio Tarbell
	name = "\improper First Nations facemask"
	desc = "A simple cloth rag that bears the flag of the first nations."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "flagmask"
	item_state = "flagmask"
	flags = FPRINT|TABLEPASS|MASKCOVERSMOUTH
	w_class = 2
	gas_transfer_coefficient = 0.90
*/

/obj/item/clothing/mask/mara_kilpatrick_1 //staghorn: Mara Kilpatrick
	name = "shamrock pendant"
	desc = "A silver and emerald shamrock pendant. It has the initials \"M.K.\" engraved on the back."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "mara_kilpatrick_1"
	flags = FPRINT|TABLEPASS
	w_class = 1

////// Small locket - Altair An-Nasaqan - Serithi

/obj/item/clothing/tie/fluff/altair_locket
	name = "small locket"
	desc = "A small golden locket attached to an Ii'rka-reed string. Inside the locket is a holo-picture of a female Tajaran, and an inscription writtin in Siik'mas."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "altair_locket"
	item_state = "altair_locket"
	_color = "altair_locket"
	slot_flags = 0
	flags = FPRINT|TABLEPASS
	w_class = 1
	slot_flags = SLOT_MASK

////// Silver locket - Konaa Hirano - Konaa_Hirano

/obj/item/clothing/tie/fluff/konaa_hirano
	name = "silver locket"
	desc = "This oval shaped, argentium sterling silver locket hangs on an incredibly fine, refractive string, almost thin as hair and microweaved from links to a deceptive strength, of similar material. The edges are engraved very delicately with an elegant curving design, but overall the main is unmarked and smooth to the touch, leaving room for either remaining as a stolid piece or future alterations. There is an obvious internal place for a picture or lock of some sort, but even behind that is a very thin compartment unhinged with the pinch of a thumb and forefinger."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "konaahirano"
	item_state = "konaahirano"
	_color = "konaahirano"
	slot_flags = 0
	flags = FPRINT|TABLEPASS
	w_class = 1
	slot_flags = SLOT_MASK
	var/obj/item/held //Item inside locket.

/obj/item/clothing/tie/fluff/konaa_hirano/attack_self(mob/user as mob)
	if(held)
		user << "You open [src] and [held] falls out."
		held.loc = get_turf(user)
		src.held = null

/obj/item/clothing/tie/fluff/konaa_hirano/attackby(var/obj/item/O as obj, mob/user as mob)
	if(istype(O,/obj/item/weapon/paper))
		if(held)
			usr << "[src] already has something inside it."
		else
			usr << "You slip [O] into [src]."
			user.drop_item()
			O.loc = src
			src.held = O
		return
	..()

//////  Medallion - Nasir Khayyam - Jamini

/obj/item/clothing/tie/fluff/nasir_khayyam_1
	name = "medallion"
	desc = "This silvered medallion bears the symbol of the Hadii Clan of the Tajaran."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "nasir_khayyam_1"
	flags = FPRINT|TABLEPASS
	w_class = 1
	slot_flags = SLOT_MASK


////// Medallion - Lin Chang - Roland410

/obj/item/clothing/tie/fluff/lin_chang_1
	name = "shining black medallion"
	desc = "A shiny black medallion made of something that looks like the Earth's obsidian, but it is harder than anything ever seen yet. On the front there seems to be a standing unathi chiseled in it, on the back the name of Lin Chang with the title of the Assassin Archmage."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "nasir_khayyam_1"
	flags = FPRINT|TABLEPASS
	w_class = 1
	slot_flags = SLOT_MASK

////// Emerald necklace - Ty Foster - Nega

/obj/item/clothing/mask/mara_kilpatrick_1
	name = "emerald necklace"
	desc = "A brass necklace with a green emerald placed at the end. It has a small inscription on the top of the chain, saying \'Foster\'"
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "ty_foster"
	flags = FPRINT|TABLEPASS
	w_class = 1

//////////// Shoes ////////////

/obj/item/clothing/shoes/magboots/fluff/susan_harris_1 //sniperyeti: Susan Harris
	name = "Susan's Magboots"
	desc = "A colorful pair of magboots with the name Susan Harris clearly written on the back."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "atmosmagboots0"

//////////// Sets ////////////

/*
/obj/item/clothing/suit/storage/labcoat/fluff/cdc_labcoat
	name = "\improper CDC labcoat"
	desc = "A standard-issue CDC labcoat that protects against minor chemical spills.  It has the name \"Wiles\" sewn on to the breast pocket."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "labcoat_cdc_open"
*/
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

////// Retired Patrol Outfit //desiderium: Rook Maudlin

/obj/item/clothing/suit/storage/det_suit/fluff/retpolcoat
	name = "retired colony patrolman's coat"
	desc = "A clean, black nylon windbreaker with the words \"OUTER LIGHT POLICE\" embroidered in gold-dyed thread on the back. \"RETIRED\" is tastefully embroidered below in a smaller font."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "retpolcoat"
	item_state = "retpolcoat"
	_color = "retpolcoat"

/obj/item/clothing/head/det_hat/fluff/retpolcap
	name = "retired colony patrolman's cap"
	desc = "A clean and properly creased colony police cap. The badge is shined and polished, the word \"RETIRED\" engraved professionally under the words \"OUTER LIGHT POLICE.\""
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "retpolcap"

/obj/item/clothing/under/det/fluff/retpoluniform
	name = "retired colony patrolman's uniform"
	desc = "A meticulously clean police uniform belonging to Precinct 31, Outer Light Colony. The word \"RETIRED\" is engraved tastefully and professionally in the badge below the number, 501."
	icon = 'icons/obj/custom_items.dmi'
	icon_state = "retpoluniform"
	_color = "retpoluniform"

//////////// Weapons ////////////

///// Well-used baton - Oen'g Issek - Donofnyc3

/obj/item/weapon/melee/baton/fluff/oeng_baton
	name = "well-used stun baton"
	desc = "A stun baton used for incapacitating targets; there seems to be a bunch of tally marks set into the handle."
















