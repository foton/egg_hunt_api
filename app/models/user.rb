class User < ActiveRecord::Base
  has_secure_token

  EMAIL_REGEXP =/[\w-]+(\.[\w-]+)*@([a-z0-9-]+(\.[a-z0-9-]+)*?\.[a-z]{2,6}|(\d{1,3}\.){3}\d{1,3})(:\d{4})?/ # from http://regexlib.com/Search.aspx?k=email&c=1&m=-1&ps=20

  validates :email, presence: true, format: { with: EMAIL_REGEXP}, uniqueness: true
  #token is generated before_create by has_secure_token
  validates :token, presence: true, length: { minimum: 20, maximum: 250 }, uniqueness: true, on: :update


  def self.authorized_attributes_for(other_user)
    ( other_user.present? && other_user.admin? ) ? [:email, :admin] : []
  end  


end
