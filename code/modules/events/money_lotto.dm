/datum/event/money_lotto
	var/winner_name = "John Smith"
	var/winner_sum = 0
	var/deposit_success = 0

/datum/event/money_lotto/start()
	winner_sum = pick(5000, 10000, 50000, 100000, 500000, 1000000, 1500000)
	if(GLOB.all_money_accounts.len)
		var/datum/money_account/D = pick(GLOB.all_money_accounts)
		winner_name = D.owner_name

		D.credit(winner_sum, "Winner!", "Biesel TCD Terminal #[rand(111,333)]", "Nyx Daily Grand Slam -Stellar- Lottery")
		deposit_success = 1

/datum/event/money_lotto/announce()
	var/datum/feed_message/newMsg = new /datum/feed_message
	newMsg.author = "Nanotrasen Editor"
	newMsg.admin_locked = TRUE

	newMsg.body = "Nyx Daily wishes to congratulate [winner_name] for recieving the Nyx Stellar Slam Lottery, and receiving the out of this world sum of [winner_sum] credits!"
	if(!deposit_success)
		newMsg.body += "Unfortunately, we were unable to verify the account details provided, so we were unable to transfer the money. Send a cheque containing the sum of $500 to ND 'Stellar Slam' office on the Nyx gateway containing updated details, and your winnings'll be re-sent within the month."

	GLOB.news_network.get_channel_by_name("Nyx Daily")?.add_message(newMsg)
	for(var/nc in GLOB.allNewscasters)
		var/obj/machinery/newscaster/NC = nc
		NC.alert_news("Nyx Daily")
