class Admin::ApplicationController < ApplicationController
  layout 'admin'

  http_basic_authenticate_with name: "admin", password: "h41r1llus10n"
end
