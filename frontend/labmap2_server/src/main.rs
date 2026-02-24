use actix_files::{NamedFile, Files};
use actix_web::{get, App, HttpServer, Responder, HttpResponse, web};

#[get("/")]
async fn index() -> impl Responder {
    NamedFile::open("static/labmap2.html")
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(|| {
        App::new()
            .service(index)
            .service(Files::new("/", "static/").use_last_modified(true))
            .route("/health", web::get().to(HttpResponse::Ok))
    })
    .bind("0.0.0.0:8080")? // Bind to localhost on port 8080
    .run()
    .await
}

