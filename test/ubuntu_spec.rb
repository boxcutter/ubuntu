require_relative 'spec_helper'

describe 'box' do
  it 'should have a root user' do
    expect(user 'root').to exist
  end
  
  it 'should have a vagrant user' do
    expect(user 'vagrant').to exist
  end
end
