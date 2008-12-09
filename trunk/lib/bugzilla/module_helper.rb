class Module
  # Return the name without the whole path hierarchy
  def simple_name
    name.split('::').last
  end
end
