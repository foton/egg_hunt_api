class User < ActiveRecord::Base
  has_secure_token
  TOKEN_FOR_REGENERATE="regenerate"
  EMAIL_REGEXP =/[\w-]+(\.[\w-]+)*@([a-z0-9-]+(\.[a-z0-9-]+)*?\.[a-z]{2,6}|(\d{1,3}\.){3}\d{1,3})(:\d{4})?/ # from http://regexlib.com/Search.aspx?k=email&c=1&m=-1&ps=20

  validates :email, presence: true, format: { with: EMAIL_REGEXP}, uniqueness: true
  validates :token, presence: true, length: { minimum: 20, maximum: 250 }, uniqueness: true, on: :update
  
  before_validation :fill_in_new_token #token should be generated before_create by has_secure_token

  def self.authorized_attributes_for(other_user)
    ( other_user.present? && other_user.admin? ) ? [:email, :token, :admin] : []
  end  

  private

    def fill_in_new_token
      self.regenerate_token if (self.token == TOKEN_FOR_REGENERATE) || self.token.blank?
    end  


end
