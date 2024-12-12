use actix_files::{NamedFile, Files};
use actix_web::{get, App, HttpServer, Responder};

#[get("/")]
async fn index() -> impl Responder {
    NamedFile::open("Labmap2.html")
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(|| {
        App::new()
            .service(index)
            .service(Files::new("/static", "static/").use_last_modified(true))
    })
    .bind("0.0.0.0:8080")? // Bind to localhost on port 8080
    .run()
    .await
}

