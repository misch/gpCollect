require 'rails_helper'
require_relative '../../lib/tasks/scrape_helpers'

RSpec.describe 'scrape_helpers' do
  it 'should match the most common variant with the name location regexp ' do
    matches = ScrapeHelpers::NAME_LOCATION_REGEXP.match '20. Volkmer Margrit'
    expect(matches[:rank_category]).to eq('20')
    expect(matches[:name]).to eq('Volkmer Margrit')
    expect(matches[:location]).to be_nil
  end

  it 'should match the variant with location with the name location regexp ' do
    matches = ScrapeHelpers::NAME_LOCATION_REGEXP.match '2. Voegeli Stephan, Bolligen'
    expect(matches[:rank_category]).to eq('2')
    expect(matches[:name]).to eq('Voegeli Stephan')
    expect(matches[:location]).to eq('Bolligen')
  end

  it 'should match the variant with last names with spaces with the name location regexp ' do
    matches = ScrapeHelpers::NAME_LOCATION_REGEXP.match '1171. Van Der Lingen Patrick'
    expect(matches[:rank_category]).to eq('1171')
    expect(matches[:name]).to eq('Van Der Lingen Patrick')
    expect(matches[:location]).to be_nil
  end

  it 'should match the variant with last names with spaces and location with the name location regexp ' do
    matches = ScrapeHelpers::NAME_LOCATION_REGEXP.match '1171. Van Der Lingen Patrick, Bern'
    expect(matches[:rank_category]).to eq('1171')
    expect(matches[:name]).to eq('Van Der Lingen Patrick')
    expect(matches[:location]).to eq('Bern')
  end

end
