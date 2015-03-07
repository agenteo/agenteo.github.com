---
published: false
---
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






all on VM



real    7m22.225s
user    2m5.656s
sys     0m38.494s





visit index page:

```


19:13:58 web.1  | 10.0.2.2 - - [27/Feb/2015 19:13:58] "GET /content HTTP/1.1" 200 61339 5.0396
19:13:58 web.1  | 10.0.2.2 - - [27/Feb/2015 19:13:58] "GET /public_ui/vendor/owl.carousel.css?body=1 HTTP/1.1" 200 4615 0.0732
19:13:58 web.1  | 10.0.2.2 - - [27/Feb/2015 19:13:58] "GET /public_ui/vendor/owl.theme.default.css?body=1 HTTP/1.1" 200 1395 0.0577
19:13:58 web.1  | 10.0.2.2 - - [27/Feb/2015 19:13:58] "GET /public_ui/_carousel.css?body=1 HTTP/1.1" 200 8117 0.0564
19:13:58 web.1  | 10.0.2.2 - - [27/Feb/2015 19:13:58] "GET /public_ui/_variables.css?body=1 HTTP/1.1" 200 - 0.0575
19:13:58 web.1  | 10.0.2.2 - - [27/Feb/2015 19:13:58] "GET /public_ui/_whats-new.css?body=1 HTTP/1.1" 200 225 0.0544
19:13:58 web.1  | 10.0.2.2 - - [27/Feb/2015 19:13:58] "GET /public_ui/application.css?body=1 HTTP/1.1" 200 652 0.0694
19:13:58 web.1  | 10.0.2.2 - - [27/Feb/2015 19:13:58] "GET /shared_ui/_variables.css?body=1 HTTP/1.1" 200 - 0.0605
19:13:58 web.1  | 10.0.2.2 - - [27/Feb/2015 19:13:58] "GET /shared_ui/content_piece.css?body=1 HTTP/1.1" 200 16643 0.0579
19:13:58 web.1  | 10.0.2.2 - - [27/Feb/2015 19:13:58] "GET /shared_ui/list_pieces.css?body=1 HTTP/1.1" 200 6587 0.0578
19:13:59 web.1  | 10.0.2.2 - - [27/Feb/2015 19:13:59] "GET /shared_ui/pattern_library_amends.css?body=1 HTTP/1.1" 200 1793 0.0570
19:13:59 web.1  | 10.0.2.2 - - [27/Feb/2015 19:13:59] "GET /shared_ui/question_and_answer.css?body=1 HTTP/1.1" 200 1205 0.0596
19:13:59 web.1  | 10.0.2.2 - - [27/Feb/2015 19:13:59] "GET /shared_ui/application.css?body=1 HTTP/1.1" 200 650 0.0824
19:13:59 web.1  | 10.0.2.2 - - [27/Feb/2015 19:13:59] "GET /public_ui/vendor/owl.carousel.js?body=1 HTTP/1.1" 200 79153 0.0589
19:13:59 web.1  | 10.0.2.2 - - [27/Feb/2015 19:13:59] "GET /public_ui/analytics.js?body=1 HTTP/1.1" 200 3623 0.0630
19:13:59 web.1  | 10.0.2.2 - - [27/Feb/2015 19:13:59] "GET /public_ui/analytics/clicks/anchor-external.js?body=1 HTTP/1.1" 200 694 0.0679
19:13:59 web.1  | 10.0.2.2 - - [27/Feb/2015 19:13:59] "GET /public_ui/analytics/clicks/anchor-internal.js?body=1 HTTP/1.1" 200 656 0.0555
19:13:59 web.1  | 10.0.2.2 - - [27/Feb/2015 19:13:59] "GET /public_ui/analytics/clicks/breadcrumb.js?body=1 HTTP/1.1" 200 879 0.0614
19:13:59 web.1  | 10.0.2.2 - - [27/Feb/2015 19:13:59] "GET /public_ui/analytics/clicks/carousel-item.js?body=1 HTTP/1.1" 200 918 0.0543
19:13:59 web.1  | 10.0.2.2 - - [27/Feb/2015 19:13:59] "GET /public_ui/analytics/clicks/content-filter-list.js?body=1 HTTP/1.1" 200 952 0.0557
19:13:59 web.1  | 10.0.2.2 - - [27/Feb/2015 19:13:59] "GET /public_ui/analytics/clicks/more-must-read.js?body=1 HTTP/1.1" 200 976 0.0543
19:13:59 web.1  | 10.0.2.2 - - [27/Feb/2015 19:13:59] "GET /public_ui/analytics/clicks/next-up.js?body=1 HTTP/1.1" 200 944 0.0561
19:13:59 web.1  | 10.0.2.2 - - [27/Feb/2015 19:13:59] "GET /public_ui/analytics/clicks/pagination.js?body=1 HTTP/1.1" 200 1771 0.0602
19:13:59 web.1  | 10.0.2.2 - - [27/Feb/2015 19:13:59] "GET /public_ui/analytics/clicks/photo-card.js?body=1 HTTP/1.1" 200 2116 0.0513
19:13:59 web.1  | 10.0.2.2 - - [27/Feb/2015 19:13:59] "GET /public_ui/analytics/clicks/term-tag.js?body=1 HTTP/1.1" 200 825 0.0534
19:13:59 web.1  | 10.0.2.2 - - [27/Feb/2015 19:13:59] "GET /public_ui/analytics/clicks/view-more-content-button.js?body=1 HTTP/1.1" 200 867 0.0556
19:14:00 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:00] "GET /public_ui/analytics/views/carousel-item.js?body=1 HTTP/1.1" 200 1204 0.0513
19:14:00 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:00] "GET /public_ui/analytics/views/more-must-read.js?body=1 HTTP/1.1" 200 1221 0.0538
19:14:00 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:00] "GET /public_ui/analytics/views/next-up.js?body=1 HTTP/1.1" 200 1161 0.0523
19:14:00 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:00] "GET /public_ui/analytics/views/photo-card.js?body=1 HTTP/1.1" 200 1763 0.0668
19:14:00 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:00] "GET /public_ui/analytics/views/slideshow-slide.js?body=1 HTTP/1.1" 200 1087 0.0505
19:14:00 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:00] "GET /public_ui/base.js?body=1 HTTP/1.1" 200 2074 0.0611
19:14:00 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:00] "GET /public_ui/carousel.js?body=1 HTTP/1.1" 200 1971 0.0509
19:14:00 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:00] "GET /public_ui/xo.ad_renderer.js?body=1 HTTP/1.1" 200 3309 0.0534
19:14:00 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:00] "GET /public_ui/application.js?body=1 HTTP/1.1" 200 4 0.1317
19:14:00 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:00] "GET /jquery_ujs.js?body=1 HTTP/1.1" 200 17510 0.0619
19:14:00 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:00] "GET /shared_ui/vendor/jquery.succinct.js?body=1 HTTP/1.1" 200 982 0.0555
19:14:00 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:00] "GET /shared_ui/lazy-load-images.js?body=1 HTTP/1.1" 200 575 0.0568
19:14:00 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:00] "GET /shared_ui/dynamic_ad.js?body=1 HTTP/1.1" 200 790 0.0568
19:14:00 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:00] "GET /shared_ui/nav_term_renderer.js?body=1 HTTP/1.1" 200 1412 0.0577
19:14:00 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:00] "GET /shared_ui/vendor/jquery.scroll-monitor-1.0.8.js?body=1 HTTP/1.1" 200 10075 0.0637
19:14:00 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:00] "GET /shared_ui/vendor/scroll-monitor-1.0.8.js?body=1 HTTP/1.1" 200 10075 0.0559
19:14:01 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:01] "GET /shared_ui/application.js?body=1 HTTP/1.1" 200 587 0.0816




19:14:11 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:11] "GET /content HTTP/1.1" 200 61339 1.5285
19:14:11 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:11] "GET /public_ui/vendor/owl.carousel.css?body=1 HTTP/1.1" 304 - 0.0594
19:14:11 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:11] "GET /public_ui/vendor/owl.theme.default.css?body=1 HTTP/1.1" 304 - 0.0484
19:14:12 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:12] "GET /public_ui/_carousel.css?body=1 HTTP/1.1" 304 - 0.0539
19:14:12 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:12] "GET /public_ui/_variables.css?body=1 HTTP/1.1" 304 - 0.0453
19:14:12 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:12] "GET /public_ui/_whats-new.css?body=1 HTTP/1.1" 304 - 0.0525
19:14:12 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:12] "GET /public_ui/application.css?body=1 HTTP/1.1" 304 - 0.0493
19:14:12 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:12] "GET /shared_ui/_variables.css?body=1 HTTP/1.1" 304 - 0.0492
19:14:12 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:12] "GET /shared_ui/content_piece.css?body=1 HTTP/1.1" 304 - 0.0471
19:14:12 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:12] "GET /shared_ui/list_pieces.css?body=1 HTTP/1.1" 304 - 0.0538
19:14:12 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:12] "GET /shared_ui/pattern_library_amends.css?body=1 HTTP/1.1" 304 - 0.0494
19:14:12 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:12] "GET /shared_ui/question_and_answer.css?body=1 HTTP/1.1" 304 - 0.0506
19:14:12 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:12] "GET /shared_ui/application.css?body=1 HTTP/1.1" 304 - 0.0472
19:14:12 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:12] "GET /public_ui/vendor/owl.carousel.js?body=1 HTTP/1.1" 304 - 0.0509
19:14:12 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:12] "GET /public_ui/analytics.js?body=1 HTTP/1.1" 304 - 0.0496
19:14:12 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:12] "GET /public_ui/analytics/clicks/anchor-external.js?body=1 HTTP/1.1" 304 - 0.0547
19:14:12 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:12] "GET /public_ui/analytics/clicks/anchor-internal.js?body=1 HTTP/1.1" 304 - 0.0491
19:14:12 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:12] "GET /public_ui/analytics/clicks/breadcrumb.js?body=1 HTTP/1.1" 304 - 0.0492
19:14:12 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:12] "GET /public_ui/analytics/clicks/carousel-item.js?body=1 HTTP/1.1" 304 - 0.0479
19:14:12 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:12] "GET /public_ui/analytics/clicks/content-filter-list.js?body=1 HTTP/1.1" 304 - 0.0470
19:14:12 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:12] "GET /public_ui/analytics/clicks/more-must-read.js?body=1 HTTP/1.1" 304 - 0.0487
19:14:12 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:12] "GET /public_ui/analytics/clicks/next-up.js?body=1 HTTP/1.1" 304 - 0.0587
19:14:13 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:13] "GET /public_ui/analytics/clicks/pagination.js?body=1 HTTP/1.1" 304 - 0.0516
19:14:13 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:13] "GET /public_ui/analytics/clicks/photo-card.js?body=1 HTTP/1.1" 304 - 0.0482
19:14:13 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:13] "GET /public_ui/analytics/clicks/term-tag.js?body=1 HTTP/1.1" 304 - 0.0464
19:14:13 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:13] "GET /public_ui/analytics/clicks/view-more-content-button.js?body=1 HTTP/1.1" 304 - 0.0500
19:14:13 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:13] "GET /public_ui/analytics/views/carousel-item.js?body=1 HTTP/1.1" 304 - 0.0479
19:14:13 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:13] "GET /public_ui/analytics/views/more-must-read.js?body=1 HTTP/1.1" 304 - 0.0513
19:14:13 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:13] "GET /public_ui/analytics/views/next-up.js?body=1 HTTP/1.1" 304 - 0.0686
19:14:13 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:13] "GET /public_ui/analytics/views/photo-card.js?body=1 HTTP/1.1" 304 - 0.0512
19:14:13 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:13] "GET /public_ui/analytics/views/slideshow-slide.js?body=1 HTTP/1.1" 304 - 0.0466
19:14:13 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:13] "GET /public_ui/base.js?body=1 HTTP/1.1" 304 - 0.0477
19:14:13 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:13] "GET /public_ui/carousel.js?body=1 HTTP/1.1" 304 - 0.0535
19:14:13 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:13] "GET /public_ui/xo.ad_renderer.js?body=1 HTTP/1.1" 304 - 0.0489
19:14:13 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:13] "GET /public_ui/application.js?body=1 HTTP/1.1" 304 - 0.0515
19:14:13 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:13] "GET /jquery_ujs.js?body=1 HTTP/1.1" 304 - 0.0458
19:14:13 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:13] "GET /shared_ui/vendor/jquery.succinct.js?body=1 HTTP/1.1" 304 - 0.0472
[[19:14:13]] web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:13] "GET /shared_ui/lazy-load-images.js?body=1 HTTP/1.1" 304 - 0.0869
19:14:13 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:13] "GET /shared_ui/dynamic_ad.js?body=1 HTTP/1.1" 304 - 0.0631
19:14:14 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:14] "GET /shared_ui/nav_term_renderer.js?body=1 HTTP/1.1" 304 - 0.2924
19:14:14 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:14] "GET /shared_ui/vendor/jquery.scroll-monitor-1.0.8.js?body=1 HTTP/1.1" 304 - 0.0448
19:14:14 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:14] "GET /shared_ui/vendor/scroll-monitor-1.0.8.js?body=1 HTTP/1.1" 304 - 0.0419
19:14:14 web.1  | 10.0.2.2 - - [27/Feb/2015 19:14:14] "GET /shared_ui/application.js?body=1 HTTP/1.1" 304 - 0.0560



eteotti:~ |$ wrk -d120s http://localhost:9191/content
Running 2m test @ http://localhost:9191/content
  2 threads and 10 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    14.33s     2.19s   15.59s    94.00%
    Req/Sec     0.02      0.14     1.00     98.00%
  82 requests in 2.00m, 4.83MB read
  Socket errors: connect 0, read 0, write 0, timeout 518
Requests/sec:      0.68
Transfer/sec:     41.14KB
eteotti:~ |$




no NFS, 22.33s


eteotti:~ |$ wrk -d120s http://localhost:9191/content
Running 2m test @ http://localhost:9191/content
  2 threads and 10 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    32.22s     8.89s   37.24s    85.71%
    Req/Sec     0.00      0.00     0.00    100.00%
  32 requests in 2.00m, 1.88MB read
  Socket errors: connect 0, read 0, write 0, timeout 568
Requests/sec:      0.27
Transfer/sec:     16.05KB
o

NFS 7s, 5s



real    5m53.687s
user    2m6.300s
sys     0m19.713s
