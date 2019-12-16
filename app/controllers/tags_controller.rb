class TagsController < ApplicationController
  before_action :set_tag, only: %i[destroy]
  before_action :set_taxonomy

  # POST taxonomies/:taxonomy_id/tags
  def create
    @tag = Tag.new(tag_params)

    if @tag.save
      redirect_to taxonomy_url(@taxonomy), notice: "Tag was successfully created."
    else
      render :new
    end
  end

  # DELETE taxonomies/:taxonomy_id/tags/1
  def destroy
    @tag.destroy
    redirect_to taxonomy_url(@taxonomy), notice: "Tag was successfully destroyed."
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_tag
    @tag = Tag.find(params[:id])
  end

  def set_taxonomy
    @taxonomy = Taxonomy.find(params[:taxonomy_id])
  end

  # Only allow a trusted parameter "white list" through.
  def tag_params
    params.require(:tag).permit(:name, :parent_id).merge(taxonomy: @taxonomy)
  end
end
