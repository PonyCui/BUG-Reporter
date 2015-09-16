
Pod::Spec.new do |s|

  s.name         = "BUG-Reporter"
  s.version      = "0.0.1"
  s.summary      = "The best way to deliver iOS App issue to worktile.com"

  s.description  = <<-DESC
                   这是一个基于Worktile API开发的iOS应用BUG提交SDK。
                   使用此SDK，测试人员可以快捷地在手机上提交BUG至worktile中，每一个BUG的提交过程不超过1分钟。
                   DESC

  s.homepage     = "https://github.com/PonyCui/BUG-Reporter"

  s.license      = "MIT"

  s.author             = { "ponycui" => "" }
  s.platform     = :ios, "7.0"

  s.source       = { :git => "https://github.com/PonyCui/BUG-Reporter.git"}

  s.source_files  = "Source"
  s.requires_arc = true

end
