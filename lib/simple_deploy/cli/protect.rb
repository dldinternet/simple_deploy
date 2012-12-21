
require 'trollop'

module SimpleDeploy
  module CLI

    class Protect
      include Shared

      def protect
        @opts = Trollop::options do
          version SimpleDeploy::VERSION
          banner <<-EOS

Protect/Unprotect one or more stacks.

simple_deploy protect -n STACK_NAME1 -n STACK_NAME2 -e ENVIRONMENT -p on_off

EOS
          opt :help, "Display Help"
          opt :environment, "Set the target environment", :type => :string
          opt :protection, "Enable/Disable protection using on/off", :type  => :string
          opt :log_level, "Log level:  debug, info, warn, error", :type    => :string,
                                                                  :default => 'info'
          opt :name, "Stack name(s) of stacks to protect", :type => :string,
                                                           :multi => true
        end

        CLI::Shared.valid_options? :provided => @opts,
                                   :required => [:environment, :name]

        config = Config.new.environment @opts[:environment]

        @opts[:name].each do |name|
          stack = Stack.new :environment => @opts[:environment],
                            :name        => name,
                            :config      => config,
                            :logger      => logger
          rescue_stackster_exceptions_and_exit do
            stack.update :attributes => [{ 'protection' => @opts[:protection] }]
          end
        end
      end

      def logger
        @logger ||= SimpleDeployLogger.new :log_level => @opts[:log_level]
      end

      def command_summary
        'Protect/Unprotect one or more stacks'
      end

    end

  end
end
