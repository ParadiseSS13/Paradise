/obj/item/clothing/accessory
	name = "tie"
	desc = "A neosilk clip-on tie."
	icon = 'icons/obj/clothing/ties.dmi'
	icon_state = "bluetie"
	item_state = ""	//no inhands
	item_color = "bluetie"
	slot_flags = SLOT_TIE
	w_class = WEIGHT_CLASS_SMALL
	var/slot = ACCESSORY_SLOT_DECOR
	var/obj/item/clothing/under/has_suit = null		//the suit the tie may be attached to
	var/image/inv_overlay = null	//overlay used when attached to clothing.
	var/allow_duplicates = TRUE // Allow accessories of the same type.

/obj/item/clothing/accessory/Initialize(mapload)
	. = ..()
	inv_overlay = image("icon" = 'icons/obj/clothing/ties_overlay.dmi', "icon_state" = "[item_color? "[item_color]" : "[icon_state]"]")

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

	if (islist(has_suit.armor) || isnull(has_suit.armor)) 	// This proc can run before /obj/Initialize has run for U and src,
		has_suit.armor = getArmor(arglist(has_suit.armor))	// we have to check that the armor list has been transformed into a datum before we try to call a proc on it
															// This is safe to do as /obj/Initialize only handles setting up the datum if actually needed.
	if (islist(armor) || isnull(armor))
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

/obj/item/clothing/accessory/attack(mob/living/carbon/human/H, mob/living/user)
	// This code lets you put accessories on other people by attacking their sprite with the accessory
	if(istype(H) && !ismonkeybasic(H)) //Monkeys are a snowflake because you can't remove accessories once added
		if(H.wear_suit && H.wear_suit.flags_inv & HIDEJUMPSUIT)
			to_chat(user, "[H]'s body is covered, and you cannot attach \the [src].")
			return 1
		var/obj/item/clothing/under/U = H.w_uniform
		if(istype(U))
			user.visible_message("<span class='notice'>[user] is putting a [src.name] on [H]'s [U.name]!</span>", "<span class='notice'>You begin to put a [src.name] on [H]'s [U.name]...</span>")
			if(do_after(user, 40, target=H) && H.w_uniform == U)
				user.visible_message("<span class='notice'>[user] puts a [src.name] on [H]'s [U.name]!</span>", "<span class='notice'>You finish putting a [src.name] on [H]'s [U.name].</span>")
				U.attackby(src, user)
		else
			to_chat(user, "[H] is not wearing anything to attach \the [src] to.")
		return 1
	return ..()

//default attackby behaviour
/obj/item/clothing/accessory/attackby(obj/item/I, mob/user, params)
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

/obj/item/clothing/accessory/blue
	name = "blue tie"
	icon_state = "bluetie"
	item_color = "bluetie"

/obj/item/clothing/accessory/red
	name = "red tie"
	icon_state = "redtie"
	item_color = "redtie"

/obj/item/clothing/accessory/black
	name = "black tie"
	icon_state = "blacktie"
	item_color = "blacktie"

/obj/item/clothing/accessory/horrible
	name = "horrible tie"
	desc = "A neosilk clip-on tie. This one is disgusting."
	icon_state = "horribletie"
	item_color = "horribletie"

/obj/item/clothing/accessory/waistcoat // No overlay
	name = "waistcoat"
	desc = "For some classy, murderous fun."
	icon_state = "waistcoat"
	item_state = "waistcoat"
	item_color = "waistcoat"

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi'
		)

/obj/item/clothing/accessory/stethoscope
	name = "stethoscope"
	desc = "An outdated medical apparatus for listening to the sounds of the human body. It also makes you look like you know what you're doing."
	icon_state = "stethoscope"
	item_color = "stethoscope"

/obj/item/clothing/accessory/stethoscope/attack(mob/living/carbon/human/M, mob/living/user)
	if(ishuman(M) && isliving(user))
		if(user == M)
			user.visible_message("[user] places [src] against [user.p_their()] chest and listens attentively.", "You place [src] against your chest...")
		else
			user.visible_message("[user] places \the [src] against [M]'s chest and listens attentively.", "You place \the [src] against [M]'s chest...")
		var/obj/item/organ/internal/H = M.get_int_organ(/obj/item/organ/internal/heart)
		var/obj/item/organ/internal/L = M.get_int_organ(/obj/item/organ/internal/lungs)
		if(M.pulse && (H || (L && !HAS_TRAIT(M, TRAIT_NOBREATH))))
			var/color = "notice"
			if(H)
				var/heart_sound
				switch(H.damage)
					if(0 to 1)
						heart_sound = "healthy"
					if(1 to 25)
						heart_sound = "offbeat"
					if(25 to 50)
						heart_sound = "uneven"
						color = "warning"
					if(50 to INFINITY)
						heart_sound = "weak, unhealthy"
						color = "warning"
				to_chat(user, "<span class='[color]'>You hear \an [heart_sound] pulse.</span>")
			if(L)
				var/lung_sound
				switch(L.damage)
					if(0 to 1)
						lung_sound = "healthy respiration"
					if(1 to 25)
						lung_sound = "labored respiration"
					if(25 to 50)
						lung_sound = "pained respiration"
						color = "warning"
					if(50 to INFINITY)
						lung_sound = "gurgling"
						color = "warning"
				to_chat(user, "<span class='[color]'>You hear [lung_sound].</span>")
		else
			to_chat(user, "<span class='warning'>You don't hear anything.</span>")
		return
	return ..(M,user)


//Medals
/obj/item/clothing/accessory/medal
	name = "bronze medal"
	desc = "A bronze medal."
	icon_state = "bronze"
	item_color = "bronze"
	materials = list(MAT_METAL=1000)
	resistance_flags = FIRE_PROOF

// GOLD (awarded by centcom)
/obj/item/clothing/accessory/medal/gold
	name = "gold medal"
	desc = "A prestigious golden medal."
	icon_state = "gold"
	item_color = "gold"
	materials = list(MAT_GOLD=1000)

/obj/item/clothing/accessory/medal/gold/captain
	name = "medal of captaincy"
	desc = "A golden medal awarded exclusively to those promoted to the rank of captain. It signifies the codified responsibilities of a captain to Nanotrasen, and their undisputable authority over their crew."
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/clothing/accessory/medal/gold/captain/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_PARENT_QDELETING, PROC_REF(alert_admins_on_destroy))

/obj/item/clothing/accessory/medal/gold/heroism
	name = "medal of exceptional heroism"
	desc = "An extremely rare golden medal awarded only by CentComm. To receive such a medal is the highest honor and as such, very few exist."

// SILVER (awarded by Captain)

/obj/item/clothing/accessory/medal/silver
	name = "silver medal"
	desc = "A silver medal."
	icon_state = "silver"
	item_color = "silver"
	materials = list(MAT_SILVER=1000)

/obj/item/clothing/accessory/medal/silver/valor
	name = "medal of valor"
	desc = "An award issued by Captains to crew members whose exceptional performance and service to the station has been commended by the station's top leadership."

/obj/item/clothing/accessory/medal/silver/leadership
	name = "medal of command"
	desc = "An award issued by Captains to heads of department who do an excellent job managing their department. Made of pure silver."


// BRONZE (awarded by heads of department, except for the bronze heart)



/obj/item/clothing/accessory/medal/security
	name = "robust security medal"
	desc = "An award issued by the HoS to security staff who excel at upholding the law."

/obj/item/clothing/accessory/medal/science
	name = "smart science medal"
	desc = "An award issued by the RD to science staff who advance the frontiers of knowledge."

/obj/item/clothing/accessory/medal/engineering
	name = "excellent engineering medal"
	desc = "An award issued by the CE to engineering staff whose dedication keep the station running at its best."

/obj/item/clothing/accessory/medal/service
	name = "superior service medal"
	desc = "An award issued by the HoP to service staff who go above and beyond."

/obj/item/clothing/accessory/medal/medical
	name = "magnificient medical medal"
	desc = "An award issued by the CMO to medical staff who excel at saving lives."

/obj/item/clothing/accessory/medal/legal
	name = "meritous legal medal"
	desc = "An award issued by the Magistrate to legal staff who uphold the rule of law."

/obj/item/clothing/accessory/medal/supply
	name = "stable supply medal"
	desc = "An award issued by the Quartermaster to supply staff dedicated to being effective."

/obj/item/clothing/accessory/medal/heart
	name = "bronze heart medal"
	desc = "A rarely-awarded medal for those who sacrifice themselves in the line of duty to save their fellow crew."
	icon_state = "bronze_heart"




/*
	Holobadges are worn on the belt or neck, and can be used to show that the holder is an authorized
	Security agent - the user details can be imprinted on the badge with a Security-access ID card,
	or they can be emagged to accept any ID for use in disguises.
*/

/obj/item/clothing/accessory/holobadge
	name = "holobadge"
	desc = "This glowing blue badge marks the holder as THE LAW."
	icon_state = "holobadge"
	item_color = "holobadge"
	slot_flags = SLOT_BELT | SLOT_TIE

	var/stored_name = null

/obj/item/clothing/accessory/holobadge/cord
	icon_state = "holobadge-cord"
	item_color = "holobadge-cord"

/obj/item/clothing/accessory/holobadge/attack_self(mob/user)
	if(!stored_name)
		to_chat(user, "Waving around a badge before swiping an ID would be pretty pointless.")
		return
	if(isliving(user))
		user.visible_message("<span class='warning'>[user] displays [user.p_their()] Nanotrasen Internal Security Legal Authorization Badge.\nIt reads: [stored_name], NT Security.</span>",
		"<span class='warning'>You display your Nanotrasen Internal Security Legal Authorization Badge.\nIt reads: [stored_name], NT Security.</span>")

/obj/item/clothing/accessory/holobadge/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/card/id) || istype(I, /obj/item/pda))

		var/obj/item/card/id/id_card = null

		if(istype(I, /obj/item/card/id))
			id_card = I
		else
			var/obj/item/pda/pda = I
			id_card = pda.id

		if(ACCESS_SEC_DOORS in id_card.access || emagged)
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

/obj/item/clothing/accessory/holobadge/attack(mob/living/carbon/human/H, mob/living/user)
	if(isliving(user))
		user.visible_message("<span class='warning'>[user] invades [H]'s personal space, thrusting [src] into [H.p_their()] face insistently.</span>",
		"<span class='warning'>You invade [H]'s personal space, thrusting [src] into [H.p_their()] face insistently. You are the law.</span>")

//////////////
//OBJECTION!//
//////////////

/obj/item/clothing/accessory/lawyers_badge
	name = "attorney's badge"
	desc = "Fills you with the conviction of JUSTICE. Lawyers tend to want to show it to everyone they meet."
	icon_state = "lawyerbadge"
	item_state = "lawyerbadge"
	item_color = "lawyerbadge"
	var/cached_bubble_icon = null

/obj/item/clothing/accessory/lawyers_badge/attack_self(mob/user)
	if(prob(1))
		user.say("The testimony contradicts the evidence!")
	user.visible_message("<span class='notice'>[user] shows [user.p_their()] attorney's badge.</span>", "<span class='notice'>You show your attorney's badge.</span>")

/obj/item/clothing/accessory/lawyers_badge/on_attached(obj/item/clothing/under/S, mob/user)
	..()
	if(has_suit && ismob(has_suit.loc))
		var/mob/M = has_suit.loc
		cached_bubble_icon = M.bubble_icon
		M.bubble_icon = "lawyer"

/obj/item/clothing/accessory/lawyers_badge/on_removed(mob/user)
	if(has_suit && ismob(has_suit.loc))
		var/mob/M = has_suit.loc
		M.bubble_icon = cached_bubble_icon
	..()

///////////
//SCARVES//
///////////

/obj/item/clothing/accessory/scarf // No overlay
	name = "scarf"
	desc = "A stylish scarf. The perfect winter accessory for those with a keen fashion sense, and those who just can't handle a cold breeze on their necks."
	dog_fashion = /datum/dog_fashion/head

/obj/item/clothing/accessory/scarf/red
	name = "red scarf"
	icon_state = "redscarf"
	item_color = "redscarf"

/obj/item/clothing/accessory/scarf/green
	name = "green scarf"
	icon_state = "greenscarf"
	item_color = "greenscarf"

/obj/item/clothing/accessory/scarf/darkblue
	name = "dark blue scarf"
	icon_state = "darkbluescarf"
	item_color = "darkbluescarf"

/obj/item/clothing/accessory/scarf/purple
	name = "purple scarf"
	icon_state = "purplescarf"
	item_color = "purplescarf"

/obj/item/clothing/accessory/scarf/yellow
	name = "yellow scarf"
	icon_state = "yellowscarf"
	item_color = "yellowscarf"

/obj/item/clothing/accessory/scarf/orange
	name = "orange scarf"
	icon_state = "orangescarf"
	item_color = "orangescarf"

/obj/item/clothing/accessory/scarf/lightblue
	name = "light blue scarf"
	icon_state = "lightbluescarf"
	item_color = "lightbluescarf"

/obj/item/clothing/accessory/scarf/white
	name = "white scarf"
	icon_state = "whitescarf"
	item_color = "whitescarf"

/obj/item/clothing/accessory/scarf/black
	name = "black scarf"
	icon_state = "blackscarf"
	item_color = "blackscarf"

/obj/item/clothing/accessory/scarf/zebra
	name = "zebra scarf"
	icon_state = "zebrascarf"
	item_color = "zebrascarf"

/obj/item/clothing/accessory/scarf/christmas
	name = "christmas scarf"
	icon_state = "christmasscarf"
	item_color = "christmasscarf"

//The three following scarves don't have the scarf subtype
//This is because Ian can equip anything from that subtype
//However, these 3 don't have corgi versions of their sprites
/obj/item/clothing/accessory/stripedredscarf
	name = "striped red scarf"
	desc = "A stylish scarf. The perfect winter accessory for those with a keen fashion sense, and those who just can't handle a cold breeze on their necks."
	icon_state = "stripedredscarf"
	item_color = "stripedredscarf"

/obj/item/clothing/accessory/stripedgreenscarf
	name = "striped green scarf"
	desc = "A stylish scarf. The perfect winter accessory for those with a keen fashion sense, and those who just can't handle a cold breeze on their necks."
	icon_state = "stripedgreenscarf"
	item_color = "stripedgreenscarf"

/obj/item/clothing/accessory/stripedbluescarf
	name = "striped blue scarf"
	desc = "A stylish scarf. The perfect winter accessory for those with a keen fashion sense, and those who just can't handle a cold breeze on their necks."
	icon_state = "stripedbluescarf"
	item_color = "stripedbluescarf"

//Necklaces
/obj/item/clothing/accessory/necklace
	name = "necklace"
	desc = "A simple necklace."
	icon_state = "necklace"
	item_state = "necklace"
	item_color = "necklace"
	slot_flags = SLOT_TIE

/obj/item/clothing/accessory/necklace/dope
	name = "gold necklace"
	desc = "Damn, it feels good to be a gangster."
	icon_state = "bling"
	item_state = "bling"
	item_color = "bling"

/obj/item/clothing/accessory/necklace/skullcodpiece
	name = "skull codpiece"
	desc = "A skull shaped ornament, intended to protect the important things in life."
	icon_state = "skull"
	item_state = "skull"
	item_color = "skull"
	armor = list(MELEE = 5, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 10, RAD = 5, FIRE = 0, ACID = 15)
	allow_duplicates = FALSE

/obj/item/clothing/accessory/necklace/talisman
	name = "bone talisman"
	desc = "A hunter's talisman, some say the old gods smile on those who wear it."
	icon_state = "talisman"
	item_state = "talisman"
	item_color = "talisman"
	armor = list(MELEE = 5, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 10, RAD = 5, FIRE = 0, ACID = 15)
	allow_duplicates = FALSE

/obj/item/clothing/accessory/necklace/locket
	name = "gold locket"
	desc = "A gold locket that seems to have space for a photo within."
	icon_state = "locket"
	item_state = "locket"
	item_color = "locket"
	slot_flags = SLOT_TIE
	var/base_icon
	var/open
	var/obj/item/held //Item inside locket.

/obj/item/clothing/accessory/necklace/locket/Destroy()
	QDEL_NULL(held)
	return ..()


/obj/item/clothing/accessory/necklace/locket/attack_self(mob/user as mob)
	if(!base_icon)
		base_icon = icon_state

	if(!("[base_icon]_open" in icon_states(icon)))
		to_chat(user, "[src] doesn't seem to open.")
		return

	open = !open
	to_chat(user, "You flip [src] [open?"open":"closed"].")
	if(open)
		icon_state = "[base_icon]_open"
		if(held)
			to_chat(user, "[held] falls out!")
			held.forceMove(get_turf(user))
			held = null
	else
		icon_state = "[base_icon]"

/obj/item/clothing/accessory/necklace/locket/attackby(obj/item/O as obj, mob/user as mob)
	if(!open)
		to_chat(user, "You have to open it first.")
		return

	if(istype(O,/obj/item/paper) || istype(O, /obj/item/photo))
		if(held)
			to_chat(usr, "[src] already has something inside it.")
		else
			to_chat(usr, "You slip [O] into [src].")
			user.drop_item()
			O.forceMove(src)
			held = O
	else
		return ..()

//Cowboy Shirts
/obj/item/clothing/accessory/cowboyshirt
	name = "black cowboy shirt"
	desc = "For a real western look. Looks like it can clip on to a uniform."
	icon_state = "cowboyshirt"
	item_state = "cowboyshirt"
	item_color = "cowboyshirt"

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi'
		)

/obj/item/clothing/accessory/cowboyshirt/short_sleeved
	name = "shortsleeved black cowboy shirt"
	desc = "For when it's a hot day in the west. Looks like it can clip on to a uniform."
	icon_state = "cowboyshirt_s"
	item_state = "cowboyshirt_s"
	item_color = "cowboyshirt_s"

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi'
		)

/obj/item/clothing/accessory/cowboyshirt/white
	name = "white cowboy shirt"
	desc = "For the rancher in us all. Looks like it can clip on to a uniform."
	icon_state = "cowboyshirt_white"
	item_state = "cowboyshirt_white"
	item_color = "cowboyshirt_white"

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi'
		)

/obj/item/clothing/accessory/cowboyshirt/white/short_sleeved
	name = "short sleeved white cowboy shirt"
	desc = "Best for midday cattle tending. Looks like it can clip on to a uniform."
	icon_state = "cowboyshirt_whites"
	item_state = "cowboyshirt_whites"
	item_color = "cowboyshirt_whites"

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi'
		)

/obj/item/clothing/accessory/cowboyshirt/pink
	name = "pink cowboy shirt"
	desc = "For only the manliest of men, or girliest of girls. Looks like it can clip on to a uniform."
	icon_state = "cowboyshirt_pink"
	item_state = "cowboyshirt_pink"
	item_color = "cowboyshirt_pink"

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi'
		)

/obj/item/clothing/accessory/cowboyshirt/pink/short_sleeved
	name = "short sleeved pink cowboy shirt"
	desc = "For a real buckle bunny. Looks like it can clip on to a uniform."
	icon_state = "cowboyshirt_pinks"
	item_state = "cowboyshirt_pinks"
	item_color = "cowboyshirt_pinks"

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi'
		)

/obj/item/clothing/accessory/cowboyshirt/navy
	name = "navy cowboy shirt"
	desc = "Now yer a real cowboy. Looks like it can clip on to a uniform."
	icon_state = "cowboyshirt_navy"
	item_state = "cowboyshirt_navy"
	item_color = "cowboyshirt_navy"

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi'
		)

/obj/item/clothing/accessory/cowboyshirt/navy/short_sleeved
	name = "short sleeved navy cowboy shirt"
	desc = "Sometimes ya need to roll up your sleeves. Looks like it can clip on to a uniform."
	icon_state = "cowboyshirt_navys"
	item_state = "cowboyshirt_navys"
	item_color = "cowboyshirt_navys"

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi'
		)

/obj/item/clothing/accessory/cowboyshirt/red
	name = "red cowboy shirt"
	desc = "It's high noon. Looks like it can clip on to a uniform."
	icon_state = "cowboyshirt_red"
	item_state = "cowboyshirt_red"
	item_color = "cowboyshirt_red"

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi'
		)

/obj/item/clothing/accessory/cowboyshirt/red/short_sleeved
	name = "short sleeved red cowboy shirt"
	desc = "Life on the open range is quite dangeorus, you never know what to expect. Looks like it can clip on to a uniform."
	icon_state = "cowboyshirt_reds"
	item_state = "cowboyshirt_reds"
	item_color = "cowboyshirt_reds"

	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/suit.dmi',
		"Drask" = 'icons/mob/clothing/species/drask/suit.dmi',
		"Grey" = 'icons/mob/clothing/species/grey/suit.dmi'
		)

/obj/item/clothing/accessory/corset
	name = "black corset"
	desc = "A black corset for those fancy nights out."
	icon_state = "corset"
	item_state = "corset"
	item_color = "corset"


/obj/item/clothing/accessory/corset/red
	name = "red corset"
	desc = "A red corset those fancy nights out."
	icon_state = "corset_red"
	item_state = "corset_red"
	item_color = "corset_red"

/obj/item/clothing/accessory/corset/blue
	name = "blue corset"
	desc = "A blue corset for those fancy nights out."
	icon_state = "corset_blue"
	item_state = "corset_blue"
	item_color = "corset_blue"

/proc/english_accessory_list(obj/item/clothing/under/U)
	if(!istype(U) || !U.accessories.len)
		return
	var/list/A = U.accessories
	var/total = A.len
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
