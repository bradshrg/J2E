# _Archive

Throwaway one-off helper scripts moved out of the working tree. None of these are
imported or run by the app. They were scratch scripts from an iterative debugging loop
over the homepage banner/logo and i18n setup.

WARNING before re-running any of them:
  - They use macOS-only `sed -i ''` and will misbehave on Linux.
  - Many hardcode `/Users/robin/Desktop/J2E/...` paths that don't exist here.
  - They target stale line numbers in HomePage.js.

Copy a file back to its original path first if you ever need to reference/run it.
The canonical react-auto-intl config (`frontend/.rairc`) was intentionally KEPT in place.
