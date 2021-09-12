class Project < ApplicationRecord
  has_many :tasks, dependent: :destroy
  belongs_to :user

  def status
    if tasks.empty?
      'pending'
    end
    
    if tasks.all? { |task| task.complete? }
      'complete'
    elsif tasks.any? { |task| task.in_progress? || task.complete? }
      'in-progress'
    else
      'pending'
    end
  end
end
