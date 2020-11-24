class ListsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_list, only: [:show, :edit, :update, :destroy]

  # GET /lists
  # GET /lists.json
  def index
    @lists = List.all
  end

  # GET /lists/1
  # GET /lists/1.json
  def show
  end

  # GET /lists/new
  def new
    @list = List.create(user: current_user)
    redirect_to edit_list_path(@list)
  end

  # GET /lists/1/edit
  def edit
  end

  # # POST /lists
  # # POST /lists.json
  # def create
  #   @list = List.new(list_params)
  #   @list.user = current_user
  #
  #   respond_to do |format|
  #     if @list.save
  #       format.html { redirect_to @list, notice: 'List was successfully created.' }
  #       format.json { render :show, status: :created, location: @list }
  #     else
  #       format.html { render :new }
  #       format.json { render json: @list.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # PATCH/PUT /lists/1
  # PATCH/PUT /lists/1.json
  def update
    @list.assign_attributes(list_params)
    respond_to do |format|
      if params[:commit] == "Update List" && @list.save
        format.html { redirect_to @list, notice: 'List was successfully updated.' }
        format.json { render :show, status: :ok, location: @list }
        format.js   { redirect_to @list, notice: 'List was successfully updated.' }
      elsif @list.save
        format.html { redirect_to @list, notice: 'List was successfully updated.' }
        format.json { render :show, status: :ok, location: @list }
        format.js
      else
        format.html { render :edit }
        format.json { render json: @list.errors, status: :unprocessable_entity }
        format.js { head :unprocessable_entity }
      end
    end
  end

  # DELETE /lists/1
  # DELETE /lists/1.json
  def destroy
    @list.destroy
    respond_to do |format|
      format.html { redirect_to lists_url, notice: 'List was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_list
      @list = List.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def list_params
      params.require(:list).permit(:name, :description, items_attributes: [ :id, :position, :name, :description, :completed_at, :_destroy ])
    end
end
