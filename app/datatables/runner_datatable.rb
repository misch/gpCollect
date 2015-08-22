class RunnerDatatable < AjaxDatatablesRails::Base
  include ActiveRecord::Sanitization::ClassMethods
  def_delegators :@view, :runner_path, :link_to

  def sortable_columns
    # Declare strings in this format: ModelName.column_name
    @sortable_columns ||= ['Runner.first_name', 'Runner.last_name', 'Runner.club_or_hometown', 'Runner.sex']
  end

  def searchable_columns
    # Declare strings in this format: ModelName.column_name
    @searchable_columns ||= ['Runner.first_name', 'Runner.last_name', 'Runner.club_or_hometown']
  end

  private

  def data
    records.map do |record|
      [
        record.first_name,
        record.last_name,
        record.club_or_hometown,
        record.sex,
        record.runs.size,
        link_to('Show', runner_path(record))
      ]
    end
  end

  def get_raw_records
    Runner.all.includes(:runs)
  end

  # Overrides the filter method defined from the gem. When searching, we ignore all accents, so a search for 'théo'
  # will also return 'theo' (and vice-versa).
  def filter_records(records)
    if params[:search].present? and not params[:search][:value].blank?
      term = "#{sanitize_sql_like(params[:search][:value])}%"
      where_clause = searchable_columns.map do |model_and_column|
        _, column = model_and_column.split('.')
        "unaccent(#{column}) ILIKE f_unaccent('#{term}')"
      end.join(' or ')
      records.where(where_clause)
    else
      records
    end
  end
  # ==== Insert 'presenter'-like methods below if necessary
end
