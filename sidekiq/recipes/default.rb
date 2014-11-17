#
# Cookbook Name:: sidekiq
# Recipe:: default
#

node[:deploy].each do |application, deploy|
  process_name = "sidekiq_#{application}"

  template "/etc/monit/conf.d/#{process_name}.monitrc" do
    source "monitrc.conf.erb"
    owner 'root'
    group 'root'
    mode 0644
    variables(
      :env => deploy[:rails_env],
      :path => deploy[:deploy_to],
      :user => deploy[:user],
      :group => deploy[:group],
      :process_name => process_name
    )
  end

  execute "ensure-sidekiq-is-setup-with-monit" do
    command %Q{
      monit reload
    }
  end

  execute "restart-sidekiq" do
    command %Q{
      echo "sleep 20 && monit -g #{process_name} restart all" | at now
    }
  end
end
