$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

module ShinagawaSeaside
  VERSION = '0.0.2'

  def ShinagawaSeaside::set_tasks(ttdb, opts)
    ttdb = ttdb.map{|db|
      h = Hash.new
      db.keys.each{|k|
        h[k.to_sym] = db[k]
      }
      h
    }.map{|db|
      name = db[:name]
      port = db[:port].to_i
      basedir = opts[:basedir]
      {
        :cmd => 'ttserver',
        :basedir => basedir,
        :name => name,
        :port => port,
        :pidfile => "#{basedir}/#{name}.pid",
        :dbname => "#{basedir}/#{name}.tch#bnum=1000000"
      }
    }

    desc 'start TokyoTyrant server'
    task 'ttstart' do
      puts 'starting TokyoTyrant servers..'
      for tt in ttdb do
        Dir.mkdir(tt[:basedir]) if !File.exists?(tt[:basedir])
        puts ''
        puts "name=>#{tt[:name]}, port=>#{tt[:port]}, pid=>#{tt[:pidfile]}"
        if File.exists?(tt[:pidfile])
          pid = open(tt[:pidfile]).read
          puts "existing process - pid:#{pid}"
        else
          system("#{tt[:cmd]} -port #{tt[:port]} -dmn -pid #{tt[:pidfile]} #{tt[:dbname]}")
          puts 'done'
        end
      end
    end
    
    desc 'stop TokyoTyrant server'
    task 'ttstop' do
      puts 'stopping TokyoTyrant servers..'
      for tt in ttdb do
        if File.exists?(tt[:pidfile])
          pid = open(tt[:pidfile]).read
          puts ''
          puts "name=>#{tt[:name]}, port=>#{tt[:port]}, pid=>#{pid}"
          system("kill -TERM #{pid}")
          count = 0
          loop do
            sleep 0.1
            if !File.exists?(tt[:pidfile])
              puts 'done'
              break
            end
            if (count+=1) > 100
              puts "hanging process - pid:#{pid}"
              break
            end
          end
        else
          puts 'no process found'
        end
      end
    end
    
    desc 'restart TokyoTyrant server'
    task 'ttrestart' => ['ttstop', 'ttstart']
    
  end

end
