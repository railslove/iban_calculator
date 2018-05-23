describe IbanCalculator do
  describe '.url' do
    it 'defaults to ibanrechner.de' do
      expect(IbanCalculator.url).to eq('https://ssl.ibanrechner.de/soap/?wsdl')
    end

    it 'allows overriding' do
      IbanCalculator.url = 'http://mytest.com'
      expect(IbanCalculator.url).to eq('http://mytest.com')
      IbanCalculator.url = 'https://ssl.ibanrechner.de/soap/?wsdl'
    end
  end

  describe '.user' do
    it 'defaults to ""' do
      expect(IbanCalculator.user).to eq('')
    end

    it 'allows specifying it' do
      IbanCalculator.user = 'test'
      expect(IbanCalculator.user).to eq('test')
      IbanCalculator.user = ''
    end
  end

  describe '.password' do
    it 'defaults to ""' do
      expect(IbanCalculator.password).to eq('')
    end

    it 'allows specifying it' do
      IbanCalculator.password = 'test'
      expect(IbanCalculator.password).to eq('test')
      IbanCalculator.password = ''
    end
  end

  describe '.logger' do
    it 'defaults to a logger instance' do
      expect(IbanCalculator.logger).to be_instance_of(Logger)
    end

    it 'allows specifying it' do
      old_logger = IbanCalculator.logger
      logger = Logger.new(STDERR)
      IbanCalculator.logger = logger
      expect(IbanCalculator.logger).to eql(logger)
      IbanCalculator.logger = old_logger
    end
  end

  describe '.calculate_iban' do
    let(:error_message) { 'Service could not handle the request' }
    let(:response) { { calculate_iban_response: { return: { return_code: '65536' } } } }

    before { allow_any_instance_of(Savon::Client).to receive(:call) { double(body: response) } }

    it 'raises a generic exception' do
      expect { IbanCalculator.calculate_iban({}) }.to raise_error(IbanCalculator::ServiceError, error_message)
    end
  end

  describe '.execute' do
    context 'invalid username and password' do
      let(:error_message) { 'User someone, password test: invalid username-password combination' }
      let(:response) { { failing_response: { return: { result: error_message } } } }

      before { allow_any_instance_of(Savon::Client).to receive(:call) { double(body: response) } }

      it 'raises a generic exception' do
        expect { IbanCalculator.execute(:failing) }.to raise_error(IbanCalculator::ServiceError, error_message)
      end
    end
  end
end
