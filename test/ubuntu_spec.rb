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
end
