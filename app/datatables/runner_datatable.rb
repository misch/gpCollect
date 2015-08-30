class RunnerDatatable < AjaxDatatablesRails::Base
  include ActiveRecord::Sanitization::ClassMethods
  def_delegators :@view, :runner_path, :remember_runner_path, :link_to, :fa_icon, :content_tag

  def sortable_columns
    # Declare strings in this format: ModelName.column_name
    @sortable_columns ||= ['Runner.first_name', 'Runner.last_name', 'Runner.club_or_hometown', 'Runner.sex',
                           'Runner.nationality', 'Runner.runs_count']
  end

  def searchable_columns
    # Declare strings in this format: ModelName.column_name
    @searchable_columns ||= ['Runner.first_name', 'Runner.last_name', 'Runner.club_or_hometown']
  end

  def as_json(options = {})
    filtered_data = data
    total_count = Rails.cache.fetch('raw_count') { get_raw_records.count(:all) }
    {
        :draw => params[:draw].to_i,
        :recordsTotal =>  total_count,
        :recordsFiltered => records.first['filtered_count'] || total_count,
        :data => filtered_data
    }
  end

  private

  def data
    records.map do |record|
      [
          record.first_name,
          record.last_name,
          record.club_or_hometown,
          record.sex,
          record.nationality,
          record.runs_count,
          record.fastest_run.decorate.duration_formatted,
          link_to(fa_icon('eye lg'), runner_path(record)) + ' ' +
              link_to(content_tag(:i, '', class: 'fa fa-lg'), '#', data: {remember_runner: record.id})
      ]
    end
  end

  def get_raw_records
    Runner.all.includes(:runs, :categories)
  end

  # Overrides the filter method defined from the gem. When searching, we ignore all accents, so a search for 'théo'
  # will also return 'theo' (and vice-versa).
  # Every word (separated by space) will be searched individually in all searchable columns. Only rows that satisfy all
  # words (in some column) are returned.
  def filter_records(records)
    if params[:search].present? and not params[:search][:value].blank?
      search_for = params[:search][:value].split(' ')
      where_clause = search_for.map do |unescaped_term|
        term = "%#{sanitize_sql_like(unescaped_term)}%"
        searchable_columns.map do |model_and_column|
          model, column = model_and_column.split('.')
          model = model.constantize
          unaccented_column = ::Arel::Nodes::NamedFunction.new('f_unaccent', [model.arel_table[column.to_sym]])
          unaccented_column.matches(::Arel::Nodes::NamedFunction.new('f_unaccent', [::Arel::Nodes::build_quoted(term)]))
        end.reduce(:or)
      end.reduce(:and)
      records.select('*, count(*) OVER() as filtered_count').where(where_clause)
    else
      records
    end
  end
end
