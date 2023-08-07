require 'sinatra'
require 'rack/handler/puma'
require 'csv'
require 'rack'
require 'json'
require 'sidekiq'
require_relative './public/csv_importer'
require_relative './public/tests_all'
require_relative './public/exams_all'
require_relative './public/exam_data'

set :public_folder, File.dirname(__FILE__) + '/public'
set :public_folder, File.dirname(__FILE__) + '/front_end'

get '/api/exams' do
  content_type :json
  ExamsAll.get_all_exams
end

get '/api/tests' do
  content_type :json
  TestsAll.get_all_tests
end

get '/exams' do
  File.open('./front_end/index.html').read
end

get '/exams/:token' do
  exam_data = ExamData.exam_data_by_token(params[:token].upcase)

  template = File.open('./front_end/show.html').read
  template.gsub('{%exam.token%}', exam_data[0]['exam_token'])
          .gsub('{%exam.result_date%}', exam_data[0]['exam_result_date'])
          .gsub('{%patient.cpf%}', exam_data[0]['patient_cpf'])
          .gsub('{%patient.name%}', exam_data[0]['patient_name'])
          .gsub('{%patient.email%}', exam_data[0]['patient_email'])
          .gsub('{%patient.birthday%}', exam_data[0]['patient_birthday'])
          .gsub('{%patient.address%}', exam_data[0]['patient_address'])
          .gsub('{%patient.city%}', exam_data[0]['patient_city'])
          .gsub('{%patient.state%}', exam_data[0]['patient_state'])
          .gsub('{%doctor.name%}', exam_data[0]['doctor_name'])
          .gsub('{%doctor.crm%}', exam_data[0]['doctor_crm'])
          .gsub('{%doctor.crm_state%}', exam_data[0]['doctor_crm_state'])
          .gsub('{%doctor.email%}', exam_data[0]['doctor_email'])
          .gsub('{%hemacias.limits%}', exam_data[0]['test_limits'])
          .gsub('{%hemacias.result%}', exam_data[0]['test_result'])
          .gsub('{%leucocitos.limits%}', exam_data[1]['test_limits'])
          .gsub('{%leucocitos.result%}', exam_data[1]['test_result'])
          .gsub('{%plaquetas.limits%}', exam_data[2]['test_limits'])
          .gsub('{%plaquetas.result%}', exam_data[2]['test_result'])
          .gsub('{%hdl.limits%}', exam_data[3]['test_limits'])
          .gsub('{%hdl.result%}', exam_data[3]['test_result'])
          .gsub('{%ldl.limits%}', exam_data[4]['test_limits'])
          .gsub('{%ldl.result%}', exam_data[4]['test_result'])
          .gsub('{%vldl.limits%}', exam_data[5]['test_limits'])
          .gsub('{%vldl.result%}', exam_data[5]['test_result'])
          .gsub('{%glicemia.limits%}', exam_data[6]['test_limits'])
          .gsub('{%glicemia.result%}', exam_data[6]['test_result'])
          .gsub('{%tgo.limits%}', exam_data[7]['test_limits'])
          .gsub('{%tgo.result%}', exam_data[7]['test_result'])
          .gsub('{%tgp.limits%}', exam_data[8]['test_limits'])
          .gsub('{%tgp.result%}', exam_data[8]['test_result'])
          .gsub('{%eletrolitos.limits%}', exam_data[9]['test_limits'])
          .gsub('{%eletrolitos.result%}', exam_data[9]['test_result'])
          .gsub('{%tsh.limits%}', exam_data[10]['test_limits'])
          .gsub('{%tsh.result%}', exam_data[10]['test_result'])
          .gsub('{%t4-livre.limits%}', exam_data[11]['test_limits'])
          .gsub('{%t4-livre.result%}', exam_data[11]['test_result'])
          .gsub('{%acido_urico.limits%}', exam_data[12]['test_limits'])
          .gsub('{%acido_urico.result%}', exam_data[12]['test_result'])
end

post '/import_csv' do
  csv_content = params['csvFile'][:tempfile].read.force_encoding("UTF-8")
  CsvImporter.perform_async(csv_content)
end

get '/csv-upload' do
  File.open('./front_end/import.html').read
end

get '/csv-tests' do
  rows = CSV.read('./public/data.csv', col_sep: ';')
  columns = rows.shift
  rows.map do |row|
    row.each_with_object({}).with_index do |(cell, acc), idx|
      column = columns[idx]
      acc[column] = cell
    end
  end.to_json
end

if ENV['RACK_ENV'] != 'test'
  Rack::Handler::Puma.run(
    Sinatra::Application,
    Port: 3000,
    Host: '0.0.0.0'
  )
end