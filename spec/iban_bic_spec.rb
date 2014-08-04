describe IbanCalculator::IbanBic do
  subject { described_class.new('user', 'pass', 'url', Logger.new(STDOUT) ) }

  before { allow(subject.logger).to receive(:info) }

  describe '#italian_account_number' do
    it 'returns an empty hash if not all fields are provided' do
      expect(subject.italian_account_number).to eq({})
    end

    it 'returns hash with correct account number if valid data is provided' do
      expect(subject.italian_account_number(
        'country' => 'IT',
        'cab' => '03280',
        'abi' => '03002',
        'cin' => 'D',
        'account' => '400162854',
      )).to eq('account' => 'D0300203280000400162854')
    end
  end

  describe '#default_payload' do
    it 'includes account data' do
      expect(subject.default_payload).to match hash_including(user: 'user', password: 'pass')
    end
  end

  describe '#process_bic_candidates' do
    context 'known single BIC payload' do
      let(:payload) { valid_payload[:bic_candidates] }

      it 'returns an array' do
        expect(subject.process_bic_candidates(payload)).to be_kind_of(Array)
      end

      it 'returns its bank\'s bic' do
        expect(subject.process_bic_candidates(payload).first).to match hash_including(bic: 'BYLADEM1001')
      end

      it 'returns its bank\'s zip' do
        expect(subject.process_bic_candidates(payload).first).to match hash_including(zip: '10117')
      end

      it 'returns its bank\'s city' do
        expect(subject.process_bic_candidates(payload).first).to match hash_including(city: 'Berlin')
      end
    end

    context 'unknown payload' do
      let(:payload) { { :items => [], :"@xsi:type" => 'SOAP-ENC:Array' } }

      it 'logs the payload' do
        subject.process_bic_candidates(payload) rescue
        expect(subject.logger).to have_received(:info)
      end

      it 'raises an exception' do
        expect { subject.process_bic_candidates(payload) }.to raise_exception(ArgumentError)
      end
    end
  end

  describe '#formatted_result' do
    before { allow(subject).to receive(:process_bic_candidates).and_return(['data']) }

    it 'returns a valid ruby date for last update date' do
      expect(subject.formatted_result(valid_payload)[:updated_at]).to be_kind_of(Date)
    end

    it 'transforms the list of bic candidates' do
      subject.formatted_result(valid_payload)
      expect(subject).to have_received(:process_bic_candidates)
    end

    it 'includes iban' do
      expect(subject.formatted_result(valid_payload).keys).to include(:iban)
    end
  end

  describe '#iban_payload' do
    context 'italian data is provided' do
      before { allow(subject).to receive(:italian_account_number).and_return({ 'account' => 'italy-123' }) }

      it 'normalizes italian account data' do
        subject.iban_payload({})
        expect(subject).to have_received(:italian_account_number)
      end

      it 'merges italian data' do
        expect(subject.iban_payload({ 'country' => 'IT' })).to match(hash_including(account: 'italy-123'))
      end

      it 'strips italian data' do
        expect(subject.iban_payload({ 'cin' => '123' }).keys).to_not include('cin')
      end
    end

    it 'adds default payload' do
      expect(subject.iban_payload({}).keys).to include(:user, :password, :legacy_mode)
    end

    it 'overrides default data' do
      expect(subject.iban_payload({ bank_code: '123' })).to match hash_including(bank_code: '123')
    end

    it 'replaces account_number with account' do
      expect(subject.iban_payload({ account_number: '123' })).to match hash_including(account: '123')
    end
  end

  describe '#calculate_iban' do
    before { allow(subject.client).to receive(:call).and_return(response) }

    context 'valid response' do
      let(:response) { double(body: { calculate_iban_response: { return: valid_payload } }) }

      it 'returns a formatted response' do
        allow(subject).to receive(:formatted_result)
        subject.calculate_iban({})
        expect(subject).to have_received(:formatted_result)
      end

      it 'calls the client with the generated payload' do
        subject.calculate_iban({})
        expect(subject.client).to have_received(:call).with(:calculate_iban, message: anything)
      end
    end

    context 'probably valid response' do
      let(:response) { double(body: { calculate_iban_response: { return: valid_payload.merge(return_code: '32') } }) }

      it 'logs a message' do
        subject.calculate_iban({}) rescue IbanCalculator::InvalidData
        expect(subject.logger).to have_received(:info).with(/needs manual check/)
      end

      it 'returns a formatted response' do
        allow(subject).to receive(:formatted_result)
        subject.calculate_iban({})
        expect(subject).to have_received(:formatted_result)
      end
    end

    context 'invalid response' do
      let(:response) { double(body: { calculate_iban_response: { return: valid_payload.merge(return_code: '128') } }) }

      it 'logs a message' do
        subject.calculate_iban({}) rescue IbanCalculator::InvalidData
        expect(subject.logger).to have_received(:info).with(/iban check invalid/)
      end

      it 'fails with invalid data exception' do
        expect{ subject.calculate_iban({}) }.to raise_exception(IbanCalculator::InvalidData)
      end
    end

    context 'server error response' do
      let(:response) { double(body: { calculate_iban_response: { return: valid_payload.merge(return_code: '65536') } }) }

      it 'logs a message' do
        subject.calculate_iban({}) rescue IbanCalculator::ServiceError
        expect(subject.logger).to have_received(:info).with(/iban check failed/)
      end

      it 'fails with service error exception' do
        expect{ subject.calculate_iban({}) }.to raise_exception(IbanCalculator::ServiceError)
      end
    end
  end

  def valid_payload
    {
      :iban=>"DE59120300001111236988",
      :result=>"passed",
      :return_code=>"0",
      :ibanrueck_return_code=>{
        :"@xsi:type"=>"xsd:string"
      },
      :checks=>{
        :item=>["length", "bank_code", "account_number"],
        :"@xsi:type"=>"SOAP-ENC:Array",
        :"@soap_enc:array_type"=>"xsd:string[3]"
      },
      :bic_candidates=>{
        :item=>{
          :bic=>"BYLADEM1001",
          :zip=>"10117",
          :city=>"Berlin",
          :wwwcount=>"0",
          :sampleurl=>{:"@xsi:type"=>"xsd:string"},
          :"@xsi:type"=>"tns:BICStruct"
        },
        :"@xsi:type"=>"SOAP-ENC:Array",
        :"@soap_enc:array_type"=>"tns:BICStruct[1]"
      },
      :country=>"DE",
      :bank_code=>"12030000",
      :alternative_bank_code=>{:"@xsi:type"=>"xsd:string"},
      :bank=>"Deutsche Kreditbank Berlin",
      :bank_address=>{:"@xsi:type"=>"xsd:string"},
      :bank_url=>{:"@xsi:type"=>"xsd:string"},
      :branch=>{:"@xsi:type"=>"xsd:string"},
      :branch_code=>{:"@xsi:type"=>"xsd:string"},
      :in_scl_directory=>"yes",
      :sct=>"yes",
      :sdd=>"yes",
      :b2b=>"yes",
      :account_number=>"1011856976",
      :alternative_account_number=>{:"@xsi:type"=>"xsd:string"},
      :account_validation_method=>"00",
      :account_validation=>"Methode 00, Konto 1111236988, BLZ 12030000, Prüfziffer 6 steht an Position 10, erwartete Prüfziffer: 6. Überblick über die Berechnung: Nimm die Ziffern auf den Positionen 1 bis 9 - hier: 1111236988 -, multipliziere sie von rechts nach links mit den Gewichten 2,1,2,1,2,1,2,1,2, addiere die Quersummen der Produkte, bilde den Rest der Division durch 10, ziehe das Ergebnis von 10 ab,  und das Ergebnis modulo 10 ist die erwartete Prüfziffer.",
      :length_check=>"passed",
      :account_check=>"passed",
      :bank_code_check=>"passed",
      :bic_plausibility_check=>{:"@xsi:type"=>"xsd:string"},
      :data_age=>"20140525",
      :iba_nformat=>"DEkk BBBB BBBB CCCC CCCC CC",
      :formatcomment=>"B = sort code (BLZ), C = account No.",
      :balance=>"4",
      :"@xsi:type"=>"tns:IBANCalcResStruct"
    }
  end
end
