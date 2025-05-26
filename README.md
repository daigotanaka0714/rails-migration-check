# rails-migration-check

[![CI](https://github.com/daigotanaka0714/rails-migration-check/actions/workflows/test.yml/badge.svg)](https://github.com/daigotanaka0714/rails-migration-check/actions/workflows/test.yml)
[![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Reusable GitHub Action to check for Rails migration file inconsistencies (file naming, method presence, schema.rb update).

## Usage

Add to your workflow:

```yaml
- uses: actions/checkout@v4
- uses: ruby/setup-ruby@v1
  with:
    ruby-version: 3.2
- uses: daigotanaka0714/rails-migration-check@v1
```

## What it checks

- Migration filename format
- Migration method existence (`change`, `up`, or `down`)
- `schema.rb` updated

## Local Test

Run all self-tests:

```sh
ruby test/run_tests.rb
```

## License

MIT
