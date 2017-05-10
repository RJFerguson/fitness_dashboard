class User < ApplicationRecord
  has_secure_password

  has_many :user_sleeps
  has_many :sleeps, through: :user_sleeps

  has_many :user_exercises
  has_many :exercises, through: :user_exercises

  has_many :user_foods
  has_many :foods, through: :user_foods

  has_many :user_weights

  def total_calories_eaten
    foods_eaten_today = UserFood.where(user_id: self.id, date_eat: DateTime.parse(Time.now.to_s).strftime("%Y-%m-%d"))
    foods_eaten_today.sum(&:calories)
  end

  def total_calories_burned
    exercises = UserExercise.where(user_id: self.id, date_completed: DateTime.parse(Time.now.to_s).strftime("%Y-%m-%d"))
    sleeping = UserSleep.where(user_id: self.id, sleep_date: DateTime.parse(Time.now.to_s).strftime("%Y-%m-%d"))

    exercises.sum(&:calories) + sleeping.sum(&:calories)
  end

  def net_calories
    self.total_calories - (self.total_calories_burned)
  end

  def current_weight
    curr_weight = self.user_weights.last.weight + (self.net_calories/3500)
  end

  private

  #run at end of day
  
  def end_day_weight
    self.user_weights.last.weight + (self.net_calories/3500)
  end

  def end_day_calories_burned
    self.total_calories_burned
  end

  def end_day_calories_eaten
    self.total_calories_eaten
  end

  def day_end_totals
    User_Weight.create(user_id: self.id,
    day: DateTime.parse(Time.now.to_s).strftime("%Y-%m-%d"),
    daily_weight: self.end_day_weight,
    daily_calories_burned: self.end_day_calories_burned,
    daily_sleep_duration: UserSleep.where(user_id: self.id, sleep_date: DateTime.parse(Time.now.to_s).strftime("%Y-%m-%d")).sum(&:duration))
  end

end