<!-- TOC depth:6 withLinks:1 updateOnSave:0 orderedList:0 -->

- [NanoUI](#nanoui)
	- [Introduction](#introduction)
	- [Components](#components)
		- [`ui_interact()`](#ui_interact)
		- [`Topic()`](#topic)
		- [Template (doT)](#template-dot)
			- [Helpers](#helpers)
				- [Link](#link)
				- [displayBar](#displayBar)
			- [doT](#dot)
			- [Styling](#styling)
	- [Contributing](#contributing)

<!-- /TOC -->
# NanoUI

## Introduction

### Credit goes to Neersighted of /tg/station for the styling and large chunks of content of this README.

NanoUI is one of the three primary user interface libraries currently in use
on Paradise (browse(), /datum/browser, NanoUI). It is the most complex of the three,
but offers quite a few advantages, most notably in default features.

NanoUI adds a `ui_interact()` proc to all atoms, which, ideally, should be called
via `interact()`; However, the current standardized layout is `ui_interact()` being
directly called from anywhere in the atom, generally `attack_hand()` or `attack_self()`.
The `ui_interact()` proc should not contain anything but NanoUI data and code.

Here is a simple example from
[poolcontroller.dm](https://github.com/ParadiseSS13/Paradise/blob/master/code/game/machinery/poolcontroller.dm).

    /obj/machinery/poolcontroller/attack_hand(mob/user)
        ui_interact(user)

    /obj/machinery/poolcontroller/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
        var/data[0]

        data["currentTemp"] = temperature
        data["emagged"] = emagged
        data["TempColor"] = temperaturecolor

        ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
        if(!ui)
            ui = new(user, src, ui_key, "poolcontroller.tmpl", "Pool Controller Interface", 520, 410)
            ui.set_initial_data(data)
            ui.open()




## Components

### `ui_interact()`

The `ui_interact()` proc is used to open a NanoUI (or update it if already open).
As NanoUI will call this proc to update your UI, you should include the data list
within it. On /tg/station, this is handled via `get_ui_data()`, however, as it would
take quite a long time to convert every single one of the 100~ UI's to using such a method,
it is instead just directly created within `ui_interact()`.

The parameters for `try_update_ui` and `/datum/nanoui/new()` are documented in
the code [here](https://github.com/ParadiseSS13/Paradise/tree/master/code/modules/nano).
The most interesting parameter is `state`, which allows the object to choose the
checks that allow the UI to be interacted with.

The default state (`default_state`) checks that the user is alive, conscious,
and within a few tiles. It allows universal access to silicons. Other states
exist, and may be more appropriate for different interfaces. For example,
`physical_state` requires the user to be nearby, even if they are a silicon.
`inventory_state` checks that the user has the object in their first-level
(not container) inventory, this is suitable for devices such as radios;
`admin_state` checks that the user is an admin (good for admin tools).

    /obj/item/the/thing/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, force_open = 0)
        var/data[0]

        ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open = force_open)
        if (!ui)
            ui = new(user, src, ui_key, "template", title, width, height)
            ui.set_initial_data(data)
            ui.open()


### `Topic()`

`Topic()` handles input from the UI. Typically you will recieve some data from
a button press, or pop up a input dialog to take a numerical value from the
user. Sanity checking is useful here, as `Topic()` is trivial to spoof with
arbitrary data.

The `Topic()` interface is just the same as with more conventional,
stringbuilder-based UIs, and this needs little explanation.

    /obj/item/weapon/tank/Topic(href, href_list)
        if (..())
            return 1

        if (href_list["dist_p"])
            if (href_list["dist_p"] == "custom")
                var/custom = input(usr, "What rate do you set the regulator to? The dial reads from 0 to [TANK_MAX_RELEASE_PRESSURE].") as null|num
                if(isnum(custom))
                    href_list["dist_p"] = custom
                    .()
            else if (href_list["dist_p"] == "reset")
                distribute_pressure = TANK_DEFAULT_RELEASE_PRESSURE
            else if (href_list["dist_p"] == "min")
                distribute_pressure = TANK_MIN_RELEASE_PRESSURE
            else if (href_list["dist_p"] == "max")
                distribute_pressure = TANK_MAX_RELEASE_PRESSURE
            else
                distribute_pressure = text2num(href_list["dist_p"])
            distribute_pressure = min(max(round(distribute_pressure), TANK_MIN_RELEASE_PRESSURE), TANK_MAX_RELEASE_PRESSURE)
        if (href_list["stat"])
            if(istype(loc,/mob/living/carbon))
                var/mob/living/carbon/location = loc
                if(location.internal == src)
                    location.internal = null
                    location.internals.icon_state = "internal0"
                    usr << "<span class='notice'>You close the tank release valve.</span>"
                    if (location.internals)
                        location.internals.icon_state = "internal0"
                else
                    if(location.wear_mask && (location.wear_mask.flags & MASKINTERNALS))
                        location.internal = src
                        usr << "<span class='notice'>You open \the [src] valve.</span>"
                        if (location.internals)
                            location.internals.icon_state = "internal1"
                    else
                        usr << "<span class='warning'>You need something to connect to \the [src]!</span>"


### Template (doT)

NanoUI templates are written in a customized version of 
[doT](https://olado.github.io/doT/index.html),
a Javascript template engine. Data is accessed from the `data` object,
configuration (not used in pratice) from the `config` object, and template
helpers are accessed from the `helper` object.

It is worth explaining that Paradise's version of doT uses custom syntax
for the templates. The `?` operator is split into `if`, `else if parameter`, and `else`,
instead of `?`, `?? paramater`, `??`, and the `=` operator is replaced with `:`. Refer
to the chart below for a full comparison.



#### Helpers

##### Link

    {{:helpers.link(text, icon, {'parameter': true}, status, class, id)}}

Used to create a link (button), which will pass its parameters to `Topic()`.

* Text: The text content of the link/button
* Icon: The icon shown to the left of the link (http://fontawesome.io/)
* Parameters: The values to be passed to `Topic()`'s `href_list`.
* Status: `null` for clickable, a class for selected/unclickable.
* Class: Styling to apply to the link.
* ID: Sets the element ID.

Status and Class have almost the same effect. However, changing a link's status
from `null` to something else makes it unclickable, while setting a custom Class
does not.

Ternary operators are often used to avoid writing many `if` statements.
For example, depending on if a value in `data` is true or false we can set a
button to clickable or selected:

    {{:helper.link('Close', 'lock', {'stat': 1}, data.valveOpen ? null : 'selected')}}

Available classes/statuses are:

* null (normal)
* selected
* disabled
* yellowButton
* redButton
* linkDanger

##### displayBar

    {{:helpers.displayBar(value, min, max, class, text)}}

Used to create a bar, to display a numerical value visually. Min and Max default
to 0 and 100, but you can change them to avoid doing your own percent calculations.

* Value: Defaults to a percentage but can be a straight number if Min/Max are set
* Min: The minimum value (left hand side) of the bar
* Max: The maximum value (right hand side) of the bar
* Class: The color of the bar (null/normal, good, average, bad)
* Text: The text label for the data contained in the bar (often just number form)

As with buttons, ternary operators are quite useful:

    {{:helper.bar(data.tankPressure, 0, 1013, (data.tankPressure > 200) ? 'good' : ((data.tankPressure > 100) ? 'average' : 'bad'))}}


#### doT

doT is a simple template language, with control statements mixed in with
regular HTML and interpolation expressions.

However, Paradise uses a custom version with a different syntax. Refer
to the chart below for the differences.

Operator    |  doT       |     equiv         |
|-----------|------------|-------------------|
|Conditional| ?          | if                |
|           | ??         | else              |
|           | ?? (param) | else if (param)   |
|Interpolate| =          | :                 |
|^ + Encode | !          | >                 |
|Evaluation | #          | #                 |
|Defines    | ## #       | ## #              |
|Iteration  | ~ (param)  | for (param)       |

Here is a simple example from tanks, checking if a variable is true:

    {{if data.maskConnected}}
        <span>The regulator is connected to a mask.</span>
    {{else if}}
        <span>The regulator is not connected to a mask.</span>
    {{/if}}

The doT tutorial is [here](https://olado.github.io/doT/tutorial.html).

Print:

    {{:expression }}

Print (with escape):

    {{>expression }}

If/Else If/Else

    {{if condition}}
    // if
    {{else if condition}}
    // else if
    {{else}}
    // else
    {{/if}}

For

    {{for object:key:index}}
    // key, value
    {{/for}}

#### Styling

/tg/station has standardized styling, with specific article tags, and headers, and sections.
However, as the templates are already horrifying unstandardized, Paradise does not have any
particular styling standards.

The only real requirement is that it, A. Looks alrightish, and B. Functions properly. Try
to avoid snowflaking anything into the main CSS file, please. 


## Contributing

There are a few gotchas when it comes to writing for NanoUI. In order to
simplify server code and make the UI more responsive, we precompile all
templates to Javascript. In addition, Coffeescript and LESS are used to make
development easier, and also need to be precompiled. Precompiling CSS also
allows us to add fallbacks for old versions of Internet Explorer.

To compile NanoUI (which you will need to do after adding or updating a
template), first install [Node.js](https://nodejs.org).

Next, you will need to install packages used by NanoUI:

    cd nanoui/
    npm install -g gulp bower
    npm install

Finally, to compile NanoUI, run Gulp:

    gulp

Every time you make an update, you will need to recompile. Before comitting,
make sure you minimize the files with Gulp:

    gulp --min