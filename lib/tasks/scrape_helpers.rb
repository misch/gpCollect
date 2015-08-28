module ScrapeHelpers
  NAME_LOCATION_REGEXP = /^(?<rank_category>\d+). (?<name>[^,]+)(?:, (?<location>.+))?$/
  RUN_TYPE_OVERALL_RANK_REGEXP = /^[A-Z]+\/(?<rank>\d+).$/

  # One old html row looks like this (for 1999):
  # ["M35", "783. Ayrom Houman", "62 Morges", "1:18.32,7", "8036)", "GM/4146."]
  # For 2000:
  # ["GP/W20", "92. Allenbach Katharina", "71 Ried (Frutigen)", "1:18.24,0", "6013)", "GF/361."]
  # # Target format is
  # Platz;Pl.AK;Pl.(M/W);Nr.;Name;AK;Verein/Ort;Rel *;5km;10km;Zielzeit
  def self.old_html_row_to_csv_row(row, options={})
    if row[1].length > 40
      # Most probably, name, birth_year and club_or_hometown are merged. Find where to split:
      name, club_or_hometown = row[1].split(/(?<=[[[:alpha:]].-]) (?=\d{2} )/)
      # And reinsert into row.
      row[1] = name
      row.insert(2, club_or_hometown)
    end
    unless row[3].match /\.\d{2},\d$/
      # This should be a duration.
      # If it's not, we split location by accident -> remove the additional column and merge with previous.
      row[2] << '(' + row.delete_at(3)
    end
    return nil unless is_gp?(row)
    category = if row[0].include? '/'
                 # for year 2000+, this column looks like this: 'GP/M30'
                 row[0].split('/')[1]
               else
                 row[0]
               end
    name_location_matches = NAME_LOCATION_REGEXP.match(row[1])
    rank_category = name_location_matches[:rank_category]
    name = name_location_matches[:name]
    # If no name is available, only 'Startnummer' is given. We don't scrape these.
    return nil if name.include? 'Startnummer'

    # convert name to csv name format.
    csv_name = split_name(name).join(', ')

    birth_year, club_or_hometown = row[2].split(' ')
    club_or_hometown ||= name_location_matches[:location]

    # Convert from 59.09,9 to 59:09.9
    time = row[3].gsub('.', ':').gsub(',', '.')

    start_number = row[options.fetch(:start_number_column, 4)].gsub(')', '')

    if row.size >= 10
      km5 = row[7]
      # TODO: km10 is actually row[7] + row[9]
      km10 = row[9]
      # Not used
      km10toFinish = row[11]
    else
      km5 = nil
    end
    rank_match = RUN_TYPE_OVERALL_RANK_REGEXP.match(row[5])
    if rank_match
      rank = rank_match[:rank]
    end
    [rank, rank_category, nil, start_number, csv_name, category, club_or_hometown, km5, nil, nil, time, birth_year]
  end

  COMPOSED_LAST_NAME_STARTERS = ['van ', 'von ', 'di ', 'de ', 'el ' 'le ', 'del ', 'du ', 'des ', 'le ', 'la ',
                                 'della ', 'dalla ', 'mc ']
  # A name consists of a last_name and a first_name. Each can contain multiple words, e.g.
  # e.g. Van Der Sluis Jan --> [Van Der Sluis, Jan]
  # returns [last_name, first_name]
  def self.split_name(name)
    name_array = name.split
    if name_array.size == 2
      name_array
    else
      split_position = case
                         when name.downcase.start_with?('van der ', 'von der ', 'auf der ')
                           name_array.size > 3 ? 2 : 1
                         when name.downcase.start_with?(*COMPOSED_LAST_NAME_STARTERS)
                           name_array.size > 2 ? 1 : 0
                         else
                           name_array.size/2 - 1
                       end
      [name_array[0..split_position].join(' '), name_array[split_position+1..-1].join(' ')]
    end
  end

  def self.is_gp?(row)
    if row.size > 6
      # Is a more modern page, use first attribute to
      row[0][0..1] == 'GP'
    else
      row[5].first == 'G'
    end
  end
end