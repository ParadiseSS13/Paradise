#Python 3+ Script for jsonifying feedback table data as of 2017-11-12 made by Jordie0608
#Apologies for the boilerplated and squirrely code in parts, this has been my first foray into python
# Script modified for ParadiseSS13 as of 2020-12-21 by AffectedArc07
#
#Before starting ensure you have installed mysql-connector
#pip install mysql-connector
#
#To view the parameters for this script, execute it with the argument --help
#All the positional arguments are required, remember to include prefixes in your table names if you use them
#An example of the command used to execute this script from powershell:
#python feedback_conversion_2017-11-12.py "localhost" "root" "password" "feedback" "feedback" "feedback_2"
#I found that this script would complete conversion of 10000 rows approximately every 2-3 seconds
#Depending on the size of your feedback table and the computer used it may take several minutes for the script to finish
#
#The script has been tested to complete with Paradise's feedback table as of 2020-12-21
#Due to the complexity of data that has potentially changed formats multiple times and suffered errors when recording I cannot guarantee it'll always execute successfully
#In the event of an error the new feedback table is automatically truncated
#The source table is never modified so you don't have to worry about losing any data due to errors
#Note that some feedback keys are renamed or coalesced into one, additionnaly some have been entirely removed
#
#While this script can be run with your game server(s) active, it may interfere with other database operations and any feedback created after the script has started won't be converted
# AA: Dont run this with the server on. You WILL break things

import mysql.connector
import argparse
import json
import re
import sys
from datetime import datetime

def parse_text(details):
    if not details:
        return
    if details.startswith('"') and details.endswith('"'):
        details = details[1:-1] #the first and last " aren't removed by splitting the dictionary
        details = details.split('" | "')
    else:
        if "_" in details:
            details = details.split(' ')
    return details

def parse_tally(details):
    if not details:
        return
    overflowed = None
    if len(details) >= 65535: #a string this long means the data hit the 64KB character limit of TEXT columns
        overflowed = True
    if details.startswith('"') and details.endswith('"'):
        details = details[details.find('"')+1:details.rfind('"')] #unlike others some of the tally data has extra characters to remove
        split_details = details.split('" | "')
    else:
        split_details = details.split(' ')
    if overflowed:
        split_details = split_details[:-1] #since the string overflowed the last element will be incomplete and needs to be ignored
    details = {}
    for i in split_details:
        increment = 1
        if '|' in i and i[i.find('|')+1:]:
            increment = float(i[i.find('|')+1:])
            i = i[:i.find('|')]
        if i in details:
            details[i] += increment
        else:
            details[i] = increment
    for i in details:
        details[i] = '{0:g}'.format(details[i]) #remove .0 from floats that have it to conform with DM
    return details

def parse_nested(var_name, details):
    if not details:
        return
    #group by data before pipe
    if var_name in ("admin_toggle", "preferences_verb", "mining_equipment_bought", "vending_machine_usage", "changeling_powers", "wizard_spell_improved", "testmerged_prs"):
        if details.startswith('"') and details.endswith('"'):
            details = details[1:-1]
            split_details = details.split('" | "')
        else:
            split_details = details.split(' ')
        details = {}
        for i in split_details:
            if "|" in i and i[:i.find('|')] not in details:
                details[i[:i.find('|')]] = {}
            elif "|" not in i and i[i.find('|')+1:] not in details:
                details[i[i.find('|')+1:]] = 0
        for i in split_details:
            if "|" in i:
                if details[i[:i.find('|')]] is not dict:
                    continue
                if i[i.find('|')+1:] in details[i[:i.find('|')]]:
                    details[i[:i.find('|')]][i[i.find('|')+1:]] += 1
                else:
                    details[i[:i.find('|')]][i[i.find('|')+1:]] = 1
            else:
                if i in details and type(details[i]) is not dict: #sometimes keys that should have a value after a pipe just don't and would otherwise error here
                    details[i] += 1
        return details
    # Begin snowflakery for para changes
    elif var_name in ("traitor_objective", "job_objective", "cult_objective", "wizard_objective", "changeling_objective", "employee_objective"):
        split_details = details.split(' ')
        details = {}
        for i in split_details:
            if "|" in i and i[:i.find('|')] not in details:
                details[i[:i.find('|')]] = {}
        for i in split_details:
            if "|" in i:
                if i[i.find('|')+1:] in details[i[:i.find('|')]]:
                    details[i[:i.find('|')]][i[i.find('|')+1:]] += 1
                else:
                    details[i[:i.find('|')]][i[i.find('|')+1:]] = 1
        return details
    #group by data after pipe
    elif var_name in ("cargo_imports", "export_sold_cost", "item_used_for_combat", "played_url"):
        if details.startswith('"') and details.endswith('"'):
            details = details[1:-1]
            split_details = details.split('" | "')
        else:
            split_details = details.split(' ')
        details = {}
        for i in split_details:
            if i == i[i.rfind('|')+1:]: #there's no pipe and data to group by, so we fill it in
                i = "{0}|missing data".format(i)
            details[i[i.rfind('|')+1:]] = {}
        for i in split_details:
            if i == i[i.rfind('|')+1:]:
                i = "{0}|missing data".format(i)
            if i[:i.find('|')] in details[i[i.rfind('|')+1:]]:
                details[i[i.rfind('|')+1:]][i[:i.find('|')]] += 1
            else:
                details[i[i.rfind('|')+1:]][i[:i.find('|')]] = 1
        return details
    elif var_name == "hivelord_core":
        if details.startswith('"') and details.endswith('"'):
            details = details[1:-1]
            split_details = details.split('" | "')
        else:
            split_details = details.split(' ')
        details = {}
        for i in split_details:
            if i[:i.find('|')] not in details:
                details[i[:i.find('|')]] = {}
                if "used" in i:
                    if "used" not in details:
                        details[i[:i.find('|')]]["used"] = {}
        for i in split_details:
            if "used" in i:
                if "used" not in details[i[:i.find('|')]]:
                    details[i[:i.find('|')]]["used"] = {}
                    details[i[:i.find('|')]]["used"][i[i.rfind('|')+1:]] = 1
                else:
                    if i[i.rfind('|')+1:] in details[i[:i.find('|')]]["used"]:
                        details[i[:i.find('|')]]["used"][i[i.rfind('|')+1:]] += 1
                    else:
                        details[i[:i.find('|')]]["used"][i[i.rfind('|')+1:]] = 1
            elif "|" in i:
                if i[i.find('|')+1:] in details[i[:i.find('|')]]:
                    details[i[:i.find('|')]][i[i.find('|')+1:]] += 1
                else:
                    details[i[:i.find('|')]][i[i.find('|')+1:]] = 1
        return details
    elif var_name == "job_preferences":
        if details.startswith('"') and details.endswith('"'):
            details = details[1:-1]
            split_details = details.split('|-" | "|')
        else:
            split_details = details.split('|- |')
        details = {}
        for i in split_details:
            if i.startswith('|'):
                i = i[1:]
            if i[:i.find('|')] not in details:
                details[i[:i.find('|')]] = {}
        for i in split_details:
            if i.startswith('|'):
                i = i[1:]
            if i.endswith('-'):
                i = i[:-2]
            sub_split = i.split('|')
            job = sub_split[0]
            sub_split = sub_split[1:]
            for o in sub_split:
                details[job][o[:o.find('=')].lower()] = o[o.find('=')+1:]
        return details

def parse_associative(var_name, details):
    if not details:
        return
    if var_name == "colonies_dropped":
        if details.startswith('"') and details.endswith('"'):
            details = details[1:-1]
        split_details = details.split('|')
        details = {}
        details["1"] = {"x" : split_details[0], "y" : split_details[1], "z" : split_details[2]}
        return details
    elif var_name == "commendation":
        if details.startswith('"') and details.endswith('"'):
            details = details[1:-1]
        if '}" | "{' in details:
            split_details = details.split('}" | "{')
        else:
            split_details = details.split('} {')
        details = {}
        for i in split_details:
            params = []
            sub_split = i.split(',')
            for o in sub_split:
                o = re.sub('[^A-Za-z0-9 ]', '', o[o.find(':')+1:]) #remove all the formatting and escaped characters from being pre-encoded as json
                params.append(o)
            details[len(details)+1] = {"commender" : params[0], "commendee" : params[1], "medal" : params[2], "reason" : params[3]}
        return details
    elif var_name == "high_research_level":
        if details.startswith('"') and details.endswith('"'):
            details = details[1:-1]
            split_details = details.split('" | "')
        else:
            split_details = details.split(' ')
        details = {}
        levels = {}
        for i in split_details:
            x = {i[:-1] : i[-1:]}
            levels.update(x)
        details["1"] = levels
        return details

def parse_special(var_name, var_value, details):
    #old data is essentially a tally in text form
    if var_name == "immortality_talisman":
        if details.startswith('"') and details.endswith('"'):
            split_details = details.split('" | "')
        else:
            split_details = details.split(' ')
        return len(split_details)
    #now records channel names, so we have to fill in whats missing
    elif var_name == "newscaster_channels":
        details = var_value
        return details
    #all the channels got renamed, plus we ignore any with an amount of zero
    elif var_name == "radio_usage":
        if details.startswith('"') and details.endswith('"'):
            details = details[details.find('C'):-1]
            split_details = details.split('" | "')
        else:
            split_details = details.split(' ')
        details = {}
        new_keys = {"COM":"common", "SCI":"science", "HEA":"command", "MED":"medical", "ENG":"engineering", "SEC":"security", "DTH":"centcom", "SYN":"syndicate", "SRV":"service", "CAR":"supply", "OTH":"other", "PDA":"PDA", "RC":"request console"}
        for i in split_details:
            if i.endswith('0'):
                continue
            if i[:i.find('-')] not in new_keys:
                continue
            details[new_keys[i[:i.find('-')]]] = i[i.find('-')+1:]
        return details
    #all of the data tracked by this is invalid due to recording the incorrect type
    elif var_name == "shuttle_gib":
        return {"missing data":1}
    #all records have a  prefix of 'slimebirth_' that needs to be removed
    elif var_name == "slime_babies_born":
        if details.startswith('"') and details.endswith('"'):
            details = details[1:-1]
            split_details = details.split('" | "')
        else:
            split_details = details.split(' ')
        details = {}
        for i in split_details:
            if i[i.find('_')+1:].replace('_', ' ') in details:
                details[i[i.find('_')+1:].replace('_', ' ')] += 1
            else:
                details[i[i.find('_')+1:].replace('_', ' ')] = 1
        return details
    #spaces were replaced by underscores, we need to undo this
    elif var_name == "slime_core_harvested":
        if details.startswith('"') and details.endswith('"'):
            details = details[1:-1]
            split_details = details.split('" | "')
        else:
            split_details = details.split(' ')
        details = {}
        for i in split_details:
            if i.replace('_', ' ') in details:
                details[i.replace('_', ' ')] += 1
            else:
                details[i.replace('_', ' ')] = 1
        return details

def parse_multirow(var_name, var_value, details, multirows_completed):
    if var_name in ("ahelp_close", "ahelp_icissue", "ahelp_reject", "ahelp_reopen", "ahelp_resolve", "ahelp_unresolved"):
        ahelp_vars = {"ahelp_close":"closed", "ahelp_icissue":"IC", "ahelp_reject":"rejected", "ahelp_reopen":"reopened", "ahelp_resolve":"resolved", "ahelp_unresolved":"unresolved"}
        details = {ahelp_vars[var_name]:var_value}
        del ahelp_vars[var_name]
        query_where = "round_id = {0} AND (".format(query_row[2])
        for c, i in enumerate(ahelp_vars):
            if c:
                query_where += " OR "
            query_where += "var_name = \"{0}\"".format(i)
        query_where += ")"
        cursor.execute("SELECT var_name, var_value FROM {0} WHERE {1}".format(current_table, query_where))
        rows = cursor.fetchall()
        if rows:
            for r in rows:
                details[ahelp_vars[r[0]]] = r[1]
        keys = list(ahelp_vars.keys())
        keys.append(var_name)
        multirows_completed += keys
        return details
    elif var_name in ("alert_comms_blue", "alert_comms_green"):
        level_vars = {"alert_comms_blue":"1", "alert_comms_green":"0"}
        details = {level_vars[var_name]:var_value}
        del  level_vars[var_name]
        i = list(level_vars)[0]
        cursor.execute("SELECT var_value FROM {0} WHERE round_id = {1} AND var_name = \"{2}\"".format(current_table, query_row[2], i))
        row = cursor.fetchone()
        if row:
            details[level_vars[i]] = row[0]
        keys = list(level_vars.keys())
        keys.append(var_name)
        multirows_completed += keys
        return details
    elif var_name in ("alert_keycard_auth_bsa", "alert_keycard_auth_maint"):
        auth_vars = {"alert_keycard_auth_maint":("emergency maintenance access", "enabled"), "alert_keycard_auth_bsa":("bluespace artillery", "unlocked")}
        i = list(auth_vars[var_name])
        details = {i[0]:{i[1]:var_value}}
        del auth_vars[var_name]
        i = list(auth_vars)[0]
        cursor.execute("SELECT var_value FROM {0} WHERE round_id = {1} AND var_name = \"{2}\"".format(current_table, query_row[2], i))
        row = cursor.fetchone()
        if row:
            o = list(auth_vars[i])
            details[o[0]] = {o[1]:row[0]}
        keys = list(auth_vars.keys())
        keys.append(var_name)
        multirows_completed += keys
        return details
    elif var_name in ("arcade_loss_hp_emagged", "arcade_loss_hp_normal", "arcade_loss_mana_emagged", "arcade_loss_mana_normal", "arcade_win_emagged", "arcade_win_normal"):
        result_vars = {"arcade_loss_hp_emagged":("loss", "hp", "emagged"), "arcade_loss_hp_normal":("loss", "hp", "normal"), "arcade_loss_mana_emagged":("loss", "mana", "emagged"), "arcade_loss_mana_normal":("loss", "mana", "normal"), "arcade_win_emagged":("win", "emagged"), "arcade_win_normal":("win", "normal")}
        i = list(result_vars[var_name])
        del result_vars[var_name]
        if i[0] == "loss":
            details = {i[0]:{i[1]:{i[2]:var_value}}}
        else:
            details = {i[0]:{i[1]:var_value}}
        query_where = "round_id = {0} AND (".format(query_row[2])
        for c, i in enumerate(result_vars):
            if c:
                query_where += " OR "
            query_where += "var_name = \"{0}\"".format(i)
        query_where += ")"
        cursor.execute("SELECT var_name, var_value FROM {0} WHERE {1}".format(current_table, query_where))
        rows = cursor.fetchall()
        if rows:
            for r in rows:
                i = list(result_vars[r[0]])
                if i[0] not in details:
                    details[i[0]] = {}
                if i[0] == "loss":
                    if i[1] not in details[i[0]]:
                        details[i[0]][i[1]] = {}
                    details[i[0]][i[1]][i[2]] = r[1]
                else:
                    details[i[0]][i[1]] = r[1]
        keys = list(result_vars.keys())
        keys.append(var_name)
        multirows_completed += keys
        return details
    elif var_name in ("cyborg_engineering", "cyborg_janitor", "cyborg_medical", "cyborg_miner", "cyborg_peacekeeper", "cyborg_security", "cyborg_service", "cyborg_standard"):
        module_vars = {"cyborg_engineering":"Engineering", "cyborg_janitor":"Janitor", "cyborg_medical":"Medical", "cyborg_miner":"Miner", "cyborg_peacekeeper":"Peacekeeper", "cyborg_security":"Security", "cyborg_service":"Service", "cyborg_standard":"Standard"}
        details = {module_vars[var_name]:var_value}
        del module_vars[var_name]
        query_where = "round_id = {0} AND (".format(query_row[2])
        for c, i in enumerate(module_vars):
            if c:
                query_where += " OR "
            query_where += "var_name = \"{0}\"".format(i)
        query_where += ")"
        cursor.execute("SELECT var_name, var_value FROM {0} WHERE {1}".format(current_table, query_where))
        rows = cursor.fetchall()
        if rows:
            for r in rows:
                details[module_vars[r[0]]] = r[1]
        keys = list(module_vars.keys())
        keys.append(var_name)
        multirows_completed += keys
        return details
    elif var_name in ("escaped_human", "escaped_total", "round_end_clients", "round_end_ghosts", "survived_human", "survived_total"):
        round_vars = {"escaped_human":("escapees", "human"), "escaped_total":("escapees", "total"), "round_end_clients":("clients"), "round_end_ghosts":("ghosts"), "survived_human":("survivors", "human"), "survived_total":("survivors", "total")}
        if var_name in ("round_end_clients", "round_end_ghosts"):
            i = round_vars[var_name]
            details = {i:var_value}
        else:
            i = list(round_vars[var_name])
            details = {i[0]:{i[1]:var_value}}
        del round_vars[var_name]
        query_where = "round_id = {0} AND (".format(query_row[2])
        for c, i in enumerate(round_vars):
            if c:
                query_where += " OR "
            query_where += "var_name = \"{0}\"".format(i)
        query_where += ")"
        cursor.execute("SELECT var_name, var_value FROM {0} WHERE {1}".format(current_table, query_where))
        rows = cursor.fetchall()
        if rows:
            for r in rows:
                if r[0] in ("round_end_clients", "round_end_ghosts"):
                    i = round_vars[r[0]]
                    details[i] = r[1]
                else:
                    i = list(round_vars[r[0]])
                    if i[0] not in details:
                        details[i[0]] = {}
                    details[i[0]][i[1]] = r[1]
        keys = list(round_vars.keys())
        keys.append(var_name)
        multirows_completed += keys
        return details
    elif var_name in ("mecha_durand_created", "mecha_firefighter_created", "mecha_gygax_created", "mecha_honker_created", "mecha_odysseus_created", "mecha_phazon_created", "mecha_ripley_created", "mecha_reticence_created"):
        mecha_vars ={"mecha_durand_created":"Durand", "mecha_firefighter_created":"Firefighter Ripley", "mecha_gygax_created":"Gygax", "mecha_honker_created":"Honker", "mecha_odysseus_created":"Odysseus", "mecha_phazon_created":"Phazon", "mecha_ripley_created":"Ripley", "mecha_reticence_created":"Reticence"}
        details = {mecha_vars[var_name]:var_value}
        del mecha_vars[var_name]
        query_where = "round_id = {0} AND (".format(query_row[2])
        for c, i in enumerate(mecha_vars):
            if c:
                query_where += " OR "
            query_where += "var_name = \"{0}\"".format(i)
        query_where += ")"
        cursor.execute("SELECT var_name, var_value FROM {0} WHERE {1}".format(current_table, query_where))
        rows = cursor.fetchall()
        if rows:
            for r in rows:
                details[mecha_vars[r[0]]] = r[1]
        keys = list(mecha_vars.keys())
        keys.append(var_name)
        multirows_completed += keys
        return details

def pick_parsing(var_name, var_value, details, multirows_completed):
    if var_name in text_keys:
        return parse_text(details)
    elif var_name in amount_keys:
        return var_value
    elif var_name in simple_tallies:
        return parse_tally(details)
    elif var_name in nested_tallies:
        return parse_nested(var_name, details)
    elif var_name in associatives:
        return parse_associative(var_name, details)
    elif var_name in special_cases:
        return parse_special(var_name, var_value, details)
    elif var_name in multirow:
        return parse_multirow(var_name, var_value, details, multirows_completed)
    else:
        return False

if sys.version_info[0] < 3:
    raise Exception("Python must be at least version 3 for this script.")
text_keys = ["religion_book", "religion_deity", "religion_name", "shuttle_fasttravel", "shuttle_manipulator", "shuttle_purchase", "shuttle_reason", "station_renames", "chaplain_weapon"]
amount_keys = ["admin_cookies_spawned", "cyborg_ais_created", "cyborg_frames_built", "cyborg_mmis_filled", "newscaster_newspapers_printed", "newscaster_stories", "nuclear_challenge_mode", "cyborg_birth", "newscaster_channels", "spacepod_created"]
simple_tallies = ["admin_secrets_fun_used", "admin_verb", "assembly_made", "brother_success", "cell_used", "changeling_power_purchase", "changeling_success", "chemical_reaction", "circuit_printed", "clockcult_scripture_recited", "contamination", "cult_runes_scribed", "engine_started", "employee_success", "event_admin_cancelled", "event_ran", "food_harvested", "food_made", "gun_fired", "handcuffs", "item_deconstructed", "item_printed", "jaunter", "lazarus_injector", "mining_voucher_redeemed", "mobs_killed_mining", "object_crafted", "ore_mined", "pick_used_mining", "slime_cores_used", "spacepod_created", "surgeries_completed", "time_dilation_current", "traitor_random_uplink_items_gotten", "traitor_success", "voice_of_god", "warp_cube", "wisp_lantern", "wizard_spell_learned", "wizard_success", "zone_targeted"]
nested_tallies = ["admin_toggle", "cargo_imports", "changeling_objective", "changeling_powers", "cult_objective", "employee_objective", "export_sold_cost", "hivelord_core", "item_used_for_combat", "job_preferences", "mining_equipment_bought", "played_url", "preferences_verb", "testmerged_prs", "traitor_objective", "vending_machine_usage", "wizard_objective", "wizard_spell_improved"]
associatives = ["colonies_dropped", "commendation"]
special_cases = ["immortality_talisman", "radio_usage", "shuttle_gib", "slime_babies_born", "slime_core_harvested"]
multirow = ["ahelp_close", "ahelp_icissue", "ahelp_reject", "ahelp_reopen", "ahelp_resolve", "ahelp_unresolved", "alert_comms_blue", "alert_comms_green", "alert_keycard_auth_bsa", "alert_keycard_auth_maint", "arcade_loss_hp_emagged", "arcade_loss_hp_normal", "arcade_loss_mana_emagged", "arcade_loss_mana_normal", "arcade_win_emagged", "arcade_win_normal", "cyborg_engineering", "cyborg_janitor", "cyborg_medical", "cyborg_miner", "cyborg_peacekeeper", "cyborg_security", "cyborg_service", "cyborg_standard", "escaped_human", "escaped_total", "mecha_durand_created", "mecha_firefighter_created", "mecha_gygax_created", "mecha_honker_created", "mecha_odysseus_created", "mecha_phazon_created", "mecha_ripley_created", "round_end_clients", "round_end_ghosts", "survived_human", "survived_total"]
renames = {"ahelp_stats":["ahelp_close", "ahelp_icissue", "ahelp_reject", "ahelp_reopen", "ahelp_resolve", "ahelp_unresolved"], "ais_created":["cyborg_ais_created"], "arcade_status":["arcade_loss_hp_emagged", "arcade_loss_hp_normal", "arcade_loss_mana_emagged", "arcade_loss_mana_normal", "arcade_win_emagged", "arcade_win_normal"], "cyborg_modules":["cyborg_engineering", "cyborg_janitor", "cyborg_medical", "cyborg_miner", "cyborg_peacekeeper", "cyborg_security", "cyborg_service", "cyborg_standard"], "immortality_talisman_uses":["immortality_talisman"], "keycard_auths":["alert_keycard_auth_bsa", "alert_keycard_auth_maint"], "mechas_created":["mecha_durand_created", "mecha_firefighter_created", "mecha_gygax_created", "mecha_honker_created", "mecha_odysseus_created", "mecha_phazon_created", "mecha_ripley_created"], "mmis_filled":["cyborg_mmis_filled"], "newspapers_printed":["newscaster_newspapers_printed"], "round_end_stats":["escaped_human", "escaped_total", "round_end_clients", "round_end_ghosts", "survived_human", "survived_total"], "security_level_changes":["alert_comms_blue", "alert_comms_green"]}
key_types = {"amount":["ais_created", "immortality_talisman_uses", "mmis_filled", "newspapers_printed", "admin_cookies_spawned", "cyborg_frames_built", "newscaster_stories", "nuclear_challenge_mode", "newscaster_channels", "cyborg_birth", "spacepod_created"],
"associative":["colonies_dropped", "commendation"],
"nested tally":["admin_toggle", "arcade_status", "cargo_imports", "changeling_objective", "changeling_powers", "cult_objective", "export_sold_cost", "hivelord_core", "item_used_for_combat", "job_preferences", "keycard_auths", "mining_equipment_bought", "played_url", "preferences_verb", "round_end_stats", "testmerged_prs", "traitor_objective", "vending_machine_usage", "wizard_objective", "wizard_spell_improved", "employee_objective"],
"tally":[ "admin_secrets_fun_used", "admin_verb", "ahelp_stats", "assembly_made", "brother_success", "cell_used", "changeling_power_purchase", "changeling_success", "chemical_reaction", "circuit_printed", "clockcult_scripture_recited", "contamination", "cult_runes_scribed", "cyborg_modules", "engine_started", "event_admin_cancelled", "event_ran", "food_harvested", "food_made", "gun_fired", "handcuffs", "item_deconstructed", "item_printed", "jaunter", "lazarus_injector", "mechas_created", "mining_voucher_redeemed", "mobs_killed_mining", "object_crafted", "ore_mined", "pick_used_mining", "radio_usage", "security_level_changes", "shuttle_gib", "slime_babies_born", "slime_cores_used", "slime_core_harvested", "surgeries_completed", "time_dilation_current", "traitor_random_uplink_items_gotten", "traitor_success", "voice_of_god", "warp_cube", "wisp_lantern", "wizard_spell_learned", "wizard_success", "zone_targeted", "employee_success"],
"text":["shuttle_fasttravel", "shuttle_manipulator", "shuttle_purchase", "shuttle_reason", "religion_book", "religion_deity", "religion_name", "station_renames", "chaplain_weapon"]}
multirows_completed = []
query_values = ""
current_round = 0
parser = argparse.ArgumentParser()
parser.add_argument("address", help="MySQL server address (use localhost for the current computer)")
parser.add_argument("username", help="MySQL login username")
parser.add_argument("password", help="MySQL login password")
parser.add_argument("database", help="Database name")
parser.add_argument("curtable", help="Name of the current feedback table (remember prefixes if you use them)")
parser.add_argument("newtable", help="Name of the new table to insert to, can't be same as the source table (remember prefixes)")
args = parser.parse_args()
db=mysql.connector.connect(host=args.address, user=args.username, passwd=args.password, db=args.database)
cursor=db.cursor()
current_table = args.curtable
new_table = args.newtable
cursor.execute("SELECT max(id) FROM {0}".format(current_table))
query_id = cursor.fetchone()
max_id = query_id[0]
start_time = datetime.now()
print("Beginning conversion at {0}".format(start_time.strftime("%Y-%m-%d %H:%M:%S")), flush = True)
try:
    # This is a range from 820,000 UPWARDS. Paradise feedback was flushed on 2018-03-22, and the row ID of the new start is around the 820k range
    # The script can handle empty rows just fine (and in this case, does), this just saves a LOT of time and useless querying -aa
    for current_id in range(820000, max_id):
        if current_id % 10000 == 0:
            cur_time = datetime.now()
            print("Reached row ID {0} Duration: {1}".format(current_id, cur_time - start_time), flush = True)
        cursor.execute("SELECT * FROM {0} WHERE id = {1}".format(current_table, current_id))
        query_row = cursor.fetchone()
        if not query_row:
            continue
        else:
            if current_round != query_row[2]:
                multirows_completed.clear()
                if query_values:
                    query_values = query_values[:-1]
                    query_values += ';'
                    cursor.execute("INSERT INTO {0} (datetime, round_id, key_name, key_type, version, json) VALUES {1}".format(new_table, query_values))
                    query_values = ""
            current_round = query_row[2]
            if query_row[3] in multirows_completed:
                continue
            parsed_data = pick_parsing(query_row[3], query_row[4], query_row[5], multirows_completed)
            if not parsed_data:
                continue
            json_data = {}
            json_data["data"] = parsed_data
            new_key = query_row[3]
            for r in renames:
                if new_key in renames[r]:
                    new_key = r
                    break
            new_key_type = None
            for t in key_types:
                if new_key in key_types[t]:
                    new_key_type = t
                    break
            dequoted_json = re.sub("\'", "\\'", json.dumps(json_data))
            query_values += "('{0}',{1},'{2}','{3}',{4},'{5}'),".format(query_row[1], query_row[2], new_key, new_key_type, 1, dequoted_json)
    end_time = datetime.now()
    print("Conversion completed at {0}".format(datetime.now().strftime("%Y-%m-%d %H:%M:%S")), flush = True)
    print("Script duration: {0}".format(end_time - start_time), flush = True)
except Exception as e:
    end_time = datetime.now()
    print("Error encountered on row ID {0} at {1}".format(current_id, datetime.now().strftime("%Y-%m-%d %H:%M:%S")), flush = True)
    print("Script duration: {0}".format(end_time - start_time), flush = True)
    cursor.execute("TRUNCATE {0} ".format(new_table))
    raise e
cursor.close()
db.commit()
