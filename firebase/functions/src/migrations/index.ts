import { migration as migration001 } from "./001_init_styles_from_data";
import { migration as migration002 } from "./002_secure_storage_paths";
import { migration as migration003 } from "./003_normalize_user_data";
import { migration as migration004 } from "./004_consolidate_profile_collections";

export interface Migration {
  id: string;
  description?: string;
  up(db: any): Promise<void>;
  down(db: any): Promise<void>;
}

// Export all migrations in order
export const migrations: Migration[] = [
  migration001,
  migration002,
  migration003,
  migration004,
];

// For easier access by ID
export const migrationMap: { [key: string]: Migration } = {
  [migration001.id]: migration001,
  [migration002.id]: migration002,
  [migration003.id]: migration003,
  [migration004.id]: migration004,
};

export const getMigration = (id: string): Migration | undefined => {
  return migrationMap[id];
};

export const getAllMigrations = (): Migration[] => {
  return migrations;
};
