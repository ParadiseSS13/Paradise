#[macro_use]
extern crate rocket;

use rocket::fs::NamedFile;
use rocket::http::Header;
use rocket::response::Responder;
use rocket::Request;
use std::path::{Path, PathBuf};

struct WithCORS<T> {
    inner: T,
}

impl<'r, T: Responder<'r, 'static>> Responder<'r, 'static> for WithCORS<T> {
    fn respond_to(self, req: &'r Request<'_>) -> rocket::response::Result<'static> {
        let mut response = self.inner.respond_to(req)?;
        response.set_header(Header::new("Access-Control-Allow-Origin", "*"));
        response.set_header(Header::new("Access-Control-Allow-Methods", "GET"));
        response.set_header(Header::new(
            "Cache-Control",
            "no-store, no-cache, must-revalidate",
        ));
        Ok(response)
    }
}

#[get("/<file..>")]
async fn files(file: PathBuf) -> Option<WithCORS<NamedFile>> {
    NamedFile::open(Path::new("./data/asset-store/").join(file))
        .await
        .ok()
        .map(|f| WithCORS { inner: f })
}

#[launch]
fn rocket() -> _ {
    rocket::build()
        .configure(rocket::Config::figment().merge(("port", 58715)))
        .mount("/", routes![files])
}
