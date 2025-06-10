#!/usr/bin/env ruby
require 'fileutils'

puts "=== Rails db/migrate file checker ==="
migrations = Dir.glob('db/migrate/*.rb')
errors = []

migrations.each do |file|
  filename = File.basename(file)
  
  unless filename.match?(/^\d{14}_.+\.rb$/)
    errors << "❌ Invalid filename format: #{filename}"
  end
  
  content = File.read(file)
  unless content.include?('def change') || content.include?('def up') || content.include?('def down')
    errors << "❌ No migration method found in: #{filename}"
  end
end

# Execute migrations only if not explicitly skipped
skip_migration_execution = ENV['SKIP_MIGRATION_EXECUTION'] == 'true'
unless skip_migration_execution
  puts "=== Rails db/schema.rb file checker ==="
  # Now execute migrations manually
  # Use custom migration command if provided, otherwise use default
  migration_command = ENV.fetch('MIGRATION_COMMAND', 'bundle exec rails db:migrate')
  puts "Running: #{migration_command}"
  system(migration_command)
end

# Check schema.rb changes only if migrations exist and not in test environment
skip_git_check = ENV['SKIP_GIT_CHECK'] == 'true'
unless skip_git_check
  if migrations.any?
    if ENV['MOCK_GIT_DIFF']
      schema_diff = ENV['MOCK_GIT_DIFF']
    else
      # Get schema.rb diff after running migrations
      schema_diff = `git diff --name-only db/schema.rb`
    end
    
    if schema_diff.strip.empty?
      errors << "❌ schema.rb has not been updated. Run `rails db:migrate` and commit changes."
    end
  else
    puts "ℹ️  No migration files found. Skipping schema.rb check."
  end
end

if errors.any?
  puts errors.join("\n")
  exit false
else
  puts "✅ All migrations look good."
  exit true
end
