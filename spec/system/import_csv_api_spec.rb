require 'spec_helper'
require 'sinatra'
require 'rspec'
require 'rack/test'
require_relative '../../public/db_populate'
require_relative '../../server'
require_relative 'reset_database'

ENV['RACK_ENV'] = 'test'

RSpec.describe "API", type: :request do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  context '/api/exams' do
    it 'retorna um array vazio quando é carregado um arquivo csv sem conteúdo com o cabeçalho' do
      DbPopulate.db_populate_from_csv('./spec/support/data_test_empty.csv')
      get '/api/exams'

      expect(JSON.parse(last_response.body)).to eq([])
      expect(last_response).to be_ok
    end

    it 'retorna 200 e todos os exames cadastrados' do
      DbPopulate.db_populate_from_csv('./spec/support/data_test.csv')

      get '/api/exams'

      expect(last_response.content_type).to eq 'application/json'
      expect(last_response).to be_ok
      expect(last_response.status).to eq 200
      json_response = JSON.parse(last_response.body)
      expect(json_response).to be_an(Array)
      expect(json_response.length).to eq(3)
      expect(json_response[0]['cpf']).to eq('048.973.170-88')
      expect(json_response[1]['cpf']).to eq('048.108.026-04')
      expect(json_response[2]['cpf']).to eq('066.126.400-90')
      ResetDatabase.reset
    end
  end

  context '/api/tests' do
    it 'retorna um array vazio quando é carregado um arquivo csv sem conteúdo com o cabeçalho' do
      DbPopulate.db_populate_from_csv('./spec/support/data_test_empty.csv')
      get '/api/tests'

      expect(last_response.status).to eq 200
      expect(last_response.body).to eq("[]")
      json_response = JSON.parse(last_response.body)
    end

    it 'retorna 200 e todos os exames cadastrados' do
      DbPopulate.db_populate_from_csv('./spec/support/data_test.csv')

      get '/api/tests'

      expect(last_response.content_type).to eq 'application/json'
      expect(last_response).to be_ok
      expect(last_response.status).to eq 200
      json_response = JSON.parse(last_response.body)
      expect(json_response).to be_an(Array)
      expect(json_response.length).to eq(39)
      expect(json_response[0]['cpf']).to eq('048.973.170-88')
      expect(json_response[15]['cpf']).to eq('048.108.026-04')
      expect(json_response[27]['cpf']).to eq('066.126.400-90')
      ResetDatabase.reset
    end
  end
end