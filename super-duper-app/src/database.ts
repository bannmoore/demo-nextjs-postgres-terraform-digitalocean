import { Kysely, PostgresDialect } from "kysely";
import { DB } from "kysely-codegen";
import { Pool } from "pg";
import { parse } from "pg-connection-string";

const dbConfig = parse(process.env.DATABASE_URL || "");
const db = new Kysely<DB>({
  dialect: new PostgresDialect({
    pool: new Pool({
      /**
       * Note that we're parsing the connection string instead of passing it
       * to the connectionString attribute. This will be important when we
       * deploy to DigitalOcean.
       * Underlying issue: https://github.com/brianc/node-postgres/pull/2709
       */
      database: dbConfig.database || "",
      host: dbConfig.host || "",
      user: dbConfig.user,
      password: dbConfig.password,
      port: Number(dbConfig.port || "5432"),
      ssl: dbConfig.ssl
        ? {
            rejectUnauthorized: true,
            ca: process.env.DATABASE_CERT,
          }
        : undefined,
    }),
  }),
});

export function getThings() {
  return db.selectFrom("things").selectAll().execute();
}
