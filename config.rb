###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

# With alternative layout
# page "/path/to/file.html", layout: :otherlayout

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", locals: {
#  which_fake_page: "Rendering a fake page with a local variable" }

# General configuration

# Reload the browser automatically whenever files change
configure :development do
  activate :livereload
end

###
# Helpers
###

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end

# Build-specific configuration
configure :build do
  # Minify CSS on build
  # activate :minify_css

  # Minify Javascript on build
  # activate :minify_javascript

  config[:backend_repo_url] = "git@github.com:inz/cloud-stove.git"
  config[:frontend_repo_url] = "git@github.com:inz/cloud-stove-ui.git"

  # Pull in backend docs
  activate :external_pipeline,
    name: :backend_docs,
    command: "mkdir -p .tmp && cd .tmp && rm -rf backend && git clone --depth 1 #{config[:backend_repo_url]} backend && cd backend && yard --output-dir doc/backend",
    source: ".tmp/backend/doc",
    latency: 2
  
  # Pull in front end docs
  activate :external_pipeline,
    name: :frontend_docs,
    command: "mkdir -p .tmp && cd .tmp && rm -rf frontend && git clone --depth 1 #{config[:frontend_repo_url]} frontend && cd frontend && npm install && npm install -g compodoc && compodoc --tsconfig tsconfig.json --name 'The Cloud Stove Front End' --output doc/frontend",
    source: ".tmp/frontend/doc",
    latency: 2
end

activate :deploy do |deploy|
  deploy.deploy_method = :git
end