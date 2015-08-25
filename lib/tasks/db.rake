require 'mechanize'
require 'csv'

namespace :db do
  desc "Scrapes data from the public website and writes it to a csv file."
  task scrape_data: :environment do
    year = 2012
    agent = Mechanize.new
    mech_page = agent.get("http://bern.mikatiming.de/#{year}/?page=1&event=GP&num_results=100&pid=search&search%5Bclub%5D=%25&search%5Bage_class%5D=%25&search%5Bsex%5D=%25&search%5Bnation%5D=%25&search%5Bstate%5D=%25&search_sort=name")
    page_number = 1
    # TODO: total is only estimate.
    progressbar = ProgressBar.create(total: 160, format: '%B %R pages/s, %a', :throttle_rate => 0.1)

    CSV.open("db/data/#{year}", 'wb', col_sep: ';') do |csv|
      while mech_page
        html_rows = mech_page.search('table.list-table tr')
        rows = html_rows.map {|i| i.css('td').map { |td| td.content.strip.gsub('»', '') }}
        rows.each {|row| csv << row }
        page_number += 1
        progressbar.increment
        next_link = mech_page.link_with(:text => page_number.to_s)
        break unless next_link
        mech_page = next_link.click
      end
    end
    progressbar.finish
  end
end
