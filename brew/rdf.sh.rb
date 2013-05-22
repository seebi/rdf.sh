require 'formula'

class RdfSh < Formula
  homepage 'https://github.com/seebi/rdf.sh'
  url 'https://github.com/seebi/rdf.sh/archive/v0.6.tar.gz'
  version '0.6'
  sha1 'c47ae7b72850808cc2811a2389c04a7c335f1509'

  depends_on 'raptor'
  depends_on 'rasqal'
  depends_on 'curl'

  def install
    bin.install('rdf' => 'rdf')
    man1.install('rdf.1')
    # todo: how to install zsh autocompletion?
  end

  def test
    system "rdf"
  end
end
