class Libkml < Formula
  desc "Library to parse, generate and operate on KML"
  homepage "https://github.com/libkml/libkml"
  url "https://github.com/libkml/libkml/archive/refs/tags/1.3.0.tar.gz"
  sha256 "8892439e5570091965aaffe30b08631fdf7ca7f81f6495b4648f0950d7ea7963"
  license "BSD-3-Clause"

  bottle do
    sha256 cellar: :any, monterey: "ab3d12d8e52bd4cf60b4862b58b924b5556338e272335ca205e814803298a968"
  end

  depends_on "cmake" => :build

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.cc").write <<~EOS
      #include <iostream>
      #include <string>
      #include <cassert>
      #include "kml/dom.h"  // The KML DOM header.

      int main() {
        // Parse KML from a memory buffer.
        std::string errors;
        kmldom::ElementPtr element = kmldom::Parse(
          "<kml>"
            "<Placemark>"
              "<name>hi</name>"
              "<Point>"
                "<coordinates>1,2,3</coordinates>"
              "</Point>"
            "</Placemark>"
          "</kml>",
          &errors);

        // Convert the type of the root element of the parse.
        const kmldom::KmlPtr kml = kmldom::AsKml(element);
        const kmldom::PlacemarkPtr placemark =
          kmldom::AsPlacemark(kml->get_feature());

        // Access the value of the <name> element.
        std::cout << "The Placemark name is: " << placemark->get_name()
          << std::endl;
        assert(placemark->get_name() == "hi");
      }
    EOS
    system ENV.cxx, "test.cc", "-std=c++14", "-I#{include}", "-L#{lib}", "-lkmldom", \
      "-lkmlbase", "-o", "test"
    system "./test"
  end
end
