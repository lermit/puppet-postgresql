require "#{File.join(File.dirname(__FILE__),'..','spec_helper.rb')}"

describe 'postgresql::cluster', :type => :define do

  let(:title) { 'my_cluster' }
  let(:node) { 'rspec.example42.com' }
  let(:facts) { { :arch => 'i386', :operatingsystem => 'Debian' } }

  describe 'Test postgresql::cluster should create a cluster' do
    let(:params) { { :owner => 'theowner' } }
    it { should contain_exec('postgres-manage-cluster-my_cluster').with_command(/pg_createcluster/) }
    it { should contain_exec('postgres-manage-cluster-my_cluster').without_onlyif() }
    it { should contain_exec('postgres-manage-cluster-my_cluster').with_user('postgres') }
    it { should contain_exec('postgres-manage-cluster-my_cluster').with_require(/Package/) }
  end

  describe 'Test postgresql::cluster - delete cluster' do
    let(:params) { { :absent => true } }
    it { should contain_exec('postgres-manage-cluster-my_cluster').with_command(/pg_dropcluster/) }
    it { should contain_exec('postgres-manage-cluster-my_cluster').without_unless() }
    it { should contain_exec('postgres-manage-cluster-my_cluster').with_user('postgres') }
    it { should contain_exec('postgres-manage-cluster-my_cluster').with_require(/Package/) }
  end
end
