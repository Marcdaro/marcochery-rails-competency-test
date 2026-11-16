# Demo data for local development. Run with: bin/rails db:seed
# Safe to run more than once: it won't create duplicate users or articles.
# These are throwaway local-only accounts.

password = "password123"

editor = User.find_or_create_by!(email: "editor@example.com") do |u|
  u.password = password
  u.role = :editor
end

User.find_or_create_by!(email: "reader@example.com") do |u|
  u.password = password
end

User.find_or_create_by!(email: "admin@example.com") do |u|
  u.password = password
  u.role = :admin
end

# Articles live in text files under db/seeds/articles/<Category>/:
#
#   db/seeds/articles/Technology/01-my-article.txt
#
#   ---
#   title: "My Article Title"
#   trending: 1        (optional: 1, 2 or 3 puts it in that Trending Now slot)
#   ---
#
#   First paragraph.
#
#   Second paragraph (leave a blank line between paragraphs).
#
# - The folder name is the article's category.
# - Files are loaded in name order, so the 01-, 02- prefixes set the order.
#   The last file in a folder is created last and shows first on the site.
# - Editing a file and running db:seed again updates that article
#   (articles are matched by title).
ARTICLES_DIR = Rails.root.join("db/seeds/articles")
FRONT_MATTER = /\A---\s*\n(.*?)\n---\s*\n/m

Dir.glob(ARTICLES_DIR.join("*/*.txt")).sort.each do |path|
  text = File.read(path)
  match = text.match(FRONT_MATTER) or raise "#{path} is missing its --- title --- header"

  header = YAML.safe_load(match[1])
  title = header.fetch("title")
  category = File.basename(File.dirname(path))
  content = match.post_match.strip

  article = Article.find_or_initialize_by(title: title)
  article.user ||= editor
  article.update!(category: category, content: content, trending_position: header["trending"])
end

puts "Seeded #{User.count} users and #{Article.count} articles."
