# encoding: UTF-8
module MergeRunnersHelpers
  def self.merge_runners(runner, to_be_merged_runner)
    runner.runs += to_be_merged_runner.runs
    runner.save!
    to_be_merged_runner.destroy!
  end

  def self.find_runners_only_differing_in(attr, additional_attributes_select=[], additional_attributes_group=[])
    identifying_runner_attributes_select = [:first_name, :last_name, :nationality, :club_or_hometown, :sex, '(current_date - birth_date)/365/10 AS age']
    identifying_runner_attributes_group = [:first_name, :last_name, :nationality, :club_or_hometown, :sex, 'age']
    r = Runner.select(identifying_runner_attributes_select - [attr] + additional_attributes_select + ['array_agg(id) AS ids'])
            .group(identifying_runner_attributes_group - [attr] + additional_attributes_group).having('count(*) > 1')
    # Each merge candidate consists of multiple runners, retrieve these runners from database here.
    merge_candidates = r.map { |i| Runner.includes(:run_days).find(i['ids']) }
    # Only select the runners as merge candidates that differ in the queried attribute.
    merge_candidates.select! {|i| i.first[attr] != i.second[attr]}
    # Only select runners for merging that have no overlapping run days.
    merge_candidates.select {|i| i.all? {|fixed_runner| (i - [fixed_runner]).all? { |other_runner| (fixed_runner.run_days & other_runner.run_days).empty? }}}
  end

  def self.count_accents(string)
    # [[:alpha:]] will match accented characters, \w will not.
    (string.scan(/[[:alpha:]]/) - string.scan(/\w/)).size
  end

  MALE_FIRST_NAMES = %w(Jannick Candido Loïc Patrick Raffael)
  FEMALE_FIRST_NAMES = %w(Denise Tabea)
  POSSIBLY_WRONGLY_ACCENTED_ATTRIBUTES = [:first_name, :last_name]
  POSSIBLY_WRONGLY_CASED_ATTRIBUTES = [:club_or_hometown]
  POSSIBLY_WRONGLY_SPACED_ATTRIBUTES = [:first_name, :last_name, :club_or_hometown]

  def self.merge_duplicates
    merged_runners = 0
    # Handle wrong sex, try to find correct sex using name list.
    find_runners_only_differing_in(:sex).each do |entries|
      if entries.size != 2
        raise "More than two possibilities, dont know what to do for #{entries}"
      end
      # These are differentiated by age, go to next.
      next if (entries.first.birth_date - entries.second.birth_date).abs > 10 * 365
      first_name = entries.first.first_name
      correct_entry, wrong_entry = if MALE_FIRST_NAMES.include?(first_name)
                                     # M comes first, so ordering by sex will return it first.
                                     entries.sort_by(&:sex)
                                   elsif FEMALE_FIRST_NAMES.include?(first_name)
                                     entries.sort_by(&:sex).reverse
                                   else
                                     raise "Could not match gender to #{entries}, please extend names list."
                                   end
      merge_runners(correct_entry, wrong_entry)
      merged_runners += 1
    end
    puts "Merged #{merged_runners} entries based on sex."

    POSSIBLY_WRONGLY_ACCENTED_ATTRIBUTES.each do |attr|
      merged_runners = 0
      find_runners_only_differing_in(attr, ["f_unaccent(#{attr}) as unaccented"], ['unaccented']).each_with_index do |entries|

        # The correct entry is the one with more accents (probably?).
        correct_entry = entries.max_by { |entry| count_accents(entry[attr]) }
        wrong_entries = entries.reject { |entry| entry == correct_entry }
        wrong_entries.each { |entry| merge_runners(correct_entry, entry) }
        merged_runners += 1
      end
      puts "Merged #{merged_runners} entries based on accents of #{attr}."
    end


    # Try to fix case sensitive duplicates in club_or_hometown, e. g. in
    # Veronique	Plessis	Arc Et Senans
    # Veronique	Plessis	Arc et Senans
    POSSIBLY_WRONGLY_CASED_ATTRIBUTES.each do |attr|
      merged_runners = 0
      find_runners_only_differing_in(attr, ["f_unaccent(lower(#{attr})) as low"], ['low']).each do |entries|
        if entries.size != 2
          raise "More than two possibilities, dont know what to do for #{entries}"
        end
        # We take the one with more lowercase characters as he correct one. E. g. for
        # Reichenbach I. K.
        # Reichenbach i. K.
        # the version at the bottom is preferred.
        correct_entry, wrong_entry = if entries.first[attr].scan(/[[:lower:]]/).size > entries.second[attr].scan(/[[:lower:]]/).size
                                       [entries.first, entries.second]
                                     else
                                       [entries.second, entries.first]
                                     end
        merge_runners(correct_entry, wrong_entry)
        merged_runners += 1
      end
      puts "Merged #{merged_runners} entries based on case of #{attr}."
    end

    POSSIBLY_WRONGLY_SPACED_ATTRIBUTES.each do |attr|
      merged_runners = 0
      find_runners_only_differing_in(attr, ["replace(#{attr}, '-', ' ') as spaced"], ['spaced']).each do |entries|
        if entries.size != 2
          raise "More than two possibilities, dont know what to do for #{entries}"
        end
        # We take the one with more spaces as he correct one.
        correct_entry, wrong_entry = if entries.first[attr].scan(/ /).size > entries.second[attr].scan(/ /).size
                                       [entries.first, entries.second]
                                     else
                                       [entries.second, entries.first]
                                     end
        merge_runners(correct_entry, wrong_entry)
        merged_runners += 1
      end
      puts "Merged #{merged_runners} entries based on spaces of #{attr}."
    end

    # TODO: Try to fix club_or_hometown duplicates, e. g.
    # Achim	Seifermann	LAUFWELT de Lauftreff
    # Achim	Seifermann	Laufwelt.de
    #only_differing_club_or_hometown = Runner.select(identifying_runner_attributes - [:club_or_hometown])
    #                                      .group(identifying_runner_attributes - [:club_or_hometown]).having('count(*) > 1')
  end
end
