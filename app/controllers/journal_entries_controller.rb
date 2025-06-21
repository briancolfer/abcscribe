class JournalEntriesController < ApplicationController
  before_action :set_journal_entry, only: [:show, :edit, :update, :destroy]
  
  def index
    @journal_entries = current_user.journal_entries.order(created_at: :desc)
  end

  def show
  end

  def new
    @journal_entry = current_user.journal_entries.build
  end

  def create
    @journal_entry = current_user.journal_entries.build(journal_entry_params)
    
    if @journal_entry.save
      if params[:journal_entry][:new_tags].present?
        params[:journal_entry][:new_tags].each do |name|
          tag = current_user.tags.find_or_create_by(name: name.strip)
          @journal_entry.tags << tag unless @journal_entry.tags.include?(tag)
        end
      end
      redirect_to @journal_entry, notice: 'Journal entry was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @journal_entry.update(journal_entry_params)
      if params[:journal_entry][:new_tags].present?
        params[:journal_entry][:new_tags].each do |name|
          tag = current_user.tags.find_or_create_by(name: name.strip)
          @journal_entry.tags << tag unless @journal_entry.tags.include?(tag)
        end
      end
      redirect_to @journal_entry, notice: 'Journal entry was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @journal_entry.destroy
    redirect_to journal_entries_path, notice: 'Journal entry was successfully deleted.'
  end
  
  private
  
  def set_journal_entry
    @journal_entry = current_user.journal_entries.find(params[:id])
  end
  
  def journal_entry_params
    params.require(:journal_entry).permit(:antecedent, :behavior, :consequence,
      tag_ids: [], new_tags: [])
  end
end
