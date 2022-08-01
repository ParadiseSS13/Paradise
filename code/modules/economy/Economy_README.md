# Paradise Economy System

The entirety backing of the financial system in the code is based on two datums, `/datum/money_account` and
`datum/money_account_database`. Money accounts are individual user accounts or assigned to a financial
entity such as vendors or specific departments; These money accounts hold all information about the account including
its name, balance, account credentials, and the procs for interfacing with the accounts. Money Account Databases
are where money_accounts are stored
