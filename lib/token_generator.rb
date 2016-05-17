module TokenGenerator
  # Generate token for column using SecureRandom.urlsafe_base64
  def generate_token(column, size = 16)
    begin
      self[column] = SecureRandom.urlsafe_base64(size)
    end while self.class.exists?(column => self[column])
    self[column]
  end
end