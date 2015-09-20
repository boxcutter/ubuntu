require_relative 'spec_helper'

describe 'docker' do
  docker_string = command('ls /usr/bin/docker').stdout
  if docker_string.include? '/usr/bin/docker' then
    it 'should have docker installed' do
      expect(command('docker run hello-world').exit_status).to eq(0)
    end
  end
end
