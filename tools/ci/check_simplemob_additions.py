import os
from pathlib import Path
import sys
import time

from avulto import DME, Path as p
from avulto.ast import SourceLoc


RED = "\033[0;31m"
GREEN = "\033[0;32m"
BLUE = "\033[0;34m"
NC = "\033[0m"  # No Color

BURNDOWN_LIST = {
    p(x)
    for x in {
        "/mob/living/simple_animal/bot",
        "/mob/living/simple_animal/bot/cleanbot",
        "/mob/living/simple_animal/bot/ed209",
        "/mob/living/simple_animal/bot/ed209/bluetag",
        "/mob/living/simple_animal/bot/ed209/redtag",
        "/mob/living/simple_animal/bot/ed209/syndicate",
        "/mob/living/simple_animal/bot/floorbot",
        "/mob/living/simple_animal/bot/honkbot",
        "/mob/living/simple_animal/bot/medbot",
        "/mob/living/simple_animal/bot/medbot/adv",
        "/mob/living/simple_animal/bot/medbot/brute",
        "/mob/living/simple_animal/bot/medbot/fire",
        "/mob/living/simple_animal/bot/medbot/fish",
        "/mob/living/simple_animal/bot/medbot/machine",
        "/mob/living/simple_animal/bot/medbot/mysterious",
        "/mob/living/simple_animal/bot/medbot/o2",
        "/mob/living/simple_animal/bot/medbot/syndicate",
        "/mob/living/simple_animal/bot/medbot/syndicate/emagged",
        "/mob/living/simple_animal/bot/medbot/tox",
        "/mob/living/simple_animal/bot/mulebot",
        "/mob/living/simple_animal/bot/secbot",
        "/mob/living/simple_animal/bot/secbot/armsky",
        "/mob/living/simple_animal/bot/secbot/beepsky",
        "/mob/living/simple_animal/bot/secbot/buzzsky",
        "/mob/living/simple_animal/bot/secbot/buzzsky/telecomms",
        "/mob/living/simple_animal/bot/secbot/buzzsky/telecomms/doomba",
        "/mob/living/simple_animal/bot/secbot/griefsky",
        "/mob/living/simple_animal/bot/secbot/griefsky/toy",
        "/mob/living/simple_animal/bot/secbot/ofitser",
        "/mob/living/simple_animal/bot/secbot/pingsky",
        "/mob/living/simple_animal/demon",
        "/mob/living/simple_animal/demon/pulse_demon",
        "/mob/living/simple_animal/demon/pulse_demon/wizard",
        "/mob/living/simple_animal/demon/shadow",
        "/mob/living/simple_animal/demon/slaughter",
        "/mob/living/simple_animal/demon/slaughter/cult",
        "/mob/living/simple_animal/demon/slaughter/laughter",
        "/mob/living/simple_animal/demon/slaughter/lesser",
        "/mob/living/simple_animal/drone",
        "/mob/living/simple_animal/hostile",
        "/mob/living/simple_animal/hostile/ancient_robot_leg",
        "/mob/living/simple_animal/hostile/asteroid",
        "/mob/living/simple_animal/hostile/asteroid/abandoned_minebot",
        "/mob/living/simple_animal/hostile/asteroid/elite",
        "/mob/living/simple_animal/hostile/asteroid/elite/broodmother",
        "/mob/living/simple_animal/hostile/asteroid/elite/broodmother_child",
        "/mob/living/simple_animal/hostile/asteroid/elite/herald",
        "/mob/living/simple_animal/hostile/asteroid/elite/herald/mirror",
        "/mob/living/simple_animal/hostile/asteroid/elite/legionnaire",
        "/mob/living/simple_animal/hostile/asteroid/elite/legionnairehead",
        "/mob/living/simple_animal/hostile/asteroid/elite/legionnairehead/xenobiology",
        "/mob/living/simple_animal/hostile/asteroid/elite/pandora",
        "/mob/living/simple_animal/hostile/clockwork_construct",
        "/mob/living/simple_animal/hostile/clockwork_construct/clockwork_marauder",
        "/mob/living/simple_animal/hostile/clockwork_construct/clockwork_marauder/hostile",
        "/mob/living/simple_animal/hostile/construct",
        "/mob/living/simple_animal/hostile/construct/armoured",
        "/mob/living/simple_animal/hostile/construct/armoured/hostile",
        "/mob/living/simple_animal/hostile/construct/behemoth",
        "/mob/living/simple_animal/hostile/construct/behemoth/hostile",
        "/mob/living/simple_animal/hostile/construct/builder",
        "/mob/living/simple_animal/hostile/construct/builder/hostile",
        "/mob/living/simple_animal/hostile/construct/harvester",
        "/mob/living/simple_animal/hostile/construct/harvester/hostile",
        "/mob/living/simple_animal/hostile/construct/proteon",
        "/mob/living/simple_animal/hostile/construct/proteon/hostile",
        "/mob/living/simple_animal/hostile/construct/wraith",
        "/mob/living/simple_animal/hostile/construct/wraith/hostile",
        "/mob/living/simple_animal/hostile/construct/wraith/hostile/bubblegum",
        "/mob/living/simple_animal/hostile/deathsquid",
        "/mob/living/simple_animal/hostile/deathsquid/joke",
        "/mob/living/simple_animal/hostile/floor_cluwne",
        "/mob/living/simple_animal/hostile/guardian",
        "/mob/living/simple_animal/hostile/guardian/assassin",
        "/mob/living/simple_animal/hostile/guardian/beam",
        "/mob/living/simple_animal/hostile/guardian/bomb",
        "/mob/living/simple_animal/hostile/guardian/charger",
        "/mob/living/simple_animal/hostile/guardian/gaseous",
        "/mob/living/simple_animal/hostile/guardian/healer",
        "/mob/living/simple_animal/hostile/guardian/healer/sealhealer",
        "/mob/living/simple_animal/hostile/guardian/protector",
        "/mob/living/simple_animal/hostile/guardian/punch",
        "/mob/living/simple_animal/hostile/guardian/punch/sealpunch",
        "/mob/living/simple_animal/hostile/guardian/ranged",
        "/mob/living/simple_animal/hostile/headslug",
        "/mob/living/simple_animal/hostile/illusion",
        "/mob/living/simple_animal/hostile/illusion/cult",
        "/mob/living/simple_animal/hostile/illusion/escape",
        "/mob/living/simple_animal/hostile/illusion/escape/cult",
        "/mob/living/simple_animal/hostile/illusion/escape/stealth",
        "/mob/living/simple_animal/hostile/illusion/mirage",
        "/mob/living/simple_animal/hostile/megafauna",
        "/mob/living/simple_animal/hostile/megafauna/ancient_robot",
        "/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner",
        "/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/guidance",
        "/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/hunter",
        "/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/syndicate",
        "/mob/living/simple_animal/hostile/megafauna/bubblegum",
        "/mob/living/simple_animal/hostile/megafauna/bubblegum/hallucination",
        "/mob/living/simple_animal/hostile/megafauna/bubblegum/round_2",
        "/mob/living/simple_animal/hostile/megafauna/colossus",
        "/mob/living/simple_animal/hostile/megafauna/dragon",
        "/mob/living/simple_animal/hostile/megafauna/dragon/lesser",
        "/mob/living/simple_animal/hostile/megafauna/dragon/space_dragon",
        "/mob/living/simple_animal/hostile/megafauna/fleshling",
        "/mob/living/simple_animal/hostile/megafauna/hierophant",
        "/mob/living/simple_animal/hostile/megafauna/legion",
        "/mob/living/simple_animal/hostile/mimic",
        "/mob/living/simple_animal/hostile/mimic/copy",
        "/mob/living/simple_animal/hostile/mimic/copy/machine",
        "/mob/living/simple_animal/hostile/mimic/copy/ranged",
        "/mob/living/simple_animal/hostile/mimic/copy/vendor",
        "/mob/living/simple_animal/hostile/mimic/crate",
        "/mob/living/simple_animal/hostile/morph",
        "/mob/living/simple_animal/hostile/morph/wizard",
        "/mob/living/simple_animal/hostile/mushroom",
        "/mob/living/simple_animal/hostile/poison",
        "/mob/living/simple_animal/hostile/poison/bees",
        "/mob/living/simple_animal/hostile/poison/bees/queen",
        "/mob/living/simple_animal/hostile/poison/bees/syndi",
        "/mob/living/simple_animal/hostile/poison/terror_spider",
        "/mob/living/simple_animal/hostile/poison/terror_spider/black",
        "/mob/living/simple_animal/hostile/poison/terror_spider/brown",
        "/mob/living/simple_animal/hostile/poison/terror_spider/gray",
        "/mob/living/simple_animal/hostile/poison/terror_spider/green",
        "/mob/living/simple_animal/hostile/poison/terror_spider/mother",
        "/mob/living/simple_animal/hostile/poison/terror_spider/prince",
        "/mob/living/simple_animal/hostile/poison/terror_spider/purple",
        "/mob/living/simple_animal/hostile/poison/terror_spider/queen",
        "/mob/living/simple_animal/hostile/poison/terror_spider/queen/empress",
        "/mob/living/simple_animal/hostile/poison/terror_spider/queen/princess",
        "/mob/living/simple_animal/hostile/poison/terror_spider/red",
        "/mob/living/simple_animal/hostile/poison/terror_spider/white",
        "/mob/living/simple_animal/hostile/retaliate",
        "/mob/living/simple_animal/hostile/retaliate/carp",
        "/mob/living/simple_animal/hostile/retaliate/carp/koi",
        "/mob/living/simple_animal/hostile/retaliate/carp/koi/honk",
        "/mob/living/simple_animal/hostile/spaceinfected",
        "/mob/living/simple_animal/hostile/spaceinfected/default",
        "/mob/living/simple_animal/hostile/spaceinfected/default/ranged",
        "/mob/living/simple_animal/hostile/spaceinfected/gateopener",
        "/mob/living/simple_animal/hostile/statue",
        "/mob/living/simple_animal/hostile/syndicate",
        "/mob/living/simple_animal/hostile/syndicate/depot",
        "/mob/living/simple_animal/hostile/syndicate/depot/modsuit",
        "/mob/living/simple_animal/hostile/syndicate/depot/modsuit/backup",
        "/mob/living/simple_animal/hostile/syndicate/depot/modsuit/elite",
        "/mob/living/simple_animal/hostile/syndicate/depot/officer",
        "/mob/living/simple_animal/hostile/syndicate/modsuit",
        "/mob/living/simple_animal/hostile/syndicate/modsuit/elite",
        "/mob/living/simple_animal/hostile/syndicate/modsuit/ranged",
        "/mob/living/simple_animal/hostile/syndicate/ranged",
        "/mob/living/simple_animal/hostile/syndicate/ranged/orion",
        "/mob/living/simple_animal/hostile/syndicate/shield",
        "/mob/living/simple_animal/hostile/venus_human_trap",
        "/mob/living/simple_animal/hostile/winter",
        "/mob/living/simple_animal/hostile/winter/reindeer",
        "/mob/living/simple_animal/hostile/winter/santa",
        "/mob/living/simple_animal/hostile/winter/santa/stage_1",
        "/mob/living/simple_animal/hostile/winter/santa/stage_2",
        "/mob/living/simple_animal/hostile/winter/santa/stage_3",
        "/mob/living/simple_animal/hostile/winter/santa/stage_4",
        "/mob/living/simple_animal/hostile/winter/snowman",
        "/mob/living/simple_animal/hostile/winter/snowman/ranged",
        "/mob/living/simple_animal/parrot",
        "/mob/living/simple_animal/parrot/poly",
        "/mob/living/simple_animal/pet",
        "/mob/living/simple_animal/pet/cat",
        "/mob/living/simple_animal/pet/cat/cak",
        "/mob/living/simple_animal/pet/cat/kitten",
        "/mob/living/simple_animal/pet/cat/proc_cat",
        "/mob/living/simple_animal/pet/cat/runtime",
        "/mob/living/simple_animal/pet/cat/syndi",
        "/mob/living/simple_animal/pet/cat/var_cat",
        "/mob/living/simple_animal/pet/dog",
        "/mob/living/simple_animal/pet/dog/corgi",
        "/mob/living/simple_animal/pet/dog/corgi/borgi",
        "/mob/living/simple_animal/pet/dog/corgi/exoticcorgi",
        "/mob/living/simple_animal/pet/dog/corgi/ian",
        "/mob/living/simple_animal/pet/dog/corgi/lisa",
        "/mob/living/simple_animal/pet/dog/corgi/narsie",
        "/mob/living/simple_animal/pet/dog/corgi/puppy",
        "/mob/living/simple_animal/pet/dog/corgi/puppy/void",
        "/mob/living/simple_animal/pet/dog/fox",
        "/mob/living/simple_animal/pet/dog/fox/renault",
        "/mob/living/simple_animal/pet/dog/fox/syndifox",
        "/mob/living/simple_animal/pet/dog/pug",
        "/mob/living/simple_animal/revenant",
        "/mob/living/simple_animal/shade",
        "/mob/living/simple_animal/shade/cult",
        "/mob/living/simple_animal/shade/holy",
        "/mob/living/simple_animal/shade/sword",
        "/mob/living/simple_animal/shade/sword/generic_item",
        "/mob/living/simple_animal/slime",
        "/mob/living/simple_animal/slime/pet",
        "/mob/living/simple_animal/slime/random",
        "/mob/living/simple_animal/slime/unit_test_dummy",
    }
}


def format_error(source_loc: SourceLoc | Path, message):
    if isinstance(source_loc, SourceLoc):
        if os.getenv("GITHUB_ACTIONS") == "true":
            return f"::error file={source_loc.file_path},line={source_loc.line},title=Simplemob Additions::{source_loc.file_path}:{source_loc.line}: {RED}{message}{NC}"
        else:
            return f"{source_loc.file_path}:{source_loc.line}: {RED}{message}{NC}"
    else:
        if os.getenv("GITHUB_ACTIONS") == "true":
            return f"::error file={source_loc},title=Simplemob Additions::{source_loc}: {RED}{message}{NC}"
        else:
            return f"{source_loc}: {RED}{message}{NC}"


if __name__ == "__main__":
    print("check_simplemob_additions started")

    exit_code = 0
    start = time.time()

    dme = DME.from_file("paradise.dme")

    simplemobs = set(dme.subtypesof("/mob/living/simple_animal"))
    additions = simplemobs - BURNDOWN_LIST

    if additions:
        exit_code = 1
        print("unexpected simplemobs found:")
        type_decls = [dme.types[pth] for pth in additions]
        for type_decl in type_decls:
            print(
                format_error(
                    type_decl.source_loc,
                    f"unexpected simplemob addition {type_decl.path}.",
                )
            )
        print("Please implement all new mobs as /mob/living/basic mobs.")

    unexpected = BURNDOWN_LIST - simplemobs
    if unexpected:
        exit_code = 1
        print("the following paths were allowed but not found:")
        for pth in sorted(unexpected):
            print(
                format_error(
                    Path(__file__).relative_to(dme.filepath.resolve().parent),
                    f"stale path {pth}.",
                )
            )
        print("Please remove the offending paths from check_simplemob_additions.py.")

    end = time.time()
    print(f"check_simplemob_additions tests completed in {end - start:.2f}s\n")

    sys.exit(exit_code)
