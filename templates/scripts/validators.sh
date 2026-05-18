#!/usr/bin/env bash
# Project-specific validators for templates/scripts/bootstrap.sh.
#
# bootstrap.sh sources this file (if present) from inside its own scope, so
# any `VALIDATORS[VAR_NAME]='regex'` line below ADDS that validator to the
# array bootstrap.sh uses for input checking. On validation failure, bootstrap
# offers a "Use anyway? [y/N]" override — these aren't hard gates, they catch
# typos at input time.
#
# The values are POSIX extended regular expressions (bash's `[[ "$s" =~ $re ]]`).
#
# Examples below are commented out — uncomment what applies to your project,
# or add your own. The generic template ships with this file containing
# no active entries (only LOG_LEVEL and DEV_MODE validators come from
# bootstrap.sh core).
#
# Telegram bots:
# VALIDATORS[TELEGRAM_BOT_TOKEN]='^[0-9]{8,12}:[A-Za-z0-9_-]{30,}$'
# VALIDATORS[TELEGRAM_WEBHOOK_SECRET]='^[A-Za-z0-9_-]{8,256}$'
# VALIDATORS[TELEGRAM_CHANNEL_ID]='^-?[0-9]+$'
#
# Meta / Facebook Conversions API:
# VALIDATORS[META_DEFAULT_PIXEL_ID]='^[0-9]{14,17}$'
# VALIDATORS[META_CAPI_TOKEN]='^[A-Za-z0-9]{40,}$'
#
# Stripe (live + test keys):
# VALIDATORS[STRIPE_API_KEY]='^sk_(live|test)_[A-Za-z0-9]{24,}$'
#
# Generic HTTPS URL (anchored, schema-strict):
# VALIDATORS[WEBHOOK_BASE_URL]='^https?://[A-Za-z0-9._~/?#@!$&'\''()*+,;=:%-]+$'
#
# Postgres connection string:
# VALIDATORS[DATABASE_URL]='^postgres(ql)?://.+$'
#
# Add your own project-specific entries below.
# (intentionally empty by default — the generic template ships with zero
# active project-specific validators.)
