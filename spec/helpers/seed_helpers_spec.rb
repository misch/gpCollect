require 'rails_helper'
require_relative '../../db/seed_helpers'

RSpec.describe 'seed_helpers' do
  it 'should match the most common variant with the name regexp' do
    matches = NAME_REGEXP.match 'Abati, Mauro (SUI)'
    expect(matches[:last_name]).to eq('Abati')
    expect(matches[:first_name]).to eq('Mauro')
    expect(matches[:nationality]).to eq('SUI')
  end

  it 'should match names with composed first names separated by dash with the name regexp' do
    matches = NAME_REGEXP.match 'Abegglen, Marie-Thérèse (SUI)'
    expect(matches[:last_name]).to eq('Abegglen')
    expect(matches[:first_name]).to eq('Marie-Thérèse')
    expect(matches[:nationality]).to eq('SUI')
  end

  it 'should match names with composed last names separated by dash with the name regexp' do
    matches = NAME_REGEXP.match 'Aegerter-Rüegsegger, Verena (SUI)'
    expect(matches[:last_name]).to eq('Aegerter-Rüegsegger')
    expect(matches[:first_name]).to eq('Verena')
    expect(matches[:nationality]).to eq('SUI')
  end

  it 'should match names with composed first names separated by space with the name regexp' do
    matches = NAME_REGEXP.match 'Aeschlimann, Karin Andrea (SUI)'
    expect(matches[:last_name]).to eq('Aeschlimann')
    expect(matches[:first_name]).to eq('Karin Andrea')
    expect(matches[:nationality]).to eq('SUI')
  end

  it 'should match names without nationality' do
    matches = NAME_REGEXP.match 'von Allmen-Sarmiento, Teresita'
    expect(matches).to be_truthy
    expect(matches[:last_name]).to eq('von Allmen-Sarmiento')
    expect(matches[:first_name]).to eq('Teresita')
    expect(matches[:nationality]).to be nil
  end

  it 'should not match if only nationality is present' do
    matches = NAME_REGEXP.match '(SUI)'
    expect(matches).to be_falsey
  end
end
