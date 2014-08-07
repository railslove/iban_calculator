RSpec.describe IbanCalculator::BicCandidate do

  subject { described_class.new(single_candidate[:item]) }

  describe '.build_list' do
    it 'returns an array if one item is added' do
      expect(described_class.build_list(single_candidate).size).to eq(1)
    end

    it 'returns an array of multiple items' do
      expect(described_class.build_list(multiple_candidates).size).to eq(2)
    end

    it 'returns BicCandiate objects' do
      expect(described_class.build_list(single_candidate).first).to be_kind_of(described_class)
    end
  end

  describe '.new' do
    it 'assigns its bic' do
      expect(subject.bic).to eq('BOFIIE2D')
    end

    it 'assigns its city' do
      expect(subject.city).to eq('city')
    end

    it 'assigns its zip' do
      expect(subject.zip).to eq('zip')
    end

    it 'assigns its www_count' do
      expect(subject.www_count).to eq(0)
    end

    it 'assigns its sample_url' do
      expect(subject.sample_url).to eq('sample_url')
    end
  end

  describe '#source' do
    it 'returns directory if document has no www count' do
      subject.www_count = 0
      expect(subject.source).to eq(:directory)
    end

    it 'returns www if document has www count' do
      subject.www_count = 1
      expect(subject.source).to eq(:www)
    end
  end

  describe '#as_json' do
    it 'takes a hash as argument to be compatible with rails' do
      expect{ subject.as_json({}) }.to_not raise_error
    end

    it 'returns all attributes' do
      expect(subject.as_json).to eq({
        bic: 'BOFIIE2D',
        zip: 'zip',
        city: 'city',
        sample_url: 'sample_url',
        www_count: 0
      })
    end
  end

  def single_candidate
    {
      :item => {
        :bic => 'BOFIIE2D',
        :zip => 'zip',
        :city => 'city',
        :wwwcount => '0',
        :sampleurl => 'sample_url',
        :'@xsi:type' => 'tns:BICStruct'
      },
      :'@xsi:type' => 'SOAP-ENC:Array',
      :'@soap_enc:array_type' => 'tns:BICStruct[1]'
    }
  end

  def multiple_candidates
    {
      :item => [{
        :bic => 'BOFIIE2D',
        :zip => 'zip',
        :city => 'city',
        :wwwcount => '0',
        :sampleurl => 'sample_url',
        :'@xsi:type' => 'tns:BICStruct'
      }, {
        :bic => 'BOFIIE2D',
        :zip => 'zip',
        :city => 'city',
        :wwwcount => '0',
        :sampleurl => 'sample_url',
        :'@xsi:type' => 'tns:BICStruct'
      }],
      :'@xsi:type' => 'SOAP-ENC:Array',
      :'@soap_enc:array_type' => 'tns:BICStruct[1]'
    }
  end
end
