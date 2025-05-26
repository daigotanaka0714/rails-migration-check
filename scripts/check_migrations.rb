#!/usr/bin/env ruby
require 'fileutils'

puts "=== Rails migration file checker ==="

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

# Check schema.rb changes
schema_diff = `git diff --name-only db/schema.rb`
if schema_diff.strip.empty?
  errors << "❌ schema.rb has not been updated. Run `rails db:migrate` and commit changes."
end

if errors.any?
  puts errors.join("\n")
  exit 1
else
  puts "✅ All migrations look good."
end
