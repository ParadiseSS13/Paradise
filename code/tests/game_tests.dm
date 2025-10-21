//include game test files in this module in this ifdef
//Keep this sorted alphabetically

#ifdef TEST_RUNNER
#include "_game_test_puppeteer.dm"
#include "_game_test.dm"
#include "_map_per_tile_test.dm"
#include "test_runner.dm"
#endif

#ifdef GAME_TESTS
#include "atmos\test_ventcrawl.dm"
#include "attack_chain\test_attack_chain_borgs.dm"
#include "attack_chain\test_attack_chain_cult_dagger.dm"
#include "attack_chain\test_attack_chain_machinery.dm"
#include "attack_chain\test_attack_chain_mobs.dm"
#include "attack_chain\test_attack_chain_reagent_containers.dm"
#include "attack_chain\test_attack_chain_structures.dm"
#include "attack_chain\test_attack_chain_stunbaton.dm"
#include "attack_chain\test_attack_chain_turf.dm"
#include "attack_chain\test_attack_chain_vehicles.dm"
#include "attack_chain\test_attack_chain_watercloset.dm"
#include "games\test_cards.dm"
#include "jobs\test_job_globals.dm"
#include "test_aicard_icons.dm"
#include "test_announcements.dm"
#include "test_anti_drop.dm"
#include "test_apc_construction.dm"
#include "test_components.dm"
#include "test_config_sanity.dm"
#include "test_cooking.dm"
#include "test_crafting_lists.dm"
#include "test_dynamic_budget.dm"
#include "test_elements.dm"
#include "test_emotes.dm"
#include "test_ensure_subtree_operational_datum.dm"
#include "test_init_sanity.dm"
#include "test_job_selection.dm"
#include "test_log_format.dm"
#include "test_map_templates.dm"
#include "test_missing_icons.dm"
#include "test_origin_tech.dm"
#include "test_purchase_reference_test.dm"
#include "test_reagent_id_typos.dm"
#include "test_rustg_version.dm"
#include "test_spawn_humans.dm"
#include "test_spell_targeting_test.dm"
#include "test_sql.dm"
#include "test_status_effect_ids.dm"
#include "test_subsystem_init.dm"
#include "test_subsystem_metric_sanity.dm"
#include "test_timer_sanity.dm"
#include "test_wears_collar.dm"
#endif

#ifdef MAP_TESTS
#include "test_areas_apcs.dm"
#include "test_map_tests.dm"
#endif
