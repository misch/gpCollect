require 'mechanize'
require 'csv'


namespace :db do
  desc "Scrapes data from the public website and writes it to a csv file."
  task scrape_data: :environment do
    COMPATIBLE_YEARS = (2009..2012)
    COMPATIBLE_YEARS.each do |year|
      agent = Mechanize.new
      mech_page = agent.get("http://bern.mikatiming.de/#{year}/?page=1&event=GP&num_results=100&pid=search&search%5Bclub%5D=%25&search%5Bage_class%5D=%25&search%5Bsex%5D=%25&search%5Bnation%5D=%25&search%5Bstate%5D=%25&search_sort=name")
      page_number = 1
      # TODO: total is only estimate.
      progressbar = ProgressBar.create(title: "Scraping #{year}", total: 160,
                                       format: '%t %B %R pages/s, %a', :throttle_rate => 0.1)

      CSV.open("db/data/gp_bern_10m_#{year}.csv", 'wb', col_sep: ';') do |csv|
        while mech_page
          html_rows = if page == 1
                        # For first page, also parse table header
                        mech_page.search('table.list-table tr')
                      else
                        mech_page.search('table.list-table tbody tr')
                      end
          rows = html_rows.map {|i| i.css('td').map do |td|
            # Once in a while an attribute is truncated, marked by trailing '...'.
            # The full string can then be parsed by getting the title attribute of the span contained.
            if td.content.include? '...'
              td.css('span')[0][:title]
            else
              td.content
            end.gsub('»', '').strip
          end
          }
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
end
