# vim: syntax=ruby:expandtab:shiftwidth=2:softtabstop=2:tabstop=2
#
# Cookbook Name:: fb_iptables
# Recipe:: packages
#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# firewalld/ufw conflicts with direct iptables management
conflicting_package = value_for_platform(
  'ubuntu' => { :default => 'ufw' },
  :default => 'firewalld',
)

service conflicting_package do
  only_if { node['fb_iptables']['manage_packages'] }
  action [:stop, :disable]
end

package conflicting_package do
  only_if { node['fb_iptables']['manage_packages'] }
  options '--exclude kernel*' if node.fedora?
  action :remove
end

package 'iptables packages' do
  only_if do
    node['fb_iptables']['manage_packages'] && !node['fb_iptables']['use_nft'] }
  end
  package_name lazy { FB::IPTables.packages(node) }
  action :upgrade
  notifies :run, 'execute[reload iptables]'
  notifies :run, 'execute[reload ip6tables]'
end

package 'nftables' do
  only_if do
    node['fb_iptables']['manage_packages'] && node['fb_iptables']['use_nft'] }
  end
  action :upgrade
  notifies :run, 'execute[reload nftables]'
end

# These aren't packages or package related, but I believe they are
# here so that packages.rb can be self-contained.
execute 'reload iptables' do
  only_if { node['fb_iptables']['enable'] && !node['fb_iptables']['use_nft'] }
  command '/usr/sbin/fb_iptables_reload 4 reload'
  action :nothing
  subscribes :run, 'package[osquery]'
end

execute 'reload ip6tables' do
  only_if { node['fb_iptables']['enable'] && !node['fb_iptables']['use_nft'] }
  command '/usr/sbin/fb_iptables_reload 6 reload'
  action :nothing
end

execute 'reload nftables' do
  only_if { node['fb_iptables']['enable'] && node['fb_iptables']['use_nft'] }
  command '/usr/sbin/fb_iptables_reload nft reload'
  action :nothing
end
