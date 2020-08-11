require File.expand_path '../../spec_helper.rb', __FILE__
require_relative '../../services/parse_class_name'

describe 'ParseClassName' do
  before(:all) {}

  it 'works with a standard class definition' do
    contents = "class Test \n other stuff"
    result = ParseClassName.call(contents)
    expect(result).to eq('Test')
  end

  it 'works with a class definition namespaced under a module' do
    contents = "module TestModule \n class Test \n other stuff"
    result = ParseClassName.call(contents)
    expect(result).to eq('TestModule::Test')
  end

  it 'works with a class definition namespaced under another class' do
    contents = "class TestClass \n class Test \n other stuff"
    result = ParseClassName.call(contents)
    expect(result).to eq('TestClass::Test')
  end

  it 'works with any combination of namespaced classes/modules' do
    contents =
      "module TestModuleOne \n module TestModuleTwo \n class TestClassOne \n other stuff"
    result = ParseClassName.call(contents)
    expect(result).to eq('TestModuleOne::TestModuleTwo::TestClassOne')
  end
end
