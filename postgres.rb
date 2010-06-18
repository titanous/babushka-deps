dep 'postgres passworded access' do
  requires 'postgres software', 'user exists'
  met? { !sudo("echo '\\du' | #{which 'psql'}", :as => 'postgres').split("\n").grep(/^\W*\b#{var :username}\b/).empty? }
  meet { sudo "echo \"CREATE USER #{var :username} WITH PASSWORD #{var :password}\" | psql", :as => 'postgres' }
end
