use crate::jobs;
use byondapi::value::ByondValue;
use serde::{Deserialize, Serialize};
use std::cell::RefCell;
use std::collections::{BTreeMap, HashMap};

// ----------------------------------------------------------------------------
// Interface

#[derive(Serialize, Deserialize)]
struct Response<'a> {
    status_code: u16,
    headers: HashMap<String, String>,
    body: Option<&'a str>,
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
                .set("User-Agent", &format!("{PKG_NAME}/{VERSION}"));

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

fn submit_request(prep: RequestPrep) -> Option<String> {
    let response = prep.req.send_bytes(&prep.body).map_err(Box::new).unwrap();

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

    body = response.into_string().unwrap();
    resp.body = Some(&body);

    Some(serde_json::to_string(&resp).unwrap())
}

// Exported methods
#[byondapi::bind]
fn http_start_client() -> eyre::Result<ByondValue> {
    HTTP_CLIENT.with(|cell| cell.replace(Some(ureq::agent())));
    Ok(ByondValue::null())
}

#[byondapi::bind]
fn http_shutdown_client() -> eyre::Result<ByondValue> {
    HTTP_CLIENT.with(|cell| cell.replace(None));
    Ok(ByondValue::null())
}

#[byondapi::bind]
fn http_submit_async_request(mut request: ByondValue) -> eyre::Result<ByondValue> {
    let method = request.read_var("method")?.get_string()?;
    let url = request.read_var("url")?.get_string()?;
    let body = request.read_var("body")?.get_string()?;

    let headers = request.read_var("headers").unwrap().get_list().unwrap();

    let mut real_headers = None;

    if headers.len() > 0 {
        let mut btm: BTreeMap<String, String> = BTreeMap::new();

        for pair in headers.chunks(2) {
            if let [k, v] = pair {
                let kstr = k.get_string().unwrap();
                let vstr = v.get_string().unwrap();
                btm.insert(kstr, vstr);
            }
        }

        real_headers = Some(btm);
    }

    let req = match construct_request(method.as_str(), url.as_str(), body.as_str(), &real_headers) {
        Some(r) => r,
        None => return Ok(ByondValue::null()),
    };

    let job_id = jobs::start(move || submit_request(req).unwrap());

    request
        .write_var("id", &ByondValue::new_num(job_id as f32))
        .unwrap();

    request
        .write_var("in_progress", &ByondValue::new_num(1f32))
        .unwrap();

    Ok(ByondValue::null())
}

#[byondapi::bind]
fn http_check_job(mut request: ByondValue) -> eyre::Result<ByondValue> {
    let id = request.read_var("id").unwrap().get_number().unwrap() as usize;
    match jobs::check(&id) {
        Some(res) => match res {
            Ok(res2) => {
                // We are no longer in progress
                request
                    .write_var("in_progress", &ByondValue::new_num(0f32))
                    .unwrap();

                // Decode response
                let web_response: Response = serde_json::from_str(&res2).unwrap();
                // We have a response - assemble our HTML datum
                let target_type = ByondValue::new_str("/datum/http_response").unwrap();
                let mut response_datum = ByondValue::builtin_new(target_type, &[]).unwrap();

                // Write primatives
                response_datum
                    .write_var(
                        "status_code",
                        &ByondValue::new_num(web_response.status_code as f32),
                    )
                    .unwrap();

                response_datum
                    .write_var(
                        "body",
                        &ByondValue::new_str(web_response.body.unwrap()).unwrap(),
                    )
                    .unwrap();

                // Headers are more complicated since its an assoc list
                let mut headers_list = ByondValue::new_list().unwrap();
                for header_k in web_response.headers.keys() {
                    // Get the key as a BV
                    let hk_bv = ByondValue::new_str(header_k.to_string()).unwrap();

                    // Get the value as a BV
                    let hv = web_response.headers.get(header_k).unwrap();
                    let hv_bv = ByondValue::new_str(hv.to_string()).unwrap();

                    headers_list.write_list_index(hk_bv, hv_bv).unwrap();
                }

                // Send it back
                Ok(response_datum)
            }
            Err(flume::TryRecvError::Disconnected) => {
                // We have an error - send proper stuff back
                request
                    .write_var(
                        "error_code",
                        &ByondValue::new_str(jobs::JOB_PANICKED).unwrap(),
                    )
                    .unwrap();

                return Ok(ByondValue::null());
            }
            Err(flume::TryRecvError::Empty) => {
                request
                    .write_var(
                        "error_code",
                        &ByondValue::new_str(jobs::NO_RESULTS_YET).unwrap(),
                    )
                    .unwrap();
                return Ok(ByondValue::null());
            }
        },
        None => {
            request
                .write_var(
                    "error_code",
                    &ByondValue::new_str(jobs::NO_SUCH_JOB).unwrap(),
                )
                .unwrap();
            return Ok(ByondValue::null());
        }
    }
}
