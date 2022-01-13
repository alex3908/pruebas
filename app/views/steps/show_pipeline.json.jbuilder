# frozen_string_literal: true

folder_paginated = @step.filtered_folders(params)
  .paginate(page: params[:page], per_page: @max_rows)

json.next_page folder_paginated.next_page
json.folders do
  json.array! folder_paginated, partial: "folders/folder", as: :folder
end
