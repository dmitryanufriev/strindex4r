# frozen_string_literal: true

# String class extensions
class String
  # Returns suffix for given prefix.
  # For example: for word 'hello' and prefix 'hel' suffix will be 'lo'.
  def suffix(prefix)
    delete_prefix prefix if start_with? prefix
  end

  # Returns true if string is empty or contains spaces only.
  def blank?
    strip.empty?
  end
end
