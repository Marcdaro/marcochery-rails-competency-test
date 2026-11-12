# Demo data for local development. Run with: bin/rails db:seed
# Safe to run more than once (find_or_create_by! won't duplicate records).
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

{
  "Technology" => [ "New Chip Doubles Battery Life", "Open Source Hits a Milestone", "Rails 8 Ships", "Robots Learn to Fold Laundry" ],
  "Sports" => [ "Underdogs Win the Cup", "Marathon Record Falls", "Rookie Signs Record Deal" ],
  "World" => [ "Leaders Meet for Climate Talks", "New Rail Line Opens" ]
}.each do |category, titles|
  titles.each do |title|
    Article.find_or_create_by!(title: title) do |a|
      a.category = category
      a.content = "#{title}. This is sample content for the #{category} section of the news app. " * 4
      a.user = editor
    end
  end
end

puts "Seeded #{User.count} users and #{Article.count} articles."
