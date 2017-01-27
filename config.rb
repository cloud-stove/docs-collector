###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false
page 'CNAME', layout: false

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

config[:docs_repo_url] = "https://$GITHUB_TOKEN:x-oauth-basic@github.com/cloud-stove/docs-collector.git"
config[:backend_repo_url] = "git@github.com:inz/cloud-stove.git"
config[:frontend_repo_url] = "git@github.com:inz/cloud-stove-ui.git"

if ENV['CI'] == 'true'
  config[:backend_repo_url] = "https://$GITHUB_TOKEN:x-oauth-basic@github.com/inz/cloud-stove.git"
  config[:frontend_repo_url] = "https://$GITHUB_TOKEN:x-oauth-basic@github.com/inz/cloud-stove-ui.git"
end

# Build-specific configuration
configure :build do
  # Minify CSS on build
  # activate :minify_css

  # Minify Javascript on build
  # activate :minify_javascript

  def fetch_code_command(directory_name, repo_url)
    if ENV['CI'] == 'true'
      "mkdir -p #{directory_name} && cd #{directory_name} && git init && git pull --depth=1 #{repo_url}"
    else
      "git clone --depth 1 #{repo_url} #{directory_name} && cd #{directory_name}"
    end
  end

  # Pull in backend docs
  activate :external_pipeline,
    name: :backend_docs,
    command: "mkdir -p .tmp && cd .tmp && rm -rf backend && #{fetch_code_command(:backend, config[:backend_repo_url])} && yard --output-dir doc/backend",
    source: ".tmp/backend/doc",
    latency: 2
  
  # Pull in front end docs
  activate :external_pipeline,
    name: :frontend_docs,
    command: "mkdir -p .tmp && cd .tmp && rm -rf frontend && #{fetch_code_command(:frontend, config[:frontend_repo_url])} && npm install --ignore-scripts && npm run typedoc -- --out doc/frontend/",
    source: ".tmp/frontend/doc",
    latency: 2
end

activate :deploy do |deploy|
  deploy.deploy_method = :git
  if ENV['CI'] == 'true'
    deploy.remote = config[:docs_repo_url]
  end
end