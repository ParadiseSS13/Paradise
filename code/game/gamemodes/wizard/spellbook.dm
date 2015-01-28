/obj/item/weapon/spellbook
	name = "spell book"
	desc = "The legendary book of spells of the wizard."
	icon = 'icons/obj/library.dmi'
	icon_state ="book"
	throw_speed = 1
	throw_range = 5
	w_class = 1.0
	flags = FPRINT | TABLEPASS
	var/uses = 5
	var/temp = null
	var/max_uses = 5
	var/op = 1
	var/activepage

/obj/item/weapon/spellbook/attackby(obj/item/O as obj, mob/user as mob)
	if(istype(O, /obj/item/weapon/contract))
		var/obj/item/weapon/contract/contract = O
		if(contract.used)
			user << "The contract has been used, you can't get your points back now."
		else
			user << "You feed the contract back into the spellbook, refunding your points."
			src.max_uses++
			src.uses++
			del (O)




/obj/item/weapon/spellbook/attack_self(mob/user as mob)
	user.set_machine(src)
	var/dat
	if(temp)
		dat = "[temp]<BR><BR><A href='byond://?src=\ref[src];temp=1'>Clear</A>"
	else if(!activepage || activepage == "return")
		dat = "<B>The Book of Magic:</B><BR>"
		dat += "Uses remaining: [uses]<BR>"
		dat += "<HR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=spells'>Learn and Improve Magical Abilities</A><BR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=artifacts'>Summon Magical Tools and Weapons</A><BR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=oneuse'>Cast Powerful One Time Spells</A><BR>"

		dat += "<HR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=rememorize'>Re-memorize Spells</A><BR>"
	else if (activepage == "spells")
		dat += "<B>Spells:</B><BR>"
		dat += "Spells that can be reused endlessly. Unless stated otherwise all spells require full wizard garb as a focus.<BR>"
		dat += "The number after the spell name is the cooldown time. You can reduce this number by spending more points on the spell.<BR>"

		dat += "<HR>"

		dat += "<A href='byond://?src=\ref[src];spell_choice=noclothes'>Remove Clothes Requirement</A><BR>"
		dat += "<b>Warning: this takes away 2 spell choices.</b><BR>"

		dat += "<A href='byond://?src=\ref[src];spell_choice=magicmissile'>Magic Missile</A> (15)<BR>"
		dat += "<I>This spell fires several, slow moving, magic projectiles at nearby targets. If they hit a target, it is paralyzed and takes minor damage.</I><BR>"

		dat += "<A href='byond://?src=\ref[src];spell_choice=fireball'>Fireball</A> (10)<BR>"
		dat += "<I>This spell fires a fireball in the direction you're facing and does not require wizard garb. Be careful not to fire it at people that are standing next to you.</I><BR>"

		dat += "<A href='byond://?src=\ref[src];spell_choice=disintegrate'>Disintegrate</A> (60)<BR>"
		dat += "<I>This spell instantly kills somebody adjacent to you with the vilest of magick. It has a long cooldown.</I><BR>"

		dat += "<A href='byond://?src=\ref[src];spell_choice=disabletech'>Disable Technology</A> (60)<BR>"
		dat += "<I>This spell disables all weapons, cameras and most other technology in range.</I><BR>"

		dat += "<A href='byond://?src=\ref[src];spell_choice=smoke'>Smoke</A> (10)<BR>"
		dat += "<I>This spell spawns a cloud of choking smoke at your location and does not require wizard garb.</I><BR>"

		dat += "<A href='byond://?src=\ref[src];spell_choice=repulse'>Repulse</A> (40)<BR>"
		dat += "<I>This spell throws nearby objects away from you and knocks creatures down.</I><BR>"

		dat += "<A href='byond://?src=\ref[src];spell_choice=blind'>Blind</A> (30)<BR>"
		dat += "<I>This spell temporarly blinds a single person and does not require wizard garb.</I><BR>"

		dat += "<A href='byond://?src=\ref[src];spell_choice=mindswap'>Mind Transfer</A> (60)<BR>"
		dat += "<I>This spell allows the user to switch bodies with a target. Careful to not lose your memory in the process.</I><BR>"

		dat += "<A href='byond://?src=\ref[src];spell_choice=forcewall'>Forcewall</A> (10)<BR>"
		dat += "<I>This spell creates an unbreakable wall that lasts for 30 seconds and does not need wizard garb.</I><BR>"

		dat += "<A href='byond://?src=\ref[src];spell_choice=blink'>Blink</A> (2)<BR>"
		dat += "<I>This spell randomly teleports you a short distance. Useful for evasion or getting into areas if you have patience.</I><BR>"

		dat += "<A href='byond://?src=\ref[src];spell_choice=teleport'>Teleport</A> (60)<BR>"
		dat += "<I>This spell teleports you to a type of area of your selection. Very useful if you are in danger, but has a decent cooldown, and is unpredictable.</I><BR>"

		dat += "<A href='byond://?src=\ref[src];spell_choice=mutate'>Mutate</A> (60)<BR>"
		dat += "<I>This spell causes you to turn into a hulk and gain telekinesis for a short while.</I><BR>"

		dat += "<A href='byond://?src=\ref[src];spell_choice=etherealjaunt'>Ethereal Jaunt</A> (30)<BR>"
		dat += "<I>This spell creates your ethereal form, temporarily making you invisible and able to pass through walls.</I><BR>"

		dat += "<A href='byond://?src=\ref[src];spell_choice=knock'>Knock</A> (10)<BR>"
		dat += "<I>This spell opens nearby doors and does not require wizard garb.</I><BR>"

		dat += "<A href='byond://?src=\ref[src];spell_choice=horseman'>Curse of the Horseman</A> (15)<BR>"
		dat += "<I>This spell will curse a person to wear an unremovable horse mask (it has glue on the inside) and speak like a horse. It does not require wizard garb.</I><BR>"

		dat += "<A href='byond://?src=\ref[src];spell_choice=fleshtostone'>Flesh to Stone</A> (60)<BR>"
		dat += "<I>This spell will curse a person to immediately turn into an unmoving statue. The effect will eventually wear off if the statue is not destroyed.</I><BR>"

		dat += "<A href='byond://?src=\ref[src];spell_choice=summonitem'>Instant Summons</A> (10)<BR>"
		dat += "<I>This spell can be used to bind a valuable item to you, bringing it to your hand at will. Using this spell while holding the bound item will allow you to unbind it. It does not require wizard garb.</I><BR>"

		dat += "<HR>"

		dat += "<A href='byond://?src=\ref[src];spell_choice=return'><B>Return</B></A><BR>"

	else if (activepage == "oneuse")
		dat += "<B>One Time Spells:</B><BR>"
		dat += "These potent spells can only be used once and will be used automatically upon purchase.<BR>"
		dat += "The effects are global and irreversable, these spells cannot be unlearned, but they can be bought multiple times.<BR>"

		dat += "<HR>"

		dat += "<A href='byond://?src=\ref[src];spell_choice=summonguns'>Summon Guns</A> (One time use, global spell)<BR>"
		dat += "<I>Nothing could possibly go wrong with arming a crew of lunatics just itching for an excuse to kill eachother. Just be careful not to get hit in the crossfire!</I><BR>"

		dat += "<A href='byond://?src=\ref[src];spell_choice=summonmagic'>Summon Magic</A> (One time use, global spell)<BR>"
		dat += "<I>Share the wonders of magic with the crew and show them why they aren't to be trusted with it at the same time.</I><BR>"

		dat += "<HR>"

		dat += "<A href='byond://?src=\ref[src];spell_choice=return'><B>Return</B></A><BR>"

	else if (activepage == "artifacts")

		dat += "<B>Artefacts:</B><BR>"
		dat += "Powerful items imbued with eldritch magics. Summoning one will count towards your maximum number of uses.<BR>"
		dat += "These items are not bound to you and can be stolen. Additionaly they cannot typically be returned once purchased.<BR>"
		dat += "<HR>"

		dat += "<A href='byond://?src=\ref[src];spell_choice=staffchange'>Staff of Change</A><BR>"
		dat += "<I>An artefact that spits bolts of coruscating energy which cause the target's very form to reshape itself.</I><BR>"
		dat += "<HR>"

		dat += "<A href='byond://?src=\ref[src];spell_choice=soulstone'>Six Soul Stone Shards and the spell Artificer</A><BR>"
		dat += "<I>Soul Stone Shards are ancient tools capable of capturing and harnessing the spirits of the dead and dying. The spell Artificer allows you to create arcane machines for the captured souls to pilot.</I><BR>"
		dat += "<HR>"

		dat += "<A href='byond://?src=\ref[src];spell_choice=staffanimation'>Staff of Animation</A><BR>"
		dat += "<I>An arcane staff capable of shooting bolts of eldritch energy which cause inanimate objects to come to life. This magic doesn't affect machines.</I><BR>"
		dat += "<HR>"

		dat += "<A href='byond://?src=\ref[src];spell_choice=staffdoor'>Staff of Door Creation</A><BR>"
		dat += "<I>A particular staff that can mold solid metal into ornate wooden doors. Useful for getting around in the absence of other transportation. Does not work on glass.</I><BR>"
		dat += "<HR>"

		dat += "<A href='byond://?src=\ref[src];spell_choice=staffchaos'>Staff of Chaos</A><BR>"
		dat += "<I>A caprious tool that can fire all sorts of magic without any rhyme or reason. Using it on people you care about is not recommended.</I><BR>"
		dat += "<HR>"

		dat += "<A href='byond://?src=\ref[src];spell_choice=wands'>Wand Assortment</A><BR>"
		dat += "<I>A collection of wands that allow for a wide variety of utility. Wands do not recharge, so be conservative in use. Comes in a handy belt.</I><BR>"
		dat += "<HR>"

		dat += "<A href='byond://?src=\ref[src];spell_choice=armor'>Mastercrafted Armor Set</A><BR>"
		dat += "<I>An artefact suit of armor that allows you to cast spells while providing more protection against attacks and the void of space.</I><BR>"
		dat += "<HR>"

		dat += "<A href='byond://?src=\ref[src];spell_choice=contract'>Contract of Apprenticeship</A><BR>"
		dat += "<I>A magical contract binding an apprentice wizard to your service, using it will summon them to your side.</I><BR>"
		dat += "<HR>"

		dat += "<A href='byond://?src=\ref[src];spell_choice=scrying'>Scrying Orb</A><BR>"
		dat += "<I>An incandescent orb of crackling energy, using it will allow you to ghost while alive, allowing you to spy upon the station with ease. In addition, buying it will permanently grant you x-ray vision.</I><BR>"

		dat += "<HR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=return'><B>Return</B></A><BR>"
	user << browse(dat, "window=radio")
	onclose(user, "radio")
	return

/obj/item/weapon/spellbook/Topic(href, href_list)
	..()
	var/mob/living/carbon/human/H = usr

	if(H.stat || H.restrained())
		return
	if(!istype(H, /mob/living/carbon/human))
		return 1

	if(H.mind.special_role == "apprentice")
		temp = "If you got caught sneaking a peak from your teacher's spellbook, you'd likely be expelled from the Wizard Academy. Better not."
		return

	if(loc == H || (in_range(src, H) && istype(loc, /turf)))
		H.set_machine(src)
		if(href_list["spell_choice"])
			if(href_list["spell_choice"] == "rememorize")
				var/area/wizard_station/A = locate()
				if(usr in A.contents)
					uses = max_uses
					H.spellremove(usr)
					temp = "All spells have been removed. You may now memorize a new set of spells."
					feedback_add_details("wizard_spell_learned","UM") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
				else
					temp = "You may only re-memorize spells whilst located inside the wizard sanctuary."
			else if(href_list["spell_choice"] == "spells" || href_list["spell_choice"] == "artifacts" || href_list["spell_choice"] == "oneuse" || href_list["spell_choice"] == "return")
				activepage = href_list["spell_choice"]
			else if(uses >= 1 && max_uses >=1)
				uses--
			/*
			*/
				var/list/available_spells = list(magicmissile = "Magic Missile", fireball = "Fireball", disintegrate = "Disintegrate", disabletech = "Disable Tech", repulse = "Repulse", smoke = "Smoke", blind = "Blind", mindswap = "Mind Transfer", forcewall = "Forcewall", blink = "Blink", teleport = "Teleport", mutate = "Mutate", etherealjaunt = "Ethereal Jaunt", knock = "Knock", horseman = "Curse of the Horseman", fleshtostone = "Flesh to Stone", summonitem = "Instant Summons", summonguns = "Summon Guns", summonmagic = "Summon Magic", staffchange = "Staff of Change", soulstone = "Six Soul Stone Shards and the spell Artificer", armor = "Mastercrafted Armor Set", staffanimate = "Staff of Animation", staffchaos = "Staff of Chaos", staffdoor = "Staff of Door Creation", wands = "Wand Assortment")
				var/already_knows = 0
				for(var/obj/effect/proc_holder/spell/wizard/aspell in H.spell_list)
					if(available_spells[href_list["spell_choice"]] == initial(aspell.name))
						already_knows = 1
						if(aspell.spell_level >= aspell.level_max)
							temp = "This spell cannot be improved further."
							uses++
							break
						else
							aspell.name = initial(aspell.name)
							aspell.spell_level++
							aspell.charge_max = round(initial(aspell.charge_max) - aspell.spell_level * (initial(aspell.charge_max) - aspell.cooldown_min)/ aspell.level_max)
							if(aspell.charge_max < aspell.charge_counter)
								aspell.charge_counter = aspell.charge_max
							switch(aspell.spell_level)
								if(1)
									temp = "You have improved [aspell.name] into Efficient [aspell.name]."
									aspell.name = "Efficient [aspell.name]"
								if(2)
									temp = "You have further improved [aspell.name] into Quickened [aspell.name]."
									aspell.name = "Quickened [aspell.name]"
								if(3)
									temp = "You have further improved [aspell.name] into Free [aspell.name]."
									aspell.name = "Free [aspell.name]"
								if(4)
									temp = "You have further improved [aspell.name] into Instant [aspell.name]."
									aspell.name = "Instant [aspell.name]"
							if(aspell.spell_level >= aspell.level_max)
								temp += " This spell cannot be strengthened any further."
			/*
			*/
				if(!already_knows)
					switch(href_list["spell_choice"])
						if("noclothes")
							feedback_add_details("wizard_spell_learned","NC")
							H.spell_list += new /obj/effect/proc_holder/spell/wizard/noclothes
							temp = "This teaches you how to use your spells without your magical garb, truely you are the wizardest."
							uses -= 2
						if("magicmissile")
							feedback_add_details("wizard_spell_learned","MM") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							H.spell_list += new /obj/effect/proc_holder/spell/wizard/targeted/projectile/magic_missile(H)
							temp = "You have learned magic missile."
						if("fireball")
							feedback_add_details("wizard_spell_learned","FB") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							H.spell_list += new /obj/effect/proc_holder/spell/wizard/dumbfire/fireball(H)
							temp = "You have learned fireball."
						if("disintegrate")
							feedback_add_details("wizard_spell_learned","DG") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							H.spell_list += new /obj/effect/proc_holder/spell/wizard/targeted/inflict_handler/disintegrate(H)
							temp = "You have learned disintegrate."
						if("disabletech")
							feedback_add_details("wizard_spell_learned","DT") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							H.spell_list += new /obj/effect/proc_holder/spell/wizard/targeted/emplosion/disable_tech(H)
							temp = "You have learned disable technology."
						if("repulse")
							feedback_add_details("wizard_spell_learned","RP") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							H.spell_list += new /obj/effect/proc_holder/spell/wizard/aoe_turf/repulse(null)
							temp = "You have learned repulse."
						if("smoke")
							feedback_add_details("wizard_spell_learned","SM") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							H.spell_list += new /obj/effect/proc_holder/spell/wizard/targeted/smoke(H)
							temp = "You have learned smoke."
						if("blind")
							feedback_add_details("wizard_spell_learned","BD") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							H.spell_list += new /obj/effect/proc_holder/spell/wizard/targeted/trigger/blind(H)
							temp = "You have learned blind."
						if("mindswap")
							feedback_add_details("wizard_spell_learned","MT") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							H.spell_list += new /obj/effect/proc_holder/spell/wizard/targeted/mind_transfer(H)
							temp = "You have learned mindswap."
						if("forcewall")
							feedback_add_details("wizard_spell_learned","FW") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							H.spell_list += new /obj/effect/proc_holder/spell/wizard/aoe_turf/conjure/forcewall(H)
							temp = "You have learned forcewall."
						if("blink")
							feedback_add_details("wizard_spell_learned","BL") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							H.spell_list += new /obj/effect/proc_holder/spell/wizard/targeted/turf_teleport/blink(H)
							temp = "You have learned blink."
						if("teleport")
							feedback_add_details("wizard_spell_learned","TP") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							H.spell_list += new /obj/effect/proc_holder/spell/wizard/targeted/area_teleport/teleport(H)
							temp = "You have learned teleport."
						if("mutate")
							feedback_add_details("wizard_spell_learned","MU") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							H.spell_list += new /obj/effect/proc_holder/spell/wizard/targeted/genetic/mutate(H)
							temp = "You have learned mutate."
						if("etherealjaunt")
							feedback_add_details("wizard_spell_learned","EJ") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							H.spell_list += new /obj/effect/proc_holder/spell/wizard/targeted/ethereal_jaunt(H)
							temp = "You have learned ethereal jaunt."
						if("knock")
							feedback_add_details("wizard_spell_learned","KN") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							H.spell_list += new /obj/effect/proc_holder/spell/wizard/aoe_turf/knock(H)
							temp = "You have learned knock."
						if("horseman")
							feedback_add_details("wizard_spell_learned","HH") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							H.spell_list += new /obj/effect/proc_holder/spell/wizard/targeted/horsemask(H)
							temp = "You have learned curse of the horseman."
						if("fleshtostone")
							feedback_add_details("wizard_spell_learned","FS") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							H.spell_list += new /obj/effect/proc_holder/spell/wizard/targeted/inflict_handler/flesh_to_stone(H)
							temp = "You have learned flesh to stone."
						if("summonitem")
							feedback_add_details("wizard_spell_learned","IS") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							H.spell_list += new /obj/effect/proc_holder/spell/wizard/targeted/summonitem(null)
							temp = "You have learned instant summons."
						if("summonguns")
							feedback_add_details("wizard_spell_learned","SG") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							H.rightandwrong(0)
							max_uses--
							temp = "You have cast summon guns."
						if("summonmagic")
							feedback_add_details("wizard_spell_learned","SM") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							H.rightandwrong(1)
							max_uses--
							temp = "You have cast summon magic."
						if("staffchange")
							feedback_add_details("wizard_spell_learned","ST") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							new /obj/item/weapon/gun/magic/staff/change(get_turf(H))
							temp = "You have purchased a staff of change."
							max_uses--
						if("soulstone")
							feedback_add_details("wizard_spell_learned","SS") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							new /obj/item/weapon/storage/belt/soulstone/full(get_turf(H))
							H.spell_list += new /obj/effect/proc_holder/spell/wizard/aoe_turf/conjure/construct(H)
							temp = "You have purchased a belt full of soulstones and have learned the artificer spell."
							max_uses--
						if("armor")
							feedback_add_details("wizard_spell_learned","HS") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							new /obj/item/clothing/shoes/sandal(get_turf(H)) //In case they've lost them.
							new /obj/item/clothing/gloves/purple(get_turf(H))//To complete the outfit
							new /obj/item/clothing/suit/space/rig/wizard(get_turf(H))
							new /obj/item/clothing/head/helmet/space/rig/wizard(get_turf(H))
							temp = "You have purchased a suit of wizard armor."
							max_uses--
						if("staffanimation")
							feedback_add_details("wizard_spell_learned","SA") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							new /obj/item/weapon/gun/magic/staff/animate(get_turf(H))
							temp = "You have purchased a staff of animation."
							max_uses--
						if("staffchaos")
							feedback_add_details("wizard_spell_learned","SC") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							new /obj/item/weapon/gun/magic/staff/chaos(get_turf(H))
							temp = "You have purchased a staff of chaos."
							max_uses--
						if("staffdoor")
							feedback_add_details("wizard_spell_learned","SD") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							new /obj/item/weapon/gun/magic/staff/door(get_turf(H))
							temp = "You have purchased a staff of door creation."
							max_uses--
						if("wands")
							feedback_add_details("wizard_spell_learned","WA") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							new /obj/item/weapon/storage/belt/wands/full(get_turf(H))
							temp = "You have purchased an assortment of wands."
							max_uses--
						if("contract")
							feedback_add_details("wizard_spell_learned","CT") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							new /obj/item/weapon/contract(get_turf(H))
							temp = "You have purchased a contract of apprenticeship."
							max_uses--
						if("scrying")
							feedback_add_details("wizard_spell_learned","SO") //please do not change the abbreviation to keep data processing consistent. Add a unique id to any new spells
							new /obj/item/weapon/scrying(get_turf(H))
							if (!(M_XRAY in H.mutations))
								H.mutations.Add(M_XRAY)
								H.sight |= (SEE_MOBS|SEE_OBJS|SEE_TURFS)
								H.see_in_dark = 8
								H.see_invisible = SEE_INVISIBLE_LEVEL_TWO
								H << "\blue The walls suddenly disappear."
							temp = "You have purchased a scrying orb, and gained x-ray vision."
							max_uses--
			H.update_power_buttons()
		else
			if(href_list["temp"])
				temp = null
				activepage = null
		attack_self(H)

	return

//Single Use Spellbooks//

/obj/item/weapon/spellbook/oneuse
	var/spell = /obj/effect/proc_holder/spell/wizard/targeted/projectile/magic_missile //just a placeholder to avoid runtimes if someone spawned the generic
	var/spellname = "sandbox"
	var/used = 0
	name = "spellbook of "
	uses = 1
	max_uses = 1
	desc = "This template spellbook was never meant for the eyes of man..."

/obj/item/weapon/spellbook/oneuse/New()
	..()
	name += spellname

/obj/item/weapon/spellbook/oneuse/attack_self(mob/user as mob)
	var/obj/effect/proc_holder/spell/wizard/S = new spell
	for(var/obj/effect/proc_holder/spell/wizard/knownspell in user.spell_list)
		if(knownspell.type == S.type)
			if(user.mind)
				if(user.mind.special_role == "apprentice" || user.mind.special_role == "Wizard")
					user <<"<span class='notice'>You're already far more versed in this spell than this flimsy how-to book can provide.</span>"
				else
					user <<"<span class='notice'>You've already read this one.</span>"
			return
	if(used)
		recoil(user)
	else
		user.spell_list += S
		user <<"<span class='notice'>you rapidly read through the arcane book. Suddenly you realize you understand [spellname]!</span>"
		user.attack_log += text("\[[time_stamp()]\] <font color='orange'>[user.real_name] ([user.ckey]) learned the spell [spellname] ([S]).</font>")
		onlearned(user)
		user.update_power_buttons()

/obj/item/weapon/spellbook/oneuse/proc/recoil(mob/user as mob)
	user.visible_message("<span class='warning'>[src] glows in a black light!</span>")

/obj/item/weapon/spellbook/oneuse/proc/onlearned(mob/user as mob)
	used = 1
	user.visible_message("<span class='caution'>[src] glows dark for a second!</span>")

/obj/item/weapon/spellbook/oneuse/attackby()
	return

/obj/item/weapon/spellbook/oneuse/fireball
	spell = /obj/effect/proc_holder/spell/wizard/dumbfire/fireball
	spellname = "fireball"
	icon_state ="bookfireball"
	desc = "This book feels warm to the touch."

/obj/item/weapon/spellbook/oneuse/fireball/recoil(mob/user as mob)
	..()
	explosion(user.loc, -1, 0, 2, 3, 0)
	del(src)

/obj/item/weapon/spellbook/oneuse/smoke
	spell = /obj/effect/proc_holder/spell/wizard/targeted/smoke
	spellname = "smoke"
	icon_state ="booksmoke"
	desc = "This book is overflowing with the dank arts."

/obj/item/weapon/spellbook/oneuse/smoke/recoil(mob/user as mob)
	..()
	user <<"<span class='caution'>Your stomach rumbles...</span>"
	if(user.nutrition)
		user.nutrition -= 200
		if(user.nutrition <= 0)
			user.nutrition = 0

/obj/item/weapon/spellbook/oneuse/blind
	spell = /obj/effect/proc_holder/spell/wizard/targeted/trigger/blind
	spellname = "blind"
	icon_state ="bookblind"
	desc = "This book looks blurry, no matter how you look at it."

/obj/item/weapon/spellbook/oneuse/blind/recoil(mob/user as mob)
	..()
	user <<"<span class='warning'>You go blind!</span>"
	user.eye_blind = 10

/obj/item/weapon/spellbook/oneuse/mindswap
	spell = /obj/effect/proc_holder/spell/wizard/targeted/mind_transfer
	spellname = "mindswap"
	icon_state ="bookmindswap"
	desc = "This book's cover is pristine, though its pages look ragged and torn."
	var/mob/stored_swap = null //Used in used book recoils to store an identity for mindswaps

/obj/item/weapon/spellbook/oneuse/mindswap/onlearned()
	spellname = pick("fireball","smoke","blind","forcewall","knock","horses","charge")
	icon_state = "book[spellname]"
	name = "spellbook of [spellname]" //Note, desc doesn't change by design
	..()

/obj/item/weapon/spellbook/oneuse/mindswap/recoil(mob/user as mob)
	..()
	if(stored_swap in dead_mob_list)
		stored_swap = null
	if(!stored_swap)
		stored_swap = user
		user <<"<span class='warning'>For a moment you feel like you don't even know who you are anymore.</span>"
		return
	if(stored_swap == user)
		user <<"<span class='notice'>You stare at the book some more, but there doesn't seem to be anything else to learn...</span>"
		return

	if(user.mind.special_verbs.len)
		for(var/V in user.mind.special_verbs)
			user.verbs -= V

	if(stored_swap.mind.special_verbs.len)
		for(var/V in stored_swap.mind.special_verbs)
			stored_swap.verbs -= V

	var/mob/dead/observer/ghost = stored_swap.ghostize(0)
	ghost.spell_list = stored_swap.spell_list

	user.mind.transfer_to(stored_swap)
	stored_swap.spell_list = user.spell_list

	if(stored_swap.mind.special_verbs.len)
		for(var/V in user.mind.special_verbs)
			user.verbs += V

	ghost.mind.transfer_to(user)
	user.key = ghost.key
	user.spell_list = ghost.spell_list

	if(user.mind.special_verbs.len)
		for(var/V in user.mind.special_verbs)
			user.verbs += V

	stored_swap <<"<span class='warning'>You're suddenly somewhere else... and someone else?!</span>"
	user <<"<span class='warning'>Suddenly you're staring at [src] again... where are you, who are you?!</span>"
	stored_swap = null

/obj/item/weapon/spellbook/oneuse/forcewall
	spell = /obj/effect/proc_holder/spell/wizard/aoe_turf/conjure/forcewall
	spellname = "forcewall"
	icon_state ="bookforcewall"
	desc = "This book has a dedication to mimes everywhere inside the front cover."

/obj/item/weapon/spellbook/oneuse/forcewall/recoil(mob/user as mob)
	..()
	user <<"<span class='warning'>You suddenly feel very solid!</span>"
	var/obj/structure/closet/statue/S = new /obj/structure/closet/statue(user.loc, user)
	S.timer = 30
	user.drop_item()


/obj/item/weapon/spellbook/oneuse/knock
	spell = /obj/effect/proc_holder/spell/wizard/aoe_turf/knock
	spellname = "knock"
	icon_state ="bookknock"
	desc = "This book is hard to hold closed properly."

/obj/item/weapon/spellbook/oneuse/knock/recoil(mob/user as mob)
	..()
	user <<"<span class='warning'>You're knocked down!</span>"
	user.Stun(20)
	user.Weaken(20)

/obj/item/weapon/spellbook/oneuse/horsemask
	spell = /obj/effect/proc_holder/spell/wizard/targeted/horsemask
	spellname = "horses"
	icon_state ="bookhorses"
	desc = "This book is more horse than your mind has room for."

/obj/item/weapon/spellbook/oneuse/horsemask/recoil(mob/living/carbon/user as mob)
	if(istype(user, /mob/living/carbon/human))
		user <<"<font size='15' color='red'><b>HOR-SIE HAS RISEN</b></font>"
		var/obj/item/clothing/mask/horsehead/magichead = new /obj/item/clothing/mask/horsehead
		magichead.canremove = 0		//curses!
		magichead.flags_inv = null	//so you can still see their face
		magichead.voicechange = 1	//NEEEEIIGHH
		user.drop_from_inventory(user.wear_mask)
		user.equip_to_slot_if_possible(magichead, slot_wear_mask, 1, 1)
		del(src)
	else
		user <<"<span class='notice'>I say thee neigh</span>"

/obj/item/weapon/spellbook/oneuse/charge
	spell = /obj/effect/proc_holder/spell/wizard/targeted/charge
	spellname = "charging"
	icon_state ="bookcharge"
	desc = "This book is made of 100% post-consumer wizard."

/obj/item/weapon/spellbook/oneuse/charge/recoil(mob/user as mob)
	..()
	user <<"<span class='warning'>[src] suddenly feels very warm!</span>"
	empulse(src, 1, 1)

/obj/item/weapon/spellbook/oneuse/summonitem
	spell = /obj/effect/proc_holder/spell/wizard/targeted/summonitem
	spellname = "instant summons"
	icon_state ="booksummons"
	desc = "This book is bright and garish, very hard to miss."

/obj/item/weapon/spellbook/oneuse/summonitem/recoil(mob/user as mob)
	..()
	user <<"<span class='warning'>[src] suddenly vanishes!</span>"
	qdel(src)
