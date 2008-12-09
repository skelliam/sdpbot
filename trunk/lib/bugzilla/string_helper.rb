class String
  def snake_case
    self.split(/(?=[A-Z])/).join('_').downcase 
  end
end