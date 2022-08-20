# frozen_string_literal: true

class Blog < ApplicationRecord
  belongs_to :user
  has_many :likings, dependent: :destroy
  has_many :liking_users, class_name: 'User', source: :user, through: :likings

  validates :title, :content, presence: true

  scope :published, -> { where('secret = FALSE') }

  scope :search, lambda { |term|
    where('title LIKE :term OR content LIKE :term', term: "%#{sanitize_sql(term.to_s)}%")
  }

  scope :default_order, -> { order(id: :desc) }

  scope :accessible_to, lambda { |current_user|
    if current_user.nil?
      published
    else
      where('user_id = :blog_author', blog_author: current_user.id).or(published)
    end
  }

  def owned_by?(target_user)
    user == target_user
  end
end
