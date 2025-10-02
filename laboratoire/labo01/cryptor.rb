class Cryptor
    # Printable ASCII characters range is 32 to 126
    MIN = 32
    MAX = 126

    CHARACTERS = (MIN..MAX).to_a

    attr_reader :offset

    def initialize(offset)
        raise TypeError.new("Offset must be an Integer") unless offset.is_a? Integer
        raise ArgumentError.new("Offset must be >= 0") unless offset >= 0

        @offset = offset % CHARACTERS.count
        @shifted = CHARACTERS.rotate(@offset) 
    end

    def encode(code)
        raise TypeError.new("Code must be an Integer") unless code.is_a? Integer

        return @shifted[(code - MIN) % CHARACTERS.count]
    end

    def decode(code)
        raise TypeError.new("Code must be an Integer") unless code.is_a? Integer

        return CHARACTERS[(code - MIN - @offset) % CHARACTERS.count]
    end

end

if __FILE__ == $0

    #
    ## Example
    #

    crypto = Cryptor.new(93)

    original = 65
    puts("Original = #{original}")

    encoded = crypto.encode(original)
    puts("Encoded = #{encoded}")
    puts("Decoded = #{crypto.decode(encoded)}")

    # Tests
    [0, 1, 8, 64, 128, 256].each do |key|
        cryptoTest = Cryptor.new(key)

        sample = Cryptor::CHARACTERS.sample(42)

        encoded = sample.map { |value| cryptoTest.encode(value) }
        decoded = encoded.map { |value| cryptoTest.decode(value) }

        if sample != decoded 
            puts("ERROR: key=#{key}")
            p(sample)
            p(encoded)
            p(decoded)
        end
    end

end
