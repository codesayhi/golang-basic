package config

import (
	"log"
	"os"

	"github.com/joho/godotenv"
)

type Config struct {
	Port       string
	DBUrl      string
	DriverName string
}

func Load() *Config {
	err := godotenv.Load("configs/.env")
	if err != nil {
		log.Fatal("Error loading .env file")
	}

	return &Config{
		Port:       getEnv("PORT", "8080"),
		DBUrl:      getEnv("DB_URL", ""),
		DriverName: getEnv("DRIVER_NAME", ""),
	}
}

// @func getEnv: Lấy giá trị .env
// @param key: Key ENV
// @param fallback: Fallback ENV (Giá trị mặc định)
// return string value Env
func getEnv(key, fallback string) string {
	if value, ok := os.LookupEnv(key); ok {
		return value
	}
	return fallback
}
