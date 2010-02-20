# encoding: utf-8

require "rubygems"
require "sinatra"
require "lib/data"
require "lib/parser"
require "lib/pdf"

get "/" do
  erb :index
end

post "/plan" do
  begin
    if params[:data]
      days = EclParser.parse!(params[:data])
      pdf = PdfGenerator.generate!(days)
      
      send_data pdf, :filename => "plan-pwr.pdf", 
        :disposition => "attachment", :type => 'application/pdf'
    else
      "Error!"
    end
  rescue
    "Error!. Skontaktuj sie z administratorem ;]"
  end
end