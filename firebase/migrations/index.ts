import { migration as migration001 } from "./001_init_users";
import { migration as migration002 } from "./002_init_styles";

export const MIGRATIONS_REGISTRY = [migration001, migration002];
