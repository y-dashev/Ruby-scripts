#!/usr/bin/env ruby
# frozen_string_literal: true

require 'open3'
require 'getoptlong'

DATABASE_URL_COMMAND = 'heroku config:get DATABASE_URL --remote='

# rubocop:disable Metrics/MethodLength
def print_help
  puts `
    Usage: #{File.basename(__FILE__)} [OPTIONS]

    Options:
      -h, --help:
        Show this help message.

      -a, --app_name APP_NAME:
        Heroku app name needed for db URL.

      -n, --db_name DB_NAME:
        Local database name.

      -u, --user USER:
        Optional: Database user name.

      -p, --password PASSWORD:
        Optional: Database password.
  `
end
# rubocop:enable Metrics/MethodLength

def run_command(command)
  stdout, stderr, status = Open3.capture3(command)
  raise "Error running command: #{command}\n#{stderr}" unless status.success?

  stdout.strip
end

def backup_database(heroku_database_url, backup_file)
  puts 'Backing up the Heroku database...'
  command = "pg_dump #{heroku_database_url} > #{backup_file}"
  run_command(command)
  puts 'Backup completed!'
end

def restore_database(db_name, backup_file)
  puts 'Restoring the local database...'
  command = "pg_restore -d #{db_name} --no-owner --no-privilege --data-only #{backup_file}"
  run_command(command)
  puts 'Restore completed!'
end

opts = GetoptLong.new(
  ['--help', '-h', GetoptLong::NO_ARGUMENT],
  ['--app_name', '-a', GetoptLong::REQUIRED_ARGUMENT],
  ['--db_name', '-n', GetoptLong::REQUIRED_ARGUMENT],
  ['--user', '-u', GetoptLong::OPTIONAL_ARGUMENT],
  ['--password', '-p', GetoptLong::OPTIONAL_ARGUMENT]
)

heroku_database_url = nil
user = nil
password = ''
db_name = ''

opts.each do |opt, arg|
  case opt
  when '--help'
    print_help
    exit(0)
  when '--password'
    password = arg
  when '--user'
    user = arg
  when '--db_name'
    db_name = arg
  when '--app_name'
    heroku_database_url = run_command("#{DATABASE_URL_COMMAND}#{arg}")
  end
end

unless heroku_database_url
  puts 'Heroku database URL not found. Please provide a valid app name.'
  exit(1)
end

# Generate a backup file name
backup_file = "database_backup_#{Time.now.strftime('%Y%m%d%H%M%S')}.sql"

# Backup the Heroku database
backup_database(heroku_database_url, backup_file)

# Restore the database locally
restore_database(db_name, backup_file)

# Clean up the backup file
File.delete(backup_file)

puts 'Database migration complete!'
