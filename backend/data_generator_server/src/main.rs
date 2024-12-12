use actix_web::{web, App, HttpServer, Responder, HttpResponse};
use std::process::Command;
use std::sync::Mutex;
use serde::{Deserialize, Serialize};

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

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    std::env::set_var("RUST_LOG", "debug");
    env_logger::init();
    let shared_state = web::Data::new(AppState {
        desktops: Mutex::new(Vec::new()),
    });

    HttpServer::new(move || {
        App::new()
            .app_data(shared_state.clone()) // Register shared state with the app
            .route("/generate", web::get().to(generate_data))
            .route("/set", web::post().to(set_custom_data))
            .route("/get", web::get().to(get_custom_data))
    })

    .bind("0.0.0.0:8081")?
    .run()
    .await
}

