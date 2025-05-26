# rails-migration-check

[![Test Rails Migration Checks](https://github.com/your-org/rails-migration-check/actions/workflows/check-migrations.yml/badge.svg)](https://github.com/your-org/rails-migration-check/actions/workflows/check-migrations.yml)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A GitHub Actions package to **automatically check for common Rails migration inconsistencies** (naming, methods, schema.rb sync, etc.) on pull requests.

## Features

- Checks Rails migration filenames (timestamp + name format)
- Ensures each migration file has a `change`, `up`, or `down` method
- Detects if `db/schema.rb` is updated with new migrations
- Works out-of-the-box in CI on PRs

## Usage

### 1. Add to your repository

Clone or copy this repository’s `scripts/` and `.github/workflows/` directories into your Rails project.

### 2. Enable GitHub Actions

This workflow runs on every Pull Request that changes `db/migrate` or `db/schema.rb`.

### 3. Example output (on PR)

- ✅ All migrations look good.
- ❌ Invalid filename format: `20230507123456_create_user.rb`
- ❌ No migration method found in: `20230507123457_add_email_to_users.rb`
- ❌ schema.rb has not been updated. Run `rails db:migrate` and commit changes.

## Customization

You can extend `scripts/check_migrations.rb` to include your team's specific migration rules.

## Development

- Requires Ruby 2.7+ and Bundler
- Runs in standard GitHub Actions environment

## License

MIT
