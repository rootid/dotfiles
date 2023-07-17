
;; Initialize package sources
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

;; org mode is installed already if you use Emacs version >= 24
(require 'org)
(add-hook 'org-mode-hook 'org-babel-mode)
(setq org-babel-default-language "emacs-lisp")
(setq org-babel-load-languages '((emacs-lisp . t) (python . t)))

(org-babel-load-file (expand-file-name "~/emacs_config/basic.org"))
