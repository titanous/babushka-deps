dep 'rack app' do
  requires 'postgres passworded access', 'postgres db', 'git deploy repo', 'webapp', 'git deploy hooks'
  setup {
    define_var :app_path, :default => "/home/#{var(:username)}/sites/#{var(:domain)}"
    set :rails_root, var(:app_path)
    set :vhost_type, 'passenger'
  }
end

dep 'git deploy repo' do
  requires 'git'

  setup {
    define_var :deploy_branch, :default => 'master'
  }

  met? {
    git_repo? var(:app_path)
  }

  meet {
    sudo "mkdir -p #{var(:app_path)}", :as => var(:username)
    in_dir var(:app_path) do
      ["git init", "sed -i'' -e 's/master/#{var(:deploy_branch)}/' .git/HEAD",
       "git config --bool receive.denyNonFastForwards false",
       "git config receive.denyCurrentBranch ignore"].each { |cmd| sudo cmd, :as => var(:username) }
    end
  }
end

dep 'git deploy hooks' do
  met? { 
    File.exists?("#{var(:app_path)}/.git/hooks/post-recieve")
    File.exists?("#{var(:app_path)}/.git/hooks/post-reset")
  }

  meet {
   %w[post-reset post-receive].each do |hook_name|
      render_erb "rack_app/#{hook_name}", :to => "#{var(:app_path)}/.git/hooks/#{hook_name}", :sudo => true
      sudo "chmod +x #{var(:app_path)}/.git/hooks/#{hook_name}"
    end
    sudo "chown -R #{var(:username)} #{var(:app_path)}"
  }
end
