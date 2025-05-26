require 'fileutils'
require 'stringio'
require 'open3'

RSpec.describe "Migration Checker Script" do
  # Common setup and cleanup
  after(:each) do
    cleanup_test_environment
  end

  # Common test patterns
  shared_examples "migration check behavior" do |expected_result, description|
    it description do
      expect(run_migration_check).to send("be_#{expected_result}")
    end
  end

  shared_examples "git integration behavior" do |git_diff_result, expected_result, description|
    it description do
      mock_git_diff(git_diff_result)
      expect(run_migration_check).to send("be_#{expected_result}")
    end
  end

  describe "with valid migrations" do
    before(:each) do
      setup_test_environment('valid', skip_git: true)
    end

    include_examples "migration check behavior", :successful, "passes with valid migrations"
  end

  describe "with invalid migrations" do
    before(:each) do
      setup_test_environment('invalid', skip_git: true)
    end

    include_examples "migration check behavior", :failed, "fails with invalid migrations"
  end

  describe "with no migrations" do
    before(:each) do
      create_test_directories
      copy_schema_file('valid')
    end

    include_examples "migration check behavior", :successful, "passes when no migration files exist"

    it "displays informational message about skipping schema check" do
      result = run_migration_check_with_output
      expect(result[:output]).to include("No migration files found. Skipping schema.rb check.")
      expect(result[:success]).to be true
    end
  end

  describe "with git integration" do
    before(:each) do
      setup_test_environment('valid')
    end

    context "when schema.rb is not updated" do
      include_examples "git integration behavior", '', :failed, "fails the check"
    end

    context "when schema.rb is updated" do
      include_examples "git integration behavior", 'db/schema.rb', :successful, "passes the check"
    end

    context "when no migrations exist" do
      before(:each) do
        FileUtils.rm_rf("db/migrate")
        FileUtils.mkdir_p("db/migrate")  # Create empty directory
      end

      it "skips schema.rb check and passes" do
        result = run_migration_check_with_output
        expect(result[:output]).to include("No migration files found. Skipping schema.rb check.")
        expect(result[:success]).to be true
      end
    end
  end

  private

  # Setup test environment
  def setup_test_environment(fixture_type, skip_git: false)
    create_test_directories
    copy_migration_files(fixture_type)
    copy_schema_file(fixture_type)
    configure_git_behavior(skip_git)
  end

  # Cleanup test environment
  def cleanup_test_environment
    FileUtils.rm_rf("db")
    clear_environment_variables
  end

  # Create test directories
  def create_test_directories
    FileUtils.mkdir_p("db/migrate")
    FileUtils.mkdir_p("db")
  end

  # Copy migration files
  def copy_migration_files(fixture_type)
    migration_files_for(fixture_type).each do |file|
      FileUtils.cp(file, "db/migrate/")
    end
  end

  # Copy schema.rb file
  def copy_schema_file(fixture_type)
    FileUtils.cp(schema_file_for(fixture_type), "db/schema.rb")
  end

  # Configure Git behavior
  def configure_git_behavior(skip_git)
    ENV['SKIP_GIT_CHECK'] = 'true' if skip_git
  end

  # Mock Git diff
  def mock_git_diff(diff_result)
    ENV['MOCK_GIT_DIFF'] = diff_result
  end

  # Clear environment variables
  def clear_environment_variables
    %w[SKIP_GIT_CHECK MOCK_GIT_DIFF SKIP_MIGRATION_EXECUTION].each { |var| ENV.delete(var) }
  end

  # Execute migration check
  def run_migration_check
    ENV['SKIP_MIGRATION_EXECUTION'] = 'true'  # Skip migration execution in tests
    MigrationCheckResult.new(system("ruby scripts/check_migrations.rb"))
  end

  # Execute migration check with output capture
  def run_migration_check_with_output
    ENV['SKIP_MIGRATION_EXECUTION'] = 'true'  # Skip migration execution in tests
    stdout, stderr, status = Open3.capture3("ruby scripts/check_migrations.rb")
    {
      output: stdout,
      error: stderr,
      success: status.success?
    }
  end

  # Helper to capture output
  def capture_output
    original_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = original_stdout
  end

  # File path helpers
  def migration_files_for(fixture_type)
    Dir["fixtures/#{fixture_type}/*_*.rb"]
  end

  def schema_file_for(fixture_type)
    "fixtures/#{fixture_type}/schema.rb"
  end

  # Result object wrapper class
  class MigrationCheckResult
    def initialize(system_result)
      @system_result = system_result
    end

    def successful?
      @system_result == true
    end

    def failed?
      @system_result == false
    end
  end

  # Custom matcher definitions
  RSpec::Matchers.define :be_successful do
    match do |actual|
      actual.successful?
    end

    failure_message do |actual|
      "expected migration check to be successful, but it failed"
    end
  end

  RSpec::Matchers.define :be_failed do
    match do |actual|
      actual.failed?
    end

    failure_message do |actual|
      "expected migration check to fail, but it was successful"
    end
  end
end
