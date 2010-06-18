pkg 'readline headers' do
  installs { via :apt, 'libreadline5-dev' }
  provides []
end

dep 'ree path' do
  define_var(:ree_prefix, :default => '/opt/ruby-enterprise')
  met? { shell("grep #{var(:ree_prefix)} /etc/environment") }
  meet { 
    sudo("sed -ri 's|=\"|=\"#{var(:ree_prefix)}/bin:|' /etc/environment")
    shell('source /etc/environment')
  }
end

src 'ree installed' do
  requires 'libssl headers', 'readline headers', 'ree path'

  merge :versions, {:ree => '1.8.7-2010.02'}
  define_var(:ree_prefix, :default => '/opt/ruby-enterprise')
  source "http://rubyforge.org/frs/download.php/71096/ruby-enterprise-1.8.7-2010.02.tar.gz"

  configure { true }
  build { true }
  install { log_shell 'Installing', "./installer --auto=#{var(:ree_prefix)}", :sudo => Babushka::GemHelper.should_sudo? }

  met? {
    ree_version_exe = var(:ree_prefix) / 'bin/ree-version'
    if !File.executable?(ree_version_exe)
      unmet "ree isn't installed"
    else
      installed_version = shell(ree_version_exe).split(' ')[-1]
      if installed_version != var(:versions)[:ree]
        unmet "an outdated version of ree is installed (#{installed_version})"
      else
        met "ree-#{installed_version} is installed"
      end
    end
  }
end
