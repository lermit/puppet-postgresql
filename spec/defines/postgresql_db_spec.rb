require "#{File.join(File.dirname(__FILE__),'..','spec_helper.rb')}"

describe 'postgresql::db', :type => :define do

  let(:title) { 'my_db' }
  let(:node) { 'rspec.example42.com' }
  let(:facts) { { :arch => 'i386', :operatingsystem => 'Debian' } }

  describe 'Test postgresql::db should create a database named my_db' do
    let(:params) { { :owner => 'theowner' } }
    it { should contain_exec('postgres-manage-database-my_db').with_command(/CREATE DATABASE/) }
    it 'should enclose database into double quote' do
      should contain_exec('postgres-manage-database-my_db').with_command(/\\\"my_db\\\"/)
    end
    it 'should enclose owner into double quote' do
      should contain_exec('postgres-manage-database-my_db').with_command(/\\\"theowner\\\"/)
    end
    it { should contain_exec('postgres-manage-database-my_db').without_onlyif() }
    it { should contain_exec('postgres-manage-database-my_db').with_user('postgres') }
    it { should contain_exec('postgres-manage-database-my_db').with_require(/Postgresql::Role/) }
  end

  describe 'Test postgresql::db - delete database' do
    let(:params) { { :absent => true } }
    it { should contain_exec('postgres-manage-database-my_db').with_command(/DROP DATABASE/) }
    it 'should enclose database into double quote' do
      should contain_exec('postgres-manage-database-my_db').with_command(/\\\"my_db\\\"/)
    end
    it { should contain_exec('postgres-manage-database-my_db').without_unless() }
    it { should contain_exec('postgres-manage-database-my_db').with_user('postgres') }
  end
end
