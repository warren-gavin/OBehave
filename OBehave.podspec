Pod::Spec.new do |s|

  s.name          = "OBehave"
  s.version       = "0.0.18"
  s.summary       = "A collection of drag and drop view controller behaviors"
  s.homepage      = "https://github.com/warren-gavin/OBehave"
  s.license       = { :type => "MIT", :file => "LICENSE" }
  s.author        = { "Apokrupto" => "warren@apokrupto.com" }
  s.platform      = :ios, "10.0"
  s.source        = { :git => "https://github.com/warren-gavin/OBehave.git", :tag => s.version }
  s.source_files  = "#{s.name}/**/*.swift"
  s.description   = <<-DESC
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

  # Subspecs

  s.subspec 'Actions' do |actions|
    actions.subspec 'OpenSettings' do |opensettings|
      opensettings.source_files = 'OBehave/Classes/Actions/OpenSettings'
    end
    actions.subspec 'PhoneCall' do |phonecall|
      phonecall.source_files = 'OBehave/Classes/Actions/PhoneCall'
    end
    actions.subspec 'SendMail' do |sendmail|
      sendmail.source_files = 'OBehave/Classes/Actions/SendMail'
    end
  end

  s.subspec 'Animations' do |animations|
    animations.source_files = 'OBehave/Classes/Animations'
    animations.subspec 'OverlayView' do |overlayview|
      overlayview.source_files = 'OBehave/Classes/Animations/OverlayView'
    end
    animations.subspec 'ResizeView' do |resizeview|
      resizeview.source_files = 'OBehave/Classes/Animations/ResizeView'
    end
    animations.subspec 'RotateView' do |rotateview|
      rotateview.source_files = 'OBehave/Classes/Animations/RotateView'
    end
    animations.subspec 'SlideIn' do |slidein|
      slidein.source_files = 'OBehave/Classes/Animations/SlideIn'
    end
  end

  s.subspec 'Effects' do |effects|
    effects.subspec 'BlurImage' do |blurimage|
      blurimage.source_files = 'OBehave/Classes/Effects/BlurImage'
    end
    effects.subspec 'TintImage' do |tintimage|
      tintimage.source_files = 'OBehave/Classes/Effects/TintImage'
    end
  end

  s.subspec 'Images' do |images|
    images.subspec 'KenBurns' do |kenburns|
      kenburns.source_files = 'OBehave/Classes/Images/KenBurns'
    end
    images.subspec 'Parallax' do |parallax|
      parallax.source_files = 'OBehave/Classes/Images/Parallax'
    end
    images.subspec 'Picker' do |picker|
      picker.source_files = 'OBehave/Classes/Images/Picker'
    end
    images.subspec 'SaveImage' do |saveimage|
      saveimage.source_files = 'OBehave/Classes/Images/SaveImage'
    end
  end

  s.subspec 'Keyboard' do |keyboard|
    keyboard.source_files = 'OBehave/Classes/Keyboard'
    keyboard.subspec 'Anchored' do |anchored|
      anchored.source_files = 'OBehave/Classes/Keyboard/Anchored'
    end
    keyboard.subspec 'Dynamic' do |dynamic|
      dynamic.source_files = 'OBehave/Classes/Keyboard/Dynamic'
    end
    keyboard.subspec 'Fixed' do |fixed|
      fixed.source_files = 'OBehave/Classes/Keyboard/Fixed'
    end
  end

  s.subspec 'Tables' do |tables|
    tables.subspec 'EmptyState' do |emptystate|
      emptystate.source_files = 'OBehave/Classes/Tables/EmptyState'
    end
    tables.subspec 'ParallaxHeader' do |parallaxheader|
      parallaxheader.source_files = 'OBehave/Classes/Tables/ParallaxHeader'
    end
    tables.subspec 'StretchyHeader' do |stretchyheader|
      stretchyheader.source_files = 'OBehave/Classes/Tables/StretchyHeader'
    end
  end

  s.subspec 'Tools' do |tools|
    tools.subspec 'BarCodeScanner' do |barcodescanner|
      barcodescanner.source_files = 'OBehave/Classes/Tools/BarCodeScanner'
    end
    tools.subspec 'ChangeLocalization' do |changelocalization|
      changelocalization.source_files = 'OBehave/Classes/Tools/ChangeLocalization'
    end
  end

  s.subspec 'ViewController' do |viewcontroller|
    viewcontroller.subspec 'Layout' do |layout|
      layout.source_files = 'OBehave/Classes/ViewController/Layout'
    end
    viewcontroller.subspec 'Lifecycle' do |lifecycle|
      lifecycle.source_files = 'OBehave/Classes/ViewController/Lifecycle'
    end
    viewcontroller.subspec 'Paging' do |paging|
      paging.source_files = 'OBehave/Classes/ViewController/Paging'
    end
    viewcontroller.subspec 'Transition' do |transition|
      transition.source_files = 'OBehave/Classes/ViewController/Transition'
      transition.subspec 'Inset' do |inset|
        inset.source_files = 'OBehave/Classes/ViewController/Transition/Inset'
        inset.subspec 'BlurredBackground' do |blurredbackground|
          blurredbackground.source_files = 'OBehave/Classes/ViewController/Transition/Inset/BlurredBackground'
        end
        inset.subspec 'DimmedBackground' do |dimmedbackground|
          dimmedbackground.source_files = 'OBehave/Classes/ViewController/Transition/Inset/DimmedBackground'
        end
      end
      transition.subspec 'Shutter' do |shutter|
        shutter.source_files = 'OBehave/Classes/ViewController/Transition/Shutter'
      end
      transition.subspec 'Slide' do |slide|
        slide.source_files = 'OBehave/Classes/ViewController/Transition/Slide'
      end
    end
  end

end
