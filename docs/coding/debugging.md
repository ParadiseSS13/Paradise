# Guide to Debugging

## Intro
Got a bug and you're unable to find it by just looking at your code? Try
debugging! This guide will teach you the basics of debugging, how to read the
values and some tips and tricks. It will be written as a chronological story.
Where the chapters explain the next part of the debugging process.

Be sure to look at [Getting Started](../contributing/getting_started.md) if
you're new and need help with setting up your repo. Do also remember that all
below here is how I do it. There are many ways but I find that this works for
me.

### What Is Debugging
> "Debugging is the process of detecting and removing of existing and potential
errors (also called as "bugs") in a software code that can cause it to behave
unexpectedly or crash."
[(source)](https://economictimes.indiatimes.com/definition/debugging)

As you can see from this quote. It is a very broad term. This guide will use a
code debugger to step through your code and look at what is happening.

## How To Debug
We will be using [#15958](https://github.com/ParadiseSS13/Paradise/issues/15958) as an example issue.

### Finding The Issue
First of all, you need to understand what is happening functionally. This
usually gives you hints as to where it goes wrong.

Looking at the GitHub issue we can see that the author (luckily) wrote a clear
reproduction. Without one we'd only be guessing as to where it goes wrong
exactly. Here a tripwire mine activates when it is in a container such as a
closed locker or a bag.

This gives us the hint that the trigger mechanism does not check if the object
is directly on a turf. Using this hint we go look for the proc which causes the
trigger to happen. Using [my previous guide's advice][contrib]
we quickly find `/obj/item/assembly/infra`.

![image](./images/debug_infra_search_results.png)

In the current file of `/obj/item/assembly/infra`, "infrared.dm", we can see a
lot of different procs. We're only really interested in the proc which triggers
the bomb.

![image](./images/debug_trigger_proc.png)

We see that the proc `toggle_secure` starts and stops processing of the object.
This gives us a hint as to where the triggering happens. Looking at
`/obj/item/assembly/infra/process` we see that it creates beams when it is
active. Those beams are functionally used to trigger the bomb itself.

![image](./images/debug_infra_process.png)

Looking at the `/obj/effect/beam/i_beam` object we see that this is indeed the
case.

![image](./images/debug_ibeam_hit.png)

`/obj/effect/beam/i_beam/proc/hit()` is defined here which calls `trigger_beam`
on master. `hit()` in term is called whenever something `Bumped` or `Crossed`
the beam. I found this by right clicking on the `hit` proc and choosing `Find
All References`

![image](./images/debug_ibeam_findreferences.png)

![image](./images/debug_ibeam_findresults.png)

So now we know what is causing the triggering of the bomb. We know that beams
are sent when the bomb is active. And we functionally know that these beams are
also sent when the bomb is hidden in a locker or bag.

[contrib]: ./quickstart.md

### Breakpoints
Now we know what is happening we can start debugging. I have a suspicion already
of what is the cause of the issue. Namely that the `infrared emitter` does not
check the `loc` of the actual bomb in the `/obj/item/assembly/infra/process()`
proc.

To confirm this I will place a breakpoint just when the `process` proc begins.
You do this by clicking just left of the line number where you want to put the
breakpoint.

![image](./images/debug_set_breakpoint.png)

The red dot there is a breakpoint that is set. Clicking it again removes it.

After doing this we will follow the reproduction steps. Once the game hits your
breakpoint it will freeze your game and your VS Code instance should pop up to
the front. If not just open VS Code.

When testing this I noticed that the breakpoint got hit multiple times before I
could do my reproduction. If that is the case then you have multiple options for
combating this annoyance. Either you disable the breakpoint and re-enable it
when you are ready to test. This is not a great way of doing it for this case
but in some cases, this is enough. Or you move the breakpoint to a better
location. I choose this one and I've moved it a bit lower.

![image](./images/debug_lower_breakpoint.png)

I moved it past the `if(!on)` check which eliminates all trip wires which are
not turned on. (Quick note. This is really bad code. They should not be
processing when they are not turned on)

I spawned a premade grenade instead of making my own grenade here. Saves me
quite some time and annoyance in trying to look up how to do this again.
Remember the search results when looking for the trip mine? Yeah, use one of
those.

### In Debug Mode
Once I turn on the bomb I notice that VS Code indeed pops up to the front. The
game is now paused till you say it can continue.

![image](./images/debug_game_paused.png)

The breakpoint line is now highlighted. The highlight shows where the code is
currently. It is about to do the `if(!secured)` check. Let's make the code
execute that one step by stepping over the line. F10 as a shortcut or you can
press the "Step Over" button in your active debugger window.

![image](./images/debug_stepthrough.png)

Now the code is executed and the highlight moved to the next line. Step over is
handy to quickly move over your code. It will jump over any proc call. Step Into
(F11) is for when you want to actually step into the proc call. This will be
explained later when it is needed.

If you step over a bunch of times you will see that it will go and create the
`i_beam`.

![image](./images/debug_stepthrough_create.png)

Even though I am currently holding the bomb in my hands (same situation as when
it is in a bag/locker code-wise). Why is this the case? In the code, you can see
that a beam is created when the bomb is `on`, `secured` and `first` and `last`
are both null. These all have nothing to do with our issue. But the last check
checks if `T` is not null. `T` is defined earlier in the proc as
`get_turf(src)`.

![image](./images/debug_stepthrough_getturf.png)

In other words. `T` is the turf below my characters feet. And of course, this
one does exist in this case. What is missing here is a check to see if the
actual bomb is on a `turf`. How do we even check this?

Time to go look for a reference to the actual bomb as `/obj/item/assembly/infra`
is just the mechanism used by the bomb. `/obj/item/assembly/infra` itself is a
subtype of `/obj/item/assembly` which is the base type that is used for bomb
mechanisms. So we best look at the definition of `/obj/item/assembly`. We do
this by `Ctrl`-clicking on the `assembly` part of `/obj/item/assembly/infra`.

![image](./images/debug_assembly_def.png)

Here we see the definition. We can see that `/obj/item/assembly` has a variable
called `holder` which is of type `/obj/item/assembly_holder`. This is most
likely the thing we want.

Now to check if this is correct. Go to your debug window and open `Arguments`
and then `src`. `src` is of course the object we currently are. Which is the
`/obj/item/assembly/infra`. Once it is open you can see a **LOT** of variables.

![image](./images/debug_arg_vars.png)

We are not interested in most of them and instead, we want to find `holder`

![image](./images/debug_holder_var.png)

Yep, this is the one we want. Now how do we check if this object is directly on
a turf? How do we even check its location? The answer is `loc`. `loc` contains
the location of the object. Here I found out that the `loc` of the
`assembly_holder` wasn't actually my character but instead it was the grenade.
Good thing we checked further before we started coding right?

![image](./images/debug_mine_location.png)

### Finding/Making The Right Variable To Use
Now it becomes a bit odd. Chemistry bomb code is fairly ... bad. But we can make
this work. First, we go look a bit more into the code to find the proper
variable to use. We *can* use `holder.loc.loc` but that says very little about
what it actually means. It would cause even more headaches for people working
with the code in the future. Instead, we will help our future co-developers a
bit and look into improving the existing code. Later on, we also see that this
is not the correct way of fixing it fully.

Let's take a look at the `assembly` code in `assembly.dm`. Let's see how the
assembly determines what its grenade is. When looking around the file I found
the proc `/obj/item/assembly/proc/pulse(radio = FALSE)`. This one seems
promising.

![image](./images/debug_radio_pulse.png)

Here we can see that either the holder is used or if `loc` is a grenade it will
be primed using `prime`. As you can see a previous coder even stated that this
is a hack. This however does give me an idea of how to handle this and the edge
cases that exist. Namely the case where a grenade owns the trip laser as a
mechanism.

The idea I had in mind is to create a proc which returns the physical outer
object. The payload, grenade or such. Where does this proc go? Well in the
assembly file since it will be usable for other code as well. I just put it at
the bottom of the file since nowhere else seemed to fit better. I quickly found
that I needed some more info for this. What if the `holder` was not attached
yet? Or it is remotely attached to a bomb? For this I made a proc for the
`/obj/item/assembly_holder` object which will return the actual outermost
object.

![image](./images/debug_get_outer_object.png)

I found out that `master` is the bomb linked by the line at the top of the
image. This all allows me to complete my other proc.

![image](./images/debug_complete_other_proc.png)

Now we have a proper method to use to find the outermost object.

### Applying The Fix And Testing It
Now we can go and fix the issue at hand. We want to check if the outermost
object its `loc` is a turf. If not it should not fire new lasers and kill the
old ones.

We already have the turf that the `/obj/item/assembly/infra` is located on. Now
we just have to check if that turf is the same turf as our outermost object.

![image](./images/debug_check_turf.png)

Now, this should work. But you of course have to test it! Build it and run the
game. Run it without a breakpoint set first to see if it works functionally.

And it seems to work! Now let's trip it and see if it actually keeps working.

### Runtimes And Stacktrace Traveling
And the game froze. VS Code began blinking. What is happening? The game ran into
a runtime exception

![image](./images/debug_runtime.png)

Now let's see if this is actually our fault or not. Since we did not touch any
timers. To check this go to the debug window and open the call stack.

![image](./images/debug_call_stack.png)

Here you can see **ALL** the current "threads" of the game. DM itself is not a
multithreaded language but it can have multiple threads. I won't go into detail
on that here for simplicity sake. The top item is the one you are currently on.
Just click on it to open it.

![image](./images/debug_top_call_stack.png)

Here we can see the entire stack trace of our current thread. The stack trace is
the entire path the code took thus far. At the top is the last called proc and
at the bottom is the origin of the call. Clicking on each stack will jump you to
the location in the code. The message said that `addtimer` was called on a
`QDELETED` item. This means that the item it is made for is already deleted.
Lets click on `/obj/item/assembly/infra/trigger_beam()` in the stack trace to go
to that call location.

![image](./images/debug_addtimer.png)

Here we see where it went wrong. It seems that `addtimer(CALLBACK(src,
.proc/process_cooldown), 10)` is called even though the `src` is already
deleted. How can this happen? To save us all some time. `pulse` is the proc
which triggers the bomb. In our case our bomb exploded, destroying itself.
Now... is this our fault? No. But we can fix it nonetheless.

![image](./images/debug_pulse_false.png)

This code change will ensure the message is sent and that the runtime stops from
happening.

### Stepping Into VS Stepping Over
Now back to the testing. Once build again start up the game again and try it
this time using a raw `/obj/item/assembly/infra`. As you can see it works only
when you hold it. But not when it is on the floor itself. Seems we made a
mistake! Place a breakpoint again in the `/obj/item/assembly/infra/process()`
proc since there something goes wrong.

![image](./images/debug_outer_object_breakpoint.png)

Now we want to step into the current line. This means that we will go into
`get_outer_object`. Press either F11 or the "Step Into" button.

![image](./images/debug_step_into_button.png)

This will get us to the proc itself. Now step over till you see it return `loc`.
`loc` here is the turf. Which is not the outermost object. Seems we need to do
another check there. This almost certainly also goes for
`/obj/item/assembly_holder/proc/get_outer_object()` as we used mostly the same
logic there.

![image](./images/debug_common_logic.png)

## Outro
Now let's test again. And it seems that there are more issues! The
assembly_holder still shoots a laser if you hold it or put it in a bag. Same for
the infra itself. Now I know the fix already but where is the fun in that.

I'm leaving the last solution (and honour of making the PR that solves the
issue) open for you! If you feel like testing yourself then please pick up this
issue and fix it the way you think would work. I'd love to see your method!

Please also let me know what you think of this format of doing a guide. This one
was more a look into how I do it step by step compared to a more structured
guide.
