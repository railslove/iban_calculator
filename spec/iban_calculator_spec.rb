require 'spec_helper'

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
end
