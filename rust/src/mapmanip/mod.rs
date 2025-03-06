use core::map_to_string;
use core::to_grid_map;
use core::GridMap;

use byondapi::byond_string;
use byondapi::value::ByondValue;
use eyre::Context;
use eyre::ContextCompat;
use itertools::Itertools;
use rand::prelude::IteratorRandom;
use serde::{Deserialize, Serialize};
use tools::extract_submap;
use tools::insert_submap;

use crate::logging::dm_call_stack_trace;
use crate::logging::setup_panic_handler;

mod core;
mod tools;

#[cfg(test)]
mod test;

///
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(tag = "type")]
pub enum MapManipulation {
    SubmapExtractInsert {
        submap_size_x: i64,
        submap_size_y: i64,
        submap_size_z: i64,
        submaps_dmm: String,
        marker_extract: String,
        marker_insert: String,
        submaps_can_repeat: bool,
    },
}

pub fn mapmanip_config_parse(config_path: &std::path::Path) -> eyre::Result<Vec<MapManipulation>> {
    // read
    let config = std::fs::read_to_string(config_path)
        .wrap_err(format!("mapmanip config read err: {config_path:?}"))?;

    // strip comments
    // as the jsonc format is "json with comments"
    // but serde_json lib can only handle actual json
    let re = regex::Regex::new(r"\/\/.*")?;
    let config = re.replace_all(&config, "");

    // parse
    let config = serde_json::from_str::<Vec<MapManipulation>>(&config)
        .wrap_err(format!("mapmanip config json parse err: {config_path:?}"))?;

    Ok(config)
}

pub fn mapmanip(
    map_dir_path: &std::path::Path,
    map: dmmtools::dmm::Map,
    config: &Vec<MapManipulation>,
) -> eyre::Result<dmmtools::dmm::Map> {
    // convert to gridmap
    let mut map = to_grid_map(&map);

    // go through all the manipulations in `.jsonc` config for this `.dmm`
    for (n, manipulation) in config.iter().enumerate() {
        // readable index for errors
        let n = n + 1;
        let config_len = config.len();

        match manipulation {
            MapManipulation::SubmapExtractInsert {
                submap_size_x,
                submap_size_y,
                submap_size_z,
                submaps_dmm,
                marker_extract,
                marker_insert,
                submaps_can_repeat,
            } => mapmanip_submap_extract_insert(
                map_dir_path,
                &mut map,
                *submap_size_x,
                *submap_size_y,
                *submap_size_z,
                submaps_dmm,
                marker_extract,
                marker_insert,
                *submaps_can_repeat,
            )
            .wrap_err(format!(
                "submap extract insert fail;
					submaps path: {submaps_dmm:?};
					markers: {marker_extract}, {marker_insert};"
            )),
        }
        .wrap_err(format!("mapmanip fail; manip n is: {n}/{config_len}"))?;
    }

    Ok(core::to_dict_map(&map).wrap_err("failed on `to_dict_map`")?)
}

fn mapmanip_submap_extract_insert(
    map_dir_path: &std::path::Path,
    map: &mut GridMap,
    submap_size_x: i64,
    submap_size_y: i64,
    submap_size_z: i64,
    submaps_dmm: &String,
    marker_extract: &String,
    marker_insert: &String,
    submaps_can_repeat: bool,
) -> eyre::Result<()> {
    let submap_size = dmmtools::dmm::Coord3::new(
        submap_size_x.try_into().wrap_err("invalid submap_size_x")?,
        submap_size_y.try_into().wrap_err("invalid submap_size_y")?,
        submap_size_z.try_into().wrap_err("invalid submap_size_z")?,
    );

    // get the submaps map
    let submaps_dmm: std::path::PathBuf = submaps_dmm.try_into().wrap_err("invalid path")?;
    let submaps_dmm = map_dir_path.join(submaps_dmm);
    let submaps_map = GridMap::from_file(&submaps_dmm)
        .wrap_err(format!("can't read and parse submap dmm: {submaps_dmm:?}"))?;

    // find all the submap extract markers
    let mut marker_extract_coords = vec![];
    for (coord, tile) in submaps_map.grid.iter() {
        if tile.prefabs.iter().any(|p| p.path == *marker_extract) {
            marker_extract_coords.push(coord);
        }
    }

    // find all the insert markers
    let mut marker_insert_coords = vec![];
    for (coord, tile) in map.grid.iter() {
        if tile.prefabs.iter().any(|p| p.path == *marker_insert) {
            marker_insert_coords.push(coord);
        }
    }

    // do all the extracts-inserts
    for insert_coord in marker_insert_coords {
        // pick a submap
        let (extract_coord_index, extract_coord) = marker_extract_coords
            .iter()
            .cloned()
            .enumerate()
            .choose(&mut rand::thread_rng())
            .wrap_err(format!(
                "can't pick a submap to extract; no more extract markers in the submaps dmm; marker type: {marker_extract}"
            ))?;

        // if submaps should not be repeating, remove this one from the list
        if !submaps_can_repeat {
            marker_extract_coords.remove(extract_coord_index);
        }

        // extract that submap from the submap dmm
        let extracted = extract_submap(&submaps_map, extract_coord, submap_size)
            .wrap_err(format!("submap extraction failed; from {extract_coord}"))?;

        // and insert the submap into the manipulated map
        insert_submap(&extracted, insert_coord, map)
            .wrap_err(format!("submap insertion failed; at {insert_coord}"))?;
    }

    Ok(())
}

///
#[byondapi::bind]
fn mapmanip_read_dmm_file(path: ByondValue) -> eyre::Result<ByondValue> {
    internal_mapmanip_read_dmm_file(path)
}

pub(crate) fn internal_mapmanip_read_dmm_file(path: ByondValue) -> eyre::Result<ByondValue> {
    setup_panic_handler();

    let path: String = path
        .get_string()
        .wrap_err(format!("path arg is not a string: {:?}", path))?;
    let path: std::path::PathBuf = path
        .clone()
        .try_into()
        .wrap_err(format!("path arg is not a valid file path: {}", path))?;

    // just return null if path is bad for whatever reason
    if !path.is_file() || !path.exists() {
        return Ok(ByondValue::null());
    }

    // read file and parse with spacemandmm
    let mut dmm = dmmtools::dmm::Map::from_file(&path).wrap_err(format!(
        "spacemandmm parsing error; dmm file path: {path:?}; see error from spacemandmm below for more information"
    ))?;

    // do mapmanip if defined for this dmm
    let path_mapmanip_config = {
        let mut p = path.clone();
        p.set_extension("jsonc");
        p
    };
    if path_mapmanip_config.exists() {
        // get path for dir of this dmm
        let path_dir = path.parent().wrap_err("no parent")?;
        // parse config
        let config = crate::mapmanip::mapmanip_config_parse(&path_mapmanip_config).wrap_err(
            format!("config parse fail; path: {:?}", path_mapmanip_config),
        )?;
        // do actual map manipulation
        dmm = crate::mapmanip::mapmanip(path_dir, dmm, &config)
            .wrap_err(format!("mapmanip fail; dmm file path: {path:?}"))?;
    }

    // convert the map back to a string
    let dmm = crate::mapmanip::core::map_to_string(&dmm).wrap_err(format!(
        "error in converting map back to string; dmm file path: {path:?}"
    ))?;

    // and return it
    Ok(ByondValue::new_str(dmm)?)
}

///
#[no_mangle]
pub unsafe extern "C" fn read_dmm_file_ffi(
    argc: byondapi::sys::u4c,
    argv: *mut byondapi::value::ByondValue,
) -> byondapi::value::ByondValue {
    setup_panic_handler();
    let args = unsafe { ::byondapi::parse_args(argc, argv) };
    match crate::mapmanip::internal_mapmanip_read_dmm_file(
        args.get(0).map(ByondValue::clone).unwrap_or_default(),
    ) {
        Ok(val) => val,
        Err(info) => {
            let _ = dm_call_stack_trace(format!("Rustlibs ERROR read_dmm_file_ffi() \n {info:#?}"));
            ByondValue::null()
        }
    }
}

/// To be used by the `tools/rustlib_tools/mapmanip.ps1` script.
/// Not to be called from the game server, so bad error-handling is fine.
/// This should run map manipulations on every `.dmm` map that has a `.jsonc` config file,
/// and write it to a `.mapmanipout.dmm` file in the same location.
#[no_mangle]
pub unsafe extern "C" fn all_mapmanip_configs_execute_ffi() {
    let mapmanip_configs = walkdir::WalkDir::new("./_maps")
        .into_iter()
        .map(|d| d.unwrap().path().to_owned())
        .filter(|p| p.extension().is_some())
        .filter(|p| p.extension().unwrap() == "jsonc")
        .collect_vec();
    assert_ne!(mapmanip_configs.len(), 0);

    for config_path in mapmanip_configs {
        let dmm_path = {
            let mut p = config_path.clone();
            p.set_extension("dmm");
            p
        };

        let path_dir: &std::path::Path = dmm_path.parent().unwrap();

        let mut dmm = dmmtools::dmm::Map::from_file(&dmm_path).unwrap();

        let config = crate::mapmanip::mapmanip_config_parse(&config_path).unwrap();

        dmm = crate::mapmanip::mapmanip(path_dir, dmm, &config).unwrap();

        let dmm = map_to_string(&dmm).unwrap();

        let dmm_out_path = {
            let mut p = dmm_path.clone();
            p.set_extension("mapmanipout.dmm");
            p
        };
        std::fs::write(dmm_out_path, dmm).unwrap();
    }
}
