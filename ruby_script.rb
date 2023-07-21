#!/usr/bin/env ruby
# Ruby code chmod +x myscript.sh"

require 'open3'
require 'getoptlong'

opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--app_name', '-a', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--db_url', '-d', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--user', '-u', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--password', '-p', GetoptLong::OPTIONAL_ARGUMENT ],

)

dir = nil
db_url = nil
app_name = nil
user = nil
password = ''

opts.each do |opt, arg|
  case opt
    when '--help'
      puts <<-EOF
hello [OPTION] ... DIR

-h, --help:
   show help

--app_name [app_name]:
   heroku app anme in your local git repos

      EOF
    when '--password'
      password = arg
    when '--user'
      user = arg
    when '--app_name'
      app_name = arg
    when '--db_url'
      puts opt

      if arg == ''
        exit 0
        return
      else
        db_url = arg
      end
  end
end

puts db_url
puts db_url
puts app_name
puts user
puts password

return if db_url.nil? or app_name.nil?

# Heroku app and database details
heroku_app_name = app_name
heroku_database_url = db_url 

# Local PostgreSQL connection details
local_database_url = 'postgres://localhost:5432/local_database_name'
local_database_username = user
local_database_password = password

# Backup and restore database
def backup_database(heroku_database_url, backup_file)
  puts 'Backing up the Heroku database...'
  `pg_dump "#{heroku_database_url}" > "#{backup_file}"`
  puts 'Backup completed!'
end

def restore_database(local_database_url, backup_file)
  puts 'Restoring the local database...'
  `pg_restore --clean --verbose --no-acl --no-owner -U "#{local_database_username}" -d "#{local_database_url}" "#{backup_file}"`
  puts 'Restore completed!'
end

# Generate a backup file name
backup_file = "database_backup_#{Time.now.strftime('%Y%m%d%H%M%S')}.sql"

# Backup the Heroku database
backup_database(heroku_database_url, backup_file)

# Restore the database locally
restore_database(local_database_url, backup_file)

# Clean up the backup file
File.delete(backup_file)

puts 'Database migration complete!'
