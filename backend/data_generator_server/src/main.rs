use actix_web::{web, App, HttpServer, Responder, HttpResponse};
use std::process::Command;

async fn generate_data() -> impl Responder {
    // Call the Python script
    let output = Command::new("python3")
        .arg("data_generator.py")
        .output();

    match output {
        Ok(output) => {
            if let Ok(stdout) = String::from_utf8(output.stdout) {
                HttpResponse::Ok()
                    .content_type("application/json")
                    .body(stdout)
            } else {
                HttpResponse::InternalServerError().body("Failed to parse script output")
            }
        }
        Err(e) => HttpResponse::InternalServerError().body(format!("Error running script: {}", e)),
    }
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(|| {
        App::new().route("/generate", web::get().to(generate_data))
    })
    .bind("127.0.0.1:8080")?
    .run()
    .await
}

