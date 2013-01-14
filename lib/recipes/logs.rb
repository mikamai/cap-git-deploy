namespace :logs do
  desc "app current stage log files"
  task :tail_app, :roles => :app do
    trap('INT') { puts 'Interupted'; exit 0; }
    run "tail -F #{current_path}/log/#{stage}.log" do |channel, stream, data|
      puts  # for an extra line break before the host name
      puts "#{channel[:host]}: #{data}"
      break if stream == :err
    end
  end

  task :default, :roles => :app do
    tail_app
  end
end