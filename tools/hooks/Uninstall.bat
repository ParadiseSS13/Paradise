@call "%~dp0\..\bootstrap\python" -m hooks.install --uninstall %*
git config --unset merge.tgui-merge-bundle.driver
@pause
