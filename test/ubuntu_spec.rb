require_relative 'spec_helper'

describe 'box' do
  it 'should have a root user' do
    expect(user 'root').to exist
  end

  has_docker = command('command -v docker').exit_status == 0
  it 'should make vagrant a member of the docker group', :if => has_docker do
    expect(user 'vagrant').to belong_to_group 'docker'
  end

  it 'should turn off release upgrades' do
    expect(file('/etc/update-manager/release-upgrades').content)
      .to match(/Prompt=never/)
  end

  it 'should use English and UTF-8 for locale' do
    env = {}
    (command 'env').stdout.each_line do |line|
      var, *value = line.gsub(/[\r\n]+$/, '').split('=')
      env[var] = value.join('=')
    end

    ['COLLATE', 'CTYPE', 'MESSAGES', 'MONETARY', 'NUMERIC', 'TYPE'].each do
      value = env['LC_ALL'] || env["LC_#{value}"] || env['LANG']
      expect(value).to eq('en_US.UTF-8')
    end

    language = env['LANGUAGE']
    if language
      expect(language.split(':').first).to be_nil.or match(/^en(_US)?$/)
    end
  end
end
