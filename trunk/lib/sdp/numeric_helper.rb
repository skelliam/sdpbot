class Float
  # USAGE : 123123123.123131.decimal # => 123123123.12
  # OR 123123123.123131.decimal 4 # => 123123123.1231
  # Defaults to a scale of 2
  def decimal(prec=2)
    number = self.to_s.split(".")[0]
    scale = self.to_s.split(".")[1][0..(prec-1)]
    "#{number}.#{scale}".to_f
  end
end