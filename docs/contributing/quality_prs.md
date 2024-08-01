# A Guide to Good Quality Pull Requests

by *Sirryan*

Hello community members! This guide will help you improve your contributions to
our awesome codebase. To do this, I hope to help you understand how to make PRs
that are atomic, easy to review, and well-documented.

## Introduction

Like most contributors on Paradise, my interest in contributing to our codebase
sparked from my love for the game and a desire to improve it. Learning how to
even run a local server and set up git is the first hurdle, followed by learning
DM, and eventually crawling your way to making your first change to a local
branch. At this point one's love for contributing can start to bloom because
you're capable of molding the game into something more pleasing for yourself.

However, your newly-developed skills and motivation must also be accompanied
with certain responsibilities and adherence to our community guidelines. Instead
of editing code in a bubble, you are now submitting changes to an actual game,
played by hundreds of players, and supported by 100s of community members. You
must not only sell your change to our development team but also make sure that
we can understand what's being changed in the first place and that your change
is beneficial for the server.

## Making "Good" Pull Requests

Pulling back from the coding world for a moment, I want to talk about another
community based platform, Wikipedia. One of my favorite things about Wikipedia
is the thorough, battle-tested article quality review system they have. The
crown jewel of this rating system is called a "good article" and it embodies
everything desirable you could ever want in a wikipedia article whether you're a
writer or a reader. While "good articles" are a restricted rating (your topic
has to be important enough), there are lower ratings any article can attain
which sets the best standards for all articles! I feel as though Github Pull
Requests can be similarly scrutinized.

Much like a "Good Article," on our GitHub a "Good PR" has the following
characteristics:

- **Your PR is limited in scope.** The PR only has one intended purpose or
  change. the PR _only_ changes code that is needed for the purpose of that
  change.
- **Your PR is designed to be reviewed.** You leverage code comments and design
  logic in a way that a relatively experienced reviewer can understand your
  change quickly.
- **Your PR is properly documented.** The entire PR template is filled out, all
  changes are documented, and you provide ample justification for your changes.
- **Your PR is tested.** You loaded your changes on a local test server and
  systematically checked all changes. This testing is not only documented but
  very thorough.

All of these things will ensure ease of review and expedient flow of your Pull
Request through our GitHub pipeline. To best understand how to reach a level of
quality such as a "Good PR," I'm going to break down each of those points in
detail.

## Limit your Pull Request's Scope

One common issue with PRs is something called **"scope creep"** where the scope
of your pull request--the full window of files/lines you are changing--expands
beyond the original intended changes of the PR. Expanding your pull-request
extends voting, review, and testing in such a way that your PR is at a higher
risk of becoming stale, getting conflicted, and potentially being closed. So it
is in your best interest to constrain the size of your PR as much as possible.

But where's a good place to start? Well, when you're writing your intended
change, try not get side-tracked adding that miscellaneous feature, tweaking
that related system, and/or thinking about altering a few `to_chat`'s here and
there along the way. You might feel like you're improving the game (you probably
are) but this distracts from the more important aspect of your Pull Request,
which is the original intent of your PR. This is a great time to write those
off-topic ideas/changes down somewhere else where you can maybe think about
picking them up later in another PR.

By limiting your pull request to your originally planned (singular) change you
are keeping your Pull Request **atomic.** Specifically you should:

- **Focus on One Issue:** If you're fixing a bug, limit your PR to that bug fix.
  If you're adding a feature, don't mix it with unrelated refactoring. Pick one
  thing and do it really well!
- **Keep it Small and Manageable:** Smaller PRs are easier to review and less
  likely to introduce new bugs. It's a lot easier to deconflict and debug 10 PRs
  that each change 5 files than to deconflict and debug 1 PR that changes 50.
- **Incremental Changes:** Break down large changes into smaller, logical parts.
  Submit these parts as separate PRs. If your feature requires a refactor of a
  system or several bug fixes to an object, do those first separately in a
  different PR before expanding content.

While I'm mostly writing this section to make my life easier when I inevitably
review your Pull Request down the road… keeping your PRs small and atomic go a
long way to preserving your time & energy.

## Make Your Code Easier to Review

**Fact:** A well-structured & documented PR is easier and faster to review.

When someone opens a Pull Request, all of the files changed is brand new code to
me for the most part. Especially if you are refactoring or adding new content.
So I need a bit of help or I'm gonna be banging my head against my monitor for a
while. After 30 minutes of confused reading I'm going to abandon my review and
tell you to document your code better before I start again.

To help you visualize, I would like to take you on a minor code adventure.
Either through GitHub search or your local code editor find the definition for
`/datum/controller/subsystem`, it should be in `subsystem.dm`. Take a peak
around that file, you'll end up seeing a whole lot of code comments. Pick a
random variable or proc and try to explain what it does (rubber ducky debugging
style) to an imaginary friend. Now imagine trying to do that without any of the
comment documentation in the file. You likely can't, not without digging for a
long while and following all of the code logic yourself. Do you even know where
to start?

I'm not going to write an essay on this section since it really boils down to a
lot of best practices you will learn along the way, so here's some bullets to
brush over:

**Code Comment:**

- **Function Headers:** Add comments at the beginning of each function to
  explain its purpose, input parameters, and return values.
- **Complex Logic:** Place comments above or alongside complex or non-obvious
  code sections to clarify the logic and intent.
- **Avoid Obvious Comments:** Do not comment on code that is self-explanatory,
  as it can clutter the codebase.

**Naming Conventions:**

- **Descriptive Names:** Use clear and descriptive names for functions and
  variables that convey their purpose and use. Name it how it is please!
- **Consistency:** Follow the Paradises naming conventions (snake_case for most
  things).
- **Avoid Abbreviations:** Use full words instead of abbreviations unless they
  are widely understood and standard within the codebase.
- **Action-Oriented:** Name functions based on what they do (e.g.,
  calculate_score(), visible_message(), update_appearance()).
- **Meaningful and Contextual:** Choose names that reflect the variable's role
  or content (e.g., telecrystal_count, account_pin, summoner).

By adhering to these practices, you help ensure that your code is understandable
and maintainable, making it easier for reviewers and other contributors to work
with.

## Fill Out the PR Template

When creating a pull request, it's crucial to provide clear, detailed
information. Your title and description are the first things anyone sees and are
essential for communicating the intent and scope of your changes to the Design,
Balance, and Review team.

**Be #26094 and Not #7003**

This means your PR should be sufficiently presented, like #26094, which is
detailed and precise, rather than vague and insufficient, like #7003.

**Use Proper PR Titles and Descriptions**

- **Titles:** Use clear and concise titles that summarize the change. Avoid
  vague or ambiguous titles. For example, instead of "Fix bug," use "Fix crash
  caused by null reference in inventory system."
- **Descriptions:** Provide a detailed description of your changes. Explain what
  the PR does, why it's needed, and how it affects the game. This should be a
  comprehensive overview that leaves little to interpretation.

**Communicating and Visualizing Your Changes**

When modifying game features, include:

- **Proper Descriptions:** Clearly describe the changes made to features.
  Explain how these changes alter the game's functionality or balance.
- **Screenshots and Videos:** Provide visual evidence of changes, such as
  screenshots or videos. This is especially important for UI changes, sprite
  updates, or any feature that affects the visual aspect of the game. Include
  before-and-after images if applicable.
- **Proof of Functionality:** Demonstrate that the feature works as intended in
  the game. This could include video clips of gameplay or detailed descriptions
  of test cases and results.

**Provide Justifications for Changes**

It's important to justify why your changes are beneficial:

- **Rationale:** Explain why the change is necessary. Avoid stating personal
  opinions without support. Instead, provide a well-reasoned explanation of the
  issue being addressed or the improvement being made.
- **Community Consensus:** Mention if there has been discussion among credible
  community members. Link to relevant forum threads, Discord conversations, or
  other community discussions that show a consensus or strong support for the
  change.
- **Data and Evidence:** If applicable, provide data or consistent anecdotal
  evidence to support the need for the change. This could include bug reports,
  player feedback, or metrics showing a problem with the current state of the
  game.

You must ensure that your PR provides all necessary information for a thorough
review. This not only helps maintain the quality and balance of the game but
also speeds up the review process by reducing back-and-forth questions and
clarifications. Remember, a well-prepared PR reflects well on you as a
contributor and helps maintain a high standard for the codebase.

## Test Your Code

Testing your code is a crucial part of our development process, especially when
contributing to a multiplayer game like SS13. While we're working on a
specialized article that will delve deeper into best practices for code testing,
this section will cover the essential aspects and front-facing impacts of
testing, as well as how to effectively communicate your testing efforts in your
pull request.

**The Basics of Code Testing**

At a bare minimum, your PR should indicate that you've successfully compiled
your code and tested it on a local test server. This basic step assures
reviewers and other team members that your code runs without immediate issues
and doesn't cause server crashes. However, thorough testing goes beyond just
ensuring the game compiles.

**Document Your Testing Process**

When documenting your testing, include detailed steps that you took to verify
your changes. This helps reviewers understand how you tested the functionality
and provides a reference for anyone else looking to verify your work. Consider
the following:

- **Feature Verification:** Describe how you verified that new features work as
  intended. For example, if you added a new item, detail how you tested its
  creation, usage, and any unique interactions it might have.
- **Edge Case Testing:** Test and document scenarios where players might use
  your feature in uncommon but predictable ways. This helps catch issues that
  may not be immediately obvious but could arise in actual gameplay.
- **Performance Considerations:** If your changes could impact game performance,
  mention how you tested for this. For example, if you introduced a new loop or
  complex logic, describe any stress tests or performance profiling you
  conducted.

**Communicate Testing Results**

In your PR description, clearly communicate the results of your testing. Did
everything work as expected? Were there any unexpected issues? If you
encountered bugs that you couldn't resolve, note them and explain why they are
there, how they affect the game, and if there are plans to address them later.

**The Importance of Thorough Testing**

Thorough testing is vital for maintaining the quality and stability of the game.
It helps prevent embarrassing situations where a new feature is eagerly
anticipated by players, only to be released in a broken or incomplete state.
Reverting a PR or dealing with numerous bug reports due to avoidable issues can
be frustrating for both the development team and players.

**Additional Resources**

For a more comprehensive guide on testing your PR, refer to the [Guide to
Testing](../coding/testing_guide.md). This resource will provide detailed
instructions and best practices for ensuring your changes are robust and
reliable. Testing your code is not just a technical necessity; it's a
professional courtesy to your fellow developers and the player community. By
taking the time to thoroughly test and document your changes, you contribute to
a more enjoyable and stable game experience for everyone.

## Conclusion

As someone who's been developing at Paradise for several years and has briefly
served as a head of staff, the quality of our community is of high importance to
me. This article is a call to our contributing community to elevate their pull
requests to a quality they can truly be proud of. While Paradise may not always
lead in content expansion or player counts, it consistently sets the standard
for professionalism and server quality. By adhering to the guidelines outlined
in this article, you can continue to help us maintain and enhance our reputation
as a top-tier server, known for its stability, thoughtful design, and vibrant
community. Let's work together to make our GitHub repository a better experience
for everyone who enjoys Paradise.
