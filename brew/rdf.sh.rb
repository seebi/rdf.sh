class RdfSh < Formula
  desc "multi-tool shell script for doing Semantic Web jobs on the command-line"
  homepage "https://github.com/seebi/rdf.sh"
  url "https://github.com/seebi/rdf.sh/archive/v0.8.0.tar.gz"
  sha256 "e66b677d82ad93d6d05a348ac13cb4e604db590392ae785e9eae84668c963218"
  head "https://github.com/seebi/rdf.sh.git"

  depends_on "raptor"
  depends_on "rasqal"
  depends_on "curl"

  def install
    bin.install("rdf" => "rdf")
    man1.install("rdf.1")
    zsh_completion.install "_rdf"
  end

  test do
    system "rdf"
  end
end
