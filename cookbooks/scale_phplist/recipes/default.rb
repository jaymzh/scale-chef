#
# Cookbook Name:: scale_phplist
# Recipe:: default
#

if node.centos8?
  relpath = File.join(Chef::Config['file_cache_path'], 'remi-release-8.rpm')
  remote_file relpath do
    source 'https://rpms.remirepo.net/enterprise/remi-release-8.rpm'
    owner 'root'
    group 'root'
    mode '0644'
    action :create
  end

  package 'remi-release-8' do
    source relpath
    action :install
  end

  # for php-imap
  node.default['fb_dnf']['modules']['php'] = {
    'enable' => true,
    'stream' => 'remi-7.2',
  }
end

pkgs = %w{
  php
  php-mysqlnd
  php-imap
}

package pkgs do
  action :upgrade
  notifies :restart, 'service[apache]'
end

remote_file 'fetch phplist tarball' do
  not_if do
    File.directory?("/usr/local/phplist-#{node['scale_phplist']['version']}")
  end
  source lazy {
    "https://s3.amazonaws.com/scale-packages/phplist-#{node['scale_phplist']['version']}.tgz"
  }
  path lazy { 
    "#{Chef::Config['file_cache_path']}/phplist-#{node['scale_phplist']['version']}.tgz" 
  }
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

execute 'extract phplist tarball' do
  command lazy {
    "tar xf #{Chef::Config['file_cache_path']}/phplist-#{node['scale_phplist']['version']}.tgz -C /usr/local/ --owner=root --group=apache"
  }
  creates lazy { "/usr/local/phplist-#{node['scale_phplist']['version']}" }
end

template 'config.php' do
  path lazy { 
    "/usr/local/phplist-#{node['scale_phplist']['version']}/public_html/lists/config/config.php" 
  }
  owner 'root'
  group 'apache'
  mode '0640'
end

link '/var/www/html/lists' do
  to lazy {
    "/usr/local/phplist-#{node['scale_phplist']['version']}/public_html/lists" 
  }
end
