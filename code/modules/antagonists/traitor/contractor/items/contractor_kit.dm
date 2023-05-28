/obj/item/storage/box/syndie_kit/contractor
	name = "contractor kit"
	desc = "A box containing supplies destined to Syndicate contractors."
	// Settings
	/// Amount of random items to be added to the contractor kit.
	/// See [/obj/item/storage/box/syndie_kit/contractor/var/item_list] for the available items.
	var/num_additional_items = 3
	/// Items that may be part of the random items given to a contractor as part of their kit.
	/// Ideally all about 5 TC or less and fit the theme. Some of these are nukeops only.
	/// One item may show up only once.
	var/list/item_list = list(
		// Offensive
		/obj/item/gun/projectile/automatic/c20r/toy,
		/obj/item/storage/box/syndie_kit/throwing_weapons,
		/obj/item/pen/edagger,
		/obj/item/gun/projectile/automatic/toy/pistol/riot,
		/obj/item/soap/syndie,
		/obj/item/storage/box/syndie_kit/dart_gun,
		/obj/item/gun/syringe/rapidsyringe,
		/obj/item/storage/backpack/duffel/syndie/x4,
		// Mixed
		/obj/item/storage/box/syndie_kit/emp,
		/obj/item/flashlight/emp,
		// Support
		/obj/item/storage/box/syndidonkpockets,
		/obj/item/storage/belt/military/traitor,
		/obj/item/clothing/shoes/chameleon/noslip,
		/obj/item/storage/toolbox/syndicate,
		/obj/item/storage/toolbox/syndisuper,
		/obj/item/storage/backpack/duffel/syndie/surgery,
		/obj/item/multitool/ai_detect,
		/obj/item/encryptionkey/binary,
		/obj/item/jammer,
		/obj/item/implanter/freedom,
	)


/obj/item/storage/box/syndie_kit/contractor/populate_contents()
	new /obj/item/paper/contractor_guide(src)
	new /obj/item/contractor_uplink(src)
	new /obj/item/storage/box/syndie_kit/contractor_loadout(src)
	// Add the random items
	for(var/i in 1 to num_additional_items)
		var/obj/item/I = pick_n_take(item_list)
		new I(src)

/obj/item/storage/box/syndie_kit/contractor_loadout
	name = "contractor standard loadout box"
	desc = "A standard issue box included in a contractor kit."

/obj/item/storage/box/syndie_kit/contractor_loadout/populate_contents()
	new /obj/item/clothing/head/helmet/space/syndicate/contractor(src)
	new /obj/item/clothing/suit/space/syndicate/contractor(src)
	new /obj/item/melee/classic_baton/telescopic/contractor(src)
	new /obj/item/clothing/under/chameleon(src)
	new /obj/item/clothing/mask/chameleon(src)
	new /obj/item/pen/fakesign(src)
	new /obj/item/card/id/syndicate(src)
	new /obj/item/storage/fancy/cigarettes/cigpack_syndicate(src)
	new /obj/item/lighter/zippo(src)
	new /obj/item/encryptionkey/syndicate(src)

/obj/item/paper/contractor_guide
	name = "Инструкции контрактнику"

/obj/item/paper/contractor_guide/Initialize() //The translation is slightly different from the original text, since the chapter "extraction" does not correspond to the actions in the game
	info = {"<p>Приветствуем, агент. Наши поздравления по поводу вашего назначения на должность контрактника Синдиката. Помимо уже имеющихся у вас целей,
			данный набор открывает вам доступ к контрактам, выполнение которых оплачивается телекристаллами.</p>
			<p>Внутри вашего набора находится специализированный скафандр контрактника. Он компактнее, чем стандартные скафандры Синдиката, доступные в вашем аплинке,
			и может влезть в ваш карман. Скафандр сделан из легких материалов и не замедляет вас. Помимо прочего, мы предоставили вам противогаз и комбинезон с функцией "Хамелеон",
			оба этих предмета могут в любой момент менять свой внешний вид на нужный вам. Сигареты пропитаны особой смесью - они будут медленно исцелять ваши травмы с течением времени.</p>
			<p>Дополнительно вам в набор будет выделено три случайных предмета, что были у нас под рукой. Мы надеемся, что они помогут вам в вашей задаче.</p>
			<p>Хаб контрактника, доступный в вашем специализированном аплинке, предоставляет доступ к уникальным предметам и возможностям.
			Покупка осуществляется с помощью особой валюты - репутации (Rep), которая предоставляется в двух условных единицах после каждого успешного завершения контракта.</p>
			<h3>Использование Аплинка Контрактника</h3>
			<ol>
				<li>Возьмите в руки аплинк, лежащий в вашем наборе, и запустите его.</li>
				<li>После успешного запуска вы можете принимать контракты и получать выплаты в телекристаллах за их выполнение.</li>
				<li>Сумма получаемой награды, указанная в скобках как TC, это награда, которую вы получите, если доставите вашу цель <b>живой</b>. Награду в виде
				кредитов вы получите в полном объеме, вне зависимости от того, жива ли ваша цель, или нет.</li>
				<li>Выполнение контрактов осуществляется путем доставки цели вашего контракта в обозначенную зону эвакуации, запроса эвакуации через ваш аплинк и перемещения цели в портал.</li>
			</ol>
			<p>Внимательно всё обдумайте, принимая контракт. В то время, как вы можете видеть все возможные зоны эвакуации заранее, отказ от уже взятого контракта приведет к
			невозможности повторно взять или заменить этот контракт.</p>
			<h3>Похищение</h3>
			<ol>
				<li>Убедитесь, что и вы, и цель находитесь в зоне эвакуации.</li>
				<li>Возьмите в руки ваш аплинк и запросите эвакуацию через кнопку "Call Extraction", после чего подожгите предоставленный вам фальшфейер.</li>
				<li>После использования фальшфейера, дождитесь активации эвакуационного портала.</li>
				<li>Переместите вашу цель в эвакуационный портал.</li>
			</ol>
			<h3>Выкуп</h3>
			<p>Ваши цели нужны нам по нашим собственным причинам, однако, как только они станут для нас бесполезными, мы возвращаем их обратно на станцию за выкуп со стороны НТ.
			Через некоторое время после похищения они будут возвращены в ту локацию, откуда они были доставлены нам. И да, вдобавок от выплаты в виде ТК, вы получите свою долю от выкупа.
			Мы платим на ту карту, что была помещена вами в слот карты в момент эвакуации.</p>
			<p>Удачи, агент. Вы можете сжечь эту бумагу с помощью предоставленной вам зажигалки.</p>"}

	return ..()
