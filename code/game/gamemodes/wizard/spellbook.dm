/datum/spellbook_entry/proc/CanBuy(mob/living/carbon/human/user, obj/item/spellbook/book) // Specific circumstances
	if(book.uses < cost || limit == 0)
		return FALSE
	return TRUE

/datum/spellbook_entry/proc/Buy(mob/living/carbon/human/user, obj/item/spellbook/book) //return TRUE on success
	if(!S)
		S = new spell_type()

	return LearnSpell(user, book, S)

/datum/spellbook_entry/proc/LearnSpell(mob/living/carbon/human/user, obj/item/spellbook/book, obj/effect/proc_holder/spell/newspell)
	for(var/obj/effect/proc_holder/spell/aspell in user.mind.spell_list)
		if(initial(newspell.name) == initial(aspell.name)) // Not using directly in case it was learned from one spellbook then upgraded in another
			if(aspell.spell_level >= aspell.level_max)
				to_chat(user, "<span class='warning'>This spell cannot be improved further.</span>")
				return FALSE
			else
				aspell.name = initial(aspell.name)
				aspell.spell_level++
				aspell.cooldown_handler.recharge_duration = round(aspell.base_cooldown - aspell.spell_level * (aspell.base_cooldown - aspell.cooldown_min) / aspell.level_max)
				switch(aspell.spell_level)
					if(1)
						to_chat(user, "<span class='notice'>You have improved [aspell.name] into Efficient [aspell.name].</span>")
						aspell.name = "Efficient [aspell.name]"
					if(2)
						to_chat(user, "<span class='notice'>You have further improved [aspell.name] into Quickened [aspell.name].</span>")
						aspell.name = "Quickened [aspell.name]"
					if(3)
						to_chat(user, "<span class='notice'>You have further improved [aspell.name] into Free [aspell.name].</span>")
						aspell.name = "Free [aspell.name]"
					if(4)
						to_chat(user, "<span class='notice'>You have further improved [aspell.name] into Instant [aspell.name].</span>")
						aspell.name = "Instant [aspell.name]"
				if(aspell.spell_level >= aspell.level_max)
					to_chat(user, "<span class='notice'>This spell cannot be strengthened any further.</span>")
				aspell.on_purchase_upgrade()
				return TRUE
	//No same spell found - just learn it
	SSblackbox.record_feedback("tally", "wizard_spell_learned", 1, name)
	user.mind.AddSpell(newspell)
	to_chat(user, "<span class='notice'>You have learned [newspell.name].</span>")
	return TRUE

/datum/spellbook_entry/proc/CanRefund(mob/living/carbon/human/user, obj/item/spellbook/book)
	if(!refundable)
		return FALSE
	if(!S)
		S = new spell_type()
	for(var/obj/effect/proc_holder/spell/aspell in user.mind.spell_list)
		if(initial(S.name) == initial(aspell.name))
			return TRUE
	return FALSE

/datum/spellbook_entry/proc/Refund(mob/living/carbon/human/user, obj/item/spellbook/book) //return point value or -1 for failure
	var/area/wizard_station/A = locate()
	if(!(user in A.contents))
		to_chat(user, "<span class='warning'>You can only refund spells at the wizard lair.</span>")
		return -1
	if(!S) //This happens when the spell's source is from another spellbook, from loadouts, or adminery, this create a new template temporary spell
		S = new spell_type()
	var/spell_levels = 0
	for(var/obj/effect/proc_holder/spell/aspell in user.mind.spell_list)
		if(initial(S.name) == initial(aspell.name))
			spell_levels = aspell.spell_level
			user.mind.spell_list.Remove(aspell)
			qdel(aspell)
			if(S) //If we created a temporary spell above, delete it now.
				QDEL_NULL(S)
			return cost * (spell_levels + 1)
	return -1

/datum/spellbook_entry/proc/GetInfo()
	if(!S)
		S = new spell_type()
	var/dat =""
	dat += "<b>[name]</b>"
	dat += " Cooldown:[S.base_cooldown/10]"
	dat += " Cost:[cost]<br>"
	dat += "<i>[S.desc][desc]</i><br>"
	dat += "[S.clothes_req?"Needs wizard garb":"Can be cast without wizard garb"]<br>"
	return dat

//Spell loadouts datum, list of loadouts is in wizloadouts.dm
/datum/spellbook_entry/loadout
	name = "Standard Loadout"
	cost = 10
	category = "Standard"
	refundable = FALSE
	buy_word = "Summon"
	var/list/items_path = list()
	var/list/spells_path = list()
	var/destroy_spellbook = FALSE //Destroy the spellbook when bought, for loadouts containing non-standard items/spells, otherwise wiz can refund spells

/datum/spellbook_entry/loadout/GetInfo()
	var/dat = ""
	dat += "<b>[name]</b>"
	if(cost > 0)
		dat += " Cost:[cost]<br>"
	else
		dat += " No Cost<br>"
	dat += "<i>[desc]</i><br>"
	return dat

/datum/spellbook_entry/loadout/Buy(mob/living/carbon/human/user, obj/item/spellbook/book)
	if(destroy_spellbook)
		var/response = alert(user, "The [src] loadout cannot be refunded once bought. Are you sure this is what you want?", "No refunds!", "No", "Yes")
		if(response == "No")
			return FALSE
		to_chat(user, "<span class='notice'>[book] crumbles to ashes as you acquire its knowledge.</span>")
		qdel(book)
	else if(items_path.len)
		var/response = alert(user, "The [src] loadout contains items that will not be refundable if bought. Are you sure this is what you want?", "No refunds!", "No", "Yes")
		if(response == "No")
			return FALSE
	if(items_path.len)
		var/obj/item/storage/box/wizard/B = new(src)
		for(var/path in items_path)
			new path(B)
		user.put_in_hands(B)
	for(var/path in spells_path)
		var/obj/effect/proc_holder/spell/S = new path()
		LearnSpell(user, book, S)
	OnBuy(user, book)
	return TRUE

/datum/spellbook_entry/loadout/proc/OnBuy(mob/living/carbon/human/user, obj/item/spellbook/book)
	return

/obj/item/spellbook
	name = "spell book"
	desc = "The legendary book of spells of the wizard."
	icon = 'icons/obj/library.dmi'
	icon_state = "spellbook"
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	var/uses = 10
	var/temp = null
	var/op = 1
	var/tab = null
	var/main_tab = null
	var/mob/living/carbon/human/owner
	var/list/datum/spellbook_entry/entries = list()
	var/list/categories = list()
	var/list/main_categories = list("Spells", "Magical Items", "Loadouts")
	var/list/spell_categories = list("Offensive", "Defensive", "Mobility", "Assistance", "Rituals")
	var/list/item_categories = list("Artefacts", "Weapons and Armors", "Staves", "Summons")
	var/list/loadout_categories = list("Standard", "Unique")

/obj/item/spellbook/proc/initialize()
	var/entry_types = subtypesof(/datum/spellbook_entry) - /datum/spellbook_entry/item - /datum/spellbook_entry/summon - /datum/spellbook_entry/loadout
	for(var/T in entry_types)
		var/datum/spellbook_entry/E = new T
		if(GAMEMODE_IS_RAGIN_MAGES && E.is_ragin_restricted)
			qdel(E)
			continue
		entries |= E
		categories |= E.category

	main_tab = main_categories[1]
	tab = categories[1]

/obj/item/spellbook/New()
	..()
	initialize()

/obj/item/spellbook/attackby(obj/item/O as obj, mob/user as mob, params)
	if(istype(O, /obj/item/contract))
		var/obj/item/contract/contract = O
		if(contract.used)
			to_chat(user, "<span class='warning'>The contract has been used, you can't get your points back now!</span>")
		else
			to_chat(user, "<span class='notice'>You feed the contract back into the spellbook, refunding your points.</span>")
			uses+=2
			qdel(O)
		return

	if(istype(O, /obj/item/antag_spawner/slaughter_demon))
		to_chat(user, "<span class='notice'>On second thought, maybe summoning a demon is a bad idea. You refund your points.</span>")
		if(istype(O, /obj/item/antag_spawner/slaughter_demon/laughter))
			uses += 1
			for(var/datum/spellbook_entry/item/hugbottle/HB in entries)
				if(!isnull(HB.limit))
					HB.limit++
		else if(istype(O, /obj/item/antag_spawner/slaughter_demon/shadow))
			uses += 1
			for(var/datum/spellbook_entry/item/shadowbottle/SB in entries)
				if(!isnull(SB.limit))
					SB.limit++
		else
			uses += 2
			for(var/datum/spellbook_entry/item/bloodbottle/BB in entries)
				if(!isnull(BB.limit))
					BB.limit++
		qdel(O)
		return

	if(istype(O, /obj/item/antag_spawner/morph))
		to_chat(user, "<span class='notice'>On second thought, maybe awakening a morph is a bad idea. You refund your points.</span>")
		uses += 1
		for(var/datum/spellbook_entry/item/oozebottle/OB in entries)
			if(!isnull(OB.limit))
				OB.limit++
		qdel(O)
		return

	if(istype(O, /obj/item/antag_spawner/revenant))
		to_chat(user, "<span class='notice'>On second thought, maybe the ghosts have been salty enough today. You refund your points.</span>")
		uses += 1
		for(var/datum/spellbook_entry/item/revenantbottle/RB in entries)
			if(!isnull(RB.limit))
				RB.limit++
		qdel(O)
		return
	return ..()

/obj/item/spellbook/proc/GetCategoryHeader(category)
	var/dat = ""
	switch(category)
		if("Offensive")
			dat += "Spells geared towards debilitating and destroying.<BR><BR>"
			dat += "For spells: the number after the spell name is the cooldown time.<BR>"
			dat += "You can reduce this number by spending more points on the spell.<BR>"
		if("Defensive")
			dat += "Spells geared towards improving your survivability or reducing foes ability to attack.<BR><BR>"
			dat += "For spells: the number after the spell name is the cooldown time.<BR>"
			dat += "You can reduce this number by spending more points on the spell.<BR>"
		if("Mobility")
			dat += "Spells geared towards improving your ability to move. It is a good idea to take at least one.<BR><BR>"
			dat += "For spells: the number after the spell name is the cooldown time.<BR>"
			dat += "You can reduce this number by spending more points on the spell.<BR>"
		if("Assistance")
			dat += "Spells geared towards improving your other items and abilities.<BR><BR>"
			dat += "For spells: the number after the spell name is the cooldown time.<BR>"
			dat += "You can reduce this number by spending more points on the spell.<BR>"
		if("Rituals")
			dat += "These powerful spells are capable of changing the very fabric of reality. Not always in your favour.<BR>"
		if("Weapons and Armors")
			dat += "Various weapons and armors to crush your enemies and protect you from harm.<BR><BR>"
			dat += "Items are not bound to you and can be stolen. Additionally they cannot typically be returned once purchased.<BR>"
		if("Staves")
			dat += "Various staves granting you their power, which they slowly recharge over time.<BR><BR>"
			dat += "Items are not bound to you and can be stolen. Additionally they cannot typically be returned once purchased.<BR>"
		if("Artefacts")
			dat += "Various magical artefacts to aid you.<BR><BR>"
			dat += "Items are not bound to you and can be stolen. Additionally they cannot typically be returned once purchased.<BR>"
		if("Summons")
			dat += "Magical items geared towards bringing in outside forces to aid you.<BR><BR>"
			dat += "Items are not bound to you and can be stolen. Additionally they cannot typically be returned once purchased.<BR>"
		if("Standard")
			dat += "These battle-tested spell sets are easy to use and provide good balance between offense and defense.<BR><BR>"
			dat += "They all cost, and are worth, 10 spell points. You are able to refund any of the spells included as long as you stay in the wizard den.<BR>"
		if("Unique")
			dat += "These esoteric loadouts usually contain spells or items that cannot be bought elsewhere in this spellbook.<BR><BR>"
			dat += "Recommended for experienced wizards looking for something new. No refunds once purchased!<BR>"
	return dat

/obj/item/spellbook/proc/wrap(content)
	var/dat = ""
	dat +="<html><head><title>Spellbook</title></head>"
	dat += {"
	<head>
		<style type="text/css">
			body { font-size: 80%; font-family: 'Lucida Grande', Verdana, Arial, Sans-Serif; }
			ul#tabs { list-style-type: none; margin: 10px 0 0 0; padding: 0 0 0.6em 0; }
			ul#tabs li { display: inline; }
			ul#tabs li a { color: #42454a; background-color: #dedbde; border: 1px solid #c9c3ba; border-bottom: none; padding: 0.6em; text-decoration: none; }
			ul#tabs li a:hover { background-color: #f1f0ee; }
			ul#tabs li a.selected { color: #000; background-color: #f1f0ee; border-bottom: 1px solid #f1f0ee; font-weight: bold; padding: 0.6em 0.6em 0.6em 0.6em; }
			ul#maintabs { list-style-type: none; margin: 30px 0 0 0; padding: 0 0 1em 0; font-size: 14px; }
			ul#maintabs li { display: inline; }
			ul#maintabs li a { color: #42454a; background-color: #dedbde; border: 1px solid #c9c3ba; padding: 1em; text-decoration: none; }
			ul#maintabs li a:hover { background-color: #f1f0ee; }
			ul#maintabs li a.selected { color: #000; background-color: #f1f0ee; font-weight: bold; padding: 1.4em 1.2em 1em 1.2em; }
			div.tabContent { border: 1px solid #c9c3ba; padding: 0.5em; background-color: #f1f0ee; }
			div.tabContent.hide { display: none; }
		</style>
	</head>
	"}
	dat += {"[content]</body></html>"}
	return dat

/obj/item/spellbook/attack_self(mob/user as mob)
	if(!owner)
		to_chat(user, "<span class='notice'>You bind the spellbook to yourself.</span>")
		owner = user
		return
	if(user != owner)
		to_chat(user, "<span class='warning'>[src] does not recognize you as it's owner and refuses to open!</span>")
		return
	user.set_machine(src)
	var/dat = ""

	dat += "<ul id=\"maintabs\">"
	var/list/cat_dat = list()
	for(var/main_category in main_categories)
		cat_dat[main_category] = "<hr>"
		dat += "<li><a [main_tab==main_category?"class=selected":""] href='byond://?src=[UID()];mainpage=[main_category]'>[main_category]</a></li>"
	dat += "</ul>"
	dat += "<ul id=\"tabs\">"
	switch(main_tab)
		if("Spells")
			for(var/category in categories)
				if(category in spell_categories)
					cat_dat[category] = "<hr>"
					dat += "<li><a [tab==category?"class=selected":""] href='byond://?src=[UID()];page=[category]'>[category]</a></li>"
		if("Magical Items")
			for(var/category in categories)
				if(category in item_categories)
					cat_dat[category] = "<hr>"
					dat += "<li><a [tab==category?"class=selected":""] href='byond://?src=[UID()];page=[category]'>[category]</a></li>"
		if("Loadouts")
			for(var/category in categories)
				if(category in loadout_categories)
					cat_dat[category] = "<hr>"
					dat += "<li><a [tab==category?"class=selected":""] href='byond://?src=[UID()];page=[category]'>[category]</a></li>"
	dat += "<li><a><b>Points remaining : [uses]</b></a></li>"
	dat += "</ul>"

	var/datum/spellbook_entry/E
	for(var/i=1,i<=entries.len,i++)
		var/spell_info = ""
		E = entries[i]
		spell_info += E.GetInfo()
		if(E.CanBuy(user,src))
			spell_info+= "<a href='byond://?src=[UID()];buy=[i]'>[E.buy_word]</A><br>"
		else
			spell_info+= "<span>Can't [E.buy_word]</span><br>"
		if(E.CanRefund(user,src))
			spell_info+= "<a href='byond://?src=[UID()];refund=[i]'>Refund</A><br>"
		spell_info += "<hr>"
		if(cat_dat[E.category])
			cat_dat[E.category] += spell_info

	for(var/category in categories)
		dat += "<div class=\"[tab==category?"tabContent":"tabContent hide"]\" id=\"[category]\">"
		dat += GetCategoryHeader(category)
		dat += cat_dat[category]
		dat += "</div>"

	user << browse(wrap(dat), "window=spellbook;size=800x600")
	onclose(user, "spellbook")
	return

/obj/item/spellbook/Topic(href, href_list)
	if(..())
		return 1
	var/mob/living/carbon/human/H = usr

	if(!ishuman(H))
		return 1

	if(H.mind.special_role == SPECIAL_ROLE_WIZARD_APPRENTICE)
		temp = "If you got caught sneaking a peak from your teacher's spellbook, you'd likely be expelled from the Wizard Academy. Better not."
		return 1

	var/datum/spellbook_entry/E = null
	if(loc == H || (in_range(src, H) && isturf(loc)))
		H.set_machine(src)
		if(href_list["buy"])
			E = entries[text2num(href_list["buy"])]
			if(E && E.CanBuy(H,src))
				if(E.Buy(H,src))
					if(E.limit)
						E.limit--
					uses -= E.cost
		else if(href_list["refund"])
			E = entries[text2num(href_list["refund"])]
			if(E && E.refundable)
				var/result = E.Refund(H,src)
				if(result > 0)
					if(!isnull(E.limit))
						E.limit += result
					uses += result
		else if(href_list["mainpage"])
			main_tab = sanitize(href_list["mainpage"])
			tab = sanitize(href_list["page"])
			if(main_tab == "Spells")
				tab = spell_categories[1]
			else if(main_tab == "Magical Items")
				tab = item_categories[1]
			else if(main_tab == "Loadouts")
				tab = loadout_categories[1]
		else if(href_list["page"])
			tab = sanitize(href_list["page"])
	attack_self(H)
	return 1


