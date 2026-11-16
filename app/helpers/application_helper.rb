module ApplicationHelper
  # A link in the section nav bar. The current section gets a red underline.
  def section_nav_link(label, path, active:)
    classes = "inline-block border-b-2 py-3 transition-colors "
    classes += active ? "border-red-700 text-red-700" : "border-transparent text-slate-700 hover:border-slate-400 hover:text-slate-900"

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
end
