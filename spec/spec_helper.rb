require 'pg'

ENV['RACK_ENV'] = 'test'
require "./config/environment.rb"

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.before(:all) do
    begin
      PG.connect(host:"postgres-redo", user: "admin", password: "password").exec("CREATE DATABASE rebase_redo")
    rescue
    end

    connect_pg_test = PG.connect(host:"postgres-redo", user: "admin", password: "password", dbname: 'rebase_redo')

    connect_pg_test.exec("CREATE TABLE IF NOT EXISTS patients (
      id SERIAL PRIMARY KEY,
      cpf VARCHAR(30) UNIQUE,
      name VARCHAR(100),
      email VARCHAR(100),
      birthday DATE,
      address VARCHAR(300),
      city VARCHAR(100),
      state VARCHAR(30)
    )")

    connect_pg_test.exec("CREATE TABLE IF NOT EXISTS doctors (
      id SERIAL PRIMARY KEY,
      crm VARCHAR(20) UNIQUE,
      crm_state VARCHAR(2),
      name VARCHAR(80),
      email VARCHAR(100)
    )")

    connect_pg_test.exec("CREATE TABLE IF NOT EXISTS exams (
      id SERIAL PRIMARY KEY,
      token VARCHAR(6) UNIQUE,
      result_date DATE,
      patient_id INTEGER REFERENCES patients(id),
      doctor_id INTEGER REFERENCES doctors(id)
    )")

    connect_pg_test.exec("CREATE TABLE IF NOT EXISTS tests (
      id SERIAL PRIMARY KEY,
      test_type VARCHAR(30),
      limits VARCHAR(30),
      result INTEGER,
      token_id VARCHAR(6) REFERENCES exams(token)
    )")

    connect_pg_test.close
  end

  config.after(:each) do
    connect_pg_test = PG.connect(host:"postgres-redo", user: "admin", password: "password", dbname: "rebase_redo")

    connect_pg_test.exec("DELETE FROM tests;")
    connect_pg_test.exec("DELETE FROM exams;")
    connect_pg_test.exec("DELETE FROM doctors;")
    connect_pg_test.exec("DELETE FROM patients;")

    connect_pg_test.close
  end

  # config.after(:all) do
  #   connect_pg_test = PG.connect(host:"postgres-redo", user: "admin", password: "password", dbname: 'rebase_redo')
  #   connect_pg_test.exec("SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE datname = 'rebase_redo';")
  #   connect_pg_test.exec("DROP DATABASE rebase_redo")
  #   connect_pg_test.close
  # end


  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.disable_monkey_patching!
  config.warnings = true

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  config.profile_examples = 10
  config.order = :random
  Kernel.srand config.seed
end
