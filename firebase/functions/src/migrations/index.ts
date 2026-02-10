import { migration as migration001 } from "./001_init_styles_from_data";

export interface Migration {
  id: string;
  description?: string;
  up(db: any): Promise<void>;
  down(db: any): Promise<void>;
}

// Export all migrations in order
export const migrations: Migration[] = [migration001];

// For easier access by ID
export const migrationMap: { [key: string]: Migration } = {
  [migration001.id]: migration001,
};

export const getMigration = (id: string): Migration | undefined => {
  return migrationMap[id];
};

export const getAllMigrations = (): Migration[] => {
  return migrations;
};
