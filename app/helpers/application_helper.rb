module ApplicationHelper
  def page_title(title)
    content_for(:title) { title }
  end

  def flash_class(key)
    key.to_s == "alert" ? "flash-alert" : "flash-notice"
  end
end
