
class Contentninja < Formula
  homepage "http://contentninja.services"
  url "https://github.com/contentninjaservices/contentninja/archive/master.zip"
  version "0.8.5"
  sha256 "7a3d1a931636419414502108253537f7516cb22e1c66b966ec2d55b933cb4fdf"


  def install
    system "make install" # if this fails, try separate make/make install steps
  end

  test do
    system "false"
  end
end
