require 'fileutils'

def run_test(fixture_path, expected_success)
  puts "== Running test: #{fixture_path}"

  FileUtils.rm_rf('db/migrate')
  FileUtils.mkdir_p('db/migrate')
  FileUtils.cp_r(Dir["#{fixture_path}/*.rb"], 'db/migrate')
  FileUtils.cp("#{fixture_path}/schema.rb", 'db/schema.rb')

  result = system("ruby scripts/check_migrations.rb")
  status = $?.exitstatus

  if expected_success && status != 0
    puts "❌ Expected success but failed: #{fixture_path}"
    exit 1
  elsif !expected_success && status == 0
    puts "❌ Expected failure but passed: #{fixture_path}"
    exit 1
  else
    puts "✅ Test passed: #{fixture_path}"
  end
end

run_test("test/fixtures/valid", true)
run_test("test/fixtures/invalid", false)
