class ImportUsersController < ApplicationController
  def index
    @group = Group.find(params[:id])
    if request.post?
      @import = ImportUserToGroup.new
      import_data
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end


  private

  def import_data
    @import.call(@group)
    @import.user = User.current
    @import.original_file = params[:file]
    @import.set_default_settings
    @import.extname = File.extname( params[:file].original_filename) if params[:file]
    @import.call(@group)
    flash[:notice] = "#{@import.users_saved.count} users imported. #{@import.users_failed.count} users do not exist: #{@import.users_failed.join('<br/>')}".html_safe
    redirect_to edit_group_path(@group)
  rescue CSV::MalformedCSVError => e
    flash.now[:error] = l(:error_invalid_csv_file_or_settings)
  rescue ArgumentError, EncodingError => e
    flash.now[:error] = l(:error_invalid_file_encoding, :encoding => ERB::Util.h(@import.settings['encoding']))
  rescue SystemCallError => e
    flash.now[:error] = l(:error_can_not_read_import_file)
  end
end
