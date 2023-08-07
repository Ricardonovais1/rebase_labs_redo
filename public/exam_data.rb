require 'pg'
require 'json'

class ExamData
  def self.exam_data_by_token(token)
    pg_conn = PG.connect(host: 'postgres-redo', user: 'admin', password: 'password', dbname: 'rebase_redo')

    exam_data = pg_conn.exec("
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
        JOIN doctors ON exams.doctor_id = doctors.id

        WHERE exams.token = $1", [token])
  end
end