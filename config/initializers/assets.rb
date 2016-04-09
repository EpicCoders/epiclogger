# Be sure to restart your server when you modify this file.
Rails.application.configure do
  # Version of your assets, change this if you want to expire all your assets.
  config.assets.version = '1.1'

  # Add additional assets to the asset load path
  # config.assets.paths << Emoji.images_path
  # config.assets.paths << Rails.root.join("app", "assets", "pages")
  # Precompile additional assets.
  # application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
  config.assets.precompile += %w( fontmizz/*.* )

  config.assets.precompile << lambda do |filename, path|
    path =~ /vendor\/assets/ && %w(.png .gif .jpg .eot .svg .ttf .woff).include?(File.extname(filename))
  end
end
