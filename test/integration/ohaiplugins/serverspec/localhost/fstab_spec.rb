require 'spec_helper'

fstab = OHAI['fstab']

describe 'Fstab Plugin' do

  it 'should be a Mash' do
      expect(fstab).to be_a(Mash)
  end

  it 'should have a value' do
      expect(fstab['fstab']).not_to be_empty
  end
end
