require 'pg'
require 'json'

$connect_pg = PG.connect(host: 'postgres-redo', user: 'admin', password: 'password', dbname: 'rebase_redo')

module ExamsAll
  def self.get_all_exams
    results = $connect_pg.exec("
      SELECT

        tests.id AS test_id,
        patients.cpf AS patient_cpf,
        patients.name AS patient_name,
        patients.email AS patient_email,
        patients.birthday AS patient_birthday,
        patients.address AS patient_address,
        patients.city AS patient_city,
        patients.state AS patient_state,
        doctors.name AS doctor_name,
        doctors.crm AS doctor_crm,
        doctors.crm_state AS doctor_crm_state,
        doctors.email AS doctor_email,
        exams.token AS exam_token,
        exams.result_date AS exam_result_date,
        tests.test_type AS test_type,
        tests.limits AS test_limits,
        tests.result AS test_result

      FROM exams

      JOIN tests ON exams.token = tests.token_id
      JOIN patients ON exams.patient_id = patients.id
      JOIN doctors ON exams.doctor_id = doctors.id;
    ")



    exams_per_token = results.group_by { |row| row['exam_token'] }.map do |token, rows|

      doctor_info = {
        'nome médico': rows.first['doctor_name'],
        'crm médico': rows.first['doctor_crm'],
        'crm médico estado': rows.first['doctor_crm_state'],
        'email médico': rows.first['doctor_email'],
      }

      tests_for_exam = rows.map do |row|
        {
          'tipo exame': row['test_type'],
          'limites tipo exame': row['test_limits'],
          'resultado': row['test_result']
        }

      end

      {
        'token resultado exame': token,
        'nome paciente': rows.first['patient_name'],
        'data exame': rows.first['exam_result_date'],
        'cpf': rows.first['patient_cpf'],
        'email paciente': rows.first['patient_email'],
        'data nascimento paciente': rows.first['patient_birthday'],
        'endereço/rua paciente': rows.first['patient_address'],
        'cidade paciente': rows.first['patient_city'],
        'estado paciente': rows.first['patient_state'],
        'médico responsável': doctor_info,
        'testes deste exame': tests_for_exam
      }
    end

    exams_per_token.to_json
  end
end
