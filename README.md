# rails-migration-check

[![CI](https://github.com/daigotanaka0714/rails-migration-check/actions/workflows/test.yml/badge.svg)](https://github.com/daigotanaka0714/rails-migration-check/actions/workflows/test.yml)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Reusable GitHub Action to check for Rails migration file inconsistencies and automatically run migrations to verify schema consistency.

## Features

- ✅ **Migration filename format validation** - Ensures proper timestamp format
- ✅ **Migration method validation** - Checks for `change`, `up`, or `down` methods
- ✅ **Automatic migration execution** - Runs migrations and validates schema.rb updates
- ✅ **Flexible configuration** - Customizable migration commands and working directories
- ✅ **Smart skipping** - Automatically skips schema checks when no migrations exist

## Basic Usage

```yaml
- uses: actions/checkout@v4
- uses: ruby/setup-ruby@v1
  with:
    ruby-version: 3.2
- uses: daigotanaka0714/rails-migration-check@v1
```

## Advanced Usage

### Skip Migration Execution

Useful for testing environments or when you don't want to run migrations:

```yaml
- uses: daigotanaka0714/rails-migration-check@v1
  with:
    skip-migration-execution: 'true'
```

### Custom Migration Command

For projects using different migration commands:

```yaml
- uses: daigotanaka0714/rails-migration-check@v1
  with:
    migration-command: 'bundle exec rake db:migrate'
```

### Custom Working Directory

For monorepo setups or when Rails app is in a subdirectory:

```yaml
- uses: daigotanaka0714/rails-migration-check@v1
  with:
    working-directory: './backend'
```

### Complete Example

```yaml
name: Rails Migration Check
on: [push, pull_request]

jobs:
  migration-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.2
          bundler-cache: true
          
      - name: Setup Database
        run: |
          bundle exec rails db:create
          bundle exec rails db:schema:load
          
      - uses: daigotanaka0714/rails-migration-check@v1
        with:
          migration-command: 'bundle exec rails db:migrate RAILS_ENV=test'
          working-directory: '.'
```

## Input Parameters

| Parameter | Description | Required | Default |
|-----------|-------------|----------|---------|
| `skip-migration-execution` | Skip executing rails db:migrate | No | `false` |
| `migration-command` | Custom migration command to run | No | `bundle exec rails db:migrate` |
| `working-directory` | Working directory where Rails project is located | No | `.` |

## What it checks

1. **Migration filename format** - Validates `YYYYMMDDHHMMSS_description.rb` format
2. **Migration method existence** - Ensures presence of `change`, `up`, or `down` methods
3. **Schema consistency** - Runs migrations and verifies `schema.rb` is updated
4. **Smart behavior** - Skips schema checks when no migration files exist

## Local Development

### Run Tests

```sh
bundle install
bundle exec rspec
```

### Manual Testing

```sh
ruby scripts/check_migrations.rb
```

## License

MIT
