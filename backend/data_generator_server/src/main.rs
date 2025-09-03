use actix_web::{web, App, HttpServer, Responder, HttpResponse, middleware};
use actix_web::rt::time;
use std::process::Command;
use std::sync::Mutex;
use std::time::Duration;
use std::fs;
use serde::{Deserialize, Serialize};
use reqwest;

struct AppState {
    desktops: Mutex<Vec<CustomData>>,
}

#[derive(Deserialize, Serialize, Clone)]
struct CustomData {
    name: String,
    status: String,
    logged_in: String,
    user: String,
}

#[derive(Deserialize, Serialize, Clone)]
struct DesktopWrapper {
    desktops: Vec<CustomData>,
}

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

// Handler for the `/set` route
async fn set_custom_data(data: web::Json<DesktopWrapper>, state: web::Data<AppState>) -> impl Responder {
    let mut desktops = state.desktops.lock().unwrap();
    *desktops = data.into_inner().desktops;
    HttpResponse::Ok().body("Custom data updated successfully\n")
}

// Handler to retrieve custom data
async fn get_custom_data(state: web::Data<AppState>) -> impl Responder {
    let desktops = state.desktops.lock().unwrap();

    let response = DesktopWrapper {
        desktops: desktops.clone(),
    };

    HttpResponse::Ok()
        .content_type("application/json")
        .json(response)
}

async fn get_hours() -> impl Responder {
    // Replace with local path to your YAML file
    let path = "./hours.yaml";

    match fs::read_to_string(path) {
        Ok(contents) => HttpResponse::Ok()
            .content_type("text/yaml")
            .body(contents),
        Err(_) => HttpResponse::InternalServerError().body("Failed to read YAML file"),
    }
}

async fn refresh_hours_file() {
    let url = "https://github.com/ocf/etc/raw/refs/heads/master/configs/hours.yaml";
    let path = "./hours.yaml";

    let client = reqwest::Client::new();
    let mut interval = time::interval(Duration::from_secs(1800)); // every 30 min

    loop {
        interval.tick().await;

        if let Ok(resp) = client.get(url).send().await {
            if let Ok(body) = resp.text().await {
                if let Err(err) = fs::write(path, body) {
                    eprintln!("Failed to write file: {}", err);
                } else {
                    println!("Refreshed {}", path);
                }
            }
        }
    }
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    std::env::set_var("RUST_LOG", "debug");
    env_logger::init();
    let shared_state = web::Data::new(AppState {
        desktops: Mutex::new(Vec::new()),
    });

    tokio::spawn(refresh_hours_file());

    HttpServer::new(move || {
        App::new()
            .app_data(shared_state.clone()) // Register shared state with the app
            .wrap(middleware::NormalizePath::new(middleware::TrailingSlash::Trim)) 
            .wrap(middleware::DefaultHeaders::new()
                .add((actix_web::http::header::CONTENT_ENCODING, "identity"))
            )
            .route("/api/generate", web::get().to(generate_data))
            .route("/api/set", web::post().to(set_custom_data))
            .route("/api/get", web::get().to(get_custom_data))
            .route("/api/hours", web::get().to(get_hours))
            .route("/health", web::get().to(HttpResponse::Ok))
    })

    .bind("0.0.0.0:8080")?
    .run()
    .await
}

