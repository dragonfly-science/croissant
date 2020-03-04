class TaxonomiesController < ApplicationController
  before_action :set_taxonomy, only: %i[show upload]

  # GET /taxonomies/1
  def show
  end

  # PATCH /taxonomies/:id/upload
  def upload
    file = upload_params[:file]
    updater = TaxonomyUpdater.new(file, @taxonomy)
    if updater.valid?
      updater.import!
      flash_taxonomy_updater_notices(updater)
    else
      flash[:alert] = "Tags not updated. #{updater.validity_errors.join(", ")}"
      flash[:error_list] = updater.validity_errors
    end
    redirect_to taxonomy_path
  end

  private

  def flash_taxonomy_updater_notices(updater)
    flash[:notice] = updater.results_notice
    flash[:alert] = updater.errors_notice
    flash[:error_list] = updater.failed_items.map(&:formatted_error_messages)
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_taxonomy
    @taxonomy = Taxonomy.find(params[:id])
    authorize @taxonomy
  end

  def upload_params
    params.require(:taxonomy).permit(:file)
  end
end
