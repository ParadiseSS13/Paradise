/**
* Use that for creating non-varedited objects,
* or that you don't want to specify because they're insignificant for personal DM file
*/
// Fountain
/obj/structure/statue/fountain
	name = "фонтан"
	desc = "Фонтан, собранный из настоящего, тёсанного камня."
	icon = 'modular_ss220/objects/icons/fountain.dmi'
	icon_state = "fountain_g"
	layer = ABOVE_ALL_MOB_LAYER
	anchored = TRUE
	pixel_x = -16

/obj/structure/statue/fountain/aged
	name = "старый фонтан"
	desc = "Фонтан, собранный из настоящего, тёсанного камня. Его помотало временем."
	icon = 'modular_ss220/objects/icons/fountain.dmi'
	icon_state = "fountain"

// Spotlights, used for floors on station
/obj/structure/marker_beacon/spotlight
	name = "напольный прожектор"
	desc = "Осветительное устройство. Из него исходит яркий луч света."
	icon_state = "markerrandom"
	var/spotlight_color

/obj/structure/marker_beacon/spotlight/yellow
	icon_state = "markeryellow-on"
	spotlight_color = "Yellow"

/obj/structure/marker_beacon/spotlight/jade
	icon_state = "markerjade-on"
	spotlight_color = "Jade"

/obj/structure/marker_beacon/spotlight/Initialize(mapload)
	. = ..()
	picked_color = spotlight_color
	update_icon(UPDATE_ICON_STATE)

/obj/structure/marker_beacon/spotlight/yellow/update_icon_state()
	set_light(light_range, light_power, LIGHT_COLOR_YELLOW)

/obj/structure/marker_beacon/spotlight/jade/update_icon_state()
	set_light(light_range, light_power, LIGHT_COLOR_BLUEGREEN)

// Pamphlets
/obj/item/paper/pamphlet
	name = "pamphlet"
	desc = "A pamphlet that promotes something."
	icon_state = "pamphlet"

// TODO: Write something
/obj/item/paper/pamphlet/deathsquad
	name = "deathsquad pamphlet"
	icon_state = "pamphlet-ds"

/obj/item/paper/pamphlet/gateway
	info = "<b>Welcome to the Nanotrasen Gateway project...</b><br>\
			Congratulations! If you're reading this, you and your superiors have decided that you're \
			ready to commit to a life spent colonising the rolling hills of far away worlds. You \
			must be ready for a lifetime of adventure, a little bit of hard work, and an award \
			winning dental plan- but that's not all the Nanotrasen Gateway project has to offer.<br>\
			<br>Because we care about you, we feel it is only fair to make sure you know the risks \
			before you commit to joining the Nanotrasen Gateway project. All away destinations have \
			been fully scanned by a Nanotrasen expeditionary team, and are certified to be 100% safe. \
			We've even left a case of space beer along with the basic materials you'll need to expand \
			Nanotrasen's operational area and start your new life.<br><br>\
			<b>Gateway Operation Basics</b><br>\
			All Nanotrasen approved Gateways operate on the same basic principals. They operate off \
			area equipment power as you would expect, but they also require a backup wire with at least \
			128, 000 Watts of power running through it. Without this supply, it cannot safely function \
			and will reject all attempts at operation.<br><br>\
			Once it is correctly setup, and once it has enough power to operate, the Gateway will begin \
			searching for an output location. The amount of time this takes is variable, but the Gateway \
			interface will give you an estimate accurate to the minute. Power loss will not interrupt the \
			searching process. Influenza will not interrupt the searching process. Temporal anomalies \
			may cause the estimate to be inaccurate, but will not interrupt the searching process.<br><br> \
			<b>Life On The Other Side</b><br>\
			Once you have traversed the Gateway, you may experience some disorientation. Do not panic. \
			This is a normal side effect of travelling vast distances in a short period of time. You should \
			survey the immediate area, and attempt to locate your complimentary case of space beer. Our \
			expeditionary teams have ensured the complete safety of all away locations, but in a small \
			number of cases, the Gateway they have established may not be immediately obvious. \
			Do not panic if you cannot locate the return Gateway. Begin colonisation of the destination. \
			<br><br><b>A New World</b><br>\
			As a participant in the Nanotrasen Gateway Project, you will be on the frontiers of space. \
			Though complete safety is assured, participants are advised to prepare for inhospitable \
			environs."

// TODO: Rewrite text (update info and add map)
/obj/item/paper/pamphlet/deltainfo
	name = "информационный буклет ИСН «Керберос»"
	info = "<font face=\"Verdana\" color=black><center><H1>Буклет нового сотрудника \
			на борту НСС &#34;Керберос&#34;</H1></center>\
			<BR><HR><B></B><BR><center><H2>Цель</H2></center>\
			<BR><font size=\"4\">Данное руководство было создано с целью \
			<B>облегчить процесс</B> введения в работу станции <B>нового экипажа</B>, \
			а также для <B>информирования сотрудников</B> об оптимальных маршрутах \
			передвижения. В данном буклете находится <B>основная карта</B> &#34;Кербероса&#34; \
			и несколько интересных фактов о станции.</font>\
			<BR> За время строительства проект станции претерпел несколько значительных \
			изменений. Изначально новая станция должна была стать туристическим объектом, \
			но после произошедшей в <B>2549 году</B> серии <B>террористических актов</B> \
			объект вошёл в состав парка научно-исследовательских станций корпорации. В \
			нынешних технических туннелях до сих пор можно найти заброшенные комнаты для \
			гостей, бары и клубы. В связи с плачевным состоянием несущих конструкций \
			посещать эти части станции не рекомендуется, однако неиспользуемые площади \
			могут быть использованы для строительства новых отсеков.\
			<BR><HR><BR><center><H2>Особенности станции</H2></center>\
			<BR>В отличие от большинства других научно-исследовательских станций Nanotrasen, \
			таких как &#34;Кибериада&#34;, <B>ИСН &#34;Керборос&#34;</B> имеет менее \
			жёсткую систему контроля за личными вещами экипажа. В частности, в отсеках \
			были построены <B>дополнительные автолаты</B>, в том числе <B>публичные</B> \
			(в карго и РНД). Также, благодаря более высокому бюджету, были возведены \
			<B>новые отсеки</B>, такие как <B>ангар</B> или <B>склад</B> в отсеке РнД.\
			Был расширен отдел <B>вирусологии</B> и возведены <B>новые техничесские туннели</B> для \
			новых проектов.</font>"

/obj/item/paper/pamphlet/update_icon_state()
	return

// Wallets
// Adding more items that wallet can hold
/obj/item/storage/wallet/Initialize(mapload)
	. = ..()
	can_hold += list(
		/obj/item/encryptionkey,
		/obj/item/clothing/gloves/ring)

// These objects are deleted by Offs, i returned them
// Archive structure
/obj/structure/cult/archives
	name = "Desk"
	desc = "A desk covered in arcane manuscripts and tomes in unknown languages. Looking at the text makes your skin crawl."
	icon_state = "archives"
	light_range = 1.5
	light_color = LIGHT_COLOR_FIRE

// Display Cases
/obj/structure/displaycase/hos
	alert = TRUE
	start_showpiece_type = /obj/item/food/donut/sprinkles
	req_access = list(ACCESS_HOS)
