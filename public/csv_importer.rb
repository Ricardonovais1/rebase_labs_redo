require 'sidekiq'
require 'csv'
require_relative 'db_setup'
require_relative 'db_populate'

class CsvImporter
  include Sidekiq::Worker

  def perform(csv_file)
    @db = PG.connect(host: 'postgres-redo', user: 'admin', password: 'password', dbname: 'rebase_redo')
    @exams_data = convert_csv_to_array_of_hashes(csv_file)

    @exams_data.each do |individual_test|
      populate_patients_table(individual_test, @db)
      populate_doctors_table(individual_test, @db)
      populate_exams_and_tests_table(individual_test, @db)
    end
  end

  def convert_csv_to_array_of_hashes(csv_file)
    rows = CSV.parse(csv_file, col_sep: ';')
    columns = rows.shift
    rows.map do |row|
      row.each_with_object({}).with_index do |(cell, acc), idx|
        column = columns[idx]
        acc[column] = cell
      end
    end
  end

  def populate_patients_table(test, db)
    @patient_not_in_table = db.exec('SELECT * FROM patients WHERE cpf = $1', [test['cpf']]).num_tuples.zero?

    if @patient_not_in_table
      db.exec('INSERT INTO patients (cpf, name, email, birthday, address, city, state) VALUES ($1, $2, $3, $4, $5, $6, $7)',
              [
                test['cpf'],
                test['nome paciente'],
                test['email paciente'],
                test['data nascimento paciente'],
                test['endereço/rua paciente'],
                test['cidade paciente'],
                test['estado patiente']
            ])
    end
  end

  def populate_doctors_table(test, db)
    @doctor_not_in_table = db.exec('SELECT * FROM doctors WHERE crm = $1', [test['crm médico']]).num_tuples.zero?

    if @doctor_not_in_table
      db.exec('INSERT INTO doctors (crm, crm_state, name, email) VALUES ($1, $2, $3, $4)',
              [
                test['crm médico'],
                test['crm médico estado'],
                test['nome médico'],
                test['email médico']
              ])
    end
  end

  def populate_exams_and_tests_table(test, db)
    exam_token = test['token resultado exame']
    exam_not_in_table = db.exec('SELECT * FROM exams WHERE token = $1', [exam_token]).num_tuples.zero?

    if exam_not_in_table
      patient_id = db.exec('SELECT id FROM patients WHERE cpf = $1', [test['cpf']]).first&.fetch('id')&.to_i
      doctor_id = db.exec('SELECT id FROM doctors WHERE crm = $1', [test['crm médico']]).first&.fetch('id')&.to_i

      db.exec('INSERT INTO exams (token, result_date, patient_id, doctor_id) VALUES ($1, $2, $3, $4)',
              [
                test['token resultado exame'],
                test['data exame'],
                patient_id,
                doctor_id
              ])
    end

    tests_from_this_exam = @exams_data.select { |exam| exam['token resultado exame'] == exam_token }

    test_not_in_table = db.exec('SELECT * FROM tests WHERE test_type = $1 AND token_id = $2', [test['tipo exame'], exam_token]).num_tuples.zero?

    tests_from_this_exam.each do |single_test|

      if test_not_in_table
        db.exec('INSERT INTO tests (test_type, limits, result, token_id) VALUES ($1, $2, $3, $4)',
                [
                  single_test['tipo exame'],
                  single_test['limites tipo exame'],
                  single_test['resultado tipo exame'],
                  exam_token,
                ])
      end
    end
  end
end