class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :masqueradable, :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :omniauthable

  has_one_attached :avatar
  has_person_name

  has_many :notifications, as: :recipient
  has_many :services

  include PgSearch::Model
  pg_search_scope :search_by_full_name,
                  against: [ :first_name, :last_name ],
                  using: {
                      # dmetaphone: {},
                      tsearch: {
                          any_word: true,
                          dictionary: "english",
                          prefix: true
                      },
                      trigram: {
                          word_similarity: true,
                          # threshold: 0.1
                      }
                  }

  def self.search(params={})
    params.slice!(:q)
    params.delete_if { |_k, v| v.blank? }
    return all unless params.any?

    self.search_by_full_name(params[:q])
  end
end
