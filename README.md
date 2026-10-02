# db-lot-scanner

PostgreSQL schema/migrations for AI game lot scanning quote records
(`LotScanSession`, `ScannedItem`). Part of the `lot-scanner` product —
see [retrostoremanager/lot-scanner](https://github.com/retrostoremanager/lot-scanner)
`specs/001-lot-scan-review/` for the spec, plan, and data model this implements.

## Where this lives

The `lotscanner` database runs on **`db-gamedb`'s existing Azure Postgres Flexible
Server** — a deliberate choice to avoid a second server's monthly cost (see
`lot-scanner`'s `specs/001-lot-scan-review/research.md` #5). It is a separate database
on that server, not a schema inside `gamedb` itself, so its migration history stays
independent of `db-gamedb`'s.

## Structure

- `migrations/` — ordered, numbered migration files (authoritative history). Run via
  `000_deploy_all.sql`, which `\i`-includes each migration in order.
- `schema/schema.sql` — a read-only current-state snapshot of the schema, for quickly
  reading the full shape without replaying migration history. Not applied directly.

## Applying migrations

```bash
psql -h <db-gamedb-server>.postgres.database.azure.com -U <user> -d lotscanner \
  -f migrations/000_deploy_all.sql
```

The `lotscanner` database itself is provisioned via `infra-gamedb`'s Bicep (a
`Microsoft.DBforPostgreSQL/flexibleServers/databases` resource added alongside the
existing `gamedb` database) — see that repo's `main.bicep`. This repo only owns what's
*inside* the database once it exists.

## Connection string

`fn-lot-scanner` reads this the same way `api-gamedb` reads its `GameDb` connection
string — `ConnectionStrings:lotscanner` (local) or `ConnectionStrings__lotscanner`
(Azure App Settings, sourced from Key Vault):

```
Host=<db-gamedb-server>.postgres.database.azure.com;Database=lotscanner;Username=<user>;Password=<password>;SSL Mode=Require
```
