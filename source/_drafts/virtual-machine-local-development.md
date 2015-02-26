real    18m6.106s
user    6m16.388s
sys     1m42.354s

193 examples, 0 failures, 2 pending
15 examples, 0 failures
181 examples, 0 failures, 1 pending
174 examples, 0 failures
5 examples, 0 failures
8 examples, 0 failures
94 examples, 0 failures
29 examples, 0 failures
17 examples, 0 failures


🍕  Testing domain logic
............................................................................................*........................................................................................

Pending:
  DomainLogic::AdInjector with a text of more characters than the character limit should not inject the ad inside markup
    # No reason given
    # ./spec/models/domain_logic/ad_injector_spec.rb:47

Finished in 1.22 seconds (files took 4.75 seconds to load)
181 examples, 0 failures, 1 pending

Randomized with seed 45870

🍺  Validating domain logic with code styleguide
warning: parser/current is loading parser/ruby21, which recognizes
warning: 2.1.5-compliant syntax, but you are running 2.1.0.
Inspecting 76 files
............................................................................

76 files inspected, no offenses detected
🏁

real    0m10.486s
user    0m4.859s
sys     0m0.945s


On VM:

🍕  Testing domain logic
.......*.............................................................................................................................................................................

Pending:
  DomainLogic::AdInjector with a text of more characters than the character limit should not inject the ad inside markup
    # No reason given
    # ./spec/models/domain_logic/ad_injector_spec.rb:47

Finished in 1.77 seconds (files took 6.28 seconds to load)
181 examples, 0 failures, 1 pending

Randomized with seed 8742

🍺  Validating domain logic with code styleguide
warning: parser/current is loading parser/ruby21, which recognizes
warning: 2.1.5-compliant syntax, but you are running 2.1.0.
Inspecting 76 files
............................................................................

76 files inspected, no offenses detected
🏁

real    0m13.572s
user    0m4.160s
sys     0m2.648s



Locally:

eteotti:~/code/xogrp/editorial-cms/components/public_ui (master) |$ time ./test.sh
>>> Testing public ui
.....................................................................................................................Viewport argument key "minimal-ui" not recognized and ignored.
tag manager
.........................................................

Finished in 22.63 seconds (files took 1.46 seconds to load)
174 examples, 0 failures

Randomized with seed 41001

[2015-02-26 09:44:37] INFO  WEBrick 1.3.1
[2015-02-26 09:44:37] INFO  ruby 2.1.0 (2013-12-25) [x86_64-darwin13.0]
[2015-02-26 09:44:37] INFO  WEBrick::HTTPServer#start: pid=19463 port=63040
Waiting for jasmine server on 63040...
jasmine server started.
..............

14 specs, 0 failures
[2015-02-26 09:44:38] INFO  going to shutdown ...
[2015-02-26 09:44:38] INFO  WEBrick::HTTPServer#start done.

real    0m28.565s
user    0m16.253s
sys     0m2.314s



on VM:

vagrant@weddit-devbox:/app/editorial-cms/components/public_ui$ time ./test.sh
>>> Testing public ui
.............................Viewport argument key "minimal-ui" not recognized and ignored.
.................................................................................................................................................

Finished in 26.08 seconds (files took 9.09 seconds to load)
174 examples, 0 failures

Randomized with seed 16903

Waiting for jasmine server on 54330...
Waiting for jasmine server on 54330...
Waiting for jasmine server on 54330...
Waiting for jasmine server on 54330...
[2015-02-26 15:45:09] INFO  WEBrick 1.3.1
[2015-02-26 15:45:09] INFO  ruby 2.1.0 (2013-12-25) [i686-linux]
[2015-02-26 15:45:09] INFO  WEBrick::HTTPServer#start: pid=9569 port=54330
Waiting for jasmine server on 54330...
jasmine server started.
..............

14 specs, 0 failures
[2015-02-26 15:45:11] INFO  going to shutdown ...
[2015-02-26 15:45:11] INFO  WEBrick::HTTPServer#start done.

real    0m44.963s
user    0m13.909s
sys     0m7.168s




on workstation:

^Ceteotti:~/code/xogrp/editorial-cms/components/public_ui (master) |$ time be rspec spec/features/display_piece/ads/article_footer_spec.rb:10
Run options: include {:locations=>{"./spec/features/display_piece/ads/article_footer_spec.rb"=>[10]}}
Viewport argument key "minimal-ui" not recognized and ignored.
.

Finished in 6.15 seconds (files took 1.28 seconds to load)
1 example, 0 failures

Randomized with seed 6375


real    0m8.177s
user    0m4.051s
sys     0m1.130s


on VM:

vagrant@weddit-devbox:/app/editorial-cms/components/public_ui$ time bundle exec rspec spec/features/display_piece/ads/article_footer_spec.rb:10
Run options: include {:locations=>{"./spec/features/display_piece/ads/article_footer_spec.rb"=>[10]}}
Viewport argument key "minimal-ui" not recognized and ignored.
tag manager
.

Finished in 5.63 seconds (files took 6.22 seconds to load)
1 example, 0 failures

Randomized with seed 3796


real    0m12.791s
user    0m2.096s
sys     0m3.220s


on workstation:

eteotti:~/code/xogrp/editorial-cms/components/admin_ui (master) |$ time bundle exec rspec --tag js
Run options: include {:js=>true}
.......DEPRECATION WARNING: Passing string argument to #within_window is deprecated. Pass window object or lambda. (called from /Users/eteotti/code/xogrp/editorial-cms/components/admin_ui/spec/features/visual_editor/preview_article_spec.rb:22)
Viewport argument key "minimal-ui" not recognized and ignored.
...............DEPRECATION WARNING: Passing string argument to #within_window is deprecated. Pass window object or lambda. (called from /Users/eteotti/code/xogrp/editorial-cms/components/admin_ui/spec/features/preview/article_mobile_spec.rb:26)
Viewport argument key "minimal-ui" not recognized and ignored.
tag manager
.....DEPRECATION WARNING: Passing string argument to #within_window is deprecated. Pass window object or lambda. (called from /Users/eteotti/code/xogrp/editorial-cms/components/admin_ui/spec/features/visual_editor/preview_article_mobile_spec.rb:27)
tag manager
.DEPRECATION WARNING: Passing string argument to #within_window is deprecated. Pass window object or lambda. (called from /Users/eteotti/code/xogrp/editorial-cms/components/admin_ui/spec/features/preview/article_spec.rb:23)
Viewport argument key "minimal-ui" not recognized and ignored.
tag manager
...........DEPRECATION WARNING: Passing string argument to #within_window is deprecated. Pass window object or lambda. (called from /Users/eteotti/code/xogrp/editorial-cms/components/admin_ui/spec/features/preview/slideshow_spec.rb:35)
Viewport argument key "minimal-ui" not recognized and ignored.
tag manager
...

Finished in 2 minutes 7.9 seconds (files took 2.63 seconds to load)
42 examples, 0 failures

Randomized with seed 56632


real    2m11.360s
user    1m21.181s
sys     0m8.886s


on VM:

vagrant@weddit-devbox:/app/editorial-cms/components/admin_ui$ time bundle exec rspec --tag js






Run options: include {:js=>true}
DEPRECATION WARNING: Passing string argument to #within_window is deprecated. Pass window object or lambda. (called from /app/editorial-cms/components/admin_ui/spec/features/visual_editor/preview_article_spec.rb:22)
Viewport argument key "minimal-ui" not recognized and ignored.
tag manager
.......DEPRECATION WARNING: Passing string argument to #within_window is deprecated. Pass window object or lambda. (called from /app/editorial-cms/components/admin_ui/spec/features/preview/article_spec.rb:23)
Viewport argument key "minimal-ui" not recognized and ignored.
tag manager
....DEPRECATION WARNING: Passing string argument to #within_window is deprecated. Pass window object or lambda. (called from /app/editorial-cms/components/admin_ui/spec/features/preview/article_mobile_spec.rb:26)
Viewport argument key "minimal-ui" not recognized and ignored.
tag manager
.........DEPRECATION WARNING: Passing string argument to #within_window is deprecated. Pass window object or lambda. (called from /app/editorial-cms/components/admin_ui/spec/features/preview/slideshow_spec.rb:35)
Viewport argument key "minimal-ui" not recognized and ignored.
tag manager
.....................DEPRECATION WARNING: Passing string argument to #within_window is deprecated. Pass window object or lambda. (called from /app/editorial-cms/components/admin_ui/spec/features/visual_editor/preview_article_mobile_spec.rb:27)
.

Finished in 1 minute 35.38 seconds (files took 11.66 seconds to load)
42 examples, 0 failures

Randomized with seed 49746


real    1m48.184s
user    1m5.332s
sys     0m11.149s



on vm:

vagrant@weddit-devbox:/app/editorial-cms/components/admin_ui$ time ./test.sh
>>> Testing admin ui
.......................................DEPRECATION WARNING: Passing string argument to #within_window is deprecated. Pass window object or lambda. (called from /app/editorial-cms/components/admin_ui/spec/features/preview/article_mobile_spec.rb:26)
Viewport argument key "minimal-ui" not recognized and ignored.
tag manager
....................DEPRECATION WARNING: Passing string argument to #within_window is deprecated. Pass window object or lambda. (called from /app/editorial-cms/components/admin_ui/spec/features/visual_editor/preview_article_mobile_spec.rb:27)
.*............DEPRECATION WARNING: Passing string argument to #within_window is deprecated. Pass window object or lambda. (called from /app/editorial-cms/components/admin_ui/spec/features/visual_editor/preview_article_spec.rb:22)
Viewport argument key "minimal-ui" not recognized and ignored.
tag manager
...........DEPRECATION WARNING: Passing string argument to #within_window is deprecated. Pass window object or lambda. (called from /app/editorial-cms/components/admin_ui/spec/features/preview/article_spec.rb:23)
Viewport argument key "minimal-ui" not recognized and ignored.
tag manager
..................................................................................................DEPRECATION WARNING: Passing string argument to #within_window is deprecated. Pass window object or lambda. (called from /app/editorial-cms/components/admin_ui/spec/features/preview/slideshow_spec.rb:35)
Viewport argument key "minimal-ui" not recognized and ignored.
tag manager
..*........

Pending:
  AdminUi::ContentItemsSortableLinksHelper with a filter with descending sorting option parameter should display a link to acending (a to z) sorting
    # No reason given
    # ./spec/helpers/admin_ui/articles_sortable_links_helper_spec.rb:71
  Editor uploading primary image on invalid article Warn the user about validation errors
    # ignored for now will have to be dealt with later -- upload image to tmp folder?
    # ./spec/features/article_image_spec.rb:101

Finished in 3 minutes 24.8 seconds (files took 10.98 seconds to load)
193 examples, 0 failures, 2 pending

Randomized with seed 22964

Waiting for jasmine server on 54924...
Waiting for jasmine server on 54924...
Waiting for jasmine server on 54924...
Waiting for jasmine server on 54924...
Waiting for jasmine server on 54924...
[2015-02-26 17:16:36] INFO  WEBrick 1.3.1
[2015-02-26 17:16:36] INFO  ruby 2.1.0 (2013-12-25) [i686-linux]
[2015-02-26 17:16:36] INFO  WEBrick::HTTPServer#start: pid=10388 port=54924
Waiting for jasmine server on 54924...
jasmine server started.
..........................*....*..............

46 specs, 0 failures, 2 pending specs
[2015-02-26 17:17:31] INFO  going to shutdown ...
[2015-02-26 17:17:31] INFO  WEBrick::HTTPServer#start done.

real    4m51.342s
user    1m29.338s
sys     0m20.325s




on local:

eteotti:~/code/xogrp/editorial-cms/components/admin_ui (master) |$ time ./test.sh
>>> Testing admin ui
.......................*....................................................................DEPRECATION WARNING: Passing string argument to #within_window is deprecated. Pass window object or lambda. (called from /Users/eteotti/code/xogrp/editorial-cms/components/admin_ui/spec/features/visual_editor/preview_article_mobile_spec.rb:27)
tag manager
.........................................DEPRECATION WARNING: Passing string argument to #within_window is deprecated. Pass window object or lambda. (called from /Users/eteotti/code/xogrp/editorial-cms/components/admin_ui/spec/features/visual_editor/preview_article_spec.rb:22)
Viewport argument key "minimal-ui" not recognized and ignored.
tag manager
...........DEPRECATION WARNING: Passing string argument to #within_window is deprecated. Pass window object or lambda. (called from /Users/eteotti/code/xogrp/editorial-cms/components/admin_ui/spec/features/preview/article_spec.rb:23)
Viewport argument key "minimal-ui" not recognized and ignored.
tag manager
..DEPRECATION WARNING: Passing string argument to #within_window is deprecated. Pass window object or lambda. (called from /Users/eteotti/code/xogrp/editorial-cms/components/admin_ui/spec/features/preview/slideshow_spec.rb:35)
Viewport argument key "minimal-ui" not recognized and ignored.
tag manager
..........................................*...DEPRECATION WARNING: Passing string argument to #within_window is deprecated. Pass window object or lambda. (called from /Users/eteotti/code/xogrp/editorial-cms/components/admin_ui/spec/features/preview/article_mobile_spec.rb:26)
Viewport argument key "minimal-ui" not recognized and ignored.
tag manager
.

Pending:
  Editor uploading primary image on invalid article Warn the user about validation errors
    # ignored for now will have to be dealt with later -- upload image to tmp folder?
    # ./spec/features/article_image_spec.rb:101
  AdminUi::ContentItemsSortableLinksHelper with a filter with descending sorting option parameter should display a link to acending (a to z) sorting
    # No reason given
    # ./spec/helpers/admin_ui/articles_sortable_links_helper_spec.rb:71

Finished in 3 minutes 24.1 seconds (files took 1.79 seconds to load)
193 examples, 0 failures, 2 pending

Randomized with seed 33966

[2015-02-26 15:14:06] INFO  WEBrick 1.3.1
[2015-02-26 15:14:06] INFO  ruby 2.1.0 (2013-12-25) [x86_64-darwin13.0]
[2015-02-26 15:14:06] INFO  WEBrick::HTTPServer#start: pid=37435 port=62123
Waiting for jasmine server on 62123...
jasmine server started.
..........................*....*..............

46 specs, 0 failures, 2 pending specs
[2015-02-26 15:14:09] INFO  going to shutdown ...
[2015-02-26 15:14:09] INFO  WEBrick::HTTPServer#start done.

real    3m35.405s
user    1m36.912s
sys     0m9.407s
