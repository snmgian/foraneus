class Foraneus

  Error = Struct.new(:key, :message) do
    def to_s
      "#{key} - #{message}"
    end
  end

end
