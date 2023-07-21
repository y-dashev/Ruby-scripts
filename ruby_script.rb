#!/usr/bin/env ruby
# Ruby code chmod +x myscript.sh"

require 'open3'
require 'getoptlong'

opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--db_url', '-d', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--db_name', '-n', GetoptLong::REQUIRED_ARGUMENT ],
  [ '--user', '-u', GetoptLong::OPTIONAL_ARGUMENT ],
  [ '--password', '-p', GetoptLong::OPTIONAL_ARGUMENT ],

)

# heroku db url
heroku_database_url = nil

user = nil
password = ''
db_name = ''

opts.each do |opt, arg|
  case opt
    when '--help'
      puts <<-EOF
hello [OPTION] ... 

-h, --help:
   show help

--db_url [db_url]:
   heroku app db url 

      EOF
    when '--password'
      password = arg
    when '--user'
      user = arg
    when '--db_name'
      db_name = arg
    when '--db_url'
      puts opt

      if arg == ''
        exit 0
        return
      else
        heroku_database_url = arg
      end
  end
end


return if heroku_database_url.nil?


# Backup and restore database
def backup_database(heroku_database_url, backup_file)
  puts 'Backing up the Heroku database...'
  `pg_dump "#{heroku_database_url}" > "#{backup_file}"`
  puts 'Backup completed!'
end

def restore_database(db_name,backup_file)
  puts 'Restoring the local database...'
  `pg_restore -d "#{db_name}" --no-owner --no-privilege --data-only "#{backup_file}"`
  puts 'Restore completed!'
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
