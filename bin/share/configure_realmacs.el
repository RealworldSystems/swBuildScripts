(message "Loading configure_realmacs.el")

(custom-set-variables
 '(aliases-user-file-list (append aliases-user-file-list (list (getenv "SW_WHICH_GIS_ALIAS_FILE"))))
 )

(aliases-update-sw-menu)
