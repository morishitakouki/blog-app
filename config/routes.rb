Rails.application.routes.draw do
  resources :articles do
    resource :like, only: %i[ create destroy ], module: :articles
  end

  devise_for :users

  # マイページ / プロフィール設定
  get   "settings", to: "settings#edit",   as: :settings
  patch "settings", to: "settings#update"
  get   "mypage",   to: "users#mypage",    as: :mypage

  # 他ユーザーも含むプロフィール（@ハンドル）。一般ルートの後に置く
  get "@:username", to: "users#show", as: :profile, constraints: { username: /[a-zA-Z0-9_]+/ }

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # ホーム（みんなのタイムライン）
  root "articles#index"
end
