def generate_array(number)
  Array.new(number) { [SecureRandom.hex(3), SecureRandom.hex(6)] }
end
