use crate::jobs;
use crate::logging;
use byondapi::value::ByondValue;
use eyre::Result;
use serde::{Deserialize, Serialize};
use std::cell::RefCell;
use std::collections::{BTreeMap, HashMap};
// ----------------------------------------------------------------------------
// Interface

#[derive(Serialize, Deserialize)]
struct Response {
    status_code: u16,
    headers: HashMap<String, String>,
    body: Option<String>,
}

// If the response can be deserialized -> success.
// If the response can't be deserialized -> failure or WIP.

// ----------------------------------------------------------------------------
// Shared HTTP client state

const VERSION: &str = env!("CARGO_PKG_VERSION");
const PKG_NAME: &str = env!("CARGO_PKG_NAME");

thread_local! {
    pub static HTTP_CLIENT: RefCell<Option<ureq::Agent>> = RefCell::new(Some(ureq::agent()));
}

// ----------------------------------------------------------------------------
// Request construction and execution

struct RequestPrep {
    req: ureq::Request,
    body: Vec<u8>,
}

fn construct_request(
    method: &str,
    url: &str,
    body: &str,
    headers: &Option<BTreeMap<String, String>>,
) -> Option<RequestPrep> {
    HTTP_CLIENT.with(|cell| {
        let borrow = cell.borrow_mut();
        match &*borrow {
            Some(client) => {
                let mut req = match method {
                    "post" => client.post(url),
                    "put" => client.put(url),
                    "patch" => client.patch(url),
                    "delete" => client.delete(url),
                    "head" => client.head(url),
                    _ => client.get(url),
                }
                .set("User-Agent", &format!("{PKG_NAME}/{VERSION}"))
                .timeout(std::time::Duration::from_secs(5));

                let final_body = body.as_bytes().to_vec();

                match headers {
                    Some(h) => {
                        for (key, value) in h {
                            req = req.set(key, value);
                        }
                    }
                    None => {}
                }

                Some(RequestPrep {
                    req,
                    body: final_body,
                })
            }

            // If we got here we royally fucked up
            None => None,
        }
    })
}

fn submit_request(prep: RequestPrep) -> Result<String> {
    // Send the request
    // TODO: this is a sinful hack, rewrite this as soon as the module is stable on live
    let response = match prep.req.send_bytes(&prep.body) {
        Ok(r) => r,
        Err(ureq::Error::Status(code, r)) => r,
        Err(ureq::Error::Transport(t)) => {
            let mut resp = Response {
                status_code: 0,
                headers: HashMap::new(),
                body: None,
            };
            resp.body = Some(t.to_string());
            return Ok(serde_json::to_string(&resp)?);
        }
    };
    let body;
    let mut resp = Response {
        status_code: response.status(),
        headers: HashMap::new(),
        body: None,
    };

    for key in response.headers_names() {
        let Some(value) = response.header(&key) else {
            continue;
        };

        resp.headers.insert(key, value.to_owned());
    }

    body = response.into_string()?;
    resp.body = Some(body);

    Ok(serde_json::to_string(&resp)?)
}

// Exported methods
#[byondapi::bind]
fn http_start_client() -> Result<ByondValue> {
    HTTP_CLIENT.with(|cell| cell.replace(Some(ureq::agent())));
    Ok(ByondValue::null())
}

#[byondapi::bind]
fn http_shutdown_client() -> Result<ByondValue> {
    HTTP_CLIENT.with(|cell| cell.replace(None));
    Ok(ByondValue::null())
}

#[byondapi::bind]
fn http_submit_async_request(mut request: ByondValue) -> Result<ByondValue> {
    let method = request.read_var("method")?.get_string()?;
    let url = request.read_var("url")?.get_string()?;
    let body = request.read_var("body")?.get_string()?;

    let headers = request.read_var("headers")?.get_list()?;

    let mut real_headers = None;

    if headers.len() > 0 {
        let mut btm: BTreeMap<String, String> = BTreeMap::new();

        for pair in headers.chunks(2) {
            if let [k, v] = pair {
                let kstr = k.get_string()?;
                let vstr = v.get_string()?;
                btm.insert(kstr, vstr);
            }
        }

        real_headers = Some(btm);
    }

    let req = match construct_request(method.as_str(), url.as_str(), body.as_str(), &real_headers) {
        Some(r) => r,
        None => return Ok(ByondValue::null()),
    };

    // Start the request as a job on a new thread
    let job_id = jobs::start(move || match submit_request(req) {
        Ok(r) => r,
        Err(e) => e.to_string(),
    });

    // Write job id back to BYOND
    request.write_var("id", &ByondValue::new_num(job_id as f32))?;
    request.write_var("in_progress", &ByondValue::new_num(1f32))?;

    Ok(ByondValue::null())
}

#[byondapi::bind]
fn http_check_job(mut request: ByondValue) -> Result<ByondValue> {
    // logging::setup_panic_handler();
    let id = request.read_var("id")?.get_number()? as usize;
    match jobs::check(&id) {
        // Job id exists, check progress
        Some(res) => match res {
            // Request completed, parse it
            Ok(res) => {
                // We are no longer in progress
                request.write_var("in_progress", &ByondValue::new_num(0f32))?;
                request
                    .write_var("error_code", &ByondValue::null())
                    .unwrap();

                // Decode response
                let web_response: Response = serde_json::from_str(&res).unwrap();
                // We have a response - assemble our HTML datum
                let target_type = ByondValue::new_str("/datum/http_response")?;
                let mut response_datum = ByondValue::builtin_new(target_type, &[])?;

                // Write primitives
                response_datum
                    .write_var(
                        "status_code",
                        &ByondValue::new_num(web_response.status_code as f32),
                    )
                    .unwrap();
                response_datum
                    .write_var("body", &ByondValue::new_str(web_response.body.unwrap())?)?;

                // Headers are more complicated since its an assoc list
                let mut headers_list = ByondValue::new_list().unwrap();
                for header_k in web_response.headers.keys() {
                    // Get the key as a BV
                    let hk_bv = ByondValue::new_str(header_k.to_string())?;

                    // Get the value as a BV
                    let hv = web_response.headers.get(header_k).unwrap();
                    let hv_bv = ByondValue::new_str(hv.to_string())?;

                    headers_list.write_list_index(hk_bv, hv_bv)?;
                }

                // Send it back
                Ok(response_datum)
            }
            // Request is still being made
            Err(flume::TryRecvError::Empty) => {
                request.write_var("error_code", &ByondValue::new_str(jobs::NO_RESULTS_YET)?)?;
                return Ok(ByondValue::null());
            }
            // Something bad happened during the request
            Err(flume::TryRecvError::Disconnected) => {
                request.write_var("error_code", &ByondValue::new_str(jobs::JOB_PANICKED)?)?;
                request.write_var("in_progress", &ByondValue::new_num(0f32))?;
                return Ok(ByondValue::null());
            }
        },
        // Job id does not exist
        None => {
            request.write_var(
                "error_code",
                &ByondValue::new_str(jobs::NO_SUCH_JOB).unwrap(),
            )?;

            return Ok(ByondValue::null());
        }
    }
}
