# Demo: NextJS + Postgres + Terraform + DigitalOcean

This sample repo demonstrates how to deploy a small NextJS application to [Digital Ocean](https://www.digitalocean.com/). The project contains three directories:

- `super-duper-app`: The [NextJS](https://nextjs.org/) application. This includes a Dockerfile, and uses Kysely to access the database.
- `super-duper-db`: Migrations for the app's Postgres database, managed by [Goose](https://github.com/pressly/goose).
- `super-duper-infra`: The [Terraform](https://www.terraform.io/) code defining the DigitalOcean infrastructure used to host both the application and the database.

## Interesting bits

### Updates to the base NextJS application

This demo contains a bog-standard NextJS app, created following the instructions on their [documentation](https://nextjs.org/docs/app/api-reference/cli/create-next-app). I did have to make a few changes.

1. Dockerfile

The`Dockerfile` for the NextJS app was adapted from [this example](https://github.com/vercel/next.js/blob/canary/examples/with-docker/Dockerfile). I modified this line:

```dockerfile
FROM --platform=linux/amd64 node:18-alpine AS base
```

DigitalOcean app platform expects Docker images to be built on the AMD64 platform, but my Mac defaults to images built on Arm64. Hence, the `--platform=linux/amd64` flag. Not having this flag might produce the following build error:

```
[2025-02-10 23:22:05] starting container: starting sub-container [docker-entrypoint.sh node server.js]: creating process: failed to load /usr/local/bin/docker-entrypoint.sh: exec format error
```

1. NextJS set to "standalone" output mode

In `next.config.ts`, set `output` to "standalone". This ensures NextJS will produce a standalone build with the expected entrypoint script for Docker. See [the Docs](https://nextjs.org/docs/pages/api-reference/config/next-config-js/output).

```ts
import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  output: "standalone", // Add this line.
};

export default nextConfig;
```

1. Database dependencies and codegen

```sh
npm i --save pg pg-connection-string kysely
npm i --save-dev @types/pg kysely-codegen
```

Kysely is an abstraction layer for SQL, and combined with Codegen gives us type objects representing the database. `package.json` also contains a `codegen` script that generates these types:

```sh
npm run codegen
```

4. Postgres pool connection configuration

In `super-duper-app/src/database.ts`, this is the connection config:

```ts
const dbConfig = parse(process.env.DATABASE_URL || "");
const db = new Kysely<DB>({
  dialect: new PostgresDialect({
    pool: new Pool({
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
```

You might wonder why I'm bothering to parse the connection string into bits instead of passing it directly:

```ts
const db = new Kysely<DB>({
  dialect: new PostgresDialect({
    pool: new Pool({
      connectionString: process.env.DATABASE_URL,
      ssl: {
        rejectUnauthorized: true,
        ca: process.env.DATABASE_CERT,       
      }
    }),
  }),
});
```

This works locally, but DigitalOcean throws a "self signed certificate in certificate chain" error when the app tries to access the database. The problem seems to live somewhere in the intersection of SSL, the DATABASE_URL exported by Terraform, and how node-postgres parses the ssl bits of that string. [This issue](https://github.com/brianc/node-postgres/pull/2709) is my best guess on the root cause.

### Jump Server

In addition to our application, and our database cluster, you may notice that I've also deployed a standalone server in a droplet:

```hcl
resource "digitalocean_droplet" "super_duper_jump_server" {
  name     = "super-duper-jump-server"
  image    = "ubuntu-24-10-x64"
  region   = var.do_region
  size     = "s-1vcpu-512mb-10gb"
  ssh_keys = [digitalocean_ssh_key.super_duper_jump_server_ssh_key.fingerprint]
  vpc_uuid = digitalocean_vpc.super_duper_vpc.id
}
```

This [jump server](https://en.wikipedia.org/wiki/Jump_server#:~:text=A%20jump%20server%2C%20jump%20host,means%20of%20access%20between%20them.) allows me to remotely access my database and do things like run [pgcli](https://www.pgcli.com/) commands and manage migrations.

## How to Deploy this Project

### Prerequisites

- [NodeJS](https://nodejs.org/en/download) installed locally (`which npx`)
- [Docker for Desktop](https://www.docker.com/get-started/) installed locally (`which docker`)
- A DigitalOcean account

**Heads up: **This setup isn't particularly expensive, but it _could_ occur costs. Be sure to remove any created resources when you're done by calling the `./bin/teardown_infrastructure.sh` script.

### Guide

1. On your DigitalOcean console, create a new API Access Token.
2. On your DigialOcean console, create a Container Registry if you don't already have one. This project requires one available "repo" slot.
3. Clone this repository.
4. Run the deployment scripts:

```sh
export DIGITALOCEAN_TOKEN="MY_TOKEN" # token from DigitalOcean

./bin/deploy_application.sh
# provide your Digital Ocean access token when prompted

./bin/deploy_infrastructure.sh
# type 'yes' when prompted
```

5. Connect to the jump server:

```sh
./bin/connection_to_jump_server.sh
```

6. While connected to the jump server, run the following:

```sh
ssh-keygen -t rsa
cat ~/.ssh/id_rsa.pub
# Add this public key to GitHub.

# Clone code
cd /mnt/super_duper_jump_server_volume
git clone git@github.com:bannmoore/demo-nextjs-postgres-terraform-digitalocean.git
cd demo-nextjs-postgres-terraform-digitalocean

# Run migrations
source ../.env
cd ./super-duper-db
./bin/jump_server_setup.sh
./bin/migrate.sh
```

7. Access your App Platform app on DigitalOcean by clicking the URL in the console. You should see a black screen containing a list of things from the database.

8. When you're done with everything, tear down the infrastructure so you don't get charged!

```sh
./bin/teardown_infrastructure.sh
```

## FAQ

### Why Digital Ocean?

DigitalOcean is my hosting service of choice for personal projects. It makes spinning up static sites quick and easy, and doesn't cost much per month. For small apps and sandboxing, I find it much less overwhelming than something like GCP or AWS.

### Do I have to use Goose?

Nope. You can swap out Goose for whatever database management tool you'd like. Just be sure to update the `super-duper-db/bin/jump_server_setup.sh` script with the installation code.

### Is it a good idea to deploy infrastructure from my personal machine?

Probably not! In a real production scenario, we'd shift all this infrastructure code onto something like [Terraform Cloud](https://www.hashicorp.com/en/resources/what-is-terraform-cloud), to automate updates and ensure workspace state persistence. But that's too much overhead for my average hobby project.

## Other resources

- [Blog post: Deploying Clojure like a Seasoned Hobbyist](https://tonitalksdev.com/deploying-clojure-like-a-seasoned-hobbyist)
- [A useful reference for DigitalOcean slugs required by Terraform](https://slugs.do-api.dev/)