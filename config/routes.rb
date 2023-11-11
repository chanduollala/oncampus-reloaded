Rails.application.routes.draw do
  # resources :internship_documents
  # resources :internships
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  ################ Only for students. ###############

  # Identifies user by decoding Auth Token
  # Returns student details
  # [personal details, academic details, contact details]
  get "/profile", to: "users#show_profile_self"

  # Identifies student by user ID
  # Verifies login data of student
  # Generates Auth Token with [user_id, expiry, signature]
  # Returns Auth Token generated
  # [token]
  post "/login/student", to: "users#student_login"





  ################ Only for college admins. #########

  # Identifies user by student ID
  # Returns student details
  # [personal details, academic details, contact details]
  get "/student/:id", to: "users#show_student"


  # Identifies college by College Admin's ID. TODO
  # Creates entry in user - Student with identified college
  # Returns ID of created user
  # [id]
  post "/users", to: "users#create"


  # Identifies College Admin by user ID
  # Verifies login data of college admin
  # Generates Auth Token with [user_id, expiry, signature]
  # Returns Auth Token generated
  # [token]
  post "/login/college-admin", to: "users#collegeadmin_login"


  # Identifies college by College Admin's ID. TODO
  # Deletes all existing students of that college
  # []
  delete "/users", to: "users#destroy"


  # Returns branches of that college
  # [branches]
  get "/branches", to: "branches#index"


  # Identifies college by College Admin's ID.
  # Creates entry in Recruitments with identified college and company
  # Returns ID of Recruitment created
  # [id]
  post "/recruitments", to: "recruitments#create"


  # Identifies recruitment by Recruitment ID
  # Updates Recruitment fields
  # Returns ID of Recruitment created
  # [id]
  put "/recruitments/:id", to: "recruitments#update"



  get "/companies", to: "companies#index" #public


  get "/recruitments", to: "recruitments#index"
  get "/recruitments/:id", to: "recruitments#show"
  # get "/recruitments/status/:id", to: "recruitments#get_status"

  post "/recruitment-updates", to: "recruitment_updates#create" #ca only

  get "/branch/:id", to: "branches#show"

  post "/update-dp/:id", to: "users#update_dp" #any user
  get "/user-name-image", to: "users#name_and_image" #any user
  get "/company-logo/:id", to: "companies#get_logo" #public
  post "/update-logo/:id", to: "companies#update_logo" #public #TODO
  get "/user-dp/:id", to: "users#get_image" #any user

  get "/selections", to: "campus_selections#search"
  get "/students/search/:search_term", to: "users#search"
  post "/selections/campus", to: "campus_selections#create"
  get "/selections/summary/:recruitment_id", to: "campus_selections#get_selection_summary"
  delete "/selections/campus/:id", to: "campus_selections#destroy"
  get "/students/bulk-upload", to: "users#bulk_upload_template"
  get "/create-multiple-users", to: "users#create_multiple_users"
  get "/students/branch/:branch_id", to: "users#index_by_branch"


  get "selections/campus/student/:id", to: "campus_selections#student_summary"
  get "calendar", to: "recruitment_updates#daywise_updates"
  get "export/student-data", to: "users#students_data"
  get "export/placement-data", to: "campus_selections#export_placements_data"
  get "placement_summary", to: "campus_selections#placement_summary"



  post "internships", to: "internships#create"
  get "internships/:id", to: "internships#show"
  get "internships", to: "internships#index"


end
