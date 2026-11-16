class AddTrendingPositionToArticles < ActiveRecord::Migration[8.1]
  # 1, 2 or 3 puts an article in that slot of the homepage's Trending Now section.
  # Empty for every other article.
  def change
    add_column :articles, :trending_position, :integer
    add_index :articles, :trending_position
  end
end
