Rails.application.routes.draw do
  devise_for :users
  resources :consultations, only: %i[index show new create] do
    resources :submissions, only: %i[index new create destroy] do
      get "/tag", to: "submissions#tag"
      get "/goto", to: "submissions#goto"
    end
    resources :surveys, only: %i[new create]
    get "/export", to: "consultations#export"
    resources :submissions, only: %i[show edit update], shallow: true
  end

  put "submissions/:id/process", to: "submissions#mark_process", as: :process_submission
  put "submissions/:id/complete", to: "submissions#mark_complete", as: :complete_submission
  put "submissions/:id/reject", to: "submissions#mark_reject", as: :reject_submission
  put "submissions/:id/archive", to: "submissions#mark_archived", as: :archive_submission
  put "submissions/:id/restore", to: "submissions#mark_restored", as: :restore_submission

  resources :taxonomies, only: :show do
    resources :tags, only: %i[create destroy]
  end

  patch "taxonomies/:id/upload", to: "taxonomies#upload", as: :upload_taxonomy

  resources :submission_tags, only: %i[create destroy]

  authenticate :user do
    namespace :admin do
      resources :users
      put  "users/:id/approve", to: "users#approve", as: :approve_user
      put  "users/:id/suspend", to: "users#suspend", as: :suspend_user
      put  "users/:id/reactivate", to: "users#reactivate", as: :reactivate_user
      post "users/search", to: "users#search", as: :search_users

      resources :consultations, only: %i[index edit update]
      put  "consultations/:id/archive", to: "consultations#archive", as: :archive_consultation
      put  "consultations/:id/restore", to: "consultations#restore", as: :restore_consultation

      resources :consultation_users, only: %i[create destroy]
    end
  end

  ##
  # Workaround a "bug" in lighthouse CLI
  #
  # Lighthouse CLI (versions 5.4 - 5.6 tested) issues a `GET /asset-manifest.json`
  # request during its run - the URL seems to be hard-coded. This file does not
  # exist so, during tests, your test will fail because rails will die with a 404.
  #
  # Lighthouse run from Chrome Dev-tools does not have the same behaviour.
  #
  # This hack works around this. This behaviour might be fixed by the time you
  # read this. You can check by commenting out this block and running the
  # accessibility and performance tests. You are encouraged to remove this hack
  # as soon as it is no longer needed.
  #
  if defined?(Webpacker) && Rails.env.test?
    # manifest paths depend on your webpacker config so we inspect it
    manifest_path = Webpacker::Configuration
                    .new(root_path: Rails.root, config_path: Rails.root.join("config/webpacker.yml"), env: Rails.env)
                    .public_manifest_path
                    .relative_path_from(Rails.root.join("public"))
                    .to_s
    get "/asset-manifest.json", to: redirect(manifest_path)
  end

  ##
  # If you want the Sidekiq web console in production environments you need to
  # put it behind some authentication first.
  #
  if Rails.env.development?
    require "sidekiq/web"
    mount Sidekiq::Web => "/sidekiq" # Sidekiq monitoring console
  end

  root "consultations#index"

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
