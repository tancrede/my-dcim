class BaiesController < ApplicationController
  def edit
    @baie = Baie.find(params[:id])
  end

  def update
    @baie = Baie.find(params[:id])
    respond_to do |format|
      if @baie.update(baie_params)
        format.html { redirect_to salle_path(@baie.salle), notice: 'baie was successfully updated.' }
        format.json { render :show, status: :ok, location: @baie }
      else
        format.html { render :edit }
        format.json { render json: @baie.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def baie_params
    params.require(:baie).permit(:title)
  end

end
