class Modele < ActiveRecord::Base

  # validates_presence_of :title

  has_many :serveurs
  has_many :composants, -> { order(name: :asc, position: :asc) }

  belongs_to :marque
  belongs_to :architecture
  belongs_to :category

  accepts_nested_attributes_for :composants,
                                :allow_destroy => true,
                                :reject_if     => :all_blank

  def to_s
    title
  end
end
