require 'xclisten'

class XCListen

  describe XCListen do

    class ShellTask
      def run(args)
        @command = args
      end
    end

    before(:all) do
      @base_dir = Dir.pwd
    end

    after(:each) do
      Dir.chdir(@base_dir)
    end

    context "Devices" do
      let(:devices) { XCListen::IOS_DEVICES }

      it "has ALL of them" do
        devices['iphone6_plus'].should == 'iPhone 6 Plus'
        devices['iphone6'].should == 'iPhone 6'
        devices['iphone5s'].should == 'iPhone 5s'
        devices['iphone5'].should == 'iPhone 5'
        devices['iphone4s'].should == 'iPhone 4s'
        devices['ipad2'].should == 'iPad 2'
        devices['ipad_retina'].should == 'iPad Retina'
        devices['ipad_air'].should == 'iPad Air'
      end
    end

    context "Defaults" do

      before(:each) do
        Dir.chdir('fixtures/ObjectiveRecord')
        @xclisten = XCListen.new
      end

      it "runs runs tests on iPhone 5s by default" do
        @xclisten.device.should == 'iPhone 5s'
      end

      it "uses the project name as the default scheme" do
        @xclisten.scheme.should == 'SampleProject'
      end

      it "uses the first found workspace by default" do
        @xclisten.workspace.should == 'Example/SampleProject.xcworkspace'
      end

      it "uses iphonesimulator sdk by default" do
        @xclisten.sdk.should == 'iphonesimulator'
      end

      it "listens to the closest workspace instead of alphabetically" do
        Dir.chdir("#{@base_dir}/fixtures/MadeUpProject")
        XCListen.new.workspace.should == 'MadeUpProject.xcworkspace'
      end

    end

    it "initializes with device" do
      xclisten = XCListen.new(:device => 'iphone5')
      xclisten.device.should == 'iPhone 5'
    end

    it "initializes with a different workspace" do
      xclisten = XCListen.new(:workspace => 'Example/Sample.xcworkspace')
      xclisten.workspace.should == 'Example/Sample.xcworkspace'
    end

    it "initializes with a different scheme" do
      xclisten = XCListen.new(:scheme => 'AnotherScheme')
      xclisten.scheme.should == 'AnotherScheme'
    end

    it 'initializes with SDK' do
      xclisten = XCListen.new(:sdk => 'iphonesimulator')
      xclisten.sdk.should == 'iphonesimulator'
    end

    it 'uses xcodebuild with given flags' do
      flags = {
        :workspace => 'Example/Sample.xcworkspace',
        :scheme => 'kif',
        :sdk => 'iphoneos',
        :device => 'name=iPhone 5s'
      }
      xclisten = XCListen.new(flags)
      xclisten.xcodebuild.should == "xcodebuild -workspace #{flags[:workspace]} -scheme #{flags[:scheme]} -sdk #{flags[:sdk]} -destination '#{flags[:device]}'"
    end

    it "doesn't specify destination for OSX" do
      xclisten = XCListen.new(:sdk => 'macosx')
      xclisten.xcodebuild.should_not include('-destination')
    end

    it "knows if it can run" do
      Dir.stub(:glob).and_return([""])
      xclisten = XCListen.new
      xclisten.can_run?.should be_falsey
    end

    context "finding the right workspace" do

      it "works with one level deep workspace" do
        Dir.chdir('fixtures/ObjectiveRecord')
        XCListen.new.workspace.should == 'Example/SampleProject.xcworkspace'
      end

      it "works with xcworkspace in the same directory" do
        Dir.chdir('fixtures/AFNetworking')
        XCListen.new.workspace.should == 'AFNetworking.xcworkspace'
      end
    end
  end

end
