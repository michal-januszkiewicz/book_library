class ReaderSerializer
  class << self
    def one(reader)
      {
        library_card_number: reader.library_card_number,
        name: reader.name,
        email: reader.email
      }
    end

    def collection(readers)
      readers.map { |reader| one(reader) }
    end
  end
end
