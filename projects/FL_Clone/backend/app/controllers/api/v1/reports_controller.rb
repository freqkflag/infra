class Api::V1::ReportsController < ApplicationController
  def create
    report = current_user.reports.build(report_params)
    
    if report.save
      render json: { message: 'Report submitted' }, status: :created
    else
      render json: { errors: report.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  private
  
  def report_params
    params.require(:report).permit(:reportable_type, :reportable_id, :reason)
  end
end

