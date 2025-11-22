# Supabase PostgreSQL Extensions

## Overview

This Supabase instance has **64 extensions** enabled in the `extensions` schema (security best practice - extensions should not be in the `public` schema).

## Enabled Extensions

### Core Extensions
- `pg_stat_statements` - Track planning and execution statistics
- `pgcrypto` - Cryptographic functions
- `uuid-ossp` - UUID generation

### Text Search & Indexing
- `pg_trgm` - Text similarity using trigrams
- `btree_gin` - GIN index support for common datatypes
- `btree_gist` - GiST index support for common datatypes
- `unaccent` - Remove accents from text
- `fuzzystrmatch` - String similarity and distance
- `dict_int` - Integer dictionary for text search
- `dict_xsyn` - Extended synonym processing

### Data Types
- `citext` - Case-insensitive text type
- `hstore` - Key-value storage
- `ltree` - Hierarchical tree structures
- `intarray` - Integer array operations
- `cube` - Multidimensional cubes
- `isn` - International product numbering standards
- `seg` - Line segments and intervals
- `vector` - Vector similarity search (for AI/ML)

### Spatial & Geographic
- `postgis` - Geographic objects and functions
- `postgis_raster` - Raster data support
- `postgis_sfcgal` - SFCGAL functions
- `pgrouting` - Routing functionality
- `earthdistance` - Great circle distance calculations
- `address_standardizer` - Address parsing
- `address_standardizer_data_us` - US address data

### Performance & Monitoring
- `pg_prewarm` - Prewarm relation data
- `pg_buffercache` - Shared buffer cache examination
- `pg_stat_monitor` - Advanced query performance monitoring
- `pgrowlocks` - Row-level locking information
- `pgstattuple` - Tuple-level statistics
- `pageinspect` - Low-level page inspection
- `pg_visibility` - Visibility map examination
- `pg_freespacemap` - Free space map examination
- `pg_walinspect` - Write-Ahead Log inspection

### Networking & HTTP
- `http` - HTTP client for PostgreSQL
- `pg_net` - Async HTTP requests
- `dblink` - Connect to other PostgreSQL databases
- `postgres_fdw` - Foreign data wrapper for remote PostgreSQL
- `file_fdw` - Foreign data wrapper for flat files

### Utilities
- `tablefunc` - Table manipulation functions (crosstab, etc.)
- `autoinc` - Auto-incrementing fields
- `lo` - Large object maintenance
- `sslinfo` - SSL certificate information
- `tcn` - Triggered change notifications
- `tsm_system_rows` - TABLESAMPLE by number of rows
- `tsm_system_time` - TABLESAMPLE by time limit
- `old_snapshot` - Old snapshot threshold utilities

### Audit & Tracking
- `insert_username` - Track who changed tables
- `moddatetime` - Track last modification time
- `pgaudit` - Auditing functionality

### Testing
- `pgtap` - Unit testing for PostgreSQL

### Advanced Features
- `pgjwt` - JSON Web Token API
- `pg_hashids` - Hashids support
- `pg_jsonschema` - JSON schema validation
- `pg_repack` - Reorganize tables with minimal locks
- `hypopg` - Hypothetical indexes
- `pg_surgery` - Database surgery tools
- `amcheck` - Relation integrity verification
- `xml2` - XPath querying and XSLT

### Full-Text Search
- `pgroonga` - Super fast full-text search (all languages)
- `pgroonga_database` - PGroonga database management
- `rum` - RUM index access method

### Supabase-Specific
- `wrappers` - Foreign data wrappers developed by Supabase

## Extension Schema

All extensions are installed in the `extensions` schema (not `public`) for security best practices.

## Managing Extensions

### List All Extensions
```bash
cd /root/infra/supabase
docker compose exec -T supabase-db psql -h localhost -U supabase_admin -d postgres -c "\dx"
```

### Enable a New Extension
```bash
docker compose exec -T supabase-db psql -h localhost -U supabase_admin -d postgres -c "CREATE EXTENSION IF NOT EXISTS extension_name WITH SCHEMA extensions;"
```

### Disable an Extension
```bash
docker compose exec -T supabase-db psql -h localhost -U supabase_admin -d postgres -c "DROP EXTENSION IF EXISTS extension_name;"
```

### Re-enable All Extensions
```bash
cd /root/infra/supabase
docker compose exec -T supabase-db psql -h localhost -U supabase_admin -d postgres < enable-all-extensions.sql
```

## Notes

- Some extensions require specific schemas (e.g., `supabase_vault` requires `vault` schema, `pg_cron` requires `cron` schema)
- Extensions like `pg_cron` may require additional configuration
- See `init-supabase.sql` for the standard extension setup
- See `enable-all-extensions.sql` for the complete extension list

**Last Updated:** 2025-11-22

