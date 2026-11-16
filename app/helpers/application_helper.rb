module ApplicationHelper
  # Placeholder "photo" colours per category until articles have real images
  STORY_GRADIENTS = [
    "from-red-700 via-rose-900 to-neutral-950",
    "from-sky-600 via-indigo-900 to-neutral-950",
    "from-amber-500 via-orange-800 to-neutral-950",
    "from-emerald-600 via-teal-900 to-neutral-950",
    "from-fuchsia-600 via-purple-900 to-neutral-950"
  ].freeze

  # A link in the section nav bar. The current section is red with a red underline.
  def section_nav_link(label, path, active:)
    classes = "inline-block border-b-2 py-3 transition-colors "
    classes += active ? "border-red-600 text-red-500" : "border-transparent text-white hover:border-neutral-500 hover:text-neutral-200"

    link_to label, path, class: classes, aria: { current: (active ? "page" : nil) }
  end

  # Which nav section the current page belongs to: :home, :all, or a category name
  def current_section
    return unless controller_name == "articles"

    case action_name
    when "home" then :home
    when "index" then @category || :all
    when "show", "edit" then @article&.category
    end
  end

  # "4 min read", based on about 200 words a minute
  def read_time(article)
    minutes = (article.content.to_s.split.size / 200.0).ceil.clamp(1..)
    "#{minutes} min read"
  end

  # Each category gets its own gradient, in nav order (unknown categories fall back to the first)
  def story_gradient(category)
    index = nav_categories.index(category) || 0
    STORY_GRADIENTS[index % STORY_GRADIENTS.size]
  end
end
