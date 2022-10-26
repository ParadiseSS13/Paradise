# Paradise Economy

## Introduction
This README was last updated on October 2nd, 2022

## Economy SubSystem
The Economy SubSystem

## The Space Credit Financial System
The Space Credit system is split up into two important datums: money accounts (`/datum/money_account`) and money account databases (`datum/money_account_database`). Money accounts represent individual accounts and money account databases represent a collection of money accounts. This brings up the first interaction standard with these datums, in the code you should never be directly interacting with money_accounts except in cases where you are reading information from them (as opposed to writing to them)

For example it is fine to read the credit balance, account name, or credentials but it would not be ok to change the balance or lists of information directly. You should only be handling those through preexisting procs on the account database level.

### Interacting with Money Accounts through the Account Database
most instances of any financial/economy machinery/programs should have a reference to the main station
database. You'll see a lot of machinery already use a var ref to the main station db, through this, most all economy actions can be performed. (Please see each procs documentation for usage). This is how you will interact with money account, through the account database.

A good way to make sure your machine can access the station money database
`var/datum/money_account_database/account_db = GLOB.station_money_database`

find a money account via the account number, will not find department accounts
`/datum/money_account_database/proc/find_user_account()`
Charge a money account
`/datum/money_account_database/proc/charge_account`
Credit a money account
`/datum/money_account_database/proc/credit_account`
Check user permission to access a money account based on given parameters
`/datum/money_account_database/proc/try_authenticate_login`
Create a transaction log on a money account (and DB in some cases), basically a constructor
`/datum/money_account_database/proc/log_account_action`
Create a money transfer request on specified money account
`/datum/money_account_database/proc/create_transfer_request`
Resolves a money transfer request, deletes account and handles money moving if succesful
`/datum/money_account_database/proc/resolve_transfer_request`

for example, in order to interact with money account A you will need to go through your account database
`account_db.credit_account(A, 50, "Account Credit", ...)`
as opposed to doing it the wrong way which doesn't create a transaction log or check to see if the DB is online
`A.deposit_credits(50)`

As with the previousl example, you may notice that a lot of these procs exist on the money account level. Those are internal procs that exist for the account database to use. The reason for this is to ensure proper logging for players and admins, handle interactions where two money accounts are involved, and to prevent runtimes that may occur from value mismatches. Many procs such as a `charge_account()` and `resolve_transfer_request()` also ensure perfect transfer of credits, this is important (And explained in the next section)

### Perfect Credit Transfer
The power of an in-game economy exists because of how much control we have over it. Every credit spent needs to go somewhere, and every credit given needs to come from somewhere. One should avoid just crediting accounts on a whim or removing money for no reason. Since we don't have current implementations of supply/demand or rolling prices (increasing or decreasing), prices of items in-game are fixed. That means that the money supply is the only thing controlling how much or little of items that the crew can buy.


