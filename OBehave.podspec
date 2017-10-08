#
#  Be sure to run `pod spec lint OBehave.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "OBehave"
  s.version      = "0.0.1"
  s.summary      = "A collection of drag and drop view controller behaviors"

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description  = <<-DESC
  A collection of drag and drop view controller behaviors

  A behavior is a unit of code that does a single job that may be reused in multiple areas of a project or projects.

  Using composition, view controllers are given ownership of a behavior in Interface Builder (or the storyboard).
  Composition is favoured over inheriting functionality from a base view controller for the following reasons:

    1.  Behaviors can be re-used across multiple projects
    1.  A base view controller with lots of code that may be used by some
        but not all subclassed view controllers is poor design.
    1.  Using behaviors provides true separation of concerns.
    1.  View controllers are reduced in size

  See http://www.objc.io/issue-13/behaviors.html for details.
                   DESC

  s.homepage     = "https://github.com/warren-gavin/OBehave"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Apokrupto" => "warren@apokrupto.com" }
  s.platform     = :ios, "10.0"
  s.source       = { :git => "https://github.com/warren-gavin/OBehave.git", :tag => s.version }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  CocoaPods is smart about how it includes source code. For source files
  #  giving a folder will include any swift, h, m, mm, c & cpp files.
  #  For header files it will include any header in the folder.
  #  Not including the public_header_files will make all headers public.
  #

  s.source_files  = "#{s.name}/**/*.swift"
  s.exclude_files = "#{s.name}/Classes/FutureWork"

end
