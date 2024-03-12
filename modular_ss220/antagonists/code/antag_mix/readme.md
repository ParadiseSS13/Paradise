# Antag Mix Mode

## Antag Mix Mode

`Antag Mix` is gamemode which simply allows to have multiple roundstart antagonists without creating new gamemode per each antagonists combination.
The setup order of the gamemode is following:

1.  The first stage is `/datum/game_mode/antag_mix` gamemode new instance creation,
    where `apply_configuration()` is executed, which handles loading of configuration into the instance.

2.  Next is `pre_setup()`, where `Antag Scenarios` are picked.
    If no scenarios were picked, than `pre_setup` will fail and another gamomode will roll.
    This stage consists of these steps:

    1.  Initializing accepatable scenarios (see `initialize_acceptable_scenarios()`).
    2.  Round budget calculation (see `calculate_budget()`),
        which is linearly dependent from amount of ready player, simply `ready_players_amount * budget_multiplier`.
        So, more players means more budget to spend on `Antag Scenarios`.
        `budget_multiplier` is simple coefficient used to scale the budget. The higher it is, the greater is the budget and vice versa.
    3.  Drafting scenarios (see `draft_scenarios()`), which is also divided into following step:

        1.  Trimming ready players, to have only ones, that actually can be picked for the scenario.

        2.  Filtering scenarios which meet following requirement:

            -   Scenario has `weight` more than `0`
            -   Scenario is ready to be executed (see `/datum/antag_scenario/proc/ready()`)

        3.  The valid scenario than added to assoc list of `scenario -> it's weight`

    4.  The result assoc list from the previous stage is then passed into pick stage:

        1.  The scenarios are picked until all of the conditions below are true:

            -   Round `budget` is higher than `0`
            -   There is at least `1` scenario available to be picked
            -   Antag fraction of already picked scenarios is not higher than `max_antag_fraction`

        2.  When scenario is picked, it's then added to assoc list of `picked_scenarios`, where `picked_scenario -> picked_times` pairs are stored. Scenarios are considered unpickable if:

            -   Scenario's cost is higher than budget left
            -   Antag fraction after adding the scenario will be higher than `max_antag_fraction`

        Also tracked `current_antag_fraction` and `budget_left` are updated based on scenario's parameters.

        3.  Picked scenarios will be passed into next stage `pre_execute_scenario`. This stage also has thigs to say:

            -   Candidates will be trimmed again, because same player can't be picked for multiple scenarios
            -   Scenarios will be properly scaled and then `pre_execute` will be called on scenario to pick and added to `executed_scenarios`
            -   If scenario `pre_execute` failes - scenario won't be added to `executed_scenarios` which means that it won't be included into round
            -   The resulting cost is calculated, `scaled_times` wise, and then substracted from the budget.

        4.  If `budget` was spent incorrectly, which means that some of the picked scenarios failed to `pre_execute`,
            then `pick_scenarios` will be recursively called, to try spend `budget` that was left.
            Any left `budget` that can't be spent unfortunately will burn.

3.  Next and last stage is scenarios execution (see `/datum/antag_scenario/proc/execute()`),
    which will happen on gamemode `post_setup()`. Unfortunetale on this stage the world is already set up
    and any failures are to leave with.

## Antag Scenarios

The `Antag Scenario` is simply set of rules, based on the antagonist is picked and injected into the round.
How scenarios are used is better explained in [previous topic](#antag-mix-mode).

### How To Create New Scenario

You came up with idea of adding new antagonist into the game and what it to be included in `Antag Mix`?
So here is the guide for you how to do it properly:

1. Create a new subtype of `/datum/antag_scenario` for teamless antags or `/datum/antag_scenario/team` for antags,
   that are divided into teams.

2. Most of the type, all you have to do is to simply set following properties to values you need:

-   `name` - just the name of scenario. Currently is not used
-   `config_tag` - unique identifier of scenario in configuration
-   `abstract` - this must be `TRUE` for scenarios, that can be used by `Antag Mix`
-   `antag_role` - value, that uniquely specifies the antagonist. Used to check player eligibility to play the role
-   `antag_special_role` - special role, that is assigned to player chosen for scenario
-   `antag_datum` - `/datum/antagonist` that will be assigned to chosen player in `execute()`
-   `scaled_times` - amount of times, the scenario was chosen to be executed again.
    Lineary affects `antag_cap`: [`antag_cap * (scaled_times + 1)`]
-   `required_players` (configurable) - amount of players required to start the scenario
-   `cost` (configurable) - cost of the antag scenario
-   `weight` (configurable) - frequency of scenario, related to other scenarios. Higher values - higher frequency
-   `antag_cap` (configurable) - max amount of antagonists, the scenario can inject.
-   `candidates_required` - how many possible candidates are required for this scenario to be executed
-   `restricted_roles` - roles that can't be chosen for the scenario
-   `protected_roles` - roles that can't be chosen for the scenario
    if 'GLOB.configuration.gamemode.prevent_mindshield_antags' is TRUE
-   `restricted_species` - species that can't be chosen for the scenario

## Configuration

`Antag Scenarios` and `Antag Mix Mode` have plenty of variables, that can be configured.
This allows to easily enough tweak existing values.
All of the following variables are present in [configuration file](/config/config.toml) `antag_mix_gamemode_configuration` section.

### Antag Mix Mode

When adding new configurables, add values in configuration file and corresponding value to `/datum/configuration_section/antag_mix_gamemode_configuration`.
Values from configuration file should be loaded in `/datum/configuration_section/antag_mix_gamemode_configuration/load_data`.
Values from configuration are assigned to `/datum/game_mode/antag_mix` instance corresponding properties in `/datum/game_mode/antag_mix/proc/apply_configuration()`,
so also do it here.

Here is complete list of configurable variables of `Antag Mix Mode`:

-   `budget_multiplier` - defines how much the rounstart budget is multiplied.
    Higher values - mean more budget, lower - less.
-   `max_antag_fraction` - defines percentage of roundstart antags injected in relation to roundstart ready players.
    For example value 0.1 means 10%. If 60 players are ready on roundstart - 6 antagonist players can be added at most.

### Antag Scenarios

`Antag Scenario` can be fine grain tuned in [configuration file](/config/config.toml) `antag_mix_gamemode_configuration` section.
Long story short - configuration is in `.toml` format, so best way to understand it, is to read [documentation](https://toml.io/en/v1.0.0#array-of-tables).
Each `Antag Scenario` entry can be uniquely identified by `tag` property in configuration.
The `/datum/antag_scenario` with `config_tag` property equal to corresponding `tag` will be configured in `/datum/antag_scenario/proc/apply_configuration()`.
If non existing param will be present in configuration, the error will be logged.
Here is also example, which will be much easier to understand after familiarizing with syntax and semantics of `.toml`:

```toml
# Here `antag_mix_gamemode_configuration` is name of whole section, in `toml` it's called `table`.
# `antag_scenarios_configuration` is name of `key` in `antag_mix_gamemode_configuration` table. Which itself represents array of tables.
# Each new scenarion configuration entry must start with `[[antag_mix_gamemode_configuration.antag_scenarios_configuration]]`.
[[antag_mix_gamemode_configuration.antag_scenarios_configuration]]
# `Key` with name `tag` in table `antag_scenarios_configuration. Tag uniquely identifies each scenario.
tag = "traitor"

# Here we specify belonging of `params` table to `antag_scenarios_configuration` array of tables.
# Whole path must be specified in order to correctly be identified by `.toml` parser.
[antag_mix_gamemode_configuration.antag_scenarios_configuration.params]
"required_players" = 1
"cost" = 1
"weight" = 1
"antag_cap" = 1
"candidates_required" = 1
"restricted_roles" = ["Cyborg"]
"protected_roles" = [
	"Security Officer",
	"Warden",
	"Detective",
	"Head of Security",
	"Captain",
	"Blueshield",
	"Nanotrasen Representative",
	"Magistrate",
	"Internal Affairs Agent",
	"Nanotrasen Navy Officer",
	"Special Operations Officer",
	"Syndicate Officer",
	"Solar Federation General",
]
```

Below is present complete list of existing configurables for curretly existing antag scenarios.
Other variables are prohibited to be changed using configuration file, so they are not present here.
To read more about other variables check [/datum/antag_scenario](/modular_ss220/antagonists/code/antag_mix/scenarios/antag_scenario.dm).
If new configurable properties will be added, include them below:

### General Properties

-   `required_players` - number of ready players, that are required for this scenario to be acceptable
-   `cost` - how much of `Antag Mix` budget is spent on this scenario.
    `0` means, that scenario is only bounded by `max_antag_fraction`
-   `weight` - how often the scenario is picked relatively to other scenarios
-   `antag_cap` - how many players can be chosen for antags by scenario per `scaled_times`
-   `candidates_required` - how many possible candidates are required for this scenario to be executed
    The value is used in `/datum/antag_scenario/proc/ready()`
-   `restricted_roles` - list of roles, that can't be chosen for this scenario
-   `protected_roles` - list of roles, that can't be chosen for this scenario if `GLOB.configuration.gamemode.prevent_mindshield_antags` is `TRUE`
-   `restricted_species` - list of species, that can't be chosen for this scenario

Team scenarios are separated into own subtype. Complete list of specific variables is present here:

### `/datum/antag_scenario/team` Specific Properties

-   `team_size` - amount of players, that will be added to same team
