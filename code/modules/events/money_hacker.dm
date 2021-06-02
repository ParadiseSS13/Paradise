#define MINIMUM_PERCENTAGE_LOSS 0.5
#define VARIABLE_LOSS 2 // Invariant: 1 - VARIABLE_LOSS/10 >= MINIMUM_PERCENTAGE_LOSS

GLOBAL_VAR_INIT(account_hack_attempted, 0)

/datum/event/money_hacker
	var/datum/money_account/affected_account
	endWhen = 100
	var/end_time

/datum/event/money_hacker/setup()
	end_time = world.time + 6000
	if(GLOB.all_money_accounts.len)
		affected_account = pick(GLOB.all_money_accounts)

		GLOB.account_hack_attempted = 1
	else
		kill()

/datum/event/money_hacker/announce()
	var/message = "Обнаружен взлом  (выполняется с момента [station_time_timestamp()]). Целью атаки является: Финансовый счет #[affected_account.account_number], \
без вмешательства эта атака будет успешной примерно через 10 минут. Требуемое вмешательство: временно заморозьте учётную запись до тех пор, пока атака не прекратится. \
Уведомления будут отправляться по мере появления обновлений."
	var/my_department = "[station_name()] firewall subroutines"

	for(var/obj/machinery/message_server/MS in GLOB.machines)
		if(!MS.active) continue
		MS.send_rc_message("Head of Personnel's Desk", my_department, message, "", "", 2)

/datum/event/money_hacker/tick()
	if(world.time >= end_time)
		endWhen = activeFor
	else
		endWhen = activeFor + 10

/datum/event/money_hacker/end()
	var/message
	if(!isnull(affected_account) && !affected_account.suspended)
		message = "Попытка взлома удалась."

		var/lost = affected_account.money * (MINIMUM_PERCENTAGE_LOSS + rand(0,VARIABLE_LOSS) / 10)

		affected_account.phantom_charge(lost)


		//create a taunting log entry
		var/dest_name = pick("","yo brotha from anotha motha","el Presidente","chieF smackDowN")
		var/amount = pick("","([rand(0,99999)])","alla money","9001$","HOLLA HOLLA GET DOLLA","([lost])")
		var/purpose = pick("Ne$ ---ount fu%ds init*&lisat@*n","PAY BACK YOUR MUM","Funds withdrawal","pWnAgE","l33t hax","liberationez")
		var/date1 = "31 December, 1999"
		var/date2 = "[num2text(rand(1,31))] [pick("January","February","March","April","May","June","July","August","September","October","November","December")], [rand(1000,3000)]"
		var/date = pick("", GLOB.current_date_string, date1, date2)
		var/time1 = rand(0, 99999999)
		var/time2 = "[round(time1 / 36000)+12]:[(time1 / 600 % 60) < 10 ? add_zero(time1 / 600 % 60, 1) : time1 / 600 % 60]"
		var/time = pick("", station_time_timestamp(), time2)
		var/source_terminal = pick("","[pick("Biesel","New Gibson")] GalaxyNet Terminal #[rand(111,999)]","your mums place","nantrasen high CommanD")

		affected_account.makeTransactionLog(amount, purpose, source_terminal, dest_name, TRUE, date, time)


	else
		//crew wins
		message = "Атака прекратилась, пострадавший аккаунт теперь можно вновь использовать."

	var/my_department = "[station_name()] firewall subroutines"

	for(var/obj/machinery/message_server/MS in GLOB.machines)
		if(!MS.active) continue
		MS.send_rc_message("Head of Personnel's Desk", my_department, message, "", "", 2)

#undef MINIMUM_PERCENTAGE_LOSS
#undef VARIABLE_LOSS
