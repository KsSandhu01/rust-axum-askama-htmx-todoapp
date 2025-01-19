#[derive(Debug, Clone)]
pub struct Config {
    pub database_url: String,
    pub jwt_secret: String,
    pub jwt_expires_in: String,
    pub jwt_maxage: i32,
}

impl Config {
    pub fn init() -> Self {
        let database_url = std::env::var("DATABASE_URL").expect("DATABASE_URL must be set");
        let jwt_secret = std::env::var("JWT_SECRET").unwrap_or_else(|_| {
            println!("JWT_SECRET is not set, using a default secret");
            "default_jwt_secret".to_string() // Default value
        });
        let jwt_expires_in = std::env::var("JWT_EXPIRED_IN").unwrap_or_else(|_| {
            println!("JWT_EXPIRED_IN is not set, using a default value");
            "1h".to_string() // Default to 1 hour
        });
        let jwt_maxage = std::env::var("JWT_MAXAGE").unwrap_or_else(|_| {
            println!("JWT_MAXAGE is not set, using a default value");
            "3600".to_string() // Default to 3600 seconds (1 hour)
        });

        Self {
            database_url,
            jwt_secret,
            jwt_expires_in,
            jwt_maxage: jwt_maxage.parse::<i32>().unwrap(),
        }
    }
}
