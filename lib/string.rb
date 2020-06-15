# frozen_string_literal: true

class String
  def suffix(prefix)
    delete_prefix prefix if start_with? prefix
  end

  def blank?
    strip.empty?
  end
end
