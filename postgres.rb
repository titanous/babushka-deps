def psql(cmd)
  sudo "echo \"#{cmd.gsub('"', '\"').end_with(';')}\" | #{which 'psql'}", :as => 'postgres'
end

dep 'postgres passworded access' do
  requires 'postgres software', 'user exists'
  met? { !sudo("echo '\\du' | #{which 'psql'}", :as => 'postgres').split("\n").grep(/^\W*\b#{var :username}\b/).empty? }
  meet { psql "CREATE USER #{var :username} WITH PASSWORD '#{var :password}' CREATEDB" }
end

dep 'postgres db' do
  requires 'postgres gem', 'postgres access'
  met? {
    !shell("psql -l") {|shell|
      shell.stdout.split("\n").grep(/^\s*#{var :db_name}\s+\|/)
    }.empty?
  }
  meet {
    sudo "createdb -O '#{var :username}' '#{var :db_name}'", :as => 'postgres'
  }
end
