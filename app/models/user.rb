class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :articles, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_articles, through: :likes, source: :article

  validates :username,
            uniqueness: { case_sensitive: false },
            allow_blank: true,
            format: { with: /\A[a-zA-Z0-9_]{3,20}\z/, message: "は半角英数字と_の3〜20文字で入力してください" }

  before_validation :assign_default_username, on: :create

  # @ハンドル名（未設定ならメールのローカル部から自動生成済み）
  def handle
    username.presence || "user#{id}"
  end

  # 表示名（未設定なら@ハンドルを使う）
  def name
    display_name.presence || handle
  end

  def to_param
    handle
  end

  def liked?(article)
    likes.exists?(article_id: article.id)
  end

  private

  # サインアップ時にユーザー名が空ならメールアドレスから自動生成する
  def assign_default_username
    return if username.present?

    base = email.to_s.split("@").first.to_s.gsub(/[^a-zA-Z0-9_]/, "").downcase
    base = "user" if base.length < 3
    base = base[0, 20]

    candidate = base
    suffix = 0
    while User.exists?(username: candidate)
      suffix += 1
      candidate = "#{base[0, 17]}#{suffix}"
    end
    self.username = candidate
  end
end
