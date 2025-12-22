use crate::jobs;
use byondapi::{prelude::ValueType, value::ByondValue};
use dashmap::DashMap;
use eyre::{eyre, Result};
use mysql::{
    consts::{ColumnFlags, ColumnType::*},
    prelude::Queryable,
    OptsBuilder, Params, Pool, PoolConstraints, PoolOpts, Value,
};
use once_cell::sync::Lazy;
use serde::{Deserialize, Serialize};
use serde_json::Number;
use std::{collections::HashMap, sync::atomic::AtomicUsize};
use std::{error::Error, time::Duration};

// ----------------------------------------------------------------------------
// Interface

const DEFAULT_PORT: u16 = 3306;
// The `mysql` crate defaults to 10 and 100 for these, but that is too large.
const DEFAULT_MIN_THREADS: usize = 1;
const DEFAULT_MAX_THREADS: usize = 10;

struct ConnectOptions {
    host: String,
    port: u16,
    user: String,
    pass: String,
    db_name: String,
    read_timeout: f32,
    write_timeout: f32,
    min_threads: usize,
    max_threads: usize,
}

struct LocalQuery {
    query: String,
    connection: String,
    params: Params,
}

// Needs to support serde shenanigans just so we can use the jobs system
// Gah
#[derive(Serialize, Deserialize)]
struct LocalResponse {
    status: String,
    // Most of these are optional so we can return the same class back
    affected: Option<u64>,
    last_insert_id: Option<u64>,
    //columns: Option<Vec<String>>,
    rows: Option<Vec<serde_json::Value>>,
}

#[byondapi::bind]
fn sql_connect_pool(options_p: ByondValue) -> Result<ByondValue> {
    let options: ConnectOptions = ConnectOptions {
        host: options_p.read_string("host").unwrap(),
        port: options_p.read_number("port").unwrap() as u16,
        user: options_p.read_string("user").unwrap(),
        pass: options_p.read_string("pass").unwrap(),
        db_name: options_p.read_string("db_name").unwrap(),
        read_timeout: options_p.read_number("read_timeout").unwrap(),
        write_timeout: options_p.read_number("write_timeout").unwrap(),
        min_threads: options_p.read_number("min_threads").unwrap() as usize,
        max_threads: options_p.read_number("max_threads").unwrap() as usize,
    };

    let target_type = ByondValue::new_str("/datum/db_connection_response")?;
    let mut response_datum = ByondValue::builtin_new(target_type, &[])?;

    match sql_connect(options) {
        Ok(v) => {
            response_datum
                .write_var("ok", &ByondValue::new_num(1 as f32))
                .unwrap();
            response_datum.write_var("handle", &ByondValue::new_str(v)?)?;
        }
        Err(e) => {
            let error_message = unwrap_box(e);
            response_datum
                .write_var("ok", &ByondValue::new_num(0 as f32))
                .unwrap();
            response_datum.write_var("error_message", &ByondValue::new_str(error_message)?)?;
        }
    }

    Ok(response_datum)
}

#[byondapi::bind]
fn sql_query_blocking(mut options_p: ByondValue) -> Result<ByondValue> {
    // Sort our params now
    let mut local_params: Params = Params::Empty;

    match options_p.read_list("arguments") {
        Ok(v) => local_params = byondlist_to_params(v), // Create params from a BYOND list,
        Err(_) => {}
    }

    let lq: LocalQuery = LocalQuery {
        query: options_p.read_string("sql").unwrap(),
        connection: options_p.read_string("connection").unwrap(),
        params: local_params,
    };

    match do_query(lq) {
        Ok(o) => {
            let query_response: LocalResponse = serde_json::from_str(&o).unwrap();

            query_data_to_byond(query_response, options_p)
        }
        Err(e) => {
            // Write error back to BYOND
            options_p
                .write_var("last_error", &ByondValue::new_str(unwrap_box(e)).unwrap())
                .unwrap()
        }
    };

    Ok(ByondValue::null())
}

#[byondapi::bind]
fn sql_query_async(mut options_p: ByondValue) -> Result<ByondValue> {
    let mut local_params: Params = Params::Empty;

    match options_p.read_list("arguments") {
        Ok(v) => local_params = byondlist_to_params(v), // Create params from a BYOND list,
        Err(_) => {}
    }

    let lq: LocalQuery = LocalQuery {
        query: options_p.read_string("sql").unwrap(),
        connection: options_p.read_string("connection").unwrap(),
        params: local_params,
    };

    let job_id = jobs::start(move || match do_query(lq) {
        Ok(o) => o,
        Err(e) => unwrap_box(e),
    });

    options_p.write_var("query_id", &ByondValue::new_num(job_id as f32))?;
    options_p.write_var("in_progress", &ByondValue::new_num(1f32))?;

    Ok(ByondValue::null())
}

// hopefully won't panic if queries are running
#[byondapi::bind]
fn sql_disconnect_pool(options_p: ByondValue) -> Result<ByondValue> {
    let handle_p = options_p.get_string().unwrap();
    let handle = match handle_p.parse::<usize>() {
        Ok(o) => o,
        Err(e) => return Ok(ByondValue::new_str(unwrap_box(e)).unwrap()),
    };

    match POOL.remove(&handle) {
        Some(_) => return Ok(ByondValue::new_num(1f32)),
        None => return Ok(ByondValue::new_num(0f32)),
    }
}

#[byondapi::bind]
fn sql_connected(options_p: ByondValue) -> Result<ByondValue> {
    let handle_p = options_p.get_string().unwrap();
    let handle = match handle_p.parse::<usize>() {
        Ok(o) => o,
        Err(e) => return Ok(ByondValue::new_str(unwrap_box(e)).unwrap()),
    };

    match POOL.get(&handle) {
        Some(_) => return Ok(ByondValue::new_num(1f32)),
        None => return Ok(ByondValue::new_num(0f32)),
    }
}

#[byondapi::bind]
fn sql_check_query(mut query: ByondValue) -> Result<ByondValue> {
    // logging::setup_panic_handler();
    let id = query.read_var("query_id")?.get_number()? as usize;
    match jobs::check(&id) {
        // Job id exists, check progress
        Some(res) => match res {
            Ok(res) => match serde_json::from_str(&res) {
                Ok(v) => {
                    // It decoded fine
                    let query_response: LocalResponse = v;
                    query_data_to_byond(query_response, query);
                    query.write_var("last_error", &ByondValue::null())?;
                    query.write_var("in_progress", &ByondValue::new_num(0f32))?;
                    return Ok(ByondValue::null());
                }
                Err(e) => {
                    // It was not fine
                    if res.len() == 0 {
                        // But maybe it was
                        // Send us an dataset back
                        let localres: LocalResponse = LocalResponse {
                            status: "ok".to_string(),
                            affected: None,
                            last_insert_id: None,
                            rows: None,
                        };
                        query_data_to_byond(localres, query);
                        query.write_var("last_error", &ByondValue::null())?;
                        query.write_var("in_progress", &ByondValue::new_num(0f32))?;
                        return Ok(ByondValue::null());
                    } else {
                        // But it probably wasnt
                        query.write_var("last_error", &ByondValue::new_str(jobs::JOB_PANICKED)?)?;
                        query.write_var("in_progress", &ByondValue::new_num(0f32))?;
                        return Err(eyre!("{} - {}", e, &res));
                    }
                }
            },
            // Query still executed
            Err(flume::TryRecvError::Empty) => {
                query.write_var("last_error", &ByondValue::new_str(jobs::NO_RESULTS_YET)?)?;
                return Ok(ByondValue::null());
            }
            // Something bad happened during the query
            Err(flume::TryRecvError::Disconnected) => {
                query.write_var("last_error", &ByondValue::new_str(jobs::JOB_PANICKED)?)?;
                query.write_var("in_progress", &ByondValue::new_num(0f32))?;
                return Ok(ByondValue::null());
            }
        },
        // Job id does not exist
        None => {
            query.write_var(
                "last_error",
                &ByondValue::new_str(jobs::NO_SUCH_JOB).unwrap(),
            )?;

            return Ok(ByondValue::null());
        }
    }
}
/*
byond_fn!(fn sql_check_query(id) {
    Some(jobs::check(id))
});
*/

// ----------------------------------------------------------------------------
// Main connect and query implementation

static POOL: Lazy<DashMap<usize, Pool>> = Lazy::new(DashMap::new);
static NEXT_ID: AtomicUsize = AtomicUsize::new(0);

fn sql_connect(options: ConnectOptions) -> Result<String, Box<dyn Error>> {
    let pool_constraints =
        PoolConstraints::new(options.min_threads, options.max_threads).unwrap_or(
            PoolConstraints::new_const::<DEFAULT_MIN_THREADS, DEFAULT_MAX_THREADS>(),
        );

    let pool_opts = PoolOpts::with_constraints(PoolOpts::new(), pool_constraints);

    // Library wants optionals passed to this builder
    // I cant be arsed with that
    // -aa07
    let builder = OptsBuilder::new()
        .ip_or_hostname(Some(options.host))
        .tcp_port(options.port)
        // Work around addresses like `localhost:3307` defaulting to socket as
        // if the port were the default too.
        .prefer_socket(options.port == DEFAULT_PORT)
        .user(Some(options.user))
        .pass(Some(options.pass))
        .db_name(Some(options.db_name))
        .read_timeout(Some(Duration::from_secs_f32(options.read_timeout)))
        .write_timeout(Some(Duration::from_secs_f32(options.write_timeout)))
        .pool_opts(pool_opts);

    let pool = Pool::new(builder)?;

    let handle = NEXT_ID.fetch_add(1, std::sync::atomic::Ordering::Relaxed);
    POOL.insert(handle, pool);

    Ok(handle.to_string())
}

fn do_query(lq: LocalQuery) -> Result<String, Box<dyn Error>> {
    let mut conn = {
        let pool = match POOL.get(&lq.connection.parse()?) {
            Some(s) => s,
            None => {
                return Ok(serde_json::to_string(&LocalResponse {
                    status: "offline".to_string(),
                    affected: None,
                    //columns: None,
                    last_insert_id: None,
                    rows: None,
                })
                .unwrap());
            }
        };
        pool.get_conn()?
    };

    let query_result = conn.exec_iter(lq.query, lq.params)?;
    let affected = query_result.affected_rows();
    let last_insert_id = query_result.last_insert_id();
    let mut columns = Vec::new();
    for col in query_result.columns().as_ref().iter() {
        let colstr = col.name_str().to_string();
        columns.push(colstr);
    }

    let mut rows: Vec<serde_json::Value> = Vec::new();
    for row in query_result {
        let row = row?;
        let mut json_row: Vec<serde_json::Value> = Vec::new();
        for (i, col) in row.columns_ref().iter().enumerate() {
            let ctype = col.column_type();
            let value = row
                .as_ref(i)
                .ok_or("length of row was smaller than column count")?;
            let converted = match value {
                mysql::Value::Bytes(b) => match ctype {
                    MYSQL_TYPE_VARCHAR | MYSQL_TYPE_STRING | MYSQL_TYPE_VAR_STRING => {
                        serde_json::Value::String(String::from_utf8_lossy(b).into_owned())
                    }
                    MYSQL_TYPE_BLOB
                    | MYSQL_TYPE_LONG_BLOB
                    | MYSQL_TYPE_MEDIUM_BLOB
                    | MYSQL_TYPE_TINY_BLOB => {
                        if col.flags().contains(ColumnFlags::BINARY_FLAG) {
                            serde_json::Value::Array(
                                b.iter()
                                    .map(|x| serde_json::Value::Number(Number::from(*x)))
                                    .collect(),
                            )
                        } else {
                            serde_json::Value::String(String::from_utf8_lossy(b).into_owned())
                        }
                    }
                    _ => serde_json::Value::Null,
                },
                mysql::Value::Float(f) => serde_json::Value::Number(
                    Number::from_f64(f64::from(*f)).unwrap_or_else(|| Number::from(0)),
                ),
                mysql::Value::Double(f) => serde_json::Value::Number(
                    Number::from_f64(*f).unwrap_or_else(|| Number::from(0)),
                ),
                mysql::Value::Int(i) => serde_json::Value::Number(Number::from(*i)),
                mysql::Value::UInt(u) => serde_json::Value::Number(Number::from(*u)),
                mysql::Value::Date(year, month, day, hour, minute, second, _ms) => {
                    serde_json::Value::String(format!(
                        "{year}-{month:02}-{day:02} {hour:02}:{minute:02}:{second:02}"
                    ))
                }
                _ => serde_json::Value::Null,
            };
            json_row.push(converted);
        }
        rows.push(serde_json::Value::Array(json_row));
    }

    drop(conn);

    Ok(serde_json::to_string(&LocalResponse {
        status: "ok".to_string(),
        affected: Some(affected),
        last_insert_id: last_insert_id,
        //columns: Some(columns),
        rows: Some(rows),
    })
    .unwrap())
}

// ----------------------------------------------------------------------------
// Helpers

fn unwrap_box<E: std::fmt::Display>(e: E) -> String {
    e.to_string()
}

fn byondlist_to_params(params: Vec<ByondValue>) -> Params {
    let mut real_params = Params::Empty;

    if params.len() > 0 {
        let mut temp_params_2: HashMap<Vec<u8>, Value> = HashMap::new();

        for pair in params.chunks(2) {
            if let [k, v] = pair {
                let kbytes = k.get_string().unwrap().into_bytes();
                let v_value = byondvalue_to_mysql(v.to_owned());

                temp_params_2.insert(kbytes, v_value);
            }
        }

        real_params = Params::Named(temp_params_2);
    }

    real_params
}

fn byondvalue_to_mysql(val: ByondValue) -> mysql::Value {
    match ValueType::try_from(val.get_type()) {
        Ok(v) => {
            match v {
                ValueType::Number => {
                    let num = val.get_number().unwrap();
                    // Detect integer values vs. true floats
                    if num.fract() == 0.0 {
                        mysql::Value::Int(num as i64)
                    } else {
                        mysql::Value::Float(num)
                    }
                }
                ValueType::String => mysql::Value::Bytes(
                    val.get_cstring()
                        .unwrap() // this is definitely unsafe but OH WELL
                        .to_string_lossy()
                        .as_bytes()
                        .into(),
                ),
                _ => {
                    // Default to null if we cry about it
                    mysql::Value::NULL
                }
            }
        }
        Err(_) => {
            // Default to null if we cant do anything
            mysql::Value::NULL
        }
    }
}

fn serde_to_byondvalue(val: serde_json::Value) -> ByondValue {
    match val {
        serde_json::Value::Bool(b) => ByondValue::new_num(if b { 1f32 } else { 0f32 }),
        serde_json::Value::Number(i) => {
            let v = i.as_f64().unwrap();
            ByondValue::new_num(v as f32) // Loses precision - but we wont get that in BYOND anyway
        }
        serde_json::Value::String(s) => ByondValue::new_str(s).unwrap(),
        _ => ByondValue::null(),
    }
}

fn query_data_to_byond(raw_data: LocalResponse, mut byond_obj: ByondValue) {
    if raw_data.status != "ok" {
        byond_obj
            .write_var("last_error", &ByondValue::new_str("DB offline").unwrap())
            .unwrap();
        return;
    }

    // Lets update where needed
    match raw_data.affected {
        Some(v) => {
            // We will lose precision here but byond doesnt like BIGINT anyway sooooo
            byond_obj
                .write_var("affected", &ByondValue::new_num(v as f32))
                .unwrap()
        }
        None => {}
    }

    match raw_data.last_insert_id {
        Some(v) => {
            // We will lose precision here but byond doesnt like BIGINT anyway sooooo
            byond_obj
                .write_var("last_insert_id", &ByondValue::new_num(v as f32))
                .unwrap()
        }
        None => {}
    }

    // Uncomment this if we ever want to support columns DM side
    /*
    match raw_data.columns {
        Some(v) => {
            // Oh god we need to make a BYOND list
            let mut column_list = ByondValue::new_list().unwrap();
            column_list
                .write_var("len", &ByondValue::new_num(v.len() as f32))
                .unwrap();
            let mut list_idx = 0f32;
            for column in v.iter() {
                list_idx += 1f32;
                // Get it as a proper DM string
                let column_bv = ByondValue::new_str(column.to_owned()).unwrap();
                // Write to the list
                column_list.write_list_index(list_idx, column_bv).unwrap();
            }

            byond_obj.write_var("columns", &column_list).unwrap()
        }
        None => {}
    }
    */

    // Now for the hard part - mapping the colums and rows out
    match raw_data.rows {
        Some(v) => {
            let mut rows_list = ByondValue::new_list().unwrap();
            // This is very hacky but will be fixed when we have native list sizing stuff in byondapi
            // Lummox is aware
            rows_list
                .write_var("len", &ByondValue::new_num(v.len() as f32))
                .unwrap();

            let mut row_idx = 0f32;
            for row in v.iter() {
                let mut this_row = ByondValue::new_list().unwrap();
                row_idx += 1f32;

                // Hacky time~
                this_row
                    .write_var(
                        "len",
                        &ByondValue::new_num(row.as_array().unwrap().len() as f32),
                    )
                    .unwrap();

                let mut col_idx = 0f32;
                for val in row.as_array().unwrap().iter() {
                    col_idx += 1f32;
                    this_row
                        .write_list_index(col_idx, serde_to_byondvalue(val.to_owned()))
                        .unwrap();
                }

                // Dumb hack until lummox does it
                rows_list.write_list_index(row_idx, this_row).unwrap();
            }

            byond_obj.write_var("rows", &rows_list).unwrap()
        }
        None => {}
    }
}
