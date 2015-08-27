require 'rails_helper'
require_relative '../../lib/tasks/scrape_helpers'

RSpec.describe 'scrape_helpers' do
  it 'should match the most common variant with the name location regexp ' do
    matches = ScrapeHelpers::NAME_LOCATION_REGEXP.match '20. Volkmer Margrit'
    expect(matches[:rank_category]).to eq('20')
    expect(matches[:name]).to eq('Volkmer Margrit')
    expect(matches[:location]).to be_nil
  end

  it 'should match the variant with location with the name location regexp' do
    matches = ScrapeHelpers::NAME_LOCATION_REGEXP.match '2. Voegeli Stephan, Bolligen'
    expect(matches[:rank_category]).to eq('2')
    expect(matches[:name]).to eq('Voegeli Stephan')
    expect(matches[:location]).to eq('Bolligen')
  end

  it 'should match the variant with last names with spaces with the name location regexp' do
    matches = ScrapeHelpers::NAME_LOCATION_REGEXP.match '1171. Van Der Lingen Patrick'
    expect(matches[:rank_category]).to eq('1171')
    expect(matches[:name]).to eq('Van Der Lingen Patrick')
    expect(matches[:location]).to be_nil
  end

  it 'should match the variant with last names with spaces and location with the name location regexp' do
    matches = ScrapeHelpers::NAME_LOCATION_REGEXP.match '1171. Van Der Lingen Patrick, Bern'
    expect(matches[:rank_category]).to eq('1171')
    expect(matches[:name]).to eq('Van Der Lingen Patrick')
    expect(matches[:location]).to eq('Bern')
  end

  it 'should match the variant with canton  with the name location regexp' do
    matches = ScrapeHelpers::NAME_LOCATION_REGEXP.match '132. Aebi Eugen, Lengnau BE'
    expect(matches[:rank_category]).to eq('132')
    expect(matches[:name]).to eq('Aebi Eugen')
    expect(matches[:location]).to eq('Lengnau BE')
  end

  it 'should match the variant with large string  with the name location regexp' do
    matches = ScrapeHelpers::NAME_LOCATION_REGEXP.match '1098. Aeschlimann Toni, Ostermundige 58 Ascom 4'
    expect(matches[:rank_category]).to eq('1098')
    expect(matches[:name]).to eq('Aeschlimann Toni')
    expect(matches[:location]).to eq('Ostermundige 58 Ascom 4')
  end

end
