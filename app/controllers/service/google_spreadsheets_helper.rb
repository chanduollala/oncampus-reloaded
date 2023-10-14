module Service
  class GoogleSpreadsheetsHelper


    @google_json = Rails.application.credentials.google_api_json

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
  end

end
