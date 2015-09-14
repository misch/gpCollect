class Category < ActiveRecord::Base
  has_many :runs
  has_many :run_day_category_aggregates

  def name
    sex + if age_max
            'U' + age_max.to_s
          else
            age_min.to_s
          end
  end

end
