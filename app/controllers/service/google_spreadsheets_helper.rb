module Service
  class GoogleSpreadsheetsHelper

    private
      # @google_json = { "type": "service_account", "project_id": "oncampus1", "private_key_id": "2bcb395b01a0a95a2b6aec4cfe02605c4183b4ef", "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDTVTTl4I9Bk9kz\n70bZICtc5JVAq+U0rdd2d/sDoeeKra4WqCMoePFXaEUU3kqfwq+C2BYs0X6s8VTy\n/05DsQp0T6B1GXZH3BN70H/eBMxQS2nDDK7NMm0xZfcDshtWbKSiFxly8sAe+NWv\nsqRJ+zOPAI1ua0aIKJ2po1ysW2CUWkJZGFMES/b2Q0fc9DMhHchvBvkGN0niUn/C\n0iH303wNEauyX7YLYGtL9P7ZTcomge52qvqYCGXZhVAJst2Ht7og/6/+we/TOMj3\nhm7Vqsc6DpmelBL9jI1/rdZwHbRXYvex8QwSVEWlVNy34q272jMoa20k5ysFdzKI\njlipf6gnAgMBAAECggEAQtpljYLoTppyz5cWFoGytgQpove93lhQHM3/vjptgNVI\niSpPVPJNhpUZpWxctwVjeETbXvo21IbTlLtnCsrqv7igzepsHHdmQnjGunlSGOSC\nZI2Sjp8xI7tZ1PV26HQd8JjWGCLq2+Fj19zvU+f/e3F1TETrXw9aMNvY6T1O5B7G\nN38m6hvONe48iIhpqmoG9cBCyY9dWo3AtEpsop9BSj44KpVQMlq50w4I+hFTihWk\nZokz/RKfYcLwaMlRw3FblUNRgF4lOT5QJ/xg64rPNiEE01xgO1/ldf+dlidwe7+P\nOVeo8cI3B7pCI52Ny0CnGddpWMBGGSW93Y0prxRwAQKBgQDwllId4q4P3WHQmIOL\nbAOWjIf7CXmGFZwXk7uZ4wbWsPl3heEpIsLqi3sYB2mSVFfdPE8rSM2CSSsaP8ud\nW/ZquGqBo5BMbgu/aciISxuFweKjFHptEeZxxUeHMNsUxOvhRLwtHR2IiodZRXB8\nf5lvYUMexnCrN+Y8G3KAsi8mAQKBgQDg3xvGR5Db9mZATxjbohcQ8V9sgS9IGQja\nDqXn46fM54jvwXFtWeKNE/Nn+rXeR7QJ3ccbpEz1+4FAqIrOaUJiV8DokaDmOwAs\nAEabaqfRruU/CuZ7mCykeMsfzwdFSwsg/EKfhU0nLN1LwkSJV1bQZD4/Di40BIqz\ntL1Q+VzeJwKBgQC1dyyJDilsHfdhdygBSX+LVoRafVMEJ9iMkAm4kNzfoq0H0ht7\nA5Uxg/NctHqUvLlpTcwJQeiAlN/F9MiH8I11AZSUI+L7QyXpQsjWxJAF27AugYu2\nKQJAXiUNe3RDviSMzWOCQ6u7CYH9e7rUrQn2UM5nsBXbj1ZBkBJVsBCQAQKBgCvV\ncc2Rz7wA6OeqQ3c0vnhQBMDa4cOVFbOj3VU5fFEl5PyPYbPmLJJBjFX9egwtP/wY\nXiKWQWZFs2lOMViRDh6ranArSwj2AU+ScjEDdlkaVZeXYVxASpt47Gdz7L/mI/I3\nGimMS4DSbwTAhqma+9I9aCDUe88p/3uORMUPBrpLAoGBANSEiyMNkkooujJITRFn\nmFPD88yZIl9YmynroqKipfq0DevypjMnVkv/pPHKEMsL2GhVEkQSU1+HApbi5KIF\ntgKHmspZpGSt84tcJynuUT7B758HlclCUGnTjyd4o335Bs3uE+//bjP6W9xlyCrW\nyrFhslLkhnZakZam1OgcrZeP\n-----END PRIVATE KEY-----\n", "client_email": "admin1@oncampus1.iam.gserviceaccount.com", "client_id": "115566620386982553662", "auth_uri": "https://accounts.google.com/o/oauth2/auth", "token_uri": "https://oauth2.googleapis.com/token", "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs", "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/admin1%40oncampus1.iam.gserviceaccount.com", "universe_domain": "googleapis.com" }

   @google_json = JSON.parse(ENV['GOOGLE_JSON'])
    def self.create_spreadsheet

      require 'google_drive'

      # Authenticate using the service account credentials JSON
      session = GoogleDrive::Session.from_service_account_key(StringIO.new(@google_json.to_json))

      # Create a new spreadsheet
      spreadsheet_title = 'Bulk upload - ' + Time.now.to_i.to_s
      spreadsheet = session.create_spreadsheet(spreadsheet_title)
      # spreadsheet.publish_to_web

      # Get the first worksheet
      worksheet = spreadsheet.worksheets.first

      # Add headers to the first row
      headers = [
        "Username", "Password", "First name", "Middle name", "Last name",
        "Gender", "Date of birth", "Mother name", "Father name", "Nationality",
        "Email address", "Phone", "Current CGPA", "Roll number", "Year of passing",
        "Branch", "Section", "Active backlogs"
      ]

      sheet_setup(spreadsheet)
      worksheet.max_rows = 100
      worksheet.max_cols = 17
      worksheet.insert_rows(1, [headers])
      worksheet.save
      # Make the spreadsheet public
      spreadsheet.acl.push({ type: 'anyone', role: 'writer' })
      # Get the public link
      public_link = spreadsheet.human_url

      puts "Spreadsheet published and set to public. Public link: #{public_link}"

      # Construct the embed link
      return spreadsheet.key
    end


    def self.create_users_from_spreadsheet(spreadsheet_id)
      require 'google_drive'

      # Authenticate using the service account credentials JSON
      session = GoogleDrive::Session.from_service_account_key(StringIO.new(@google_json.to_json))
      spreadsheet = session.file_by_id(spreadsheet_id)
      worksheet = spreadsheet.worksheets.first
      users = []

      # Iterate through rows in the worksheet (skipping the header row)
      (2..worksheet.num_rows).each do |row_index|
        row_data = worksheet.rows[row_index - 1]
        user = {
          "user": {
            "college_id": 101,
            "username": row_data[0],
            "password": row_data[1],
            "usertype": "S",
            "name_attributes": {
              "first": row_data[2],
              "middle": row_data[3],
              "last": row_data[4]
            },
            "personal_detail_attributes": {
              "gender": row_data[5],
              "dob": row_data[6],
              "mother_name": row_data[7],
              "father_name": row_data[8],
              "nationality": row_data[9]
            },
            "contact_detail_attributes": {
              "email": row_data[10],
              "phone": row_data[11]
            },
            "academic_detail_attributes": {
              "current_cgpa": row_data[12].to_f,
              "rollno": row_data[13],
              "yop": row_data[14].to_i,
              "branch_id": Branch.find_by(college_id: 101, abbr: row_data[15]).id,
              "section": row_data[16],
              "backlogs": row_data[17].to_s.downcase == "true"
            }
          }
        }
        users << user
      end


      spreadsheet.delete(permanent=true)
      users
    end


    def self.delete_file(id)
      require 'google_drive'

      # Authenticate using the service account credentials JSON
      session = GoogleDrive::Session.from_service_account_key(StringIO.new(@google_json.to_json))
      session.delete_file(id)
    end


    def self.clean

      # Initialize the Drive API
      drive_service = Google::Apis::DriveV3::DriveService.new
      drive_service.client_options.application_name = 'Google Drive Ruby'
      drive_service.authorization = Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: StringIO.new(@google_json.to_json),
        scope: Google::Apis::DriveV3::AUTH_DRIVE_FILE
      )
      response = drive_service.list_files

      # Print the file names
      response.files.each do |file|
        # drive_service.delete_file(file.id)
        puts file.name
      end
    end


    def self.sheet_setup(spreadsheet)
      require 'google/apis/sheets_v4'
      require 'googleauth'
      require 'googleauth/stores/file_token_store'
      require 'google/apis/drive_v3'

      service = Google::Apis::SheetsV4::SheetsService.new

      service.client_options.application_name = 'Google Sheets Ruby'
      service.authorization = Google::Auth::ServiceAccountCredentials.make_creds(
        json_key_io: StringIO.new(@google_json.to_json),
        scope: Google::Apis::SheetsV4::AUTH_SPREADSHEETS
      )

      gender_validation_request = Google::Apis::SheetsV4::Request.new(
        set_data_validation: Google::Apis::SheetsV4::SetDataValidationRequest.new(
          range: Google::Apis::SheetsV4::GridRange.new(
            start_column_index: 5,
            end_column_index: 6,
            start_row_index: 1,
            sheet_id:0
          ),
          rule: Google::Apis::SheetsV4::DataValidationRule.new(
            condition: Google::Apis::SheetsV4::BooleanCondition.new(
              type: 'ONE_OF_LIST',
              values: [
                Google::Apis::SheetsV4::ConditionValue.new(user_entered_value: 'Male'),
                Google::Apis::SheetsV4::ConditionValue.new(user_entered_value: 'Female'),
                Google::Apis::SheetsV4::ConditionValue.new(user_entered_value: 'Other'),
              ]
            ),
            show_custom_ui: true,
            strict:true,
            input_message: "Select from options"
          )
        )
      )

      date_validation_request = Google::Apis::SheetsV4::Request.new(
        set_data_validation: Google::Apis::SheetsV4::SetDataValidationRequest.new(
          range: Google::Apis::SheetsV4::GridRange.new(
            start_column_index: 6,
            end_column_index: 7,
            start_row_index: 1,
            sheet_id: 0
          ),
          rule: Google::Apis::SheetsV4::DataValidationRule.new(
            condition: Google::Apis::SheetsV4::BooleanCondition.new(
              type: 'CUSTOM_FORMULA',
              values: [Google::Apis::SheetsV4::ConditionValue.new(user_entered_value: '=REGEXMATCH(TO_TEXT(G:G), "^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0,1,2])/(19|20)\\d{2}$")')]
            ),
            show_custom_ui: true,
            input_message: "Enter DD/MM/YYYY"
          )
        )
      )

      email_validation_request = Google::Apis::SheetsV4::Request.new(
        set_data_validation: Google::Apis::SheetsV4::SetDataValidationRequest.new(
          range: Google::Apis::SheetsV4::GridRange.new(
            start_column_index: 10,
            end_column_index: 11,
            start_row_index: 1,
            sheet_id: 0
          ),
          rule: Google::Apis::SheetsV4::DataValidationRule.new(
            condition: Google::Apis::SheetsV4::BooleanCondition.new(
              type: 'CUSTOM_FORMULA',
              values: [Google::Apis::SheetsV4::ConditionValue.new(user_entered_value: '=REGEXMATCH(TO_TEXT(K:K), "^[A-Za-z0-9._%+-]+@[A-Za-z0-9\\.-]+.[A-Za-z]{2,}$")')]
            ),
            show_custom_ui: true,
            input_message: "Enter valid email"
          )
        )
      )

      phone_validation_request = Google::Apis::SheetsV4::Request.new(
        set_data_validation: Google::Apis::SheetsV4::SetDataValidationRequest.new(
          range: Google::Apis::SheetsV4::GridRange.new(
            start_column_index: 11,
            end_column_index: 12,
            start_row_index: 1,
            sheet_id: 0
          ),
          rule: Google::Apis::SheetsV4::DataValidationRule.new(
            condition: Google::Apis::SheetsV4::BooleanCondition.new(
              type: 'CUSTOM_FORMULA',
              values: [Google::Apis::SheetsV4::ConditionValue.new(user_entered_value: '=REGEXMATCH(TO_TEXT(L:L), "^\\d{10}$")')]
            ),
            show_custom_ui: true,
            input_message: "Enter valid email"
          )
        )
      )

      cgpa_validation_request = Google::Apis::SheetsV4::Request.new(
        set_data_validation: Google::Apis::SheetsV4::SetDataValidationRequest.new(
          range: Google::Apis::SheetsV4::GridRange.new(
            start_column_index: 12,
            end_column_index: 13,
            start_row_index: 1,
            sheet_id: 0
          ),
          rule: Google::Apis::SheetsV4::DataValidationRule.new(
            condition: Google::Apis::SheetsV4::BooleanCondition.new(
              type: 'CUSTOM_FORMULA',
              values: [Google::Apis::SheetsV4::ConditionValue.new(user_entered_value: '=REGEXMATCH(TO_TEXT(M:M), "^\\d{1,}\\.?\\d{0,}$")')]
            ),
            show_custom_ui: true,
            input_message: "Enter valid cgpa"
          )
        )
      )

      yop_validation_request = Google::Apis::SheetsV4::Request.new(
        set_data_validation: Google::Apis::SheetsV4::SetDataValidationRequest.new(
          range: Google::Apis::SheetsV4::GridRange.new(
            start_column_index: 14,
            end_column_index: 15,
            start_row_index: 1,
            sheet_id: 0
          ),
          rule: Google::Apis::SheetsV4::DataValidationRule.new(
            condition: Google::Apis::SheetsV4::BooleanCondition.new(
              type: 'ONE_OF_LIST',
              values:
                (Time.now.year-2..Time.now.year+6).map { |value| Google::Apis::SheetsV4::ConditionValue.new(user_entered_value: value.to_s) },

              ),
            show_custom_ui: true,
            strict:true,
            input_message: "Select from options"
          )
        )
      )


      branch_validation_request = Google::Apis::SheetsV4::Request.new(
        set_data_validation: Google::Apis::SheetsV4::SetDataValidationRequest.new(
          range: Google::Apis::SheetsV4::GridRange.new(
            start_column_index: 15,
            end_column_index: 16,
            start_row_index: 1,
            sheet_id: 0
          ),
          rule: Google::Apis::SheetsV4::DataValidationRule.new(
            condition: Google::Apis::SheetsV4::BooleanCondition.new(
              type: 'ONE_OF_LIST',
              values:
                (Branch.all.where(college_id: 101)).map { |branch| Google::Apis::SheetsV4::ConditionValue.new(user_entered_value: branch.abbr) },

              ),
            show_custom_ui: true,
            strict:true,
            input_message: "Select from options"
          )
        )
      )

      section_validation_request = Google::Apis::SheetsV4::Request.new(
        set_data_validation: Google::Apis::SheetsV4::SetDataValidationRequest.new(
          range: Google::Apis::SheetsV4::GridRange.new(
            start_column_index: 16,
            end_column_index: 17,
            start_row_index: 1,
            sheet_id: 0
          ),
          rule: Google::Apis::SheetsV4::DataValidationRule.new(
            condition: Google::Apis::SheetsV4::BooleanCondition.new(
              type: 'ONE_OF_LIST',
              values:
                ['A', 'B', 'C'].map { |section| Google::Apis::SheetsV4::ConditionValue.new(user_entered_value: section) },
              ),
            show_custom_ui: true,
            strict:true,
            input_message: "Select from options"
          )
        )
      )

      backlogs_validation_request = Google::Apis::SheetsV4::Request.new(
        set_data_validation: Google::Apis::SheetsV4::SetDataValidationRequest.new(
          range: Google::Apis::SheetsV4::GridRange.new(
            start_column_index: 17,
            end_column_index: 18,
            start_row_index: 1,
            sheet_id: 0
          ),
          rule: Google::Apis::SheetsV4::DataValidationRule.new(
            condition: Google::Apis::SheetsV4::BooleanCondition.new(
              type: 'ONE_OF_LIST',
              values:
                ['Yes', 'No'].map { |value| Google::Apis::SheetsV4::ConditionValue.new(user_entered_value: value) }
            ),
            show_custom_ui: true,
            strict:true,
            input_message: "Select from options"
          )
        )
      )

      # publish_request = Google::Apis::SheetsV4::BatchUpdateSpreadsheetRequest.new(requests: [
      #   Google::Apis::SheetsV4::Request.new(update_sheet_properties: {
      #     properties: { sheet_id: 0,
      #                   grid_properties: { frozen_row_count: 1 } },
      #     fields: 'gridProperties.frozenRowCount'
      #   }),
      #   Google::Apis::SheetsV4::Request.new(update_spreadsheet_properties: {
      #     properties: { auto_recalc: 'ON_CHANGE' },
      #     fields: 'autoRecalc'
      #   })
      # ])

      batch_update_request = Google::Apis::SheetsV4::BatchUpdateSpreadsheetRequest.new(
        requests: [
          gender_validation_request,
          date_validation_request,
          email_validation_request,
          phone_validation_request,
          cgpa_validation_request,
          yop_validation_request,
          branch_validation_request,
          section_validation_request,
          backlogs_validation_request,
        ]
      )


      service.batch_update_spreadsheet(spreadsheet.key, batch_update_request)
      # service.batch_update_spreadsheet(spreadsheet.key, publish_request)


    end


    def self.upload_internship_document(file, internship_id, type)

      @internship = Internship.find(internship_id)


      # Authenticate using the service account credentials JSON
      session = GoogleDrive::Session.from_service_account_key(StringIO.new(@google_json.to_json))

      # # Get the root collection (folder) of the Drive
      # root_collection = session.collection_by_title('Root')

      # Check if the 'Internships' folder exists
      # main_folder = session.collection_by_title('My Drive')
      main_folder = session.collection_by_id('1ZGAIYpvebDKp9pQFFoz5Am1ufNZh6U1v')

      # unless main_folder
      #   main_folder = session.create_collection('Internships')
      #   puts "Folder 'Internships' created successfully."
      # else
      #   puts "Folder 'Internships' already exists."
      # end

      @academic_detail = @internship.user.academic_detail
      class_folder_title=
      @academic_detail.yop.to_s + " "+
      @academic_detail.branch.abbr+ " "+
      @academic_detail.section



      # Check if the 'CSE-B' folder exists within 'Internships'
      class_folder = main_folder.subcollection_by_title(class_folder_title)

      # If the 'CSE-B' folder doesn't exist, create it
      unless class_folder
        class_folder = main_folder.create_subcollection(class_folder_title)
        puts "Folder '#{class_folder_title}' created successfully within 'Internships'."
      else
        puts "Folder '#{class_folder_title}' already exists within 'Internships'."
      end

      student_folder = class_folder.subcollection_by_title(@academic_detail.rollno)

      unless student_folder
        student_folder = class_folder.create_subcollection(@academic_detail.rollno)
        puts "Folder '#{@academic_detail.rollno}' created successfully within '#{class_folder_title}'."
      else
        puts "Folder '#{@academic_detail.rollno}' already exists within '#{class_folder_title}'."
      end


      internship_folder = student_folder.subcollection_by_title(@internship.company_name)

      unless internship_folder
        internship_folder = student_folder.create_subcollection(@internship.company_name)
        puts "Folder '#{@internship.company_name}' created successfully within '#{@academic_detail.rollno}'."
      else
        puts "Folder '#{@internship.company_name}' already exists within '#{@academic_detail.rollno}'."
      end


      if file
        file_name = file.original_filename


        file_exists = internship_folder.files.any? { |f| File.basename(f.title, ".*") ==  File.basename(file_name, ".*")}

        if file_exists
          # Overwrite the existing file
          existing_file = internship_folder.files.find { |f| File.basename(f.title, ".*") ==  File.basename(file_name, ".*") }
          existing_file.delete
        end

        file  = internship_folder.upload_from_string(file.read, file_name, convert: false)
        puts "File '#{file_name}' uploaded to '#{@internship.company_name}' folder."

        file.id
      else
        false
      end
    end

    def self.fetch_thumbnail(file_id, width = 100)
      # Assuming 'session' is already configured in the initializer
      session = GoogleDrive::Session.from_service_account_key(StringIO.new(@google_json.to_json))

      # Fetch file metadata using the file ID
      file = session.file_by_id(file_id)

      # Get the thumbnail link with the specified width
      thumbnail_link = file.thumbnail_link

      # Now you can use the thumbnail_link to display the thumbnail
      # For example, you can use an image_tag in your view
      # image_tag(thumbnail_link)
      thumbnail_link
    end
  end

end
