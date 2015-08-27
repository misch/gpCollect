module ScrapeHelpers
  NAME_LOCATION_REGEXP = /(?<rank_category>\d+). (?<name>[^,]+)(?:, (?<location>[[:alpha:]]+))?$/
  TIME_RANK_REGEXP = /(?<time>[^ ]+) \((?<start_number>\d+)\)/
  RUN_TYPE_OVERALL_RANK_REGEXP = /[A-Z]+\/(?<rank>)./

  # One old html row looks like this:
  # ["M40", "270. Aymon Alain", "57 Bussigny", "1:09.00,2 (2032)", "GM/1604."]
  # Target format is
  # Platz;Pl.AK;Pl.(M/W);Nr.;Name;AK;Verein/Ort;Rel *;5km;10km;Zielzeit
  def self.old_html_row_to_csv_row(row)
    is_gp = row[4].first == 'G'
    return nil unless is_gp
    category = row[0]
    name_location_matches = NAME_LOCATION_REGEXP.match(row[1])
    name = name_location_matches[:name]
    # TODO: convert name to csv name format.
    csv_name = nil

    rank_category = name_location_matches[:rank_category]

    club_or_hometown = row[2].presence || name_location_matches[:location]
    time_rank_matches = TIME_RANK_REGEXP.match(row[3])
    start_number = time_rank_matches[:start_number]
    time = time_rank_matches[:time]

    rank = RUN_TYPE_OVERALL_RANK_REGEXP.match(row[4])[:rank]
    [rank, rank_category, nil, start_number, csv_name, category, club_or_hometown, nil, nil, nil, time]
  end
end