/obj/item/clothing/accessory
	name = "accessory"
	desc = "If you see this contact a developer."
	icon = 'icons/obj/clothing/accessories.dmi'
	icon_state = ""
	slot_flags = ITEM_SLOT_ACCESSORY
	var/slot = ACCESSORY_SLOT_DECOR
	/// the suit the accessory may be attached to
	var/obj/item/clothing/under/has_suit = null
	/// overlay used when attached to clothing.
	var/mutable_appearance/inv_overlay
	/// Allow accessories of the same type.
	var/allow_duplicates = TRUE
	/// Icon state when attached to clothing, if null the `icon_state` value will be used
	var/attached_icon_state

/obj/item/clothing/accessory/Initialize(mapload)
	. = ..()
	inv_overlay = mutable_appearance('icons/obj/clothing/accessories_overlay.dmi', attached_icon_state || icon_state)

/obj/item/clothing/accessory/Moved(atom/OldLoc, Dir, Forced)
	. = ..()
	if(has_suit)
		has_suit.detach_accessory(src, null)

/obj/item/clothing/accessory/Destroy()
	if(has_suit)
		has_suit.detach_accessory(src, null)
	return ..()

//when user attached an accessory to S
/obj/item/clothing/accessory/proc/on_attached(obj/item/clothing/under/S, mob/user as mob)
	if(!istype(S))
		return
	has_suit = S
	loc = has_suit
	has_suit.overlays += inv_overlay
	has_suit.actions += actions

	for(var/X in actions)
		var/datum/action/A = X
		if(has_suit.is_equipped())
			var/mob/M = has_suit.loc
			A.Grant(M)

	if(islist(has_suit.armor) || isnull(has_suit.armor)) 	// This proc can run before /obj/Initialize has run for U and src,
		has_suit.armor = getArmor(arglist(has_suit.armor))	// we have to check that the armor list has been transformed into a datum before we try to call a proc on it
															// This is safe to do as /obj/Initialize only handles setting up the datum if actually needed.
	if(islist(armor) || isnull(armor))
		armor = getArmor(arglist(armor))

	has_suit.armor = has_suit.armor.attachArmor(armor)

	if(user)
		to_chat(user, "<span class='notice'>You attach [src] to [has_suit].</span>")
	src.add_fingerprint(user)

/obj/item/clothing/accessory/proc/on_removed(mob/user)
	if(!has_suit)
		return
	has_suit.overlays -= inv_overlay
	has_suit.actions -= actions

	for(var/X in actions)
		var/datum/action/A = X
		if(ismob(has_suit.loc))
			var/mob/M = has_suit.loc
			A.Remove(M)

	has_suit.armor = has_suit.armor.detachArmor(armor)

	has_suit = null
	if(user)
		user.put_in_hands(src)
		add_fingerprint(user)

/obj/item/clothing/accessory/attack__legacy__attackchain(mob/living/carbon/human/H, mob/living/user)
	// This code lets you put accessories on other people by attacking their sprite with the accessory
	if(istype(H) && !ismonkeybasic(H)) //Monkeys are a snowflake because you can't remove accessories once added
		if(H.wear_suit && H.wear_suit.flags_inv & HIDEJUMPSUIT)
			to_chat(user, "[H]'s body is covered, and you cannot attach \the [src].")
			return TRUE
		var/obj/item/clothing/under/U = H.w_uniform
		if(istype(U))
			if(user == H)
				U.attach_accessory(src, user, TRUE)
				return
			user.visible_message("<span class='notice'>[user] is putting a [src.name] on [H]'s [U.name]!</span>", "<span class='notice'>You begin to put a [src.name] on [H]'s [U.name]...</span>")
			if(do_after(user, 4 SECONDS, target = H) && H.w_uniform == U)
				if(U.attach_accessory(src, user, TRUE))
					user.visible_message("<span class='notice'>[user] puts a [src.name] on [H]'s [U.name]!</span>", "<span class='notice'>You finish putting a [src.name] on [H]'s [U.name].</span>")
					after_successful_nonself_attach(H, user)
		else
			to_chat(user, "[H] is not wearing anything to attach \the [src] to.")
		return TRUE
	return ..()

/obj/item/clothing/accessory/proc/after_successful_nonself_attach(mob/living/carbon/human/H, mob/living/user)
	return

//default attackby behaviour
/obj/item/clothing/accessory/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	..()

//default attack_hand behaviour
/obj/item/clothing/accessory/attack_hand(mob/user as mob)
	if(has_suit)
		return	//we aren't an object on the ground so don't call parent
	..()

/obj/item/clothing/accessory/proc/attached_unequip(mob/user) // If we need to do something special when clothing is removed from the user
	return

/obj/item/clothing/accessory/proc/attached_equip(mob/user) // If we need to do something special when clothing is removed from the user
	return

/// No overlay
/obj/item/clothing/accessory/waistcoat
	name = "waistcoat"
	desc = "For some classy, murderous fun."
	icon_state = "waistcoat"
	sprite_sheets = list("Vox" = 'icons/mob/clothing/species/vox/suit.dmi')

//Medals
/obj/item/clothing/accessory/medal
	name = "bronze medal"
	desc = "A bronze medal."
	icon_state = "bronze"
	materials = list(MAT_METAL=1000)
	resistance_flags = FIRE_PROOF
	/// The channel we will announce on when we are rewarded to someone
	var/channel
	/// Will we try to announce, toggled by using in hand
	var/try_announce = TRUE

/obj/item/clothing/accessory/medal/examine(mob/user)
	. = ..()
	if(channel)
		. += "<span class='notice'>The tiny radio inside seems to be [try_announce ? "active" : "inactive"].</span>"

/obj/item/clothing/accessory/medal/attack_self__legacy__attackchain(mob/user)
	. = ..()
	if(channel)
		try_announce = !try_announce
		to_chat(user, "<span class='notice'>You silently [try_announce ? "enable" : "disable"] the radio in [src].</span>")

/obj/item/clothing/accessory/medal/after_successful_nonself_attach(mob/living/carbon/human/H, mob/living/user)
	if(!channel || !try_announce)
		return
	if(!is_station_level(user.z))
		return
	GLOB.global_announcer.autosay("[H] has been rewarded [src] by [user]!", "Medal Announcer", channel, src)
	channel = null

// GOLD (awarded by centcom)
/obj/item/clothing/accessory/medal/gold
	name = "gold medal"
	desc = "A prestigious golden medal."
	icon_state = "gold"
	materials = list(MAT_GOLD=1000)
	channel = "Common"

/obj/item/clothing/accessory/medal/gold/captain
	name = "medal of captaincy"
	desc = "A golden medal awarded exclusively to those promoted to the rank of captain. It signifies the codified responsibilities of a captain to Nanotrasen, and their undisputable authority over their crew."
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	channel = null // captains medal is special :)

/obj/item/clothing/accessory/medal/gold/captain/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/high_value_item)

/obj/item/clothing/accessory/medal/gold/heroism
	name = "medal of exceptional heroism"
	desc = "An extremely rare golden medal awarded only by CentComm. To receive such a medal is the highest honor and as such, very few exist."
	icon_state = "ion"

// SILVER (awarded by Captain)

/obj/item/clothing/accessory/medal/silver
	name = "silver medal"
	desc = "A silver medal."
	icon_state = "silver"
	materials = list(MAT_SILVER=1000)
	channel = "Command"

/obj/item/clothing/accessory/medal/silver/valor
	name = "medal of valor"
	desc = "An award issued by Captains to crew members whose exceptional performance and service to the station has been commended by the station's top leadership."
	channel = "Common"

/obj/item/clothing/accessory/medal/silver/leadership
	name = "medal of command"
	desc = "An award issued by Captains to heads of department who do an excellent job managing their department. Made of pure silver."


// BRONZE (awarded by heads of department, except for the bronze heart and recruiter medals)



/obj/item/clothing/accessory/medal/security
	name = "robust security medal"
	desc = "An award issued by the HoS to security staff who excel at upholding the law."
	channel = "Security"

/obj/item/clothing/accessory/medal/science
	name = "smart science medal"
	desc = "An award issued by the RD to science staff who advance the frontiers of knowledge."
	channel = "Science"

/obj/item/clothing/accessory/medal/engineering
	name = "excellent engineering medal"
	desc = "An award issued by the CE to engineering staff whose dedication keep the station running at its best."
	channel = "Engineering"

/obj/item/clothing/accessory/medal/service
	name = "superior service medal"
	desc = "An award issued by the HoP to service staff who go above and beyond."
	channel = "Service"

/obj/item/clothing/accessory/medal/medical
	name = "magnificient medical medal"
	desc = "An award issued by the CMO to medical staff who excel at saving lives."
	channel = "Medical"

/obj/item/clothing/accessory/medal/legal
	name = "meritous legal medal"
	desc = "An award issued by the Magistrate to legal staff who uphold the rule of law."
	channel = "Procedure"

/obj/item/clothing/accessory/medal/supply
	name = "stable supply medal"
	desc = "An award issued by the Quartermaster to supply staff dedicated to being effective."
	channel = "Supply"

/// Prize for the NT Recruiter emagged arcade
/obj/item/clothing/accessory/medal/recruiter
	name = "nanotrasen recruiter medal"
	desc = "A prize for those who completed the company's most difficult training, use it to earn the respect of everyone in human resources."

/obj/item/clothing/accessory/medal/heart
	name = "bronze heart medal"
	desc = "A rarely-awarded medal for those who sacrifice themselves in the line of duty to save their fellow crew."
	icon_state = "bronze_heart"
	channel = "Common"

// Plasma, from NT research departments. For now, used by the HRD-MDE project for the moderate 2 fauna, drake and hierophant.

/obj/item/clothing/accessory/medal/plasma
	name = "plasma medal"
	desc = "An eccentric medal made of plasma."
	icon_state = "plasma"
	materials = list(MAT_PLASMA = 1000)
	cares_about_temperature = TRUE

/obj/item/clothing/accessory/medal/plasma/temperature_expose(temperature, volume)
	..()
	if(temperature > T0C + 200)
		burn_up()

/obj/item/clothing/accessory/medal/plasma/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay)
	. = ..()
	burn_up()

/obj/item/clothing/accessory/medal/plasma/proc/burn_up()
	var/turf/simulated/T = get_turf(src)
	if(istype(T))
		T.atmos_spawn_air(LINDA_SPAWN_HEAT | LINDA_SPAWN_TOXINS | LINDA_SPAWN_OXYGEN, 10) //Technically twice as much plasma as it should spawn but a little more never hurt anyone.
	visible_message("<span class='warning'>[src] bursts into flame!</span>")
	qdel(src)

// Alloy, for the vetus speculator, or abductors I guess.

/obj/item/clothing/accessory/medal/alloy
	name = "alloy medal"
	desc = "An eccentric medal made of some strange alloy."
	icon_state = "alloy"
	materials = list(MAT_METAL = 500, MAT_PLASMA = 500)

// Mostly mining medals past here

/obj/item/clothing/accessory/medal/gold/bubblegum
	name = "bubblegum HRD-MDE award"
	desc = "An award which represents magnificant contributions to the HRD-MDE project in the form of analysing Bubblegum, and the related blood space."
	channel = null

/// Kill every hardmode boss. In a shift. Good luck.
/obj/item/clothing/accessory/medal/gold/heroism/hardmode_full
	name = "medal of incredible dedication"
	desc = "An extremely rare golden medal awarded only by CentComm. This medal was issued for miners who went above and beyond for the HRD-MDE project. Engraved on it is the phrase <i>'mori quam foedari'...</i>"
	channel = null

/obj/item/clothing/accessory/medal/silver/colossus
	name = "colossus HRD-MDE award"
	desc = "An award which represents major contributions to the HRD-MDE project in the form of analysing a colossus."
	channel = null

/obj/item/clothing/accessory/medal/silver/legion
	name = "legion HRD-MDE award"
	desc = "An award which represents major contributions to the HRD-MDE project in the form of analysing the Legion."
	channel = null

/obj/item/clothing/accessory/medal/blood_drunk
	name = "blood drunk HRD-MDE award"
	desc = "A award which represents minor contributions to the HRD-MDE project in the form of analysing the blood drunk miner."

/obj/item/clothing/accessory/medal/plasma/hierophant
	name = "hierophant HRD-MDE award"
	desc = "An award which represents moderate contributions to the HRD-MDE project in the form of analysing the Hierophant."

/obj/item/clothing/accessory/medal/plasma/ash_drake
	name = "ash drake HRD-MDE award"
	desc = "An award which represents moderate contributions to the HRD-MDE project in the form of analysing an ash drake."

/obj/item/clothing/accessory/medal/alloy/vetus
	name = "vetus speculator HRD-MDE award"
	desc = "An award which represents major contributions to the HRD-MDE project in the form of analysing the Vetus Speculator."

/*
	Holobadges are worn on the belt or neck, and can be used to show that the holder is an authorized
	Security agent - the user details can be imprinted on the badge with a Security-access ID card,
	or they can be emagged to accept any ID for use in disguises.
*/

/obj/item/clothing/accessory/holobadge
	name = "holobadge"
	desc = "This glowing blue badge marks the holder as THE LAW."
	icon_state = "holobadge"
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_ACCESSORY

	var/stored_name = null

/obj/item/clothing/accessory/holobadge/cord
	icon_state = "holobadge-cord"

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/neck.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/neck.dmi',
		"Kidan" = 'icons/mob/clothing/species/kidan/neck.dmi',
	)

/obj/item/clothing/accessory/holobadge/attack_self__legacy__attackchain(mob/user)
	if(!stored_name)
		to_chat(user, "Waving around a badge before swiping an ID would be pretty pointless.")
		return
	if(isliving(user))
		user.visible_message("<span class='warning'>[user] displays [user.p_their()] Nanotrasen Internal Security Legal Authorization Badge.\nIt reads: [stored_name], NT Security.</span>",
		"<span class='warning'>You display your Nanotrasen Internal Security Legal Authorization Badge.\nIt reads: [stored_name], NT Security.</span>")

/obj/item/clothing/accessory/holobadge/attackby__legacy__attackchain(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/card/id) || istype(I, /obj/item/pda))

		var/obj/item/card/id/id_card = null

		if(istype(I, /obj/item/card/id))
			id_card = I
		else
			var/obj/item/pda/pda = I
			id_card = pda.id

		if((ACCESS_SEC_DOORS in id_card.access) || emagged)
			to_chat(user, "<span class='notice'>You imprint your ID details onto the badge.</span>")
			stored_name = id_card.registered_name
			name = "holobadge ([stored_name])"
			desc = "This glowing blue badge marks [stored_name] as THE LAW."
		else
			to_chat(user, "<span class='warning'>[src] rejects your insufficient access rights.</span>")
		return
	..()

/obj/item/clothing/accessory/holobadge/emag_act(mob/user)
	if(emagged)
		to_chat(user, "<span class='warning'>[src] is already cracked.</span>")
	else
		emagged = TRUE
		to_chat(user, "<span class='warning'>You swipe the card and crack the holobadge security checks.</span>")
		return TRUE

/obj/item/clothing/accessory/holobadge/attack__legacy__attackchain(mob/living/carbon/human/H, mob/living/user)
	if(H != user)
		user.visible_message("<span class='warning'>[user] invades [H]'s personal space, thrusting [src] into [H.p_their()] face insistently.</span>",
		"<span class='warning'>You invade [H]'s personal space, thrusting [src] into [H.p_their()] face insistently. You are THE LAW!</span>")
		return
	..()

//////////////
//OBJECTION!//
//////////////

/obj/item/clothing/accessory/legal_badge
	name = "magistrate's badge"
	desc = "Fills you with the conviction of JUSTICE. Display your mastery of Space Law to the world."
	icon_state = "legal_badge"
	var/cached_bubble_icon = null
	var/what_you_are = "THE LAW"

/obj/item/clothing/accessory/legal_badge/attack_self__legacy__attackchain(mob/user)
	if(prob(1))
		user.say("The testimony contradicts the evidence!")
	user.visible_message("<span class='notice'>[user] shows [user.p_their()] [name].</span>", "<span class='notice'>You show your [name].</span>")

/obj/item/clothing/accessory/legal_badge/attack__legacy__attackchain(mob/living/carbon/human/H, mob/living/user)
	if(H != user)
		user.visible_message("<span class='warning'>[user] invades [H]'s personal space, thrusting [src] into [H.p_their()] face insistently.</span>",
		"<span class='warning'>You invade [H]'s personal space, thrusting [src] into [H.p_their()] face insistently. You are [what_you_are]!</span>")
		return
	..()

/obj/item/clothing/accessory/legal_badge/on_attached(obj/item/clothing/under/S, mob/user)
	..()
	if(has_suit && ismob(has_suit.loc))
		var/mob/M = has_suit.loc
		cached_bubble_icon = M.bubble_icon
		M.bubble_icon = "legal"

/obj/item/clothing/accessory/legal_badge/on_removed(mob/user)
	if(has_suit && ismob(has_suit.loc))
		var/mob/M = has_suit.loc
		M.bubble_icon = cached_bubble_icon
	..()

/obj/item/clothing/accessory/legal_badge/iaa
	name = "internal affairs badge"
	desc = "Marks you as an expert of Standard Operating Procedure, and as a soul-crushing paper pusher."
	what_you_are = "HUMAN RESOURCES"

/obj/item/clothing/accessory/skullcodpiece
	name = "skull codpiece"
	desc = "A skull shaped ornament, intended to protect the important things in life."
	icon_state = "skull"
	armor = list(MELEE = 5, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 10, RAD = 5, FIRE = 0, ACID = 15)
	allow_duplicates = FALSE

/obj/item/clothing/accessory/talisman
	name = "bone talisman"
	desc = "A hunter's talisman, some say the old gods smile on those who wear it."
	icon_state = "talisman"
	armor = list(MELEE = 5, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 10, RAD = 5, FIRE = 0, ACID = 15)
	allow_duplicates = FALSE

//Cowboy Shirts
/obj/item/clothing/accessory/cowboyshirt
	name = "black cowboy shirt"
	desc = "For a real western look. Looks like it can clip on to a uniform."
	icon_state = "cowboyshirt"
	sprite_sheets = list("Vox" = 'icons/mob/clothing/species/vox/suit.dmi')

/obj/item/clothing/accessory/cowboyshirt/short_sleeved
	name = "shortsleeved black cowboy shirt"
	desc = "For when it's a hot day in the west. Looks like it can clip on to a uniform."
	icon_state = "cowboyshirt_s"
	sprite_sheets = list("Vox" = 'icons/mob/clothing/species/vox/suit.dmi')

/obj/item/clothing/accessory/cowboyshirt/white
	name = "white cowboy shirt"
	desc = "For the rancher in us all. Looks like it can clip on to a uniform."
	icon_state = "cowboyshirt_white"
	sprite_sheets = list("Vox" = 'icons/mob/clothing/species/vox/suit.dmi')

/obj/item/clothing/accessory/cowboyshirt/white/short_sleeved
	name = "short sleeved white cowboy shirt"
	desc = "Best for midday cattle tending. Looks like it can clip on to a uniform."
	icon_state = "cowboyshirt_whites"
	sprite_sheets = list("Vox" = 'icons/mob/clothing/species/vox/suit.dmi')

/obj/item/clothing/accessory/cowboyshirt/pink
	name = "pink cowboy shirt"
	desc = "For only the manliest of men, or girliest of girls. Looks like it can clip on to a uniform."
	icon_state = "cowboyshirt_pink"
	sprite_sheets = list("Vox" = 'icons/mob/clothing/species/vox/suit.dmi')

/obj/item/clothing/accessory/cowboyshirt/pink/short_sleeved
	name = "short sleeved pink cowboy shirt"
	desc = "For a real buckle bunny. Looks like it can clip on to a uniform."
	icon_state = "cowboyshirt_pinks"
	sprite_sheets = list("Vox" = 'icons/mob/clothing/species/vox/suit.dmi')

/obj/item/clothing/accessory/cowboyshirt/navy
	name = "navy cowboy shirt"
	desc = "Now yer a real cowboy. Looks like it can clip on to a uniform."
	icon_state = "cowboyshirt_navy"
	sprite_sheets = list("Vox" = 'icons/mob/clothing/species/vox/suit.dmi')

/obj/item/clothing/accessory/cowboyshirt/navy/short_sleeved
	name = "short sleeved navy cowboy shirt"
	desc = "Sometimes ya need to roll up your sleeves. Looks like it can clip on to a uniform."
	icon_state = "cowboyshirt_navys"
	sprite_sheets = list("Vox" = 'icons/mob/clothing/species/vox/suit.dmi')

/obj/item/clothing/accessory/cowboyshirt/red
	name = "red cowboy shirt"
	desc = "It's high noon. Looks like it can clip on to a uniform."
	icon_state = "cowboyshirt_red"
	sprite_sheets = list("Vox" = 'icons/mob/clothing/species/vox/suit.dmi')

/obj/item/clothing/accessory/cowboyshirt/red/short_sleeved
	name = "short sleeved red cowboy shirt"
	desc = "Life on the open range is quite dangeorus, you never know what to expect. Looks like it can clip on to a uniform."
	icon_state = "cowboyshirt_reds"
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/suit.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/suit.dmi'
	)

/obj/item/clothing/accessory/corset
	name = "black corset"
	desc = "A black corset for those fancy nights out."
	icon_state = "corset"
	inhand_icon_state = "corset"

/obj/item/clothing/accessory/corset/red
	name = "red corset"
	desc = "A red corset those fancy nights out."
	icon_state = "corset_red"

/obj/item/clothing/accessory/corset/blue
	name = "blue corset"
	desc = "A blue corset for those fancy nights out."
	icon_state = "corset_blue"

//Pins
/obj/item/clothing/accessory/pin
	name = "nanotrasen pin"
	desc = "It's a standard pin to wear so you can show your loyalty to Nanotrasen!"
	icon_state = "nt_pin"

/obj/item/clothing/accessory/pin/pride
	name = "pride pin"
	desc = "It's a standard pin, wear it with pride. You can change which flag is used from a button on the back."
	icon_state = "pride_pin"

	///List of all pride flags to icon state
	var/static/list/flag_types = list(
		"Pride" = "pride_pin",
		"Bisexual Pride" = "bi_pin",
		"Pansexual Pride" = "pan_pin",
		"Asexual Pride" = "ace_pin",
		"Non-binary Pride" = "enby_pin",
		"Transgender Pride" = "trans_pin")

	///List of all pride flags to icon image, for the radial
	var/static/list/flag_icons = list()

/obj/item/clothing/accessory/pin/pride/Initialize(mapload)
	. = ..()
	if(length(flag_icons)) //Only generate it once
		return

	for(var/current_pin in flag_types) //generate the flag icons
		var/image/pin_icon = image(icon, icon_state = flag_types[current_pin])
		flag_icons[current_pin] = pin_icon

/obj/item/clothing/accessory/pin/pride/attack_self__legacy__attackchain(mob/user)
	. = ..()
	var/chosen_pin = show_radial_menu(user, src, flag_icons, require_near = TRUE)
	if(!chosen_pin)
		to_chat(user, "<span class='notice'>You decide not to change [src].</span>")
		return
	var/pin_icon_state = flag_types[chosen_pin]
	to_chat(user, "<span class='notice'>You change [src] to show [chosen_pin].</span>")

	icon_state = pin_icon_state
	inv_overlay = mutable_appearance('icons/obj/clothing/accessories_overlay.dmi', icon_state)

/proc/english_accessory_list(obj/item/clothing/under/U)
	if(!istype(U) || !length(U.accessories))
		return
	var/list/A = U.accessories
	var/total = length(A)
	if(total == 1)
		return "\a [A[1]]"
	else if(total == 2)
		return "\a [A[1]] and \a [A[2]]"
	else
		var/output = ""
		var/index = 1
		var/comma_text = ", "
		while(index < total)
			output += "\a [A[index]][comma_text]"
			index++

		return "[output]and \a [A[index]]"
