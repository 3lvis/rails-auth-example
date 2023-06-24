require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'has a valid' do
    it 'factory' do
      user = build(:user)
      expect(user).to be_valid
    end
  
    it 'email format' do
      user = build(:user, email: 'invalid_email')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('is not an email')
    end
  end

  describe 'is invalid without' do
    it 'a name' do
      user = build(:user, name: nil)
      expect(user).not_to be_valid
    end
  
    it 'an email' do
      user = build(:user, email: nil)
      expect(user).not_to be_valid
    end  
  end

  describe 'email uniqueness' do
    let!(:user) { create(:user) }

    context 'when the email address is already taken' do
      it 'is not valid' do
        new_user = build(:user, email: user.email)
        expect(new_user).not_to be_valid
      end
    end

    context 'when the email address is not taken' do
      it 'is valid' do
        new_user = build(:user, email: 'another_test@example.com')
        expect(new_user).to be_valid
      end
    end
  end
end