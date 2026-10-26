package config

import (
	"fmt"
	"log/slog"
	"os"
	"path/filepath"
	"sort"
	"strings"

	"github.com/jmoiron/sqlx"
)

// RunMigrations busca los archivos .sql en la carpeta migrations/
// y los ejecuta en orden lexicográfico registrándolos en schema_migrations.
func RunMigrations(db *sqlx.DB, migrationsDir string) error {
	if migrationsDir == "" {
		migrationsDir = "migrations"
	}

	// Verificar si el directorio existe
	if _, err := os.Stat(migrationsDir); os.IsNotExist(err) {
		slog.Warn("migrations_dir_not_found", slog.String("dir", migrationsDir))
		return nil
	}

	// Crear tabla de tracking si no existe
	createTableQuery := `
		CREATE TABLE IF NOT EXISTS schema_migrations (
			version VARCHAR(100) PRIMARY KEY,
			applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
		) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
	`
	if _, err := db.Exec(createTableQuery); err != nil {
		return fmt.Errorf("error creando tabla schema_migrations: %w", err)
	}

	files, err := os.ReadDir(migrationsDir)
	if err != nil {
		return fmt.Errorf("error leyendo directorio de migraciones: %w", err)
	}

	var sqlFiles []string
	for _, f := range files {
		if !f.IsDir() && strings.HasSuffix(f.Name(), ".sql") {
			sqlFiles = append(sqlFiles, f.Name())
		}
	}
	sort.Strings(sqlFiles)

	for _, filename := range sqlFiles {
		var exists int
		err := db.Get(&exists, "SELECT COUNT(*) FROM schema_migrations WHERE version = ?", filename)
		if err == nil && exists > 0 {
			continue // Ya aplicada
		}

		filePath := filepath.Join(migrationsDir, filename)
		content, err := os.ReadFile(filePath)
		if err != nil {
			return fmt.Errorf("error leyendo archivo %s: %w", filename, err)
		}

		slog.Info("applying_migration", slog.String("version", filename))
		if _, err := db.Exec(string(content)); err != nil {
			return fmt.Errorf("error ejecutando migración %s: %w", filename, err)
		}

		if _, err := db.Exec("INSERT INTO schema_migrations (version) VALUES (?)", filename); err != nil {
			return fmt.Errorf("error registrando migración %s: %w", filename, err)
		}
		slog.Info("migration_applied", slog.String("version", filename))
	}

	return nil
}
