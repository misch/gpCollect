module ScrapeHelpers
  NAME_LOCATION_REGEXP = /(?<rank_category>\d+). (?<name>[^,]+)(?:, (?<location>[[:alpha:]]+))?$/
  RUN_TYPE_OVERALL_RANK_REGEXP = /[A-Z]+\/(?<rank>\d+)./

  # One old html row looks like this:
  # ["M35", "783. Ayrom Houman", "62 Morges", "1:18.32,7", "8036)", "GM/4146."]  # Target format is
  # Platz;Pl.AK;Pl.(M/W);Nr.;Name;AK;Verein/Ort;Rel *;5km;10km;Zielzeit
  def self.old_html_row_to_csv_row(row)
    is_gp = row[5].first == 'G'
    return nil unless is_gp
    category = if row[0].include? '/'
                 # for year 2000+, this column looks like this: 'GP/M30'
                 row[0].split('/')[1]
               else
                 row[0]
               end
    name_location_matches = NAME_LOCATION_REGEXP.match(row[1])
    rank_category = name_location_matches[:rank_category]
    name = name_location_matches[:name]
    # TODO: convert name to csv name format.
    first_name, last_name = split_name(name)

    csv_name = nil

    birth_year, club_or_hometown = row[2].split(' ')
    club_or_hometown ||= name_location_matches[:location]

    time = row[3]
    start_number = row[4].gsub(')', '')

    rank = RUN_TYPE_OVERALL_RANK_REGEXP.match(row[5])[:rank]
    [rank, rank_category, nil, start_number, csv_name, category, club_or_hometown, nil, nil, nil, time, birth_year]
  end

  # A name consists of a last_name and a first_name. Each can contain multiple words, e.g.
  # e.g. Van Der Sluis Jan --> [Van Der Sluis, Jan]
  def self.split_name(name)
    splitted = name.split
    if splitted.size == 2
      splitted
    else
      if name.lower.start_with?(['van der, von der'])
        splitted[0..1].join(' '), splitted[2..-1]
      end
    end


  end
end