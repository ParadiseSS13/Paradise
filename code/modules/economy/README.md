# Paradise Economy

## Introduction
This README was last updated on October 2nd, 2022

## Economy SubSystem
The Economy SubSystem performs a few important tasks that turns the gears of the economy

* `payday()` - This is called every 30 minutes. the payday proc goes through every single money account and credits it the amount it has its paycheck set to. In addition, it will add/subtract credits based on what bonuses/deductions the money account has on it. In addition, SSeconomy tracks global deductions and bonuses which will be applied to EVERY paycheck and then zero'd out after the payday is over. If a money account is open on a NanoBank app, they will be alerted to the paycheck through the app.

* `process_job_tasks()`- This is called every 30 seconds to check if players who have job objectives have completed the requirements of those job objectives, if so, it will add a "bonus" to the players next check and notify the player of the payroll modification. This proc handles calling procs and changing variables that will check completion on the job task and disable it from being checked in the future once payout is given.

## The Space Credit Financial System
The Space Credit system is split up into two important datums: money accounts (`/datum/money_account`) and money account databases (`datum/money_account_database`). Money accounts represent individual accounts and money account databases represent a collection of money accounts.

### Money Accounts
A `/datum/money_acount` or "money account" is where most economy data is stored. In money accounts information is contained about the owner as well as all relevant credentials and setting for the account. Money accounts are rather barebones and only contain helper functions to simplify direct interaction.

**Credit Balance**
Accounts are primarily a store of space credits for crew
`/datum/money_account/proc/try_withdraw_credits` - used to subtract credits from account balance with some safety checks
`/datum/money_account/proc/deposit_credits`      - used to deposit credits into the account balance
`/datum/money_account/proc/set_credits`          - used to set credit balance to a specified value

**Account Security**
Accounts are not perfectly secure and safe, in fact, they're built to be broken into when crew members are not careful with their credentials, or an antagonist chooses to try and access another's account

`/datum/money_account/proc/authenticate_login`
This authenticate_login() proc is used to check the provided credentials against the accounts security level, it returns fails (FALSE) or success (TRUE) if the provided values pass the threshold/security reqs for the specificed security level
There are a few important accounts level

* `ACCOUNT_SECURITY_ID` - Account can be accessed with only the account number
* `ACCOUNT_SECURITY_PIN` - Account can be accessed only with the account number AND correct pin
* `ACCOUNT_SECURITY_RESTRICTED` - Account has same pin/acc-number restrictions but can only be accessed through special machines
* `ACCOUNT_SECURITY_CC` - Account requires user to be an admin, this is for CC character safety
* `ACCOUNT_SECURITY_VENDOR` - Account requires forced programmatic access, players in-game cannot access this account

`make_transaction_log` - Creates a `/datum/transaction` object to be tracked on money account
Transactions are just logs of money going in and out of the account so that players can see where there money comes from and how it is being spent, it provides a paper trail as well for security and legal affairs

**Money Transfers**
Money transfers are the transfer of space credits between money accounts, while the movement of space credits out of one account into another is handled by an account database, the actual requests that have not been resolved are stored and handled on money accounts

`/datum/money_account/proc/create_transfer_request`
Simple helper proc that handles creating a transfer request on the money account, needed to interact with LAZYLISTs
`/datum/money_account/proc/resolve_transfer_request`
another helper proc that clears the transfer request

Neither of these procs actually transfer money account and rather just deal with how the information is being stored and processed on the money account, the actual money transfer is done through the account database.

**Why You Shouldn't use these Procs**
You shouldn't be using these procs unless you intend to change how the account database interacts with money accounts. Like mentioned previously, money accounts are only for storing data and don't actual perform the functions and power the moving parts of the economy. This is because there can be upwards of 100 money accounts in one round, in order to make this memory performative, money accounts are focused on being as efficient as possible by utilizing LAZY LISTS and facilitating good Garbage Collection practices

Instead, if you want to perform calculations, purchases, transfers, etc with multiple money accounts, ALL of that should be done through a account database or some form of financial machinery but not the money account.

### Account Databases
If Money accounts are just records of data, account databases are a store of multiple money data records. A `datum/money_account_database` holds lists of money accounts and serves as the primary means in which interactions are carried out

most instances of any financial/economy machinery/programs should have a reference to the main station
database. You'll see a lot of machinery already use a var ref to the main station db, through this, most all economy actions can be performed. (Please see each procs documentation for usage). This is how you will interact with money account, through the account database.

**Referencing Money Databases**
A good way to make sure your machine can access the station money database
`var/datum/money_account_database/account_db = GLOB.station_money_database`
Additionally, if you need to access a different money database you can go through SSeconomy
`SSeconomy.money_account_databases`

**Using a Money DB to find an account**
The only way to find personal money accounts in a money DB is with the account associated account number
you can use `find_user_account()` for this.
`/datum/money_account_database/proc/find_user_account(account_number, include_departments = FALSE)`
for this proc specifically, you can specify to include departments in the search

For the main station type account db, you can also find departments, you can either get all the departments in one list an iterate through it yourself, or just provide the name of the department
`/datum/money_account_database/main_station/proc/get_all_department_accounts()`
`/datum/money_account_database/main_station/proc/get_account_by_department(department)`

**Moving Money In and Out of Money Accounts**
You can charge a money account, when doing this through the account_db, you need to provide information about the purchase so that if the charge goes through, proper transaction logs can be created
`/datum/money_account_database/proc/charge_account`

You can add credits to a money account with the credit account proc, works similairly to charge account
`/datum/money_account_database/proc/credit_account`

Create a money transfer request datum on specified money account, notifies the money account to start storing this data
`/datum/money_account_database/proc/create_transfer_request`
Resolves a money transfer request, deletes transfer request and charges/credits involved accounts
`/datum/money_account_database/proc/resolve_transfer_request`

**Money Account Security through the DB**
Check user permission to access a money account based on given parameters
`/datum/money_account_database/proc/try_authenticate_login`
Create a transaction log on a money account (and DB in some cases), basically a constructor
`/datum/money_account_database/proc/log_account_action`


for example, in order to interact with money account A you will need to go through your account database
`account_db.credit_account(A, 50, "Account Credit", ...)`
as opposed to doing it the wrong way which doesn't create a transaction log or check to see if the DB is online
`A.deposit_credits(50)`

As with the previousl example, you may notice that a lot of these procs exist on the money account level. Those are internal procs that exist for the account database to use. The reason for this is to ensure proper logging for players and admins, handle interactions where two money accounts are involved, and to prevent runtimes that may occur from value mismatches. Many procs such as a `charge_account()` and `resolve_transfer_request()` also ensure perfect transfer of credits, this is important (And explained in the next section)

### Perfect Credit Transfer
The power of an in-game economy exists because of how much control we have over it. Every credit spent needs to go somewhere, and every credit given needs to come from somewhere. One should avoid just crediting accounts on a whim or removing money for no reason. Since we don't have current implementations of supply/demand or rolling prices (increasing or decreasing), prices of items in-game are fixed. That means that the money supply is the only thing controlling how much or little of items that the crew can buy.

Space Credits Taps (In-Flow of Space Credits into the economy)
* SSeconomy Payday every 30 minutes
* Job Objectives Completion
* Cargo selling crates, plasma, seeds, and research
* Round-start Money Account Balances
* Slot Machine Winnings (although this really is a space credit drain in disguise)
* Contract Completions (contractors)

Space Credit Drains/Exchanges (Out-Flow of space credits out of the economy)
* Vending Machine Purchases
* Cargo Supply Console Purchases
* Physical Destruction of Space cash or credits stored in economy machinery
* RARE: Sol Traders

## Other Important Economy Machinery/Programs
