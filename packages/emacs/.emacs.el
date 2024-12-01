;; Initializ package sources
(require 'package)

;; package-archives keeps track of all existing sources of packages 
;; (setq variable value) - set value to variable 
(setq package-archives '(("melpa" . "https://melpa.org/packages/") 
			 ("org" . "https://orgmode.org/elpa/") 
			 ("elpa" . "https://elpa.gnu.org/packages/")))

;; No automatic package loading of packages 
(setq package-enable-at-startup nil)

;; Initialize the package system and load installed packages. 
(package-initialize) 

;; make sure package archive contents are updated
(unless package-archive-contents (package-refresh-contents))

;; install/update use-package if not available/latest version is updated
(unless (package-installed-p 'use-package)
(package-refresh-contents)
(package-install 'use-package))

;; TODO - Additional config https://protesilaos.com/emacs/modus-themes#h:f0f3dbcb-602d-40cf-b918-8f929c441baf
(add-to-list 'load-path "~/dotfiles/packages/emacs/emacs_themes/modus-themes")
(load-theme 'modus-operandi)            ; Light theme

;; TODO - Explore straight.el vs packge.el
;; Use of straight.el 
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; org mode is installed already if you use Emacs version >= 24
(require 'org)
(org-babel-load-file (expand-file-name "~/emacs_config/basic.org"))
