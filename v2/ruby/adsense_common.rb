#!/usr/bin/env ruby
# Encoding: utf-8
#
# Copyright:: Copyright 2021, Google LLC
#
# License:: Licensed under the Apache License, Version 2.0 (the "License");
#           you may not use this file except in compliance with the License.
#           You may obtain a copy of the License at
#
#           http://www.apache.org/licenses/LICENSE-2.0
#
#           Unless required by applicable law or agreed to in writing, software
#           distributed under the License is distributed on an "AS IS" BASIS,
#           WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
#           implied.
#           See the License for the specific language governing permissions and
#           limitations under the License.
#
# Handles common tasks across all AdSense Management API samples.

require 'google/apis'
require 'google/apis/adsense_v2'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'logger'

API_NAME = 'adsense'
API_SCOPE = 'https://www.googleapis.com/auth/adsense.readonly'
CLIENT_SECRETS_FILE = 'client_secrets.json'
CREDENTIAL_STORE_FILE = "#{API_NAME}-oauth2.yaml"
OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'

# Handles authentication and loading of the API.
def service_setup()
  # Uncomment the following lines to enable logging.
  # log_file = File.open("#{$0}.log", 'a+')
  # log_file.sync = true
  # logger = Logger.new(log_file)
  # logger.level = Logger::DEBUG
  # Google::Apis.logger = logger # Logging is set globally

  # The Google Auth Library for Ruby requires a user ID. If your app serves
  # multiple users, you will need to manage them yourself. Note: this ID
  # is not directly related to Client ID or any other OAuth constructs.
  user_id = 'ruby-adsense-examples-user'

  # Get OAuth credentials.
  client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_FILE)
  token_store = Google::Auth::Stores::FileTokenStore.new(
      :file => CREDENTIAL_STORE_FILE)
  authorizer = Google::Auth::UserAuthorizer.new(
      client_id, Google::Apis::AdsenseV2::AUTH_ADSENSE_READONLY, token_store)
  credentials = authorizer.get_credentials(user_id)

  # If OAuth tokens were not found, run the OAuth flow.
  if credentials.nil?
    url = authorizer.get_authorization_url(base_url: OOB_URI)
    puts 'Open the following URL in the browser and enter the ' +
         'resulting code after authorization'
    puts url
    print 'Code: '
    code = STDIN.gets
    credentials = authorizer.get_and_store_credentials_from_code(
        user_id: user_id, code: code, base_url: OOB_URI)
  end

  # Initialize and return API Service.
  service = Google::Apis::AdsenseV2::AdsenseService.new
  service.client_options.application_name = "Ruby #{API_NAME} samples: #{$0}"
  service.client_options.application_version = '1.0.0'
  service.request_options.authorization = credentials
  return service
end

# Lists all AdSense accounts the user has access to, and prompts them to choose
# one. Returns the account ID.
def choose_account(adsense)
  result = adsense.list_accounts()
  account = nil

  if !result || !result.accounts || result.accounts.empty?
    puts 'No AdSense accounts found. Exiting.'
    exit
  elsif result.accounts.length == 1
    account = result.accounts.first
    puts 'Only one account found (%s), using it.' % account.name
  else
    puts 'Please choose one of the following options: '
    result.accounts.each_with_index do |acc,i|
      puts '%d. %s (%s)' % [i + 1, acc.display_name, acc.name]
    end
    print '> '
    account_index = Integer(gets.chomp) - 1
    account = result.accounts[account_index]
    puts 'Account %s chosen, resuming.' % account.name
  end

  return account.name
end

# Converts a Google::Apis::AdsenseV2::Date into an ISO string (YYYY-MM-DD).
def date_to_iso_string(date)
  return nil if date.nil?
  return '%d-%02d-%02d' % [date.year, date.month, date.day]
end
