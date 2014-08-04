describe IbanCalculator::InvalidData do
  subject { described_class.new('', 128) }

  describe '#resolve_error_code' do
    it 'handles single errors' do
      expect(subject.resolve_error_code(128)).to eq(account_number: [:checksum_failed])
    end

    it 'can combine multiple errors' do
      expect(subject.resolve_error_code(128 + 256)).to eq(account_number: [:checksum_failed], bank_code: [:not_found])
    end

    it 'can combine multiple errors of same attribute' do
      expect(subject.resolve_error_code(128 + 512)).to eq(account_number: [:checksum_failed, :invalid_length])
    end

    it 'can combine multiple errors of same attribute' do
      expect(subject.resolve_error_code(512)).to eq(account_number: [:invalid_length])
    end
  end

  describe '#error_codes' do
    it 'ignores zeros' do
      expect(subject.error_codes(0)).to eq([])
    end

    it 'detects unique values' do
      expect(subject.error_codes(1)).to eq([1])
    end

    it 'detects compounded values' do
      expect(subject.error_codes(3)).to eq([1, 2])
    end

    it 'detects 512' do
      expect(subject.error_codes(512)).to eq([512])
    end

    it 'detects compounded values up to 8192' do
      expect(subject.error_codes(8193)).to eq([1, 8192])
    end
  end

  describe '#known_error_codes' do
    it 'detects 512' do
      expect(subject.known_error_codes(512)).to eq([512])
    end
  end

  describe '#error' do
    it 'sets error on object' do
      expect(described_class.new('test', 512).errors).to eq(account_number: [:invalid_length])
    end
  end
end
