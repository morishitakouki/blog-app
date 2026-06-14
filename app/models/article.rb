class Article < ApplicationRecord
  belongs_to :user

  has_many :likes, dependent: :destroy
  has_many :likers, through: :likes, source: :user

  validates :title, presence: true
  validates :body, presence: true

  scope :newest_first, -> { order(created_at: :desc) }

  def liked_by?(user)
    return false unless user
    likes.exists?(user_id: user.id)
  end
end
