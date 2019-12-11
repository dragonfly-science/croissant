class TaxonomiesController < ApplicationController
  before_action :set_taxonomy, only: %i[show]

  # GET /taxonomies/1
  def show
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_taxonomy
    @taxonomy = Taxonomy.find(params[:id])
  end
end
