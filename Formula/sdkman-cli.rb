class SdkmanCli < Formula
  desc "SDKMAN! the Software Development Kit Manager"
  homepage "https://sdkman.io"
  url "https://github.com/sdkman/sdkman-cli/releases/download/5.18.2/sdkman-cli-5.18.2.zip"
  sha256 "e98d0d0501e8b8d2749a601b5dc23344ed5ad67c99beb0f4d968c2e186b4ee71"
  license "Apache-2.0"

  resource "sdkman_cli_native" do
    on_intel do
      url "https://github.com/sdkman/sdkman-cli-native/releases/download/v0.4.6/sdkman-cli-native-0.4.6-x86_64-apple-darwin.zip"
      sha256 "3927da764a7e70bd0f53031938cfd43fe84b613da028560b9ea05dec28dbde31"
    end
    on_arm do
      url "https://github.com/sdkman/sdkman-cli-native/releases/download/v0.4.6/sdkman-cli-native-0.4.6-aarch64-apple-darwin.zip"
      sha256 "c9f67a5ad65944a9563ff9df99dfae6fedec0814c062136178ad9dfff92734f9"
    end
  end

  def install
    libexec.install Dir["*"]

    %w[tmp ext etc var candidates].each { |dir| mkdir libexec/dir }

    system "curl", "-s", "https://api.sdkman.io/2/candidates/all", "-o", libexec/"var/candidates"

    (libexec/"etc/config").write <<~EOS
      sdkman_auto_answer=false
      sdkman_auto_complete=true
      sdkman_auto_env=false
      sdkman_beta_channel=false
      sdkman_colour_enable=true
      sdkman_curl_connect_timeout=7
      sdkman_curl_max_time=10
      sdkman_debug_mode=false
      sdkman_insecure_ssl=false
      sdkman_rosetta2_compatible=false
      sdkman_selfupdate_feature=false
    EOS

    (libexec/"var/version").write version
    (libexec/"var/version_native").write resource("sdkman_cli_native").version

    on_intel do
      (libexec/"var/platform").write "darwinx64"
    end
    on_arm do
      (libexec/"var/platform").write "darwinarm64"
    end

    libexec.install resource("sdkman_cli_native") 
  end

  test do
    assert_match /SDKMAN!\nscript: #{version}\nnative: #{resource("sdkman_cli_native").version}/, shell_output("export SDKMAN_DIR=#{libexec} && source #{libexec}/bin/sdkman-init.sh && sdk version")
  end
end
