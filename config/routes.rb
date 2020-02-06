Rails.application.routes.draw do
  devise_for :users
  resources :consultations, only: %i[index show new create] do
    resources :submissions, only: %i[index new create destroy] do
      get "/tag", to: "submissions#tag"
    end
    get "/export", to: "consultations#export"
    resources :submissions, only: %i[show edit update], shallow: true
  end

  put "submissions/:id/process", to: "submissions#mark_process", as: :process_submission
  put "submissions/:id/complete", to: "submissions#mark_complete", as: :complete_submission
  put "submissions/:id/reject", to: "submissions#mark_reject", as: :reject_submission

  resources :taxonomies, only: :show do
    resources :tags, only: %i[create destroy]
  end

  patch "taxonomies/:id/upload", to: "taxonomies#upload", as: :upload_taxonomy

  resources :submission_tags, only: %i[create destroy]

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
  if defined?(Sidekiq::Web) && Rails.env.development?
    mount Sidekiq::Web => "/sidekiq" # Sidekiq monitoring console
    require "sidekiq/web"
  end

  root "consultations#index"

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
