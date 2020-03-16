#define CULT_ELDERGOD "eldergod"
#define CULT_SLAUGHTER "slaughter"

/obj/effect/rune/proc/fizzle()
	if(istype(src,/obj/effect/rune))
		usr.say(pick("Hakkrutju gopoenjim.", "Nherasai pivroiashan.", "Firjji prhiv mazenhor.", "Tanah eh wakantahe.", "Obliyae na oraie.", "Miyf hon vnor'c.", "Wakabai hij fen juswix."))
	else
		usr.whisper(pick("Hakkrutju gopoenjim.", "Nherasai pivroiashan.", "Firjji prhiv mazenhor.", "Tanah eh wakantahe.", "Obliyae na oraie.", "Miyf hon vnor'c.", "Wakabai hij fen juswix."))
	for (var/mob/V in viewers(src))
		V.show_message("<span class='warning'>The markings pulse with a small burst of light, then fall dark.</span>", 3, "<span class='warning'>You hear a faint fizzle.</span>", 2)
	return

/obj/effect/rune/proc/check_icon()
	if(!SSticker.mode)//work around for maps with runes and cultdat is not loaded all the way
		var/bits = make_bit_triplet()
		icon = get_rune(bits)
	else
		icon = get_rune_cult(invocation)

/obj/item/tome
	name = "arcane tome"
	desc = "An old, dusty tome with frayed edges and a sinister-looking cover."
	icon_state ="tome"
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	var/scribereduct = 0
	var/canbypass = 0 //ADMINBUS

/obj/item/tome/accursed
	name = "accursed tome"
	desc = "An arcane tome still empowered with a shadow of its former consecration."
	scribereduct = 30 //faster because it's made by corrupting a bible

/obj/item/tome/imbued //Admin-only tome, allows instant drawing of runes
	name = "imbued arcane tome"
	desc = "An arcane tome granted by the Geometer itself."
	scribereduct = 50
	canbypass = 1

/obj/item/tome/New()
	if(!SSticker.mode)
		icon_state = "tome"
	else
		icon_state = SSticker.cultdat.tome_icon
	..()

/obj/item/tome/examine(mob/user)
	. = ..()
	if(iscultist(user) || user.stat == DEAD)
		. += "<span class='cult'>The scriptures of [SSticker.cultdat.entity_title3]. Allows the scribing of runes and access to the knowledge archives of the cult of [SSticker.cultdat.entity_name].</span>"
		. += "<span class='cult'>Striking another cultist with it will purge holy water from them.</span>"
		. += "<span class='cult'>Striking a noncultist, however, will sear their flesh.</span>"

/obj/item/tome/attack(mob/living/M, mob/living/user)
	if(!istype(M))
		return
	if(!iscultist(user))
		return ..()
	if(iscultist(M))
		if(M.reagents && M.reagents.has_reagent("holywater")) //allows cultists to be rescued from the clutches of ordained religion
			to_chat(user, "<span class='cult'>You remove the taint from [M].</span>")
			var/holy2unholy = M.reagents.get_reagent_amount("holywater")
			M.reagents.del_reagent("holywater")
			M.reagents.add_reagent("unholywater",holy2unholy)
			add_attack_logs(user, M, "Hit with [src], removing the holy water from them")
		return
	M.take_organ_damage(0, 15) //Used to be a random between 5 and 20
	playsound(M, 'sound/weapons/sear.ogg', 50, 1)
	M.visible_message("<span class='danger'>[user] strikes [M] with the arcane tome!</span>", \
					  "<span class='userdanger'>[user] strikes you with the tome, searing your flesh!</span>")
	flick("tome_attack", src)
	user.do_attack_animation(M)
	add_attack_logs(user, M, "Hit with [src]")

/obj/item/tome/attack_self(mob/user)
	if(!iscultist(user))
		to_chat(user, "<span class='warning'>[src] seems full of unintelligible shapes, scribbles, and notes. Is this some sort of joke?</span>")
		return
	open_tome(user)

/obj/item/tome/proc/open_tome(mob/user)
	var/choice = alert(user,"You open the tome...",,"Scribe Rune","More Information","Cancel")
	switch(choice)
		if("More Information")
			read_tome(user)
		if("Scribe Rune")
			scribe_rune(user)
		if("Cancel")
			return

/obj/item/tome/proc/read_tome(mob/user)
	var/text = list()
	text += "<center><font color='red' size=3><b><i>Archives of [SSticker.cultdat.entity_title1]</i></b></font></center><br><br><br>"
	text += "A rune's name and effects can be revealed by examining the rune.<<br><br>"

	text += "<font color='red'><b>Rite of Binding</b></font><br>This rune is one of the most important runes the cult has, being the only way to create new talismans. A blank sheet of paper must be on top of the rune. After \
	invoking it and choosing which talisman you desire, the paper will be converted, after some delay into a talisman.<br><br>"

	text += "<font color='red'><b>Teleport</b></font><br>This rune is unique in that it requires a keyword before the scribing can begin. When invoked, it will find any other Teleport runes; \
	If any are found, the user can choose which rune to send to. Upon activation, the rune teleports everything above it to the selected rune.<br><br>"

	text += "<font color='red'><b>Rite of Enlightenment</b></font><br>This rune is critical to the success of the cult. It will allow you to convert normal crew members into cultists. \
	To do this, simply place the crew member upon the rune and invoke it. This rune requires two invokers to use. If the target to be converted is mindshielded or a certain assignment, they will \
	be unable to be converted. People [SSticker.cultdat.entity_title3] wishes sacrificed will also be ineligible for conversion, and anyone with a shielding presence like the null rod will not be converted.<br> \
	Successful conversions will produce a tome for the new cultist.<br><br>"

	text += "<font color='red'><b>Rite of Tribute</b></font><br><b>This rune is necessary to achieve your goals.</b> Simply place any dead creature upon the rune and invoke it (this will not \
	target cultists!). If this creature has a mind, a soulstone will be created and the creature's soul transported to it. Sacrificing the dead can be done alone, but sacrificing living crew <b>or your cult's target</b> will require 3 cultists. \
	Soulstones used on construct shells will move that soul into a powerful construct of your choice.<br><br>"


	text += "<font color='red'><b>Rite of Resurrection</b></font><br>This rune requires two corpses. To perform the ritual, place the corpse you wish to revive onto \
	the rune and the offering body adjacent to it. When the rune is invoked, the body to be sacrificed will turn to dust, the life force flowing into the revival target. Assuming the target is not moved \
	within a few seconds, they will be brought back to life, healed of all ailments.<br><br>"

	text += "<font color='red'><b>Rite of Disruption</b></font><br>Robotic lifeforms have time and time again been the downfall of fledgling cults. This rune may allow you to gain the upper \
	hand against these pests. By using the rune, a large electromagnetic pulse will be emitted from the rune's location. The size of the EMP will grow significantly for each additional adjacent cultist when the \
	rune is activated.<br><br>"

	text += "<font color='red'><b>Astral Communion</b></font><br>This rune is perhaps the most ingenious rune that is usable by a single person. Upon invoking the rune, the \
	user's spirit will be ripped from their body. In this state, the user's physical body will be locked in place to the rune itself - any attempts to move it will result in the rune pulling it back. \
	The body will also take constant damage while in this form, and may even die. The user's spirit will contain their consciousness, and will allow them to freely wander the station as a ghost. This may \
	also be used to commune with the dead.<br><br>"

	text += "<font color='red'><b>Rite of the Corporeal Shield</b></font><br>While simple, this rune serves an important purpose in defense and hindering passage. When invoked, the \
	rune will draw a small amount of life force from the user and make the space above the rune completely dense, rendering it impassable to all but the most complex means. The rune may be invoked again to \
	undo this effect and allow passage again.<br><br>"

	text += "<font color='red'><b>Rite of Joined Souls</b></font><br>This rune allows the cult to free other cultists with ease. When invoked, it will allow the user to summon a single cultist to the rune from \
	any location. It requires two invokers, and will damage each invoker slightly.<br><br>"

	text += "<font color='red'><b>Blood Boil</b></font><br>When invoked, this rune will do a massive amount of damage to all non-cultist viewers, but it will also emit a small explosion upon invocation. \
	It requires three invokers.<br><br>"

	text += "<font color='red'><b>Leeching</b></font><br>When invoked, this rune will transfer lifeforce from the victim to the invoker.<br><br>"

	text += "<font color='red'><b>Rite of Spectral Manifestation</b></font><br>This rune allows you to summon spirits as humanoid fighters. When invoked, a spirit above the rune will be brought to life as a human, wearing nothing, that seeks only to serve you and [SSticker.cultdat.entity_title3]. \
	However, the spirit's link to reality is fragile - you must remain on top of the rune, and you will slowly take damage. Upon stepping off the rune, all summoned spirits will dissipate, dropping their items to the ground. You may manifest \
	multiple spirits with one rune, but you will rapidly take damage in doing so.<br><br>"

	text += "<font color='red'><b><i>Ritual of Dimensional Rending</i></b></font><br><b>This rune is necessary to achieve your goals.</b> On attempting to scribe it, it will produce shields around you and alert everyone you are attempting to scribe it; it takes a very long time to scribe, \
	and does massive damage to the one attempting to scribe it.<br>Invoking it requires 9 invokers and the sacrifice of a specific crewmember, and once invoked, will summon [SSticker.cultdat.entity_title3], [SSticker.cultdat.entity_name]. \
	This will complete your objectives.<br><br><br>"

	text += "<font color='red'><b>Talisman of Teleportation</b></font><br>The talisman form of the Teleport rune will transport the invoker to a selected Teleport rune once.<br><br>"

	text += "<font color='red'><b>Talisman of Fabrication</b></font><br>This talisman is the main way of creating construct shells. To use it, one must strike 30 sheets of metal with the talisman. The sheets will then be twisted into a construct shell, ready to receive a soul to occupy it.<br><br>"

	text += "<font color='red'><b>Talisman of Tome Summoning</b></font><br>This talisman will produce a single tome at your feet.<br><br>"

	text += "<font color='red'><b>Talisman of Veiling/Revealing</b></font><br>This talisman will hide runes on its first use, and on the second, will reveal runes.<br><br>"

	text += "<font color='red'><b>Talisman of Disguising</b></font><br>This talisman will permanently disguise all nearby runes as crayon runes.<br><br>"

	text += "<font color='red'><b>Talisman of Electromagnetic Pulse</b></font><br>This talisman will EMP anything else nearby. It disappears after one use.<br><br>"

	text += "<font color='red'><b>Talisman of Stunning</b></font><br>Attacking a target will knock them down for a long duration in addition to inhibiting their speech. \
	Robotic lifeforms will suffer the effects of a heavy electromagnetic pulse instead.<br><br>"

	text += "<font color='red'><b>Talisman of Armaments</b></font><br>The Talisman of Arming will equip the user with armored robes, a backpack, shoes, an eldritch longsword, and an empowered bola. Any equipment that cannot \
	be equipped will not be summoned, weaponry will be put on the floor below the user. Attacking a fellow cultist with it will instead equip them.<br><br>"

	text += "<font color='red'><b>Talisman of Horrors</b></font><br>The Talisman of Horror must be applied directly to the victim, it will shatter your victim's mind with visions of the end-times that may incapacitate them.<br><br>"

	text += "<font color='red'><b>Talisman of Shackling</b></font><br>The Talisman of Shackling must be applied directly to the victim, it has 4 uses and cuffs victims with magic shackles that disappear when removed.<br><br>"

	text += "In addition to these runes, the cult has a small selection of equipment and constructs.<br><br>"

	text += "<font color='red'><b>Equipment:</b></font><br><br>"

	text += "<font color='red'><b>Cult Blade</b></font><br>Cult blades are sharp weapons that, notably, cannot be used by non-cultists. These blades are produced by the Talisman of Arming.<br><br>"

	text += "<font color='red'><b>Cult Bola</b></font><br>Cult bolas are strong bolas, useful for snaring targets. These bolas are produced by the Talisman of Arming.<br><br>"

	text += "<font color='red'><b>Cult Robes</b></font><br>Cult robes are heavily armored robes. These robes are produced by the Talisman of Arming.<br><br>"

	text += "<font color='red'><b>Soulstone</b></font><br>A soulstone is a simple piece of magic, produced either via the starter talisman or by sacrificing humans. Using it on an unconscious or dead human, or on a Shade, will trap their soul in the stone, allowing its use in construct shells. \
	<br>The soul within can also be released as a Shade by using it in-hand.<br><br>"

	text += "<font color='red'><b>Construct Shell</b></font><br>A construct shell is useless on its own, but placing a filled soulstone within it allows you to produce your choice of a <b>Wraith</b>, a <b>Juggernaut</b>, or an <b>Artificer</b>. \
	<br>Each construct has uses, detailed below in Constructs. Construct shells can be produced via the starter talisman or the Rite of Fabrication.<br><br>"

	text += "<font color='red'><b>Constructs:</b></font><br><br>"

	text += "<font color='red'><b>Shade</b></font><br>While technically not a construct, the Shade is produced when released from a soulstone. It is quite fragile and has weak melee attacks, but is fully healed when recaptured by a soulstone.<br><br>"

	text += "<font color='red'><b>Wraith</b></font><br>The Wraith is a fast, lethal melee attacker which can jaunt through walls. However, it is only slightly more durable than a shade.<br><br>"

	text += "<font color='red'><b>Juggernaut</b></font><br>The Juggernaut is a slow, but durable, melee attacker which can produce temporary forcewalls. It will also reflect most lethal energy weapons.<br><br>"

	text += "<font color='red'><b>Artificer</b></font><br>The Artificer is a weak and fragile construct, able to heal other constructs, produce more <font color='red'><b>soulstones</b></font> and <font color='red'><b>construct shells</b></font>, \
	construct fortifying cult walls and flooring, and finally, it can release a few indiscriminate stunning missiles.<br><br>"

	text += "<font color='red'><b>Harvester</b></font><br>If you see one, know that you have done all you can and your life is void.<br><br>"

	var/text_string = jointext(text, null)
	var/datum/browser/popup = new(user, "tome", "", 800, 600)
	popup.set_content(text_string)
	popup.open()
	return 1

/obj/item/tome/proc/finale_runes_ok(mob/living/user, obj/effect/rune/rune_to_scribe)
	var/datum/game_mode/cult/cult_mode = SSticker.mode
	var/area/A = get_area(src)
	if(GAMEMODE_IS_CULT)
		if(!canbypass)//not an admin-tome, check things
			if(!cult_mode.narsie_condition_cleared)
				to_chat(user, "<span class='warning'>There is still more to do before unleashing [SSticker.cultdat.entity_name] power!</span>")
				return 0
			if(!cult_mode.eldergod)
				to_chat(user, "<span class='cultlarge'>\"I am already here. There is no need to try to summon me now.\"</span>")
				return 0
			if(cult_mode.demons_summoned)
				to_chat(user, "<span class='cultlarge'>\"We are already here. There is no need to try to summon us now.\"</span>")
				return 0
			if(!((CULT_ELDERGOD in cult_mode.objectives) || (CULT_SLAUGHTER in cult_mode.objectives)))
				to_chat(user, "<span class='warning'>[SSticker.cultdat.entity_name]'s power does not wish to be unleashed!</span>")
				return 0
			if(!(A in summon_spots))
				to_chat(user, "<span class='cultlarge'>[SSticker.cultdat.entity_name] can only be summoned where the veil is weak - in [english_list(summon_spots)]!</span>")
				return 0
		var/confirm_final = alert(user, "This is the FINAL step to summon your deities power, it is a long, painful ritual and the crew will be alerted to your presence", "Are you prepared for the final battle?", "My life for [SSticker.cultdat.entity_name]!", "No")
		if(confirm_final == "No" || confirm_final == null)
			to_chat(user, "<span class='cult'>You decide to prepare further before scribing the rune.</span>")
			return 0
		else
			return 1
	else//the game mode is not cult..but we ARE a cultist...ALL ON THE ADMINBUS
		var/confirm_final = alert(user, "This is the FINAL step to summon your deities power, it is a long, painful ritual and the crew will be alerted to your presence", "Are you prepared for the final battle?", "My life for [SSticker.cultdat.entity_name]!", "No")
		if(confirm_final == "No" || confirm_final == null)
			to_chat(user, "<span class='cult'>You decide to prepare further before scribing the rune.</span>")
			return 0
		else
			return 1

/obj/item/tome/proc/scribe_rune(mob/living/user)
	var/turf/runeturf = get_turf(user)
	if(isspaceturf(runeturf))
		return
	var/chosen_keyword
	var/obj/effect/rune/rune_to_scribe
	var/entered_rune_name
	var/list/possible_runes = list()
	var/list/shields = list()
	var/area/A = get_area(src)
	if(locate(/obj/effect/rune) in runeturf)
		to_chat(user, "<span class='cult'>There is already a rune here.</span>")
		return
	for(var/T in subtypesof(/obj/effect/rune) - /obj/effect/rune/malformed)
		var/obj/effect/rune/R = T
		if(initial(R.cultist_name))
			possible_runes.Add(initial(R.cultist_name)) //This is to allow the menu to let cultists select runes by name rather than by object path. I don't know a better way to do this
	if(!possible_runes.len)
		return
	entered_rune_name = input(user, "Choose a rite to scribe.", "Sigils of Power") as null|anything in possible_runes
	if(!Adjacent(user) || !src || QDELETED(src) || user.incapacitated())
		return
	for(var/T in typesof(/obj/effect/rune))
		var/obj/effect/rune/R = T
		if(initial(R.cultist_name) == entered_rune_name)
			rune_to_scribe = R
			if(initial(R.req_keyword))
				var/the_keyword = stripped_input(usr, "Please enter a keyword for the rune.", "Enter Keyword", "")
				if(!the_keyword)
					return
				chosen_keyword = the_keyword
			break
	if(!rune_to_scribe)
		return
	runeturf = get_turf(user) //we may have moved. adjust as needed...
	A = get_area(src)
	if(locate(/obj/effect/rune) in runeturf)
		to_chat(user, "<span class='cult'>There is already a rune here.</span>")
		return
	if(!Adjacent(user) || !src || QDELETED(src) || user.incapacitated())
		return
	if(ispath(rune_to_scribe, /obj/effect/rune/narsie) || ispath(rune_to_scribe, /obj/effect/rune/slaughter))//may need to change this - Fethas
		if(finale_runes_ok(user,rune_to_scribe))
			A = get_area(src)
			if(!(A in summon_spots))  // Check again to make sure they didn't move
				to_chat(user, "<span class='cultlarge'>The ritual can only begin where the veil is weak - in [english_list(summon_spots)]!</span>")
				return
			command_announcement.Announce("Figments from an eldritch god are being summoned somewhere on the station from an unknown dimension. Disrupt the ritual at all costs!","Central Command Higher Dimensional Affairs", 'sound/AI/spanomalies.ogg')
			for(var/B in spiral_range_turfs(1, user, 1))
				var/turf/T = B
				var/obj/machinery/shield/N = new(T)
				N.name = "Rune-Scriber's Shield"
				N.desc = "A potent shield summoned by cultists to protect them while they prepare the final ritual"
				N.icon_state = "shield-cult"
				N.health = 60
				shields |= N
		else
			return//don't do shit

	var/mob/living/carbon/human/H = user
	var/dam_zone = pick("head", "chest", "groin", "l_arm", "l_hand", "r_arm", "r_hand", "l_leg", "l_foot", "r_leg", "r_foot")
	var/obj/item/organ/external/affecting = H.get_organ(ran_zone(dam_zone))
	user.visible_message("<span class='warning'>[user] cuts open [user.p_their()] [affecting] and begins writing in [user.p_their()] own blood!</span>", "<span class='cult'>You slice open your [affecting] and begin drawing a sigil of [SSticker.cultdat.entity_title3].</span>")
	user.apply_damage(initial(rune_to_scribe.scribe_damage), BRUTE , affecting)
	if(!do_after(user, initial(rune_to_scribe.scribe_delay)-scribereduct, target = get_turf(user)))
		for(var/V in shields)
			var/obj/machinery/shield/S = V
			if(S && !QDELETED(S))
				qdel(S)
		return
	if(locate(/obj/effect/rune) in runeturf)
		to_chat(user, "<span class='cult'>There is already a rune here.</span>")
		return
	user.visible_message("<span class='warning'>[user] creates a strange circle in [user.p_their()] own blood.</span>", \
						 "<span class='cult'>You finish drawing the arcane markings of [SSticker.cultdat.entity_title3].</span>")
	for(var/V in shields)
		var/obj/machinery/shield/S = V
		if(S && !QDELETED(S))
			qdel(S)
	var/obj/effect/rune/R = new rune_to_scribe(runeturf, chosen_keyword)
	R.blood_DNA = list()
	R.blood_DNA[H.dna.unique_enzymes] = H.dna.blood_type
	R.add_hiddenprint(H)
	to_chat(user, "<span class='cult'>The [lowertext(initial(rune_to_scribe.cultist_name))] rune [initial(rune_to_scribe.cultist_desc)]</span>")
