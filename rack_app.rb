dep 'rack app' do
  requires 'postgres passworded access', 'existing postgres db', 'webapp', 'git deploy repo', 'git deploy hooks'
  setup {
    define_var :app_path, :default => "/home/#{var(:username)}/sites/#{var(:domain)}"
    define_var :deploy_branch, :default => 'master'
    set :vhost_type, 'passenger'
  }
end

dep 'git deploy repo' do
  requires 'git'

  met? {
    git_repo? var(:app_path)
  }

  meet {
    in_dir var(:app_path), :create => true do
      shell "git init"
      shell "sed -i'' -e 's/master/#{var(:deploy_branch)}/' .git/HEAD" unless var(:deploy_branch) == 'master'
      shell "git config --bool receive.denyNonFastForwards false"
      shell "git config receive.denyCurrentBranch ignore"
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
      render_erb "rack_app/#{hook_name}", :to => "#{var(:app_path)}/.git/hooks/#{hook_name}"
      shell "chmod +x #{var(:app_path)}/.git/hooks/#{hook_name}"
    end
  }
end
