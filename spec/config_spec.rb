require 'spec_helper'

describe SimpleDeploy do
  let(:config_data) do
    { 'environments' => {
        'test_env' => {
          'secret_key' => 'secret',
          'access_key' => 'access',
          'region'     => 'us-west-1'
      } },
      'notifications' => {
        'campfire' => {
          'token' => 'my_token'
      } } }
  end

  describe 'new' do
    it 'should accept config data as an argument' do
      YAML.should_not_receive(:load)

      @config = SimpleDeploy::Config.new :config => config_data
      @config.config.should == config_data
    end

    it 'should load the config from ~/.simple_deploy.yml by default' do
      File.should_receive(:open).with("#{ENV['HOME']}/.simple_deploy.yml").
                                 and_return(config_data.to_yaml)
      @config = SimpleDeploy::Config.new
      @config.config.should == config_data
    end

    it 'should load the config from SIMPLE_DEPLOY_CONFIG_FILE if supplied' do
      File.should_receive(:open).with("/my/config/file").
                                 and_return(config_data.to_yaml)
      env_mock = mock 'env'
      SimpleDeploy::Env.stub :new => env_mock
      env_mock.should_receive(:load).
               with('SIMPLE_DEPLOY_CONFIG_FILE').
               and_return "/my/config/file"
      @config = SimpleDeploy::Config.new
      @config.config.should == config_data
    end

  end

  describe "after creating a configuration" do
    before do
      @config = SimpleDeploy::Config.new :config => config_data
    end

    it "should return the default artifacts to deploy" do
      @config.artifacts.should == ['chef_repo', 'cookbooks', 'app']
    end

    it "should return the APP_URL for app" do
      @config.artifact_deploy_variable('app').should == 'APP_URL'
    end

    it "should return the Cloud Formation camel case variables" do
      @config.artifact_cloud_formation_url('app').should == 'AppArtifactURL'
    end

    it "should return the environment requested" do
      env_config = @config.environment 'test_env'
      env_config.access_key.should == 'access'
      env_config.secret_key.should == 'secret'
      env_config.region.should == 'us-west-1'
    end

    it "should return the notifications available" do
      @config.notifications.should == ( { 'campfire' => { 'token' => 'my_token' } } )
    end

    it "should return the access_key for the environment" do
      @config.access_key('test_env').should == 'access'
    end

    it "should return the secret_key for the environment" do
      @config.secret_key('test_env').should == 'secret'
    end

    it "should return the region for the environment" do
      @config.region('test_env').should == 'us-west-1'
    end

    it "should return the deploy script" do
      @config.deploy_script.should == '/opt/intu/admin/bin/configure.sh'
    end

  end

  describe "gracefully handling yaml file errors" do
    before do
      FakeFS.activate!
      @config_file_path = "#{ENV['HOME']}/.simple_deploy.yml"
      FileUtils.mkdir_p File.dirname(@config_file_path)
    end

    after do
      FakeFS.deactivate!
      FakeFS::FileSystem.clear
    end

    it "should handle a missing file gracefully" do
      expect {
        config = SimpleDeploy::Config.new
      }.to raise_error(RuntimeError, "#{@config_file_path} not found")
    end

    it "should handle a corrupt file gracefully" do
      s = "---\nport: | 80"
      File.open(@config_file_path, 'w') do |out|
        out.write(s)
      end

      expect {
        config = SimpleDeploy::Config.new
      }.to raise_error(RuntimeError, "#{@config_file_path} is corrupt")
    end
  end
end
