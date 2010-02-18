# encoding: utf-8

require "rubygems"
require "sinatra"
require "parser"

get "/" do
  erb :index
end

post "/plan" do
  begin
    if params[:data]
      send_data EclParser.generate!(params[:data]), :filename => "plan-pwr.pdf", 
        :disposition => "attachment", :type => 'application/pdf'
    else
      "Error!"
    end
  rescue
    "Error!. Skontaktuj sie z administratorem ;]"
  end
end