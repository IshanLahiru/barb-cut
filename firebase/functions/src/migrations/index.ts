import { migration as migration001 } from "./001_init_styles_from_data";
import { migration as migration002 } from "./002_secure_storage_paths";

export interface Migration {
  id: string;
  description?: string;
  up(db: any): Promise<void>;
  down(db: any): Promise<void>;
}

// Export all migrations in order
export const migrations: Migration[] = [migration001, migration002];

// For easier access by ID
export const migrationMap: { [key: string]: Migration } = {
  [migration001.id]: migration001,
  [migration002.id]: migration002,
};

export const getMigration = (id: string): Migration | undefined => {
  return migrationMap[id];
};

export const getAllMigrations = (): Migration[] => {
  return migrations;
};
