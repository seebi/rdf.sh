require 'formula'

class RdfSh < Formula
  desc 'A multi-tool shell script for doing Semantic Web jobs on the command line'
  homepage 'https://github.com/seebi/rdf.sh'
  url 'https://github.com/seebi/rdf.sh/archive/v0.7.0.tar.gz'
  head 'https://github.com/seebi/rdf.sh.git'
  version '0.7.0'
  sha256 '3210042265082092540e698202f6aa1a7dadefff97924c23ea9e2da18a8fa94b'

  depends_on 'raptor'
  depends_on 'rasqal'
  depends_on 'curl'

  def install
    bin.install('rdf' => 'rdf')
    man1.install('rdf.1')
    zsh_completion.install '_rdf'
  end

  def test
    system "rdf"
  end
end
