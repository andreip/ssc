module SSC
  module DirectoryManager

    def self.included(base)
      base.extend ClassMethods
      base.send :include, InstanceMethods
      def included(base)
      end
    end

    module ClassMethods
      def create_appliance_directory(appliance_dir, username, password, appliance_id)
        FileUtils.mkdir_p(appliance_dir)
        FileUtils.mkdir_p(File.join(appliance_dir, 'files'))
        FileUtils.touch(File.join(appliance_dir, 'repositories'))
        FileUtils.touch(File.join(appliance_dir, 'software'))
        File.open(File.join(appliance_dir, '.sscrc'), 'w') do |file|
          file.write("username: #{username}\n"+
                     "password: #{password}\n"+
                     "appliance_id: #{appliance_id}")
        end
        File.join(Dir.pwd, appliance_dir)
      end

      def manage(local_source)
        self.class_variable_set('@@appliance_directory', Dir.pwd)
        if appliance_directory_valid?(Dir.pwd)
          file= File.join(Dir.pwd, local_source)
          self.class_variable_set('@@local_source', file) if File.exist?(file)
        end
      end

      private

      def appliance_directory_valid?(dir)
        config_file= File.join(dir, '.sscrc')
        File.exist?(config_file) && File.read(config_file).match(/appliance_id:\ *\d+/)
      end

    end

    module InstanceMethods

      def save(data)
        return false if data.nil? || data == []
        source= self.class.class_variable_get('@@local_source')
        if source
          File.open(source, 'a') do |f|
            f.write(data.join("\n"))
          end
        end
        data
      end

      def read
        source= self.class.class_variable_get('@@local_source')
        File.readlines(source).collect{|i| i.strip} if source
      end

      private

      def local_empty?
        File.read(self.class.class_variable_get('@@local_source')).strip == ""
      end

    end
  end
end