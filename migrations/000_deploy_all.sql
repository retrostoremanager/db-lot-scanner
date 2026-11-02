-- PostgreSQL Database Setup for lotscanner
-- AI game lot scanning quote records (LotScanSession, ScannedItem)
-- Database lives on db-gamedb's existing Azure Postgres Flexible Server (research.md #5)
-- Run: psql -U <user> -d lotscanner -f 000_deploy_all.sql

CREATE SCHEMA IF NOT EXISTS public;

\i 001_create_lot_scan_sessions_table.sql
\i 002_create_scanned_items_table.sql
\i 003_add_scanned_items_final_price_check.sql
\i 004_add_indexes.sql
\i 005_add_company_scoping_and_multi_photo.sql
