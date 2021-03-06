require 'spec_helper'

consul_bin_dir  = '/usr/local/bin'
consul_conf_dir = '/etc/consul.d'

describe file("#{consul_conf_dir}/server/config.json") do
  it { should be_file }
  it { should be_mode 644 }
  its(:content) { should match /"leave_on_terminate":.*false/ }
  its(:content) { should match /"skip_leave_on_interrupt":.*true/ }
end

if os[:family] =~ /ubuntu|debian/
  describe file('/etc/init/consul.conf') do
    it { should be_file }
    it { should be_mode 644 }
  end
end

if os[:family] =~ /centos|redhat/
  describe file('/usr/lib/systemd/system/consul.service') do
    it { should be_file }
    it { should be_mode 644 }
  end
end

describe command("#{consul_bin_dir}/consul --version") do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match %r(Consul v0.6.4) }
end

describe service('consul') do
  it { should be_enabled }
  it { should be_running }
end

describe process('consul') do
  it { should be_running }
  its(:args) { should match %r(consul agent -config-dir .*) }
end

describe port(53) do
  it { should_not be_listening }
end

describe port(8600) do
  it { should be_listening }
end
