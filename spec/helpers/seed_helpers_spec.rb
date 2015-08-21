require 'rails_helper'
load 'db/seed_helpers.rb'

RSpec.describe 'seed_helpers' do
  it 'should match all variants of names with the name regexp' do
    matches = NAME_REGEXP.match 'Abati, Mauro (SUI)'
    expect(matches[1]).to eq('Abati')
    expect(matches[2]).to eq('Mauro')
    expect(matches[3]).to eq('SUI')
  end
end
