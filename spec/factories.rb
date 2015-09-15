FactoryGirl.define do
  factory :category do
    sex 'M'
    age_min 30
  end

  factory :run_day do
    date { 1.year.ago }
  end

  factory :run do
    duration { Faker::Number.between(4618000, 5366200) }
    category
    run_day
    runner
  end

  factory :runner do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    club_or_hometown { Faker::Address.city }
    birth_date { Faker::Date.between(50.years.ago, 20.years.ago) }
    # user_with_posts will create post data after the user has been created
    factory :runner_with_runs do
      # posts_count is declared as a transient attribute and available in
      # attributes on the factory, as well as the callback via the evaluator
      transient do
        runs_count 3
      end

      # the after(:create) yields two values; the user instance itself and the
      # evaluator, which stores all values from the factory, including transient
      # attributes; `create_list`'s second argument is the number of records
      # to create and we make sure the user is associated properly to the post
      after(:create) do |runner, evaluator|
        create_list(:run, evaluator.runs_count, runner: runner)
      end
    end
  end

  factory :admin do
    email 'test@tester.com'
    password 'test1234'
  end
end