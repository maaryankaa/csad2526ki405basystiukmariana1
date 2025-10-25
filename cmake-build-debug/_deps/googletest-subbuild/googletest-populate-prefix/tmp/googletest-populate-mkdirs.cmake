# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION 3.5)

file(MAKE_DIRECTORY
  "/Users/mac/csad2526ki405basystiukmariana1/cmake-build-debug/_deps/googletest-src"
  "/Users/mac/csad2526ki405basystiukmariana1/cmake-build-debug/_deps/googletest-build"
  "/Users/mac/csad2526ki405basystiukmariana1/cmake-build-debug/_deps/googletest-subbuild/googletest-populate-prefix"
  "/Users/mac/csad2526ki405basystiukmariana1/cmake-build-debug/_deps/googletest-subbuild/googletest-populate-prefix/tmp"
  "/Users/mac/csad2526ki405basystiukmariana1/cmake-build-debug/_deps/googletest-subbuild/googletest-populate-prefix/src/googletest-populate-stamp"
  "/Users/mac/csad2526ki405basystiukmariana1/cmake-build-debug/_deps/googletest-subbuild/googletest-populate-prefix/src"
  "/Users/mac/csad2526ki405basystiukmariana1/cmake-build-debug/_deps/googletest-subbuild/googletest-populate-prefix/src/googletest-populate-stamp"
)

set(configSubDirs )
foreach(subDir IN LISTS configSubDirs)
    file(MAKE_DIRECTORY "/Users/mac/csad2526ki405basystiukmariana1/cmake-build-debug/_deps/googletest-subbuild/googletest-populate-prefix/src/googletest-populate-stamp/${subDir}")
endforeach()
