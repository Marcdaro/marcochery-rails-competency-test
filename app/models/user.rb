class User < ApplicationRecord
  ############################################################################################
  ## PeterGate Roles                                                                        ##
  ## The :user role is added by default and shouldn't be included in this list.             ##
  ## Add :root_admin to this list for a role that reaches every action whatever             ##
  ## the access rules say. Nobody can hold it until it is declared here.                    ##
  ## The multiple option can be set to true if you need users to have multiple roles.       ##
  # #petergate(roles: [:admin, :editor], multiple: false)                                      ##
  ############################################################################################


  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  petergate roles: [ :editor, :admin ], multiple: false
  has_many :articles
end
